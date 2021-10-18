return function(plan, p)
	local install_sandbox = p or {}
	-- this function allows to define own strategies which
	-- then can be used in the processing of the chunkfile
	function install_sandbox.register_strategy(name, func)
		strategies[name] = func

		install_sandbox[name] = function(args)
			local handle = args[1]

			if not plan:contains(handle) then
				table.insert(plan, {strategy=name, handle=handle, args=args})
			end
		end
	end

	-- allows github to be used as strategy
	function install_sandbox.github(args)
		local handle = args[1]

		if not plan:contains(handle) then
			table.insert(plan, {strategy='github', handle=handle, args=args})
		end
	end

	-- allows private github to be used as strategy
	function install_sandbox.private_github(args)
		local handle = args[1]

		if not plan:contains(handle) then
			table.insert(plan, {strategy='private_github', handle=handle, args=args})
		end
	end

	return install_sandbox
end