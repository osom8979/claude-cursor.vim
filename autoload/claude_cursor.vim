" Autoload functions for claude-cursor.vim

if !g:claude_cursor_enabled
    finish
endif

let s:message_prefix = '[claude-cursor.vim] '
let s:terminal_visible = 0
let s:terminal_buffer_number = -1

function! claude_cursor#is_terminal_visible() abort
    return s:terminal_visible
endfunction

function! claude_cursor#toggle() abort
    if s:terminal_visible
        call claude_cursor#hide()
    else
        call claude_cursor#show()
    endif
endfunction

function! s:on_terminal_exit(job_id, code, event) abort
    if a:code == 0
        execute 'bdelete! ' . s:terminal_buffer_number
        let s:terminal_buffer_number = -1
        let s:terminal_visible = 0
    endif
endfunction

function! claude_cursor#show() abort
    if s:terminal_buffer_number != -1 && bufexists(s:terminal_buffer_number)
        let l:winid = bufwinid(s:terminal_buffer_number)
        if l:winid != -1
            " Window exists, jump to it
            call win_gotoid(l:winid)
        else
            " Buffer exists but not visible, open it.
            execute 'vertical botright ' . g:claude_cursor_terminal_width . 'split'
            execute 'buffer ' . s:terminal_buffer_number
        endif
    else
        " Create new terminal
        execute 'vertical botright ' . g:claude_cursor_terminal_width . 'split'
        enew
        let s:terminal_buffer_number = bufnr('%')
        call termopen(g:claude_cursor_executable, {
                    \ 'on_exit': function('s:on_terminal_exit')
                    \ })
        setlocal nobuflisted
        setlocal bufhidden=hide
        setlocal nonumber
        setlocal norelativenumber
    endif

    startinsert

    let s:terminal_visible = 1
    echo "Claude Code terminal is now visible"
endfunction

function! claude_cursor#hide() abort
    if s:terminal_buffer_number != -1 && bufexists(s:terminal_buffer_number)
        let l:winid = bufwinid(s:terminal_buffer_number)
        if l:winid != -1
            call win_execute(l:winid, 'close')
        endif
    endif

    let s:terminal_visible = 0
    echo "Claude Code terminal is now hidden"
endfunction

function! claude_cursor#focus() abort
    if s:terminal_buffer_number != -1 && bufexists(s:terminal_buffer_number)
        let l:winid = bufwinid(s:terminal_buffer_number)
        if l:winid != -1
            call win_gotoid(l:winid)
            startinsert
        endif
    endif
endfunction

function! s:get_current_file() abort
    return expand('%:p')
endfunction

function! s:get_current_line() abort
    return line('.')
endfunction

function! s:get_current_column() abort
    return col('.')
endfunction

