--- Module to handle opening C/C++ header and source files side-by-side.
-- This module provides functionality to ensure headers are opened in the left split
-- and sources in the right split. The behavior can be modified with the `fixed_order` option.
-- @module cpp_header_source_pair

local M = {}

--- Default configuration options.
M.config = {
	open_header_sources = true, -- Enable or disable header-source pairing.
	fixed_order = true, -- Ensure headers are always on the left, sources on the right.
}

--- Setup function for configuration.
-- This function allows users to configure the plugin options.
-- @param opts (table) Configuration options.
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

--- Checks if a file exists.
-- @param name (string) The full path to the file.
-- @return (boolean) `true` if the file exists, `false` otherwise.
function M.file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

--- Checks if there is an adjacent window in a given direction.
-- @param direction (string) The direction to check (`"h"` for left, `"l"` for right).
-- @return (boolean) `true` if there is an adjacent window, `false` otherwise.
function M.has_adjacent_window(direction)
	local current_win = vim.api.nvim_get_current_win()
	vim.cmd("wincmd " .. direction)
	local new_win = vim.api.nvim_get_current_win()
	vim.cmd("wincmd p")
	return current_win ~= new_win
end

--- Changes the file in the adjacent window in a specified direction.
-- @param direction (string) The direction of the adjacent window (`"h"` for left, `"l"` for right).
-- @param file_path (string) The path of the file to open in the adjacent window.
function M.change_file_in_adjacent_window(direction, file_path)
	local current_win = vim.api.nvim_get_current_win()
	vim.cmd("wincmd " .. direction)
	vim.cmd("edit " .. file_path)
	vim.cmd("set filetype=cpp") -- Ensures proper syntax highlighting
	vim.api.nvim_set_current_win(current_win)
end

--- Opens header and source files in a fixed order (header left, source right).
-- @param has_left (boolean) Whether there is a window to the left.
-- @param has_right (boolean) Whether there is a window to the right.
-- @param pair (string) The path to the paired file.
-- @param is_header (boolean) Whether the current file is a header.
-- @param current_file (string) The path to the current file.
function M.open_fixed_order(has_left, has_right, pair, is_header, current_file)
	if is_header then
		if has_left and not has_right then
			M.change_file_in_adjacent_window("h", current_file)
			vim.cmd("edit " .. pair)
			vim.cmd("set filetype=cpp")
		elseif has_right and not has_left then
			M.change_file_in_adjacent_window("l", pair)
		else
			local current_win = vim.api.nvim_get_current_win()
			vim.cmd("vsplit " .. pair)
			vim.cmd("set filetype=cpp")
			vim.api.nvim_set_current_win(current_win)
		end
	else
		if has_left and not has_right then
			M.change_file_in_adjacent_window("h", pair)
		elseif has_right and not has_left then
			M.change_file_in_adjacent_window("l", current_file)
			vim.cmd("edit " .. pair)
			vim.cmd("set filetype=cpp")
		else
			vim.cmd("vsplit " .. current_file)
			vim.cmd("set filetype=cpp")
			M.change_file_in_adjacent_window("h", pair)
		end
	end
end

--- Opens header and source files in any order (nearest adjacent window).
-- @param has_right (boolean) Whether there is a window to the right.
-- @param has_left (boolean) Whether there is a window to the left.
-- @param pair (string) The path to the paired file.
function M.open_any_order(has_right, has_left, pair)
	if not has_right and not has_left then
		local current_win = vim.api.nvim_get_current_win()
		vim.cmd("vsplit " .. pair)
		vim.cmd("set filetype=cpp")
		vim.api.nvim_set_current_win(current_win)
	elseif has_right then
		M.change_file_in_adjacent_window("l", pair)
	else
		M.change_file_in_adjacent_window("h", pair)
	end
end

--- Handles the pairing of header and source files.
-- This is the main entry point for the plugin. It determines whether to open
-- the files in fixed order or any order based on `M.fixed_order`.
function M.handle_pairing()
	if M.config.open_header_sources then
		local current_file = vim.fn.expand("%:p")
		local is_header = current_file:match("%.h$") or current_file:match("%.hpp$")
		local pair = ""

		-- Determine the paired file
		if is_header then
			pair = current_file:gsub("%.h$", ".c"):gsub("%.hpp$", ".cpp")
		else
			pair = current_file:gsub("%.c$", ".h"):gsub("%.cpp$", ".hpp")
		end

		local f_exists = M.file_exists(pair)
		local has_left = M.has_adjacent_window("h")
		local has_right = M.has_adjacent_window("l")

		if pair and f_exists then
			if M.config.fixed_order then
				M.open_fixed_order(has_left, has_right, pair, is_header, current_file)
			else
				M.open_any_order(has_left, has_right, pair)
			end
		end
	end
end

--- Automatically handles header-source pairing when C/C++ files are opened.
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = { "*.h", "*.hpp", "*.c", "*.cpp" },
	callback = function()
		M.handle_pairing()
	end,
})

return M
