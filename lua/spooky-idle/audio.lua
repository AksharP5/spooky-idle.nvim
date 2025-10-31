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

	if current_proc and current_proc:is_active() then
		current_proc:kill("sigterm")
		current_proc = nil
	end

	current_proc = uv.spawn(player, {
		args = args,
		cwd = vim.loop.cwd() or vim.fn.getcwd(),
		env = vim.fn.environ(),
		detached = false,
	}, function()
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
	local sound_dir = M._dir or (debug.getinfo(1, "S").source:sub(2):match("(.*/)") .. "../../sounds")
	local expanded = vim.fn.expand(sound_dir)
	local pattern = expanded .. "/*.{ogg,mp3,wav,flac}"
	local files = vim.fn.glob(pattern, false, true)
	if #files == 0 then
		vim.notify("spooky-idle: No sounds found in " .. expanded, vim.log.levels.WARN)
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
	if current_proc and current_proc:is_active() then
		current_proc:kill("sigterm")
		current_proc = nil
	end
end

return M
