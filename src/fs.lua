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
	local ok = os.execute('rm -r ' .. path)

	if ok then
		return true
	else
		return false
	end
end

return fs