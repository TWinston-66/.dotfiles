return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		dashboard = {
			enabled = true,
			preset = {
				header = [[
 ███╗   ██╗██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██║   ██║██║████╗ ████║
 ██╔██╗ ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":FzfLua files" },
					{ icon = " ", key = "g", desc = "Find Text", action = ":FzfLua live_grep" },
					{ icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
					{ icon = " ", key = "e", desc = "File Explorer", action = ":lua Snacks.explorer()" },
					{ icon = "󰎞 ", key = "v", desc = "Vault", action = ":Obsidian quick_switch" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = " ", key = "c", desc = "Config", action = ":FzfLua files cwd=" .. vim.fn.stdpath("config") },
					{ icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				{ section = "startup" },
			},
		},

		explorer = { enabled = true },
		image = { enabled = true },
		picker = { enabled = true, ui_select = false },
		scroll = { enabled = true },
		words = { enabled = true },
	},

	keys = {
		{ "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
		{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
		{ "<leader>gb", function() Snacks.gitbrowse() end, mode = { "n", "v" }, desc = "Git Browse" },
		{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
		{ "<leader>bD", function() Snacks.bufdelete({ force = true }) end, desc = "Delete Buffer (Force)" },
		{ "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
		{ "]]", function() Snacks.words.jump(vim.v.count1) end, mode = { "n", "t" }, desc = "Next Reference" },
		{ "[[", function() Snacks.words.jump(-vim.v.count1) end, mode = { "n", "t" }, desc = "Prev Reference" },
	},

	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.inlay_hints():map("<leader>uh")
			end,
		})
	end,
}
