local RunService = game:GetService("RunService")

local AutoExposure = require(script.AutoExposure)

local Neon = {}

function Neon.ok()
	RunService:BindToRenderStep("NEON_AutoExposure", 201, AutoExposure.update)
end

return Neon