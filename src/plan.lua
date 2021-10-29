local log = require('src.log')()
local plan = {environment=nil}

-- this method checks if a certain chunk is already registered in the plan; to
-- be used to make sure that only unique namespaces (names) are added to
-- avoid duplicate work
--
-- therefore it is important for chunkfile definitions to contain as first
-- argument a namespace; which is used for loading and to check uniqueness.
-- If multiple versions of the same lib are needed, the namespace (i.e. name)
-- can be used to allow this.
function plan:contains(namespace)
	for _, entry in ipairs(plan) do
		if entry.namespace == namespace then
			return true
		end
	end

	return false
end

function plan:silence()
	log:silence()
end

function plan:set_env(env)
	self.environment = env
end

function plan:add(strategy, args)
	local entry = {
		strategy=strategy,
		namespace=nil,
		arguments=nil,
		_hooks={
			post_install=nil
		}
	}

	function entry:post_install(func)
		self._hooks.post_install = func
	end

	function entry:run_post_install(...)
		if not self._hooks.post_install then
			return
		end

		log:print(string.format('running post install for lib "%s"', self.namespace))
		self._hooks.post_install(...)
		log:print(string.format('post install done for lib "%s"', self.namespace))
	end

	-- we need to extract some kind of namespace
	-- to be used for duplication checks
	local namespace = (args.namespace or args[1])

	if not self:contains(namespace) then
		entry.namespace = namespace
		entry.arguments = args

		table.insert(plan, entry)
	end

	return entry
end

function plan:each(func)
	for _, e in ipairs(self) do
		if not self.environment or (e.arguments.env and self.environment == e.arguments.env) then
			log:print(string.format('\ntrying strategy "%s" for namespace "%s"', e.strategy, e.namespace))
			func(e)
		end
	end
end

return plan