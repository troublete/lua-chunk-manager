local fs = require('src.fs')
local util = require('src.util')

local strategies = {}

-- curl is pre-registered out-of-the box; but also a good example
-- the first argument passed to ANY registered strategy is always the 
-- lib path of the current project; after that all args passed to the
-- chunkfile 'call' i.e. git {}; are passed in in order
function strategies.curl(lib_path, handle, url, user)
	local path = lib_path .. '/' .. handle

	if fs.is_directory(path) then
		print('"' .. handle .. '" already retrieved.')
		return
	end

	if not fs.create_path(path) then
		print('directory for "' .. handle .. '" can not be created.')
	end

	if util.download_and_unpack(url, path, user) then
		print('"' .. handle .. '" retrieved.')
	end

	-- it is required that a strategy returns the target path, since
	-- this will be used to build the loader later
	return path 
end

function strategies.github(lib_path, handle)
	return strategies.curl(lib_path, handle, 'http://github.com/' .. handle .. '/tarball/master')
end

function strategies.private_github(lib_path, handle, user)
	return strategies.curl(lib_path, handle, 'http://github.com/' .. handle .. '/tarball/master', user)
end

return strategies