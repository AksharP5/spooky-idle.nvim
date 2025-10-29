---@class spookyidle.Subcommand
---@field impl fun(args: string[], opts: table)
---@field complete? fun(arg_lead: string): string[]

---@type table<string, spookyidle.Subcommand>
local subcommands = {
	start = {
		impl = function()
			require("spooky-idle.core").start()
		end,
	},
	stop = {
		impl = function()
			require("spooky-idle.core").stop()
		end,
	},
	toggle = {
		impl = function()
			require("spooky-idle.core").toggle()
		end,
	},
}

local M = {}

---@param opts table
function M.run(opts)
	local fargs = opts.fargs
	local sub = fargs[1]
	if not sub or not subcommands[sub] then
		vim.notify("spooky-idle: unknown subcommand", vim.log.levels.ERROR)
		return
	end
	subcommands[sub].impl(fargs, opts)
end

function M.complete(arg_lead, cmdline)
	return vim.tbl_filter(function(k)
		return k:find(arg_lead) ~= nil
	end, vim.tbl_keys(subcommands))
end

return M
