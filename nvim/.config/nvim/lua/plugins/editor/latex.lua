return {
	"lervag/vimtex",
	lazy = false,
	init = function()
		vim.g.vimtex_view_method = "skim"
		vim.g.vimtex_view_skim_sync = 1
		vim.g.vimtex_view_skim_activate = 0
		vim.g.vimtex_view_skim_reading_bar = 1

		vim.g.vimtex_compiler_method = "latexmk"

		vim.g.vimtex_quickfix_open_on_warning = 0
		vim.g.vimtex_quickfix_ignore_filters = {
			"Underfull \\\\hbox",
			"Overfull \\\\hbox",
		}
	end,
}
