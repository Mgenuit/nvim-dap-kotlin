local tsquery = require("vim.treesitter.query")

local M = {}

local function sanitised(test_name)
	local clean_test = test_name:gsub("`", "")
	return clean_test
end

function M.test_class()
	local query = [[
(class_declaration (type_identifier) @cname)
]]
	local parser = vim.treesitter.get_parser(0)
	local root = (parser:parse()[1]):root()

	local closest_name = nil

	local stop_row = vim.api.nvim_win_get_cursor(0)[1] -- The query stops looking after this. By taking the last result we get the funtion your cursor is in
	local ft = vim.api.nvim_buf_get_option(0, "filetype")
	assert(ft == "kotlin", "dap-go error: can only debug go files, not " .. ft)

	local test_query = vim.treesitter.parse_query(ft, query)
	assert(test_query, "dap-go error: could not parse test query")

	for _, match, _ in test_query:iter_matches(root, 0, 0, stop_row) do
		for id, node in pairs(match) do
			local capture = test_query.captures[id]
			if capture == "cname" then
				closest_name = tsquery.get_node_text(node, 0)
			end
		end
	end
	return closest_name
end

function M.closest_test()
	local tests_query = [[
    (function_declaration
    (modifiers)? @mod
    (simple_identifier) @fname)
]]

	local parser = vim.treesitter.get_parser(0)
	local root = (parser:parse()[1]):root()

	Debug_test_tree = {}
	local test_name = ""

	local stop_row = vim.api.nvim_win_get_cursor(0)[1] -- The query stops looking after this. By taking the last result we get the funtion your cursor is in
	local ft = vim.api.nvim_buf_get_option(0, "filetype")
	assert(ft == "kotlin", "dap-go error: can only debug go files, not " .. ft)

	local test_query = vim.treesitter.parse_query(ft, tests_query)
	assert(test_query, "dap-go error: could not parse test query")

	for _, match, _ in test_query:iter_matches(root, 0, 0, stop_row) do
		local test_match = {}
		for id, node in pairs(match) do
			local capture = test_query.captures[id]
			if capture == "mod" then
				local name = tsquery.get_node_text(node, 0)
				test_match.modifier = name
			end
			if capture == "fname" then
				test_match.function_name = tsquery.get_node_text(node, 0)
			end
		end
		table.insert(Debug_test_tree, test_match)
		test_name = test_match.function_name
	end
	return sanitised(test_name)
end

return M
