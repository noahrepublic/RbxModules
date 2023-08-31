return function()
	local require = require(script.Parent)(script.Parent)

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
end
