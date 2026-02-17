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
nmap <silent> <Leader>bd :bd<CR> 
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
nmap <c-h> <c-w>h<c-w><bar>
nmap <c-l> <c-w>l<c-w><bar>
nmap <Leader>wc <C-W>c
nmap <S-H> gT
nmap <S-L> gt
nmap <leader>th <C-W>t<C-W>H
nmap <leader>tk <C-W>t<C-W>K
map <C-t><C-t> :tabnew<CR>
map <C-t><C-w> :tabclose<CR>
imap <C-J> <C-O>o
imap <C-K> <C-O>O
nmap <leader>q :nohl<CR>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-K> <C-U>
vnoremap < <gv
vnoremap > >gv

let g:netrw_banner=0
nnoremap <silent> <leader>e :Ex<CR>
