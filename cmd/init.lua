local requires = require('src.requires')
local log = require('src.log')()
local fs = require('src.fs')

local cmd = require('src.command')('init', 'initialize chunk', function(args)
	if args:has_flag('global') then
		current_directory = lcm_home
	end

	requires:unsilence()

	if args:has_flag('silent') then
		requires:silence()
		log:silence()
	end

	if not args:has_flag('loader') then
		local code, path = requires:chunkfile(current_directory)

		if code ~= requires.EXISTS then
			local content = fs.get_file_content(lcm_directory .. '/tpl/chunkfile.lua')
			fs.put_file_content(path, content)
			log:print(string.format('"%s" written', path))
		end
	end

	if not args:has_flag('loader') and not args:has_flag('chunkfile') then
		local code, path = requires:mapfile(current_directory)

		if code ~= requires.EXISTS then
			local content = fs.get_file_content(lcm_directory .. '/tpl/map.lua')
			fs.put_file_content(path, content)
			log:print(string.format('"%s" written', path))
		end
	end

	if not args:has_flag('chunkfile') then
		local code, path = requires:loader(current_directory)

		if code ~= requires.EXISTS then
			local content = fs.get_file_content(lcm_directory .. '/tpl/load.lua')
			fs.put_file_content(path, content)
			log:print(string.format('"%s" written', path))
		end
	end
end)

cmd:add_flag('global', 'run command in LCM_HOME')
cmd:add_flag('silent', 'omit any output')
cmd:add_flag('loader', 'create only lib/load.lua')
cmd:add_flag('chunkfile', 'create only chunkfile.lua')

return cmd