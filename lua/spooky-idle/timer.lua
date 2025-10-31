local M = {}
local uv = vim.uv
local idle_timer

function M.start(timeout, callback)
	M.stop()
	local t = uv.new_timer()
	if not t then
		vim.notify("spooky-idle: failed to create timer", vim.log.levels.ERROR)
		return
	end
	idle_timer = t
	idle_timer:start(timeout, 0, vim.schedule_wrap(callback))
end

function M.stop()
	if idle_timer then
		idle_timer:stop()
		idle_timer:close()
		idle_timer = nil
	end
end

return M
