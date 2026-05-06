local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local CollisionSetup = {}

function CollisionSetup:start()
	PhysicsService:RegisterCollisionGroup("Bags")
	PhysicsService:RegisterCollisionGroup("Players")
	PhysicsService:CollisionGroupSetCollidable("Bags", "Bags", false)
	PhysicsService:CollisionGroupSetCollidable("Bags", "Players", false)

	local function assignCharacter(character: Model)
		for _, descendant in character:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.CollisionGroup = "Players"
			end
		end
		character.DescendantAdded:Connect(function(descendant)
			if descendant:IsA("BasePart") then
				descendant.CollisionGroup = "Players"
			end
		end)
	end

	local function trackPlayer(player: Player)
		if player.Character then
			assignCharacter(player.Character)
		end
		player.CharacterAdded:Connect(assignCharacter)
	end

	for _, player in Players:GetPlayers() do
		trackPlayer(player)
	end
	Players.PlayerAdded:Connect(trackPlayer)
end

return CollisionSetup
