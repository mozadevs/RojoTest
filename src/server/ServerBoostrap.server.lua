-- Bootstraps the server: loads shared/server Components, then runs Services through init/start lifecycle.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Loader = require(ReplicatedStorage.Modules.Utilities.Loader)

Loader.loadComponents({
	ServerScriptService.Components,
	ReplicatedStorage.Modules.Components,
})

local Services = Loader.load({ ServerScriptService.Services })
Loader.start(Services)

print("[Server] Bootstrap complete")
