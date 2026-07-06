-- jdtls起動ロジック本体（ftplugin/java.lua から呼ばれる）。
--
-- Android(AGP)モジュールのプロジェクト固有値は、各プロジェクトルートの .nvim.lua
-- (組み込みexrc。o.exrc=true が前提で、初回ロード時に :trust が必要) から上書きできる:
--
--   vim.g.dotvim_jdtls = {
--     android = {
--       variant = 'demoDebug',                                 -- 既定 'debug'
--       java_version = '17',                                   -- 既定 '1.8'
--       source_dirs = { 'src/main/java', 'src/main/kotlin' },  -- 既定 { 'src/main/java' }
--       modules = { app = { variant = 'demoDebug' } },         -- 任意: モジュール別上書き
--     },
--   }
--
-- 未設定なら既定値(=従来のハードコード値)で動くため、.nvim.lua を置かない
-- プロジェクトの挙動は不変。
-- variant を変えた場合は jdtls/android-libs.init.gradle も同じ -Pjdtls.variant=<variant>
-- でキャッシュを再生成すること(R.jar/buildConfig が同一バリアントを指す必要がある)。

local M = {}

-- 従来のハードコード値と一致させる(.nvim.lua 無し時に挙動を変えないため)。
local ANDROID_DEFAULTS = {
  variant = 'debug',
  java_version = '1.8',
  source_dirs = { 'src/main/java' },
}

-- vim.g.dotvim_jdtls.android と ANDROID_DEFAULTS をマージして解決する。
-- スカラ(variant/java_version)は per_module > project > 既定 の優先順で選び、
-- source_dirs はリストなのでインデックスマージを避けて丸ごと置換で扱う。
local function resolve_android_opts(module_name)
  local user = (vim.g.dotvim_jdtls or {}).android or {}
  local per_module = (user.modules or {})[module_name] or {}
  local opts = {}
  for _, k in ipairs({ 'variant', 'java_version' }) do
    opts[k] = per_module[k] or user[k] or ANDROID_DEFAULTS[k]
  end
  opts.source_dirs = per_module.source_dirs or user.source_dirs or ANDROID_DEFAULTS.source_dirs
  return opts
end

-- Android Gradle Plugin(com.android.application/library)を使うモジュールは、
-- Eclipse BuildshipがそのソースセットをEclipseProjectモデルとして解決できず、
-- 同期のたびにソースフォルダなしのclasspathで上書きしてしまう(既知の構造的制約。
-- Gradle自体のビルドやJVMバージョンの問題ではない)。
--
-- かつては「invisible project」方式(srcをworkspace rootにしてreferencedLibrariesで
-- 依存を与える)にフォールバックしていたが、jdt.lsのInvisibleProjectImporterは
-- 推定ソースディレクトリ(src/main/java)の"src"セグメントの親にbuild.gradleがあると
-- isPartOfMatureProject判定でinvisible project化を拒否するため、AGPモジュールでは
-- 構造的に成立しない(ファイルはデフォルトプロジェクトにスタンドアロンでリンクされ
-- 構文チェックのみになり、ホバー・他ファイルへの定義ジャンプが効かない)。
--
-- 現在は、モジュール直下に静的なEclipseプロジェクト(.project/.classpath/.settings)を
-- 生成し、Gradle/Mavenインポートを無効化してEclipseProjectImporterに読ませる方式。
-- Buildshipを通らないので同期による上書きも起きない。
--
-- 依存JARの一覧は ~/.cache/nvim/jdtls-libs/<project>-<module>.txt に事前生成しておく
-- (生成方法は ~/.config/nvim/jdtls/android-libs.init.gradle のコメントを参照)。
-- build.gradleの依存が変わったらこのキャッシュを再生成すれば、次回起動時に
-- .classpathも作り直される。
local function find_android_module_dir(file_path, base)
  local dir = vim.fn.fnamemodify(file_path, ':h')
  while #dir > #base do
    local is_gradle_module = vim.fn.filereadable(dir .. '/build.gradle') == 1
      or vim.fn.filereadable(dir .. '/build.gradle.kts') == 1
    if is_gradle_module then
      if vim.fn.filereadable(dir .. '/src/main/AndroidManifest.xml') == 1 then
        return dir
      end
      return nil
    end
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      break
    end
    dir = parent
  end
  return nil
end