function! s:get_selected_text()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]

    if (line2byte(line_start) + column_start) > (line2byte(line_end) + column_end)
        let [line_start, column_start, line_end, column_end] = [line_end, column_end, line_start, column_start]
    endif

    let lines = getline(line_start, line_end)

    if empty(lines)
        return ''
    endif

    let lines[-1] = lines[-1][: column_end - (&selection ==# 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]

    return join(lines, "\n")
endfunction

let s:claude_progress_chars = ['-', '\', '|', '/']
let s:claude_progress_idx = 0
let s:claude_progress_timer = -1
let s:claude_progress_update_milliseconds = 100

function! s:has_airline()
    return exists('g:loaded_airline') && g:loaded_airline
endfunction

function! s:update_progress_char()
    let s:claude_progress_idx = (s:claude_progress_idx + 1) % len(s:claude_progress_chars)
    return s:claude_progress_chars[s:claude_progress_idx]
endfunction

function! s:on_update_progress()
    let l:next_progress_char = s:update_progress_char()

    " TODO: Implementation ...
endfunction

function! s:start_progress()
    let s:claude_progress_timer = timer_start(s:claude_progress_update_milliseconds, {-> s:on_update_progress()}, {'repeat': -1})
    let s:claude_progress_idx = 0
endfunction

function! s:stop_progress()
    if s:claude_progress_timer == -1
        return
    endif

    call timer_stop(s:claude_progress_timer)
    let s:claude_progress_timer = -1
    let s:claude_progress_idx = 0
endfunction

let s:claude_job_id = -1
let s:claude_stdout_buffer = []
let s:claude_stderr_buffer = []

function! claude_cursor#cancel_job()
    if s:claude_job_id != -1
        call jobstop(s:claude_job_id)
        call s:stop_progress()

        echohl WarningMsg
        echo s:message_prefix . "Job (" . s:claude_job_id . ") cancelled"
        echohl None

        let s:claude_job_id = -1
        let s:claude_stdout_buffer = []
        let s:claude_stderr_buffer = []
    else
        echohl WarningMsg
        echo s:message_prefix . "No running job"
        echohl None
    endif
endfunction

function! s:on_claude_stdout(job_id, data, event) abort
    for line in a:data
        if !empty(line)
            call add(s:claude_stdout_buffer, line)
            echom line
        endif
    endfor
endfunction

function! s:on_claude_stderr(job_id, data, event) abort
    for line in a:data
        if !empty(line)
            call add(s:claude_stderr_buffer, line)
            echom line
        endif
    endfor
endfunction

function! s:show_output_popup(lines) abort
    let l:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(l:buf, 0, -1, v:true, a:lines)

    " Calculate window size
    let l:width = min([max(map(copy(a:lines), 'strdisplaywidth(v:val)')), &columns - 10])
    let l:height = min([len(a:lines), &lines - 10])

    let l:opts = {
                \ 'relative': 'editor',
                \ 'width': l:width,
                \ 'height': l:height,
                \ 'col': (&columns - l:width) / 2,
                \ 'row': (&lines - l:height) / 2,
                \ 'style': 'minimal',
                \ 'border': 'rounded'
                \ }

    let l:win = nvim_open_win(l:buf, v:true, l:opts)

    " Set buffer options
    call nvim_buf_set_option(l:buf, 'modifiable', v:false)
    call nvim_buf_set_option(l:buf, 'filetype', 'markdown')

    " Close popup with q or <Esc>
    nnoremap <buffer> <silent> q :close<CR>
    nnoremap <buffer> <silent> <Esc> :close<CR>
endfunction

function! s:on_claude_exit(job_id, exit_code, event) abort
    call s:stop_progress()

    if a:exit_code == 0
        let l:output = join(s:claude_stdout_buffer, "\n")
        let @" = l:output

        call s:show_output_popup(s:claude_stdout_buffer)

        echo s:message_prefix . "Copy to unnamed register!"
    else
        echohl ErrorMsg
        echo s:message_prefix . "Failed with exit code " . a:exit_code
        echohl None
    endif

    let s:claude_job_id = -1
    let s:claude_stdout_buffer = []
    let s:claude_stderr_buffer = []
endfunction

function! claude_cursor#start_job(prompt, model)
    if s:claude_job_id != -1
        echohl WarningMsg
        echo s:message_prefix . "Already running"
        echohl None
        return
    endif

    let g:claude_cursor_target_file = s:get_current_file()
    let g:claude_cursor_target_line = s:get_current_line()
    let g:claude_cursor_target_column = s:get_current_column()

    let l:cmd = [
        \ g:claude_cursor_executable,
        \ '--model',
        \ a:model,
        \ '--print',
        \ a:prompt,
        \ ]

    let s:claude_stdout_buffer = []
    let s:claude_stderr_buffer = []

    let s:claude_job_id = jobstart(l:cmd, {
                \ 'on_stdout': function('s:on_claude_stdout'),
                \ 'on_stderr': function('s:on_claude_stderr'),
                \ 'on_exit': function('s:on_claude_exit'),
                \ 'stdout_buffered': v:false,
                \ 'stderr_buffered': v:false,
                \ 'pty': v:true,
                \ })

    if s:claude_job_id <= 0
        let s:claude_job_id = -1
        echohl ErrorMsg
        echo s:message_prefix . "Failed to start job"
        echohl None
        return
    endif

    call s:start_progress()
    echo s:message_prefix . "Job (" . s:claude_job_id . ") Running..."
endfunction

function! claude_cursor#suggest() abort
    let l:file = s:get_current_file()
    let l:line = s:get_current_line()

    let l:prompt = g:claude_cursor_suggest_prompt
    let l:prompt = substitute(l:prompt, '{F}', l:file, 'g')
    let l:prompt = substitute(l:prompt, '{N}', l:line, 'g')
    let l:model = g:claude_cursor_suggest_model

    call claude_cursor#start_job(l:prompt, l:model)
endfunction

function! claude_cursor#explain() abort
    let l:selected_text = s:get_selected_text()
    let l:file = s:get_current_file()
    let l:line = s:get_current_line()

    let l:prompt = g:claude_cursor_explain_prompt
    let l:prompt = substitute(l:prompt, '{F}', l:file, 'g')
    let l:prompt = substitute(l:prompt, '{N}', l:line, 'g')
    let l:prompt = substitute(l:prompt, '{T}', l:selected_text, 'g')
    let l:model = g:claude_cursor_explain_model

    call claude_cursor#start_job(l:prompt, l:model)
endfunction

