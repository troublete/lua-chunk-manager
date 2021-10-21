local fs = require('src.fs')
local util = require('src.util')

-- this is the essential runtime of fetching chunks
-- we start out with a initial plan and defined strategies
-- when during the load it is discovered that a chunk requires
-- another chunk, we add it to the plan; aswell as any strategy
-- defined in the chunkfiles of the chunks
-- the sand
return function(lib_path, plan, strategies, sandbox)
	for _, entry in ipairs(plan) do
		-- example entry: 
		--	{
		-- 		strategy='git',
		--		handle='some_lib',
		--		args={...}
		--	}
		util.p('fetching', util.quote(entry.handle), 'with', util.quote(entry.strategy))

		-- pick strategy; if available execute it
		-- with the arguments provided
		local strat = strategies[entry.strategy]

		if strat then
			local handle = entry.handle:gsub('%/+', '.'):gsub('%.+', '.') -- change to '.'-notation

			-- all strats MUST return the "target" directory; which is
			-- then the root of the module
			local path = strat(lib_path, table.unpack(entry.args or {}))

			if path then
				-- append module root to load
				-- here is order important: module instruction MUST be before any load
				local line = util.tpl_instruction_module(handle, path:gsub('%/+', '/'):gsub('[^/]+.lua$', ''))
				fs.append_to_file(line, lib_path .. '/map.lua')

				-- extend install sandbox to allow the registration
				-- of exports and the module root
				function sandbox.export(args)
					local file_path, name = table.unpack(args)

					if name then
						handle = handle .. '.' .. name
					end

					local line = util.tpl_instruction_load(handle, (path .. '/' .. file_path):gsub('%/+', '/'))
					fs.append_to_file(line, lib_path .. '/map.lua')
				end

				

				local instructions = loadfile(path .. '/chunkfile.lua', 't', sandbox)
				if instructions then
					instructions()
				end
			end
		else
			util.p('no', util.quote(entry.strategy), 'strategy found')
		end
	end
end