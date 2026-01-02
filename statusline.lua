-- 这个文件用来配置状态栏和顶部的tabline
-- 核心功能：
-- 1、状态栏配置比较少，基本上保持默认的，只有theme和path
-- 2、顶部栏的配置会稍微复杂点，预期效果是：
--   2.1 只有一个buffer时，默认隐藏tabline，包括从多个删除成一个的时候
--   2.2 有多个buffer时，默认自动显示tabline
--   2.3 可以手动切换tabline的显示/隐藏
--   2.4 切换buffer：通过快捷键<leader>bs来选择切换到其他buffer，序号跟顶部栏保持一致
--
-- 配置状态栏和顶部的tabline
require('lualine').setup {
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

                mode = 2,

                max_length = vim.o.columns * 4 / 5, -- 最多占屏幕宽度的 4/5，避免挤满

                filetype_names = {
                    NvimTree = 'Tree',
                },

                use_mode_colors = false,

                buffers_color = {
                    active = "lualine_a_normal",     -- 当前 buffer 用强高亮（类似 mode 区）
                    inactive = "lualine_c_inactive", -- 非当前用淡色
                },

                symbols = {
                    modified = " ●",   -- 已修改用圆点标志（比默认 [+] 更好看）
                    alternate_file = "#",
                    directory = "",
                },

                padding = { left = 2, right = 1 },
            }
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
}
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
