local fs = require('src.fs')

return {
	run=function(args)
		if args:has_flag('global') then
			lib_path = os.getenv('HOME') .. '/.lcm/lib/'
		end

		if fs.is_directory(lib_path) then
			print('lib path exists.')
		else
			if fs.create_path(lib_path) then
				print('lib path created.')
			else
				print('lib path could not be created.')
			end
		end

		if not args:has_flag('global') and not args:has_flag('loader') then
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
		end

		local load_file = lib_path .. '/load.lua'
		if fs.is_file(load_file) then
			print('loader exists.')
		else
			if fs.copy_file(lcm_directory .. '/tpl/load.lua', load_file) then
				print('loader created.')
			else
				print('loader could not be created.')
			end
		end

		if not args:has_flag('loader') then
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
	end,
	help={
		handle='init',
		title='setup a LCM module',
		flags={
			global={
				desc='sets up global LCM depot'
			},
			loader={
				desc='only create loader path'
			}
		}
	}
}