inoremap <silent><expr> <TAB>
    \ pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' :
    \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
    \ '<TAB>' : ddc#manual_complete()

call ddc#custom#patch_global('sources', ['skkeleton', 'nvim-lsp', 'around', 'file'])
call ddc#custom#patch_global('sourceOptions', {
  \ '_': {
  \   'ignoreCase': v:true,
  \   'minAutoCompleteLength': 1,
  \   'matchers': ['matcher_head'],
  \   'sorters': ['sorter_rank'],
  \ },
  \ 'skkeleton': {
  \   'mark': 'skkeleton',
  \   'matchers': ['skkeleton'],
  \   'sorters': []
  \ },
  \ 'around': { 'mark': 'A' },
  \ 'file': {
  \   'mark': 'F',
  \   'isVolatile': v:true,
  \   'forceCompletionPattern': '\S/\S*',
  \ },
  \ 'nvim-lsp': {
  \   'mark': 'LSP',
  \   'forceCompletionPattern': '\.\w*|:\w*|->\w*',
  \ },
  \ 'cmdline': {
  \   'mark': 'vim',
  \ },
  \ 'cmdline-history': {
  \   'mark': 'history',
  \ },
  \ })

call ddc#custom#patch_global('sourceParams', {
  \ 'around':   { 'maxSize': 500 },
  \ 'file':     { 'smartCase': v:true },
  \ })

call ddc#enable()
