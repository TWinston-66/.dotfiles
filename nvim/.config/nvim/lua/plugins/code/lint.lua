return {
    "mfussenegger/nvim-lint",
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            go = { "golangcilint" },
            python = { "ruff" },
            sh = { "shellcheck" },
            nix = { "statix" },
            javascript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescript = { "eslint_d" },
            typescriptreact = { "eslint_d" },
        }

        -- statix reports its own parse errors (often a pile at 1:1); nixd already covers syntax
        local statix_parser = lint.linters.statix.parser
        lint.linters.statix.parser = function(output, bufnr, cwd)
            return vim.tbl_filter(function(d)
                return not vim.startswith(d.message, "Unexpected ")
            end, statix_parser(output, bufnr, cwd))
        end

        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
