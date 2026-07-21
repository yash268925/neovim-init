vim.pack.add({
  { src = 'https://github.com/lambdalisue/nvim-aibo' }
})

local aibo = require('aibo')

aibo.setup({
  termcode_mode = 'csi-n',
  prompt = {
    on_attach = function(bufnr)
      local opts = { buffer = bufnr, nowait = true, silent = true }
      -- Add custom mappings using <Plug>(aibo-send) pattern
      -- vim.keymap.set({ 'n', 'i' }, '<C-j>', '<Plug>(aibo-send)<Down>', opts)
      -- vim.keymap.set({ 'n', 'i' }, '<C-k>', '<Plug>(aibo-send)<Up>', opts)
    end,
  },
})

-- Runs after nvim-aibo's own ftplugin/aibo-*.lua (built-in ftplugin loading
-- is wired up before user config, so a later `FileType` autocmd for the same
-- pattern always fires after it -- the standard ftplugin-overrule idiom).
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'aibo-*',
  callback = function(ev)
    vim.wo.winfixwidth = true

    local bufnr = ev.buf
    if not vim.api.nvim_buf_get_name(bufnr):match('^aiboprompt://') then
      return
    end

    -- Hand "/" and "@" over to nvim-ix: drop nvim-aibo's own triggers
    -- (<C-x><C-o> / vim.fn.complete()) so the characters just self-insert
    -- and nvim-ix's normal TextChangedI auto-trigger picks them up via the
    -- aibo-slash / aibo-file sources registered in dotvim.plugins.completion.
    pcall(vim.keymap.del, 'i', '/', { buffer = bufnr })
    pcall(vim.keymap.del, 'i', '@', { buffer = bufnr })

    -- nvim-aibo's own <C-n>/<C-p> only special-case the native pum
    -- (pumvisible()), so with the triggers above removed they never see
    -- nvim-ix's floating menu and always fall through to history
    -- navigation. Prefer selecting in nvim-ix's menu when it is visible;
    -- otherwise keep aibo's prompt-history prev/next.
    local ix = require('ix')

    local function history(direction)
      local plug = direction == 'next' and '<Plug>(aibo-history-next)' or '<Plug>(aibo-history-prev)'
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(plug, true, false, true), 'm', false)
    end

    vim.keymap.set('i', '<C-n>', function()
      if ix.get_completion_service():is_menu_visible() then
        (ix.action.completion.select_next())()
      else
        history('next')
      end
    end, { buffer = bufnr, silent = true })

    vim.keymap.set('i', '<C-p>', function()
      if ix.get_completion_service():is_menu_visible() then
        (ix.action.completion.select_prev())()
      else
        history('prev')
      end
    end, { buffer = bufnr, silent = true })
  end,
})

-- nvim-aibo の `-toggle` は cmd+args が完全一致する既存インスタンスしか
-- 検出できないため、引数を変えて :Claude を呼ぶと別インスタンス扱いになり
-- トグルされない。ここでは直近に開いたバッファを自前で覚えておき、それが
-- window内に見えていれば閉じるだけにすることで、引数によらないトグルにする。
local claude_state = { bufnr = nil }

local function is_claude_win_visible()
  return claude_state.bufnr ~= nil
    and vim.api.nvim_buf_is_valid(claude_state.bufnr)
    and #vim.fn.win_findbuf(claude_state.bufnr) > 0
end

local function toggle_claude(args)
  if is_claude_win_visible() then
    for _, winid in ipairs(vim.fn.win_findbuf(claude_state.bufnr)) do
      vim.api.nvim_win_close(winid, false)
    end
    return
  end

  local width = math.floor(vim.o.columns * 1 / 3)
  local cmd = string.format('Aibo -toggle -opener="botright %dvsplit" claude', width)
  if args and args ~= '' then
    cmd = cmd .. ' ' .. args
  end
  vim.cmd(cmd)

  -- nvim-aibo の内部APIから、いま開いた(または再表示した)コンソールの
  -- バッファ番号を取得して覚えておく。将来の nvim-aibo 更新で
  -- internal モジュールの形が変わると壊れうる点は留意。
  local ok, console = pcall(require, 'aibo.internal.console_window')
  if ok then
    local parsed_args = (args and args ~= '') and vim.split(args, '%s+') or {}
    local info = console.find_info_globally({ cmd = 'claude', args = parsed_args })
    if info then
      claude_state.bufnr = info.bufnr
    end
  end
end

local keymaps = require('dotvim.utils').keymaps

keymaps({
  { 'n', ';c', function() toggle_claude() end },
})

vim.api.nvim_create_user_command('Claude', function(opts)
  toggle_claude(opts.args)
end, { nargs = '*' })
