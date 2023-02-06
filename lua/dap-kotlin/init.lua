local cache = require("dap-kotlin.cache")
local util = require("dap-kotlin.util")
local test_query = require("dap-kotlin.test_query")

local M = {}
M.dap_configurations = {
	dap_command = "kotlin-debug-adapter",
	project_root = "${workspaceFolder}",
	enable_logging = false,
	log_file_path = "",
}

local function load_module(module_name)
	local ok, module = pcall(require, module_name)
	assert(ok, string.format("dap-kotlin dependency error: %s not installed", module_name))
	return module
end

local function setup_kotlin_adapter(dap)
	dap.adapters.kotlin = {
		type = "executable",
		command = M.dap_configurations.dap_command,
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
			projectRoot = M.dap_configurations.project_root,
			jsonLogFile = M.dap_configurations.log_file_path,
			enableJsonLogging = M.dap_configurations.enable_logging,
		},
		{
			type = "kotlin",
			request = "launch",
			name = "Cached file",
			mainClass = function()
				return cache._cache[vim.fn.getcwd()]
			end,
			projectRoot = M.dap_configurations.project_root,
			jsonLogFile = M.dap_configurations.log_file_path,
			enableJsonLogging = M.dap_configurations.enable_logging,
		},
		{
			type = "kotlin",
			request = "launch",
			name = "All tests",
			mainClass = "org.junit.platform.console.ConsoleLauncher --scan-class-path",
			projectRoot = M.dap_configurations.project_root,
			jsonLogFile = M.dap_configurations.log_file_path,
			enableJsonLogging = M.dap_configurations.enable_logging,
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
			projectRoot = M.dap_configurations.project_root,
			jsonLogFile = M.dap_configurations.log_file_path,
			enableJsonLogging = M.dap_configurations.enable_logging,
		},
	}
end

function M.setup(opts)
	for k, v in pairs(opts) do
		M.dap_configurations[k] = v
	end

	local dap = load_module("dap")

	dap.defaults.kotlin.auto_continue_if_many_stopped = false
	dap.set_log_level("DEBUG")

	setup_kotlin_adapter(dap)
	config_kotlin_adapter(dap)

	cache.cache_read()
end

return M
