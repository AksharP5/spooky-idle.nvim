local M = {}
local uv = vim.uv
local current_proc
local playing = false
local loop_timer

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

local function get_sounds_dir()
	local base = debug.getinfo(1, "S").source:sub(2):match("(.*/)") or ""
	local local_path = vim.fn.expand("~/projects/plugins/spooky-idle.nvim/sounds")
	local lazy_path = vim.fn.stdpath("data") .. "/lazy/spooky-idle.nvim/sounds"
	if vim.fn.isdirectory(local_path) == 1 then
		return local_path
	elseif vim.fn.isdirectory(lazy_path) == 1 then
		return lazy_path
	else
		return base .. "../../sounds"
	end
end

local function play_file(path)
	local player = detect_player()
	if not player then
		vim.notify("spooky-idle: no audio player found", vim.log.levels.WARN)
		return
	end

	local args
	if player == "ffplay" then
		args = { "-nodisp", "-autoexit", "-loglevel", "quiet", path }
	elseif player == "mpv" then
		args = { "--no-video", "--really-quiet", "--no-terminal", "--idle=no", path }
	elseif player == "afplay" or player == "paplay" then
		args = { path }
	end

	if current_proc then
		pcall(function()
			current_proc:kill("sigterm")
		end)
		current_proc = nil
	end

	current_proc = vim.system({ player, unpack(args) }, { detach = true }, function()
		current_proc = nil
		if playing then
			loop_timer = uv.new_timer()
			if loop_timer then
				loop_timer:start(2000, 0, vim.schedule_wrap(M._loop))
			end
		end
	end)
end

function M._loop()
	if not playing then
		return
	end
	local sound_dir = get_sounds_dir()
	local pattern = sound_dir .. "/*.{ogg,mp3,wav,flac}"
	local files = vim.fn.glob(pattern, false, true)
	if #files == 0 then
		vim.notify("spooky-idle: No sounds found in " .. sound_dir, vim.log.levels.WARN)
		return
	end
	local f = files[math.random(#files)]
	play_file(f)
end

function M.play_random_loop(dir)
	if playing then
		return
	end
	playing = true
	M._dir = dir
	M._loop()
end

function M.stop()
	playing = false

	if loop_timer then
		loop_timer:stop()
		loop_timer:close()
		loop_timer = nil
	end

	if current_proc then
		pcall(function()
			current_proc:kill("sigterm")
		end)
		current_proc = nil
	end
end

return M
