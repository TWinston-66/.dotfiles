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

-- Spelling
opt.spell = true
opt.spelllang = "en_us"
-- Split camelCase so identifiers are checked word by word
opt.spelloptions = "camel"
-- Words added with zg stay in the dotfiles repo
opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

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
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "tex", "plaintex", "bib" },
	callback = function()
		vim.opt_local.conceallevel = 2
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
	end,
})

-- Spelling off where it is noise. gitcommit is deliberately absent.
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.opt_local.spell = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"help",
		"man",
		"qf",
		"checkhealth",
		"lazy",
		"mason",
		"aerial",
		"fzf",
		"snacks_dashboard",
		"snacks_picker_list",
		"snacks_terminal",
	},
	callback = function()
		vim.opt_local.spell = false
	end,
})
