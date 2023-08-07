local util = require('lsp')

local stubs = {
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
  'tidy', 'tokenizer', 'xml', 'xmlreader',
  'xmlrpc', 'xmlwriter', 'xsl', 'Zend OPcache', 'zip',
  'zlib',
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'php',
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.start({
      name = 'intelephense',
      cmd = { 'intelephense', '--stdio' },
      root_dir = util.find_root(buf),
      settings = {
        intelephense = {
          files = {
            maxSize = 3200000;
          },
          stubs = stubs,
        },
      },
    })
    vim.lsp.buf_attach_client(buf, client)
  end,
})
