local uv = vim.uv
local state = {}
local state_file = vim.fn.stdpath("state") .. "/spooky-idle/state.json"

function state.load()
	local fd = uv.fs_open(state_file, "r", 438)
	if not fd then
		return { enabled = true }
	end

	local stat = uv.fs_fstat(fd)
	if not stat or stat.size == 0 then
		uv.fs_close(fd)
		return { enabled = true }
	end

	local data = uv.fs_read(fd, stat.size, 0)
	uv.fs_close(fd)

	if not data or data == "" then
		return { enabled = true }
	end

	local ok, decoded = pcall(vim.json.decode, data)
	if not ok or type(decoded) ~= "table" or decoded.enabled == nil then
		return { enabled = true }
	end

	return decoded
end

function state.save(tbl)
	uv.fs_mkdir(vim.fn.fnamemodify(state_file, ":h"), 511)
	local fd = uv.fs_open(state_file, "w", 438)
	if not fd then
		return
	end
	uv.fs_write(fd, vim.json.encode(tbl or { enabled = true }))
	uv.fs_close(fd)
end

return state
