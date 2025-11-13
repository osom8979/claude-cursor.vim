" Autoload functions for claude-cursor.vim

let s:terminal_visible = 0
let s:terminal_buffer_number = -1
let s:terminal_width = g:claude_cursor_terminal_width
let s:terminal_executable = g:claude_cursor_executable

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
        execute 'vertical botright ' . s:terminal_width . 'split'
        enew
        let s:terminal_buffer_number = bufnr('%')
        call termopen(s:terminal_executable, {
                    \ 'on_exit': function('s:on_terminal_exit')
                    \ })
        setlocal nobuflisted
        setlocal bufhidden=hide
        setlocal nonumber
        setlocal norelativenumber
        startinsert
    endif

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

function! claude_cursor#set_width(width) abort
    let s:terminal_width = a:width

    " Resize if terminal is currently visible
    if s:terminal_visible && s:terminal_buffer_number != -1
        let l:winid = bufwinid(s:terminal_buffer_number)
        if l:winid != -1
            call win_execute(l:winid, 'vertical resize ' . s:terminal_width)
        endif
    endif
endfunction

function! claude_cursor#chat(query) abort
    "if !s:terminal_hidden
    "    echo 'Claude Cursor is disabled'
    "    return
    "endif
    "
    "if empty(g:claude_cursor_api_key)
    "    echo 'Error: g:claude_cursor_api_key is not set'
    "    return
    "endif
    "
    "if empty(a:query)
    "    let query = input('Ask Claude: ')
    "    if empty(query)
    "        return
    "    endif
    "else
    "    let query = a:query
    "endif
    "
    "echo 'Asking Claude: ' . query
    "" TODO: Implement actual API call
endfunction

function! claude_cursor#explain_selection() abort
    "if !s:enabled
    "    echo 'Claude Cursor is disabled'
    "    return
    "endif
    "
    "" Get visual selection
    "let [line_start, column_start] = getpos("'<")[1:2]
    "let [line_end, column_end] = getpos("'>")[1:2]
    "let lines = getline(line_start, line_end)
    "
    "if empty(lines)
    "    echo 'No selection found'
    "    return
    "endif
    "
    "let selected_text = join(lines, "\n")
    "echo 'Explaining selection: ' . selected_text[:50] . '...'
    "" TODO: Implement actual explanation
endfunction
