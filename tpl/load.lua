_G['lcm_modules'] = {} -- contains module base paths

local pwd = os.getenv('PWD')
local home = os.getenv('HOME')
local lcm_home = (os.getenv('LCM_HOME') or home .. '/.lcm/')

-- escape path for pattern matching
local function escape_pattern(path)
	return path:gsub('([%(%)%.%%%+%-%*%?%[%^%$])', '%%%1')
end

-- clean up path; remove duplicate slashes
local function fix_path(path)
	return path:gsub('%/+', '/')
end

-- the current load file path
local path = debug.getinfo(1).short_src:gsub('[^/]+.lua$', ''):gsub('%.%/', '')

-- the current library path
local lib_path = pwd .. '/' .. path

-- the current projects map file
local mapfile = lib_path .. 'map.lua'

-- add LCM_HOME to searcher paths
package.cpath = package.cpath .. ';' .. lcm_home .. '/?.so'
package.path = package.path .. ';' .. lcm_home .. '/?.lua'

-- set up some loading meta information
-- to allow relative requires; see patched +require+ below
debug.sethook(function(_event)
	if debug.getinfo(2).name ~= 'require' then
		return
	end

	-- the path of the calling file
	local current_file = debug.getinfo(3).source

	_G['lcm_loading_state'] = { namespace=nil }
	for name, path in pairs(_G['lcm_modules']) do
		local short_module_root = escape_pattern(fix_path(path):gsub(escape_pattern(lib_path), ''))
		local file = fix_path(current_file)

		-- if we find a matching module path; the module namespace is selected
		if file:find(short_module_root) then
			_G['lcm_loading_state'].namespace = name:gsub('%/+', '.')
		end
	end
end, 'c')

-- patch require to allow relative requires within libs,
-- rename path to prepend lib path; which then should resolve correctly
local lr = require
require = function(modname)
	local lcm_config = _G['lcm_loading_state']

	if lcm_config and lcm_config.namespace then
		return lr(('lib.' .. lcm_config.namespace .. '.' .. modname):gsub('%.+', '.'))
	else
		return lr(modname)
	end
end

local loader = {}

-- register named/default exports of libs
function loader.load(args)
	local namespace, path = table.unpack(args)
	package.loaded[namespace] = dofile(path)
end

-- register module roots
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

-- try loading system wide LCM libs
local lcm_global_loaded = false
local global_map = loadfile(lcm_home .. '/lib/map.lua', 't', loader)
if global_map then 
	lcm_global_loaded = true
	global_map()
end

-- try loading 'local' LCM libs
local map = loadfile(mapfile, 't', loader)
if map then
	map()
else
	if not lcm_global_loaded then
		error('no local or global mapfile could be loaded.')
	end
end


