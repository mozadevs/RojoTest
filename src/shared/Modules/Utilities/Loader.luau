-- Loads Service/Controller/Component modules from folders and runs init/start lifecycle.
local Loader = {}

export type Module = {
	init: ((self: any, registry: { [string]: any }) -> ())?,
	start: ((self: any, registry: { [string]: any }) -> ())?,
	[any]: any,
}

function Loader.load(folders: { Instance }): { [string]: Module }
	local registry: { [string]: Module } = {}
	for _, folder in folders do
		for _, child in folder:GetChildren() do
			if not child:IsA("ModuleScript") then continue end
			assert(not registry[child.Name], ("[Loader] duplicate module name %q in %s"):format(child.Name, folder:GetFullName()))
			registry[child.Name] = require(child) :: any
		end
	end
	return registry
end

function Loader.start(registry: { [string]: Module })
	for _, module in registry do
		if module.init then module:init(registry) end
	end
	for _, module in registry do
		if module.start then
			task.spawn(function() module:start(registry) end)
		end
	end
end

function Loader.loadComponents(folders: { Instance })
	for _, folder in folders do
		for _, child in folder:GetChildren() do
			if child:IsA("ModuleScript") then
				require(child)
			end
		end
	end
end

return Loader
