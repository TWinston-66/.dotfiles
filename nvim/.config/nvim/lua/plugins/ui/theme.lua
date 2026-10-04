-- The flavour lattice-theme has picked (lattice's modules/nixos/theme.nix writes it as
-- `return { colorscheme = ..., globals = { ... } }`). Watched rather than read once, so a
-- switch recolours every running nvim without anyone sending it anything. There is no such
-- directory on macOS, which leaves Catppuccin Mocha.
local themeDir = vim.fs.joinpath(vim.env.HOME or "", ".cache", "lattice")
local themeFile = "theme-nvim.lua"

local function readTheme()
	local chunk = loadfile(vim.fs.joinpath(themeDir, themeFile))
	if not chunk then
		return nil
	end
	local ok, theme = pcall(chunk)
	if ok and type(theme) == "table" and type(theme.colorscheme) == "string" then
		return theme
	end
end

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			integrations = {
				aerial = true,
				blink_cmp = true,
				fzf = true,
				mason = true,
				mini = { enabled = true },
				native_lsp = { enabled = true },
				render_markdown = true,
				snacks = true,
				treesitter = true,
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)

			local applied

			local function apply()
				local theme = readTheme() or { colorscheme = "catppuccin-mocha" }
				local key = vim.inspect(theme)
				if key == applied then
					return
				end
				applied = key

				for name, value in pairs(theme.globals or {}) do
					vim.g[name] = value
				end
				-- lazy.nvim loads the plugin behind a colorscheme it has not loaded yet. A
				-- name that fails to load leaves whatever was up rather than an error per
				-- keystroke.
				local ok, err = pcall(vim.cmd.colorscheme, theme.colorscheme)
				if not ok then
					vim.notify("lattice theme: " .. err, vim.log.levels.WARN)
				end
			end

			apply()

			-- The directory rather than the file: lattice-palette renames a new file over
			-- the old one, which a watch on the file itself would lose track of.
			if vim.fn.isdirectory(themeDir) == 1 then
				local watcher = vim.uv.new_fs_event()
				if watcher then
					watcher:start(themeDir, {}, function(err, name)
						if not err and name == themeFile then
							vim.schedule(apply)
						end
					end)
				end
			end
		end,
	},

	-- The non-Catppuccin flavours, each in its own upstream colorscheme rather than as a
	-- palette poured into Catppuccin's highlight groups. lazy.nvim loads a colorscheme
	-- plugin the first time `:colorscheme` names it, so these cost nothing until picked.
	{ "folke/tokyonight.nvim", lazy = true },
	{ "rose-pine/neovim", name = "rose-pine", lazy = true },
	{ "sainnhe/gruvbox-material", lazy = true },
}
