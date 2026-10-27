-- プロジェクト固有値は .nvim.lua の vim.g.dotvim_jdtls で渡す (詳細は jdtls.lua)。
-- .nvim.lua を読むには exrc = true が要る。dotvim.base が有効にするので、
-- base を使わない場合はマシン側の設定で有効にすること。
return require('dotvim._lib.feature').define({
  name = 'java',
  specs = {
    'https://github.com/mfussenegger/nvim-jdtls',
  },
  setup = function()
    local group = vim.api.nvim_create_augroup('dotvim.java', { clear = true })

    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      pattern = 'java',
      callback = function(ev)
        require('dotvim.java.jdtls').start(ev.buf)
      end,
    })

    -- build.gradle などの編集中にも使えるよう、java バッファに限定しない。
    vim.api.nvim_create_user_command('JdtlsAndroidLibs', function(opts)
      require('dotvim.java.android-libs').command(opts.fargs)
    end, {
      nargs = '*',
      complete = function(arglead)
        return require('dotvim.java.android-libs').complete(arglead)
      end,
      desc = 'Android モジュールの依存一覧を生成して jdtls を作り直す',
    })
  end,
})
