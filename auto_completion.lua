-- menu: 超过1个选项时，才会弹出popup menu
-- menuone: 只有1个选项时也会弹出popup menu
-- noselect: 当popup menu弹出时，不会选中里面的任何一项，强迫用户手动去选
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- 配置nvim-cmp
-- 加载时机？
-- 1. source为lsp：应该是在language server已经attach后才加载
-- 2. source为path：应该是通过filetype判断，一般文本就不要加载了
local cmp = require('cmp')
-- 目前selectBehavior有两种行为，insert和select，详见lua/cmp/types/cmp.lua
local select_opts = { behavior = cmp.SelectBehavior.Select }
-- 
local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0)) -- 获取cursor在当前window的坐标
    -- 两个表达式，and的关系，判断光标前面是否有字符
    -- 条件1：col不等于0，即光标不在行首
    -- 条件2：获取光标前一个字符，判断是否是空字符（包括空格、<Tab>之类的）
    --   nvim_buf_get_liens是获取当前buffer的行内容，指定行的范围，会返回一个array
    --   sub是string.sub()，获取子串
    --   match是string.match()，匹配pattern，%s表示space characters，详见https://www.lua.org/pil/20.2.html
    return col ~= 0 and
           vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local feedkey = function(key, mode)
    -- 调用feedkeys()，模拟用户输入
    -- nvim.replace_keycodes()替换类似<CR><ESC><Leader>这种特殊的key，转换成它实际的值，
    -- 比如<Leader>替换成逗号（我这里配置的是逗号）
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup({
    -- 这个设置是为了解决上面设置的vim.opt.completeopt对有些lsp（比如gopls）不生效的问题
    -- PreselectMode定义在lua/cmp/types/cmp.lua
    -- 总共两种mode：'item'和'none'，item应该是默认的mode
    -- @todo：具体为什么会出现这个问题，我没搞清楚，我尝试在init.lua文件中把
    -- lsp_config.lua和auto_completion.lua的加载顺序换一下，但是没有解决
    preselect = cmp.PreselectMode.None,
    sources = {
        -- name: 每个source有一个key，需要看下他们的文档，或者
        --       看https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
        -- keyword_length: 触发请求source的最少字符
        --                 如果不填写，应该是默认输入1个字符就会触发
        {
            name = 'nvim_lsp',
            keyword_length = 2,
        },
        {
            -- cmp-path插件比较简单，只有两个option配置项
            name = 'path',
            option = {
                -- 文件夹补全时是否加上斜杠
                -- 不过这里应该是有bug，cmp-path插件的源码中混合使用item.insertText和
                -- item.word，导致这里不管是false还是true，最终结果都是true
                trailing_slash = true,
                label_trailing_slash = true, -- 在补全list中文件夹是否显示斜杠
            },
        },
    },
    window = {
        -- 设置文档弹窗的边界
        documentation = cmp.config.window.bordered()
    },
    formatting = {
        -- menu：原生的vim补全貌似没有这个，在这里也只是用于放置一个icon，用于区分来源
        -- abbr：字符串，但不代表是最终补全的，像ccls传递过来的abbr还包含了变量类型，
        --       如“dlen : size_t”，而最终补全的是dlen
        -- kind：类型，这个是lsp传过来的，比如Variable、Function、Text等
        --       具体lsp定义了哪些kind，详见lua/cmp/types/lsp.lua
        fields = { 'abbr', 'kind', 'menu'},
        format = function(entry, item)
            local menu_icon = {
                nvim_lsp = 'λ', -- 这里的nvim_lsp是一个字符串，不是一个变量，这lua的语法真的是。。。
            }
            -- 相当于把每个item的menu这个field都根据source替换成了某个字符或字符串
            item.menu = menu_icon[entry.source.name]
            return item
        end,
    },
    mapping = {
        -- 功能：按下回车，选中一个选项
        -- select: 
        --     true：当没有选中任意选项时，会默认选中第一个
        --     false：有选就有选，没选就没选
        ['<CR>']   = cmp.mapping.confirm({ select = false }),
        -- 功能：以下四个是上下选择item
        -- Tip：因为nvim-cmp插件支持模糊搜索，所以很多时候直接输入更快
        ['<Up>']   = cmp.mapping.select_prev_item(select_opts),
        ['<Down>'] = cmp.mapping.select_next_item(select_opts),
        ['<C-p>']  = cmp.mapping.select_prev_item(select_opts),
        ['<C-n>']  = cmp.mapping.select_next_item(select_opts),
        ['<C-b>']  = cmp.mapping.scroll_docs(-2), -- 滚动文档，一次2行
        ['<C-f>']  = cmp.mapping.scroll_docs(2),
        -- <Tab>键的映射，参考https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#vim-vsnip
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then -- 如果出现了item list
                cmp.select_next_item() -- 自动选择下一个
                -- 加上这个，按下<Tab>直接插入，体验更接近vscode
                -- feedkeys的mode默认是'm'，我这里显式指定下
                -- 'm'表示会remap keys，所以执行时会remap到上面的cmp.mapping.confirm()
                -- 如果这里是'n'，表示不会remap，则<CR>就是输入一个换行，但是又没有complete()，
                -- 会出现奇怪的行为
                feedkey('<CR>', 'm')
            -- 调用vim-vsnip插件中的autoload/vsnip.vim的vsnip#available方法，
            -- 判断是否有snippet可以展开 或者 是否可以跳转，这里的跳转是指
            -- 在snippet中的不同block之间跳转
            elseif vim.fn['vsnip#available'](1) == 1 then
                -- feedkeys()是模拟用户输入
                -- 而这个key映射是在vim-vsnip插件的plugin/vsnip.vim代码中定义的
                -- ```
                -- inoremap <silent> <Plug>(vsnip-expand-or-jump) <Esc>:<C-u>call <SID>expand_or_jump()<CR>
                -- snoremap <silent> <Plug>(vsnip-expand-or-jump) <Esc>:<C-u>call <SID>expand_or_jump()<CR>
                -- ```
                -- 所以下面这一行相当于输入了一个快捷键，效果是调用了expand_or_jump()函数
                feedkey('<Plug>(vsnip-expand-or-jump)', '')
            elseif has_words_before() then
                -- 会执行一系列动作，比如插入、关闭menu
                cmp.complete()
            else
                fallback() -- 兜底，也就是回到了<Tab>本来的功能
            end
        end, { 'i', 's' }), -- @todo：为什么select模式也要配置？
        -- Shift-<Tab>键的映射，参考https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#vim-vsnip
        -- 功能：
        -- 1、在completion的item list中选择前一个
        -- 2、在snippet中，跳到前一个block
        ['<S-Tab>'] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn['vsnip#jumpable'](-1) == 1 then
                feedkey('<Plug>(vsnip-jump-prev)', '')
            end
        end, { 'i', 's' }), -- @todo：为什么select模式也要配置？
    },
    snippet = {
        -- 官方说的“REQUIRED - you must specify a snippet engine”
        expand = function(args)
            vim.fn['vsnip#anonymous'](args.body) -- For `vsnip` users.
        end,
    },
})
