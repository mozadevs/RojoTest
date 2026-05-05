-- Tag-driven instance components with managed lifecycle (construct/start/stop) and update hooks.
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Trove = require(script.Parent.Trove)

local registered: { [string]: any } = {}

local Component = {}

export type Config = {
	tag: string,
	ancestors: { Instance }?,
}

local function inAncestors(instance: Instance, ancestors: { Instance }): boolean
	for _, ancestor in ancestors do
		if instance:IsDescendantOf(ancestor) then
			return true
		end
	end
	return false
end

local function construct(class, instance: Instance)
	if class._instances[instance] then return end
	if not inAncestors(instance, class.ancestors) then
		print(("[Component] SKIP %s on %s — not in ancestors"):format(class.tag, instance:GetFullName()))
		return
	end

	print(("[Component] CONSTRUCT %s on %s"):format(class.tag, instance:GetFullName()))
	local self = setmetatable({ instance = instance, trove = Trove.new() }, class)
	class._instances[instance] = self

	if self.construct then self:construct() end
	if class._instances[instance] ~= self then return end

	if self.heartbeatUpdate then
		self.trove:Connect(RunService.Heartbeat, function(dt) self:heartbeatUpdate(dt) end)
	end
	if self.steppedUpdate then
		self.trove:Connect(RunService.Stepped, function(_, dt) self:steppedUpdate(dt) end)
	end
	if RunService:IsClient() and self.renderSteppedUpdate then
		self.trove:Connect(RunService.RenderStepped, function(dt) self:renderSteppedUpdate(dt) end)
	end

	if self.start then
		task.spawn(function()
			if class._instances[instance] == self then
				print(("[Component] START %s on %s"):format(class.tag, instance:GetFullName()))
				self:start()
			end
		end)
	end
end

local function destruct(class, instance: Instance)
	local self = class._instances[instance]
	if not self then return end
	class._instances[instance] = nil

	if self.stop then self:stop() end
	self.trove:Destroy()
end

function Component.new(config: Config)
	assert(type(config) == "table", "[Component] config required")
	assert(type(config.tag) == "string", "[Component] config.tag required")
	assert(not registered[config.tag], ("[Component] tag %q already registered"):format(config.tag))

	local class = {}
	class.__index = class
	class.tag = config.tag
	class.ancestors = config.ancestors or { workspace }
	class._instances = {}
	class._trove = Trove.new()

	registered[config.tag] = class
	print(("[Component] registered tag %q (ancestors=%d, initial tagged=%d)"):format(config.tag, #class.ancestors, #CollectionService:GetTagged(config.tag)))

	function class.fromInstance(instance: Instance)
		return class._instances[instance]
	end

	function class.all()
		local list = {}
		for _, comp in class._instances do
			table.insert(list, comp)
		end
		return list
	end

	function class.destroy()
		if not registered[config.tag] then return end
		registered[config.tag] = nil
		for instance in class._instances do
			destruct(class, instance)
		end
		class._trove:Destroy()
	end

	function class:getComponent(other)
		return other._instances[self.instance]
	end

	class._trove:Connect(CollectionService:GetInstanceAddedSignal(config.tag), function(instance)
		construct(class, instance)
	end)
	class._trove:Connect(CollectionService:GetInstanceRemovedSignal(config.tag), function(instance)
		destruct(class, instance)
	end)
	for _, instance in CollectionService:GetTagged(config.tag) do
		task.defer(construct, class, instance)
	end

	return class
end

function Component.fromTag(tag: string)
	return registered[tag]
end

return Component
