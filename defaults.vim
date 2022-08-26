set autoindent
set smartindent
set number
set modeline
set autoread
set fileencodings=utf-8,iso-2022-jp-3,cp932,sjis,euc-jp,ucs-bom,guess,latin1
set fileencoding=utf-8
set laststatus=2
set ignorecase
set hlsearch
set list
set listchars=eol:$,tab:>-,space:.
set number relativenumber
set noequalalways

" project default setting
" overwrite with .vimrc.local in some Projects
set shiftwidth=2
set tabstop=4
set softtabstop=2
set expandtab

augroup filetypeIndent
  autocmd!
  autocmd BufNewFile,BufRead Makefile setlocal noexpandtab shiftwidth=4 softtabstop=4
augroup end

syntax on

nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
nnoremap sN gt
nnoremap sP gT
nnoremap sr <C-w>r
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap sn :<C-u>bn<CR>
nnoremap sp :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>
nnoremap sT :<C-u>Unite tab<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap <C-n> gt
nnoremap <C-p> gT
nnoremap t; t
nnoremap t <Nop>
nnoremap <expr> tO ':<C-u>edit ' . expand('%:h')
nnoremap tt :<C-u>tabnew<Space>
nnoremap ts :<C-u>split<Space>
nnoremap tv :<C-u>vsplit<Space>
nnoremap <silent> td :<C-u>tabclose<CR>

" copy to system clipboard
nnoremap <Space>y "+yy
vnoremap <Space>y "+yy
nnoremap <Space>p "+p
vnoremap <Space>p "+p

" escape from terminal mode
tnoremap <C-w>n <C-\><C-n>

" re-syntax
nnoremap <C-s> <Esc>:syntax sync fromstart<CR>

" make popup to transparent
set pumblend=20
set winblend=20

" set html_indent_script1 to 0
let g:html_indent_script1="zero"

" set gui environment
set guifont=PlemolJP\ Console\ NF:h10

set cmdheight=0
