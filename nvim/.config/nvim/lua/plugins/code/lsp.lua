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

			-- not in mason; installed via nix profile
			vim.lsp.config("nixd", {
				settings = {
					nixd = {
						nixpkgs = { expr = "import <nixpkgs> { }" },
						options = {
							nixos = {
								expr = "(import <nixpkgs/nixos/lib/eval-config.nix> { modules = [ ]; }).options",
							},
						},
					},
				},
				-- nixd filters server-side and truncates results (e.g. 30 items after `services.`)
				-- but reports isIncomplete = false, so blink never re-requests as you type
				on_init = function(client)
					local request = client.request
					client.request = function(self, method, params, handler, bufnr)
						if method == "textDocument/completion" and handler then
							local on_result = handler
							handler = function(err, result, ctx)
								if result then
									result.isIncomplete = true
								end
								return on_result(err, result, ctx)
							end
						end
						return request(self, method, params, handler, bufnr)
					end
				end,
			})
			if vim.fn.executable("nixd") == 1 then
				vim.lsp.enable("nixd")
			end

			-- also not in mason: upstream publishes no aarch64 Linux clangd, so
			-- `ensure_installed` only ever logged "The current platform is unsupported".
			-- clang-tools comes from systemPackages instead. gcc stays the compiler --
			-- clangd is only the index here, and the nixpkgs clangd is wrapped with the
			-- same glibc and gcc 15 header paths gcc compiles against, so the two agree
			-- even on a bare .c file with no compile_commands.json.
			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					-- clang-tidy in-process, so C needs no nvim-lint entry. Inert until a
					-- project drops in a .clang-tidy (or ~/.config/clangd/config.yaml sets
					-- Diagnostics.ClangTidy.Add) -- clangd enables no checks on its own.
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
				},
			})
			if vim.fn.executable("clangd") == 1 then
				vim.lsp.enable("clangd")
			end

			-- neocmakelsp, also from systemPackages. Upstream notes it only returns
			-- completions when the client advertises snippetSupport; blink already sets
			-- that in get_lsp_capabilities, which the "*" config above applies, so no
			-- per-server capabilities override is needed here.
			if vim.fn.executable("neocmakelsp") == 1 then
				vim.lsp.enable("neocmake")
			end

			require("mason-lspconfig").setup(opts)

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local opts = function(desc)
						return { buffer = event.buf, desc = desc }
					end
					local keymap = vim.keymap

					local fzf = function(picker)
						return function()
							require("fzf-lua")[picker]()
						end
					end

					keymap.set("n", "gd", fzf("lsp_definitions"), opts("Go to Definition"))
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to Declaration"))
					keymap.set("n", "gr", fzf("lsp_references"), opts("References"))
					keymap.set("n", "gi", fzf("lsp_implementations"), opts("Implementations"))
					keymap.set("n", "gy", fzf("lsp_typedefs"), opts("Type Definitions"))
					keymap.set("n", "<leader>fd", fzf("diagnostics_document"), opts("Search Diagnostics"))
					keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover Docs"))
					keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename Symbol"))
					keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
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
