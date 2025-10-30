if vim.g.loaded_spooky_idle then
	return
end
vim.g.loaded_spooky_idle = true

vim.api.nvim_create_user_command("SpookyIdle", function(opts)
	local core = require("spooky-idle.core")
	local arg = opts.args
	if arg == "start" then
		core.start()
	elseif arg == "stop" then
		core.stop()
	elseif arg == "toggle" then
		core.toggle()
	else
		vim.notify("Usage: :SpookyIdle [start|stop|toggle]", vim.log.levels.INFO)
	end
end, { nargs = 1 })
