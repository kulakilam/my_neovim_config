-- Mappings，按键映射，否则只能通过命令行调用api来产生一些效果
-- 这些映射将适用于所有language server，因为LSP协议是统一的

-- 代码诊断的按键映射
-- 可以通过`:help vim.diagnostic.*`查看所有的诊断api
-- @todo 诊断的配置为什么不放到on_attach中？？？
--
-- noremap表示映射不会一直递归找下去
-- silent表示命令行执行时不会显示在命令行上
local opts = { noremap=true, silent=true }
-- 'n'表示normal模式
-- open_float 把诊断信息显示在一个float window上，默认是通过sign方式显示在句末
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
-- goto_prev和goto_next是跳到上一个或者下一个有报错的地方
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
-- setloclist是把当前buffer的所有诊断报错变成一个列表，打开一个location窗口，显示在里面，也是一种quickfix
-- 方便快速查看，并跳转到自己感兴趣的那个
-- 关于location列表可以查看:h location-list
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)


-- 配置signature-help，先使用默认配置，先放在这里，如果后面要更定制化一些，再单独开个文件吧
-- 注意：需要配置在lspconfig之前
require('lsp_signature').setup({
    debug = true,
    log_path = '/Users/zhongwenbing/work_in_bytedance/test/c_test/sign_debug.log',
    verbose = true,
    cursorhold_update = false,
})

-- 定义一个on_attach函数，会在language server跟当前buffer attach后调用
-- 函数中做了一些按键映射
-- @todo：这里有个问题，如果是通过set ft=xx，貌似不会调用这里
local on_attach = function(client, bufnr)
    -- 设置signcolumn，注意这里是用nvim_win_set_option而不能用nvim_buf_set_option
    -- 可以查看`:h nvim_win_set_option()`
    -- 只有进入这个函数，也就是一个buffer attach到一个language server时，才会开启
    -- 所以如果没有attach到language server的window就不会开启，这样比较合理
    -- 'yes:1'表示一直开启，1个宽度，如果是auto不是yes，一会有一会没有，体验不好
    vim.api.nvim_win_set_option(0, 'signcolumn', 'yes:1')
    -- 使用<c-x><c-o>手动触发补全，但是有了nvim-cmp后，这个就不需要了
    -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- 执行`:help vim.lsp.*`查看下面这些函数的文档
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts) -- 跳转到声明
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts) -- 跳转到定义
    -- 光标所在变量的文档介绍
    -- 操作：按两次可以让光标进入文档，按q会关闭文档、光标回到之前的位置
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts) -- 跳转到实现
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts) -- 当你在输入函数参数时，会有一些提示
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts) -- 跳转到类型的定义，很有用
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts) -- 重命名
    -- 很有用，诊断到代码有问题时，可以把光标放在报错那一行，然后执行<space>ca，会提示怎么修复
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts) -- 跳转到引用
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
    -- LSP标准里没有提供前进、后退，可以使用vim自带的
    -- 后退：CTRL-O  前进：CTRL-I 或 <tab>  可以查看:h CTRL-O或:h CTRL-I
end

local lsp_flags = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
}

-- =================== 配置floating window的样式 ===================
-- 要解决的问题：默认配置是没有border，且背景色跟编辑器比较接近，区分度很低，体验不好
-- 解决方案：无非是1、加个border的样式；2、换一个背景色；3、两者都做

-- border的配置
-- 根据lspconfig官方文档的说明（https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#borders）
-- 因为floating window是neovim内建的功能，border也是neovim本身支持的
-- 如果要修改border的样式，只需要传递两个参数，一个是border的字符，一个是highlight groups
-- 我这里配置的rounded_border是从lsp_signature.nvim源码中copy过来的，一方面是保证样式统一，
-- 一方面是这个圆角的border看起来还可以。
local rounded_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
local handlers =  {
  ["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = rounded_border}),
  -- singatureHelp通过lsp_signature.nvim插件配置了，这里不再重复配置
  -- ["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = rounded_border}),
  -- ["textDocument/definition"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = rounded_border}),
}

-- ==================== 每个language server的配置 ====================
-- lua
require('lspconfig').sumneko_lua.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    handlers = handlers,
    settings = {
        Lua = {
            runtime = {
                -- 告诉language server你用的是哪个版本的Lua，对于Neovim来说一般都是LuaJIT
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false, -- 不加这个的话，每次打开lua文件都会弹出提示
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

-- gopls
-- 目前常见的问题：
-- 1、打开公司的仓库，基本上lsp都没法初始化成功，报错go/packages.Load: err: exit status 1
--    可能是依赖库没有权限的问题
-- 2、import的行大量报错，报workspace configuration error: err: exit status 1: stderr: go: downloading
--    是下载依赖时因为配置不正确而导致无法下载，跟go.mod、go.sum有关系
--    解决1：打开go.mod，第一行会报错，这时候执行<space>ca调出code action的修复建议，有两个选项
--          第一是执行go mod tidy，第二个是更新go.sum，我选择第一个好像不起作用，第二个就能修复
--    解决2：可能跟你的go版本有关系，所以把你的go版本升级到跟go.mod里面一样的
require('lspconfig').gopls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    handlers = handlers,
}

-- ccls
-- 如果遇到代码中出现很多报错，可能是需要把一些路径加入到include中
-- 需要在工程root目录下（子目录也可以）防止一个.ccls文件，里面写上
-- ```
-- clang
-- -I/Users/zhongwenbing/work_in_bytedance/opensource/neovim/src/
-- ```
-- 如果遇到标准库没找到，可以在.ccls中加上以下配置，这是mac上的标准库位置
-- ```
-- -I/Library/Developer/CommandLineTools/SDKs/MacOSX11.0.sdk/usr/include/
-- ```
require('lspconfig').ccls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    handlers = handlers,
}

-- bashls
-- 需要安装shellcheck(https://github.com/koalaman/shellcheck)，用brew install shellcheck
-- 如果没有安装，lsp.log中会报错
require('lspconfig').bashls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    handlers = handlers,
}

-- tsserver
-- 如果是单文件的，按gr会报错 Error: No Project.
require('lspconfig').tsserver.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    handlers = handlers,
}

-- pylsp
require('lspconfig').pylsp.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    handlers = handlers,
}

-- vimls
-- 按K查看文档的效果还不如不装language server
-- @todo：代码跳转需要用到，需要把lsp的能力和看文档结合起来
-- require('lspconfig').vimls.setup {
--     on_attach = on_attach,
--     flags = lsp_flags,
--     handlers = handlers,
-- }

-- intelephense
-- PHP的language server，感觉php的文档(按K)比其他语言的看着舒服
require('lspconfig').intelephense.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    handlers = handlers,
}

-- jsonls
require('lspconfig').jsonls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    handlers = handlers,
}
