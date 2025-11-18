# claude-cursor.vim

[![GitHub](https://img.shields.io/github/license/osom8979/claude-cursor.vim?style=flat-square)](https://github.com/osom8979/claude-cursor.vim/)

Seamless Claude Code CLI integration for Neovim

## Features

- **Terminal Integration**: Toggle a Claude Code terminal within Neovim
- **Code Explanation**: Get AI explanations for selected code or current line
- **Code Suggestions**: Receive intelligent code suggestions at cursor position
- **Customizable Models**: Choose between different Claude models (Sonnet, Haiku, Opus)
- **Korean Support**: Built-in Korean language support for explanations
- **Progress Indicators**: Visual feedback during AI processing

## Requirements

- Neovim (this plugin does not work with Vim)
- [Claude Code CLI](https://claude.ai/code) installed and configured

## Installation

### Using vim-plug
```vim
Plug 'osom8979/claude-cursor.vim'
```

### Using lazy.nvim
```lua
{
    'osom8979/claude-cursor.vim',
    config = function()
        vim.g.claude_cursor_enabled = 1
        vim.g.claude_cursor_terminal_width = 100
    end
}
```

### Using Packer
```lua
use 'osom8979/claude-cursor.vim'
```

## Configuration

```vim
" Enable the plugin (default: 1)
let g:claude_cursor_enabled = 1

" Claude Code CLI executable path (default: 'claude')
let g:claude_cursor_executable = 'claude'

" Terminal window width (default: 80)
let g:claude_cursor_terminal_width = 100

" Models for different operations (defaults shown)
let g:claude_cursor_suggest_model = 'claude-haiku-4-5-20251001'
let g:claude_cursor_explain_model = 'claude-haiku-4-5-20251001'
```

## Key Mappings

| Key | Mode | Action |
|-----|------|--------|
| `<C-L>` | All | Toggle Claude Code terminal |
| `<C-K>` | Normal/Visual | Explain selection or current line |
| `<C-Space>` | Normal | Get code suggestions |
| `<C-K>` | Insert | Get code suggestions |

## Commands

- `:ClaudeCursorToggle` - Toggle the Claude Code terminal
- `:ClaudeCursorFocus` - Focus on the Claude Code terminal
- `:ClaudeCursorExplain` - Explain selected text or current line
- `:ClaudeCursorSuggest` - Get code suggestions at cursor position

## Usage

1. **Terminal Access**: Press `<C-L>` to open/close the Claude Code terminal
2. **Code Explanation**: Select code and press `<C-K>` for AI explanation
3. **Code Suggestions**: Press `<C-Space>` (normal mode) or `<C-K>` (insert mode) for suggestions
4. **Focus Terminal**: Use `:ClaudeCursorFocus` to quickly jump to the terminal

## License

See the [LICENSE](./LICENSE) file for details. In summary,
**claude-cursor.vim** is licensed under the **MIT license**.
