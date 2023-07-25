local nvim_lsp = require('lspconfig')

local on_attach = function (client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'gx', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', 'g[', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', 'g]', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
end

local is_deno_repo = function() return vim.fs.dirname(vim.fs.find({'deno.json', 'deno.jsonc'}, { upward = true })[1]) ~= nil end

nvim_lsp.tsserver.setup({
  on_attach = function(client, bufnr)
    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end
    client.server_capabilities.document_formatting = false
    on_attach(client, bufnr)
  end,
  root_dir = function(fname)
    return nvim_lsp.util.find_node_modules_ancestor(fname) or vim.loop.os_homedir()
  end,
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "typescriptreact"
  },
  flags = {
    debounce_text_changes = 150,
  },
  autostart = not(is_deno_repo())
})

nvim_lsp.denols.setup({
  on_attach = on_attach,
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  },
  root_dir = function()
    return vim.fs.dirname(vim.fs.find({'deno.json', 'deno.jsonc'}, { upward = true })[1])
  end,
  single_file_support = false,
  autostart = is_deno_repo(),
  init_options = { lint = true, unstable = true }
})

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}

local prettier = {
  formatCommand = 'prettierd "${INPUT}"',
  formatStdin = true,
  env = {
    string.format('PRETTIERD_DEFAULT_CONFIG=%s', vim.fn.expand('~/.config/nvim/utils/linter-config/prettierrc.json')),
  },
}

nvim_lsp.efm.setup({
  on_attach = function(client, bufnr)
    client.server_capabilities.document_formatting = true
    client.server_capabilities.goto_definition = false
    on_attach(client, bufnr)
  end,
  root_dir = function(fname)
    return nvim_lsp.util.find_node_modules_ancestor(fname) or vim.loop.os_homedir()
  end,
  settings = {
    languages = {
      javascript = {eslint, prettier},
      javascriptreact = {eslint, prettier},
      ["javascript.jsx"] = {eslint, prettier},
      typescript = {eslint, prettier},
      ["typescript.tsx"] = {eslint, prettier},
      typescriptreact = {prettier},
    }
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "typescriptreact",
  }
})

local intelephense_stubs = {
  "apache", "bcmath", "bz2", "calendar", "com_dotnet",
  "Core", "ctype", "curl", "date", "dba",
  "dom", "enchant", "exif", "FFI", "fileinfo",
  "filter", "fpm", "ftp", "gd", "gettext", "gmp",
  "hash", "iconv", "imap", "intl", "json",
  "ldap", "libxml", "mbstring", "meta", "mysqli",
  "oci8", "odbc", "openssl", "pcntl", "pcre",
  "PDO", "pdo_ibm", "pdo_mysql", "pdo_pgsql", "pdo_sqlite",
  "pgsql", "Phar", "posix", "pspell", "readline",
  "Reflection", "session", "shmop", "SimpleXML", "snmp",
  "soap", "sockets", "sodium", "SPL", "sqlite3",
  "standard", "superglobals", "sysvmsg", "sysvsem", "sysvshm",
  "tidy", "tokenizer", "wordpress", "xml", "xmlreader",
  "xmlrpc", "xmlwriter", "xsl", "Zend OPcache", "zip",
  "zlib",
}

nvim_lsp.intelephense.setup({
  on_attach = on_attach,
  settings = {
    intelephense = {
      files = {
        maxSize = 3200000;
      },
      stubs = intelephense_stubs,
      environment = {
        includePaths = {
          "/home/foxtail/repo/@abatanx/waggo8.1"
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
})

nvim_lsp.hls.setup({
  on_attach = on_attach
})
