-- 使用默认配置
require('nvim-autopairs').setup {}

-- autopairs插件订阅cmp的confirm_done事件
-- cmp的事件订阅详见:h cmp.event:on
-- 当补全的是一个function或method时，自动补全一个字符，默认是补全`(`
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
require('cmp').event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done({
        -- 配置哪些文件类型需要`(`的补全，因为有些语言是不需要的，比如shell
        filetypes = {
            -- 注意：lua的key是直接写，不需要双引号，如果要加的话是写成`["xxx"]`
            -- 这个filetype可以看你打开一个文件时，执行:set ft回车时会显示什么
            -- 除了设置`(`，也可以设置其他的字符，具体可以看插件的github介绍，需要用时再说
            -- 如果要对所有filetype设置一个规则，key要写成`["*"]`
            -- 如果要禁止，设置成false
            sh = false,
        }
    })
)
