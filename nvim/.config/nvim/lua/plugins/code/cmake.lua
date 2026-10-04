-- Build integration for CMake projects. The reason this is here rather than just a
-- language server: clangd with no compile_commands.json falls back to a guessed command
-- line, so include paths, -D defines and the language standard are all whatever it
-- assumes. cmake-tools generates the database and links it where clangd looks, which is
-- what makes diagnostics in a real project match what the compiler actually does.
return {
	"Civitasv/cmake-tools.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	-- Loaded from a CMakeLists.txt, and by any of the commands below -- the commands
	-- matter because they are mostly run from a C or C++ buffer, not from the cmake file.
	ft = "cmake",
	cmd = {
		"CMakeGenerate",
		"CMakeBuild",
		"CMakeRun",
		"CMakeDebug",
		"CMakeQuickStart",
		"CMakeSelectBuildTarget",
		"CMakeSelectLaunchTarget",
		"CMakeSelectBuildType",
		"CMakeRunTest",
		"CMakeClean",
		"CMakeStopRunner",
		"CMakeSettings",
	},
	opts = {
		-- Upstream defaults to out/${variant:buildType}, which keeps Debug and Release
		-- apart. Plain `build` instead: it is the conventional name, it is already one of
		-- neocmake's root_markers, and it keeps compile_commands.json at a path that is
		-- easy to point other tools at.
		cmake_build_directory = "build",

		-- The clangd handoff, and the whole point of the plugin here. This matches the
		-- current upstream default, but it is set explicitly because it is load-bearing:
		-- if the default ever changes, C diagnostics quietly go back to guessed flags
		-- rather than failing in any visible way.
		cmake_compile_commands_options = {
			action = "soft_link",
			target = vim.uv.cwd,
		},

		-- :CMakeDebug through the gdb adapter in debug.lua. Upstream defaults to
		-- codelldb, which is not installed here, so the command would fail to start.
		cmake_dap_configuration = {
			name = "cpp",
			type = "gdb",
			request = "launch",
			stopAtBeginningOfMainSubprogram = false,
		},
	},
	keys = {
		{ "<leader>mg", "<cmd>CMakeGenerate<cr>", desc = "CMake Generate" },
		{ "<leader>mb", "<cmd>CMakeBuild<cr>", desc = "CMake Build" },
		{ "<leader>mr", "<cmd>CMakeRun<cr>", desc = "CMake Run" },
		{ "<leader>md", "<cmd>CMakeDebug<cr>", desc = "CMake Debug" },
		{ "<leader>mt", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake Select Build Target" },
		{ "<leader>ml", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "CMake Select Launch Target" },
		{ "<leader>my", "<cmd>CMakeSelectBuildType<cr>", desc = "CMake Select Build Type" },
		{ "<leader>mk", "<cmd>CMakeStopRunner<cr>", desc = "CMake Stop Runner" },
		{ "<leader>mc", "<cmd>CMakeClean<cr>", desc = "CMake Clean" },
		{ "<leader>ms", "<cmd>CMakeSettings<cr>", desc = "CMake Settings" },
	},
}
