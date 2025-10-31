if vim.g.loaded_spooky_idle then
	return
end
vim.g.loaded_spooky_idle = true

local spooky = require("spooky-idle.core")
local state = require("spooky-idle.state")

vim.api.nvim_create_user_command("SpookyIdleStart", function()
	spooky.start()
	state.save({ enabled = true })
end, { desc = "Start spooky-idle" })

vim.api.nvim_create_user_command("SpookyIdleStop", function()
	spooky.stop()
	state.save({ enabled = false })
end, { desc = "Stop spooky-idle" })

vim.api.nvim_create_user_command("SpookyIdleStatus", function()
	local msg = spooky.is_active() and "spooky-idle: active" or "spooky-idle: stopped"
	vim.notify(msg, vim.log.levels.INFO)
end, { desc = "Show spooky-idle status" })

local last_state = state.load()
if last_state.enabled then
	spooky.start()
else
	vim.schedule(function()
		vim.notify("spooky-idle is disabled (previous session)", vim.log.levels.INFO)
	end)
end
