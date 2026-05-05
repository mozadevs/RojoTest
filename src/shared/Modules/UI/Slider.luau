local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Slider = {}

function Slider:start()
	local gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("SliderGui")
	local frame = gui.Frame :: Frame
	local button = frame.Slider :: TextButton

	button.Active = true
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	local halfScale = button.AbsoluteSize.X / 2 / frame.AbsoluteSize.X
	button.Position = UDim2.new(halfScale, 0, 0.5, 0)
	button.Text = "1"

	local sliderRemote = ReplicatedStorage.SliderChanged
	local lastValue = 1
	local dragging = false

	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local rawNorm = math.clamp((input.Position.X - frame.AbsolutePosition.X - frame.AbsoluteSize.X * halfScale) / (frame.AbsoluteSize.X * (1 - 2 * halfScale)), 0, 1)
		local value = 1 + math.round(rawNorm * 9)
		button.Position = UDim2.new(halfScale + (value - 1) / 9 * (1 - 2 * halfScale), 0, 0.5, 0)
		button.Text = tostring(value)
		if value ~= lastValue then
			lastValue = value
			sliderRemote:FireServer(value)
		end
	end)
end

return Slider
