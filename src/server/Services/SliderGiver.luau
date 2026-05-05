local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local SliderGiver = {}

function SliderGiver:start()
	local function give(player)
		local gui = ServerStorage.SliderGui:Clone()
		gui.Parent = player:WaitForChild("PlayerGui")
	end

	local first = Players:GetPlayers()[1]
	if first then
		give(first)
		return
	end

	local conn
	conn = Players.PlayerAdded:Connect(function(player)
		conn:Disconnect()
		give(player)
	end)
end

return SliderGiver
