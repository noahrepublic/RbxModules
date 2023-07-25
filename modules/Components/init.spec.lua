return function()
	--> Services
	local CollectionService = game:GetService("CollectionService")

	local Components = require(script.Parent)

	local tag = "_TestComponent"

	local class = {
		_tag = tag,
	}
	class.__index = class

	function class.new()
		local self = setmetatable({}, class)

		self.value = 0

		return self
	end

	local Component = Components.LoadComponent(class)

	-- Create temporary entities

	local entity

	beforeAll(function()
		entity = Instance.new("Part")

		entity.Anchored = true
		entity.Parent = workspace
	end)

	afterEach(function()
		Component:UnbindAll()
		expect(#CollectionService:GetTagged(tag)).to.equal(0)
	end)

	describe("Pre-Start binding", function()
		it("should have all functions", function()
			expect(Component.Get).to.be.a("function")
			expect(Component.Bind).to.be.a("function")
			expect(Component.Unbind).to.be.a("function")
			expect(Component.UnbindAll).to.be.a("function")
			expect(Component.Start).to.be.a("function")
			expect(Component.Stop).to.be.a("function")
		end)

		it("should bind a component to the entity", function()
			CollectionService:AddTag(entity, tag)
			expect(CollectionService:HasTag(entity, tag)).to.equal(true)

			Component:Start()

			expect(Component:Get(entity)).to.be.a("table")
			expect(Component._initialized).to.equal(true)
		end)
	end)

	describe("Binding", function()
		it("should bind a component to an entity", function()
			Component:Bind(entity)
			expect(CollectionService:HasTag(entity, tag)).to.equal(true)
			expect(Component:Get(entity)).to.be.ok()
		end)

		it("should unbind a component from an entity", function()
			Component:Unbind(entity)
			expect(CollectionService:HasTag(entity, tag)).to.equal(false)
			expect(Component:Get(entity)).to.equal(nil)
		end)
	end)

	describe("Cloning should work", function()
		it("should init a new component", function()
			Component:Bind(entity)

			local test = Component:Get(entity)
			expect(test).to.be.ok()

			local clonedEntity = entity:Clone()
			clonedEntity.Parent = workspace

			expect(Component:Get(clonedEntity)).to.be.ok()

			clonedEntity:Destroy()
		end)
	end)

	describe("Unbind on Entity Destroy", function()
		it("should unbind a component from an entity when it is destroyed", function()
			Component:Bind(entity)
			expect(CollectionService:HasTag(entity, tag)).to.equal(true)

			entity:Destroy()
			expect(CollectionService:HasTag(entity, tag)).to.equal(false)
			expect(Component:Get(entity)).to.equal(nil)
		end)
	end)
end
