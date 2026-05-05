local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Shared.Modules.Utilities.Component)

local ConveyorBelt = Component.new({ tag = "ConveyorBelt" })

function ConveyorBelt:construct()
	local main = self.instance.Main :: BasePart
	main.AssemblyLinearVelocity = main.CFrame.LookVector * (self.instance:GetAttribute("Speed") or 20)

	self.trove:Add(task.spawn(function()
		while true do
			task.wait(self.instance:GetAttribute("Interval") or 1)
			local bag = ReplicatedStorage.Bag:Clone()
			local _, bagSize = bag:GetBoundingBox()
			bag:PivotTo(main.CFrame * CFrame.new(0, main.Size.Y / 2 + bagSize.Y / 2, main.Size.Z / 2 - 2))
			bag.Parent = workspace
		end
	end))
end

return ConveyorBelt
