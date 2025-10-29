local health = vim.health
local M = {}

function M.check()
	health.report_start("spooky-idle.nvim")
	local ok = pcall(require, "spooky-idle.config")
	if ok then
		health.report_ok("Config OK")
	else
		health.report_error("Config failed")
	end
end

return M
