--[[ Components
    Component system for binding constructors to entities.
]]

--> Variables

local Components = {
	Components = {},
}
Components.__index = Components

local Component = require(script.Component)

--> Types

type Constructor = { -- For intelisense
	[string]: any,
	new: (Entity) -> nil,
	_tag: string, -- Component tag
}

--> Public Functions

function Components.LoadComponent(constructor: Constructor)
	assert(constructor._tag, "Passed constructor does not have a tag to bind")

	local component = Component.new(constructor._tag, constructor)

	Components.Components[constructor._tag] = component

	return setmetatable(Components, component)
end

return Components
