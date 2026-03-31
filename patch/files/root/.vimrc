syntax off
filetype indent on
colorscheme desert
hi Normal ctermbg=none
hi EndOfBuffer ctermfg=241 ctermbg=none

set nocompatible
set bs=2 tw=0 so=2 ls=1
set ts=4 sts=4 sw=4
set noswf nobk noudf nolz tf
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
cnoremap <c-a> <home>
vnoremap < <gv
vnoremap > >gv
