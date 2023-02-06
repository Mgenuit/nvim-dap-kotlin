local cache = require("nvim-dap-kotlin.cache")
local util = require("nvim-dap-kotlin.util")
local test_query = require("nvim-dap-kotlin.test_query")

require("nvim-dap-kotlin.util")

local M = {}
M.opts = {
	dapCommand = "kotlin-debug-adapter",
	projectRoot = "${workspaceFolder}",
	jsonLogFile = "",
	enableJsonLogging = false,
}

local function load_module(module_name)
	local ok, module = pcall(require, module_name)
	assert(ok, string.format("dap-kotlin dependency error: %s not installed", module_name))
	return module
end

local function setup_kotlin_adapter(dap)
	dap.adapters.kotlin = {
		type = "executable",
		command = M.opts.dapCommand,
		options = {
			initialize_timeout_sec = 15,
			disconnect_timeout_sec = 15,
			auto_continue_if_many_stopped = false,
		},
	}
end

-- Setup the configurations our kotlin adapter can run under
local function config_kotlin_adapter(dap)
	dap.configurations.kotlin = {
		{
			type = "kotlin",
			request = "launch",
			name = "This file",
			mainClass = function()
				local mainclass = util.get_package() .. "." .. test_query.test_class() .. "Kt"
				cache.cache_add(mainclass)
				return mainclass
			end,
			projectRoot = M.opts.projectRoot,
			jsonLogFile = M.opts.jsonLogFile,
			enableJsonLogging = M.opts.enableJsonLogging,
		},
		{
			type = "kotlin",
			request = "launch",
			name = "Cached file",
			mainClass = function()
				return cache._cache[vim.fn.getcwd()]
			end,
			projectRoot = M.opts.projectRoot,
			jsonLogFile = M.opts.jsonLogFile,
			enableJsonLogging = M.opts.enableJsonLogging,
		},
		{
			type = "kotlin",
			request = "launch",
			name = "All tests",
			mainClass = "org.junit.platform.console.ConsoleLauncher --scan-class-path",
			projectRoot = M.opts.projectRoot,
			jsonLogFile = M.opts.jsonLogFile,
			enableJsonLogging = M.opts.enableJsonLogging,
		},
		{
			type = "kotlin",
			request = "launch",
			name = "Closest test",
			mainClass = function()
				return 'org.junit.platform.console.ConsoleLauncher -m="'
					.. util.get_package()
					.. "."
					.. test_query.test_class()
					.. "#"
					.. test_query.closest_test()
					.. '"' -- These qoutes are needed to support the kotlin way of allowing spaces in testnames
			end,
			projectRoot = M.opts.projectRoot,
			jsonLogFile = M.opts.jsonLogFile,
			enableJsonLogging = M.opts.enableJsonLogging,
		},
	}
end

function M.setup(opts)
	for k, v in pairs(opts) do
		M.opts[k] = v
	end

	local dap = load_module("dap")

	dap.defaults.kotlin.auto_continue_if_many_stopped = false
	dap.set_log_level("DEBUG")

	setup_kotlin_adapter(dap)
	config_kotlin_adapter(dap)

	cache.cache_read()
end

return M
