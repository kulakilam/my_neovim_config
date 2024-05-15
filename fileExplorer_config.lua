-- 默认配置在stdpath('data')/plugged/nvim-tree.lua/lua/nvim-tree.lua的DEFAULT_OPTS变量
-- 所有配置项都可以通过:h nvim-tree.xxx.xxx找到帮助文档，或者直接:h {配置项}，反正neovim支持补全
require('nvim-tree').setup({
    -- 跟netrw相关的配置
    -- 执行vim {path} 时，如果要使用nvim-tree打开，必须满足三个条件：
    -- 1. hijack_netrw开启
    -- 2. hijack_directories开启

    -- disable_netrw原理：相当于这个配置
    -- let g:loaded_netrw       = 1
    -- let g:loaded_netrwPlugin = 1
    -- 但是为了保险起见，:h disable_netrw中建议在init.vim开头配置上，避免vim启动时的插件顺序不确定性，
    -- 导致netrw还没来得及禁止掉，被其他插件给打开
    disable_netrw = false,
    -- hijack_netrw原理：
    -- ```
    -- if hijack_netrw then
    --   vim.cmd "silent! autocmd! FileExplorer *"
    --   vim.cmd "autocmd VimEnter * ++once silent! autocmd! FileExplorer *"
    -- end
    -- ```
    -- silent! 表示错误信息也会被忽略，一般silent是只忽略正常信息，详见:h silent!
    -- autocmd! 表示移除跟{event} + {autopat}相关的所有command，详见:h autocmd-remove
    --          在这里{event}是FileExplorer，{autopat}是*
    --          而FileExplorer这个event会在编辑目录时会触发运行netrw，详见:h FileExplorer
    --          所以这里最终的效果是，移除这个事件，不再触发netrw
    -- 第二行的意思是，订阅了VimEnter事件，在打开vim时，移除FileExplorer事件，详见:h VimEnter
    -- 相当于是对第一行的双重保险。
    hijack_netrw = true,
    -- 当编辑目录时，由nvim-tree来接管
    hijack_directories = {
        enable = true,
        auto_open = true,
    },
    -- 有buffer写入时都自动重新加载explorer
    auto_reload_on_write = true,
    -- 当光标在一个折叠的目录上，执行创建文件的动作
    -- true：创建的文件会在折叠的目录里面
    -- false：创建的文件跟光标所在的目录同级，否则如果要创建同级的文件，
    --        就得特意把光标移动到一个非目录的行上
    create_in_closed_folder = false,

    sort_by = 'case_sensitive', -- 大写字母的会排在前面，其他的还是按照字母排序
    hijack_cursor = true, -- 保持光标始终在文件名/目录名的第一个字符
    select_prompts = false, -- 改变选择的提示交互过程，还是默认的false体验好一点
    view = {
        width = 30, -- 宽度固定30
        side = 'left',
        adaptive_size = false, -- 切换了false和true都没有看到什么效果
        centralize_selection = false, -- 当光标从buffer切换到目录树时，当前打开的这个buffer对应的节点始终在视野中
        signcolumn = 'yes', -- 就是vim本身的signcolumn，后面代码诊断、git状态可以显示在这里
        float = {
            enable = false, -- 虽然很酷，但是<Tab>预览时体验不好，最好是能在floating window里面预览
            quit_on_focus_loss = true, -- 焦点离开floating window时，自动关闭
            open_win_config = { -- 具体可以看:h nvim_open_win()
                relative = 'editor',
                border = 'rounded',
                width = 30,
                height = 30,
                -- row = 1,
                -- col = 0,
                anchor = 'SW', -- 配置floating window显示的方位，不知道为啥没有生效
            },
        },
    },
    renderer = {
        group_empty = true, -- 当一个目录下只有一个目录时，会显示在一起
        highlight_git = true, -- 根据Git状态来高亮文件名，而文件前面的icon本身已经有高亮了，跟这个无关
        icons = {
            -- 三种选择，before、after、signcolumn
            -- before(默认): 文件名前面。会让文件名不对齐
            -- after: 文件名后面
            -- signcolumn: 放在signcolumn上，因为后面还要放代码诊断的信息，所以就不放在这了
            git_placement = 'after',
        },
        -- 特殊文件，会有下划线和特殊颜色高亮
        special_files = { 'Cargo.toml', 'Makefile', 'README.md', 'readme.md' },
    },
    git = {
        enable = true, -- 开启Git状态的支持
        ignore = true, -- 根据.gitignore下面的配置，忽略掉不需要显示git状态的文件或目录
        show_on_dirs = true, -- 是否在文件夹上显示icon，对折叠的文件夹很有用
        timeout = 300, -- 如果git进程的时间太长，杀掉git进程
    },
    diagnostics = { -- 代码诊断信息，数据来自nvim-lsp，显示在signcolumn上
        enable = true,
        show_on_dirs = true, -- 是否在文件夹上显示icon，对折叠的文件很有用
        debounce_delay = 50, -- 单位ms，防抖动
        icons = {
            hint = '',
            info = '',
            warning = '',
            error = '',
        },
    },
    filters = {
        dotfiles = true, -- 按H时隐藏dotfile（隐藏文件）
    },
    update_focused_file = {
        -- 非常有用，当光标移动到某个buffer时，目录树会展开该文件的位置
        -- 源码中是获取文件绝对路径来找到位置并展开，性能没啥问题。
        -- 代码详见：M.find_file()
        enable = true,
        update_root = false, -- 效果是打开一个不在当前root下的文件，会自动更改root。先不打开，回到刚才的目录会比较麻烦
    },
    actions = {
        expand_all = {
            max_folder_discovery = 100, -- 展开的最大目录数量，这个数太大会很慢
            exclude = { '.git', 'node_modules', 'site-packages' } -- 过滤掉这种又大又没啥用的目录
        },
        file_popup = { -- 用于<C-k>快捷键显示的文件信息
            open_win_config = {
                -- 想对光标的位置
                relative = 'cursor',
                col = 1,
                row = 1,
                border = 'rounded',
                style = 'minimal',
            },
        },
        open_file = {
            quit_on_open = false, -- 当从tree上打开一个文件时，关闭tree。如果不是从tree上打开的，不会关闭
            resize_window = true, -- 当从tree上打开一个文件时，resize窗口大小。如果不是从tree上打开的，不会resize
            -- 打开文件时，如果有多个窗口，需要选择一个窗口
            -- 如果是用大O打开文件，不需要选择，关于大O，详见:h nvim-tree-mappings-default
            window_picker = {
                enable = true,
                chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890', -- 选择窗口时的字符选项
                exclude = {
                    filetype = { 'notify', 'packer', 'qf', 'diff', 'fugitive', 'fugitiveblame' },
                    buftype = { 'nofile', 'terminal', 'help' },
                },
            },
        },
        remove_file = {
            -- 在某个窗口中打开的文件，在tree上被删除时，window自动关闭
            close_window = true,
        },
    },
    -- 使用libuv fs_event来监听文件系统变化，性能更好
    filesystem_watchers = {
        enable = true,
        debounce_delay = 50,
        ignore_dirs = {},
    },
    -- 实时过滤目录树，对应f键
    live_filter = {
        prefix = '[FILTER]: ',
        -- true：始终显示目录名，即使不匹配filter关键字
        -- false：支持过滤目录名
        always_show_folders = false,
    },
    tab = {
        -- 不同tab之间的tree同步
        sync = {
            -- 如果一个tab下开着tree，打开新的tab也会自动开启tree，
            -- 且各种状态都一致，比如root_dir、哪些目录是展开的
            open = true,
            -- 如果在某个tab下把tree给close掉，其他tab下的tree也会同步关闭
            close = true,
            ignore = {}, -- 填写filetype、buffer名称
        },
    },
    notify = {
        -- 设置最小通知级别，默认是INFO
        -- 从低到高分别是DEBUG, INFO, WARNING, ERROR
        threshold = vim.log.levels.INFO,
    },
    -- 是否开启日志输出，如果有调试需要再开启吧
    log = {
        enable = false,
        -- true应该是每次都追加，false是每次vim启动都用新的文件
        -- @todo：如果多个vim开启呢
        truncate = false,
        types = {
            all = false,
            config = false,
            copy_paste = false,
            dev = false,
            diagnostics = false,
            git = false,
            profile = false,
            watcher = false,
        },
    },
})

