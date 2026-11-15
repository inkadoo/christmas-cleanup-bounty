-- The lodge apron is attached over the player's existing avatar during a shift.
local Kit = {}
local C, V = Color3.fromRGB,Vector3.new
local canvas, leather, seam, brass = C(51,78,69), C(94,56,41), C(165,119,67), C(230,173,85)

function Kit.clear(character)
    local old = character and character:FindFirstChild("Holly Lodge work apron")
    if old then old:Destroy() end
end

function Kit.equip(character)
    if not character or character:FindFirstChild("Holly Lodge work apron") then return end
    local chest = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if not chest or not chest:IsA("BasePart") then return end
    local lower = character:FindFirstChild("LowerTorso")
    if not lower or not lower:IsA("BasePart") then lower = chest end

    local kit = Instance.new("Model")
    kit.Name = "Holly Lodge work apron"
    local function piece(base, label, size, localPosition, color, material, yaw)
        local part = Instance.new("Part")
        part.Name, part.Size = label, size
        part.Color, part.Material = color, material or Enum.Material.SmoothPlastic
        part.CFrame = base.CFrame * CFrame.new(localPosition) * CFrame.Angles(0,0,yaw or 0)
        part.Massless, part.CanCollide, part.CanTouch, part.CanQuery = true,false,false,false
        part.CastShadow = false
        part.Parent = kit
        local weld = Instance.new("WeldConstraint",part)
        weld.Part0,weld.Part1 = base,part
    end

    local x,y,z = chest.Size.X,chest.Size.Y,chest.Size.Z
    local front = -z/2
    piece(chest,"Canvas bib",V(x*.61,y*.59,.09),V(0,-y*.12,front-.048),canvas,Enum.Material.Fabric)
    for _,side in {-1,1} do
        piece(chest,"Shoulder strap",V(x*.064,y*.51,.075),V(side*x*.245,y*.292,front-.047),leather,nil,side*.09)
        piece(chest,"Bib rivet",V(.08,.08,.043),V(side*x*.231,y*.119,front-.103),brass,Enum.Material.Metal)
        piece(chest,"Cross-back apron strap",V(x*.056,y*.88,.066),V(side*x*.128,0.01,z/2+.041),leather,nil,side*.30)
        piece(chest,"Bib stitched edge",V(.025,y*.52,.022),V(side*x*.263,-y*.11,front-.104),seam)
    end
    local lx,ly,lz = lower.Size.X,lower.Size.Y,lower.Size.Z
    local lowerY = lower == chest and -ly*.42 or -ly*.06
    piece(lower,"Utility pocket",V(lx*.53,ly*.28,.12),V(0,lowerY,-lz/2-.07),leather)
    piece(lower,"Pocket flap",V(lx*.54,ly*.087,.041),V(0,lowerY+ly*.12,-lz/2-.142),seam)
    piece(lower,"Waist tie",V(lx*.79,ly*.14,.09),V(0,lowerY+ly*.18,-lz/2-.052),leather)
    piece(lower,"Back waist tie",V(lx*.79,ly*.14,.071),V(0,lowerY+ly*.18,lz/2+.044),leather)
    kit.Parent=character
end

function Kit.grabPose(character, root)
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    local upper=character:FindFirstChild("UpperTorso")
    local assets={}
    if not humanoid or humanoid.RigType~=Enum.HumanoidRigType.R15 or not upper then
        return assets
    end

    local width=upper.Size.X
    for _,side in {-1, 1} do
        local name=side==-1 and "Left" or "Right"
        local shoulder=character:FindFirstChild(name.."UpperArm")
        local hand=character:FindFirstChild(name.."Hand")
        if shoulder and hand then
            local target=Instance.new("Attachment")
            target.Name="Elf carry "..name.." grip"
            target.Position=Vector3.new(side*width*.29,-0.22,-1.52)
            target.Parent=root
            local pole=Instance.new("Attachment")
            pole.Name="Elf carry "..name.." elbow"
            pole.Position=Vector3.new(side*width*.62,-0.95,-0.24)
            pole.Parent=root
            local control=Instance.new("IKControl")
            control.Name="Elf carry "..name.." arm"
            control.Type=Enum.IKControlType.Position
            control.ChainRoot,control.EndEffector=shoulder,hand
            control.Target,control.Pole=target,pole
            control.Priority,control.Weight,control.SmoothTime=8,0.96,0.085
            control.Parent=humanoid
            table.insert(assets,control)
            table.insert(assets,target)
            table.insert(assets,pole)
        end
    end
    return assets
end

return Kit
