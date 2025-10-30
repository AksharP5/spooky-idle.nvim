local M = {}
local uv = vim.loop
local idle_timer
local last_activity = uv.now()
local is_idle = false

function M.start(on_idle, on_active, delay)
	if idle_timer then
		idle_timer:stop()
	end
	idle_timer = uv.new_timer()

	local function reset_activity()
		last_activity = uv.now()
		if is_idle then
			is_idle = false
			vim.schedule(on_active)
		end
	end

	vim.on_key(function()
		reset_activity()
	end)
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		callback = reset_activity,
	})

	idle_timer:start(1000, 1000, function()
		local elapsed = uv.now() - last_activity
		if not is_idle and elapsed > delay then
			is_idle = true
			vim.schedule(on_idle)
		end
	end)
end

function M.stop()
	if idle_timer then
		idle_timer:stop()
	end
	is_idle = false
end

return M
