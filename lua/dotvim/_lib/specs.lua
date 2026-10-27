-- vim.pack.add は同じプラグインの 2 回目以降の spec を無視するため、
-- 複数の機能が使うプラグインの spec はここだけで定義する。
return {
  nightfox = { src = 'https://github.com/EdenEast/nightfox.nvim' },
  mini_icons = { src = 'https://github.com/echasnovski/mini.icons' },
  mini_bufremove = { src = 'https://github.com/echasnovski/mini.bufremove' },
}
