return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	opts = {},
	init = function()

		vim.ui.select = function(...)
			require("lazy").load({ plugins = { "fzf-lua" } })
			return vim.ui.select(...)
		end
	end,
	config = function(_, opts)
		local fzf = require("fzf-lua")
		fzf.setup(opts)
		fzf.register_ui_select()
	end,
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Search Files" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Search Buffers" },
	},
}
