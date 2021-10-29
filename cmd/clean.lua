local fs = require('src.fs')
local requires = require('src.requires')
local log = require('src.log')()

local cmd = require('src.command')('clean', 'clean/purge chunk files and structures', function(args)
	if args:has_flag('global') then
		current_directory = lcm_home
	end

	requires:unsilence()

	if args:has_flag('silent') then
		requires:silence()
		log:silence()
	end

	if args:has_flag('lib') then
		requires:removed_dependencies(current_directory)
		return
	end

	if args:has_flag('bin') then
		local _, bin_path = requires:bin_directory(current_directory, true)
		for _, entry in pairs(fs.read_directory(bin_path)) do
			local e = tostring(entry)
			if e ~= 'lcm.tpl.txt' and e ~= 'lcm' then
				requires:removed_file(bin_path .. '/' .. e)
			end
		end
		return
	end

	-- we need to assure that globally the lcm exec can not be
	-- removed
	if not args:has_flag('global') then
		requires:removed_bin_directory(current_directory)
		requires:removed_lib_directory(current_directory)
	else
		log:print(string.format('removing "lib" and "bin" in global scope not possible. moving on.'))
	end

	requires:removed_chunkfile(current_directory)
end)

cmd:add_flag('lib', 'purge installed requirements')
cmd:add_flag('global', 'run command in LCM_HOME')
cmd:add_flag('silent', 'omit any output')
cmd:add_flag('bin', 'purge installed executables')

return cmd
