"
"      ██ ███████ ██     ██ 
"      ██ ██      ██     ██  Jakob Ferdinand Wegenschimmel
"      ██ █████   ██  █  ██  https://github.com/JakobFerdinand
" ██   ██ ██      ██ ███ ██ 
"  █████  ██       ███ ███  
"
" A customized neovim configuration
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

set incsearch
set showmatch
set wildmenu                                    " Display all matches when tab complete

set tabstop=2 softtabstop=2                     " One tab == two spaces
set shiftwidth=2
set expandtab                                   " Use spaces instead of tabs
set smartindent

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
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" {{ The Basics }}
" Plug 'dracula/vim'                              " Dracula color scheme
Plug 'itchyny/lightline.vim'                    " Lightline statusbar
Plug 'szw/vim-maximizer'                        " Window Maximizer
"{{ Syntax and languages }}
Plug 'elmcast/elm-vim'                          " Elm highlighting
" {{ Productivity }}
Plug 'tpope/vim-fugitive'                       " Git client
Plug 'mbbill/undotree'                          " Undotree
Plug 'preservim/nerdtree'                       " Nerdtree - a visual filemanager in vim
Plug 'ryanoasis/vim-devicons'                   " Icons for Nerdtree
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'  " Highlighting Nerdtree

call plug#end()

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
set encoding=UTF-8                              " for vim-devicons
autocmd VimEnter * source ~/.vim/vimrc          " remove [ ] around nerdtree icons
if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif

autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
  \ quit | endif





set guifont=SauceCodePro\ Nerd\ Font:h15
