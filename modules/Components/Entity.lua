--[[ Entity
    Handles the cleaning up of entities

    Self reliant, deletes itself when the entity is destroyed
]]

--> Services

local CollectionService = game:GetService("CollectionService")

--> Variables

local Entity = {}
Entity.__index = Entity

--> Public Functions

function Entity.new(entity: Instance, tag: string)
	assert(entity, "Entity is nil")

	local self = setmetatable(Entity, {})

	self._entity = entity

	self._tag = tag

	self._destroyListener = entity.Destroying:Connect(function()
		CollectionService:RemoveTag(entity, self._tag)

		self:Destroy()
	end)

	return self
end

function Entity:Destroy()
	self._destroyListener:Disconnect()
	setmetatable(self, nil)
end

return Entity
