-- colorscheme は適用しない。ui を有効にしないマシンでも git などがパレットを使えるようにするため。
vim.pack.add({ require('dotvim._lib.specs').nightfox })

return require('nightfox.palette').load('nordfox')
