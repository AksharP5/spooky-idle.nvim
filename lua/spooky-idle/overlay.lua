local M = {}
local win

---@param cfg spookyidle.Config
function M.dim(cfg)
	if win and vim.api.nvim_win_is_valid(win) then
		return
	end
	local buf = vim.api.nvim_create_buf(false, true)
	local opts = {
		relative = "editor",
		width = vim.o.columns,
		height = vim.o.lines - 1,
		row = 0,
		col = 0,
		style = "minimal",
	}
	win = vim.api.nvim_open_win(buf, false, opts)
	vim.api.nvim_set_hl(0, "SpookyOverlay", { bg = "#000000" })

	local variation = math.random(-10, 10)
	local level = math.max(0, math.min(100, 100 - (cfg.dim_level + variation)))
	vim.wo[win].winhl = "Normal:SpookyOverlay"
	vim.wo[win].winblend = level

	vim.api.nvim_create_autocmd("VimResized", {
		callback = function()
			if win and vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_set_width(win, vim.o.columns)
				vim.api.nvim_win_set_height(win, vim.o.lines - 1)
			end
		end,
	})
end

function M.clear()
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
		win = nil
	end
end

return M
