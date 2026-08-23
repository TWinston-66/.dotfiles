return {
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
			"saghen/blink.cmp",
		},
		opts = {
			ensure_installed = {
				"gopls",
				"clangd",
				"rust_analyzer",
				"ts_ls",
				"bashls",
				"lua_ls",
			},
		},
		config = function(_, opts)
			require("mason").setup()

			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			require("mason-lspconfig").setup(opts)

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local keymap_opts = { buffer = event.buf }
					local keymap = vim.keymap

					keymap.set("n", "gd", vim.lsp.buf.definition, keymap_opts)
					keymap.set("n", "gD", vim.lsp.buf.declaration, keymap_opts)
					keymap.set("n", "gr", vim.lsp.buf.references, keymap_opts)
					keymap.set("n", "gi", vim.lsp.buf.implementation, keymap_opts)
					keymap.set("n", "K", vim.lsp.buf.hover, keymap_opts)
					keymap.set("n", "<leader>rn", vim.lsp.buf.rename, keymap_opts)
					keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, keymap_opts)
				end,
			})
		end,
	},

	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "*",
		opts = {
			keymap = { preset = "default" },
			appearance = { nerd_font_variant = "mono" },
			completion = { documentation = { auto_show = true } },
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
		},
		opts_extend = { "sources.default" },
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"stylua",
				"goimports",
				"shellcheck",
				"eslint_d",
				"golangci-lint",
			},
		},
	},
}
