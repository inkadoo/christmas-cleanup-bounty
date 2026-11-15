local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundBank = require(ReplicatedStorage.LodgeSoundBank)

local FX = {}
local C, V = Color3.fromRGB, Vector3.new
local soundBus = Instance.new("SoundGroup")
soundBus.Name = "Holly Lodge SFX"
soundBus.Volume = 0.9
soundBus.Parent = SoundService

function FX.sound(role, emitter, speed)
    local recipe = SoundBank[role]
    if not recipe then return end
    local voice = Instance.new("Sound")
    voice.Name = "Lodge " .. role
    voice.SoundId, voice.Volume = recipe.id, recipe.volume
    voice.PlaybackSpeed = speed or recipe.speed or 1
    voice.RollOffMode = Enum.RollOffMode.InverseTapered
    voice.RollOffMinDistance, voice.RollOffMaxDistance = 8, recipe.range or 48
    voice.Looped = recipe.looped == true
    voice.SoundGroup = soundBus
    voice.Parent = emitter or SoundService
    voice:Play()
    if not voice.Looped then
        voice.Ended:Once(function() voice:Destroy() end)
        Debris:AddItem(voice, 7)
    end
    return voice
end

local function point(position, lifetime)
    local p = Instance.new("Part")
    p.Name = "Lodge effect origin"
    p.Size = V(0.1, 0.1, 0.1)
    p.Position = position
    p.Transparency = 1
    p.Anchored = true
    p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
    p.Parent = workspace
    Debris:AddItem(p, lifetime)
    return p
end

local function burst(parent, name, color, speed, life, size, acceleration, count)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = name
    emitter.Texture = name == "Ember burst" and "rbxasset://textures/particles/fire_sparks_main.dds"
        or "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Color = color
    emitter.Size = size
    emitter.Lifetime, emitter.Speed = life, speed
    emitter.Acceleration = acceleration
    emitter.Rate = 0
    emitter.SpreadAngle = Vector2.new(52, 52)
    emitter.LightEmission = 0.64
    emitter.Orientation = Enum.ParticleOrientation.FacingCamera
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(0.62, 0.26),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Parent = parent
    emitter:Emit(count)
    Debris:AddItem(emitter, life.Max + 0.15)
end

local function sequence(a,b)
    return NumberSequence.new({
        NumberSequenceKeypoint.new(0,a),
        NumberSequenceKeypoint.new(0.48,a*1.18),
        NumberSequenceKeypoint.new(1,b),
    })
end

function FX.clockIn(board)
    local source = typeof(board) == "Instance" and board or nil
    FX.sound("clockIn", source)
    if source then
        burst(source, "Check-in chime", ColorSequence.new(C(254,212,133), C(255,246,196)),
            NumberRange.new(1.6, 3.8), NumberRange.new(0.25, 0.65),
            sequence(0.13, 0), V(0,-2,0), 12)
    end
end

function FX.carried(model)
    FX.sound("grab", model.PrimaryPart)
end

function FX.throw(model)
    local body = model.PrimaryPart
    FX.sound("throw", body)
    local left, right = Instance.new("Attachment"), Instance.new("Attachment")
    left.Position, right.Position = V(-0.43,0,0), V(0.43,0,0)
    left.Parent, right.Parent = body, body
    local trail = Instance.new("Trail")
    trail.Name = "Toss motion"
    trail.Attachment0, trail.Attachment1 = left, right
    trail.Color = ColorSequence.new(C(255,233,185), C(251,163,83))
    trail.Transparency = NumberSequence.new(0.33, 1)
    trail.Lifetime = 0.18
    trail.LightEmission = 0.33
    trail.FaceCamera = true
    trail.Parent = body
end

function FX.hearthHit(position)
    local source = point(position + V(0,0.35,0), 3)
    FX.sound("ember", source)
    burst(source, "Ember burst", ColorSequence.new(C(255,230,141), C(241,77,30)),
        NumberRange.new(6, 16), NumberRange.new(0.42, 0.94),
        sequence(0.24, 0.04), V(0,-8,1), 32)
    local light = Instance.new("PointLight", source)
    light.Color, light.Brightness, light.Range = C(255,142,82), 5.8, 16
    TweenService:Create(light,TweenInfo.new(0.57,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Brightness=0}):Play()
    local smoke = Instance.new("ParticleEmitter")
    smoke.Name = "Rising hearth smoke"
    smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
    smoke.Color = ColorSequence.new(C(108,80,80), C(61,55,69))
    smoke.Size = sequence(0.68, 2.2)
    smoke.Lifetime, smoke.Speed = NumberRange.new(0.65, 1.35), NumberRange.new(2, 4.5)
    smoke.Transparency = NumberSequence.new(0.42,1)
    smoke.Rate, smoke.Drag = 0, 2
    smoke.Acceleration = V(0,3.5,0)
    smoke.SpreadAngle = Vector2.new(35, 35)
    smoke.Parent = source
    smoke:Emit(7)
end

function FX.mop(position)
    local source = point(position + V(0, 0.1, 0), 3)
    FX.sound("mop", source)
    burst(source, "Clean stroke", ColorSequence.new(C(223,255,238), C(114,225,205)),
        NumberRange.new(1.1, 4.4), NumberRange.new(0.22, 0.5),
        sequence(0.16,0), V(0,-8,0), 12)
end

function FX.rinse(bucket)
    FX.sound("rinse", bucket)
    burst(bucket, "Rinse spray", ColorSequence.new(C(222,251,255), C(124,201,236)),
        NumberRange.new(3.1, 6.2), NumberRange.new(0.22, 0.55),
        sequence(0.19, 0.04), V(0,-24,0), 24)
    local wash = TweenService:Create(bucket,TweenInfo.new(0.52),{Color=C(88,164,178)})
    wash:Play()
end

function FX.hearthIdle(flame)
    local sparks = Instance.new("ParticleEmitter")
    sparks.Name = "Hearth embers"
    sparks.Texture = "rbxasset://textures/particles/fire_sparks_main.dds"
    sparks.Color = ColorSequence.new(C(255,188,79),C(206,77,38))
    sparks.Rate = 4
    sparks.Lifetime = NumberRange.new(0.65,1.3)
    sparks.Speed = NumberRange.new(1.2,3.4)
    sparks.Drag = 1
    sparks.Size = sequence(0.12,0)
    sparks.Transparency = NumberSequence.new(0.14,1)
    sparks.SpreadAngle = Vector2.new(24,24)
    sparks.Acceleration = V(0,2.4,0)
    sparks.LightEmission = 0.75
    sparks.Parent = flame
    FX.sound("hearth", flame)
end

return FX
