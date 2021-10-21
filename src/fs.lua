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

function fs.create_path(path)
	local ok = os.execute('mkdir -p ' .. path)

	if ok then
		return true
	else
		return false
	end
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

function fs.append_to_file(content, path)
	local ok = os.execute('echo "' .. content .. '" >> ' .. path)

	if ok then
		return true
	else
		return false
	end
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
			local postfix = string.sub(self:path(), #self:path())
			return postfix == '/'
		end

		function e:is_file()
			return not self:is_directory()
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

function fs.to_file(str, path)
	local f = io.open(path, 'w')
	f:write(str)
	return f:close()
end

function fs.allow_exec(path)
	return os.execute('chmod +x ' .. path)
end

return fs