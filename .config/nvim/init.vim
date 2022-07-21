"
"      ██ ███████ ██     ██ 
"      ██ ██      ██     ██  Jakob Ferdinand Wegenschimmel
"      ██ █████   ██  █  ██  https://github.com/JakobFerdinand
" ██   ██ ██      ██ ███ ██ 
"  █████  ██       ███ ███  
"
" A customized neovim configuration (https://neovim.io/)
"



""""""""""""""""""""""""""""""""""""""""
" general settings
""""""""""""""""""""""""""""""""""""""""

syntax enable

set path+=**                                    " Searches current dictionary recursively

set noerrorbells visualbell t_vb= 
set clipboard=unnamedplus                       " Copy/paste between vim and other programs
set hidden                                      " keep multiple buffers open

set number
set relativenumber
set nowrap
" Show a few lines of context around the cursor. Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

set incsearch
set showmatch
set wildmenu                                    " Display all matches when tab complete

set tabstop=2 softtabstop=2                     " One tab == two spaces
set shiftwidth=2
set expandtab                                   " Use spaces instead of tabs
set smartindent
"
" Dont create swapfiles - instead use undofiles in $datadir/undodir
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
set noswapfile
set nobackup
let &undodir=data_dir.'/undodir'
set undofile

""""""""""""""""""""""""""""""""""""""""
" command remapping
""""""""""""""""""""""""""""""""""""""""

let mapleader = " "

" navigating in windows
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

" moving windows
nnoremap <leader>H :wincmd H<CR>
nnoremap <leader>J :wincmd J<CR>
nnoremap <leader>K :wincmd K<CR>
nnoremap <leader>L :wincmd L<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mouse Scrolling
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set mouse=nicr
set mouse=a

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Splits and Tabbed Files
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set splitbelow splitright


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" automatically install vim-plug
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" {{ The Basics }}
" Plug 'dracula/vim'                                  " Dracula color scheme
Plug 'itchyny/lightline.vim'                          " Lightline statusbar
Plug 'szw/vim-maximizer'                              " Window Maximizer
"{{ Syntax and languages }}
Plug 'elmcast/elm-vim'                                " Elm highlighting
Plug 'OmniSharp/omnisharp-vim'                        " C# support
" {{ Productivity }}
Plug 'tpope/vim-fugitive'                             " Git client
Plug 'mbbill/undotree'                                " Undotree
Plug 'preservim/nerdtree'                             " Nerdtree - a visual filemanager in vim
Plug 'ryanoasis/vim-devicons'                         " Icons for Nerdtree
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'        " Highlighting Nerdtree
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }   " fuzzy finder
Plug 'junegunn/fzf.vim'

call plug#end()

"""""""""""""""""""""""""""""""""""""""
" lightline
""""""""""""""""""""""""""""""""""""""""
  "\ 'colorscheme': 'dracula',
let g:lightline = {
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component_function': {
  \   'gitbranch': 'FugitiveHead' 
  \ }
  \ }
set noshowmode                                  " Disable vim default mode visualization
set laststatus=2                                " required to show lightline

"""""""""""""""""""""""""""""""""""""""
" vim-maximizer
""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>m :MaximizerToggle<CR>

""""""""""""""""""""""""""""""""""""""""
" Fugitive
""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>gs :G<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git pull<CR>
nnoremap <leader>gpp :Git push<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" undotree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <leader>u :UndotreeShow<CR>

""""""""""""""""""""""""""""""""""""""""
" NERDTree
""""""""""""""""""""""""""""""""""""""""
map <leader><leader> :NERDTreeFocus<CR>
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
let g:NERDTreeWinSize=38
let g:NERDTreeDirArrowExpandable = '►'
let g:NERDTreeDirArrawCollapsible = '▼'
set encoding=UTF-8                                  " for vim-devicons
autocmd VimEnter * source ~/.config/nvim/init.vim   " remove [ ] around nerdtree icons
if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif

autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
  \ quit | endif

""""""""""""""""""""""""""""""""""""""""
" FZF
""""""""""""""""""""""""""""""""""""""""
" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'

map <C-f> :Files<CR>
map <leader>b :Buffers<CR>
nnoremap <leader>m :Marks<CR>

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

set guifont=SauceCodePro\ Nerd\ Font:h15


""""""""""""""""""""""""""""""""""""""""
" Filetype mappings
""""""""""""""""""""""""""""""""""""""""
autocmd BufNewFile,BufRead *.csproj set filetype=xml
autocmd BufNewFile,BufRead *.props set filetype=xml
autocmd BufNewFile,BufRead *.targets set filetype=xml
