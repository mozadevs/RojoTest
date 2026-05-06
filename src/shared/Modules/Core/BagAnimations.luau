local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local BagAnimations = {}

local activeTweens = setmetatable({}, { __mode = "k" })
local generations = setmetatable({}, { __mode = "k" })

local function tweenScale(bag, from, to, info)
	local gen = (generations[bag] or 0) + 1
	generations[bag] = gen
	if activeTweens[bag] then activeTweens[bag]:Cancel() end

	bag:ScaleTo(from)
	local scale = Instance.new("NumberValue")
	scale.Value = from
	scale.Changed:Connect(function(v)
		if generations[bag] == gen and bag.Parent then
			bag:ScaleTo(math.clamp(v, 0.001, 1.2))
		end
	end)
	local tween = TweenService:Create(scale, info, { Value = to })
	activeTweens[bag] = tween
	tween.Completed:Connect(function()
		if generations[bag] == gen and bag.Parent then
			bag:ScaleTo(to)
		end
	end)
	tween:Play()
end

function BagAnimations:start()
	CollectionService:GetInstanceAddedSignal("Bag"):Connect(function(bag)
		tweenScale(bag, 0.01, 1, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
	end)
	CollectionService:GetInstanceRemovedSignal("Bag"):Connect(function(bag)
		tweenScale(bag, bag:GetScale(), 0.01, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
	end)
end

return BagAnimations
