local fs = require('src.fs')

return {
	run=function(args)
		if args:has_flag('global') then
			lib_path = os.getenv('HOME') .. '/.lcm/lib/'
		end

		local chunkfile_path = current_directory .. '/chunkfile.lua'
		local load_file = lib_path .. '/load.lua'
		local map_file = lib_path .. '/map.lua'

		if args:has_flag('deps') then
			for _, d in ipairs(fs.read_directory(lib_path)) do
				if d:is_directory() then
					print('removing "' .. tostring(d) .. '"')
					if not fs.remove_directory(lib_path .. '/' .. tostring(d)) then
						print('removing failed')
					end
				end
			end

			return
		end

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
			print('lib path removed.')
		end
	end,
	help={
		handle='clean',
		title='clean up LCM structures',
		flags={
			deps={
				desc='purge only library contents'
			},
			global={
				desc='runs a clean command on global depot'
			}
		}
	}
}