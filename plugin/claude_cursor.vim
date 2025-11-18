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

if !exists('g:claude_cursor_target_file')
    let g:claude_cursor_target_file = ''
endif

if !exists('g:claude_cursor_target_line')
    let g:claude_cursor_target_line = -1
endif

if !exists('g:claude_cursor_target_column')
    let g:claude_cursor_target_column = -1
endif

if !exists('g:claude_cursor_request_prompt')
    let g:claude_cursor_request_prompt = 'Do you have any additional requests?'
endif

if !exists('g:claude_cursor_korean_to_english_prompt')
    let g:claude_cursor_korean_to_english_prompt = 'Translate the following Korean text to English: '
endif

let s:default_suggest_prompt_lines = [
    \ "You are an expert computer programmer with deep knowledge of software engineering best practices.",
    \ "Suggest code to add at line {N} of {F}. Requirements:",
    \ "1. Code must be in English.",
    \ "2. Add a Korean comment below explaining why this addition is needed.",
    \ "3. Do not apply any formatting such as Markdown or code blocks.",
    \ "4. Output only the code and code's comment, nothing else.",
    \ "5. Match the existing indentation level and code style of the file.",
    \ "6. Consider the context of surrounding code (above and below).",
    \ "7. Use appropriate naming conventions consistent with the existing code.",
    \ "8. Keep suggestions concise and focused on the specific line position."
    \ ]

if !exists('g:claude_cursor_suggest_prompt')
    let g:claude_cursor_suggest_prompt = join(s:default_suggest_prompt_lines, "\n")
endif

let s:default_explain_prompt_lines = [
    \ "You are an expert computer programmer with deep knowledge of software engineering and code analysis.",
    \ "Explain the selected code from line {N} in {F}. Requirements:",
    \ "1. Explain in Korean.",
    \ "2. Describe what the code does and its purpose.",
    \ "3. Explain how it works technically (algorithms, data flow, logic).",
    \ "4. Mention its role in the context of surrounding code.",
    \ "5. Point out any notable patterns, best practices, or potential issues.",
    \ "6. Do not apply any formatting such as Markdown or code blocks.",
    \ "7. Output plain text explanation only.",
    \ "8. Keep the explanation clear, concise, and technically accurate.",
    \ "",
    \ "Selected code:",
    \ "{T}"
    \ ]

if !exists('g:claude_cursor_explain_prompt')
    let g:claude_cursor_explain_prompt = join(s:default_explain_prompt_lines, "\n")
endif

" Models
" https://docs.claude.com/en/docs/about-claude/models/overview#latest-models-comparison

" Sonnet 4.5 - Our smartest model for complex agents and coding
let s:default_sonnet_model = 'claude-sonnet-4-5-20250929'

" Haiku 4.5 - Our fastest model with near-frontier intelligence
let s:default_haiku_model = 'claude-haiku-4-5-20251001'

" Opus 4.1 - Exceptional model for specialized reasoning tasks
let s:default_opus_model = 'claude-opus-4-1-20250805'

if !exists('g:claude_cursor_suggest_model')
    let g:claude_cursor_suggest_model = s:default_haiku_model
endif

if !exists('g:claude_cursor_explain_model')
    let g:claude_cursor_explain_model = s:default_haiku_model
endif

" Commands
command! -nargs=0 ClaudeCursorToggle    call claude_cursor#toggle()
command! -nargs=0 ClaudeCursorFocus     call claude_cursor#focus()
command! -nargs=0 ClaudeCursorExplain   call claude_cursor#explain()
command! -nargs=0 ClaudeCursorSuggest   call claude_cursor#suggest()

" Mappings
if g:claude_cursor_enabled
    nnoremap <silent> <C-L>     <Esc>:ClaudeCursorToggle<CR>
    inoremap <silent> <C-L>     <Esc>:ClaudeCursorToggle<CR>
    cnoremap <silent> <C-L>     <Esc>:ClaudeCursorToggle<CR>
    xnoremap <silent> <C-L>     <Esc>:ClaudeCursorToggle<CR>
    snoremap <silent> <C-L>     <Esc>:ClaudeCursorToggle<CR>
    onoremap <silent> <C-L>     <Esc>:ClaudeCursorToggle<CR>
    tnoremap <silent> <C-L>     <C-\><C-N>:ClaudeCursorToggle<CR>

    nnoremap <silent> <C-K>     <Esc>:ClaudeCursorExplain<CR>
    vnoremap <silent> <C-K>     <Esc>:ClaudeCursorExplain<CR>

    nnoremap <silent> <C-Space> <Esc>:ClaudeCursorSuggest<CR>
    inoremap <silent> <C-K>     <Esc>:ClaudeCursorSuggest<CR>
endif

let &cpo = s:save_cpo
unlet s:save_cpo