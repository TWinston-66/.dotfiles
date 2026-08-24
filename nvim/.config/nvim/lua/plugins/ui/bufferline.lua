local function bufremove(buf)
	require("mini.bufremove").delete(buf, false)
end

return {
	{
		"nvim-mini/mini.bufremove",
		version = false,
		keys = {
			{
				"<leader>bd",
				function()
					bufremove(0)
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>bD",
				function()
					require("mini.bufremove").delete(0, true)
				end,
				desc = "Delete Buffer (Force)",
			},
			{
				"<leader>bo",
				function()
					local cur = vim.api.nvim_get_current_buf()
					for _, b in ipairs(vim.api.nvim_list_bufs()) do
						if b ~= cur and vim.bo[b].buflisted then
							require("mini.bufremove").delete(b, false)
						end
					end
				end,
				desc = "Delete Other Buffers",
			},
		},
		opts = {
			silent = false,
		},
	},

	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",

		keys = {
			{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
			{ "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move Buffer Prev" },
			{ "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move Buffer Next" },
		},
		opts = {
			options = {
				close_command = bufremove,
				right_mouse_command = bufremove,
				diagnostics = "nvim_lsp",
				always_show_bufferline = false,
				offsets = {
					{
						filetype = "aerial",
						text = "Outline",
						highlight = "Directory",
						separator = true,
					},
				},
				diagnostics_indicator = function(_, _, diag)
					local icons = { Error = " ", Warn = " " }
					local ret = (diag.error and icons.Error .. diag.error .. " " or "")
						.. (diag.warning and icons.Warn .. diag.warning or "")
					return vim.trim(ret)
				end,
			},
		},
		config = function(_, opts)
			require("bufferline").setup(opts)

			vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
				callback = function()
					vim.schedule(function()
						pcall(nvim_bufferline)
					end)
				end,
			})
		end,
	},
}
