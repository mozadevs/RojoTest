local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BagClicks = {}

function BagClicks:start()
	ReplicatedStorage.BagClicked.OnClientEvent:Connect(function(id)
		print("[Client] Bag clicked: " .. tostring(id))
	end)
end

return BagClicks
