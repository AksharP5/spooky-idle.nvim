---@class spookyidle.Config
---@field idle_time? integer
---@field dim_level? integer
---@field sound_enabled? boolean
---@field image_enabled? boolean

---@type spookyidle.Config
local defaults = {
	idle_time = 10000,
	dim_level = 60,
	sound_enabled = true,
	image_enabled = true,
}

local M = {}

---@return spookyidle.Config
function M.get()
	local user = type(vim.g.spooky_idle) == "function" and vim.g.spooky_idle() or vim.g.spooky_idle or {}
	return vim.tbl_deep_extend("force", defaults, user)
end

return M
