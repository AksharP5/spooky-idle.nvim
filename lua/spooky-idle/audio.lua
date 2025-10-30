local M = {}
local player
local current_job
local haunting = false
local uv = vim.loop

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

local function get_sound_dir(cfg)
	local plugin_dir = debug.getinfo(1, "S").source:sub(2)
	plugin_dir = vim.fn.fnamemodify(plugin_dir, ":h:h:h")
	local default_dir = plugin_dir .. "/sounds"
	local dir = cfg.sound_dir and vim.fn.expand(cfg.sound_dir) or default_dir
	return dir
end

local function play_random_sound(cfg)
	if not player or not cfg.sound_enabled then
		return
	end
	local dir = get_sound_dir(cfg)
	local files = vim.fn.glob(dir .. "/*.{mp3,ogg,wav}", false, true)
	if #files == 0 then
		vim.notify("spooky-idle: no sounds found in " .. dir, vim.log.levels.WARN)
		return
	end

	local file = files[math.random(#files)]
	local cmd
	if player == "ffplay" then
		cmd = { "ffplay", "-nodisp", "-autoexit", "-v", "quiet", file }
	elseif player == "afplay" then
		cmd = { "afplay", file }
	elseif player == "paplay" then
		cmd = { "paplay", file }
	end

	current_job = vim.system(cmd, {
		detach = false,
		on_exit = function()
			if haunting then
				vim.schedule(function()
					play_random_sound(cfg)
				end)
			end
		end,
	})
end

function M.start(cfg)
	if haunting then
		return
	end
	haunting = true
	play_random_sound(cfg)
end

function M.stop()
	haunting = false
	if current_job and not current_job:is_closing() then
		current_job:kill(9)
	end
end

return M
