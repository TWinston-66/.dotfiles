return {
  "gbprod/yanky.nvim",
  opts = {},
  keys = {
    { "<leader>y", "<cmd>YankyRingHistory<cr>", mode = { "n", "x" }, desc = "Yank History" },

    { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after" },
    { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before" },
    { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put after, leave cursor after" },
    { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put before, leave cursor after" },

    { "<c-]>", "<Plug>(YankyCycleForward)", desc = "Cycle to next yank" },
    { "<c-[>", "<Plug>(YankyCycleBackward)", desc = "Cycle to previous yank" },
  },
}