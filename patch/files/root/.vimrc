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

set nowrap                           " line exceed screen don't wrap
set breakindent                      " set indent in wrap
set breakindentopt=shift:1           " wrap line additional indent
"set list                            " show nontext
"set listchars=extends:>,precedes:<  " show at line left/right if wrap is off
"set sidescroll=1                    " line exceed screen cursor smooth scrolling
set laststatus=2                     " always show statusline
"set numberwidth=5                   " line number width configure 
"set cursorline                      " highlight current line
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

" key map
nnoremap k gk
nnoremap gk k
nnoremap j gj
nnoremap gj j
nnoremap <C-h> <C-w>h<CR>
nnoremap <C-j> <C-w>j<CR>
nnoremap <C-k> <C-w>k<CR>
nnoremap <C-l> <C-w>l<CR>
nnoremap H gT
nnoremap L gt

" Specify file config
"filetype plugin off
autocmd Filetype yaml set tabstop=2 shiftwidth=2 softtabstop=2

" User Interface customize
"set t_Co=256                        " color number
set background=dark                  " background color
"colorscheme Tomorrow-Night
hi Normal ctermbg=NONE
hi TabLine ctermfg=8 ctermbg=NONE cterm=NONE
hi! link TabLineFill TabLine
hi LineNr ctermfg=8 ctermbg=NONE
hi Pmenu ctermfg=15 ctermbg=8
hi PmenuSel ctermfg=0 ctermbg=4
hi VertSplit ctermfg=8 ctermbg=NONE cterm=NONE
hi IncSearch ctermfg=0 ctermbg=3 cterm=NONE
hi Search ctermfg=0
hi Visual ctermbg=NONE cterm=reverse
hi CursorLine cterm=NONE
hi CursorLineNr cterm=NONE
hi Comment ctermfg=8
"hi StatusLine cterm=NONE ctermfg=black ctermbg=8
"hi StatusLineNC cterm=NONE ctermfg=8 ctermbg=NONE

" Statusline configure
set statusline=\ #%n\ \ %<%f\ \ \ \ %P\ \(%l:%c\)\ %=%h%m%r%w\ %{&ff}\ %{&fenc}\ \ \ %Y\ 
"hi User1 ctermbg=8
"hi User2 ctermbg=8
"hi User3 ctermbg=8
"hi User4 ctermbg=8
"hi User5 ctermbg=8
