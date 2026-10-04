-- Debugging through gdb's own DAP interpreter (`gdb -i dap`, gdb 14+). No adapter from
-- mason: cpptools and codelldb are the usual choices, and both are prebuilt blobs with the
-- same aarch64 Linux gaps that sent clangd to nixpkgs. gdb comes from systemPackages, so
-- the debugger in nvim and `gdb` in a shell are the same binary and read the same
-- ~/.config/gdb/gdbinit.
return {
	{
		"mfussenegger/nvim-dap",
		dependencies = { "igorlfs/nvim-dap-view" },
		keys = {
			{ "<F5>", function() require("dap").continue() end, desc = "Debug Continue / Start" },
			{ "<F10>", function() require("dap").step_over() end, desc = "Debug Step Over" },
			{ "<F11>", function() require("dap").step_into() end, desc = "Debug Step Into" },
			{ "<F12>", function() require("dap").step_out() end, desc = "Debug Step Out" },
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
			{
				"<leader>dB",
				function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,
				desc = "Conditional Breakpoint",
			},
			{ "<leader>dc", function() require("dap").continue() end, desc = "Debug Continue / Start" },
			{ "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
			{ "<leader>dl", function() require("dap").run_last() end, desc = "Debug Run Last" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "Debug Terminate" },
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug REPL" },
			{ "<leader>du", "<cmd>DapViewToggle<cr>", desc = "Debug View" },
			{ "<leader>dw", "<cmd>DapViewWatch<cr>", mode = { "n", "v" }, desc = "Debug Watch" },
		},
		config = function()
			local dap = require("dap")

			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}

			local program = function()
				return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
			end

			local configurations = {
				{
					name = "Launch",
					type = "gdb",
					request = "launch",
					program = program,
					args = function()
						return vim.split(vim.fn.input("Args: "), " ", { trimempty = true })
					end,
					cwd = "${workspaceFolder}",
					stopAtBeginningOfMainSubprogram = false,
				},
				{
					name = "Attach to process",
					type = "gdb",
					request = "attach",
					pid = function()
						return require("dap.utils").pick_process()
					end,
					cwd = "${workspaceFolder}",
				},
				{
					name = "Attach to gdbserver :1234",
					type = "gdb",
					request = "attach",
					target = "localhost:1234",
					program = program,
					cwd = "${workspaceFolder}",
				},
			}
			dap.configurations.c = configurations
			dap.configurations.cpp = configurations
			dap.configurations.rust = configurations

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

			-- dap-view opens with a session and closes when it ends, so <leader>du is only
			-- needed to bring it back after closing it by hand.
			local view = require("dap-view")
			dap.listeners.before.attach["dap-view"] = view.open
			dap.listeners.before.launch["dap-view"] = view.open
			dap.listeners.before.event_terminated["dap-view"] = view.close
			dap.listeners.before.event_exited["dap-view"] = view.close
		end,
	},
}
