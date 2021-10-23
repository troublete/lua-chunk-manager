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

				args.flags[flag] = true

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

local function print_help(h, flag_map, omit_handle)
	if not omit_handle then
		print('', h.handle)
	else
		print('')
	end
	print('\t', h.title)

	if h.flags then
		print('')
		print('')
		for flag, def in pairs(h.flags) do
			if flag_map[flag] then
				print('', '', '--' .. flag .. ', -' .. flag_map[flag])
			else
				print('', '', '--' .. flag)
			end

			print('', '', '',  def.desc)
		end
	end
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
		self._commands[name] = module
	end

	if type(name) == 'table' then
		for _, v in ipairs(name) do
			self._commands[v] = module
		end
	end
end

-- run command
function cli:run()
	local p = parsed_arguments(self._flag_map)
	local cmd = p.args[1]

	if self._commands[cmd] and not p:has_flag('help') then
		return self._commands[cmd].run(p)
	end

	if self._commands[cmd] and p:has_flag('help') then
		print(string.format('Usage: lcm %s [args, flags...]', cmd))
		return print_help(self._commands[cmd].help, self._flag_map, true)
	end

	if p:has_flag('help') then
		print('Usage: lcm <command> [args, flags...]')
		print('Available commands:')
		print('')
		for _, c in pairs(self._commands) do
			print_help(c.help, self._flag_map)
			print()
		end
	end
end

return cli