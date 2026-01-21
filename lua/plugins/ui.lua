return {
    {
        "folke/tokyonight.nvim",
        branch = 'main',
        lazy = false,          -- 必须立即加载（主题要最早）
        priority = 1000,       -- 最高优先级，确保其他插件加载前主题已就位
        opts = {
            style = 'night',   -- 对应 tokyonight-night
            terminal_colors = true,
            -- transparent = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
                sidebars = "transparent",
                floats = "transparent",
            },
            -- 在这里覆盖基础颜色
            on_colors = function(colors)
                colors.bg = "#21252b"           -- 主背景色（Normal, buffer 等）
                colors.bg_dark = "#21252b"      -- 可选：比 bg 更暗的变体（statusline, tabline 等用）
                colors.bg_statusline = "#24282f"  -- 如果 statusline 颜色不对可以强制
                colors.bg_sidebar = "#282c34"     -- 如果 sidebar 背景没跟上
            end,
            on_highlights = function(hl, _)
                -- 这里直接自定义 GitSigns 高亮（最干净的方式）
                hl.GitSignsAdd = { fg = "#26a641" }
                hl.GitSignsChange = { fg = "#fddf68" }
                hl.GitSignsDelete = { fg = "#b62324" }
                -- 其他想改的高亮也可以加在这里
                hl.Pmenu = { bg = "#282c34" }
                hl.CmpDocNormal = { bg = "#21252b" }
                hl.CmpDocBorder = { fg = "#875612" }
                hl.NvimTreeCursorLine = { bg = "#353b45" }
            end,
        },
        config = function (_, opts)
            require("tokyonight").setup(opts)
            vim.cmd.colorscheme("tokyonight-night")
        end
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        -- 依赖（必须的，缺少会警告或渲染不全）
        dependencies = {
            "nvim-treesitter/nvim-treesitter",  -- 解析核心
            "nvim-tree/nvim-web-devicons",      -- icons
        },

        -- 关键：lazy 加载时机
        ft = { "markdown", "codecompanion" },  -- 只在这些 filetype 打开时加载 + 自动 attach

        -- 直接用 opts 传入你的自定义配置（插件会自动调用 setup(opts)）
        opts = {
            file_types = { "markdown", "codecompanion" },  -- 冗余但清晰，插件会优先用 ft

            render_modes = true,  -- 在所有模式（包括 insert）渲染（推荐，写 Markdown 时实时看到效果）

            code = {
                sign = false,          -- 关闭左侧标记（干净）
                width = "block",       -- 全宽代码块（美观）
                border = "thin",       -- 细边框（或 "rounded" / "thick"）
                above = "▄",           -- 上边框装饰
                below = "▀",           -- 下边框装饰
            },

            heading = {
                icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },  -- 你的标题图标（需 Nerd Font）
                -- 其他 heading 选项如 sign, border 等可按需加
            },

            -- 其他常用推荐选项（可选，根据需要加）
            bullet = { icons = { "•", "○", "◆" } },
            checkbox = { enabled = true },
            link = { enabled = true },
            quote = { enabled = true },
        },
    },
    {
        -- lualine.nvim：状态栏 + tabline（顶部 buffer 栏）
        {
            "nvim-lualine/lualine.nvim",
            event = "VeryLazy",  -- 启动后空闲时加载（状态栏不需立即出现）
            dependencies = { "nvim-tree/nvim-web-devicons" },  -- icons 支持（可选，但推荐）
            opts = {
                options = {
                    -- theme默认是auto，自动拿了colorscheme的值，
                    -- 除非是colorscheme设置成别的，而只有状态栏想用特定主题色
                    -- 这里好像只能设置成tokyonight，不能设置成tokyonight-night，否则会报错
                    theme = 'tokyonight',
                    -- 1表示显示文件的相对路径
                    path = 1
                },
                tabline = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        {
                            'buffers',
                            hide_filename_extension = false,
                            show_filename_only = true,
                            show_modified_status = true,
                            icons_enabled = false, -- 不显示文件名前面的图标，没啥用

                            mode = 2,

                            max_length = vim.o.columns * 4 / 5, -- 最多占屏幕宽度的 4/5，避免挤满

                            filetype_names = {
                                NvimTree = 'Tree',
                            },

                            use_mode_colors = false,

                            buffers_color = {
                                active = "lualine_a_normal",   -- 当前 buffer 用强高亮（类似 mode 区）
                                inactive = "lualine_b_normal", -- 非当前buffer，用弱高亮
                            },

                            symbols = {
                                modified = " ●",   -- 已修改用圆点标志（比默认 [+] 更好看）
                                alternate_file = "⇄ ", -- 上一次访问的 buffer 用井号标志
                                directory = "",
                            },

                            padding = { left = 2, right = 1 },
                        }
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
            },
            config = function(_, opts)
                require('lualine').setup(opts)

                -- ==================== 顶部 buffer 栏 toggle 功能 ====================

                -- 全局标志：是否已被用户手动控制过（true = 手动优先，忽略自动规则）
                local manual_override = false

                -- 根据 buffer 数量自动更新显示状态（仅在未被手动控制时生效）
                local function update_tabline_auto()
                    if manual_override then
                        return  -- 已手动控制，自动规则不再介入
                    end

                    local buf_count = #vim.fn.getbufinfo({ buflisted = 1 })
                    if buf_count > 1 then
                        vim.o.showtabline = 2  -- 显示
                    else
                        vim.o.showtabline = 0  -- 完全隐藏（不留空行）
                    end
                end

                -- 手动 toggle 函数（每次调用都会接管控制权）
                local function toggle_buffer_bar()
                    manual_override = true  -- 标记为手动模式

                    if vim.o.showtabline == 2 then
                        vim.o.showtabline = 0
                        vim.notify("Buffer bar: 隐藏", vim.log.levels.INFO)
                    else
                        vim.o.showtabline = 2
                        vim.notify("Buffer bar: 显示", vim.log.levels.INFO)
                    end
                end

                -- 初始应用一次自动规则
                update_tabline_auto()

                -- buffer 变化时尝试自动更新（但尊重手动优先）
                vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufEnter" }, {
                    callback = function()
                        vim.schedule(update_tabline_auto)
                    end,
                })

                -- 这里的buffer序号跟顶部栏是一致的，这样我有时候在按下快捷键之前就知道要切换的buffer的序号了，体验会更好
                local function select_buffer()
                    local buffers = vim.fn.getbufinfo({ buflisted = 1 })
                    if #buffers <= 1 then
                        vim.notify("只有一个 buffer，无需选择", vim.log.levels.INFO)
                        return
                    end

                    local current_buf = vim.api.nvim_get_current_buf()
                    local items = {}

                    for _, buf in ipairs(buffers) do
                        local name = buf.name ~= "" and vim.fn.fnamemodify(buf.name, ":t") or "[No Name]"
                        if buf.changed == 1 then name = name .. " [+]" end

                        -- 只加一个醒目的前缀标记当前 buffer，不加任何序号！因为vim.ui.select()会自动给每个选项加序号
                        local prefix = buf.bufnr == current_buf and "➤ " or "  "

                        local entry = prefix .. name

                        table.insert(items, {
                            text = entry,
                            bufnr = buf.bufnr,
                        })
                    end

                    vim.ui.select(items, {
                        prompt = "切换 Buffer:",
                        format_item = function(item)
                            return item.text
                        end,
                    }, function(choice)
                        if choice then
                            vim.api.nvim_set_current_buf(choice.bufnr)
                        end
                    end)
                end

                vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
                vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous buffer' })
                vim.keymap.set('n', '<leader>bs', select_buffer, { desc = 'Select buffer (内置 buffer 选择器)' })
                vim.keymap.set('n', '<leader>bt', toggle_buffer_bar, { desc = 'Toggle buffer bar (手动切换顶部 buffer 栏显示/隐藏)' })
                -- 切换到上一次访问的buffer，vim原生自带<C-6>或<C-^>，这里先用原生的，不做映射
                -- 如果要配置的话可以用<leader>bl，l代表last
            end,
        },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPost", "BufNewFile" },  -- 文件打开时加载（推荐）
        main = "ibl",                             -- 必须指定主模块（新版 ibl）
        opts = {
            scope = {
                enabled = false,                      -- 关闭 scope（当前作用域）高亮
            },
            -- 可选：其他常用配置（默认已很好，按需加）
            -- indent = { char = "│" },           -- 缩进线字符
            -- exclude = { filetypes = { "help", "dashboard", "NvimTree" } },
        },
    }
}
