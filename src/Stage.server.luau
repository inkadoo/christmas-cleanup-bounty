local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local V, C = Vector3.new, Color3.fromRGB
local red, gold = C(157,45,53), C(255,177,74)
local dark = C(57,40,39)
local World=require(script.Parent.LodgeWorld)
local map,part,build,prompt=World.map,World.part,World.build,World.prompt
local start,throw,firePos,flame,bin=World.start,World.throw,World.firePos,World.flame,World.bin
local mess=Instance.new("Folder",workspace)
mess.Name="Elf Ragdolls"
local stains=Instance.new("Folder",workspace)
stains.Name="Shift Stains"
local spots={V(-15,1.25,-28),V(14,1.25,-34),V(-8,1.25,-16),V(13,1.25,-12),
    V(-37,1.25,-22),V(-29,1.25,-31),V(29,1.25,-24),V(37,1.25,-32),V(-15,1.25,1),V(16,1.25,1)}
local function cylinder(name,pos,length,diameter,color,material)
    local p=build(name,pos.X,pos.Y,pos.Z,length,diameter,diameter,color,material)
    p.Shape=Enum.PartType.Cylinder
    p.CFrame*=CFrame.Angles(0,0,math.pi/2)
    return p
end
local supply=V(6.8,0,-37.2)
local bucketBase=cylinder("Galvanized bucket base",supply+V(0,0.41,0),0.25,1.3,C(111,127,141),Enum.Material.Metal)
local bucketWater=cylinder("Wash water",supply+V(0,1,0),0.045,1.42,C(70,118,138),Enum.Material.Glass)
for i=0,19 do
    local a=i*math.pi/10
    local facing=CFrame.new(supply+V(0,0.83,0))*CFrame.Angles(0,a,0)
    local shell=part(map,"Bucket wall",V(0.24,0.81,0.08),supply,C(141,157,164),Enum.Material.Metal)
    shell.CFrame=facing*CFrame.new(0,0,0.72)*CFrame.Angles(math.rad(-8),0,0)
    local rim=part(map,"Rolled rim",V(0.24,0.08,0.11),supply,C(181,190,192),Enum.Material.Metal)
    rim.CFrame=facing*CFrame.new(0,0.42,0.77)
end
for i=0,11 do
    local a=i*math.pi/12
    local nextA=(i+1)*math.pi/12
    local center=supply+V(0,1.16,0)
    local p1,p2=center+V(0.79*math.cos(a),0.76*math.sin(a),0),center+V(0.79*math.cos(nextA),0.76*math.sin(nextA),0)
    local wire=part(map,"Bucket handle",V(0.048,0.048,(p2-p1).Magnitude),(p1+p2)/2,C(176,184,191),Enum.Material.Metal)
    wire.CFrame=CFrame.lookAt((p1+p2)/2,p2)
    wire.CanCollide=false
end
local mopDisplay=Instance.new("Model",map)
mopDisplay.Name="Mop rack"
local mopBase=supply+V(-1.04,0.56,0.24)
local mopAxis=CFrame.new(mopBase)*CFrame.Angles(0,0,math.rad(-12))
local pole=cylinder("Ashwood mop handle",mopBase,4.45,0.13,C(145,99,66),Enum.Material.Wood)
pole.CFrame=mopAxis*CFrame.new(0,2.38,0)*CFrame.Angles(0,0,math.pi/2)
pole.CanCollide=false
pole.Parent=mopDisplay
local collar=cylinder("Crimped mop collar",mopBase,0.34,0.28,C(124,135,142),Enum.Material.Metal)
collar.CFrame=mopAxis*CFrame.new(0,0.34,0)*CFrame.Angles(0,0,math.pi/2)
collar.CanCollide=false
collar.Parent=mopDisplay
for i=1,30 do
    local a=i*2.399
    local cord=part(mopDisplay,"Cotton mop yarn",V(0.09,0.54+i%4*0.045,0.09),mopBase+V(math.cos(a)*0.28,0.1,math.sin(a)*0.28),
        C(202+i%4*10,192+i%4*10,170+i%4*10),Enum.Material.Fabric)
    cord.CFrame*=CFrame.Angles(math.sin(a)*0.71,0,math.cos(a)*0.71)
    cord.CanCollide=false
