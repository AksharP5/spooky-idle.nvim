if vim.g.loaded_spooky_idle then
	return
end
vim.g.loaded_spooky_idle = true

vim.schedule(function()
	local ok, spooky = pcall(require, "spooky-idle.core")
	if not ok or type(spooky.start) ~= "function" then
		return
	end

	spooky.start()

	vim.api.nvim_create_user_command("SpookyIdleStart", function()
		spooky.start()
	end, { desc = "Start spooky-idle manually" })

	vim.api.nvim_create_user_command("SpookyIdleStop", function()
		spooky.stop()
	end, { desc = "Stop spooky-idle" })

	vim.api.nvim_create_user_command("SpookyIdleToggle", function()
		if spooky.is_active() then
			spooky.stop()
		else
			spooky.start()
		end
	end, { desc = "Toggle spooky-idle" })
end)
