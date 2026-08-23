return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	init = function()
		vim.g.lualine_laststatus = vim.o.laststatus
		if vim.fn.argc(-1) > 0 then
			vim.o.statusline = " "
		else
			vim.o.laststatus = 0
		end
	end,
	opts = function()
		local icons = {
			diagnostics = {
				Error = " ",
				Warn = " ",
				Info = " ",
				Hint = " ",
			},
			git = {
				added = " ",
				modified = " ",
				removed = " ",
			},
		}

		vim.o.laststatus = vim.g.lualine_laststatus

		return {
			options = {
				theme = "catppuccin-nvim",
				globalstatus = vim.o.laststatus == 3,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },

				lualine_c = {
					{
						"diagnostics",
						symbols = {
							error = icons.diagnostics.Error,
							warn = icons.diagnostics.Warn,
							info = icons.diagnostics.Info,
							hint = icons.diagnostics.Hint,
						},
					},
					{ "filetype", padding = { left = 1, right = 1 } },
					{
						"filename",
						path = 1,
						symbols = { modified = " ", readonly = " ", unnamed = "[No Name]" },
					},
				},
				lualine_x = {
					{
						require("lazy.status").updates,
						cond = require("lazy.status").has_updates,
					},
					{
						"diff",
						symbols = {
							added = icons.git.added,
							modified = icons.git.modified,
							removed = icons.git.removed,
						},
						source = function()
							local summary = vim.b.minidiff_summary
							if summary then
								return {
									added = summary.add,
									modified = summary.change,
									removed = summary.delete,
								}
							end
						end,
					},
				},
				lualine_y = {
					{ "progress", separator = " ", padding = { left = 1, right = 0 } },
					{ "location", padding = { left = 0, right = 1 } },
				},
				lualine_z = {},
			},

			extensions = { "lazy", "fzf" },
		}
	end,
}
