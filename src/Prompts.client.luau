local Players = game:GetService("Players")
local Prompts = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")

local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
local active = {}
local C = Color3.fromRGB
local label = C(255, 244, 219)

local function corner(item, radius)
    local rounding = Instance.new("UICorner", item)
    rounding.CornerRadius = UDim.new(0, radius)
end

local function remove(prompt)
    local record = active[prompt]
    if not record then return end
    active[prompt] = nil
    if record.destroyed then record.destroyed:Disconnect() end
    record.gui:Destroy()
end

local function create(prompt, inputType)
    if prompt.Style ~= Enum.ProximityPromptStyle.Custom or not prompt.Parent then return end
    remove(prompt)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Lodge prompt"
    billboard.Adornee = prompt.Parent
    billboard.Size = UDim2.fromOffset(212, 61)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 1.46, 0)
    billboard.AlwaysOnTop = true
    billboard.Active = true
    billboard.Parent = gui

    local holder = Instance.new("Frame", billboard)
    holder.Size = UDim2.fromScale(1, 1)
    holder.BackgroundColor3 = C(17, 43, 42)
    holder.BackgroundTransparency = 0.08
    holder.BorderSizePixel = 0
    corner(holder, 10)
    local edge = Instance.new("UIStroke", holder)
    edge.Color, edge.Thickness = C(231, 218, 176), 1.4

    local key = Instance.new("TextButton", holder)
    key.TextColor3, key.BackgroundColor3 = C(21, 38, 38), C(255, 196, 112)
    key.Font, key.TextSize = Enum.Font.GothamBold, 17
    key.Position, key.Size = UDim2.fromOffset(8, 9), UDim2.fromOffset(45, 43)
    key.BorderSizePixel = 0
    key.Selectable = false
    corner(key, 7)

    local keyName = prompt.KeyboardKeyCode
    if inputType == Enum.ProximityPromptInputType.Gamepad then
        keyName = prompt.GamepadKeyCode
    end
    local glyph = UserInputService:GetStringForKeyCode(keyName)
    if prompt.GamepadKeyCode == keyName and glyph == "" then glyph = keyName.Name:gsub("^Button", "") end
    if glyph == "" then glyph = keyName.Name end
    key.Text = inputType == Enum.ProximityPromptInputType.Touch and "Tap" or glyph

    local action = Instance.new("TextLabel", holder)
    action.Position, action.Size = UDim2.fromOffset(63, 9), UDim2.fromOffset(144, 24)
    action.Text, action.TextColor3 = prompt.ActionText, label
    action.Font, action.TextSize = Enum.Font.FredokaOne, 17
    action.BackgroundTransparency, action.TextXAlignment = 1, Enum.TextXAlignment.Left

    local detail = Instance.new("TextLabel", holder)
    detail.Position, detail.Size = UDim2.fromOffset(63, 33), UDim2.fromOffset(142, 17)
    detail.Text, detail.TextColor3 = prompt.ObjectText, C(193, 220, 208)
    detail.Font, detail.TextSize = Enum.Font.GothamMedium, 11
    detail.TextTruncate = Enum.TextTruncate.AtEnd
    detail.BackgroundTransparency, detail.TextXAlignment = 1, Enum.TextXAlignment.Left

    local down = false
    key.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if down then return end
            down = true
            key.BackgroundColor3 = C(226, 148, 75)
            prompt:InputHoldBegin()
        end
    end)
    key.InputEnded:Connect(function(input)
        if not down then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            down = false
            key.BackgroundColor3 = C(255, 196, 112)
            prompt:InputHoldEnd()
        end
    end)
    active[prompt] = {gui=billboard, destroyed=prompt.Destroying:Connect(function() remove(prompt) end)}
end

Prompts.PromptShown:Connect(create)
Prompts.PromptHidden:Connect(remove)
