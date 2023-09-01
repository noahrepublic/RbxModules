return function()
	local loader = require(script.Parent)
	local require = loader.load(script.Parent)

	describe("(TestModule) direct child", function()
		it("should string load 'TestModule'", function()
			local testModule = require("TestModule")

			expect(testModule.Name).to.equal("TestModule")
		end)
	end)

	describe("(Test) one iteration down", function()
		it("should string load 'Test'", function()
			local test = require("Test")

			expect(test.Name).to.equal("Test")
		end)
	end)

	describe("(Test2) two iterations down", function()
		it("should string load module 'Test2'", function()
			local test2 = require("Test2")

			expect(test2.Name).to.equal("Test2")
		end)
	end)

	describe("(TestModule) direct module passed requiring", function()
		it("should require 'TestModule'", function()
			local testModule = require(script.Parent.TestModule)

			expect(testModule.Name).to.equal("TestModule")
		end)
	end)

	describe("should priority load", function() -- not really a good test :/
		it("should be in the priority table", function()
			table.insert(loader.priority, script.Parent.TestModule.TestModules2)
			expect(table.find(loader.priority, script.Parent.TestModule.TestModules2)).to.be.ok()
		end)

		it("should load by string", function()
			local testModule = require("BaseObject")

			expect(testModule).to.equal(require(script.Parent.TestModule.TestModules2._Index.BaseObject))
		end)
	end)
end
