local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

local DepthOfField = {}

local function Raycast(origin, dir)
	local IgnoreList = {Player.Character}

	local RaycastParameters = RaycastParams.new()
	RaycastParameters.FilterDescendantsInstances = IgnoreList
	RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
	local Result = workspace:Raycast(origin, origin + dir, RaycastParameters)

	if not Result then
		return 500
	end

	local Hit = Result.Instance

	if not Hit then
		return 500
	end

	return Result.Distance
end

local Scale = 1
-- local TargetScale = 1
local Distance = 0
local Camera = workspace.CurrentCamera
local function Calculate(deltaTime)
	Camera = workspace.CurrentCamera

	local Dist = Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 500)
	local DOF = Lighting:FindFirstChild("DepthOfField") or Instance.new("DepthOfFieldEffect", Lighting)
	Distance = Distance + (Dist - Distance) * (16 * deltaTime)
	DOF.FocusDistance = Distance
	DOF.InFocusRadius = Distance * 0.75

	-- if Dist <= 10 then
	-- 	TargetScale = 0.005
	-- elseif Dist <= 50 then
	-- 	TargetScale = 0.025
	-- elseif Dist <= 100 then
	-- 	TargetScale = 0.05
	-- elseif Dist <= 500 then
	-- 	TargetScale = 0.25
	-- elseif Dist <= 1000 then
	-- 	TargetScale = 0.5
	-- elseif Dist <= 2000 then
	-- 	TargetScale = 1
	-- end

	-- Scale = Scale + (TargetScale - Scale) * (16 * deltaTime)

	Player.PlayerGui.ScreenGui.Frame.Size = UDim2.new(0, 500 / Scale, 0, 4)
	Player.PlayerGui.ScreenGui.Frame.Focus.Position = UDim2.new(Dist / 500, 0, 0.5, 0)
	Player.PlayerGui.ScreenGui.Frame.Focus.Frame.Size = UDim2.new(0, ((Dist * 0.75) * 2) / Scale, 0.75, 0)
	Player.PlayerGui.ScreenGui.Frame.NFocus.Position = UDim2.new(Distance / 500, 0, 0.5, 0)
	Player.PlayerGui.ScreenGui.Frame.NFocus.Frame.Size = UDim2.new(0, ((Distance * 0.75) * 2) / Scale, 0.75, 0)
	Player.PlayerGui.ScreenGui.Dist.Text = math.floor(Dist * 10) / 10
end

function DepthOfField.update(deltaTime)
	Calculate(deltaTime)
end

return DepthOfField
