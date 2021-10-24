local fs = require('src.fs')
local requires = require('src.requires')
local log = require('src.log')()

return {
	run=function(args)
		if args:has_flag('global') then
			current_directory = os.getenv('HOME') .. '/.lcm/'
		end

		local _, map_path = requires:mapfile(current_directory)

		local sandbox = {}

		function sandbox.module(params)
			local namespace, path = table.unpack(params)

			if not args:has_flag('only-load') then
				if args:has_flag('path') then
					log:print('module', namespace, path)
				else
					log:print('module', namespace)
				end
			end
		end

		function sandbox.load(params)
			local namespace, path = table.unpack(params)

			if args:has_flag('with-load') or args:has_flag('only-load') then
				if args:has_flag('path') then
					log:print('load', namespace, path)
				else
					log:print('load', namespace)
				end
			end
		end

		local map = loadfile(map_path, 't', sandbox)
		if map then
			map()
		end
	end,
	help={
		handle='list',
		title='show a list of installed libs',
		flags={
			global={
				desc='run in global lcm depot'
			},
			path={
				desc='show source path'
			},
			['with-load']={
				desc='includes export in the list'
			},
			['only-load']={
				desc='list contains only exports'
			}
		}
	}
}