local overlay = require("spooky-idle.overlay")
local audio = require("spooky-idle.audio")

local M = {}
local uv = vim.uv
local idle_timer
local last_activity = uv.now()
local active = false

local opts = {
	idle_time = 10000,
	dim_level = 70,
	sound_enabled = true,
	sound_dir = nil,
}

function M.setup(user_opts)
	opts = vim.tbl_deep_extend("force", opts, user_opts or {})
end

local function stop_all()
	if active then
		active = false
		overlay.hide()
		audio.stop()
	end
end

local function mark_activity()
	last_activity = uv.now()
	if active then
		stop_all()
	end
end

local function start_idle()
	if active then
		return
	end
	active = true
	overlay.show(opts.dim_level)
	if opts.sound_enabled then
		audio.play_random_loop(opts.sound_dir)
	end
end

function M.start()
	if idle_timer then
		idle_timer:stop()
		idle_timer:close()
	end

	vim.o.mousemoveevent = true
	local group = vim.api.nvim_create_augroup("SpookyIdleDetect", { clear = true })

	vim.api.nvim_create_autocmd(
		{ "CursorMoved", "CursorMovedI", "InsertEnter", "FocusGained", "WinEnter", "CmdlineEnter" },
		{ group = group, callback = mark_activity }
	)

	vim.on_key(mark_activity, group)
	if vim.on_input then
		vim.on_input(mark_activity)
	end

	idle_timer = uv.new_timer()
	if not idle_timer then
		vim.notify("spooky-idle: failed to create timer", vim.log.levels.ERROR)
		return
	end

	vim.schedule(function()
		vim.notify("spooky-idle started", vim.log.levels.INFO)
	end)

	idle_timer:start(
		0,
		500,
		vim.schedule_wrap(function()
			if not active and uv.now() - last_activity >= opts.idle_time then
				start_idle()
			end
		end)
	)
end

function M.stop()
	stop_all()
	if idle_timer then
		idle_timer:stop()
		idle_timer:close()
		idle_timer = nil
	end
	vim.api.nvim_clear_autocmds({ group = "SpookyIdleDetect" })
	vim.schedule(function()
		vim.notify("spooky-idle stopped", vim.log.levels.INFO)
	end)
end

return M
