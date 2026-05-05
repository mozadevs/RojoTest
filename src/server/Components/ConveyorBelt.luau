local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Shared.Modules.Utilities.Component)

local ConveyorBelt = Component.new({ tag = "ConveyorBelt" })

function ConveyorBelt:construct()
	local main = self.instance.Main :: BasePart
	main.AssemblyLinearVelocity = main.CFrame.LookVector * (self.instance:GetAttribute("Speed") or 20)
end

return ConveyorBelt
