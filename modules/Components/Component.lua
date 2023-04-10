--> Services

local CollectionService = game:GetService("CollectionService")

--> Constructor Definition

local Component = {
	Entities = {}, -- [Instance] = Entity
}
Component.__index = Component

--> Types

type Constructor = { -- For intelisense
	[string]: any,
	new: (Instance) -> nil,
	_tag: string, -- Component tag
}

--> Variables

local Entity = require(script.Parent.Entity)

--> Public Functions

--[[ Component.new()
    Creates a new component

    @param tag: string - The tag to bind to entities
    @param constructor: Constructor - The constructor to bind to entities
    @param startMethod: string | nil - The method to call on the constructor instance when the entity is binded
]]

function Component.new(tag: string, constructor: Constructor, startMethod: string | nil)
	assert(tag, "Tag is nil")

	local self = setmetatable(Component, {})

	self._tag = tag
	self._constructor = constructor
	self._binded = {} -- [Entity] = Constructor Instance
	self._startMethod = startMethod or nil

	self._listening = false
	self._initialized = false

	return self
end

--[[ Component:Start()
    Starts listening for new entities with the tag.
]]

function Component:Start()
	self._listening = true
	self._initialized = true

	self._bindListener = CollectionService:GetInstanceAddedSignal(self._tag):Connect(function(entity)
		self:_add(entity)
	end)

	self._unbindListener = CollectionService:GetInstanceRemovedSignal(self._tag):Connect(function(entity)
		self:_remove(entity)
	end)

	for _, entity in ipairs(CollectionService:GetTagged(self._tag)) do
		task.spawn(self._add, self, entity)
	end
end

--[[ Component:_add()
	Internal function to add an binded constructor to an entity.

	SHOULD ONLY BE CALLED INTERNALY

	@param entity: Instance - The instance to bind the constructor to
]]

function Component:_add(entity: Instance)
	local bindedConstructor = self._constructor.new(entity)

	self.Entities[entity] = Entity.new(entity, self._tag)
	self._binded[entity] = bindedConstructor

	if self._startMethod and bindedConstructor[self._startMethod] then
		bindedConstructor[self._startMethod](bindedConstructor)
	end
end

--[[ Component:_remove
	Internal function to remove an binded constructor from an entity.

	SHOULD ONLY BE CALLED INTERNALY

	@param entity: Instance - The instance to bind the constructor to
]]

function Component:_remove(entity)
	local bindedConstructor = self:Get(entity)

	self.Entities[entity]:Destroy()
	self._binded[entity] = nil
	if bindedConstructor and bindedConstructor.Destroy then
		bindedConstructor:Destroy()
	end
end

--[[ Component:Bind()
    Binds the entity to the component by adding the tag.

	@param entity: Instance - The instance to bind the constructor to
]]

function Component:Bind(entity: Instance)
	assert(entity, "Entity is nil")

	CollectionService:AddTag(entity, self._tag)
end

--[[ Component:Unbind()
    Unbinds the entity from the component by removing the tag.

	@param entity: Instance - The instance to bind the constructor to
]]

function Component:Unbind(entity: Instance)
	assert(entity, "Entity is nil")

	CollectionService:RemoveTag(entity, self._tag)
end

--[[ Component:UnbindAll()
    Unbinds all entities from the component.
]]

function Component:UnbindAll()
	for entity, _ in pairs(self._binded) do
		self:Unbind(entity)
	end
end

--[[ Component:Get(entity: Instance)
    Returns the constructor instance binded to the entity.
]]

function Component:Get(entity: Instance)
	assert(entity, "Entity is nil")

	return self._binded[entity]
end

--[[ Component:IsListening()
    Returns whether the component is listening for new entities.
]]

function Component:IsListening()
	return self._listening
end

--[[ Component:IsInitialized()
    Returns whether the component has been initialized.
]]

function Component:IsInitialized()
	return self._initialized
end

--[[ Component:Stop()
    Stops the component from listening for new entities.
]]

function Component:Stop()
	self._listening = false

	self._bindListener:Disconnect()
	self._unbindListener:Disconnect()
end

return Component
