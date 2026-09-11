vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local keymap = vim.keymap

keymap.set("n", "<leader>uz", "<cmd>FzfLua spell_suggest<cr>", { desc = "Spelling Suggestions" })

