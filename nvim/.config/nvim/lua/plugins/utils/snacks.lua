return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		dashboard = {
			enabled = true,
			preset = {
				header = [[
 ███╗   ██╗██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██║   ██║██║████╗ ████║
 ██╔██╗ ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":FzfLua files" },
					{ icon = " ", key = "g", desc = "Find Text", action = ":FzfLua live_grep" },
					{ icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
					{ icon = " ", key = "e", desc = "File Explorer", action = ":lua Snacks.explorer()" },
					{ icon = "󰎞 ", key = "v", desc = "Vault", action = ":Obsidian quick_switch" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = " ", key = "c", desc = "Config", action = ":FzfLua files cwd=" .. vim.fn.stdpath("config") },
					{ icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				{ section = "startup" },
			},
		},

		explorer = { enabled = true },
		image = { enabled = true },
		picker = {
			enabled = true,
			ui_select = false,
			sources = {
				explorer = { hidden = true },
			},
		},
		scroll = { enabled = true },
		words = { enabled = true },
	},

	keys = {
		{ "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
		{ "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
		{ "<leader>gb", function() Snacks.gitbrowse() end, mode = { "n", "v" }, desc = "Git Browse" },
		{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
		{ "<leader>bD", function() Snacks.bufdelete({ force = true }) end, desc = "Delete Buffer (Force)" },
		{ "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
		{ "]]", function() Snacks.words.jump(vim.v.count1) end, mode = { "n", "t" }, desc = "Next Reference" },
		{ "[[", function() Snacks.words.jump(-vim.v.count1) end, mode = { "n", "t" }, desc = "Prev Reference" },
	},

	init = function()
		-- Snacks only renders page 1 of a PDF; re-place the image with a #page=N suffix to page through it
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "image",
			callback = function(ev)
				local file = vim.api.nvim_buf_get_name(ev.buf)
				if not file:lower():match("%.pdf$") then
					return
				end

				local escaped = file:gsub("[\\()]", "\\%0")
				local out = vim.system({
					"gs", "-q", "-dNODISPLAY", "-dNOSAFER",
					"-c", "(" .. escaped .. ") (r) file runpdfbegin pdfpagecount = quit",
				}):wait()
				local count = tonumber(vim.trim(out.stdout or ""))

				local page = 1
				local function show(n)
					page = count and math.min(math.max(n, 1), count) or math.max(n, 1)
					Snacks.image.placement.clean(ev.buf)
					Snacks.image.placement.new(ev.buf, file .. "#page=" .. page, { conceal = true, auto_resize = true })
					vim.api.nvim_echo({ { ("Page %d/%s"):format(page, count or "?") } }, false, {})
				end

				local map = function(lhs, fn, desc)
					vim.keymap.set("n", lhs, fn, { buffer = ev.buf, desc = desc })
				end
				map("]p", function() show(page + vim.v.count1) end, "Next PDF Page")
				map("[p", function() show(page - vim.v.count1) end, "Prev PDF Page")
				map("gp", function()
					if vim.v.count > 0 then
						return show(vim.v.count)
					end
					vim.ui.input({ prompt = "Page: " }, function(input)
						if tonumber(input) then
							show(tonumber(input))
						end
					end)
				end, "Go To PDF Page")
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.inlay_hints():map("<leader>uh")
			end,
		})
	end,
}
