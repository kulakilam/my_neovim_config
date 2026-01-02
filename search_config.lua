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

-- fzf-lua
-- 如果悬浮窗并没有要选择的，按ESC或者<C-[>退出
local fzf = require('fzf-lua')
fzf.setup({
    winopts = {
        preview = {
            default = 'bat',  -- 用 bat 高亮预览
        },
    },
    files = {
        cwd_prompt = true, -- 显示 cwd（默认就是 true，可省略）
    }
})
-- 常用的快捷键
vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<CR>', { desc = 'Find Files' }) -- 搜索cwd下面的文件
vim.keymap.set('n', '<leader>fF',
    function() fzf.files({ cwd = vim.fn.expand('%:p:h') }) end, -- 搜索当前buffer所在目录
    { desc = 'Find Files (current file dir)' }
)
vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua live_grep<CR>', { desc = 'Live Grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<CR>', { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua oldfiles<CR>', { desc = 'Recent Files' })
vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua help_tags<CR>', { desc = 'Help Tags' })
-- 查看变量或函数的引用，比gr要好用一些，因为可以看预览，更方便查找
vim.keymap.set('n', '<leader>lr', fzf.lsp_references,       { desc = 'LSP References' })
