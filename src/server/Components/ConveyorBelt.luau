local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Shared.Modules.Utilities.Component)

local MATERIALS = Enum.Material:GetEnumItems()
local BagClickedRemote = ReplicatedStorage.BagClicked
local SliderChangedRemote = ReplicatedStorage.SliderChanged
local nextBagId = 0

local ConveyorBelt = Component.new({ tag = "ConveyorBelt" })

function ConveyorBelt:construct()
	local main = self.instance.Main :: BasePart
	main.AssemblyLinearVelocity = main.CFrame.LookVector * (self.instance:GetAttribute("Speed") or 20)

	self.trove:Connect(SliderChangedRemote.OnServerEvent, function(_, value)
		self.instance:SetAttribute("Interval", value)
	end)

	self.trove:Add(task.spawn(function()
		local lastSpawn = os.clock()
		while true do
			task.wait()
			if os.clock() - lastSpawn < (self.instance:GetAttribute("Interval") or 1) then continue end
			lastSpawn = os.clock()
			local bag = ReplicatedStorage.Bag:Clone()
			local paint = bag.Paint :: MeshPart
			bag.PrimaryPart = paint
			paint.Material = MATERIALS[math.random(#MATERIALS)]
			paint.Color = Color3.new(math.random(), math.random(), math.random())
			for _, part in bag:GetDescendants() do
				if part:IsA("BasePart") then
					part.CollisionGroup = "Bags"
				end
			end

			nextBagId += 1
			local id = nextBagId
			bag:SetAttribute("BagId", id)
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Click"
			prompt.RequiresLineOfSight = false
			prompt.Parent = bag.Plastic
			prompt.Triggered:Connect(function(player)
				print("[Server] Bag clicked: " .. id)
				BagClickedRemote:FireClient(player, id)
			end)
			local _, bagSize = bag:GetBoundingBox()
			bag:PivotTo(main.CFrame * CFrame.new(0, main.Size.Y / 2 + bagSize.Y / 2 + 1, main.Size.Z / 2 - 2))
			paint.Anchored = true
			bag.Parent = workspace
			task.delay(0.4, function()
				if paint.Parent then
					paint.Anchored = false
					paint.AssemblyLinearVelocity = main.CFrame.LookVector * (self.instance:GetAttribute("Speed") or 20)
				end
			end)
		end
	end))

	local endZone = Instance.new("Part")
	endZone.Anchored = true
	endZone.CanCollide = false
	endZone.CanTouch = true
	endZone.Transparency = 1
	endZone.Size = Vector3.new(main.Size.X, 6, 4)
	endZone.CFrame = main.CFrame * CFrame.new(0, main.Size.Y / 2 + 3, -main.Size.Z / 2)
	endZone.Parent = main
	self.trove:Add(endZone)

	self.trove:Connect(endZone.Touched, function(hit)
		local model = hit:FindFirstAncestorOfClass("Model")
		if model and CollectionService:HasTag(model, "Bag") then
			CollectionService:RemoveTag(model, "Bag")
			local paint = model.Paint :: MeshPart
			paint.Anchored = true
			task.delay(0.3, function() model:Destroy() end)
		end
	end)
end

return ConveyorBelt
