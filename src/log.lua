return function()
	local log = {silent=false}

	function log:silence()
		self.silent = true
	end

	function log:unsilence()
		self.silent = false
	end

	function log:print(...)
		if not log.silent then
			print(table.concat(table.pack(...), '\t'))
		end
	end

	function log:error(...)
		error(table.concat(table.pack(...), '\t'), 2)
	end

	return log
end
