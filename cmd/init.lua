local fs = require('src.fs')

return function()
	if fs.is_directory(lib_path) then
		print('lib path exists.')
	else
		if fs.create_path(lib_path) then
			print('lib path created.')
		else
			print('lib path could not be created.')
		end
	end

	local chunkfile_path = current_directory .. '/chunkfile.lua'
	if fs.is_file(chunkfile_path) then
		print('chunkfile exists.')
	else
		if fs.copy_file(lcm_directory .. '/tpl/chunkfile.lua', current_directory .. '/chunkfile.lua') then
			print('chunkfile created.')
		else
			print('chunkfile could not be created.')
		end
	end

	local load_file = lib_path .. '/load.lua'
	if fs.is_file(load_file) then
		print('loader exists.')
	else
		if fs.touch(load_file) then
			print('loader created.')
		else
			print('loader could not be created.')
		end
	end

	local map_file = lib_path .. '/map.lua'
	if fs.is_file(map_file) then
		print('mapfile exists.')
	else
		if fs.touch(map_file) then
			print('mapfile created.')
		else
			print('mapfile could not be created.')
		end
	end
end