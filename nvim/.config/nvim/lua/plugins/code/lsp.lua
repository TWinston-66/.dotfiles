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
				"texlab",
				"pyright",
			},
		},
		config = function(_, opts)
			require("mason").setup()

			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})

			vim.lsp.config("texlab", {
				settings = {
					texlab = {
						build = { onSave = false },
						chktex = { onOpenAndSave = true, onEdit = false },
					},
				},
			})

			vim.lsp.config("pyright", {
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "openFilesOnly",
						},
					},
				},
				before_init = function(_, config)
					local venv = (config.root_dir or vim.fn.getcwd()) .. "/.venv/bin/python"
					if vim.uv.fs_stat(venv) then
						config.settings.python.pythonPath = venv
					end
				end,
			})

			require("mason-lspconfig").setup(opts)

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local keymap_opts = { buffer = event.buf }
					local keymap = vim.keymap

					local fzf = function(picker)
						return function()
							require("fzf-lua")[picker]()
						end
					end

					keymap.set("n", "gd", fzf("lsp_definitions"), keymap_opts)
					keymap.set("n", "gD", vim.lsp.buf.declaration, keymap_opts)
					keymap.set("n", "gr", fzf("lsp_references"), keymap_opts)
					keymap.set("n", "gi", fzf("lsp_implementations"), keymap_opts)
					keymap.set("n", "gy", fzf("lsp_typedefs"), keymap_opts)
					keymap.set("n", "<leader>fd", fzf("diagnostics_document"), keymap_opts)
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
			keymap = { preset = "super-tab" },
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
				"shfmt",
				"eslint_d",
				"prettierd",
				"golangci-lint",
				"ruff",
			},
		},
	},
}
