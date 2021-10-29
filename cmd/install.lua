local requires = require('src.requires')
local strategies = require('src.strategies')
local plan = require('src.plan')
local log = require('src.log')()
local fs = require('src.fs')
local template = require('src.template')

local cmd = require('src.command')('install', 'process chunkfile; install requirements', function(args)
	local runtime_args = args

	if args:has_flag('global') then
		current_directory = lcm_home
	end

	strategies:set_current_directory(current_directory)
	strategies:set_runtime_args(args)

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
		return plan:add('github', args)
	end

	function sandbox.symlink(args)
		return plan:add('symlink', args)
	end

	function sandbox.tar(args)
		return plan:add('tar', args)
	end

	local run_chunkfile = loadfile(chunkfile_path, 't', sandbox)
	if not run_chunkfile then
		log:error(string.format('"%s" can not be read', chunkfile_path))
	end
	run_chunkfile()

	plan:each(function(entry)
		local strategy, namespace, args = entry.strategy, entry.namespace, entry.arguments
		local namespace_path, code = strategies:call(strategy, namespace, args)

		if namespace_path then
			-- register module in load file
			local _, map_path = requires:mapfile(current_directory)

			if code ~= strategies.ALREADY_REGISTERED then
				if not fs.append_to_file(map_path, template.module_instruction(namespace, namespace_path, entry:has_post_install())) then
					log:error(string.format('library registration for "%s" failed', namespace))
				else
					log:print(string.format('library "%s" registered', namespace))
				end
			end

			if not runtime_args:has_flag('no-post-install') then
				entry:run_post_install(os.execute, namespace_path)
			end

			-- extend plan if dependency contains a chunkfile
			-- and acknowledge exports
			local code, chunkfile_path = requires:chunkfile(namespace_path, true) 

			-- allow registration of custom named exports
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

			-- allow definition of executables
			local function bin(args)
				local file = args[1]
				local file_name = namespace:match('([^/]+)%.lua')

				local runtime = ((args or {}).runtime or 'lua')

				local code, bin_file = requires:bin_file(current_directory, file_name or namespace, true)
				if code == requires.EXISTS then
					log:print(string.format('executable "%s" already available', file_name or namespace))
					return
				end

				local content = template.executable(current_directory, string.format('%s/lib/%s/%s', current_directory, namespace, file), runtime)
				if fs.put_file_content(bin_file, content) then
					log:print(string.format('executable "%s" created', file_name or namespace))
				end

				fs.allow_exec(bin_file)
			end

			sandbox.bin = bin
			sandbox.exec = bin

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
cmd:add_flag('no-post-install', 'do not run any post_install hook')

return cmd