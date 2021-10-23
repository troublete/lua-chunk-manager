local fs = require('src.fs')
local requires = require('src.requires')

return {
	run=function(args)
		if args:has_flag('global') then
			current_directory = os.getenv('HOME') .. '/.lcm/'
		end

		requires:unsilence()

		if args:has_flag('silent') then
			requires:silence()
		end

		if args:has_flag('deps') then
			requires:removed_dependencies(current_directory)
			return
		end

		if args:has_flag('bins') then
			requires:removed_bin_directory(current_directory)
			return
		end

		requires:removed_bin_directory(current_directory)
		requires:removed_lib_directory(current_directory)
		requires:removed_chunkfile(current_directory)
	end,
	help={
		handle='clean',
		title='clean up lcm structures',
		flags={
			deps={
				desc='remove retrieved dependencies'
			},
			global={
				desc='run in global lcm depot'
			},
			silent={
				desc='ommits any output'
			},
			bins={
				desc='remove only executables'
			}
		}
	}
}