local loader = {}

local basepath = function(path)
	return string.gsub(path, '(.*)(load%.lua)$', '%1')
end

local pwd = os.getenv('PWD')
local path = basepath(debug.getinfo(1).short_src)

local lib_path = pwd .. '/' .. path
local mapfile = lib_path .. 'map.lua'

local loader = {}
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