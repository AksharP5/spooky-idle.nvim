local M = {}
local player

local function is_exec(cmd)
	return vim.fn.executable(cmd) == 1
end

local function detect_player()
	local os = jit.os
	if os == "Linux" then
		if is_exec("paplay") then
			return "paplay"
		end
		if is_exec("ffplay") then
			return "ffplay"
		end
	elseif os == "OSX" then
		if is_exec("afplay") then
			return "afplay"
		end
	elseif os == "Windows" then
		if is_exec("ffplay") then
			return "ffplay"
		end
	end
end

function M.setup()
	player = detect_player()
	if not player then
		vim.notify("spooky-idle: no audio player found", vim.log.levels.WARN)
	end
end

---@param cfg spookyidle.Config
function M.play_random(cfg)
	if not player or not cfg.sound_enabled then
		return
	end
	local dir = cfg.sound_dir or (vim.fn.stdpath("data") .. "/spooky-idle/sounds")
	local files = vim.fn.glob(dir .. "/*.{mp3, ogg, wav}", false, true)
	if #files == 0 then
		return
	end
	local file = files[math.random(#files)]
	vim.system({ player, file }, { detach = true })
end

return M
