local requires = require('src.requires')
local strategies = require('src.strategies')
local plan = require('src.plan')
local log = require('src.log')()
local fs = require('src.fs')
local template = require('src.template')

local cmd = require('src.command')('install', 'process chunkfile; install requirements', function(args)
	if args:has_flag('global') then
		current_directory = lcm_home
	end

	strategies:set_current_directory(current_directory)

	if args:has_flag('debug') then
		requires:unsilence()
	end

	if args:has_flag('silent') then
		log:silence()
		plan:silence()
		strategies:silence()
	end

	if args:has_flag('env') then
		plan:set_env(args.named_args.env)
		log:print(string.format('running in "%s" environment', args.named_args.env))
	end

	local _, chunkfile_path = requires:chunkfile(current_directory)

	-- set allowed functions
	local sandbox = {}

	-- ignore all not defined functions
	setmetatable(sandbox, {__index=function() return function() end end})

	function sandbox.github(args)
		plan:add('github', args)
	end
	function sandbox.symlink(args)
		plan:add('symlink', args)
	end
	function sandbox.bin(args)
		plan:add('bin', args)
	end

	local run_chunkfile = loadfile(chunkfile_path, 't', sandbox)
	if not run_chunkfile then
		log:error(string.format('"%s" can not be read', chunkfile_path))
	end
	run_chunkfile()

	plan:each(function(strategy, namespace, args)
		local namespace_path = strategies:call(strategy, namespace, args)

		if namespace_path then
			-- register module in load file
			local _, map_path = requires:mapfile(current_directory)

			if not fs.append_to_file(map_path, template.module_instruction(namespace, namespace_path)) then
				log:error(string.format('library registration for "%s" failed', namespace))
			else
				log:print(string.format('library "%s" registered', namespace))
			end

			-- extend plan if dependency contains a chunkfile
			-- and acknowledge exports
			local code, chunkfile_path = requires:chunkfile(namespace_path, true) 

			local function export(args)
				local file, name = table.unpack(args)

				if name then
					namespace = namespace .. '.' .. name
				end

				if not fs.append_to_file(map_path, template.load_instruction(namespace, namespace_path .. '/' .. file)) then
					log:error(string.format('export registration for "%s" failed', namespace))
				else
					log:print(string.format('export "%s" for "%s" registered', name or file, namespace))
				end				
			end

			-- allow both names
			sandbox.export = export
			sandbox.exports = export

			if code == requires.EXISTS then
				local run_child_chunkfile = loadfile(chunkfile_path, 't', sandbox)
				if run_child_chunkfile then
					run_child_chunkfile()
				end
			end
		end
	end)
end)

cmd:add_flag('global', 'run command in LCM_HOME')
cmd:add_flag('silent', 'omit any output')
cmd:add_flag('debug', 'enrich output with debug information')

return cmd