local M = {}
local config = require("spooky-idle.config")
local overlay = require("spooky-idle.overlay")
local audio = require("spooky-idle.audio")
local timer = require("spooky-idle.timer")

local active = false
local cfg

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
		overlay.dim(cfg)
		audio.start(cfg)
	end, function()
		overlay.clear()
		audio.stop()
	end, cfg.idle_time)

	active = true
	vim.notify("spooky-idle started", vim.log.levels.INFO)
end

function M.stop()
	if not active then
		vim.notify("spooky-idle not running", vim.log.levels.WARN)
		return
	end
	timer.stop()
	overlay.clear()
	audio.stop()
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
