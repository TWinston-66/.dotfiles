return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
	ft = "markdown",

	opts = {
		preset = "obsidian",
		completions = { blink = { enabled = true } },
		latex = { enabled = false },
	},
}
