local M = {}
local uv = vim.uv
local dim_win, dim_buf, ghost_win, ghost_buf
local ghost_timer
local ghosts = {
	{
		"     .-.",
		"    (o o) boo!",
		"    | O \\",
		"     \\   \\",
		"      `~~~'",
	},
	{
		"      .-.",
		"     (o o)",
		"     | O \\",
		"      \\   \\",
		"       `~~~'",
	},
	{
		"    .-.",
		"   (o o)    .-.",
		"   | O \\   (o o)",
		"    \\   \\   | O \\",
		"     `~~~'   \\   \\",
		"              `~~~'",
	},
	{
		"        .-.",
		"     .-(   )-.",
		"    /   ' '   \\",
		"   | .-. .-.  |",
		"   \\( o ) ( o )/",
		"    '-(_) (_)-'",
	},
	{
		"        .-. ",
		"       (o o) ",
		"       | O \\ ",
		"       |    \\ ",
		"        `~~~' ",
		"     spooky~boo ",
	},
	{
		"      (    )",
		"     ((((()))",
		"     |o\\ /o)|",
		"     ( (  _')",
		"      (._. )",
		"       |||",
		"      _|||_",
	},
	{
		"      .-.",
		"     (o o)",
		"     | O \\",
		"     |   |",
		"     '~~~'",
		"   phantasm~",
	},
}

local function spawn_ghost()
	if ghost_win and vim.api.nvim_win_is_valid(ghost_win) then
		vim.api.nvim_win_close(ghost_win, true)
	end
	local art = ghosts[math.random(#ghosts)]
	local width = 0
	for _, line in ipairs(art) do
		width = math.max(width, #line)
	end
	local height = #art
	local col = math.random(0, math.max(1, vim.o.columns - width - 1))
	local row = math.random(0, math.max(1, vim.o.lines - height - 1))
	ghost_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(ghost_buf, 0, -1, false, art)
	ghost_win = vim.api.nvim_open_win(ghost_buf, false, {
		relative = "editor",
		style = "minimal",
		width = width,
		height = height,
		col = col,
		row = row,
		zindex = 300,
	})
	vim.api.nvim_set_option_value("winhighlight", "Normal:SpookyDim", { win = ghost_win })
end

function M.show(dim)
	vim.cmd("hi SpookyDim guibg=#000000 guifg=#aaaaaa blend=" .. dim)
	dim_buf = vim.api.nvim_create_buf(false, true)
	dim_win = vim.api.nvim_open_win(dim_buf, false, {
		relative = "editor",
		style = "minimal",
		width = vim.o.columns,
		height = vim.o.lines,
		row = 0,
		col = 0,
		zindex = 200,
	})
	vim.api.nvim_set_option_value("winhighlight", "Normal:SpookyDim", { win = dim_win })
	ghost_timer = uv.new_timer()
	if ghost_timer then
		ghost_timer:start(
			0,
			4000,
			vim.schedule_wrap(function()
				spawn_ghost()
			end)
		)
	end
end

function M.hide()
	if ghost_timer then
		ghost_timer:stop()
		ghost_timer:close()
		ghost_timer = nil
	end
	if ghost_win and vim.api.nvim_win_is_valid(ghost_win) then
		vim.api.nvim_win_close(ghost_win, true)
	end
	if dim_win and vim.api.nvim_win_is_valid(dim_win) then
		vim.api.nvim_win_close(dim_win, true)
	end
	dim_win, dim_buf, ghost_win, ghost_buf = nil, nil, nil, nil
end

return M
