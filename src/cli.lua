-- HELPER
-- flag map requires format {*flag*=*flag-short*}
local function parsed_arguments(flag_map)
	local args = {flags={}, args={}, named_args={}}
	local flag_map = flag_map or {}

	for k, v in pairs(arg) do 
		if k ~= 0 and k ~= -1 then
			local single_pre = string.sub(v, 1, 1) -- check for short hands
			local double_pre = string.sub(v, 1, 2) -- check for flags

			if single_pre == '-' and double_pre ~= '--' then -- if short hand, use all characters as separate flags
				for f in string.gmatch(v, '.') do
					if f ~= '-' then
						args.flags[f] = true
					end
				end
			end

			if single_pre == '-' and double_pre == '--' then -- if flag, use as is
				local flag = string.sub(v, 3)
				local name, value = flag:match('^(.+)%=(.+)$')

				args.flags[name or flag] = true

				if name and value then
					args.named_args[name] = value
				end
			end

			if single_pre ~= '-' and double_pre ~= '--' then -- in any other case, use as arguments
				table.insert(args.args, v)
			end
		end
	end

	function args:command()
		return self.args[1]
	end

	function args:has_flag(flag) -- check if flag matches provided flags or short hands
		return self.flags[flag] == true or self.flags[flag_map[flag]] == true
	end

	return args
end

-- MODULE
local cli = {_commands={}, _flag_map={}}

-- override flag map (@see +parsed_arguments+)
function cli:set_flag_map(flag_map)
	self._flag_map = flag_map
end

-- append new command to cli
function cli:command(name, module)
	if type(name) == 'string' then
		self._commands[name] = {module=module, shorthand=false}
	end

	if type(name) == 'table' then
		local main = nil
		for idx, v in ipairs(name) do
			self._commands[v] = {module=module, shorthand=(idx ~= 1)}

			if idx == 1 then
				main = self._commands[v].module
			else
				main:add_alias(v)
			end
		end
	end
end

-- run command
function cli:run()
	local p = parsed_arguments(self._flag_map)
	local cmd = p.args[1]

	if self._commands[cmd] and not p:has_flag('help') then
		return self._commands[cmd].module:run(p)
	end

	if self._commands[cmd] and p:has_flag('help') then
		print(string.format('Usage: lcm %s [args|flags...]', cmd))
		return self._commands[cmd].module:print_help(self._flag_map)
	end

	if p:has_flag('help') then
		print('Usage: lcm <command> [args|flags...]')
		print('Available commands:')
		for _, c in pairs(self._commands) do
			if not c.shorthand then
				c.module:print_help(self._flag_map)
			end
		end
		return
	end

	print(string.format('Need help? Run `lcm --help [command]` to show more info.'))
end

return cli