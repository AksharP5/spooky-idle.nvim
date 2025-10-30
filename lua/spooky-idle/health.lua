local health = vim.health
local M = {}

function M.check()
	health.report_start("spooky-idle.nvim")

	local ok, cfg = pcall(require, "spooky-idle.config")
	if ok then
		health.report_ok("Config loaded")
	else
		health.report_error("Config failed: " .. cfg)
	end

	local dir = (require("spooky-idle.config").get()).sound_dir
	if dir and vim.fn.isdirectory(dir) == 0 then
		health.report_warn("Sound directory not found: " .. dir)
	else
		health.report_ok("Sound directory present")
	end
end

return M
