local log = require('src.log')()

return function(name, short_desc, func)
	local cmd = {name=name, short_description=short_desc, func=func, flags={}, alias={}}

	function cmd:print_help(flag_map)
		if #self.alias > 0 then
			log:print(string.format('%s (alias: %s) – %s', name, table.concat(self.alias, ', '), self.short_description))
		else
			log:print(string.format('%s – %s', name, self.short_description))
		end

		for name, desc in pairs(self.flags) do
			local flags = {'--' .. name}
			if flag_map[name] then
				table.insert(flags, '-' .. flag_map[name])
			end

			log:print('\t', table.concat(flags, ', '), '\n\t\t', desc)
		end
	end

	function cmd:run(args)
		self.func(args)
	end

	function cmd:add_flag(name, desc)
		self.flags[name] = desc
	end

	function cmd:add_alias(name)
		table.insert(self.alias, name)
	end

	return cmd
end