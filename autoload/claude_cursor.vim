" Autoload functions for claude-cursor.vim

let s:enabled = 1

function! claude_cursor#toggle() abort
  let s:enabled = !s:enabled
  if s:enabled
    echo 'Claude Cursor enabled'
  else
    echo 'Claude Cursor disabled'
  endif
endfunction

function! claude_cursor#chat(query) abort
  if !s:enabled
    echo 'Claude Cursor is disabled'
    return
  endif

  if empty(g:claude_cursor_api_key)
    echo 'Error: g:claude_cursor_api_key is not set'
    return
  endif

  if empty(a:query)
    let query = input('Ask Claude: ')
    if empty(query)
      return
    endif
  else
    let query = a:query
  endif

  echo 'Asking Claude: ' . query
  " TODO: Implement actual API call
endfunction

function! claude_cursor#explain_selection() abort
  if !s:enabled
    echo 'Claude Cursor is disabled'
    return
  endif

  " Get visual selection
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)

  if empty(lines)
    echo 'No selection found'
    return
  endif

  let selected_text = join(lines, "\n")
  echo 'Explaining selection: ' . selected_text[:50] . '...'
  " TODO: Implement actual explanation
endfunction

function! claude_cursor#is_enabled() abort
  return s:enabled
endfunction