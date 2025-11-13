if !has('nvim')
    echohl ErrorMsg
    echomsg 'claude-cursor.vim requires Neovim'
    echohl None
    finish
endif

if exists('g:claude_cursor_loaded')
    finish
endif
let g:claude_cursor_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

" Default configuration
if !exists('g:claude_cursor_enabled')
    let g:claude_cursor_enabled = 1
endif

if !exists('g:claude_cursor_executable')
    let g:claude_cursor_executable = 'claude'
endif

if !exists('g:claude_cursor_terminal_width')
    let g:claude_cursor_terminal_width = 80
endif

" Commands
" command! -nargs=0 ClaudeCursorToggle     call claude_cursor#toggle()
" command! -nargs=0 ClaudeCursorFocus      call claude_cursor#focus()
" command! -nargs=* ClaudeCursorChat       call claude_cursor#chat(<q-args>)
" command! -nargs=0 ClaudeCursorExplain    call claude_cursor#explain_selection()
" command! -nargs=0 ClaudeCursorTranslate  call claude_cursor#translate_selection()
" command! -nargs=0 ClaudeCursorSuggest    call claude_cursor#suggest()

" Mappings
if g:claude_cursor_enabled
    " nnoremap <silent> <Plug>cct :ClaudeCursorToggle<CR>
    " vnoremap <silent> <Plug>cce :ClaudeCursorExplain<CR>
    " nnoremap <silent> <Plug>ccc :ClaudeCursorChat<CR>
    " nnoremap <silent> <Plug>ClaudeCursorToggle :ClaudeCursorToggle<CR>
    " nnoremap <silent> <Plug>ClaudeCursor :call s:LoadData()<CR>
endif

let &cpo = s:save_cpo
unlet s:save_cpo