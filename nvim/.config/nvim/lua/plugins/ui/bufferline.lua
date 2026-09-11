return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
	keys = {
		{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move Buffer Prev" },
		{ "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move Buffer Next" },
	},
	opts = {
		options = {
			close_command = function(n)
				Snacks.bufdelete(n)
			end,
			right_mouse_command = function(n)
				Snacks.bufdelete(n)
			end,
			diagnostics = "nvim_lsp",
			always_show_bufferline = false,
			offsets = {
				{
					filetype = "snacks_layout_box",
					text = "Explorer",
					highlight = "Directory",
					separator = true,
				},
				{
					filetype = "aerial",
					text = "Outline",
					highlight = "Directory",
					separator = true,
				},
			},
			diagnostics_indicator = function(_, _, diag)
				local icons = { Error = " ", Warn = " " }
				local ret = (diag.error and icons.Error .. diag.error .. " " or "")
					.. (diag.warning and icons.Warn .. diag.warning or "")
				return vim.trim(ret)
			end,
		},
	},
	config = function(_, opts)
		require("bufferline").setup(opts)

		vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
			callback = function()
				vim.schedule(function()
					pcall(nvim_bufferline)
				end)
			end,
		})
	end,
}