end
local take=prompt(pole,"Take mop","Mop rack",7)
local function getMop(player)
    local backpack=player:FindFirstChildOfClass("Backpack")
    local character=player.Character
    return (character and character:FindFirstChild("Mop")) or (backpack and backpack:FindFirstChild("Mop"))
end
local maxDirt=8
take.Triggered:Connect(function(player)
    local character=player.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    local backpack=player:FindFirstChildOfClass("Backpack")
    if not root or not humanoid or not backpack or getMop(player) or (root.Position-pole.Position).Magnitude>9 then return end
    local tool=Instance.new("Tool")
    tool.Name,tool.ToolTip,tool.CanBeDropped="Mop","Use beside a stain. Rinse in the bucket.",false
    tool.Grip=CFrame.new(0,-0.35,0)*CFrame.Angles(0,0,math.rad(10))
    tool:SetAttribute("Dirt",0)
    local grip
    local pieces={}
    for _,source in mopDisplay:GetChildren() do
        if source:IsA("BasePart") then
            local piece=source:Clone()
            piece:ClearAllChildren()
            piece.Anchored,piece.CanCollide,piece.CanQuery,piece.CanTouch,piece.Massless=false,false,false,false,true
            piece.Parent=tool
            if source==pole then grip=piece piece.Name="Handle"
            else table.insert(pieces,piece) end
        end
    end
    for _,piece in pieces do
        local weld=Instance.new("WeldConstraint",piece)
        weld.Part0,weld.Part1=grip,piece
    end
    local last=0
    local defaultGrip=tool.Grip
    tool.Activated:Connect(function()
        local now=os.clock()
        if tool.Parent~=player.Character or now-last<0.42 then return end
        local currentRoot=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not currentRoot then return end
        last=now
        tool.Grip=defaultGrip*CFrame.Angles(0,0,math.rad(-28))
        task.delay(0.22,function()
            if tool.Parent then tool.Grip=defaultGrip end
        end)
        local dirt=tool:GetAttribute("Dirt")
        if dirt>=maxDirt then return end
        local front=currentRoot.Position+currentRoot.CFrame.LookVector*2.6
        local nearest,range=nil,6.5
        for _,group in stains:GetChildren() do
            local center=group:GetAttribute("Center")
            local distance=center and (center-front).Magnitude
            if distance and distance<range then nearest,range=group,distance end
        end
        if nearest then
            nearest:Destroy()
            tool:SetAttribute("Dirt",dirt+1)
            player:SetAttribute("Mopped",(player:GetAttribute("Mopped") or 0)+1)
        end
    end)
    tool.Parent=backpack
    humanoid:EquipTool(tool)
end)
local wash=prompt(bucketBase,"Rinse mop","Cleanup station",7)
wash.KeyboardKeyCode=Enum.KeyCode.R
wash.GamepadKeyCode=Enum.KeyCode.ButtonY
wash.Triggered:Connect(function(player)
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local mop=getMop(player)
    if not root or not mop or (root.Position-bucketBase.Position).Magnitude>8 then return end
    local now=os.clock()
    if now-(mop:GetAttribute("LastRinse") or -1)<0.7 then return end
    mop:SetAttribute("LastRinse",now)
    mop:SetAttribute("Dirt",0)
    local splash=Instance.new("ParticleEmitter",bucketWater)
    splash.Rate=0
    splash.Color=ColorSequence.new(C(151,218,235))
    splash.Speed=NumberRange.new(3,6)
    splash.Lifetime=NumberRange.new(0.22,0.45)
    splash.Acceleration=V(0,-20,0)
    splash.Size=NumberSequence.new(0.12)
    splash:Emit(12)
    Debris:AddItem(splash,0.7)
end)
local MAX_TIME=180
local shiftOwner,deadline,cleared
local carries={}
local inFlight={}
local function state(player,value)
    player:SetAttribute("ShiftState",value)
end
local function cleanupCarry(player)
    local carry=carries[player]
    if carry then
        carry.weld:Destroy()
        if carry.model.Parent then carry.model.Parent=mess end
        carries[player]=nil
        throw.Enabled=false
    end
    return carry
