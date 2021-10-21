local fs = require('src.fs')
local util = require('src.util')
local process = require('src.install.process')
local strategies = require('src.install.strategies')

-- available in global: lib_path

return {
	run=function(args)
		if args:has_flag('global') then
			lib_path = os.getenv('HOME') .. '/.lcm/lib/'
		end

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

		-- allow some deps to be used

		-- WIP FEATURE
		-- this function allows to define own strategies which
		-- then can be used in the processing of the chunkfile
		-- function install_sandbox.register_strategy(name, func)
		-- 	strategies[name] = func

		-- 	install_sandbox[name] = function(args)
		-- 		local handle = args[1]

		-- 		if not plan:contains(handle) then
		-- 			table.insert(plan, {strategy=name, handle=handle, args=args})
		-- 		end
		-- 	end
		-- end

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

		-- allow local symlinks
		function install_sandbox.symlink(args)
			local handle = args[1]

			if not plan:contains(handle) then
				table.insert(plan, {strategy='symlink', handle=handle, args=args})
			end
		end

		-- allow the creation of execs
		function install_sandbox.bin(args)
			local file, name = table.unpack(args)
			local bin_path = current_directory .. '/bin/'

			local handle = file:match('[^/]+%.lua'):gsub('(.+)%.lua$', '%1')
			local file_path = bin_path .. (name or handle)


			if not fs.is_directory(bin_path) then
				if not fs.create_path(bin_path) then
					util.p('bin path could not be created.')
					return
				end
			end

			if not fs.touch(file_path) then
				util.p('bin file for', util.quote(file), 'could not be created.')
				return
			end

			fs.to_file(util.tpl_bin(current_directory, file), file_path)
			fs.allow_exec(file_path)

			util.p('bin file for', util.quote(name or handle), ' created')
			return
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
		title='install LCM deps',
		flags={
			global={
				desc='runs an install command on global depot'
			}
		}
	}
}