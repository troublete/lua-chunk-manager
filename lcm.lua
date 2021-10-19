local lua_print = print
print = function(...)
	lua_print('lcm:', ...)
end

local function base_path(path)
	local path, matches = string.gsub(path, '(.*)/(.*)$', '%1')

	if matches > 0 then
		return path .. '/'
	else
		return './'
	end
end

-- set the path relevant global
-- project paths
current_directory = os.getenv('PWD') -- the directory of the project
lib_path = current_directory .. '/lib/' -- the lib path in the project

-- lcm paths
lcm_directory = base_path(debug.getinfo(1).short_src) -- the directory of lcm

-- reference the current lcm path so the
-- support packages can be loaded
package.path = package.path .. ';' .. lcm_directory .. '?.lua'

local cli = require('src.cli') -- tool wrapper
cli:set_flag_map({
	['help']='h'
})

cli:command('clean', require('cmd.clean'))
cli:command('init', require('cmd.init'))
cli:command('install', require('cmd.install'))

cli:run()
