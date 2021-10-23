local fs = require('src.fs')
local requires = require('src.requires')
local log = require('src.log')()
local template = require('src.template')
local util = require('src.util')

local function rebuild_mapfile(current_directory, instructions)
	requires:removed_mapfile(current_directory)
	local _, mapfile_path = requires:mapfile(current_directory)

	local content = fs.get_file_content(lcm_directory .. '/tpl/map.lua')
	fs.put_file_content(mapfile_path, content)

	if not fs.append_to_file(mapfile_path, '\n' .. table.concat(instructions, '\n')) then
		log:error(string.format('error during mapfile rebuild'))
	else
		log:print(string.format('mapfile written'))
	end
end

return {
	run=function(args)
		if args:has_flag('global') then
			current_directory = os.getenv('HOME') .. '/.lcm/'
		end

		if args:has_flag('silent') then
			log:silence()
		end

		if args:has_flag('debug') then
			requires:unsilence()
		end

		if args:has_flag('lib') then
			local code, lib_path = requires:lib_directory(current_directory, true)
			if code ~= requires.EXISTS then
				log:error(string.format('"%s" does not exist', lib_path))
			end

			local code, map_path = requires:mapfile(current_directory, true)
			if code ~= requires.EXISTS then
				log:error(string.format('"%s" does not exist', map_path))
			end

			local code, chunkfile_path = requires:chunkfile(current_directory, true)
			if code ~= requires.EXISTS then
				log:error(string.format('"%s" does not exist', map_path))
			end

			local instructions = {}

			local registered_modules = {}
			local registered_loads = {}

			local required_modules = {}

			local chunkfile_sandbox = {}
			setmetatable(chunkfile_sandbox, {__index=function(_, name)
				return function(args)
					if name ~= 'bin' then
						local namespace = (args.namespace or args[1])
						if not namespace then
							log:error(string.format('invalid instruction "%s"', name))
						end

						required_modules[namespace] = true
					end
				end
			end})

			local map_sandbox = {}
			setmetatable(map_sandbox, {__index=function() return function() end end})

			function map_sandbox.module(args)
				local namespace, path = table.unpack(args)

				local code, chunkfile_path = requires:chunkfile(path, true)
				if code == requires.EXISTS then
					local ccf = loadfile(chunkfile_path, 't', chunkfile_sandbox)
					if ccf then
						ccf()
					end
				end

				registered_modules[namespace] = path
			end

			function map_sandbox.load(args)
				local namespace, path = table.unpack(args)
				registered_loads[namespace] = path
			end

			local mf = loadfile(map_path, 't', map_sandbox)
			if mf then
				mf()
			else
				log:error(string.format('mapfile invalid'))
			end

			local cf = loadfile(chunkfile_path, 't', chunkfile_sandbox)
			if cf then
				cf()
			else
				log:error(string.format('chunkfile invalid'))
			end

			for namespace, path in pairs(registered_modules) do
				local missing, not_required = false, false

				if not required_modules[namespace] then
					not_required = true
				end

				if not fs.is_directory(path) then
					missing = true
				end

				if missing or not_required then
					log:print(string.format('removing "%s"', namespace))
					registered_modules[namespace] = nil

					if fs.is_directory(path) then
						requires:removed_directory(path)
					end

					if fs.is_symlink(path) then
						requires:removed_file(path)
					end
				else
					table.insert(instructions, template.module_instruction(namespace, path))
				end
			end

			for namespace, load_path in pairs(registered_loads) do
				local module_removed = false

				if #registered_modules == 0 then
					module_removed = true
				end

				for module_namespace, module_path in pairs(registered_modules) do
					if namespace:match(util.pattern_escape(module_namespace)) and module_path == nil then
						module_removed = true
					end
				end

				if not module_removed then
					table.insert(instructions, template.load_instruction(namespace, load_path))
				end
			end

			rebuild_mapfile(current_directory, instructions)
		end
	end,
	help={
		handle='fix',
		title='fixes certain aspects of the LCM setup',
		flags={
			global={
				desc='runs fix in global depot'
			},
			silent={
				desc='omits all output'
			},
			debug={
				desc='extends output to be more intelligble'
			},
			lib={
				desc='removed not needed deps (removed from chunkfile), rebuilds map'
			}
		}

	}
}