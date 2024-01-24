let mapleader="\<Space>"
set nocompatible                     " use vim defaults
set showcmd                          " display incomplete commands
set showmatch                        " jump to matchs when entering parenthes
set matchtime=1                      " tenths of a secend to show the matching parenthes
set backspace=indent,eol,start       " make that backspace key work the way it should
set textwidth=0                      " don't wrap lines by default
set ruler                            " show the current row and column
set number                           " show line numbers
set wildmenu                         " show list instead of just completing
set splitright                       " put new split window in right
set nobackup                         " don't keep a backup file
set fillchars=vert:│                 " change vertsplit character
set ttimeoutlen=100                  " set <esc> reponse time
set path+=**                         " searches current directory recursively.

filetype plugin on

syntax on                            " turn syntax highlighting on by defautl
set mouse=a                          " turn mouse support on

set nowrap                           " line exceed screen don't wrap
"set breakindent                     " set indent in wrap
"set breakindentopt=shift:1          " wrap line additional indent
"set list                            " show nontext
"set listchars=extends:>,precedes:<  " show at line left/right if wrap is off
"set sidescroll=1                    " line exceed screen cursor smooth scrolling
set laststatus=2                     " always show statusline
"set numberwidth=5                   " line number width configure 
set cursorline                       " highlight current line
set scrolloff=2                      " keep <n> lines when scrolling

set novisualbell                     " turn off visualbell
set noerrorbells                     " turn off errorbell

set hlsearch                         " highlight searchs
set incsearch                        " do incremental searching
set ignorecase                       " ignore case when searching
set smartcase                        " no ignorecase if Uppercase char present

set autoindent                       " always set autoindenting on
set smartindent                      " indent works for c-like
set tabstop=4                        " <Tab> width look for
set expandtab                        " expand <Tab> as spaces
set softtabstop=4                    " spaces number when insert <Tab>
set shiftround                       " indent not to multiple of 'shiftwidth'
set shiftwidth=4                     " number of spaces to use for (auto)indent

"adjust split sizes easier
noremap <silent> <C-Up> :resize +3<CR>
noremap <silent> <C-Down> :resize -3<CR>
noremap <silent> <C-Left> :vertical resize -3<CR>
noremap <silent> <C-Right> :vertical resize +3<CR>

"remap split navigation to just CTRL + hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

"switch tab
nnoremap H gT
nnoremap L gt
nnoremap T H
nnoremap B L

"change split windows from vertical to horizontal or vice versa
nnoremap <leader>th <C-w>t<C-w>H
nnoremap <leader>tk <C-w>t<C-w>K

"move current line
nnoremap <silent> <C-n> :m +1<CR>
nnoremap <silent> <C-p> :m -2<CR>
vnoremap <silent> <C-n> :m '>+1<CR>gv=gv
vnoremap <silent> <C-p> :m -2<CR>gv=gv

" filetree
let g:netrw_banner=0
let g:netrw_winsize=25
let g:netrw_liststyle=3
let g:netrw_altv=1
let g:netrw_browse_split=4
nnoremap <silent> <leader>e :Vexplore<CR>
autocmd filetype netrw nnoremap <buffer> <C-l> <C-w>l

" Specify file config
autocmd Filetype yaml set tabstop=2 shiftwidth=2 softtabstop=2

" User Interface customize
set t_Co=256
set background=dark
let g:jellybeans_overrides = {
\    'background': { 'ctermbg': 'none', '256ctermbg': 'none' },
\}
colorscheme jellybeans
"hi Normal ctermbg=NONE cterm=NONE
"hi TabLine ctermfg=8 ctermbg=NONE cterm=NONE
"hi! link TabLineFill TabLine
"hi LineNr ctermbg=NONE
"hi Pmenu ctermfg=15 ctermbg=8
"hi PmenuSel ctermfg=0 ctermbg=4
"hi VertSplit ctermbg=NONE cterm=NONE
"hi IncSearch ctermfg=0 ctermbg=3 cterm=NONE
"hi Search ctermfg=0
"hi Visual ctermbg=NONE cterm=reverse
"hi CursorLine cterm=NONE
"hi CursorLineNr cterm=NONE
"hi Comment ctermfg=8
