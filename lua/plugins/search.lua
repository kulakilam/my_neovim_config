return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",  -- 很晚加载（启动后空闲时），因为不常立即需要
        opts = {
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
        }
    },
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",  -- 命令触发加载（输入 :FzfLua 时加载）
        -- 或者用 keys 触发（更激进懒加载）
        -- keys = { "<leader>ff", "<leader>fg", ... }  -- 如果想用 keys 触发
        dependencies = { "nvim-tree/nvim-web-devicons" },  -- icons 支持（推荐）

        opts = {
            winopts = {
                preview = {
                    default = 'bat',  -- 用 bat 高亮预览
                },
            },
            files = {
                cwd_prompt = true, -- 显示 cwd（默认就是 true，可省略）
            }
        },
        config = function(_, opts)
            ---@diagnostic disable: undefined-field
            -- 如果悬浮窗并没有要选择的，按ESC或者<C-[>退出
            local fzf = require('fzf-lua')
            fzf.setup(opts)
            -- 常用的快捷键
            vim.keymap.set('n', '<leader>ff', '<cmd>FzfLua files<CR>', { desc = 'Find Files' }) -- 搜索cwd下面的文件
            vim.keymap.set('n', '<leader>fF', function()
                fzf.files({ cwd = vim.fn.expand('%:p:h') }) -- 搜索当前buffer所在目录
            end, { desc = 'Find Files (current file dir)' })
            vim.keymap.set('n', '<leader>fg', '<cmd>FzfLua live_grep<CR>', { desc = 'Live Grep' })
            vim.keymap.set('n', '<leader>fb', '<cmd>FzfLua buffers<CR>', { desc = 'Buffers' })
            vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua oldfiles<CR>', { desc = 'Recent Files' })
            vim.keymap.set('n', '<leader>fh', '<cmd>FzfLua help_tags<CR>', { desc = 'Help Tags' })
            -- 查看变量或函数的引用，比gr要好用一些，因为可以看预览，更方便查找
            vim.keymap.set('n', '<leader>lr', fzf.lsp_references,       { desc = 'LSP References' })
        end
    }
}
