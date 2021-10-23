local requires = require('src.requires')
local log = require('src.log')()
local fs = require('src.fs')

return {
	run=function(args)
		if args:has_flag('global') then
			current_directory = os.getenv('HOME') .. '/.lcm/'
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
	end,
	help={
		handle='init',
		title='setup a lcm chunk (create directories and files required)',
		flags={
			silent={
				desc='ommits any output'
			},
			global={
				desc='sets up global lcm depot'
			},
			loader={
				desc='only create load.lua (e.g. for loading only global libs)'
			},
			chunkfile={
				desc='only create chunkfile.lua'
			}
		}
	}
}