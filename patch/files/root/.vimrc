syntax off
filetype indent on

set nocompatible
set bs=2 tw=0 so=2 ls=2
set ts=4 sts=4 sw=4
set noswf nobk noudf nolz
set fillchars=vert:│
set ttimeoutlen=100
set path+=**
set nowrap novb noeb
set hls is ic scs ai! si et sr

au FileType yaml,json set ts=2 sts=2 sw=2
au FileType conf set noet
au BufRead,BufNewFile *.ut set ft=uc
au BufRead,BufNewFile /etc/init.d/* set ft=sh
au BufRead,BufNewFile /etc/config/* set ft=conf
au BufRead,BufNewFile *.log set ft=conf

let mapleader="\<Space>"
nmap <leader>th <c-w>t<c-w>h
nmap <leader>tk <c-w>t<c-w>k
nmap <esc> :nohl<cr>
map <c-j> <c-w>j<c-w>_
map <c-k> <c-w>k<c-w>_
nmap <c-h> <c-w>h<c-w><bar>
nmap <c-l> <c-w>l<c-w><bar>
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

let g:netrw_banner=0
hi TabLineFill cterm=underline
set statusline=%y\ %-18.40(%<%t\ %h%w%m%r%)%9.(-%P-%)\ \(%l,%c%V\)\ %LL
