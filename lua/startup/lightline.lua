vim.g.lightline = {
  colorscheme = 'iceberg',
  active = {
    left = {
      {'mode', 'paste'},
      {'readonly', 'filename', 'modified'},
      {'gitbranch', 'gittraffic'},
    }, 
  },
  inactive = {
    left = {
      {'filename', 'modified'},
    },
    right = {},
  },
  component_function = {
    gitbranch = 'gin#component#branch#unicode',
    gittraffic= 'gin#component#traffic#unicode',
    gitfilename= 'gin#component#worktree#full',
  },
  component_type = {
    buffers = 'tabsel',
  },
  component = {
    filename = '%n: %f',
  },
  tabline = {
    left = {{'tabs'}},
    right = {},
  },
  tab = {
    active = {'tabnum', 'filename'},
    inactive = {'tabnum', 'filename'},
  },
}
