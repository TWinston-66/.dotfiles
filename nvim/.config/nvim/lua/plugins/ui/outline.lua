return {
	"stevearc/aerial.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
	cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialNext", "AerialPrev", "AerialNavToggle", "AerialInfo" },
	opts = {
		layout = {
			default_direction = "prefer_right",
			placement = "edge",
			width = 30,
			max_width = { 40, 0.3 },
		},
		attach_mode = "global",
		backends = { "lsp", "treesitter", "markdown", "man" },
		show_guides = true,
		highlight_on_hover = true,
	},
	keys = {
		{ "<leader>o", "<cmd>AerialToggle!<cr>", desc = "Toggle Outline" },
		{
			"<leader>fs",
			function()
				require("aerial").fzf_lua_picker()
			end,
			desc = "Search Symbols",
		},
		{ "[a", "<cmd>AerialPrev<cr>", desc = "Previous Symbol" },
		{ "]a", "<cmd>AerialNext<cr>", desc = "Next Symbol" },
	},
}
