-- ==================== Provider 设置（保持 :checkhealth 干净） ====================
vim.g.python3_host_prog = '/usr/bin/python3'         -- 指定 python3 路径，避免探测出错

vim.g.loaded_perl_provider = 0                       -- 禁用 perl provider
vim.g.loaded_ruby_provider = 0                       -- 禁用 ruby provider
-- 如果以后也不用 node，可加： vim.g.loaded_node_provider = 0

-- ==================== 禁用 netrw（nvim-tree 必须） ====================
-- 强烈建议放在 init.lua **最前面**，甚至在 lazy.nvim bootstrap 之前
vim.g.loaded_netrw      = 1
vim.g.loaded_netrwPlugin = 1

-- ==================== 基础编辑器选项 ====================
local opt = vim.opt                -- 为了写起来更简洁

opt.number         = true          -- 显示行号（默认关闭，这里打开）
opt.cursorline     = true          -- 高亮当前行

-- 缩进相关（你注释已经写得很清楚了，这里直接对应）
opt.expandtab      = true          -- 把 tab 转成空格
opt.shiftwidth     = 4             -- >>、<<、=、自动缩进时使用的宽度
opt.tabstop        = 4             -- 一个 <Tab> 显示的宽度（也是空格数量，因为 expandtab=on）
opt.softtabstop    = 4             -- 可选：让 backspace 删除时感觉像按了 4 个空格（推荐加）

-- 行长度与折行
opt.textwidth      = 100           -- 建议最大行宽（配合 formatoptions 等可自动折行）
opt.wrap           = false         -- 默认不自动折行

-- 滚动体验
opt.scrolloff      = 3             -- 光标上下至少保留 3 行（你原来写 7，可自行调整）

-- 搜索
opt.ignorecase     = true          -- 搜索忽略大小写
opt.smartcase      = true          -- 搜索词有大写时自动变敏感

-- 备份（默认就开，这里显式写出来更清晰）
opt.writebackup    = true          -- 写入时先备份，成功后删除（默认行为）

-- ==================== Leader 键与常用快捷键 ====================
vim.g.mapleader      = ','         -- Leader 改成逗号（原为 \）
vim.g.maplocalleader = ','         -- 可选：localleader 也设成一样

-- ,<CR> 清除搜索高亮（silent 不显示 :noh）
vim.keymap.set('n', '<Leader><CR>', ':nohlsearch<CR>', { silent = true, desc = "Clear search highlight" })

-- ,te 在当前文件目录打开新 tab（类似 :tabedit .）
vim.keymap.set('n', '<Leader>te', ':tabedit <C-r>=expand("%:p:h")<CR>/<CR>', { silent = true })

-- ,cd 切换工作目录到当前文件目录并显示
vim.keymap.set('n', '<Leader>cd', ':cd %:p:h<CR>:pwd<CR>')

-- tab 切换
vim.keymap.set('n', '<Leader>tn', ':tabnext<CR>')
vim.keymap.set('n', '<Leader>tp', ':tabprevious<CR>')

-- nvim-tree 切换（假设你已安装 nvim-tree.lua）
vim.keymap.set('n', '<Leader>nt', ':NvimTreeToggle<CR>', { desc = "Toggle NvimTree" })

-- 按 0 跳到行首非空白字符（比默认更实用）
vim.keymap.set('n', '0', '^')

-- ==================== 自动跳转到上次光标位置 ====================
-- BufReadPost 事件（非常经典的配置）
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
        local line = vim.fn.line
        if line([['"]]) > 0 and line([['"]]) <= line("$") then
            vim.cmd([[normal! g`"]])
        end
    end,
    desc = "Jump to last known cursor position",
})

-- ==================== Lazy.nvim 插件管理器 =====================
-- 启动lazy.nvim
local lazypath = vim.fn.stdpath('data') .. 'lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then -- 检查这个目录是否存在，不存在的话就克隆仓库到该目录
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)
-- 配置lazy.nvim
require('lazy').setup({
    spec = {
        { import = 'plugins' } -- 自动加载 lua/plugins/*.lua
    },
    install = { colorscheme = { 'tokeynight'} }, -- 安装插件时的界面主题
    checker = {
        enable = false,    -- 没必要开启自动更新，稳定性更重要
    },
    change_detection = {
        enable = false,    -- 关闭自动检测，没必要，目前来看还会导致其他vim进程卡住几秒钟，ui渲染也会错乱
        notify = false,    -- 关闭 "Config Change Detected" 通知
    },
})
