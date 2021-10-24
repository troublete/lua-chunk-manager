local function base_path(path)
	local path, matches = string.gsub(path, '(.*)/(.*)$', '%1')

	if matches > 0 then
		return path .. '/'
	else
		return './'
	end
end

table.unpack = (unpack or table.unpack)

-- set the path relevant global
-- project paths
current_directory = os.getenv('PWD') -- the directory of the project
lib_path = current_directory .. '/lib/' -- the lib path in the project; todo: remove

-- lcm paths
lcm_directory = base_path(debug.getinfo(1).short_src) -- the directory of current lcm
lcm_home = os.getenv('LCM_HOME') or os.getenv('HOME') .. '/.lcm/'

-- reference the current lcm path so the
-- support packages can be loaded
package.path = package.path .. ';' .. lcm_directory .. '?.lua'

local cli = require('src.cli') -- tool wrapper
cli:set_flag_map({
	['help']='h',
	['global']='g',
	['silent']='s'
})

cli:command({'clean', 'c'}, require('cmd.clean'))
cli:command('init', require('cmd.init'))
cli:command({'install', 'i'}, require('cmd.install'))
cli:command('add', require('cmd.add'))
cli:command('fix', require('cmd.fix'))
cli:command({'list', 'ls'}, require('cmd.list'))

cli:run()
