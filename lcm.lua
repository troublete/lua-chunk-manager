local function base_path(path)
	local path, matches = string.gsub(path, '(.*)/(.*)$', '%1')

	if matches > 0 then
		return path .. '/'
	else
		return './'
	end
end

-- make the paths, relevant global
current_directory = os.getenv('PWD')
lcm_directory = base_path(debug.getinfo(1).short_src)
lib_path = current_directory .. '/lib/'

-- reference the current lcm path so the
-- support packages can be loaded
package.path = package.path .. ';' .. lcm_directory .. '?.lua'

local cli = require('src.cli')
local fs = require('src.cli')

-- init command; creates idempotent
-- lcm files and directories
cli:command('clean', require('cmd.clean'))
cli:command('init', require('cmd.init'))

cli:run()

-- local chunkfile = 'chunkfile.lua'
-- local loader = 'load.lua'
-- local map = 'map.lua'


-- local create_lib_dir = function()
-- 	local lib_exists = os.execute('test -d ' .. lib_path)

-- 	if lib_exists then
-- 		return
-- 	end

-- 	local created_lib = os.execute('mkdir -p ' .. lib_path)

-- 	if created_lib then
-- 		print('created lib directory.')
-- 	end
-- end

-- if command == 'init' then
-- 	local file_exists = os.execute('test -f ' .. chunkfile)

-- 	if file_exists then
-- 		print(chunkfile .. ' already exists.')
-- 		return
-- 	end

-- 	local copied = os.execute('cp ' .. current_directory .. './tpl/' .. chunkfile .. ' ' .. current_chunkfile)

-- 	if copied then
-- 		print('chunk initialized. ' .. chunkfile .. ' created.')
-- 	end

-- 	create_lib_dir()

-- 	local copied = os.execute('cp ' .. current_directory .. './tpl/' .. loader  .. ' ' .. lib_path .. loader)

-- 	if copied then
-- 		print('chunk initialized. ' .. loader .. ' created.')
-- 	end

-- 	local created = os.execute('touch ' .. lib_path .. map)

-- 	if created then
-- 		print('chunk initialized. ' .. map .. ' created.')
-- 	end
-- end

-- if command == 'install' then
-- 	local file_exists = os.execute('test -f ' .. current_chunkfile)

-- 	if not file_exists then
-- 		print('no chunkfile.')
-- 		return
-- 	end

-- 	local sandbox = {}

-- 	function sandbox.github(args)
-- 		local name = table.unpack(args)
-- 		local lib_chunk_path = lib_path .. '/' .. name

-- 		local ok = os.execute('test -d ' .. lib_chunk_path)
-- 		if ok then
-- 			print('package "' .. name .. '" exists. moving on.')
-- 			return
-- 		end

-- 		print('fetching "' .. name .. '"')

-- 		local ok = os.execute('git clone git@github.com:' .. name .. '.git ' .. lib_chunk_path)

-- 		if ok then
-- 			print('checked out "' .. name .. '"')
-- 		end

-- 		local sandbox = {}
-- 		local map_entry = nil

-- 		function sandbox.main(args)
-- 			local path = table.unpack(args)
-- 			map_enty = 'load { \'' .. name .. '\', \'' .. lib_chunk_path .. '/' .. path .. '\' }'
-- 		end

-- 		local chunkfile = loadfile(lib_chunk_path .. '/' .. chunkfile, 't', sandbox)

-- 		if chunkfile then
-- 			chunkfile()

-- 			local ok = os.execute('echo "' .. map_enty .. '" >> ' .. lib_path .. map)
-- 		end
-- 	end

-- 	local instructions = loadfile(current_chunkfile, 't', sandbox)

-- 	if instructions == nil then
-- 		print('nothing to do.')
-- 			return
-- 		end

-- 		instructions()
-- 	end
