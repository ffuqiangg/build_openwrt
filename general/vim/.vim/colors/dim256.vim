highlight clear

if exists("syntax_on")
  syntax reset
endif

set t_Co=256
let colors_name = "dim256"

" In diffs, added lines are green, changed lines are yellow, deleted lines are
" red, and changed text (within a changed line) is bright yellow and bold.
highlight DiffAdd        ctermfg=59    ctermbg=71
highlight DiffChange     ctermfg=59    ctermbg=214
highlight DiffDelete     ctermfg=59    ctermbg=149
highlight DiffText       ctermfg=59    ctermbg=227   cterm=bold

" Invert selected lines in visual mode
highlight Visual         ctermfg=NONE ctermbg=NONE cterm=inverse

" Highlight search matches in black, with a yellow background
highlight Search         ctermfg=59    ctermbg=227

" Dim line numbers, comments, color columns, the status line, splits and sign
" columns.
if &background == "light"
  highlight LineNr       ctermfg=249
  highlight CursorLineNr ctermfg=240
  highlight Comment      ctermfg=249
  highlight ColorColumn  ctermfg=240    ctermbg=249
  highlight Folded       ctermfg=240    ctermbg=249
  highlight FoldColumn   ctermfg=240    ctermbg=249
  highlight Pmenu        ctermfg=59    ctermbg=249
  highlight PmenuSel     ctermfg=249   ctermbg=59
  highlight SpellCap     ctermfg=240    ctermbg=249
  highlight StatusLine   ctermfg=59    ctermbg=249   cterm=bold
  highlight StatusLineNC ctermfg=240    ctermbg=249   cterm=NONE
  highlight VertSplit    ctermfg=240    ctermbg=249   cterm=NONE
  highlight SignColumn                ctermbg=249
  highlight TabLine      ctermfg=240   ctermbg=NONE
  highlight TabLineSel                 ctermbg=NONE
  highlight! link TabLineFill TabLine
else
  highlight LineNr       ctermfg=240
  highlight CursorLineNr ctermfg=249
  highlight Comment      ctermfg=240
  highlight ColorColumn  ctermfg=249   ctermbg=240
  highlight Folded       ctermfg=249   ctermbg=240
  highlight FoldColumn   ctermfg=249   ctermbg=240
  highlight Pmenu        ctermfg=255   ctermbg=240
  highlight PmenuSel     ctermfg=240   ctermbg=255
  highlight SpellCap     ctermfg=249   ctermbg=240
  highlight StatusLine   ctermfg=255   ctermbg=240    cterm=bold
  highlight StatusLineNC ctermfg=249   ctermbg=240    cterm=NONE
  highlight VertSplit    ctermfg=249   ctermbg=240    cterm=NONE
  highlight SignColumn                 ctermbg=240
  highlight TabLine      ctermfg=240   ctermbg=NONE
  highlight TabLineSel                 ctermbg=NONE
  highlight! link TabLineFill TabLine
endif

highlight link DimFzfFg     Normal
highlight link DimFzfBg     Normal
highlight link DimFzfFgPlus PmenuSel
highlight link DimFzfBgPlus PmenuSel
highlight link DimFzfInfo   Comment

highlight DimFzfHl      ctermfg=71
highlight DimFzfPrompt  ctermfg=75
highlight DimFzfPointer ctermfg=149
highlight DimFzfMarker  ctermfg=203

let g:fzf_colors = { 'fg':      ['fg', 'DimFzfFg'],
                   \ 'bg':      ['bg', 'DimFzfBg'],
                   \ 'hl':      ['fg', 'DimFzfHl'],
                   \ 'fg+':     ['fg', 'DimFzfFgPlus'],
                   \ 'bg+':     ['bg', 'DimFzfbgPlus'],
                   \ 'hl+':     ['fg', 'DimFzfHl'],
                   \ 'info':    ['fg', 'DimFzfInfo'],
                   \ 'prompt':  ['fg', 'DimFzfPrompt'],
                   \ 'pointer': ['fg', 'DimFzfPointer'],
                   \ 'marker':  ['fg', 'DimFzfMarker']}
