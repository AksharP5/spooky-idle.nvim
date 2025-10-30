local M = {}

---@class spookyidle.Config
---@field idle_time integer
---@field sound_enabled boolean
---@field sound_dir string|nil
---@field dim_level integer

local defaults = {
	idle_time = 10000, -- milliseconds before idle
	sound_enabled = true,
	sound_dir = nil, -- uses built-in sounds if nil
	dim_level = 70,
}

local cfg = vim.tbl_deep_extend("force", {}, defaults)

function M.setup(user_opts)
	if user_opts then
		cfg = vim.tbl_deep_extend("force", cfg, user_opts)
	end
end

function M.get()
	return cfg
end

return M
