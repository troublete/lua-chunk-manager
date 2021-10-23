local log = require('src.log')()
local plan = {}

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

function plan:add(strategy, args)
	-- we need to extract some kind of namespace
	-- to be used for duplication checks
	local namespace = (args.namespace or args[1])

	if not self:contains(namespace) then
		table.insert(plan, {
			strategy=strategy,
			namespace=namespace,
			arguments=args
		})
	end
end

function plan:each(func)
	for _, e in ipairs(self) do
		log:print(string.format('\ntrying strategy "%s" for namespace "%s"', e.strategy, e.namespace))
		func(e.strategy, e.namespace, e.arguments)
	end
end

return plan