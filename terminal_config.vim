"" 定义key mappings
" 在terminal模式中尽量不能用到常用的按键，比如<leader>，
" 否则当需要在terminal中输入逗号，会卡大概一秒，因为在等待输入

" 触发floating terminal的显示和隐藏
nnoremap <silent> <leader>ft :FloatermToggle<CR>
tnoremap <silent>    <C-\>ft <C-\><C-n>:FloatermToggle<CR>
" 触发新建一个terminal，如果要自动跳转到当前buffer所在目录，
" 可以写成 :FloatermNew! cd %:p:h<CR> 但是体验上有问题，而--cwd=<buffer>又不生效
" 所以暂时不加自动切换目录的功能了
nnoremap <silent> <leader>fn :FloatermNew<CR>
tnoremap <silent>    <C-\>fn <C-\><C-n>:FloatermNew<CR>
" 在terminal模式中，进行terminal的切换
tnoremap <silent> <C-\>f> <C-\><C-n>:FloatermNext<CR>
tnoremap <silent> <C-\>f< <C-\><C-n>:FloatermPrev<CR>
" 杀掉当前terminal
tnoremap <silent> <C-\>fk <C-\><C-n>:FloatermKill<CR>
" 打开fzf
" 效果1：查找时过滤一些目录，比如node_modules
" 效果2：打开文件时，不新建window
nnoremap <silent> <leader>ff :FloatermNew fzf<CR>
