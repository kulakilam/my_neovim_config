require('gitsigns').setup {
    -- 定义要显示的sign，以及对应的显示字符、sign高亮、行号高亮、行高亮
    signs = {
        add          = { hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'    },
        change       = { hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn' },
        delete       = { hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn' },
        topdelete    = { hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn' },
        changedelete = { hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn' },
        untracked    = { hl = 'GitSignsAdd'   , text = '┆', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'    },
    },
    -- 是否开启signcolumn
    signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    -- 是否开启行号的高亮
    -- LSP的代码诊断sign出现时，signcolumn会被占用，所以这里把行号的高亮也开启
    numhl      = true, -- Toggle with `:Gitsigns toggle_numhl`
    -- 是否开启行的高亮
    linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`

    -- 监听.git目录来感知变化，从而能够更新signs
    watch_gitdir = {
        interval = 1000,
        follow_files = true
    },

    attach_to_untracked = true,
    -- 显示git blame在行末
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
    },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
    -- vim的sign优先级详见:h sign-priority
    -- @todo：vim默认给一个sign的优先级是10，为啥这个插件默认给了6?
    sign_priority = 6,
    -- 防抖
    update_debounce = 100,
    status_formatter = nil, -- Use default
    -- 如果文件操作这个行数，则git sign的功能会被关闭
    max_file_length = 40000, -- Disable if file is longer than this (in lines)
    -- 应该是使用floating window做预览功能
    preview_config = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
    },
    yadm = {
        enable = false
    },

    -- 先不开启keymapping，目前满足高亮需求即可
}
