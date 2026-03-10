syntax off
filetype indent on

set nocompatible
set bs=2 tw=0 so=2 ls=1
set ts=4 sts=4 sw=4
set noswf nobk noudf nolz tf
set fillchars=vert:│
set ttimeoutlen=100
set path+=**
set nowrap novb noeb sc
set hls is ic scs ai si et sr
set spr sb

au FileType yaml,json set ts=2 sts=2 sw=2
au FileType conf set noet
au BufRead,BufNewFile *.ut set ft=uc
au BufRead,BufNewFile /etc/init.d/* set ft=sh
au BufRead,BufNewFile /etc/config/* set ft=conf
au BufRead,BufNewFile *.log set ft=conf

nmap <c-j> <c-w>j
nmap <c-k> <c-w>k
nmap <c-h> <c-w>h
nmap <c-l> <c-w>l
nnoremap k gk
nnoremap gk k
nnoremap j gj
nnoremap gj j
nmap <s-h> gT
nmap <s-l> gt
imap <c-j> <c-o>o
imap <c-k> <c-o>O
cnoremap <c-a> <home>
cnoremap <c-e> <end>
vnoremap < <gv
vnoremap > >gv
imap n <down>
imap p <up>
imap b <left>
imap f <right>

hi TabLine cterm=none ctermfg=59 ctermbg=none
hi TabLineSel cterm=underline ctermfg=39 ctermbg=none
hi TabLineFill cterm=none ctermbg=none
hi Pmenu ctermfg=145 ctermbg=237
hi PmenuSel ctermfg=236 ctermbg=39
hi MatchParen cterm=underline ctermfg=39 ctermbg=none
hi VertSplit cterm=none ctermbg=none ctermfg=239
hi StatusLine cterm=none ctermfg=15 ctermbg=239
hi StatusLineNC cterm=none ctermfg=245 ctermbg=239
