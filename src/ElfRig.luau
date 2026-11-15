local PhysicsService = game:GetService("PhysicsService")
local Design = require(script.Parent.ElfDesign)
local Rig = {}
local V, C = Vector3.new, Color3.fromRGB
local COLLISION_GROUP = "WorkshopRagdolls"
local floorWeight = PhysicalProperties.new(0.72, 0.67, 0.08)
local carryWeight = PhysicalProperties.new(0.055, 0.55, 0.04)

if not PhysicsService:IsCollisionGroupRegistered(COLLISION_GROUP) then
    PhysicsService:RegisterCollisionGroup(COLLISION_GROUP)
end
PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP, COLLISION_GROUP, false)

local function vector(row)
    return V(row[1], row[2], row[3])
end

local function connect(parent, child, label, point, angle, twist)
    local a, b = Instance.new("Attachment"), Instance.new("Attachment")
    a.Name, b.Name = label .. " body", label .. " limb"
    a.Position = parent.CFrame:PointToObjectSpace(point)
    b.Position = child.CFrame:PointToObjectSpace(point)
    a.Parent, b.Parent = parent, child
    local socket = Instance.new("BallSocketConstraint")
    socket.Name = label
    socket.Attachment0, socket.Attachment1 = a, b
    socket.LimitsEnabled, socket.UpperAngle = true, angle
    socket.TwistLimitsEnabled = true
    socket.TwistLowerAngle, socket.TwistUpperAngle = -twist, twist
    socket.MaxFrictionTorque = label == "Neck" and 1.8 or 0.65
    socket.Restitution = 0.05
    socket.Parent = child
end

function Rig.bodies(model)
    local parts = {}
    for _, member in model:GetChildren() do
        if member:GetAttribute("PhysicsBody") then
            table.insert(parts, member)
        end
    end
    return parts
end

function Rig.setMode(model, mode, carrier)
    local collision = mode == "floor"
    for _, body in Rig.bodies(model) do
        body.CanCollide = collision
        body.Massless = mode == "carried"
        body.CustomPhysicalProperties = mode == "carried" and carryWeight or floorWeight
        if (mode ~= "carried" or carrier) and body:CanSetNetworkOwnership() then
            body:SetNetworkOwner(carrier)
        end
    end
end

function Rig.build(index, origin, upright)
    local variant = Design.variants[(index - 1) % #Design.variants + 1]
    local name, palette = variant[1], variant[2]
    local model = Instance.new("Model")
    model.Name = "Workshop elf " .. index
    model:SetAttribute("ElfName", name)
    local bodies = {}

    for _, item in Design.bodies do
        local part = Instance.new("Part")
        part.Name, part.Size = item[1], vector(item[2])
        part.Position = vector(item[3])
        part.Transparency, part.Anchored = 1, true
        part.CanTouch, part.CastShadow = false, false
        part.CollisionGroup = COLLISION_GROUP
        part.CustomPhysicalProperties = floorWeight
        part:SetAttribute("PhysicsBody", true)
        part.Parent = model
        bodies[part.Name] = part
    end

    for _, item in Design.parts[name] do
        local body, name, shape, size, position, color, tilt = table.unpack(item)
        local piece = Instance.new("Part")
        piece.Name, piece.Size = name, vector(size)
        piece.CFrame = CFrame.new(vector(position)) * CFrame.Angles(0, 0, tilt)
        local rgb = typeof(color) == "string" and palette[color] or color
        piece.Color = C(rgb[1], rgb[2], rgb[3])
        if shape == "oval" then
            local ellipsoid = Instance.new("SpecialMesh")
            ellipsoid.MeshType = Enum.MeshType.Sphere
            ellipsoid.Parent = piece
        end
        piece.Material = color == "metal" and Enum.Material.Metal or Enum.Material.SmoothPlastic
        piece.Anchored, piece.Massless = true, true
        piece.CanCollide, piece.CanQuery, piece.CanTouch = false, false, false
        piece.CastShadow = name == "Face" or name == "Tailored coat" or name == "Hat crown"
        piece.Parent = model
        local weld = Instance.new("WeldConstraint", piece)
        weld.Part0, weld.Part1 = bodies[body], piece
    end

    for _, item in Design.joints do
        connect(bodies[item[2]], bodies[item[3]], item[1], vector(item[4]), item[5], item[6])
    end
    model.PrimaryPart = bodies.Torso
    if upright then
        model:PivotTo(CFrame.new(origin)*CFrame.Angles(0,math.pi,0))
        for _, body in Rig.bodies(model) do
            body.CanCollide,body.CanQuery=false,false
        end
    else
        local yaw = index * 1.673
        local roll = math.rad(79 + index % 4 * 7)
        model:PivotTo(CFrame.new(origin + V(0, 0.43, 0)) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(roll, 0, 0))
    end
    return model
end

function Rig.releaseIntoWorld(model, parent)
    model.Parent = parent
    for _, part in model:GetChildren() do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
    Rig.setMode(model, "floor")
end

return Rig
