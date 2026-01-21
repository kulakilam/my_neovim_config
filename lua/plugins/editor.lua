return {
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",  -- 推荐：很晚加载（启动后空闲时），因为不常立即需要
        dependencies = {
            "JoosepAlviste/nvim-ts-context-commentstring",  -- 必须依赖，用于 Treesitter 上下文
        },
        opts = function ()
            -- Comment.nvim目前不支持jsx/tsx，需要依赖nvim-ts-context-commentstring插件
            return {
                pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
            }
        end
    },
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',  -- 进入插入模式时加载（推荐的懒加载时机）
        dependencies = { 'hrsh7th/nvim-cmp' },  -- 依赖 cmp，因为要订阅事件

        opts = {},

        config = function(_, opts)
            -- 1. 先加载 autopairs 的 setup（使用 opts）
            require('nvim-autopairs').setup(opts)

            -- 2. 再处理与 cmp 的集成（事件订阅）
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')

            cmp.event:on(
                'confirm_done',
                cmp_autopairs.on_confirm_done({
                    filetypes = {
                        -- 注意：lua的key是直接写，不需要双引号，如果要加的话是写成`["xxx"]`
                        -- 这个filetype可以看你打开一个文件时，执行:set ft回车时会显示什么
                        -- 除了设置`(`，也可以设置其他的字符，具体可以看插件的github介绍，需要用时再说
                        -- 如果要对所有filetype设置一个规则，key要写成`["*"]`
                        -- 如果要禁止，设置成false
                        sh = false,
                    },
                })
            )
        end,
    },
    {
        "sbdchd/neoformat",
        cmd = { "Neoformat" }, -- 只有在执行格式化的时候才加载
    }
}
