local cli = {_command=arg[1], _commands={}}

function cli:command(name, func)
	self._commands[name] = func
end

function cli:run()
	if self._commands[self._command] then
		self._commands[self._command]()
	else
		print('help?')
	end
end

return cli