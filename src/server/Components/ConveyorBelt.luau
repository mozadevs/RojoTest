local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Shared.Modules.Utilities.Component)

local MATERIALS = Enum.Material:GetEnumItems()

local ConveyorBelt = Component.new({ tag = "ConveyorBelt" })

function ConveyorBelt:construct()
	local main = self.instance.Main :: BasePart
	main.AssemblyLinearVelocity = main.CFrame.LookVector * (self.instance:GetAttribute("Speed") or 20)

	self.trove:Add(task.spawn(function()
		while true do
			task.wait(self.instance:GetAttribute("Interval") or 1)
			local bag = ReplicatedStorage.Bag:Clone()
			local paint = bag.Paint :: MeshPart
			paint.Material = MATERIALS[math.random(#MATERIALS)]
			paint.Color = Color3.new(math.random(), math.random(), math.random())
			local _, bagSize = bag:GetBoundingBox()
			bag:PivotTo(main.CFrame * CFrame.new(0, main.Size.Y / 2 + bagSize.Y / 2, main.Size.Z / 2 - 2))
			bag.Parent = workspace
		end
	end))

	local endZone = Instance.new("Part")
	endZone.Anchored = true
	endZone.CanCollide = false
	endZone.CanTouch = true
	endZone.Transparency = 1
	endZone.Size = Vector3.new(main.Size.X, 6, 1)
	endZone.CFrame = main.CFrame * CFrame.new(0, main.Size.Y / 2 + 3, -main.Size.Z / 2)
	endZone.Parent = main
	self.trove:Add(endZone)

	self.trove:Connect(endZone.Touched, function(hit)
		local model = hit:FindFirstAncestorOfClass("Model")
		if model and CollectionService:HasTag(model, "Bag") then
			model:Destroy()
		end
	end)
end

return ConveyorBelt