function M.start()
  local jdtls = require('jdtls')

  local bufname = vim.api.nvim_buf_get_name(0)

  local root_dir = require('jdtls.setup').find_root({
    '.git',
    'gradlew',
    'mvnw',
    'settings.gradle',
    'settings.gradle.kts',
  })
  if not root_dir or root_dir == '' then
    return
  end

  local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')

  local android_module_dir = find_android_module_dir(bufname, root_dir)

  if android_module_dir then
    local module_name = vim.fn.fnamemodify(android_module_dir, ':t')
    local opts = resolve_android_opts(module_name)
    local libs_cache = vim.fn.stdpath('cache') .. '/jdtls-libs/' .. project_name .. '-' .. module_name .. '.txt'

    if vim.fn.filereadable(libs_cache) == 1 then
      local project_file = android_module_dir .. '/.project'
      local classpath_file = android_module_dir .. '/.classpath'
      local buildship_prefs = android_module_dir .. '/.settings/org.eclipse.buildship.core.prefs'

      -- Buildshipはgradle.enabled=falseを渡していても、.settings/org.eclipse.
      -- buildship.core.prefs(auto.sync=true)が既に存在すると「Gradleリンク済み
      -- プロジェクト」とみなして同期を行い、.project/.classpathをGradle依存の
      -- 内容で上書きしてしまう(このプロジェクトのGradleImporterを無効化する
      -- 設定より、既存prefsによるリンク状態が優先される)。一度これが起きると
      -- 壊れた.classpathの方がlibsキャッシュより新しくなり、以降は再生成条件に
      -- 掛からず壊れたまま固定されてしまうため、prefsの存在自体も再生成のトリガー
      -- にし、実ファイルも削除する。
      local buildship_polluted = vim.fn.filereadable(buildship_prefs) == 1

      -- .classpathがlibsキャッシュより古い(または存在しない)、もしくは
      -- Buildshipに汚染されている場合のみ再生成する。
      if
        vim.fn.filereadable(project_file) == 0
        or vim.fn.filereadable(classpath_file) == 0
        or vim.fn.getftime(classpath_file) < vim.fn.getftime(libs_cache)
        or buildship_polluted
      then
        if buildship_polluted then
          vim.fn.delete(buildship_prefs)
        end
        vim.fn.writefile({
          '<?xml version="1.0" encoding="UTF-8"?>',
          '<projectDescription>',
          '\t<name>' .. project_name .. '-' .. module_name .. '</name>',
          '\t<comment>generated by ftplugin/java.lua (do not edit by hand)</comment>',
          '\t<projects></projects>',
          '\t<buildSpec>',
          '\t\t<buildCommand>',
          '\t\t\t<name>org.eclipse.jdt.core.javabuilder</name>',
          '\t\t\t<arguments></arguments>',
          '\t\t</buildCommand>',
          '\t</buildSpec>',
          '\t<natures>',
          '\t\t<nature>org.eclipse.jdt.core.javanature</nature>',
          '\t</natures>',
          '</projectDescription>',
        }, project_file)

        -- テストソース(test/androidTest)はコンパイルクラスパスに依存が無く
        -- エラーだらけになるだけなので、mainのみをソースフォルダにする。
        -- android.jarがjava.*を提供するため、JREコンテナはあえて入れない
        -- (入れるとjava.*がJDK側に解決されandroid.jarと食い違う)。
        local classpath = {
          '<?xml version="1.0" encoding="UTF-8"?>',
          '<classpath>',
        }

        -- ソースフォルダ(既定は src/main/java、.nvim.lua で source_dirs 上書き可)。
        -- 存在するものだけ追加する(未生成/不在のsrcをjdtlsがエラー扱いするのを避ける)。
        for _, src in ipairs(opts.source_dirs) do
          if vim.fn.isdirectory(android_module_dir .. '/' .. src) == 1 then
            table.insert(classpath, '\t<classpathentry kind="src" path="' .. src .. '"/>')
          end
        end

        -- BuildConfig.javaはGradleが生成する派生ソースで、通常はvariantのビルドで
        -- 実行された`process<Variant>Resources`等の後にのみ存在する。srcエントリを
        -- 静的に決め打ちすると、未生成時にjdtlsが存在しないフォルダとして
        -- エラー扱いするため、存在確認してから追加する
        -- (無ければ「BuildConfig cannot be resolved」の偽陽性が出るが、
        -- 一度対象variantをビルドすれば次回の.classpath再生成で解消する)。
        local buildconfig_rel = 'build/generated/source/buildConfig/' .. opts.variant
        if vim.fn.isdirectory(android_module_dir .. '/' .. buildconfig_rel) == 1 then
          table.insert(classpath, '\t<classpathentry kind="src" path="' .. buildconfig_rel .. '"/>')
        end

        for _, line in ipairs(vim.fn.readfile(libs_cache)) do
          if line ~= '' then
            table.insert(classpath, '\t<classpathentry kind="lib" path="' .. line .. '"/>')
          end
        end
        table.insert(classpath, '\t<classpathentry kind="output" path="bin"/>')
        table.insert(classpath, '</classpath>')
        vim.fn.writefile(classpath, classpath_file)

        -- コンパイラ準拠レベルを明示する。未指定だとjdtls起動JVM(最新)基準になり、
        -- android.jar(1.8想定)との組み合わせで誤診断が出うる。既定はAGPのcompileOptions
        -- デフォルトに合わせて1.8。.nvim.lua の java_version で上書き可。
        vim.fn.mkdir(android_module_dir .. '/.settings', 'p')
        vim.fn.writefile({
          'eclipse.preferences.version=1',
          'org.eclipse.jdt.core.compiler.codegen.targetPlatform=' .. opts.java_version,
          'org.eclipse.jdt.core.compiler.compliance=' .. opts.java_version,
          'org.eclipse.jdt.core.compiler.source=' .. opts.java_version,
        }, android_module_dir .. '/.settings/org.eclipse.jdt.core.prefs')
      end

      local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls-workspace/' .. project_name .. '-' .. module_name

      local android_config = {
        cmd = { 'jdtls', '-data', workspace_dir },
        root_dir = android_module_dir,
        settings = {
          java = {
            import = {
              gradle = { enabled = false },
              maven = { enabled = false },
            },
          },
        },
        init_options = {
          bundles = {},
          extendedClientCapabilities = jdtls.extendedClientCapabilities,
        },
      }
      -- settingsはworkspace/didChangeConfigurationとしてinitialize完了"後"に送られるため、
      -- それだけだと起動直後のインポートでGradleProjectImporter(Buildship)が先に走って
      -- しまう。initializationOptions.settingsとして渡すことでinitialize時点から
      -- Gradle/Mavenインポート無効を効かせ、EclipseProjectImporterに.projectを拾わせる。
      android_config.init_options.settings = android_config.settings

      jdtls.start_or_attach(android_config)
      return
    end

    vim.notify(
      'jdtls: Androidモジュール(' .. module_name .. ')用の依存関係キャッシュが見つかりません: ' .. libs_cache,
      vim.log.levels.WARN
    )
  end

  -- 通常のGradle/Mavenプロジェクト(AGP以外)はこれまで通りBuildship経由でインポートする。
  local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls-workspace/' .. project_name

  -- gradle.propertiesでorg.gradle.java.homeが明示されているプロジェクトでは、
  -- Buildshipが使うGradle Tooling API接続先のJDKもそれに合わせる。
  -- 未指定ならシステムデフォルトのままにして他プロジェクトに影響させない。
  -- (指定なしだとjdtls起動元JVMがそのままToolingAPI接続に使われ、
  --  そのJVMをGradle側がまだサポートしていないと同期が失敗することがある。
  --  ただしjdtls本体の起動JVM(cmd_env)自体は変えない。jdtls自体はJava21+を
  --  要求するため、Gradleビルド用の古めのJDKで上書きするとjdtls起動自体が
  --  失敗する。あくまでGradle Tooling API接続先だけを settings 経由で指定する)
  local gradle_java_home = nil
  local gradle_properties = io.open(root_dir .. '/gradle.properties', 'r')
  if gradle_properties then
    for line in gradle_properties:lines() do
      local value = line:match('^%s*org%.gradle%.java%.home%s*=%s*(.-)%s*$')
      if value then
        gradle_java_home = value
      end
    end
    gradle_properties:close()
  end

  local jdtls_config = {
    cmd = { 'jdtls', '-data', workspace_dir },
    root_dir = root_dir,
    settings = {
      java = {
        import = {
          gradle = {
            enabled = true,
            wrapper = { enabled = true },
          },
        },
        configuration = {
          updateBuildConfiguration = 'automatic',
        },
      },
    },
    init_options = {
      bundles = {},
      extendedClientCapabilities = jdtls.extendedClientCapabilities,
    },
  }

  if gradle_java_home then
    jdtls_config.settings.java.import.gradle.java = { home = gradle_java_home }
  end

  jdtls.start_or_attach(jdtls_config)
end

return M
