local template = {}

function template.load_instruction(namespace, path)
	return string.format("load { '%s', '%s' }", namespace, path)
end

function template.module_instruction(namespace, path)
	return string.format("module { '%s', '%s' }", namespace, path)
end

function template.chunkfile_instruction(method, args)
	return string.format("%s { %s }", method, table.concat(args, ', '))
end

function template.executable(...)
	local path, file, runtime = ...
	local vars = {runtime=runtime, path=path, file=file}
	local tpl = [[
#!/usr/bin/env {runtime}

package.path = package.path .. ';{path}/?.lua'

require('lib.load')
dofile('{file}')
]]

	local bin = tpl:gsub('%{(%w+)%}', function(match)
		return vars[match]
	end)

	return bin
end

return template