require('nvim-treesitter.configs').setup {
    -- parser的名字列表，也可以直接写一个'all'
    -- 可以通过:TSInstallInfo查看所有parser的名字
    -- @todo：html的高亮效果有很严重的问题，先删除，还不如自带的高亮
    ensure_installed = { 'c', 'go', 'help', 'lua', 'json', 'python', 'vim', 'html', 'javascript', 'css' },

    -- 是否同步安装parser，false表示并行安装（只对上面`ensure_installed`有效）
    sync_install = false,

    -- 自动安装缺失的parser，当你进入一个buffer时
    -- 建议：设置成false，如果你没有一个`tree-sitter`CLI安装在本地
    auto_install = false,

    -- 忽略安装的parser列表
    ignore_install = {
        'bash' -- bash还是习惯vim自带的高亮
    },
    -- -- treesitter插件本身是安装在stdpath('data')/plugged/下（根据vim-plug的规则）
    -- -- parser是放在stdpath('data')/plugged/nvim-treesitter/parser/下，以so文件形式
    -- -- 如果要改变parser安装目录，可以使用这个变量
    -- parser_install_dir = '/some/path/to/store/parsers', -- Remember to run vim.opt.runtimepath:append('/some/path/to/store/parsers')!

    -- 模块的配置，除了highlight，还有incremental_selection、indent、folding
    -- 具体可以看https://github.com/nvim-treesitter/nvim-treesitter#available-modules
    highlight = {
        -- `false`会关闭整个highlight，不管是什么parser
        enable = true,

        -- -- 要关闭highlight功能的parser，注意这里是parser名称，不是filetype
        -- disable = { 'help' },

        -- 也可以使用一个函数来判断是否disable，更加灵活，比如下面这个是判断文件大小
        -- 当文件大小超过max_filesize，不开启treesitter的highlight
        -- @todo：如果给大文件手动开启treesitter高亮，怎么操作？
        disable = function(lang, buf)
            local max_filesize = 1 * 1024 * 1024 -- 单位是bytes，1MB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,

        -- 这个开关如果设置成true，会同时开启vim高亮和treesitter高亮
        --   可能会让编辑器更慢，同时也可能是出现重复的高亮
        -- 也可以设置成parser列表
        additional_vim_regex_highlighting = {
            'help' -- help这个parser的高亮太少了，不如vim自带的
        },
    },
}
