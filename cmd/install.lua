local fs = require('src.fs')
local process = require('src.install.process')
local strategies = require('src.install.strategies')

-- available in global: lib_path

return {
	run=function(args)
		local chunkfile_path = current_directory .. '/chunkfile.lua'

		if not fs.is_file(chunkfile_path) then
			print('no chunkfile found.')
			return
		end

		local plan = {} -- the list of dependencies to be loaded

		-- this method checks if a certain chunk is already registered
		-- in the plan; to be used to make sure that only unique handles
		-- are added to avoid duplications in load paths
		--
		-- therefore it is important for chunkfile defs
		-- to contain as first argument a handle; which is references for loading
		-- and to check uniqueness.
		-- If multiple versions of the same lib are needed, the handle can be used
		-- to allow this.
		function plan:contains(handle)
			for _, entry in ipairs(plan) do
				if entry.handle == handle then
					return true
				end
			end

			return false
		end

		local install_sandbox = {}

		-- this function allows to define own strategies which
		-- then can be used in the processing of the chunkfile
		function install_sandbox.register_strategy(name, func)
			strategies[name] = func

			install_sandbox[name] = function(args)
				local handle = args[1]

				if not plan:contains(handle) then
					table.insert(plan, {strategy=name, handle=handle, args=args})
				end
			end
		end

		-- allows github to be used as strategy
		function install_sandbox.github(args)
			local handle = args[1]

			if not plan:contains(handle) then
				table.insert(plan, {strategy='github', handle=handle, args=args})
			end
		end

		-- allows private github to be used as strategy
		function install_sandbox.private_github(args)
			local handle = args[1]

			if not plan:contains(handle) then
				table.insert(plan, {strategy='private_github', handle=handle, args=args})
			end
		end

		local instructions = loadfile(chunkfile_path, 't', install_sandbox)
		if instructions then
			instructions() -- chunkfile is read; and interepreted (i.e. strats registered; chunks added to be fetched)
			process(lib_path, plan, strategies, install_sandbox) -- run recursive fetching of required chunks
		else 
			print('chunkfile can not be read.')
		end
	end,
	help={
		handle='install',
		title='install LCM deps'
	}
}