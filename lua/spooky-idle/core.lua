local overlay = require("spooky-idle.overlay")
local audio = require("spooky-idle.audio")

local M = {}
local uv = vim.uv
local idle_timer
local active = false
local last_activity = uv.now()
local opts = {
	idle_time = 10000, -- 10 minutes default
	dim_level = 70,
	sound_enabled = true,
	sound_dir = nil,
}

function M.setup(user_opts)
	opts = vim.tbl_deep_extend("force", opts, user_opts or {})
end

local function instant_stop()
	vim.schedule(function()
		if active then
			active = false
			overlay.hide()
			audio.stop()
		end
	end)
end

local function mark_active()
	last_activity = uv.now()
	if active then
		instant_stop()
	end
end

local function on_idle()
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
		{
			group = group,
			callback = function()
				mark_active()
			end,
		}
	)

	vim.on_key(function()
		mark_active()
	end, group)
	if vim.on_input then
		vim.on_input(function()
			mark_active()
		end)
	end

	idle_timer = uv.new_timer()
	if not idle_timer then
		vim.notify("spooky-idle: failed to create timer", vim.log.levels.ERROR)
		return
	end

	idle_timer:start(
		0,
		500,
		vim.schedule_wrap(function()
			if not active and uv.now() - last_activity >= opts.idle_time then
				on_idle()
			end
		end)
	)

	vim.notify("spooky-idle started")
end

function M.stop()
	if idle_timer then
		idle_timer:stop()
		idle_timer:close()
		idle_timer = nil
	end
	vim.api.nvim_clear_autocmds({ group = "SpookyIdleDetect" })
	instant_stop()
	vim.notify("spooky-idle stopped")
end

return M
