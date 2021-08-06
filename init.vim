set smartcase
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
set wildignorecase
set number relativenumber

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
nnoremap to :<C-u>edit<Space>
nnoremap tt :<C-u>tabnew<Space>
nnoremap <expr> tO ':<C-u>edit ' . GetRelativePath()
nnoremap <expr> tT ':<C-u>tabnew ' . GetRelativePath()
nnoremap ts :<C-u>split<Space>
nnoremap <expr> tS ':<C-u>split ' . GetRelativePath()
nnoremap tv :<C-u>vsplit<Space>
nnoremap <expr> tV ':<C-u>vsplit ' . GetRelativePath()
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

" load additional scripts
function! s:load_additional(name)
  let file = expand('~/.config/nvim/' . a:name)
  if filereadable(file)
    source `=file`
  endif
endfunction
call s:load_additional('functions.vim')

" load project local vimrc
augroup vimrc-local
  autocmd!
  autocmd BufNewFile,BufReadPost * call s:vimrc_local(expand('<afile>:p:h'))
augroup END

function! s:vimrc_local(loc)
  let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
  for i in reverse(filter(files, 'filereadable(v:val)'))
    source `=i`
  endfor
endfunction

" load global plugins
call plug#begin()

Plug 'itchyny/lightline.vim'
Plug 'jlanzarotta/bufexplorer'
Plug 'kassio/neoterm'
Plug 'ojroques/vim-oscyank'

Plug 'mhinz/vim-sayonara', { 'on': 'Sayonara' }
Plug 'cocopon/iceberg.vim'
Plug 'cocopon/vaffle.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'ryanoasis/vim-devicons'

Plug 'tpope/vim-fugitive'
Plug 'cohama/agit.vim'
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/conflict-marker.vim'

Plug 'editorconfig/editorconfig-vim'

Plug 'othree/html5.vim'
Plug 'cakebaker/scss-syntax.vim'
Plug 'leafgarland/typescript-vim'
Plug 'rust-lang/rust.vim'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" use iceberg colorscheme with lightline
" use FugitiveHead with lightline
let g:lightline = {
  \ 'colorscheme': 'iceberg',
  \ 'tabline': {
  \   'left': [[ 'buffers' ]],
  \   'right': [],
  \ },
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component_function': {
  \   'gitbranch': 'FugitiveHead',
  \   'bufferinfo': 'lightline#buffer#bufferinfo',
  \ },
  \ 'component_expand': {
  \    'buffers': 'lightline#bufferline#buffers'
  \ },
  \ 'component_type': {
  \    'buffers': 'tabsel'
  \ },
  \ 'component': {
  \   'separator': '',
  \ },
  \ }

" use iceberg colorscheme
set termguicolors
set cursorline

colorscheme iceberg


" make popup to transparent
set pumblend=20
set winblend=20

" set html_indent_script1 to 0
let g:html_indent_script1="auto"

" vim-oscyank settings
let g:oscyank_term = 'kitty'
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | OSCYankReg + | endif

" === Agit keymaps ===
autocmd FileType agit call s:agit_keymaps()

function! s:agit_keymaps()
  nmap <buffer> R <Plug>(agit-reload)
endfunction
" ==========

" === neoterm settings ===
let g:neoterm_autoscroll=1
let g:neoterm_size=20
let g:neoterm_fixedsize=1
let g:neoterm_default_mod='bo'
" ==========

" === Sayonara ===
nnoremap sq :<C-u>Sayonara<CR>
nnoremap sQ :<C-u>Sayonara!<CR>

let g:sayonara_confirm_quit=1
" ==========

" === lightline-bufferline settings ===
set hidden
set showtabline=2

nnoremap <Left> :bprev<CR>
nnoremap <Right> :bnext<CR>

let g:lightline#bufferline#show_number=1
let g:lightline#bufferline#enable_devicons=1
let g:lightline#bufferline#unicode_symbols=1
let g:lightline#bufferline#filter_by_tabpage=1
let g:lightline#bufferline#unnamed='[No Name]'
" ==========

" === vaffle ===
command! -nargs=0 Vc :call vaffle#init(expand('%:p:h'))
" ==========

" === editorconfig ===
au FileType gitcommit let b:EditorConfig_disable = 1
" ==========

" === coc.nvim ===
set updatetime=300
set shortmess+=c

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" ==========
