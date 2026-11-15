local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local emitterOrigin = Instance.new("Part")
emitterOrigin.Name = "Local lodge snowfall"
emitterOrigin.Size = Vector3.new(31, 0.1, 31)
emitterOrigin.Anchored = true
emitterOrigin.CanCollide, emitterOrigin.CanQuery, emitterOrigin.CanTouch = false, false, false
emitterOrigin.Transparency, emitterOrigin.CastShadow = 1, false
emitterOrigin.Parent = workspace

local flakes = Instance.new("ParticleEmitter")
flakes.Name = "Snow flurries"
flakes.Texture = "rbxasset://textures/particles/sparkles_main.dds"
flakes.Rate = 35
flakes.Enabled = false
flakes.LightInfluence = 0.28
flakes.SpreadAngle = Vector2.new(9, 14)
flakes.EmissionDirection = Enum.NormalId.Bottom
flakes.Speed = NumberRange.new(1.35, 3.34)
flakes.Lifetime = NumberRange.new(2.8, 5.7)
flakes.Acceleration = Vector3.new(1.35, -0.88, 0.63)
flakes.Size = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.075, 0.025),
    NumberSequenceKeypoint.new(0.58, 0.098, 0.041),
    NumberSequenceKeypoint.new(1, 0.036, 0.018),
})
flakes.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.14, 0.22),
    NumberSequenceKeypoint.new(0.68, 0.34),
    NumberSequenceKeypoint.new(1, 1),
})
flakes.Color = ColorSequence.new(Color3.fromRGB(225,242,255), Color3.fromRGB(188,223,251))
flakes.Shape = Enum.ParticleEmitterShape.Box
flakes.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
flakes.Parent = emitterOrigin

local roofCheck = RaycastParams.new()
roofCheck.FilterType = Enum.RaycastFilterType.Exclude
local elapsed = 0
local connection
connection = RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < 0.23 then return end
    elapsed = 0
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then flakes.Enabled = false return end
    local camera = workspace.CurrentCamera
    local position = root.Position
    roofCheck.FilterDescendantsInstances = {character, emitterOrigin}
    local inside = workspace:Raycast(position, Vector3.new(0, 24, 0), roofCheck) ~= nil
    if inside and flakes.Enabled then flakes:Clear() end
    flakes.Enabled = not inside
    if camera then
        local ahead = camera.CFrame.LookVector * 6
        emitterOrigin.Position = position + Vector3.new(ahead.X, 10, ahead.Z)
    end
end)
script.Destroying:Connect(function()
    connection:Disconnect()
    emitterOrigin:Destroy()
end)
