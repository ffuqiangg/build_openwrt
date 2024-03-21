set ts=4 sts=4 sw=4 expandtab
set smartindent cindent
let g:netrw_banner=0

nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <silent> <C-n> :m +1<CR>
nnoremap <silent> <C-p> :m -2<CR>
vnoremap <silent> <C-n> :m '>+1<CR>gv=gv
vnoremap <silent> <C-p> :m -2<CR>gv=gv
nnoremap H gT
nnoremap L gt
nnoremap T H
nnoremap B L

autocmd filetype yaml set ts=2 sts=2 sw=2
autocmd filetype json set ts=2 sts=2 sw=2
