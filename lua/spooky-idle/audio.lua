local M = {}
local uv = vim.uv
local player, sound_proc
local playing = false

local function detect_player()
	local os = jit.os
	if os == "Linux" then
		if vim.fn.executable("paplay") == 1 then
			return "paplay"
		end
		if vim.fn.executable("ffplay") == 1 then
			return "ffplay"
		end
		if vim.fn.executable("mpv") == 1 then
			return "mpv"
		end
	elseif os == "OSX" then
		if vim.fn.executable("afplay") == 1 then
			return "afplay"
		end
		if vim.fn.executable("ffplay") == 1 then
			return "ffplay"
		end
		if vim.fn.executable("mpv") == 1 then
			return "mpv"
		end
	elseif os == "Windows" then
		if vim.fn.executable("ffplay") == 1 then
			return "ffplay"
		end
		if vim.fn.executable("mpv") == 1 then
			return "mpv"
		end
	end
	return nil
end

local function play_file(path)
	if not player then
		return
	end
	local cmd
	if player == "ffplay" then
		cmd = { "ffplay", "-nodisp", "-autoexit", "-loglevel", "quiet", path }
	elseif player == "mpv" then
		cmd = { "mpv", "--no-video", "--really-quiet", "--no-terminal", path }
	elseif player == "afplay" then
		cmd = { "afplay", path }
	elseif player == "paplay" then
		cmd = { "paplay", path }
	end
	if cmd then
		sound_proc = vim.system(cmd, { detach = true })
	end
end

function M.play_random_loop(dir)
	if playing then
		return
	end
	player = detect_player()
	if not player then
		vim.notify("spooky-idle: No audio player found", vim.log.levels.WARN)
		return
	end
	playing = true
	local sound_dir = dir or (debug.getinfo(1, "S").source:sub(2):match("(.*/)") .. "../sounds")
	local expanded = vim.fn.expand(sound_dir)
	local pattern = expanded .. "/*.{ogg,mp3,wav,flac}"
	local files = vim.fn.glob(pattern, false, true)
	if #files == 0 then
		vim.notify("spooky-idle: No sounds found in " .. expanded, vim.log.levels.WARN)
		return
	end
	local function loop()
		if not playing then
			return
		end
		local f = files[math.random(#files)]
		play_file(f)
		local timer = uv.new_timer()
		if not timer then
			return
		end
		timer:start(15000, 0, vim.schedule_wrap(loop))
	end
	loop()
end

function M.stop()
	playing = false
	if sound_proc and sound_proc.kill then
		sound_proc:kill("sigterm")
	end
	sound_proc = nil
end

return M
