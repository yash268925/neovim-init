call ddc#custom#patch_global('sources', ['skkeleton', 'nvim-lsp', 'around', 'file'])
call ddc#custom#patch_global('cmdlineSources', ['cmdline', 'cmdline-history'])
call ddc#custom#patch_global('sourceOptions', {
  \ '_': {
  \   'ignoreCase': v:true,
  \   'maxItems': 20,
  \   'minAutoCompleteLength': 1,
  \   'matchers': ['matcher_fuzzy'],
  \   'sorters': ['sorter_fuzzy'],
  \   'converters': ['converter_fuzzy'],
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
  \   'mark': 'vimcmd',
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
