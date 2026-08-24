return {
	"zk-org/zk-nvim",
	dependencies = { "ibhagwan/fzf-lua" },
	ft = "markdown",
	cmd = {
		"ZkNew",
		"ZkNotes",
		"ZkTags",
		"ZkMatch",
		"ZkBacklinks",
		"ZkLinks",
		"ZkBuffers",
		"ZkCd",
		"ZkIndex",
		"ZkInsertLink",
		"ZkNewFromTitleSelection",
		"ZkNewFromContentSelection",
		"ZkInsertLinkAtSelection",
	},
	opts = function()
		return {
			picker = "fzf_lua",
			lsp = {
				config = {
					cmd = { "zk", "lsp" },
					name = "zk",
					filetypes = { "markdown" },
					root_dir = vim.env.ZK_NOTEBOOK_DIR or vim.fs.root(0, { ".zk" }),
				},
				auto_attach = { enabled = true },
			},
		}
	end,
	config = function(_, opts)
		require("zk").setup(opts)
	end,
	keys = {
		{ "<leader>nn", "<cmd>ZkNew { title = vim.fn.input('Title: ') }<cr>", desc = "New Note" },
		{ "<leader>no", "<cmd>ZkNotes { sort = { 'modified' } }<cr>", desc = "Open Note" },
		{ "<leader>nt", "<cmd>ZkTags<cr>", desc = "Note Tags" },
		{ "<leader>nf", "<cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<cr>", desc = "Search Notes" },
		{ "<leader>nb", "<cmd>ZkBacklinks<cr>", desc = "Note Backlinks" },
		{ "<leader>nl", "<cmd>ZkLinks<cr>", desc = "Note Links" },
		{ "<leader>ni", ":'<,'>ZkInsertLinkAtSelection<cr>", mode = "v", desc = "Insert Note Link" },
		{ "<leader>nN", ":'<,'>ZkNewFromTitleSelection<cr>", mode = "v", desc = "New Note From Selection" },
	},
}
