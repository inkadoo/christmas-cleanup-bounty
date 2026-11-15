local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local V, C = Vector3.new, Color3.fromRGB
local World=require(script.Parent.LodgeWorld)
local Rig=require(script.Parent.ElfRig)
local FX=require(script.Parent.ShiftFX)
local CrewKit=require(script.Parent.CrewKit)
local map,part,build,prompt=World.map,World.part,World.build,World.prompt
local start,throw,firePos,flame,bin=World.start,World.throw,World.firePos,World.flame,World.bin
FX.hearthIdle(flame)
local attendant=Rig.build(1,V(5.55,2.04,46.4),true)
attendant.Name="Holly, shift lead"
attendant.Parent=map
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
local shiftOwner,deadline,cleared

local function paintMop(tool,dirt)
    local amount=dirt/maxDirt
    for index,piece in tool:GetChildren() do
        if piece:IsA("BasePart") and piece.Name=="Cotton mop yarn" then
            local clean=piece:GetAttribute("CleanColor")
            if clean then
                piece.Color=clean:Lerp(C(131,42,60),math.clamp(amount*(0.70+index%4*0.16),0,1))
            end
        end
    end
end
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
            piece:SetAttribute("CleanColor",piece.Color)
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
        if shiftOwner~=player or tool.Parent~=player.Character or now-last<0.42 then return end
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
            local center=nearest:GetAttribute("Center")
            nearest:Destroy()
            FX.mop(center)
            tool:SetAttribute("Dirt",dirt+1)
            paintMop(tool,dirt+1)
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
    paintMop(mop,0)
    FX.rinse(bucketWater)
end)
local MAX_TIME=180
local carries={}
local inFlight={}
local function state(player,value)
    player:SetAttribute("ShiftState",value)
end
local function cleanupCarry(player)
    local carry=carries[player]
    if carry then
        for _,object in carry.pose do object:Destroy() end
        carry.weld:Destroy()
        if carry.model.Parent then carry.model.Parent=mess end
        carries[player]=nil
        throw.Enabled=false
        World.markThrow(false)
    end
    return carry
end
local function release(player)
    local carry=cleanupCarry(player)
    if not carry or not carry.model.Parent then return end
    carry.pickup.Enabled=true
    Rig.setMode(carry.model, "floor")
    player:SetAttribute("HoldingElf",false)
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
    local model=Rig.build(index,pos)
    local torso=model.PrimaryPart
    local pickup=prompt(torso,"Pick up",model:GetAttribute("ElfName").." • Workshop elf")
    pickup.Triggered:Connect(function(player)
        if shiftOwner~=player or carries[player] or not pickup.Enabled or workspace:GetServerTimeNow()>=deadline then return end
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root or (root.Position-torso.Position).Magnitude>10 then return end
        pickup.Enabled=false
        Rig.setMode(model, "carried", player)
        model:PivotTo(root.CFrame*CFrame.new(0,0.12,-1.73)*CFrame.Angles(math.rad(22),0,math.rad(-72)))
        model.Parent=player.Character
        local weld=Instance.new("WeldConstraint",torso)
        weld.Part0,weld.Part1=root,torso
        local pose=CrewKit.grabPose(player.Character,root)
        carries[player]={model=model,weld=weld,pickup=pickup,pose=pose}
        player:SetAttribute("HoldingElf",true)
        player:SetAttribute("CarriedElf",model:GetAttribute("ElfName"))
        FX.carried(model)
        throw.Enabled=true
        World.markThrow(true)
    end)
    splatter(pos)
    Rig.releaseIntoWorld(model,mess)
end
local function finish(player,outcome)
    if shiftOwner~=player then return end
    shiftOwner=nil
    workspace:SetAttribute("ShiftOccupied",false)
    cleanupCarry(player)
    mess:ClearAllChildren()
    stains:ClearAllChildren()
    table.clear(inFlight)
    start.Enabled=true
    player:SetAttribute("HoldingElf",false)
    player:SetAttribute("TimeRemaining",math.max(0,math.floor(deadline-workspace:GetServerTimeNow())))
    state(player,outcome)
    CrewKit.clear(player.Character)
    if outcome=="complete" then FX.sound("finish",start.Parent) end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame=CFrame.new(0,4,57) end
end
start.Triggered:Connect(function(player)
    if shiftOwner then return end
    shiftOwner,cleared=player,0
    workspace:SetAttribute("ShiftOccupied",true)
    deadline=workspace:GetServerTimeNow()+MAX_TIME
    start.Enabled=false
    player:SetAttribute("ElfTotal",#spots)
    player:SetAttribute("Cleared",0)
    player:SetAttribute("ShiftDeadline",deadline)
    FX.clockIn(start.Parent)
    state(player,"playing")
    CrewKit.equip(player.Character)
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
    local origin=V(0,3.2,-35)
    model:PivotTo(CFrame.new(origin))
    local flight=0.48
    local launch=(firePos-origin)/flight+V(0,workspace.Gravity*flight/2,0)
    Rig.setMode(model, "flight")
    for index,body in Rig.bodies(model) do
        body.AssemblyLinearVelocity=launch
        body.AssemblyAngularVelocity=V(8 + index%3, 4, 3 - index%4)
    end
    FX.throw(model)
    inFlight[model]=workspace:GetServerTimeNow()+flight
end)
RunService.Heartbeat:Connect(function()
    if not shiftOwner then return end
    local now=workspace:GetServerTimeNow()
    for model,arrival in inFlight do
        if now>=arrival then
            inFlight[model]=nil
            FX.hearthHit(firePos)
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
    player.CharacterAdded:Connect(function(character)
        if shiftOwner~=player then return end
        local humanoid=character:WaitForChild("Humanoid",5)
        if humanoid and shiftOwner==player then CrewKit.equip(character) end
    end)
end
Players.PlayerAdded:Connect(setup)
for _,player in Players:GetPlayers() do setup(player) end
Players.PlayerRemoving:Connect(function(player) finish(player,"lobby") end)
