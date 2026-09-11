return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            format_on_save = function(bufnr)
                local slow = { tex = true, plaintex = true, bib = true }
                return {
                    timeout_ms = slow[vim.bo[bufnr].filetype] and 3000 or 500,
                    lsp_format = "fallback",
                }
            end,

            formatters_by_ft = {
                lua = { "stylua" },
                go = { "goimports", "gofmt" },
                python = { "ruff_organize_imports", "ruff_format" },
                sh = { "shfmt" },
                bash = { "shfmt" },
                javascript = { "prettierd" },
                javascriptreact = { "prettierd" },
                typescript = { "prettierd" },
                typescriptreact = { "prettierd" },
                json = { "prettierd" },
                jsonc = { "prettierd" },
                yaml = { "prettierd" },
                html = { "prettierd" },
                css = { "prettierd" },
                tex = { "latexindent" },
                plaintex = { "latexindent" },
                bib = { "latexindent" },
            },
            notify_on_error = true,
            notify_no_formatters = true,
        })
    end,
}
