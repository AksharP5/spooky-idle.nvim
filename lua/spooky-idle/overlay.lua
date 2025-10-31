local M = {}
local uv = vim.uv
local overlay_win
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
		"        .-. ",
		"       (o o) ",
		"       | O \\ ",
		"       |    \\ ",
		"        `~~~' ",
		"     spooky~boo ",
	},
	{
		"      .-.",
		"     (o o)",
		"     | O \\",
		"     |   |",
		"     '~~~'",
		"   phantasm~",
	},
	{
		"        /\\                 /\\",
		"       / \\'._   (\\_/)   _.'/ \\",
		"      /_.''._'--('.')--'_.''._\\",
		'      | \\_ / `;=/ " \\=;` \\ _/ |',
		"       \\/ `\\__|`\\___/`|__/`  \\/",
		"               \\(/|\\)/",
	},
	{
		"            _____",
		"           /     \\",
		"          /       \\",
		"         |  .-. .-.|",
		"         |  |_| |_| |",
		"         |   .---.  |",
		"         |  (     ) |",
		"          \\  `-.-' /",
		"           `--._.--'",
		"           // || \\\\",
		"         _//__||__\\\\_",
		"        (__)______(__)",
	},
}

local function spawn_ghost()
	if not overlay_win or not vim.api.nvim_win_is_valid(overlay_win) then
		return
	end
	local buf = vim.api.nvim_win_get_buf(overlay_win)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

	local ghost = ghosts[math.random(#ghosts)]
	local total_lines = vim.o.lines - 1
	local total_cols = vim.o.columns
	local y_offset = math.max(0, math.random(0, total_lines - #ghost - 1))
	local x_offset = math.max(0, math.random(0, total_cols - 30))

	local lines = {}
	for _, line in ipairs(ghost) do
		table.insert(lines, string.rep(" ", x_offset) .. line)
	end

	local padding = {}
	for _ = 1, y_offset do
		table.insert(padding, "")
	end
	for _, l in ipairs(lines) do
		table.insert(padding, l)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, padding)
end

function M.show(dim)
	if overlay_win and vim.api.nvim_win_is_valid(overlay_win) then
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
		focusable = false,
	}
	overlay_win = vim.api.nvim_open_win(buf, false, opts)
	vim.api.nvim_set_hl(0, "SpookyDim", { bg = "#000000", blend = dim or 70 })
	vim.api.nvim_set_option_value("winhighlight", "Normal:SpookyDim", { win = overlay_win })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })

	ghost_timer = uv.new_timer()
	if ghost_timer then
		ghost_timer:start(0, 4000, vim.schedule_wrap(spawn_ghost))
	end
end

function M.hide()
	if ghost_timer then
		ghost_timer:stop()
		ghost_timer:close()
		ghost_timer = nil
	end
	if overlay_win and vim.api.nvim_win_is_valid(overlay_win) then
		vim.api.nvim_win_close(overlay_win, true)
		overlay_win = nil
	end
end

return M