end
local function release(player)
    local carry=cleanupCarry(player)
    if not carry or not carry.model.Parent then return end
    carry.pickup.Enabled=true
    for _,p in carry.model:GetChildren() do
        if p:IsA("BasePart") then
            p.CanCollide=p==carry.model.PrimaryPart or p.Name=="Head" or p.Name=="Sleeve" or p.Name=="Boot"
            p.Massless=not p.CanCollide
        end
    end
    carry.model.PrimaryPart:SetNetworkOwner(nil)
    player:SetAttribute("HoldingElf",false)
end
local function joint(torso,limb,worldPoint)
    local a,b=Instance.new("Attachment",torso),Instance.new("Attachment",limb)
    a.Position=torso.CFrame:PointToObjectSpace(worldPoint)
    b.Position=limb.CFrame:PointToObjectSpace(worldPoint)
    local socket=Instance.new("BallSocketConstraint",limb)
    socket.Attachment0,socket.Attachment1,socket.LimitsEnabled,socket.UpperAngle=a,b,true,80
    local filter=Instance.new("NoCollisionConstraint",limb)
    filter.Part0,filter.Part1=torso,limb
end
local bloodRandom=Random.new(735)
local function bloodGroup(surface,normal,count,spread)
    local group=Instance.new("Folder",stains)
    group.Name="Blood splatter"
    group:SetAttribute("Center",surface)
    local basis=CFrame.lookAt(surface,surface+normal)
    for i=1,count do
        local angle=bloodRandom:NextNumber(0,math.pi*2)
        local radius=i==1 and 0 or bloodRandom:NextNumber(0.21,spread)
        local width=i==1 and 1.5 or bloodRandom:NextNumber(0.15,0.99)
        local depth=i==1 and 0.91 or bloodRandom:NextNumber(0.07,0.7)
        local tint=C(111,12,30):Lerp(C(175,22,46),bloodRandom:NextNumber())
        local p=part(group,"Blood",V(0.026,width,depth),surface,tint)
        p.Shape=Enum.PartType.Cylinder
        p.CFrame=basis*CFrame.new(math.cos(angle)*radius,math.sin(angle)*radius,-0.008)
            *CFrame.Angles(0,0,angle)*CFrame.Angles(0,math.pi/2,0)
        p.CanCollide,p.CanQuery,p.CastShadow=false,false,false
    end
end
local function splatter(pos)
    local surface=pos.Z> -4 and -0.295 or 0.3
    bloodGroup(V(pos.X,surface,pos.Z),V(0,1,0),15,1.8)
end
local function dressMess()
    for _,zone in {{0,55,15,11},{0,-27,18,17},{-33,-26,8,10},{33,-26,8,10}} do
        local x,z,w,d=table.unpack(zone)
        for i=1,15 do
            local dx=bloodRandom:NextNumber(-w,w)
            local dz=bloodRandom:NextNumber(-d,d)
            bloodGroup(V(x+dx,math.abs(dx)<4.9 and 0.337 or 0.254,z+dz),V(0,1,0),bloodRandom:NextInteger(5,8),1.2)
        end
        for i=1,6 do
            local side=i%2==0 and 1 or -1
            local wallX=x+side*(w+((w==18 and 3) or (w==8 and 2.5) or 2)-0.34)
            bloodGroup(V(wallX,bloodRandom:NextNumber(0.75,3.8),z+bloodRandom:NextNumber(-d+2,d-2)),V(-side,0,0),5,0.82)
        end
    end
    for i=1,24 do
        local x=i%2==0 and bloodRandom:NextNumber(-3.2,3.2) or bloodRandom:NextNumber(-32,32)
        local z=i%2==0 and bloodRandom:NextNumber(2,37) or bloodRandom:NextNumber(-1.6,1.6)
        bloodGroup(V(x,-0.145,z),V(0,1,0),5,0.81)
    end
