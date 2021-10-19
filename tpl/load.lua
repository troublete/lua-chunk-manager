local loader = {}

local basepath = function(path)
	return string.gsub(path, '(.*)(load%.lua)$', '%1')
end

local pwd = os.getenv('PWD')
local path = basepath(debug.getinfo(1).short_src)

local lib_path = pwd .. '/' .. path
local mapfile = lib_path .. 'map.lua'

-- we hook into every require call, to setup relative paths of the current module calling;
-- so relative requires in lib chunks can be sustained
debug.sethook(function(_event)
	if debug.getinfo(2).name == 'require' then
		-- get path of file calling the require
		local current_file = debug.getinfo(3).source

		-- escape the current pwd to beused in gsub
		local escaped_pwd = string.gsub(pwd, '([%(%)%.%%%+%-%*%?%[%^%$])', '%%%1')

		-- setup library root module name
		local mod_name = current_file:gsub('[^/]+$', ''):gsub('^%@', ''):gsub(escaped_pwd, ''):gsub('%/+', '.'):match('%.(.*)%.')
		
		-- setup library root module path
		local mod_path = current_file:gsub('[^/]+$', ''):gsub('^%@', '')

		-- register as globals to be used in searcher
		_G['lcm_relative_module'] = {
			mod_name=mod_name,
			mod_path=mod_path
		}
	end
end, 'c')

-- register a new searcher; which will load remapped relative path modules
-- from lib chunks
table.insert(package.searchers, 2, function(modname)
	local lcm_config = _G['lcm_relative_module']

	if lcm_config and lcm_config.mod_name and lcm_config.mod_path then
		local mod = (lcm_config.mod_name .. modname):gsub('%.+', '.')
		local path = (lcm_config.mod_path .. modname:gsub('%.+', '/')):gsub('%/+', '/') .. '.lua'

		if not package.loaded[mod] then
			package.loaded[mod] = loadfile(path, 't')
		end

		return package.loaded[mod]
	end

	return nil
end)


local loader = {}

-- load the exports of a lib chunk
-- if none is provided; a crucial loading error will occur
-- all requires will fail – since the chunk technically returns nil
-- and therefore is not registered in loaded @see L13-L54
function loader.load(args)
	local name, path = table.unpack(args)
	package.loaded[name] = (loadfile(path, 't'))()
end

local map = loadfile(mapfile, 't', loader)
if map then
	map()
else
	error('mapfile could not be loaded.')
end