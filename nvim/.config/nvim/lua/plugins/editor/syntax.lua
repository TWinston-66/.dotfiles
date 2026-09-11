return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local parser_by_filetype = {
			help = "vimdoc",
			sh = "bash",
			javascriptreact = "javascript",
			typescriptreact = "tsx",
			markdown = { "markdown", "markdown_inline", "yaml", "html" },
		}
		local filetypes = {
			"lua",
			"vim",
			"help",
			"go",
			"c",
			"cpp",
			"rust",
			"sh",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"python",
			"json",
			"yaml",
			"toml",
			"gitcommit",
			"markdown",
		}

		local parsers = {}
		for _, ft in ipairs(filetypes) do
			local mapped = parser_by_filetype[ft] or ft
			for _, parser in ipairs(type(mapped) == "table" and mapped or { mapped }) do
				parsers[parser] = true
			end
		end
		local langs = vim.tbl_keys(parsers)
		require("nvim-treesitter").install(langs)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetypes,
			callback = function()
				vim.treesitter.start()
			end,
		})
	end,
}
