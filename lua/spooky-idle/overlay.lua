local M = {}
local win, buf, ghost_timer
local uv = vim.loop

function M.dim(cfg)
	if win and vim.api.nvim_win_is_valid(win) then
		return
	end

	buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

	win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = vim.o.columns,
		height = vim.o.lines - 1,
		row = 0,
		col = 0,
		style = "minimal",
		focusable = false,
		zindex = 1000,
	})

	vim.api.nvim_set_hl(0, "SpookyOverlay", { bg = "#000000", blend = cfg.dim_level })
	vim.wo[win].winhighlight = "Normal:SpookyOverlay"

	vim.api.nvim_create_autocmd("VimResized", {
		callback = function()
			if win and vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_set_width(win, vim.o.columns)
				vim.api.nvim_win_set_height(win, vim.o.lines - 1)
			end
		end,
	})

	M.spawn_ghosts(cfg)
end

local ghosts = {
	{ "     .-.", "   (o o) boo!", "   | O |", "   |   |", "   '~~~'" },
	{ " .-.", " (o o)", "  |-|", "  | |", "  '-' " },
}

function M.spawn_ghosts(cfg)
	if ghost_timer then
		ghost_timer:stop()
	end
	ghost_timer = uv.new_timer()
	ghost_timer:start(1000, 6000, function()
		if not win or not vim.api.nvim_win_is_valid(win) then
			return
		end
		vim.schedule(function()
			local art = ghosts[math.random(#ghosts)]
			local buf_g = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_lines(buf_g, 0, -1, false, art)
			local row = math.random(vim.o.lines - #art - 1)
			local col = math.random(math.max(1, vim.o.columns - 15))
			local ghost_win = vim.api.nvim_open_win(buf_g, false, {
				relative = "editor",
				row = row,
				col = col,
				width = 20,
				height = #art,
				style = "minimal",
				focusable = false,
				zindex = 1001,
				noautocmd = true,
			})
			vim.wo[ghost_win].winblend = 80
			vim.defer_fn(function()
				if vim.api.nvim_win_is_valid(ghost_win) then
					vim.api.nvim_win_close(ghost_win, true)
				end
			end, math.random(4000, 8000))
		end)
	end)
end

function M.clear()
	if ghost_timer then
		ghost_timer:stop()
	end
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
	win, buf = nil, nil
end

return M
