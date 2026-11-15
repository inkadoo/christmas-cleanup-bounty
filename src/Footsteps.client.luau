local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Bank = require(ReplicatedStorage:WaitForChild("LodgeSoundBank"))
local localPlayer = Players.LocalPlayer

local roles = {
    [Enum.Material.Wood]="woodStep",
    [Enum.Material.WoodPlanks]="woodStep",
    [Enum.Material.Fabric]="woodStep",
    [Enum.Material.Snow]="snowStep",
    [Enum.Material.Ice]="snowStep",
    [Enum.Material.Slate]="slateStep",
    [Enum.Material.Brick]="slateStep",
    [Enum.Material.CeramicTiles]="slateStep",
}
local random = Random.new()
local binding
local function bind(character)
    if binding then binding:Disconnect() end
    local humanoid = character:WaitForChild("Humanoid", 8)
    local root = character:WaitForChild("HumanoidRootPart", 8)
    if not humanoid or not root or character ~= localPlayer.Character then return end
    local bus = SoundService:WaitForChild("Holly Lodge SFX", 8)
    if not bus or character ~= localPlayer.Character then return end
    local samples = {}
    for _, role in {"woodStep","snowStep","slateStep"} do
        local sample = Instance.new("Sound")
        sample.Name = "Lodge " .. role
        sample.SoundId = Bank[role].id
        sample.Volume = Bank[role].volume
        sample.SoundGroup = bus
        sample.RollOffMinDistance = 5
        sample.RollOffMaxDistance = 17
        sample.Parent = root
        samples[role] = sample
    end
    local lastPosition = root.Position
    local budget, elapsed = 0, 0
    local defaultRunning
    local defaultVolume
    binding = RunService.Heartbeat:Connect(function(dt)
        if not root.Parent or character ~= localPlayer.Character then return end
        elapsed += dt
        if elapsed < 0.075 then return end
        elapsed = 0
        local position = root.Position
        local direction = (position-lastPosition)*Vector3.new(1,0,1)
        local distance = direction.Magnitude
        lastPosition = position
        local role = roles[humanoid.FloorMaterial]
        local sample = role and samples[role]
        local replacement = sample and sample.IsLoaded

        local current = root:FindFirstChild("Running")
        if current and current:IsA("Sound") then
            if current~=defaultRunning then
                defaultRunning,defaultVolume=current,current.Volume
            end
            current.Volume=replacement and 0 or defaultVolume
        end

        if not replacement or humanoid.MoveDirection.Magnitude<0.1 or distance>11 then
            budget = 0
            return
        end
        budget += distance
        local stride = 4.9
        if budget >= stride then
            budget %= stride
            sample.PlaybackSpeed = random:NextNumber(0.93,1.14)
            sample.TimePosition = 0
            sample:Play()
        end
    end)
end

localPlayer.CharacterAdded:Connect(bind)
if localPlayer.Character then task.spawn(bind,localPlayer.Character) end
