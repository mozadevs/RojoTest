-- Bootstraps the server: loads shared/server Components, then runs Services through init/start lifecycle.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Loader = require(ReplicatedStorage.Shared.Modules.Utilities.Loader)

Loader.loadComponents({
	ServerScriptService.Server.Components,
	ReplicatedStorage.Shared.Modules.Components,
})

local Services = Loader.load({ ServerScriptService.Server.Services })
Loader.start(Services)

print("[Server] Bootstrap complete")
