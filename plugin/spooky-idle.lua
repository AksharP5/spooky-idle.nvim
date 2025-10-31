if vim.g.loaded_spooky_idle then
	return
end
vim.g.loaded_spooky_idle = true

vim.api.nvim_create_user_command("SpookyIdle", function(opts)
	local sub = opts.fargs[1]
	local spooky = require("spooky-idle.core")

	if sub == "start" then
		spooky.start()
	elseif sub == "stop" then
		spooky.stop()
	elseif sub == "toggle" then
		spooky.toggle()
	else
		vim.notify("Usage: :SpookyIdle [start|stop|toggle]", vim.log.levels.INFO)
	end
end, {
	nargs = "?",
	desc = "Start or stop the spooky idle haunt",
})
