local fs = require('src.fs')

local util = {}

function util.download_and_unpack(url, target, user)
	local archive_file = target .. '/archive.tar'

	local ok = false
	if user then
		ok = os.execute('curl -u ' .. user .. ' -sL ' .. url .. ' > ' .. archive_file)
	else
		ok = os.execute('curl -sL ' .. url .. ' > ' .. archive_file)
	end

	if not ok then
		print('download failed')
		return false
	end

	if not os.execute('tar -xzf ' .. archive_file .. ' -C ' .. target) then
		print('unpack failed')
		return false
	end

	if not fs.remove_file(archive_file) then
		print('archive removal failed')
		return false
	end

	local archive_root = fs.read_directory(target)[1]
	if not os.execute('mv ' .. target .. '/' .. tostring(archive_root) .. '/* ' .. target) then
		print('move failed')
		return false
	end

	if not fs.remove_directory(target .. '/' .. tostring(archive_root)) then
		print('removal failed')
		return false
	end

	return true
end

function util.p(...)
	print(table.concat(table.pack(...), ' '))
end

function util.quote(str)
	return '"' .. str .. '"'
end

function util.tpl_instruction_load(handle, path)
	return 'load {\'' .. handle .. '\', \'' .. path .. '\' }'
end

function util.tpl_instruction_module(handle, path)
	return 'module {\'' .. handle .. '\', \'' .. path .. '\' }'
end

return util