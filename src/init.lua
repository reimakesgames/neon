local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local AutoExposure = require(script.AutoExposure)
local DepthOfField = require(script.DepthOfField)
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
	};

	DepthOfFieldEffect = {
		FarIntensity = 0.2;
		NearIntensity = 0.1;
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
	local DepthOfField = Lighting:FindFirstAncestorWhichIsA("DepthOfFieldEffect")

	return {Bloom, SunRays, DepthOfField}
end

local function SwapEffects(swapToBuiltIn: boolean)
	local TempFolder = Lighting:FindFirstChild("NEON_Temporary")
	local HiddenEffects = TempFolder:GetChildren()
	local CurrentEffects = FindCurrentEffects()
	local BuiltInIsHidden = HiddenEffects[1]:FindFirstChild("NEONBuiltIn") and true or false
	local ShouldSwap = BuiltInIsHidden == swapToBuiltIn

	if ShouldSwap then
		for _, Effect in CurrentEffects do
			Effect.Parent = TempFolder
		end

		for _, Effect in HiddenEffects do
			Effect.Parent = Lighting
		end
	end
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
		local NewEffect = QuickInstance(Class, Lighting, Properties)
		QuickInstance("StringValue", NewEffect, {Name = "NEONBuiltIn"})
	end
end

function Neon.Start()
	CreatePostProcessingEffects(DefaultEffects)
	RunService:BindToRenderStep("NEON_AutoExposure", 201, AutoExposure.update)
	RunService:BindToRenderStep("NEON_DepthOfField", 202, DepthOfField.update)
end

function Neon.SwapEffects(swapToBuiltIn: boolean)
	SwapEffects(swapToBuiltIn)
end

return Neon
