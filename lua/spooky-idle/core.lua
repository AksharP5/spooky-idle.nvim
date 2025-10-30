local M = {}
local cfg = require("spooky-idle.config")
local overlay = require("spooky-idle.overlay")
local audio = require("spooky-idle.audio")
local timer = require("spooky-idle.timer")

local cfg
local active = false

function M.start()
	if active then
		vim.notify("spooky-idle already running", vim.log.levels.INFO)
		return
	end
	cfg = config.get()
	audio.setup()

	vim.api.nvim_create_autocmd("VimLeavePre", {
		once = true,
		callback = M.stop,
	})

	timer.start(function()
		local ok_overlay = pcall(overlay.dim, cfg)
		local ok_audio = pcall(audio.play_random, cfg)
		if not ok_overlay then
			vim.notify("spooky-idle: overlay failed", vim.log.levels.ERROR)
		end
		if not ok_audio then
			vim.notify("spooky-idle: audio failed", vim.log.levels.ERROR)
		end
		vim.defer_fn(overlay.clear, 3000)
	end, cfg.idle_time)

	active = true
	vim.notify("spooky-idle haunting started", vim.log.levels.INFO)
end

function M.stop()
	if not active then
		vim.notify("spooky-idle not running", vim.log.levels.WARN)
		return
	end
	timer.stop()
	overlay.clear()
	active = false
	vim.notify("spooky-idle stopped", vim.log.levels.INFO)
end

function M.toggle()
	if active then
		M.stop()
	else
		M.start()
	end
end

return M
