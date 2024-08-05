local function init()
  vim.cmd.packadd('minpac')

  if not(vim.g['loaded_minpac']) then
    print('minpac not installed')
    return false
  end

  local init = vim.fn['minpac#init']
  local add = vim.fn['minpac#add']

  init()
  add('yash268925/iceberg.vim')
  add('ojroques/vim-oscyank')
  add('drmingdrmer/vim-toggle-quickfix')
  add('nvim-treesitter/nvim-treesitter')
  add('neovim/nvim-lspconfig')
  add('drmingdrmer/vim-toggle-quickfix')
  add('itchyny/lightline.vim')
  add('mhinz/vim-sayonara')
  add('airblade/vim-gitgutter')
  add('editorconfig/editorconfig-vim')
  add('thinca/vim-quickrun')
  add('Shougo/pum.vim')
  add('mattn/vim-molder')
  add('mattn/vim-molder-operations')
  add('lukas-reineke/indent-blankline.nvim')
  add('itchyny/vim-qfedit')
  add('SmiteshP/nvim-navic')
  add('t9md/vim-quickhl')
  add('chentoast/marks.nvim')

  -- Plugins which use Denops
  add('vim-denops/denops.vim')
  add('lambdalisue/guise.vim')
  add('lambdalisue/gin.vim')
  add('lambdalisue/suda.vim')
  add('vim-skk/skkeleton')
  add('delphinus/skkeleton_indicator.nvim')

  -- ddc
  add('Shougo/ddc.vim')
  add('Shougo/ddc-ui-pum')
  add('tani/ddc-fuzzy')
  add('Shougo/ddc-sorter_rank')
  add('LumaKernel/ddc-source-file')
  add('tani/ddc-path')
  add('Shougo/ddc-source-nvim-lsp')
  add('Shougo/ddc-source-cmdline')
  add('Shougo/ddc-source-cmdline-history')
  add('Shougo/ddc-source-rg')
  add('matsui54/denops-popup-preview.vim')
  add('takker99/ddc-bitap.git')

  -- ddu
  add('Shougo/ddu.vim')
  add('Shougo/ddu-ui-ff')
  add('Shougo/ddu-kind-file')
  add('shun/ddu-source-buffer')
  add('nabezokodaikon/ddu-source-file_fd')
  add('yuki-yano/ddu-filter-fzf')
  add('Shougo/ddu-ui-filer')
  add('Shougo/ddu-source-file')
  add('Shougo/ddu-source-file_rec')
  add('matsui54/ddu-source-file_external')
  add('shun/ddu-source-rg')
  add('ryota2357/ddu-column-icon_filename')
  add('Shougo/ddu-filter-matcher_hidden')
  add('k-ota106/ddu-source-marks')
  add('kamecha/ddu-source-tab')

  return true
end

vim.api.nvim_create_user_command('PackUpdate', function()
  if not(init()) then return end
  vim.fn['minpac#update']()
  vim.cmd.packadd('nvim-treesitter')
  vim.cmd(':TSUpdate')
end, { bang = true })
vim.api.nvim_create_user_command('PackClean', function()
  if not(init()) then return end
  vim.fn['minpac#clean']()
end, { bang = true })
vim.api.nvim_create_user_command('PackStatus', function()
  if not(init()) then return end
  vim.fn['minpac#status']()
end, { bang = true })
