local M = {}
local timer = require("spooky-idle.timer")
local overlay = require("spooky-idle.overlay")
local audio = require("spooky-idle.audio")

local config = {
	idle_time = 10000,
	dim_level = 70,
	sound_enabled = true,
	sound_dir = nil,
}

local idle = false

function M.start(opts)
	config = vim.tbl_extend("force", config, opts or {})
	if idle then
		return
	end

	idle = true
	vim.notify("Spooky Idle started...", vim.log.levels.INFO)

	timer.start(config.idle_time, function()
		overlay.start(config.dim_level)
		if config.sound_enabled then
			audio.play_random_loop(config.sound_dir)
		end
	end)

	vim.on_key(function()
		if idle then
			M.stop()
		end
	end)
end

function M.stop()
	if not idle then
		return
	end
	idle = false
	overlay.clear()
	audio.stop()
	timer.stop()
	vim.notify("Spooky Idle stopped", vim.log.levels.INFO)
end

function M.toggle()
	if idle then
		M.stop()
	else
		M.start()
	end
end

return M
