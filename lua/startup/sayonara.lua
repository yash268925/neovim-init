vim.g.sayonara_confirm_quit = 0

vim.keymap.set('n', 'sq', ':<C-u>Sayonara<CR>', { silent = true })
vim.keymap.set('n', 'sa', ':<C-u>Sayonara!<CR>', { silent = true })