end
local function ragdoll(pos,index)
    local model=Instance.new("Model",mess)
    model.Name="Workshop elf "..index
    local tunic=index%2==0 and C(43,127,83) or C(153,53,67)
    local skin=C(210,153,117)
    local function limb(name,size,offset,color)
        local p=part(model,name,size,pos+offset,color)
        p.CustomPhysicalProperties=PhysicalProperties.new(0.6,0.55,0.15)
        return p
    end
    local torso=limb("Torso",V(1.14,1.31,0.69),V(0,0.9,0),tunic)
    torso.Material=Enum.Material.SmoothPlastic
    model.PrimaryPart=torso
    local head=limb("Head",V(0.87,0.82,0.72),V(0,1.92,0),skin)
    head.Shape=Enum.PartType.Ball
    joint(torso,head,pos+V(0,1.56,0))
    local function detail(name,shape,size,offset,color,base,rotation)
        local p=limb(name,size,offset,color)
        p.Shape=shape
        p.CanCollide=false
        p.Massless=true
        if rotation then p.CFrame*=rotation end
        local weld=Instance.new("WeldConstraint",p)
        weld.Part0,weld.Part1=base,p
        return p
    end
    local ball,block=Enum.PartType.Ball,Enum.PartType.Block
    local headY=1.92
    for _,side in {-1,1} do
        detail("Pointed ear",ball,V(0.34,0.17,0.17),V(side*0.38,headY+0.04,0),skin,head,
            CFrame.Angles(0,0,math.rad(side*28)))
        detail("Eye",ball,V(0.23,0.18,0.099),V(side*0.173,headY+0.055,-0.331),C(247,237,221),head)
        detail("Iris",ball,V(0.084,0.104,0.048),V(side*0.165,headY+0.049,-0.378),C(55,39,35),head)
        detail("Brow",block,V(0.107,0.024,0.022),V(side*0.17,headY+0.184,-0.327),C(82,55,42),head,
            CFrame.Angles(0,0,side*0.12))
    end
    detail("Nose",ball,V(0.108,0.14,0.15),V(0,headY-0.032,-0.34),skin:Lerp(red,0.14),head)
    detail("Mouth",block,V(0.15,0.024,0.038),V(0,headY-0.158,-0.337),C(114,61,51),head)
    detail("Hair",ball,V(0.69,0.35,0.69),V(0,headY+0.22,0.049),C(83,49,34),head)
    for i=1,4 do
        local offset=V(-0.25+i*0.1,headY+0.29-(i%2)*0.07,-0.21)
        detail("Sculpted forelock",ball,V(0.25,0.23,0.23),offset,C(98,59,38),head,CFrame.Angles(0,0,0.28*i))
    end
    detail("Wool collar",block,V(0.58,0.13,0.67),V(0,1.49,0),C(204,203,174),torso)
    detail("Leather belt",block,V(1.07,0.18,0.65),V(0,0.59,0),dark,torso)
    detail("Brass buckle",block,V(0.23,0.18,0.06),V(0,0.59,-0.34),gold,torso)
    for i=1,3 do
        detail("Coat button",ball,V(0.08,0.08,0.05),V(0,0.68+i*0.22,-0.33),gold,torso)
    end
    local cap=limb("Elf cap",V(0.83,0.45,0.78),V(0,2.34,0),red)
    cap.Shape=Enum.PartType.Ball
    cap.CanCollide=false
    cap.Material=Enum.Material.Fabric
    detail("Cap trim",ball,V(0.87,0.17,0.8),V(0,2.22,0),C(229,221,198),head)
    detail("Cap tip",ball,V(0.29,0.44,0.34),V(0.22,2.51,0.06),red,head,CFrame.Angles(0,0,-0.69))
    detail("Cap pompom",ball,V(0.19,0.19,0.19),V(0.335,2.64,0.06),C(228,219,181),head)
    local hat=Instance.new("WeldConstraint",cap)
    hat.Part0,hat.Part1=head,cap
    for _,side in {-1,1} do
        local arm=limb("Sleeve",V(0.38,1.1,0.39),V(side*0.73,0.88,0),tunic)
        joint(torso,arm,pos+V(side*0.56,1.37,0))
        arm.Material=Enum.Material.SmoothPlastic
        detail("Hand",ball,V(0.32,0.28,0.3),V(side*0.73,0.28,0),skin,arm)
        detail("Cuff",block,V(0.4,0.11,0.42),V(side*0.73,0.43,0),C(216,210,185),arm)
        local leg=limb("Boot",V(0.42,1.08,0.49),V(side*0.29,-0.18,0),dark)
        joint(torso,leg,pos+V(side*0.29,0.29,0))
        detail("Boot toe",ball,V(0.43,0.32,0.64),V(side*0.29,-0.62,-0.14),dark,leg)
    end
    model:PivotTo(CFrame.new(pos+V(0,0.5,0))*CFrame.Angles(0,index*0.83,0)*CFrame.Angles(math.rad(84),0,0))
    local pickup=prompt(torso,"Pick up","Elf ragdoll")
    pickup.Triggered:Connect(function(player)
        if shiftOwner~=player or carries[player] or not pickup.Enabled or workspace:GetServerTimeNow()>=deadline then return end
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root or (root.Position-torso.Position).Magnitude>10 then return end
        pickup.Enabled=false
        for _,p in model:GetChildren() do
            if p:IsA("BasePart") then p.CanCollide=false p.Massless=true end
        end
        model:PivotTo(root.CFrame*CFrame.new(0,0.35,-2.1))
        model.Parent=player.Character
        local weld=Instance.new("WeldConstraint",torso)
        weld.Part0,weld.Part1=root,torso
        carries[player]={model=model,weld=weld,pickup=pickup}
        player:SetAttribute("HoldingElf",true)
        throw.Enabled=true
    end)
    splatter(pos)
    for _,p in model:GetChildren() do
        if p:IsA("BasePart") then p.Anchored=false end
    end
    for _,p in model:GetChildren() do
        if p:IsA("BasePart") and p:CanSetNetworkOwnership() then p:SetNetworkOwner(nil) end
    end
