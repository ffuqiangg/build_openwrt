syntax off

set nocompatible
set bs=2 tw=0 so=2 ls=2
set ts=4 sts=4 sw=4
set noswf nobk noudf nolz
set fillchars=vert:│
set ttimeoutlen=100
set path+=**
set nowrap novb noeb nu!
set hls is ic scs ai! si et sr

let mapleader="\<Space>"
nmap <leader>e :E<br>
nmap <leader>bd :bd<cr> 
nmap <leader>wc <c-w>c
nmap <leader>th <c-w>t<c-w>h
nmap <leader>tk <c-w>t<c-w>k
nmap <leader>q :nohl<cr>
map <c-j> <c-w>j<c-w>_
map <c-k> <c-w>k<c-w>_
nmap <c-h> <c-w>h<c-w><bar>
nmap <c-l> <c-w>l<c-w><bar>
nmap <s-h> gT
nmap <s-l> gt
map <c-t><c-t> :tabnew<cr>
map <c-t><c-w> :tabclose<cr>
imap <c-j> <c-o>o
imap <c-k> <c-o>O
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-k> <c-u>
vnoremap < <gv
vnoremap > >gv

let g:netrw_banner=0
