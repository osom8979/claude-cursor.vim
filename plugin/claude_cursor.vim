" claude-cursor.vim - Claude integration for Vim/Neovim
" Maintainer: Your Name
" Version: 0.1.0

if exists('g:loaded_claude_cursor')
  finish
endif
let g:loaded_claude_cursor = 1

let s:save_cpo = &cpo
set cpo&vim

" Default configuration
if !exists('g:claude_cursor_enabled')
  let g:claude_cursor_enabled = 1
endif

if !exists('g:claude_cursor_api_key')
  let g:claude_cursor_api_key = ''
endif

" Commands
command! -nargs=0 ClaudeToggle call claude_cursor#toggle()
command! -nargs=* ClaudeChat call claude_cursor#chat(<q-args>)
command! -nargs=0 ClaudeExplain call claude_cursor#explain_selection()

" Mappings
if g:claude_cursor_enabled
  nnoremap <silent> <leader>ct :ClaudeToggle<CR>
  vnoremap <silent> <leader>ce :ClaudeExplain<CR>
  nnoremap <silent> <leader>cc :ClaudeChat<CR>
endif

let &cpo = s:save_cpo
unlet s:save_cpo