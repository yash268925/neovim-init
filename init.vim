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

Plug 'mhinz/vim-sayonara', { 'on': 'Sayonara' }
Plug 'cocopon/iceberg.vim'
Plug 'cocopon/vaffle.vim'
Plug 'taohexxx/lightline-buffer'

Plug 'tpope/vim-fugitive'
Plug 'cohama/agit.vim'
Plug 'airblade/vim-gitgutter'

Plug 'editorconfig/editorconfig-vim'

Plug 'othree/html5.vim'
Plug 'cakebaker/scss-syntax.vim'
Plug 'jeroenbourgois/vim-actionscript'
Plug 'leafgarland/typescript-vim'
Plug 'cespare/mxml.vim'
Plug 'rust-lang/rust.vim'

Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'nvim-lua/diagnostic-nvim'

call plug#end()

" use iceberg colorscheme with lightline
" use FugitiveHead with lightline
let g:lightline = {
  \ 'colorscheme': 'iceberg',
  \ 'tabline': {
  \   'left': [ [ 'bufferinfo' ],
  \             [ 'separator' ],
  \             [ 'bufferbefore', 'buffercurrent', 'bufferafter' ], ],
  \   'right': [ [ 'close' ], ],
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
  \   'buffercurrent': 'lightline#buffer#buffercurrent',
  \   'bufferbefore': 'lightline#buffer#bufferbefore',
  \   'bufferafter': 'lightline#buffer#bufferafter',
  \ },
  \ 'component_type': {
  \   'buffercurrent': 'tabsel',
  \   'bufferbefore': 'raw',
  \   'bufferafter': 'raw',
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

" === lightline-buffer settings ===
set hidden
set showtabline=2
" ==========

" === vaffle ===
command! -nargs=0 Vc :call vaffle#init(expand('%:p:h'))
" ==========

" === nvim-lsp ===
set completeopt=menuone,noinsert,noselect
set shortmess+=c

let g:vimsyn_embed='lPr'
let g:diagnostic_enable_underline=1
let g:diagnostic_show_sign=99
lua << EOF
  local lspconfig = require('lspconfig')

  local on_attach = function (client, bufnr)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true, silent = true})
    require('completion').on_attach(client)
  end

  local eslint = {
    lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
    lintStdin = true,
    lintFormats = {"%f:%l:%c: %m"},
    lintIgnoreExitCode = true,
    formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
    formatStdin = true
  }

  lspconfig.efm.setup({
    on_attach = function(client)
      client.resolved_capabilities.document_formatting = true
      client.resolved_capabilities.goto_definition = false
      on_attach()
    end,
    root_dir = function(fname)
      return lspconfig.util.find_node_modules_ancestor(fname) or vim.loop.os_homedir()
    end,
    settings = {
      languages = {
        javascript = {eslint},
        javascriptreact = {eslint},
        ["javascript.jsx"] = {eslint},
        typescript = {eslint},
        ["typescript.tsx"] = {eslint},
        typescriptreact = {eslint},
        vue = {eslint}
      }
    },
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescript.tsx",
      "typescriptreact",
      "vue"
    }
  })

  lspconfig.vimls.setup({ on_attach = on_attach })

  lspconfig.tsserver.setup({
    on_attach = function(client)
      if client.config.flags then
        client.config.flags.allow_incremental_sync = true
      end
      client.resolved_capabilities.document_formatting = false
      on_attach()
    end
  })

  lspconfig.intelephense.setup({
    on_attach = on_attach,
    settings = {
      intelephense = {
        files = {
          maxSize = 3200000;
        },
        stubs = { "standard", "wordpress" }
      }
    }
  })

  lspconfig.vuels.setup({
    on_attach = on_attach,
    init_options = {
      config = {
        css = {},
        emmet = {},
        html = {
          suggest = {}
        },
        javascript = {
          format = {}
        },
        stylusSupremacy = {},
        typescript = {
          format = {}
        },
        vetur = {
          completion = {
            autoImport = true,
            tagCasing = "kebab",
            useScaffoldSnippets = false
          },
          format = {
            defaultFormatter = {
              js = "none",
              ts = "none"
            },
            defaultFormatterOptions = {},
            scriptInitialIndent = false,
            styleInitialIndent = false
          },
          useWorkspaceDependencies = true,
          validation = {
            script = true,
            style = true,
            template = true
          },
          experimental = {
            templateInterpolationService = true
          }
        }
      }
    }
  })

  vim.cmd('command Fix lua vim.lsp.buf.formatting()')
EOF
" ==========
