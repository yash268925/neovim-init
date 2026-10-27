local deck = require('deck')

-- choose_action のコンテキストからは呼び出し元のピッカーを辿れないため、<Tab> を押した
-- 時点のコンテキストをここに控えてキャンセル時の復帰先にする。
local choose_action_prev_ctx = nil

-- 既定の bottom_picker は最下段に split を作るため、laststatus=3 と winfixheight ウィンドウの
-- 組み合わせで Neovim 側のバグにより wfh ウィンドウが 1 行ずつ伸びる。float なら発生しない。
deck.setup({
  default_start_config = {
    get_view = function()
      return require('deck.builtin.view.float_picker')()
    end,
  },
  get_choose_action_view = function()
    local view = require('deck.builtin.view.float_picker')({
      title = 'Actions (q / <Esc>: back)',
      width_ratio = 0.4,
      height_ratio = 0.25,
    })
    local show = view.show
    view.show = function(ctx)
      -- float_picker は固定の deck_win_name でウィンドウを使い回すため、そのままだと
      -- メインのピッカーのウィンドウを乗っ取ってしまう。呼び出しの間だけ名前を退避して
      -- 別ウィンドウを開かせ、こちらは専用の名前を付けて重ならないようにする。
      local main_win
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local ok, name = pcall(vim.api.nvim_win_get_var, win, 'deck_win_name')
        if ok and name == 'deck.builtin.view.float_picker' then
          main_win = win
          break
        end
      end
      if main_win then
        vim.api.nvim_win_set_var(main_win, 'deck_win_name', 'dotvim.float_picker.stashed')
      end
      local ok, err = pcall(show, ctx)
      if main_win and vim.api.nvim_win_is_valid(main_win) then
        vim.api.nvim_win_set_var(main_win, 'deck_win_name', 'deck.builtin.view.float_picker')
      end
      if not ok then
        error(err)
      end

      local win = view.get_win()
      if win then
        vim.api.nvim_win_set_var(win, 'deck_win_name', 'dotvim.choose_action_picker')
        local config = vim.api.nvim_win_get_config(win)
        config.zindex = 100
        vim.api.nvim_win_set_config(win, config)
      end
    end
    return view
  end,
})

vim.api.nvim_create_autocmd('User', {
  group = 'dotvim.picker',
  pattern = 'DeckStart',
  callback = function(e)
    local ctx = e.data.ctx --[[@as deck.Context]]

    ctx.keymap('n', '<Tab>', function()
      choose_action_prev_ctx = ctx
      ctx.do_action('choose_action')
    end)
    ctx.keymap('n', '<C-l>', deck.action_mapping('refresh'))
    ctx.keymap('n', 'i', deck.action_mapping('prompt'))
    ctx.keymap('n', '@', deck.action_mapping('toggle_select'))
    ctx.keymap('n', '*', deck.action_mapping('toggle_select_all'))
    ctx.keymap('n', 'P', deck.action_mapping('toggle_preview_mode'))
    ctx.keymap('n', '<CR>', deck.action_mapping('default'))
    ctx.keymap('n', 'q', function() ctx.hide() end)
    ctx.keymap('n', '<Esc>', function() ctx.hide() end)
  end
})

vim.api.nvim_create_autocmd('User', {
  group = 'dotvim.picker',
  pattern = 'DeckStart:deck.actions',
  callback = function(e)
    local ctx = e.data.ctx --[[@as deck.Context]]
    local prev_ctx = choose_action_prev_ctx

    local function cancel()
      if prev_ctx then
        prev_ctx.show()
      end
      ctx.hide()
      ctx.dispose()
    end

    ctx.keymap('n', 'q', cancel)
    ctx.keymap('n', '<Esc>', cancel)
    ctx.keymap('n', '<Tab>', cancel)
  end
})

local keymaps = require('dotvim._lib.utils').keymaps

keymaps({
  { 'n', ';b', '<Cmd>Deck buffers<CR>' },
  { 'n', ';f', '<Cmd>Deck files<CR>' },
  { 'n', ';g', '<Cmd>Deck grep<CR>' },
  { 'n', ';e', '<Cmd>Deck explorer<CR>' },
  { 'n', ';r', '<Cmd>Deck lsp-ref<CR>' },
})
