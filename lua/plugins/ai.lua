-- 用来触发 CodeCompanion 的唤起和隐藏
vim.keymap.set({ 'n', 'v' }, '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', { desc = 'Toggle CodeCompanion Chat' })

-- 定义消息的 sign，会显示在 signcolumn 上
vim.fn.sign_define('CodeCompanionUser', { text = '🪴' }) -- 🙋👨‍💻🪴
vim.fn.sign_define('CodeCompanionRobot', { text = '✨' }) -- 🤖✨🌲

-- 定义一个全局变量来追踪 AI 响应状态
_G.codecompanion_status = {
    is_responding = false,
    spinner_chars = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
    spinner_index = 1,
}

-- 为每个 spinner 字符定义 sign
for i, char in ipairs(_G.codecompanion_status.spinner_chars) do
    vim.fn.sign_define('CodeCompanionThinking' .. i, { text = char, texthl = 'DiagnosticInfo' })
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'codecompanion',
    callback = function(args)
        local bufnr = args.buf

        vim.wo.number = false -- 关闭行号
        vim.wo.signcolumn = 'yes' -- 确保显示 signcolumn

        -- 添加跳转快捷键
        vim.keymap.set('n', '[c', function()
            vim.fn.search('^## Me', 'b')  -- 向上跳转到上一个用户发言
        end, { buffer = bufnr, desc = 'Jump to previous user message' })
        vim.keymap.set('n', ']c', function()
            vim.fn.search('^## Me')  -- 向下跳转到下一个用户发言
        end, { buffer = bufnr, desc = 'Jump to next user message' })

        -- 创建一个函数来更新 signs
        local function update_signs()
            -- 清除之前的 signs
            vim.fn.sign_unplace('codecompanion_user_group', { buffer = bufnr })

            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            for i, line in ipairs(lines) do
                -- 匹配用户发言的行
                if line:match('^## Me') then
                    vim.fn.sign_place(0, 'codecompanion_user_group', 'CodeCompanionUser', bufnr, {
                        lnum = i,
                        priority = 10
                    })
                end
                if line:match('^## CodeCompanion') then
                    vim.fn.sign_place(0, 'codecompanion_user_group', 'CodeCompanionRobot', bufnr, {
                        lnum = i,
                        priority = 10
                    })
                end
            end
        end

        -- 初始化时更新一次
        vim.schedule(update_signs)

        -- 监听 buffer 内容变化
        vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufEnter' }, {
            buffer = bufnr,
            callback = function()
                vim.schedule(update_signs)
            end,
        })
    end,
})

-- 监听 CodeCompanion 的请求事件
vim.api.nvim_create_autocmd('User', {
    pattern = 'CodeCompanionRequest*',
    callback = function(args)
        local bufnr = vim.api.nvim_get_current_buf()

        if args.match == 'CodeCompanionRequestStarted' then
            -- 请求开始
            _G.codecompanion_status.is_responding = true

            -- 启动旋转动画(在 signcolumn 显示)
            if vim.bo[bufnr].filetype == 'codecompanion' then
                local function spinner_tick()
                    if not _G.codecompanion_status.is_responding then
                        return
                    end

                    -- 清除之前的 thinking sign
                    vim.fn.sign_unplace('codecompanion_thinking', { buffer = bufnr })

                    -- 获取当前 buffer 的最后一行
                    local line_count = vim.api.nvim_buf_line_count(bufnr)

                    -- 放置当前 spinner 字符的 sign
                    local sign_name = 'CodeCompanionThinking' .. _G.codecompanion_status.spinner_index
                    vim.fn.sign_place(0, 'codecompanion_thinking', sign_name, bufnr, {
                        lnum = line_count,
                        priority = 20
                    })

                    -- 更新 spinner 索引
                    _G.codecompanion_status.spinner_index =
                    (_G.codecompanion_status.spinner_index % #_G.codecompanion_status.spinner_chars) + 1

                    -- 继续下一帧动画
                    vim.defer_fn(spinner_tick, 100)
                end

                spinner_tick()
            end

        elseif args.match == 'CodeCompanionRequestFinished' then
            -- 请求完成
            _G.codecompanion_status.is_responding = false
            _G.codecompanion_status.spinner_index = 1

            -- 清除思考中的 sign
            vim.fn.sign_unplace('codecompanion_thinking', { buffer = bufnr })

            -- 清除命令行消息
            vim.api.nvim_echo({{'', 'Normal'}}, false, {})
        end
    end,
})

return {
    {
        "olimorris/codecompanion.nvim",
        version = "v18.3.1",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-lua/plenary.nvim"
        },
        opts = {
            display = {
                chat = {
                    window = {
                        -- 整体效果是悬浮在右侧
                        layout = 'float', -- 或 'vertical' / 'horizontal'
                        width = 0.3,
                        height = 0.9,
                        border = 'rounded',
                        relative = 'editor',
                        row = 0,
                        col = vim.o.columns,
                        zindex = 50,
                    },
                    show_token_count = true, -- 在http模式下会显示，但是在ACP下不显示，不知道为啥
                    render = 'native',
                },
            },

            extensions = {
                history = {
                    enabled = true, -- 启用 history 扩展
                    opts = {
                        keymap = '<leader>ch',           -- 打开会话历史，chat history的缩写
                        save_chat_keymap = '<leader>cs', -- 手动保存当前 chat，是chat save的缩写
                        auto_save = true,                -- 推荐开启自动保存，这样都不用操心，随时都可以退出
                        picker = 'fzf-lua',              -- 如果没装 telescope/snacks/fzf-lua，就用 default
                        title_generation_opts = {
                            adapter = 'anthropic',       -- 使用 HTTP-based anthropic adapter，否则在使用ACP方式时会有warning
                        },
                    }
                }
            },

            opts = {  -- 全局日志配置
                log_level = "WARN",  -- 或 "TRACE" 获取最详细日志
            },

            -- 下面是模型相关的配置
            interactions = {
                chat = {
                    adapter = 'claude_code'
                },
                inline = {
                    adapter = 'anthropic', -- ACP不支持inline，所以还是用http模式的adapter，但inline模式还待验证
                },
            },
            adapters = {
                http = {
                    anthropic = function()
                        return require('codecompanion.adapters').extend('anthropic', {
                            -- 这里面的结构如果不知道确定咋配置，可以去参考下codecompanion插件下的
                            -- 源码 lua/codecompanion/adapters/http/anthropic.lua
                            env = {
                                api_key = os.getenv('ANTHROPIC_AUTH_TOKEN'),
                            },
                            url = os.getenv('ANTHROPIC_BASE_URL') .. '/v1/messages',
                            schema = {
                                model = {
                                    default = 'claude-sonnet-4-5-20250929'
                                }
                            },
                            opts = {
                                stream = true,
                                log_level = 'WARN',
                            },
                        })
                    end,
                },
                acp = {
                    -- 在使用ACP模式时，需要先启动一个ACP服务，就是执行 claude-code-acp &
                    claude_code = function()
                        return require("codecompanion.adapters").extend("claude_code", {
                            env = {
                                ANTHROPIC_API_KEY = os.getenv('ANTHROPIC_API_KEY'),
                            },
                            commands = { -- 在使用的时候去执行这个命令，而不需要手动启动，占用shell窗口
                                default = { "claude-code-acp" },
                            }
                        })
                    end,
                },
            },
        },
    },
    {
        "ravitemer/codecompanion-history.nvim",
        lazy = true
    },
    {
        "https://code.byted.org/chenjiaqi.cposture/codeverse.vim.git",
        dependencies = {
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require("trae").setup()
        end
    },
}
