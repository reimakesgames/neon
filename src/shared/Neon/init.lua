local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local AutoExposure = require(script.AutoExposure)
local QuickInstance = require(script.QuickInstance)

local DefaultEffects = {
	BloomEffect = {
		Intensity = 0.25;
		Size = 24;
		Threshold = 0.75;
	};

	SunRaysEffect = {
		Intensity = 0.05;
		Spread = 0.5;
	}
}
table.freeze(DefaultEffects)

local Neon = {}

local function FindTemporaryFolder()
	local Temporary = Lighting:FindFirstChild("NEON_Temporary")
	if not Temporary then
		return QuickInstance("Folder", Lighting, {Name = "NEON_Temporary"})
	end
	return Temporary
end

local function FindCurrentEffects()
	local Bloom = Lighting:FindFirstChildWhichIsA("BloomEffect")
	local SunRays = Lighting:FindFirstChildWhichIsA("SunRaysEffect")

	return {Bloom, SunRays}
end

local function CreatePostProcessingEffects(effectTable)
	local CurrentEffects = FindCurrentEffects()
	local TemporaryFolder = FindTemporaryFolder()

	if #CurrentEffects > 0 then
		for _, Effect in CurrentEffects do
			Effect.Parent = TemporaryFolder
		end
	end

	for Class, Properties in effectTable do
		QuickInstance(Class, Lighting, Properties)
	end
end

function Neon.Start()
	RunService:BindToRenderStep("NEON_AutoExposure", 201, AutoExposure.update)
	CreatePostProcessingEffects(DefaultEffects)
end

return Neon