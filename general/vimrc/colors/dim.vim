" Terminal Color Configure
" +-------------------------------------+
" | Num  |         RGB        |   Hex   |
" |------+--------------------+---------|
" | FG   | rgb(255, 255, 255) | #ffffff |
" |------+--------------------+---------|
" | BG   | rgb(41, 44, 54)    | #292c36 |
" |------+--------------------+---------|
" | bold | rgb(255, 255, 255) | #ffffff |
" |------+--------------------+---------|
" | #0   | rgb(41, 44, 54)    | #292c36 |
" |------+--------------------+---------|
" | #1   | rgb(220, 60, 60)   | #dc3c3c |
" |------+--------------------+---------|
" | #2   | rgb(149, 199, 111) | #95c76f |
" |------+--------------------+---------|
" | #3   | rgb(210, 142, 93)  | #d28e5d |
" |------+--------------------+---------|
" | #4   | rgb(132, 133, 206) | #8485ce |
" |------+--------------------+---------|
" | #5   | rgb(183, 57, 153)  | #b73999 |
" |------+--------------------+---------|
" | #6   | rgb(0, 171, 165)   | #00aba5 |
" |------+--------------------+---------|
" | #7   | rgb(168, 171, 181) | #a8abb5 |
" |------+--------------------+---------|
" | #8   | rgb(66, 69, 79)    | #42454f |
" |------+--------------------+---------|
" | #9   | rgb(255, 124, 124) | #ff7c7c |
" |------+--------------------+---------|
" | #10  | rgb(213, 255, 175) | #d5ffaf |
" |------+--------------------+---------|
" | #11  | rgb(255, 206, 157) | #ffce9d |
" |------+--------------------+---------|
" | #12  | rgb(196, 197, 255) | #c4c5ff |
" |------+--------------------+---------|
" | #13  | rgb(247, 121, 217) | #f779d9 |
" |------+--------------------+---------|
" | #14  | rgb(64, 235, 229)  | #40ebe5 |
" |------+--------------------+---------|
" | #15  | rgb(255, 255, 255) | #ffffff |
" +------+--------------------+---------+


highlight clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "dim"

" In diffs, added lines are green, changed lines are yellow, deleted lines are
" red, and changed text (within a changed line) is bright yellow and bold.
highlight DiffAdd        ctermfg=0    ctermbg=2
highlight DiffChange     ctermfg=0    ctermbg=3
highlight DiffDelete     ctermfg=0    ctermbg=1
highlight DiffText       ctermfg=0    ctermbg=11   cterm=bold

" Invert selected lines in visual mode
highlight Visual         ctermfg=NONE ctermbg=NONE cterm=inverse

" Highlight search matches in black, with a yellow background
highlight Search         ctermfg=0    ctermbg=11

" Dim line numbers, comments, color columns, the status line, splits and sign
" columns.
if &background == "light"
  highlight LineNr       ctermfg=7
  highlight CursorLineNr ctermfg=8
  highlight Comment      ctermfg=7
  highlight ColorColumn  ctermfg=8    ctermbg=7
  highlight Folded       ctermfg=8    ctermbg=7
  highlight FoldColumn   ctermfg=8    ctermbg=7
  highlight Pmenu        ctermfg=0    ctermbg=7
  highlight PmenuSel     ctermfg=7    ctermbg=0
  highlight SpellCap     ctermfg=8    ctermbg=7
  highlight StatusLine   ctermfg=0    ctermbg=7    cterm=bold
  highlight StatusLineNC ctermfg=8    ctermbg=7    cterm=NONE
  highlight VertSplit    ctermfg=8    ctermbg=7    cterm=NONE
  highlight SignColumn                ctermbg=7
  highlight TabLine      ctermfg=7    ctermbg=NONE
else
  highlight LineNr       ctermfg=8
  highlight CursorLineNr ctermfg=7
  highlight Comment      ctermfg=8
  highlight ColorColumn  ctermfg=7    ctermbg=8
  highlight Folded       ctermfg=7    ctermbg=8
  highlight FoldColumn   ctermfg=7    ctermbg=8
  highlight Pmenu        ctermfg=15   ctermbg=8
  highlight PmenuSel     ctermfg=8    ctermbg=15
  highlight SpellCap     ctermfg=7    ctermbg=8
  highlight StatusLine   ctermfg=15   ctermbg=8    cterm=bold
  highlight StatusLineNC ctermfg=7    ctermbg=8    cterm=NONE
  highlight VertSplit    ctermfg=7    ctermbg=8    cterm=NONE
  highlight SignColumn                ctermbg=8
  highlight TabLine      ctermfg=8    ctermbg=NONE
endif

highlight TabLineSel                  ctermbg=NONE
highlight! link TabLineFill TabLine

highlight link DimFzfFg     Normal
highlight link DimFzfBg     Normal
highlight link DimFzfFgPlus PmenuSel
highlight link DimFzfBgPlus PmenuSel
highlight link DimFzfInfo   Comment

highlight DimFzfHl      ctermfg=2
highlight DimFzfPrompt  ctermfg=12
highlight DimFzfPointer ctermfg=1
highlight DimFzfMarker  ctermfg=9

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
