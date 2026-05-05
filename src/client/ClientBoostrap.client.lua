-- Bootstraps the client: loads Components, then runs Core + UI Controllers through init/start lifecycle.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Shared.Modules
local Loader = require(Modules.Utilities.Loader)

Loader.loadComponents({ Modules.Components })

local Controllers = Loader.load({ Modules.Core, Modules.UI })
Loader.start(Controllers)

print("[Client] Bootstrap complete")
