local function attach_keymap(bufnr)
  vim.keymap.set('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', { buffer = bufnr, silent = true })
  vim.keymap.set('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', { buffer = bufnr, silent = true })
  vim.keymap.set('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', { buffer = bufnr, silent = true })
  vim.keymap.set('n', 'gs', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', { buffer = bufnr, silent = true })
  vim.keymap.set('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', { buffer = bufnr, silent = true })
  vim.keymap.set('n', 'gx', '<Cmd>lua vim.diagnostic.open_float()<CR>', { buffer = bufnr, silent = true })
  vim.keymap.set('n', 'g[', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', { buffer = bufnr, silent = true })
  vim.keymap.set('n', 'g]', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', { buffer = bufnr, silent = true })
end

local lspconfig = require('lspconfig')

local function exists_dir(path, name)
  return lspconfig.util.path.is_dir(lspconfig.util.path.join(path, name))
end

local function exists_file(path, name)
  return lspconfig.util.path.is_file(lspconfig.util.path.join(path, name))
end

local find_node_modules_ancestor = lspconfig.util.find_node_modules_ancestor

local find_deno_json_ancestor = function(startpath)
  return lspconfig.util.search_ancestors(startpath, function(path)
    if exists_file(path, 'deno.json') or exists_file(path, 'deno.jsonc') then
      return path
    end
  end)
end

lspconfig.tsserver.setup {
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescript.tsx',
    'typescriptreact',
  },
  root_dir = function(fname)
    return find_node_modules_ancestor(fname) or vim.loop.os_homedir()
  end,
  autostart = false,
  flags = {
    debounce_text_changes = 150,
  },
  on_attach = function(client, bufnr)
    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end
    client.server_capabilities.document_formatting = false
    attach_keymap(bufnr)
  end,
}

lspconfig.denols.setup {
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  },
  root_dir = deno_repo_root,
  autostart = false,
  single_file_support = false,
  init_options = {
    lint = true,
    unstable = true,
  },
  on_attach = function(_, bufnr) attach_keymap(bufnr) end,
}

local eslint = {
  lintCommand = 'eslint_d -f unix --stdin --stdin-filename ${INPUT}',
  lintStdin = true,
  lintFormats = {'%f:%l:%c: %m'},
  lintIgnoreExitCode = true,
  formatCommand = 'eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}',
  formatStdin = true
}

local prettier = {
  formatCommand = 'prettierd \'${INPUT}\'',
  formatStdin = true,
  env = {
    string.format('PRETTIERD_DEFAULT_CONFIG=%s', vim.fn.expand('~/.config/nvim/utils/linter-config/prettierrc.json')),
  },
}

lspconfig.efm.setup {
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescript.tsx',
    'typescriptreact',
  },
  root_dir = function(fname)
    return find_node_modules_ancestor(fname) or vim.loop.os_homedir()
  end,
  settings = {
    languages = {
      javascript = {eslint, prettier},
      javascriptreact = {eslint, prettier},
      ['javascript.jsx'] = {eslint, prettier},
      typescript = {eslint, prettier},
      ['typescript.tsx'] = {eslint, prettier},
      typescriptreact = {prettier},
    }
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.document_formatting = true
    client.server_capabilities.goto_definition = false
    attach_keymap(bufnr)
  end,
}

local intelephense_stubs = {
  'apache', 'bcmath', 'bz2', 'calendar', 'com_dotnet',
  'Core', 'ctype', 'curl', 'date', 'dba',
  'dom', 'enchant', 'exif', 'FFI', 'fileinfo',
  'filter', 'fpm', 'ftp', 'gd', 'gettext', 'gmp',
  'hash', 'iconv', 'imap', 'intl', 'json',
  'ldap', 'libxml', 'mbstring', 'meta', 'mysqli',
  'oci8', 'odbc', 'openssl', 'pcntl', 'pcre',
  'PDO', 'pdo_ibm', 'pdo_mysql', 'pdo_pgsql', 'pdo_sqlite',
  'pgsql', 'Phar', 'posix', 'pspell', 'readline',
  'Reflection', 'session', 'shmop', 'SimpleXML', 'snmp',
  'soap', 'sockets', 'sodium', 'SPL', 'sqlite3',
  'standard', 'superglobals', 'sysvmsg', 'sysvsem', 'sysvshm',
  'tidy', 'tokenizer', 'wordpress', 'xml', 'xmlreader',
  'xmlrpc', 'xmlwriter', 'xsl', 'Zend OPcache', 'zip',
  'zlib',
}

lspconfig.intelephense.setup {
  on_attach = function(_, bufnr) attach_keymap(bufnr) end,
  settings = {
    intelephense = {
      files = {
        maxSize = 3200000;
      },
      stubs = intelephense_stubs,
      environment = {
        includePaths = {
          '/home/foxtail/repo/@abatanx/waggo8.1'
        }
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
}

lspconfig.hls.setup {
  on_attach = function(_, bufnr) attach_keymap(bufnr) end,
}
