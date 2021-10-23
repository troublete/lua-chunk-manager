local util = {silent=false}

function util:silence()
	self.silent = true
end

function util:curl_file(url, path, args)
	local user = (args or {}).user

	local base = "curl -L -# %s"
	if self.silent then
		base = "curl -sL %s"
	end

	if user then
		if os.execute(string.format(string.format(base, url) .. " -u '%s' > %s", user, path)) then
			return true
		else
			return false
		end
	else
		if os.execute(string.format(string.format(base, url) .. " > %s", path)) then
			return true
		else
			return false
		end
	end
end

function util.untar(source, target)
	if os.execute(string.format('tar -xzf %s -C %s', source, target)) then
		return true
	else 
		return false
	end
end

function util.pattern_escape(str)
	return str:gsub('([%(%)%.%%%+%-%*%?%[%^%$])', '%%%1')
end

return util