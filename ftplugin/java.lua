local root_dir = vim.fs.dirname(
  vim.fs.find({'gradle', '.git', 'mvnw', '.project'}, { upward = true }
)[1])

vim.cmd.packadd('nvim-jdtls')

local jdtls = require('jdtls')

local jdtls_lib_path = '/usr/local/Cellar/jdtls/1.37.0/libexec'

jdtls.extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

local workspace_dir = os.getenv('HOME') .. '/.jdtls_workspace/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

jdtls.start_or_attach({
  cmd = {
    '/usr/local/opt/openjdk@22/bin/java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx4g',
    '-Xms2g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-javaagent:' .. os.getenv('HOME') .. '/.config/nvim/deps/lombok.jar',
    '-Xbootclasspath/a:' .. os.getenv('HOME') .. '/.config/nvim/deps/lombok.jar',
    '-jar', jdtls_lib_path .. '/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar',
    '-configuration', jdtls_lib_path .. '/config_mac',
    '-data', workspace_dir,
  },
  root_dir = root_dir,
  settings = {
    java = {
      autobuild = { enabled = false },
      codeGeneration = {
        generateComments = false,
      },
      signatureHelp = { enabled = true },
      configuration = {
        updateBuildConfiguration = 'disabled',
      },
      eclipse = {
        downloadSources = true,
      },
      project = {
        referencedLibraries = {
          "lib/**/*.java",
          "../lib/**/*.java",
        },
        resourceFilters = {
          ".git",
        },
      },
      jdt = {
        ls = {
          lombokSupport = { enabled = true },
        },
      },
      compile = {
        nullAnalysis = {
          nonnull = {
            "org.springframework.lang.NonNull",
          },
          nullable = {
            "org.springframework.lang.Nullable",
          },
          mode = "automatic",
        },
      },
    },
  },
})
