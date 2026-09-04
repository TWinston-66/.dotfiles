local opt = vim.opt

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Display
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.wrap = false
opt.termguicolors = true

-- Mouse
opt.mouse = "a"

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Persistence
opt.undofile = true
opt.clipboard = "unnamedplus"

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Per-language indentation
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.conceallevel = 2
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "tex", "plaintex", "bib" },
	callback = function()
		vim.opt_local.conceallevel = 2
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})
