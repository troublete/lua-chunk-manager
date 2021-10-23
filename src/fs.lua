local fs = {}

function fs.is_file(path)
	local ok = os.execute('test -f ' .. path)

	if ok then
		return true
	else
		return false
	end
end

function fs.is_directory(path)
	local ok = os.execute('test -d ' .. path)

	if ok then
		return true
	else
		return false
	end
end

function fs.is_symlink(path)
	local ok = os.execute('test -L ' .. path)

	if ok then
		return true
	else
		return false
	end
end

function fs.create_path(path)
	local ok = os.execute('mkdir -p ' .. path)

	if ok then
		return true
	else
		return false
	end
end

function fs.create_file(path)
	local handle = io.open(path, 'w')

	if not handle then
		return false
	end

	handle:write('')
	handle:close()

	return true
end

function fs.get_file_content(path)
	local handle = io.open(path, 'r')

	if not handle then
		error(string.format('"%s" could not be read', path))
	end

	local contents = handle:read('a')
	handle:close()

	return contents
end

function fs.put_file_content(path, content)
	local handle = io.open(path, 'w')

	if not handle then
		error(string.format('"%s" could not be read', path))
	end

	handle:write(content)
	handle:close()

	return true
end

function fs.touch(path)
	local ok = os.execute('touch ' .. path)

	if ok then
		return true
	else
		return false
	end
end

function fs.copy_file(source, target)
	local ok = os.execute('cp ' .. source .. ' ' .. target)

	if ok then
		return true
	else
		return false
	end
end

function fs.remove_file(path)
	local ok = os.execute('rm ' .. path)

	if ok then
		return true
	else
		return false
	end
end

function fs.remove_directory(path)
	local ok = os.execute('rm -rf ' .. path)

	if ok then
		return true
	else
		return false
	end
end

function fs.append_to_file(path, content)
	local handle = io.open(path, 'a')

	if not handle then
		return false
	end

	handle:write("\n" .. content .. "\n")
	handle:close()

	return true
end

function fs.write_to_file(content, path)
	local handle = io.open(path, 'w')

	if not handle then
		return false
	end

	handle:write(content)
	handle:close()

	return true
end

local function normalize_path(path)
	local final = string.sub(path, #path)
	if final == '/' then
		return path
	else
		return path .. '/'
	end
end

function fs.read_directory(root)
	local dir = io.popen('ls -pf ' .. root)
	local done = false
	local entries = {}

	local function entry(path)
		local e = {}

		setmetatable(e, {__tostring=function() return path end});

		function e:extension()
			local ext = string.match(path, '%.(.+)$')
			if ext == '.' then
				return nil
			else
				return ext
			end
		end

		function e:path()
			return normalize_path(root) .. path
		end

		function e:is_directory()
			return fs.is_directory(self:path())
		end

		function e:is_file()
			return fs.is_file(self:path())
		end

		function e:is_symlink()
			return fs.is_symlink(self:path())
		end

		return e
	end

	while not done do
		local entry_raw = dir:read()
		if entry_raw then
			if entry_raw ~= './' and entry_raw ~= '../' then
				table.insert(entries, entry(entry_raw))
			end
		else
			done = true
		end
	end

	dir:close()
	return entries
end

function fs.allow_exec(path)
	return os.execute('chmod +x ' .. path)
end

return fs