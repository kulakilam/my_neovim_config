" 保持checkhealth良好运行
let g:python3_host_prog = '/usr/local/bin/python3'
let g:loaded_perl_provider = 0 " 禁用perl
let g:loaded_ruby_provider = 0 " 禁用ruby

" 关闭netrw，nvim-tree.lua插件需要用到，详见:h netrw-noload
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1

set number " 默认关闭，这里打开行号
set cursorline " 高亮当前行

"" 这三者的关系是什么？
"" tabstop是指一个<tab>的宽度
"" expandtab是一个开关，如果打开，则<tab>会被自动替换成{tabstop}个空格，
""          如果还想输入<tab>符号，键入<C-v><tab>
"" shiftwidth表示按下< > = ==时，缩进的宽度，反正宽度一定是这么多，
""   至于是用<tab>还是用空格，用几个<tab>或几个空格，会结合expandtab和tabstop
""   会优先用<tab>，不够的再用空格填充
""   例子1：shiftwidth=8 tabstop=8 expandtab关闭
""   - 效果：一个缩进是8字符宽，一个<tab>也是8字符宽，所以会显示成1个<tab>
""   例子2：shiftwidth=8 tabstop=4 expandtab关闭
""   - 效果：一个缩进是8字符宽，一个<tab>是4字符宽，所以会显示成2个<tab>
""   例子3：shiftwidth=8 tabstop=3 expandtab关闭
""   - 效果：一个缩进是8字符宽，一个<tab>是3字符宽，最终显示成2<tab>+2空格
""   例子4：shiftwidth=4 tabstop=5 expandtab关闭
""   - 效果：一个缩进只能4个空格，两个缩进用1个<tab>+3个空格
"" tabstop，当expandtab开关开启时，表示空格数量；当expandtab开关关闭时，
""          表示<tab>的宽度
"" 
"" 另外讲一下按下回车时的自动缩进为什么不对齐的问题
"" 一次回车会缩进多少个宽度？
"" 1. 相同层级的不需要缩进，但是字符会被替换成<tab>+空格
"" 2. 需要向右缩进一级，这时候宽度 = {完全继承上一行缩进的宽度} + 1个shiftwidth
""    然后再转换成<tab>和空格的组合，逻辑参考上面的几个例子
"" 例子：{4个空格}<some code> {
""    执行:set shiftwidth=4
""    执行:set noexpandtab
""    执行:set tabstop=3
""    在{后面回车，新代码行会向右缩进一级，此时宽度为
""    {继承上一行缩进的宽度} + shiftwidth = 4 + 4 = 8个宽度
""    因为noexpandtab，所以会用<tab>符，一个<tab>符宽度是{tabstop}=3
""    所以最终会显示成<tab><tab><2个空格><some code>
"" 
"" 关于缩进，< > = ==，这几个操作是会重新计算并替换缩进字符的，并不会因为当前
"" 的缩进宽度跟最终效果一样，而忽略操作。所以当一个代码文件存在很多用<tab>做
"" 缩进的，你想替换成空格，在配置好expandtab、sw、ts之后，直接选中全文按一下`=`
"" 更快，而不用像我以前用命令行`:%s/\t/ /g`
set expandtab " 默认关闭，这里打开
set shiftwidth=4 " 默认是8，调整为4
set tabstop=4 " 默认是8，指的是一个<tab>的宽度

" @todo：这里未来可以考虑高级用法，结合wrapmargin、formatexpr等配置
set textwidth=100 " 默认是0，不限制一行的长度，这里暂定100

" 滚动时光标保持跟上下窗口边界有7行的距离
set scrolloff=7

set ignorecase " 搜索时，开启大小写忽略，默认是关闭的
set smartcase  " 当搜索词中包含大写，会自动忽覆盖掉ignorecase，变成大小写敏感

set writebackup " 默认也是开启，写文件的时候会自动备份，写成功后自动删除

" 默认<Leader>是反斜杠\，改成逗号','
let g:mapleader=","
" 按下,<cr>取消高亮，很实用。<silent>的作用是不会把:noh显示在命令行中
map <silent> <Leader><cr> :noh<cr>
" 按下,te会打开一个新的tab，显示当前目录，可以快速选择要编辑的文件
map <silent> <Leader>te :tabedit <c-r>=expand("%:p:h")<cr>/<cr>
" 按下,cd会跳转到当前buffer所在的目录，并打印出当前目录
" 其实也可以像上面那样使用表达式寄存器的方式
map <Leader>cd :cd %:p:h<cr>:pwd<cr>
" 切换tab
map <Leader>tn :tabn<cr>
map <Leader>tp :tabp<cr>
" 打开nvim-tree
map <Leader>nt :NvimTreeToggle<cr>
" 打开SymbolsOutline
map <leader>so :SymbolsOutline<cr>

" 按0时也跳到第一个非空字符，而不是跳到行首
map 0 ^

" 打开文件时，跳转到上一次光标的位置。
" '"或者`"表示跳转到"所做的mark，双引号是个特殊的marker
" line("'\"") 使用了mark的能力，表示获取双引号marker所在行的行号
" line("$") 表示获取最后一行的行号
" 具体可以看:h line()
" g`\" 表示jump to the {mark}，跳转到双引号mark的位置，具体可以看:h g`
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

" ================= vim-plug 插件管理器 =================
" vim-plug自身的代码文件放在stdpath('data')/site/autoload/下
" 默认在stdpath('data')/plugged/目录下存放插件，也可以创建一个目录，然后把路径传递给begin()
" 说明：neovim的stdpath('data')是~/.local/share/nvim，可以执行:echo stdpath('data')查看
call plug#begin()

"" treesitter
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' } " 自动更新所有parser

"" nvim-lspconfig
Plug 'neovim/nvim-lspconfig' " 官方插件，纯lua编写

"" Neoformat格式化工具
" 使用方法1：执行:Neoformat <tab>会自动补全，可以选择你想要的格式化工具
" 使用方法2：直接执行:Neoformat，会自动选择一个格式化工具
" 原理是调用本地的格式化工具程序，所以当格式化失败时，可以检查下本地是否安装，然后可以通过brew安装
Plug 'sbdchd/neoformat' " don't配置其他东西，只在需要的时候手动执行

"" 状态栏
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons' " 在状态栏中支持一些icons，nvim-tree插件也会用到

"" 主题色
" 可以在这里找：https://github.com/topics/neovim-colorscheme?o=desc&s=stars
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

"" 自动补全
" 暂时只引入LSP和文件路径的自动补全，像cmdline、buffer的暂时不需要
" @todo：文件路径的补全来源需要研究下性能如何
Plug 'hrsh7th/nvim-cmp' " 自动补全的核心引擎
Plug 'hrsh7th/cmp-nvim-lsp' " 补全的source 1：LSP
Plug 'hrsh7th/cmp-path' " 补全的source 2：文件路径
" 如果不安装snip，在自动补全后执行confirm时会报错，而且nvim-cmp的文档中也建议安装snip，无语...
" https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#no-snippet-plugin 这里建议安装snip
" 以及https://github.com/hrsh7th/nvim-cmp的README.md也是写着
" “REQUIRED - you must specify a snippet engine”
" 另外，luasnip的star数更多，而vsnip的作者跟nvim-cmp是同一个，比较纠结...
" 选择vsnip，是考虑到作者同一个，两个插件配合会比较好？
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
" signature-help功能。（弃用最初选择的cmp-nvim-lsp-signature-help）
Plug 'ray-x/lsp_signature.nvim'
" 自动配对
Plug 'windwp/nvim-autopairs'
" 注释
Plug 'numToStr/Comment.nvim'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
" 自动高亮光标所在的变量
Plug 'RRethy/vim-illuminate'

"" 文件管理器
Plug 'nvim-tree/nvim-tree.lua' " nvim-web-devicons上面已安装，这里不再重复安装了

"" taglist
Plug 'simrat39/symbols-outline.nvim'

"" floating terminal 悬浮的终端
Plug 'voldikss/vim-floaterm'

"" Git相关
" git signs
Plug 'lewis6991/gitsigns.nvim'

" 这里调用end()会开启filetype plugin syntax on和syntax enable
" 如果有影响可以在下方关闭，添加filetype indent off和syntax off
call plug#end()

" ===================== lua写的配置 =====================
"
" 书写规范：
" 1. 字符串：优先用单引号，因为lua中单引号和双引号的字符串没有任何区别，而单引号看起来更简洁
" 2. 函数传参：lua似乎支持不加括号，但建议require('xxx')，而不是require'xxx'
"
" 方式一，直接从外部文件加载
" @todo：改成stdpath('config')会更准确，但是基于我对Vimscript有限的知识，无法理解为什么会报错
" @todo：当跟其他lua配置存在前后加载顺序时，怎么保持优雅？
luafile ~/.config/nvim/treesitter_config.lua
luafile ~/.config/nvim/lsp_config.lua
luafile ~/.config/nvim/auto_completion.lua
luafile ~/.config/nvim/fileExplorer_config.lua
luafile ~/.config/nvim/autoPairs_config.lua
luafile ~/.config/nvim/git_config.lua
source ~/.config/nvim/terminal_config.vim " vim-floaterm这个插件是用vimL写的

" 方式二，直接写在init.vim中
lua << EOF

-- 配置主题色
-- tokyonight能够很好地支持lualine、treesitter、lsp
vim.cmd[[colorscheme tokyonight-night]]
-- tokyonight提供的git相关高亮颜色有两个问题1、太暗2、区分度低
vim.cmd[[highlight GitSignsAdd guifg=#26a641]]
vim.cmd[[highlight GitSignsChange guifg=#fddf68]]
vim.cmd[[highlight GitSignsDelete guifg=#b62324]]

-- 配置状态栏，用默认配置即可
require('lualine').setup {
    options = {
        -- theme默认是auto，自动拿了colorscheme的值，
        -- 除非是colorscheme设置成别的，而只有状态栏想用特定主题色
        -- 这里好像只能设置成tokyonight，不能设置成tokyonight-night，否则会报错
        theme = 'tokyonight'
    }
}

-- 配置Comment.nvim
require('Comment').setup {
    -- Comment.nvim目前不支持jsx/tsx，需要依赖nvim-ts-context-commentstring插件
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
}

-- 配置vim-illuminate
require('illuminate').configure({
    -- providers: provider used to get references in the buffer, ordered by priority
    providers = {
        'lsp',
        'treesitter',
        'regex',
    },
    -- delay: delay in milliseconds
    delay = 100,
    -- filetype_overrides: filetype specific overrides.
    -- The keys are strings to represent the filetype while the values are tables that
    -- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
    filetype_overrides = {},
    -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
    filetypes_denylist = {
        'dirbuf',
        'dirvish',
        'fugitive',
        'NvimTree'
    },
    -- filetypes_allowlist: filetypes to illuminate, this is overridden by filetypes_denylist
    -- You must set filetypes_denylist = {} to override the defaults to allow filetypes_allowlist to take effect
    filetypes_allowlist = {},
    -- modes_denylist: modes to not illuminate, this overrides modes_allowlist
    -- See `:help mode()` for possible values
    modes_denylist = {},
    -- modes_allowlist: modes to illuminate, this is overridden by modes_denylist
    -- See `:help mode()` for possible values
    modes_allowlist = {},
    -- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
    -- Only applies to the 'regex' provider
    -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
    providers_regex_syntax_denylist = {},
    -- providers_regex_syntax_allowlist: syntax to illuminate, this is overridden by providers_regex_syntax_denylist
    -- Only applies to the 'regex' provider
    -- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
    providers_regex_syntax_allowlist = {},
    -- under_cursor: whether or not to illuminate under the cursor
    under_cursor = true,
    -- large_file_cutoff: number of lines at which to use large_file_config
    -- The `under_cursor` option is disabled when this cutoff is hit
    large_file_cutoff = nil,
    -- large_file_config: config to use for large files (based on large_file_cutoff).
    -- Supports the same keys passed to .configure
    -- If nil, vim-illuminate will be disabled for large files.
    large_file_overrides = nil,
    -- min_count_to_highlight: minimum number of matches required to perform highlighting
    min_count_to_highlight = 1,
    -- should_enable: a callback that overrides all other settings to
    -- enable/disable illumination. This will be called a lot so don't do
    -- anything expensive in it.
    should_enable = function(bufnr) return true end,
    -- case_insensitive_regex: sets regex case sensitivity
    case_insensitive_regex = false,
})

EOF
