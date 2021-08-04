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
"Plug 'jeroenbourgois/vim-actionscript'
Plug 'leafgarland/typescript-vim'
"Plug 'cespare/mxml.vim'
Plug 'rust-lang/rust.vim'
Plug 'leafOfTree/vim-vue-plugin'

"Plug 'prabirshrestha/async.vim'
"Plug 'prabirshrestha/asyncomplete.vim'
"Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'nvim-lua/diagnostic-nvim'

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
    vim.lsp.handlers['textDocument/publishDiagnostics'] =
      function(_, _, params, client_id, _)
        local config = {
          underline = true,
          virtual_text = true,
          signs = true,
          update_in_insert = false,
        }
        local uri = params.uri
        local bufnr = vim.uri_to_bufnr(uri)

        if not bufnr then
          return
        end

        local diagnostics = params.diagnostics

        for i, v in ipairs(diagnostics) do
          diagnostics[i].message = string.format("%s: %s", v.source, v.message)
        end

        vim.lsp.diagnostic.save(diagnostics, bufnr, client_id)

        if not vim.api.nvim_buf_is_loaded(bufnr) then
          return
        end

        vim.lsp.diagnostic.display(diagnostics, bufnr, client_id, config)
      end
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
    end,
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescript.tsx",
      "typescriptreact"
    }
  })

  lspconfig.intelephense.setup({
    on_attach = on_attach,
    settings = {
      intelephense = {
        files = {
          maxSize = 3200000;
        },
        stubs = {
          "apache",
          "bcmath",
          "bz2",
          "calendar",
          "com_dotnet",
          "Core",
          "ctype",
          "curl",
          "date",
          "dba",
          "dom",
          "enchant",
          "exif",
          "FFI",
          "fileinfo",
          "filter",
          "fpm",
          "ftp",
          "gd",
          "gettext",
          "gmp",
          "hash",
          "iconv",
          "imap",
          "intl",
          "json",
          "ldap",
          "libxml",
          "mbstring",
          "meta",
          "mysqli",
          "oci8",
          "odbc",
          "openssl",
          "pcntl",
          "pcre",
          "PDO",
          "pdo_ibm",
          "pdo_mysql",
          "pdo_pgsql",
          "pdo_sqlite",
          "pgsql",
          "Phar",
          "posix",
          "pspell",
          "readline",
          "Reflection",
          "session",
          "shmop",
          "SimpleXML",
          "snmp",
          "soap",
          "sockets",
          "sodium",
          "SPL",
          "sqlite3",
          "standard",
          "superglobals",
          "sysvmsg",
          "sysvsem",
          "sysvshm",
          "tidy",
          "tokenizer",
          "wordpress",
          "xml",
          "xmlreader",
          "xmlrpc",
          "xmlwriter",
          "xsl",
          "Zend OPcache",
          "zip",
          "zlib"
        },
        diagnostics = {
          undefinedClassConstants = false,
          undefinedConstants = false,
          undefinedFunctions = false,
          undefinedMethods = false,
          undefinedProperties = false,
          undefinedSymbols = false,
          undefinedTypes = false
        }
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
