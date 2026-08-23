return {
	"ibhagwan/fzf-lua",

	opts = {},
	keys = {
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Search Files" },
		{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Search Buffers" },
	},
}
