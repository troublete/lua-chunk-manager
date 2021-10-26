local log = require('src.log')()
local requires = require('src.requires')
local fs = require('src.fs')
local util = require('src.util')
local template = require('src.template')

local strategies = {current_directory=nil}

function strategies:set_current_directory(dir)
	self.current_directory = dir
end

function strategies:silence()
	log:silence()
	requires:silence()
	util:silence()
end

function strategies:call(name, ...)
	if not self[name] then
		log:error(string.format('stategy "%s" not available', name))
	end

	-- every strategy, that registers a module or exports something, must return a path
	return self[name](self, ...) 
end

-- strategy for creating 'bin' files; it creates executable scripts in
-- the *current_directory*/bin/ directory with either the file name without
-- extension or the namespace as name; the script adds the current project
-- root to the lua load path and requires the current lib loader before
-- executing the script
function strategies:bin(namespace, args)
	local file = args[1]
	local file_name = namespace:match('([^/]+)%.lua')

	local runtime = ((args or {}).runtime or 'lua')

	local code, bin_file = requires:bin_file(self.current_directory, file_name or namespace, true)
	if code == requires.EXISTS then
		log:print(string.format('"%s" already available', file_name or namespace))
		return
	end

	local content = template.executable(current_directory, current_directory .. '/' .. file, runtime)
	if fs.put_file_content(bin_file, content) then
		log:print(string.format('executable "%s" created', file_name or namespace))
	end
	fs.allow_exec(bin_file)
end

strategies.exec = strategies.bin

-- strategy for fetching libraries from github (public and private) uses
-- namespace as path, downloads the tar of the required version
-- (default master) and extracts it; returns namespace path to be used for
-- configuration
function strategies:github(namespace, args)
	local handle = args[1]
	local at = args.at or 'master'

	local _, lib_path = requires:lib_directory(self.current_directory)
	local code, namespace_path = requires:directory(lib_path .. '/' .. namespace)

	if code == requires.EXISTS then
		log:print(string.format('"%s" already retrived', namespace))
		return
	end

	local archive_path = namespace_path .. '/archive.tar'
	local ok, code = util:curl_file(string.format('https://github.com/%s/tarball/%s/', handle, at), archive_path, args)
	if ok then
		log:print(string.format('download for "%s" successful', namespace))
	else
		log:error(string.format('download failed for "%s" with %s', namespace, tostring(code)))
	end

	if util.untar(archive_path, namespace_path) then
		log:print(string.format('extract for "%s" successful', namespace))
	else
		log:error(string.format('extract failed for "%s"', namespace))
	end

	requires:removed_tar_archive(namespace_path)

	local extracted_path = fs.read_directory(namespace_path)[1]
	if not os.execute(string.format('mv %s/* %s', namespace_path .. '/' .. tostring(extracted_path), namespace_path)) then
		log:error(string.format('move failed for "%s"', namespace))
	end

	requires:removed_directory(namespace_path .. '/' .. tostring(extracted_path))
	log:print(string.format('installed "%s"', namespace))

	return namespace_path
end

-- strategy that allows a local library/chunk/... to be
-- symlinked
function strategies:symlink(namespace, args)
	local _, lib_path = requires:lib_directory(self.current_directory)
	local code, namespace_path = requires:directory(lib_path .. '/' .. namespace, true)
	local source_directory = args[2]

	if code == requires.EXISTS then
		log:print(string.format('"%s" already available', namespace))
		return
	end

	if namespace:match('%/') then
		requires:directory(lib_path .. '/' .. namespace:gsub('[^/]*%/?$', ''))
	end

	if os.execute(string.format('ln -s %s %s', source_directory, namespace_path)) then
		log:print(string.format('"%s" linked', namespace))
	end

	return namespace_path
end

return strategies