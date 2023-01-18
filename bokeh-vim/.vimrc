set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
    Plugin 'VundleVim/Vundle.vim'
    Plugin 'jlanzarotta/bufexplorer'
    Plugin 'joonty/vdebug'
    Plugin 'preservim/nerdtree'
call vundle#end()            " required
filetype plugin indent on    " required

" Alias
command! Be BufExplorer

syntax on

"affiche de la ligne et de la colonne en bas à droite
set ruler

"affiche les numéros de lignes
set number

set expandtab
set smarttab
set sw=2
set ts=2

"change le theme par defaut
colorscheme desert

"Affiche lors de la recherche les mots correspondant en les surlignant
set hlsearch

"affiche la parenthèse correspondante
set sm

set incsearch

set nocompatible

"Show non-printable character
set list listchars=tab:\ø\ ,trail:°,nbsp:␣

"No end of line
set binary
set noendofline

" autocomplete files path
set wildmenu
set wildmode=list:longest

set backspace=indent,eol,start
