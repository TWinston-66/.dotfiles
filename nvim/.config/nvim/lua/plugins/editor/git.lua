return {
  "echasnovski/mini.diff",
  version = "*",
  event = "VeryLazy",
  config = function()
    local minidiff = require("mini.diff")

    minidiff.setup({
      mappings = {
        textobject = 'gh',
        goto_next = ']c',
        goto_prev = '[c',
      }
    })

    vim.keymap.set('n', '<leader>hs', 'gh_', { remap = true, desc = "Stage hunk" })
    vim.keymap.set('n', '<leader>hr', 'gH_', { remap = true, desc = "Reset hunk" })
    vim.keymap.set('n', '<leader>hp', function() minidiff.toggle_overlay(0) end, { desc = "Toggle preview overlay" })
  end,
}
