local fs = require('src.fs')
local requires = require('src.requires')

local cmd = require('src.command')('clean', 'clean/purge chunk files and structures', function(args)
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
end)

cmd:add_flag('deps', 'purge installed requirements')
cmd:add_flag('global', 'run command in LCM_HOME')
cmd:add_flag('silent', 'omit any output')
cmd:add_flag('bins', 'purge installed executables')

return cmd