end
local function finish(player,outcome)
    if shiftOwner~=player then return end
    shiftOwner=nil
    cleanupCarry(player)
    mess:ClearAllChildren()
    stains:ClearAllChildren()
    table.clear(inFlight)
    start.Enabled=true
    player:SetAttribute("HoldingElf",false)
    player:SetAttribute("TimeRemaining",math.max(0,math.floor(deadline-workspace:GetServerTimeNow())))
    state(player,outcome)
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame=CFrame.new(0,4,57) end
end
start.Triggered:Connect(function(player)
    if shiftOwner then return end
    shiftOwner,cleared=player,0
    deadline=workspace:GetServerTimeNow()+MAX_TIME
    start.Enabled=false
    player:SetAttribute("Cleared",0)
    player:SetAttribute("ShiftDeadline",deadline)
    state(player,"playing")
    player:SetAttribute("Mopped",0)
    dressMess()
    for i,pos in spots do ragdoll(pos,i) end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame=CFrame.lookAt(V(0,4,5),V(0,4,-15)) end
end)
throw.Triggered:Connect(function(player)
    if shiftOwner~=player or not carries[player] or workspace:GetServerTimeNow()>=deadline then return end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position-bin.Position).Magnitude>10 then return end
    local carry=cleanupCarry(player)
    player:SetAttribute("HoldingElf",false)
    local model=carry.model
    local torso=model.PrimaryPart
    local origin=V(0,3.2,-35)
    model:PivotTo(CFrame.new(origin))
    local flight=0.33
    local launch=(firePos-origin)/flight+V(0,workspace.Gravity*flight/2,0)
    for _,p in model:GetChildren() do
        if p:IsA("BasePart") then
            p.Massless=false
            p:SetNetworkOwner(nil)
            p.AssemblyLinearVelocity=launch
            p.AssemblyAngularVelocity=V(5,3,1)
        end
    end
    inFlight[model]=workspace:GetServerTimeNow()+flight
end)
RunService.Heartbeat:Connect(function()
    if not shiftOwner then return end
    local now=workspace:GetServerTimeNow()
    for model,arrival in inFlight do
        if now>=arrival then
            inFlight[model]=nil
            local burst=Instance.new("Fire",flame)
            burst.Size,burst.Heat,burst.Color=9,11,C(255,190,63)
            Debris:AddItem(burst,0.55)
            model:Destroy()
            cleared+=1
            shiftOwner:SetAttribute("Cleared",cleared)
        end
    end
    if cleared==#spots then finish(shiftOwner,"complete")
    elseif now>=deadline then finish(shiftOwner,"expired") end
end)
local function setup(player)
    state(player,"lobby")
    player.CharacterRemoving:Connect(function() release(player) end)
end
Players.PlayerAdded:Connect(setup)
for _,player in Players:GetPlayers() do setup(player) end
Players.PlayerRemoving:Connect(function(player) finish(player,"lobby") end)
