local fs = require('src.fs')
local git = require('src.git')

local function fetch(plan, strategies)
	for _, entry in pairs(plan) do
		print('fetching "' .. entry.handle .. '" with "' .. entry.strategy .. '"')

		local strat = strategies[entry.strategy]
		if strat then
			local path = strat(entry.handle)

			if path then
				-- implement autoload preload
			end
		else
			print('no strategy found for "' .. entry.source .. '"')
		end
	end
end

return function()
	local chunkfile_path = current_directory .. '/chunkfile.lua'
	if not fs.is_file(chunkfile_path) then
		print('no chunkfile found.')
		return
	end

	local plan = {}
	local strategies = {}
	function strategies.github(handle)
		local path = lib_path .. '/' .. handle
		if fs.is_directory(path) then
			print('"' .. handle .. '" already checked out.')
			return
		end

		if git.clone('git@github.com:' .. handle .. '.git', path) then
			print('"' .. handle .. '" checked out.')
		end
	end

	local install_sandbox = {}
	function install_sandbox.github(args)
		local handle = table.unpack(args)
		table.insert(plan, {strategy='github', handle=handle})
	end

	local instructions = loadfile(chunkfile_path, 't', install_sandbox)
	if instructions then
		instructions()
		fetch(plan, strategies)
	else
		print('chunkfile can not be read.')
	end
end