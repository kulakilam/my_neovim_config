-- 用来配置搜索相关的插件
-- 包括搜索当前buffer的关键字、搜索文件、搜索目录下所有文件的关键字等

-- flash.nvim
require("flash").setup({
    labels = "ASDFGHJKLQWERTYUIOP", -- 跳转标签
    search = {
        multi_window = true,
        mode = "fuzzy"
    },
    jump = {
        autojump = false,
        nohlsearch = false
    },
    modes = { search = { enabled = true }, char = { enabled = false } },
    label = {
        after = false,
        before = true,
        rainbow = { enabled = true }
    }
})
