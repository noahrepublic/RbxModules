--[[ Loader
    Provides a module to load all your modules and stores them for later use.
]]

local Loader = {
	Modules = {},
}

--> Private Functions

local function loadModule(module: ModuleScript)
	local name = module.Name

	if Loader.Modules[name] then
		return Loader.Modules[name]
	end

	local loadedModule = require(module)
	Loader.Modules[name] = loadedModule

	return loadedModule
end

--> Functions

function Loader.Get(module: ModuleScript | string)
	if type(module) == "string" then
		local loadedModule = Loader.Modules[module]

		assert(loadedModule, string.format("Can not string load module %s, has not been loaded yet.", module))
		return loadedModule
	end

	return loadModule(module)
end

function Loader.LoadChildren(parent: Instance, loadCondition: (ModuleScript) -> boolean): table
	local modules = {}
	for _, child in pairs(parent:GetChildren()) do
		if not child:IsA("ModuleScript") then
			continue
		end

		if loadCondition == nil or loadCondition(child) then
			modules[child.Name] = Loader.Get(child)
		end
	end

	return modules
end

function Loader.LoadDescendants(parent: Instance, loadCondition: (ModuleScript) -> boolean): table
	local modules = {}
	for _, descendant in pairs(parent:GetDescendants()) do
		if not descendant:IsA("ModuleScript") then
			continue
		end

		if loadCondition == nil or loadCondition(descendant) then
			modules[descendant.Name] = Loader.Get(descendant)
		end
	end

	return modules
end

function Loader.StartModules(modulesToStart: { [string]: {} }, startMethod: string): nil
	startMethod = startMethod or "Start"

	for _, module in pairs(modulesToStart) do
		if type(module) ~= "table" then
			continue
		end

		if module[startMethod] then
			module[startMethod]()
		end
	end

	return nil
end

return Loader
