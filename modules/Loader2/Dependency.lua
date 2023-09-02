-- handles dependency finding in an priority order

--[[
	- Direct Children

    - Packages
    - Server Packages (server only)

]]

--> Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--> Constants

local SHARED_PACKAGES = ReplicatedStorage:FindFirstChild("Packages")
local SERVER_PACKAGES = ServerStorage:FindFirstChild("Packages") or ServerStorage:FindFirstChild("ServerPackages")

local LoadPriority = {
	SHARED_PACKAGES,
	SERVER_PACKAGES,
}

--> Types

type PackageInfo = {
	Author: string,
	Name: string,
	Version: string,
}

--> Private Functions

local function isWallyPackage(packageInfo: PackageInfo): boolean
	return (packageInfo.Author ~= nil and packageInfo.Name ~= nil and packageInfo.Version ~= nil)
end

local function wallyPackageInfo(name: string): PackageInfo | nil
	-- wally name ex: noahrepublic_datakeep@1.0.0
	local versionSplit = name:split("@")
	local packageDetails = versionSplit[1]:split("_")

	local author = packageDetails[1]
	local packageName = packageDetails[2]

	local ver = versionSplit[2]

	local packageInfo: PackageInfo = {
		Author = author,
		Name = packageName,
		Version = ver,
	}

	local valid = isWallyPackage(packageInfo)

	if not valid then
		return nil
	end

	return packageInfo
end

local function recurseDirectory(folder, looking)
	return coroutine.wrap(function()
		for _, child in folder:GetChildren() do
			if child.Name == looking then
				coroutine.yield(child)
			end

			for directory in recurseDirectory(child, looking) do
				coroutine.yield(directory)
			end
		end
	end)
end

local function iterateWallyFolder(folder, lookingFor: string)
	local packageName = lookingFor -- used to find the init.lua

	return coroutine.wrap(function()
		for _, package in pairs(folder:GetChildren()) do
			local packageInfo = wallyPackageInfo(package.Name)

			if packageInfo and packageInfo.Name == lookingFor:lower() then -- Supports, "Promise", "promise", "PROMISE"
				packageName = packageInfo.Name
			end

			if package.Name == lookingFor then
				coroutine.yield(package)
			end

			local found = recurseDirectory(package, packageName)

			for child in found do
				print("Recursed to" .. child.Name)
				coroutine.yield(child)
			end
		end
	end)
end

local function searchPackages(packageFolder, lookingFor: string)
	local module
	for package in iterateWallyFolder(packageFolder, lookingFor) do
		if package.Name:lower() ~= lookingFor:lower() then -- the REAL package name is probably lowercase.
			continue
		end

		module = package
	end

	return module
end

local function dependencySearch(requester, moduleName: string) -- do we make it return a promise?
	assert(typeof(requester) == "Instance", "Invalid requester")
	assert(type(moduleName) == "string", "Invalid moduleName")

	local module

	module = requester:FindFirstChild(moduleName)

	if module then
		return module
	end

	for _, folder in pairs(LoadPriority) do
		if folder then
			module = searchPackages(folder, moduleName)

			if module then
				return module
			end
		end
	end

	for found in recurseDirectory(requester, moduleName) do
		if found.Name == moduleName then
			return found
		end
	end

	return nil
end

return {
	search = dependencySearch,
	priority = LoadPriority,
}
