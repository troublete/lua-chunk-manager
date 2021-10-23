local fs = require('src.fs')
local log = require('src.log')()

-- silence by default; errors will still be output, they can't be silenced
log:silence()

local r = {EXISTS=2}

local function fix_path(path)
	return path:gsub('%/+', '/')
end

local function requires_path(path, soft_check)
	local soft_check = soft_check or false
	local path = fix_path(path)

	if fs.is_directory(path) then
		log:print(string.format('"%s" exists', path))
		return r.EXISTS, path
	else
		if not soft_check then
			if fs.create_path(path) then
				log:print(string.format('"%s" created', path))
			else
				log:error(string.format('creating "%s" failed', path))
			end
		end
	end

	return 0, path
end

local function requires_file(path, soft_check)
	local path = fix_path(path)

	if fs.is_file(path) then
		log:print(string.format('"%s" exists', path))
		return r.EXISTS, path
	else
		if not soft_check then
			if fs.create_file(path) then
				log:print(string.format('"%s" created', path))
			else
				log:error(string.format('creating "%s" failed', path))
			end
		end
	end

	return 0, path
end

local function requires_directory_removal(path)
	local path = fix_path(path)

	if fs.is_directory(path) then
		if fs.remove_directory(path) then
			log:print(string.format('"%s" removed', path))
		else
			log:error(string.format('removal of "%s" failed', path))
		end
	else
		log:print(string.format('"%s" does not exist', path))
	end
end

local function requires_file_removal(path)
	local path = fix_path(path)
	
	if fs.is_file(path) then
		if fs.remove_file(path) then
			log:print(string.format('"%s" removed', path))
		else
			log:error(string.format('removal of "%s" failed', path))
		end
	else
		log:print(string.format('"%s" does not exist', path))
	end
end

function r:silence()
	log:silence()
end

function r:unsilence()
	log:unsilence()
end

function r:lib_directory(root_path, soft_check)
	local path = (root_path .. '/lib/')
	return requires_path(path, soft_check)
end

function r:removed_lib_directory(root_path)
	local path = (root_path .. '/lib/')
	requires_directory_removal(path)
end

function r:removed_dependencies(root_path)
	local _, path = self:lib_directory(root_path, true)

	for _, d in ipairs(fs.read_directory(path)) do
		if d:is_directory() then
			requires_directory_removal(path .. '/' .. tostring(d))
		end

		if d:is_symlink() then
			requires_file_removal(path .. '/' .. tostring(d))
		end
	end
end

function r:bin_directory(root_path, soft_check)
	local path = (root_path .. '/bin/')
	return requires_path(path, soft_check)
end

function r:removed_bin_directory(root_path)
	local path = (root_path .. '/bin/')
	requires_directory_removal(path)
end

function r:directory(path, soft_check)
	return requires_path(path, soft_check)
end

function r:removed_directory(path)
	requires_directory_removal(path)
end

function r:file(path, soft_check)
	return requires_file(path, soft_check)
end

function r:removed_file(path)
	return requires_file_removal(path)
end

function r:chunkfile(root_path, soft_check)
	local path = (root_path .. '/chunkfile.lua')
	return requires_file(path, soft_check)
end

function r:removed_chunkfile(root_path)
	local path = (root_path .. '/chunkfile.lua')
	requires_file_removal(path)
end

function r:removed_tar_archive(root_path)
	local path = (root_path .. '/archive.tar')
	requires_file_removal(path)
end

function r:mapfile(root_path, soft_check)
	local _, lib_path = self:lib_directory(root_path)

	local path = (lib_path .. '/map.lua')
	return requires_file(path, soft_check)
end

function r:removed_mapfile(root_path)
	local _, lib_path = self:lib_directory(root_path)

	local path = (lib_path .. '/map.lua')
	requires_file_removal(path)
end

function r:loader(root_path, soft_check)
	local _, lib_path = self:lib_directory(root_path)

	local path = (lib_path .. '/load.lua')
	return requires_file(path, soft_check)
end

function r:bin_file(root_path, path, soft_check)
	local _, bin_path = self:bin_directory(root_path)

	local path = (bin_path .. '/' .. path)
	return requires_file(path, soft_check)
end

return r