require("symbols-outline").setup({
  highlight_hovered_item = true,
  show_guides = true,
  auto_preview = false,
  position = 'right',
  relative_width = true,
  width = 25,
  auto_close = false,
  show_numbers = false,
  show_relative_numbers = false,
  show_symbol_details = true,
  preview_bg_highlight = 'Pmenu',
  autofold_depth = nil,
  auto_unfold_hover = true,
  fold_markers = { '', '' },
  wrap = false,
  keymaps = { -- These keymaps can be a string or a table for multiple keys
    close = {"<Esc>", "q"},
    goto_location = "<Cr>",
    focus_location = "o",
    hover_symbol = "<C-space>",
    toggle_preview = "K",
    rename_symbol = "r",
    code_actions = "a",
    fold = "h",
    unfold = "l",
    fold_all = "W",
    unfold_all = "E",
    fold_reset = "R",
  },
  lsp_blacklist = {},
  symbol_blacklist = {},
  symbols = {
    File = { icon = "", hl = "@text.uri" },
    Module = { icon = "", hl = "@namespace" },
    Namespace = { icon = "", hl = "@namespace" },
    Package = { icon = "", hl = "@namespace" },
    Class = { icon = "", hl = "@type" },
    Method = { icon = "ƒ", hl = "@method" },
    Property = { icon = "", hl = "@method" },
    Field = { icon = "", hl = "@field" },
    Constructor = { icon = "", hl = "@constructor" },
    Enum = { icon = "", hl = "@type" },
    Interface = { icon = "", hl = "@type" },
    Function = { icon = "", hl = "@function" },
    Variable = { icon = "", hl = "@constant" },
    Constant = { icon = "", hl = "@constant" },
    String = { icon = "", hl = "@string" },
    Number = { icon = "#", hl = "@number" },
    Boolean = { icon = "", hl = "@boolean" },
    Array = { icon = "", hl = "@constant" },
    Object = { icon = "", hl = "@type" },
    Key = { icon = "", hl = "@type" },
    Null = { icon = "", hl = "@type" },
    EnumMember = { icon = "", hl = "@field" },
    Struct = { icon = "", hl = "@type" },
    Event = { icon = "", hl = "@type" },
    Operator = { icon = "", hl = "@operator" },
    TypeParameter = { icon = "", hl = "@parameter" },
    Component = { icon = "", hl = "@function" },
    Fragment = { icon = "", hl = "@constant" },
  },
})
