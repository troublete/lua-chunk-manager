-- helpers
local function escape_path(path)
	return path:gsub('([%(%)%.%%%+%-%*%?%[%^%$])', '%%%1')
end

local function fix_path(path)
	return path:gsub('%/+', '/')
end

local function path_to_module_name(path)
	return path:gsub('%/+', '.')
end

local function module_name_to_path(path)
	return path:gsub('%.+', '/')
end

local function fix_module_name(modname)
	return modname:gsub('%.+', '.')
end

local function extract_dir(path)
	return path:gsub('[^/]+.lua$', '')
end

-- this table holds all root directory paths
-- from all chunks which exported 'something'
_G['lcm_modules'] = {}

local pwd = os.getenv('PWD')
local path = extract_dir(debug.getinfo(1).short_src)
local lib_path = pwd .. '/' .. path
local mapfile = lib_path .. 'map.lua'

-- with this hook we set up some meta information on every require call;
-- this is essential so the required chunks can maintain there relative requires
-- and we are able to remap them to 'absolute' requires; see searcher below
debug.sethook(function(_event)
	if debug.getinfo(2).name ~= 'require' then
		return
	end

	local current_file = debug.getinfo(3).source -- the path of the calling file
	_G['lcm_loading_state'] = {
		module_name=nil, -- the current module name matching the path
		module_root=nil -- the current module root based of the +export+ in chunkfile 
	}

	-- check for each export 
	for name, path in pairs(_G['lcm_modules']) do
		local module_root = fix_path(escape_path(path))
		local file = fix_path(current_file)

		-- if we find a matching root path we set the 'current module' metadata
		if file:find(module_root) then
			_G['lcm_loading_state'].module_root = path
			_G['lcm_loading_state'].module_name = path_to_module_name(name)
		end
	end
end, 'c')

-- we register a searcher, which remaps the relative requires of a required chunk
-- to a 'absolute' require; based on the set metadata earlier
table.insert(package.searchers, 2, function(module_name)
	local lcm_config = _G['lcm_loading_state']

	if lcm_config and lcm_config.module_name and lcm_config.module_root then
		local mod = fix_module_name(lcm_config.module_name .. '.' .. module_name)
		local path = fix_path(lcm_config.module_root .. module_name_to_path(module_name)) .. '.lua'

		if not package.loaded[mod] then
			package.loaded[mod] = loadfile(path)
		end

		return package.loaded[mod]
	end

	return true
end)

local loader = {}
function loader.load(args)
	local name, path = table.unpack(args)
	package.loaded[name] = (loadfile(path, 't'))()
end

function loader.module(args)
	local name, path = table.unpack(args)
	_G['lcm_modules'][name] = path

	-- register init in case it is available to allow
	-- zero export modules
	local init = loadfile(path .. '/init.lua', 't')
	if init then
		package.loaded[name] = init()
	end
end

lcm_print_modules = function()
	for k, v in pairs(package.loaded) do
		print(k, v)
	end
end

local map = loadfile(mapfile, 't', loader)
if map then
	map()
else
	error('mapfile could not be loaded.')
end