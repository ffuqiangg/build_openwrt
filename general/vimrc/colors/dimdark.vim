set background=dark
highlight clear

if exists("syntax_on")
  syntax reset
endif

set t_Co=256
let colors_name = "dimdark"

highlight Visual       ctermfg=NONE ctermbg=237  cterm=inverse
highlight Search       ctermfg=235  ctermbg=180
highlight LineNr       ctermfg=238
highlight CursorLineNr ctermfg=11
highlight Comment      ctermfg=59
highlight ColorColumn               ctermbg=236
highlight Folded       ctermfg=59
highlight! link FoldColumn Folded
highlight Pmenu        ctermfg=145  ctermbg=237
highlight PmenuSel     ctermfg=236  ctermbg=39
highlight SpellCap     ctermfg=173  ctermbg=12
highlight StatusLine   ctermfg=145  ctermbg=236  cterm=bold
highlight StatusLineNC ctermfg=59   ctermbg=236  cterm=NONE
highlight VertSplit    ctermfg=59                cterm=NONE
highlight SignColumn                ctermbg=242
highlight TabLine      ctermfg=242  ctermbg=NONE cterm=NONE
highlight TabLineSel   ctermfg=145  ctermbg=NONE cterm=NONE
highlight! link TabLineFill TabLine
