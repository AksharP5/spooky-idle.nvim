local M = {}
local cfg = require("spooky-idle.config").get()

function M.start()
	vim.notify("spooky-idle haunting started for " .. cfg.idle_time .. "ms")
end

function M.stop()
	vim.notify("spooky-idle stopped")
end

function M.toggle()
	vim.notify("spooky-idle toggled")
end

return M
