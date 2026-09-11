local vault = vim.fn.expand("~/Documents/vault")

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*",
	dependencies = { "ibhagwan/fzf-lua" },
	cmd = "Obsidian",
	event = {
		"BufReadPre " .. vault .. "/*.md",
		"BufNewFile " .. vault .. "/*.md",
	},

	opts = {
		legacy_commands = false,
		workspaces = { { name = "vault", path = vault } },
		picker = { name = "fzf-lua" },

		ui = { enable = false },
		footer = { enabled = false },
		daily_notes = { folder = "Daily" },
		link = { auto_update = true },
		new_notes_location = "current_dir",
		attachments = { folder = "./" },
		templates = { folder = "Templates" },
	},
	keys = {
		{ "<leader>vn", "<cmd>Obsidian new<cr>", desc = "New Vault Note" },
		{ "<leader>vo", "<cmd>Obsidian quick_switch<cr>", desc = "Open Vault Note" },
		{ "<leader>vt", "<cmd>Obsidian tags<cr>", desc = "Vault Tags" },
		{ "<leader>vf", "<cmd>Obsidian search<cr>", desc = "Search Vault" },
		{ "<leader>vb", "<cmd>Obsidian backlinks<cr>", desc = "Vault Backlinks" },
		{ "<leader>vl", "<cmd>Obsidian links<cr>", desc = "Vault Links" },
		{ "<leader>vd", "<cmd>Obsidian today<cr>", desc = "Daily Note" },
		{ "<leader>vT", "<cmd>Obsidian template<cr>", desc = "Insert Template" },
		{ "<leader>vp", "<cmd>Obsidian paste_img<cr>", desc = "Paste Image" },
		{ "<leader>vi", ":'<,'>Obsidian link<cr>", mode = "v", desc = "Link Selection" },
		{ "<leader>vN", ":'<,'>Obsidian extract_note<cr>", mode = "v", desc = "Extract To Note" },
	},
}
