-- helpers
local function escape_pattern(path)
	return path:gsub('([%(%)%.%%%+%-%*%?%[%^%$])', '%%%1')
end

local function fix_path(path)
	return path:gsub('%/+', '/')
end

local function path_to_module_name(path)
	return path:gsub('%/+', '.')
end

local function fix_module_name(modname)
	return modname:gsub('%.+', '.')
end

local function extract_dir(path)
	return path:gsub('[^/]+.lua$', '')
end

local function clean_path(path)
	return path:gsub('%.%/', '')
end

local home = os.getenv('HOME')
local lcm_home = (os.getenv('LCM_HOME') or home .. '/.lcm/')

-- this table holds all root directory paths from all chunks
_G['lcm_modules'] = {}

local pwd = os.getenv('PWD')
local path = clean_path(extract_dir(debug.getinfo(1).short_src))
local lib_path = pwd .. '/' .. path
local mapfile = lib_path .. 'map.lua'

-- in this map we set up some loading meta information
-- to allow relative requires; see patched +require+ below
debug.sethook(function(_event)
	if debug.getinfo(2).name ~= 'require' then
		return
	end

	local current_file = debug.getinfo(3).source -- the path of the calling file

	_G['lcm_loading_state'] = {
		namespace=nil, -- the current module name matching the path
		module_root=nil -- the current module root based of the +export+ in chunkfile 
	}

	for name, path in pairs(_G['lcm_modules']) do
		local short_module_root = escape_pattern(fix_path(path):gsub(escape_pattern(lib_path), ''))
		local file = fix_path(current_file)

		-- if we find a matching root path we set the 'current module' metadata
		if file:find(short_module_root) then
			_G['lcm_loading_state'].module_root = path
			_G['lcm_loading_state'].namespace = path_to_module_name(name)
		end
	end
end, 'c')

-- require is patched to allow relative require calls within imported chunks
local lr = require
require = function(modname)
	local module_name = modname
	local lcm_config = _G['lcm_loading_state']

	if lcm_config and lcm_config.namespace then
		return lr(fix_module_name('lib.' .. lcm_config.namespace .. '.' .. module_name))
	else
		return lr(module_name)
	end
end

-- allow global lcm depot to be used
package.cpath = package.cpath .. ';' .. lcm_home .. '/?.so'
package.path = package.path .. ';' .. lcm_home .. '/?.lua'

local loader = {}
function loader.load(args)
	local namespace, path = table.unpack(args)
	package.loaded[namespace] = dofile(path)
end

function loader.module(args)
	local namespace, path = table.unpack(args)
	_G['lcm_modules'][namespace] = path

	-- check for init.lua; allows zero export modules
	local init = loadfile(path .. '/init.lua', 't')
	if init then
		package.loaded[namespace] = init()
	end

	if args.include_path then
		package.cpath = package.cpath .. ';' .. path .. '/?.so'
		package.path = package.path .. ';' .. path .. '/?.lua'
	end
end

local lcm_global_loaded = false

-- try to load global lcm depot
local global_map = loadfile(lcm_home .. '/lib/map.lua', 't', loader)
if global_map then
	global_map()
	lcm_global_loaded = true
end

local map = loadfile(mapfile, 't', loader)
if map then
	map()
else
	if not lcm_global_loaded then
		error('no local or global mapfile could be loaded.')
	end
end


