-- @ CloneTrooper1019, 2019
-- Modified by reimakesgames, 2022

local AutoExposure = {}

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local UP = Vector3.new(0, 1, 0)

local function getBrightness(color: Color3)
	local _, _, v = color:ToHSV()
	return v
end

local function computeOcclusion(origin, dir)
	local occlusion = 0

	-- local ray = Ray.new(origin, dir.Unit * 5000)
	-- local ignoreList = {Player.Character}

	local IgnoreList = {Player.Character}

	while occlusion < 1 do
		-- local hit = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList, false, true)
		local RaycastParameters = RaycastParams.new()
		RaycastParameters.FilterDescendantsInstances = IgnoreList
		RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
		local Result = workspace:Raycast(origin, origin + dir, RaycastParameters)

		if not Result then
			break
		end

		local Hit = Result.Instance

		if not Hit then
			break
		end

		if Hit.Transparency < 0.95 and Hit.CastShadow then
			local opacity = math.clamp(1 - Hit.Transparency, 0, 1)
			local blockDepth = (Hit.Size.Magnitude * opacity) / 20
			occlusion = math.min(1, occlusion + blockDepth)
		end

		table.insert(IgnoreList, Hit)
	end

	return occlusion
end

local camera = workspace.CurrentCamera
local oldOrigin = Vector3.new(0, 0, 0)
local origin = workspace.CurrentCamera.CFrame.Position
local sunDir = Lighting:GetSunDirection()
local dayLight = math.clamp(sunDir.Y * 10, -0.5, 1)
local indoorLevel = computeOcclusion(oldOrigin, UP * 5000)
local sunOcclusion = computeOcclusion(oldOrigin, sunDir * 5000)
local indoorLight = getBrightness(Lighting.Ambient)
local outdoorLight = getBrightness(Lighting.OutdoorAmbient) * 2
local SunBlindness = math.clamp(sunDir:Dot(camera.CFrame.LookVector), 0, 1)

local CanCompute = true

function AutoExposure.update(deltaTime)
	camera = workspace.CurrentCamera

	if not camera then
		return
	end

	origin = camera.CFrame.Position
	if (oldOrigin - origin).Magnitude < 0.05 then
		CanCompute = false
	else
		CanCompute = true
	end
	oldOrigin = origin

	sunDir = Lighting:GetSunDirection()
	dayLight = math.clamp(sunDir.Y * 10, -0.5, 1)

	if dayLight < 0 then
		sunDir = Lighting:GetMoonDirection()
	end

	if CanCompute then
		indoorLevel = computeOcclusion(origin, UP * 5000)
		sunOcclusion = computeOcclusion(origin, sunDir * 5000)

		indoorLight = getBrightness(Lighting.Ambient)
		outdoorLight = getBrightness(Lighting.OutdoorAmbient) * 2
	end

	SunBlindness = math.clamp(sunDir:Dot(camera.CFrame.LookVector), 0, 1)
	SunBlindness = (SunBlindness + 2) * 90
	SunBlindness = -(math.cos(math.rad(SunBlindness)) + 1)

	local strength = 1 - (outdoorLight + ((indoorLight - outdoorLight) * indoorLevel))
	local target = sunOcclusion * strength * dayLight
	if sunOcclusion == 0 then
		target = SunBlindness
	end

	local current = Lighting.ExposureCompensation

	if (current < target) then
		current = math.min(target, current + deltaTime * 0.5)
	elseif (current > target) then
		current = math.max(target, current - deltaTime * 0.5)
	end

	Lighting.ExposureCompensation = current
	Lighting.Bloom.Threshold = 0.75 - (current * 0.5)
end

return AutoExposure
