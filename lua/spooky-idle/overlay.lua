local M = {}
local uv = vim.uv
local win, buf, ghost_timer

local ghosts = {
	{
		[[     .-.
      (o o) boo!
      | O \
       \   \
        `~~~'   ]],
	},
	{
		[[      .-.
      (o o)
      | O \
       \   \
        `~~~'   ]],
	},
}

local function create_overlay(dim_level)
	if win and vim.api.nvim_win_is_valid(win) then
		return
	end
	buf = vim.api.nvim_create_buf(false, true)
	local width = vim.o.columns
	local height = vim.o.lines
	win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = width,
		height = height,
		row = 0,
		col = 0,
		focusable = false,
		style = "minimal",
		noautocmd = true,
	})
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
	vim.api.nvim_set_hl(0, "SpookyDim", { bg = "#000000", blend = dim_level })
	vim.api.nvim_set_option_value("winhighlight", "Normal:SpookyDim", { win = win })
end

local function spawn_ghost()
	if not win or not vim.api.nvim_win_is_valid(win) then
		return
	end
	local art = ghosts[math.random(#ghosts)]
	local max_row = math.max(1, vim.o.lines - #art - 1)
	local max_col = math.max(1, vim.o.columns - 15)
	local row = math.random(max_row)
	local col = math.random(max_col)
	local ghost_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(ghost_buf, 0, -1, false, art)
	local ghost_win = vim.api.nvim_open_win(ghost_buf, false, {
		relative = "editor",
		row = row,
		col = col,
		width = 15,
		height = #art,
		style = "minimal",
		focusable = false,
		noautocmd = true,
	})
	local timer = uv.new_timer()
	if not timer then
		return
	end
	timer:start(
		2000,
		0,
		vim.schedule_wrap(function()
			if vim.api.nvim_win_is_valid(ghost_win) then
				vim.api.nvim_win_close(ghost_win, true)
			end
		end)
	)
end

local function start_ghosts()
	if ghost_timer then
		ghost_timer:stop()
		ghost_timer = nil
	end
	ghost_timer = uv.new_timer()
	if not ghost_timer then
		return
	end
	ghost_timer:start(
		0,
		4000,
		vim.schedule_wrap(function()
			if win and vim.api.nvim_win_is_valid(win) then
				spawn_ghost()
			end
		end)
	)
end

function M.start(dim_level)
	create_overlay(dim_level or 70)
	start_ghosts()
end

function M.clear()
	if ghost_timer then
		ghost_timer:stop()
		ghost_timer = nil
	end
	vim.schedule(function()
		if win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		win, buf = nil, nil
	end)
end

return M
