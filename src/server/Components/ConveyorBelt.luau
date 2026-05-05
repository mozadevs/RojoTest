local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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
			bag.PrimaryPart = paint
			paint.Material = MATERIALS[math.random(#MATERIALS)]
			paint.Color = Color3.new(math.random(), math.random(), math.random())
			paint.Anchored = true
			local _, bagSize = bag:GetBoundingBox()
			bag:PivotTo(main.CFrame * CFrame.new(0, main.Size.Y / 2 + bagSize.Y / 2, main.Size.Z / 2 - 2))
			bag:ScaleTo(0.01)
			bag.Parent = workspace

			local scale = Instance.new("NumberValue")
			scale.Value = 0.01
			scale.Parent = bag
			scale.Changed:Connect(function(v) bag:ScaleTo(v) end)
			local tween = TweenService:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Value = 1 })
			tween.Completed:Connect(function() paint.Anchored = false end)
			tween:Play()
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
			CollectionService:RemoveTag(model, "Bag")
			local paint = model.Paint :: MeshPart
			paint.Anchored = true
			local scale = Instance.new("NumberValue")
			scale.Value = 1
			scale.Parent = model
			scale.Changed:Connect(function(v) model:ScaleTo(v) end)
			local tween = TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Value = 0.01 })
			tween.Completed:Connect(function() model:Destroy() end)
			tween:Play()
		end
	end)
end

return ConveyorBelt
