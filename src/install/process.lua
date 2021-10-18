local fs = require('src.fs')

-- this is the essential runtime of fetching chunks
-- we start out with a initial plan and defined strategies
-- when during the load it is discovered that a chunk requires
-- another chunk, we add it to the plan; aswell as any strategy
-- defined in the chunkfiles of the chunks
return function(lib_path, plan, strategies, sandbox)
	for _, entry in ipairs(plan) do
		-- example entry: {strategy='git', handle='some_lib', args={...}}
		print('fetching "' .. entry.handle .. '" with "' .. entry.strategy .. '"')

		local strat = strategies[entry.strategy]
		if strat then
			local path = strat(lib_path, table.unpack(entry.args or {}))
			if path then
				-- extend the plan when deps are defined
				local chunkfile_path = path .. '/chunkfile.lua'
				if fs.is_file(chunkfile_path) then
					function sandbox.export(args)
						local file_path, name = table.unpack(args)
						local handle = entry.handle 

						if name then
							handle = handle .. '.' .. name
						end

						local export = 'load {\'' .. handle .. '\', \'' .. path .. '/' .. file_path .. '\'}'

						fs.append_to_file(export, lib_path .. '/' .. 'map.lua')
					end

					local instructions = loadfile(chunkfile_path, 't', sandbox)
					if instructions then
						instructions()
					end
				end

				-- implement specific preload if defined in chunkfile (if detected)
				-- implement extend plan if defined in chunkfile (if detected)
				-- basically implement chunkfile configs
			end
		else
			print('no "' .. entry.strategy .. '" strategy found')
		end
	end
end