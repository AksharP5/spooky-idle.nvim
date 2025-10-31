local M = {}

function M.check()
	vim.health.start("spooky-idle.nvim")
	if vim.fn.has("nvim-0.10") == 0 then
		vim.health.error("Requires Neovim 0.10 or higher")
	else
		vim.health.ok("Neovim version is sufficient")
	end
	local players = { "paplay", "afplay", "ffplay", "mpv" }
	local found = false
	for _, p in ipairs(players) do
		if vim.fn.executable(p) == 1 then
			vim.health.ok("Audio player found: " .. p)
			found = true
			break
		end
	end
	if not found then
		vim.health.warn("No audio player found (paplay, ffplay, afplay, mpv)")
	end
end

return M
