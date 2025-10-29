if vim.g.loaded_spooky_idle then
	return
end
vim.g.loaded_spooky_idle = true

vim.api.nvim_create_user_command("SpookyIdle", function(opts)
	require("spooky-idle.command").run(opts)
end, {
	nargs = "+",
	desc = "Control spooky-idle.nvim",
	complete = function(arg_lead, cmdline, _)
		return require("spooky-idle.command").complete(arg_lead, cmdline)
	end,
})
