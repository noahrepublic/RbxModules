return function()
	local Loader = require(script.Parent)

	local modulesToLoad = script.Parent.TestModules

	describe("LoadChildren", function()
		it("should load children modules named 'Test'", function()
			local modules = Loader.LoadChildren(modulesToLoad, function(module)
				return module.Name == "Test"
			end)

			expect(modules).never.to.equal({})
			expect(modules.Test).to.be.ok()
		end)

		Loader.Modules["Test"] = nil
	end)
	describe("LoadDescendants", function()
		it("should load descendants modules named 'DescendantTest'", function()
			local modules = Loader.LoadDescendants(modulesToLoad, function(module)
				return module.Name == "DescendantTest"
			end)

			expect(modules).never.to.equal({})
			expect(modules.DescendantTest).to.be.ok()
		end)

		Loader.Modules["DescendantTest"] = nil
	end)
	describe("StartModules", function()
		it("should start a module named 'Test'", function()
			local modules = Loader.LoadDescendants(modulesToLoad)

			expect(modules).never.to.equal({})
			expect(modules.DescendantTest).to.be.ok()
			expect(modules.Test).to.be.ok()

			expect(function()
				Loader.StartModules(modules)
			end).never.to.throw()
		end)
	end)
	describe("Storing", function()
		it("should have a module named 'Test'", function()
			local module = Loader.Modules["Test"]

			expect(module).to.be.ok()
		end)

		it("should have a module named 'DescendantTest'", function()
			local module = Loader.Modules["DescendantTest"]

			expect(module).to.be.ok()
		end)
	end)
end
