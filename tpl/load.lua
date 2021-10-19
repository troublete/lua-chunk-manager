-- this table holds all root directory paths
-- from all chunks which exported 'something'
_G['lcm_map'] = {}

local pwd = os.getenv('PWD')
local path = debug.getinfo(1).short_src:gsub('[^/]+.lua', '')

local lib_path = pwd .. '/' .. path
local mapfile = lib_path .. 'map.lua'

-- with this hook we set up some meta information on every require call;
-- this is essential so the required chunks can maintain there relative requires
-- and we are able to remap them to 'absolute' requires; see searcher below
debug.sethook(function(_event)
	if debug.getinfo(2).name == 'require' then
		local current_file = debug.getinfo(3).source -- the path of the file calling +require+

		_G['lcm_relative_module'] = {
			mod_name=nil, -- the current module name matching the path
			mod_root=nil -- the current module root based of the +export+ in chunkfile 
		}

		-- iterate over all +root+s collected from the mapfile
		for name, path in pairs(_G['lcm_map']) do
			local escaped_module_root = path:gsub('([%(%)%.%%%+%-%*%?%[%^%$])', '%%%1'):gsub('%/+', '/')
			local normalized_current_file = current_file:gsub('%/+', '/')

			-- if we find a matching root path we set the 'current module' metadata
			if normalized_current_file:find(escaped_module_root) then
				_G['lcm_relative_module'].mod_root = path
				_G['lcm_relative_module'].mod_name = name:gsub('%/+', '.')
			end
		end
	end
end, 'c')

-- we register a searcher, which remaps the relative requires of a required chunk
-- to a 'absolute' require; based on the set metadata earlier
table.insert(package.searchers, 2, function(modname)
	local lcm_config = _G['lcm_relative_module']

	if lcm_config and lcm_config.mod_name and lcm_config.mod_root then
		local mod = (lcm_config.mod_name .. '.' .. modname):gsub('%.+', '.')
		local path = (lcm_config.mod_root .. modname:gsub('%.+', '/')):gsub('%/+', '/') .. '.lua'

		-- we register each module in the form of `module-handle.relative-require`
		if not package.loaded[mod] then
			package.loaded[mod] = loadfile(path, 't')
		end

		return package.loaded[mod]
	end

	return nil
end)


local loader = {}

-- load the exports of a chunk
-- if none is provided; a crucial loading error will occur
-- all requires will fail – since the chunk technically returns nil
-- and therefore is not registered in package.loaded
function loader.load(args)
	local name, path = table.unpack(args)

	_G['lcm_map'][name] = path:gsub('[^/]+$', '') -- collect the root paths of the exports
	
	package.loaded[name] = (loadfile(path, 't'))()
end

local map = loadfile(mapfile, 't', loader)
if map then
	map()
else
	error('mapfile could not be loaded.')
end