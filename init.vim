set number

set expandtab
set shiftwidth=4
set tabstop=4

call plug#begin()
Plug 'neovim/nvim-lspconfig'

Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

Plug 'ray-x/lsp_signature.nvim'
call plug#end()

lua << EOF

require('lsp_signature').setup({
    debug = true,
    verbose = true,
    cursorhold_update = false,
})
require('lspconfig').ccls.setup{}
require('cmp').setup{}

EOF
