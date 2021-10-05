local fs = require('src.fs')

return function()
	local chunkfile_path = current_directory .. '/chunkfile.lua'
	local load_file = lib_path .. '/load.lua'
	local map_file = lib_path .. '/map.lua'

	if fs.remove_file(chunkfile_path) then
		print('chunkfile removed.')
	end

	if fs.remove_file(load_file) then
		print('loadfile removed.')
	end

	if fs.remove_file(map_file) then
		print('mapfile removed.')
	end

	if fs.remove_directory(lib_path) then
		print('lib directory removed.')
	end
end