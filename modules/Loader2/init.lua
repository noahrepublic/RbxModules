--[[
    Loader2 is a better loader that removes caching but adds string requiring and is meant to be used with the servicebag system inspired by Quenty's Nevermore.
]]

--> Includes

local Dependency = require(script.Dependency)

--> Private Functions

local function loadModule(moduleScript: ModuleScript) -- a module is provided for injection
	assert(
		typeof(moduleScript) == "Instance",
		"loadModule expects a ModuleScript as the first argument, got " .. typeof(moduleScript)
	)

	return function(requestedModule)
		if type(requestedModule) == "string" then
			-- string load from here
			local module = Dependency.search(moduleScript, requestedModule)

			if module then
				module = require(module)
			end

			return module
		else
			return require(requestedModule)
		end
	end
end

--> Functions

return {
	load = loadModule,
	priority = Dependency.priority,
}
