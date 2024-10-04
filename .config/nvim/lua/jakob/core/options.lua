vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.scrolloff = 5

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.expandtab = true
opt.autoindent = true

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you inclue mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

--backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

opt.clipboard:append("unnamedplus") --use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom
