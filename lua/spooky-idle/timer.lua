local M = {}
local uv = vim.loop
local idle_timer
local last_activity = uv.now()

---@paramcb fun()
---@param delay integer
function M.start(cb, delay)
	if idle_timer then
		idle_timer:stop()
	end
	idle_timer = uv.new_timer()

	vim.on_key(function()
		last_activity = uv.now()
	end)
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		callback = function()
			last_activity = uv.now()
		end,
	})

	idle_timer:start(1000, 1000, function()
		local elapsed = uv.now() - last_activity
		if elapsed > delay then
			vim.schedule(cb)
			last_activity = uv.now()
		end
	end)
end

function M.stop()
	if idle_timer then
		idle_timer:stop()
	end
end

return M
