local fs = require('src.fs')
local requires = require('src.requires')
local log = require('src.log')()
local install = require('cmd.install')
local template = require('src.template')

return {
	run=function(args)
		if args:has_flag('global') then
			current_directory = os.getenv('HOME') .. '/.lcm/'
		end

		if args:has_flag('silent') then
			log:silence()
		end

		local _, chunkfile_path = requires:chunkfile(current_directory)
		local instructions = {}
		
		for idx, cmd in ipairs(args.args) do
			if idx ~= 1 then
				local method, positional_args = cmd:match('(.+)%:(.+)')

				local arguments = {}
				for a in positional_args:gmatch('[^,]+') do
					table.insert(arguments, string.format("'%s'", a))
				end

				for k, v in pairs(args.named_args) do
					table.insert(arguments, string.format("%s = '%s'", k, v))
				end

				local i = template.chunkfile_instruction(method, arguments)
				table.insert(instructions, i)

				if fs.append_to_file(chunkfile_path, table.concat(instructions, "\n")) then
					log:print(string.format('"%s" added to chunkfile', i))
				else
					log:error('could not add to chunkfile')
				end
			end
		end

		if not args:has_flag('no-install') then
			install.run(args)
		end
	end,
	help={
		handle='add',
		title='add a chunk dependency',
		flags={
			global={
				desc='add to global depot'
			},
			silent={
				desc='omits any output'
			},
			['no-install']={
				desc='does not run install after adding'
			}
		}

	}
}