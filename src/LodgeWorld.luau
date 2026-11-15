local Lighting=game:GetService("Lighting")
local V,C=Vector3.new,Color3.fromRGB
local snow,pine,red,gold=C(206,229,239),C(32,79,64),C(157,45,53),C(255,177,74)
local wood,dark,stone=C(116,72,52),C(57,40,39),C(83,89,104)
local map = Instance.new("Folder", workspace)
map.Name = "Holly Lodge"
local function part(parent,name,size,pos,color,material)
    local p=Instance.new("Part")
    p.Name,p.Size,p.Position,p.Color=name,size,pos,color
    p.Material=material or Enum.Material.SmoothPlastic
    p.Anchored=true
    p.Parent=parent
    return p
end
local function build(name,x,y,z,w,h,d,color,material)
    return part(map,name,V(w,h,d),V(x,y,z),color,material)
end
local function glow(p,color,brightness,range)
    local l=Instance.new("PointLight",p)
    l.Color,l.Brightness,l.Range=color,brightness,range
end
local function sign(text,pos,size)
    local anchor=part(map,text,V((size or 205)/37,1.16,0.05),pos,dark)
    anchor.Transparency=1
    anchor.CanCollide=false
    local gui=Instance.new("SurfaceGui",anchor)
    gui.Adornee=anchor
    gui.Face=Enum.NormalId.Back
    gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
    gui.CanvasSize=Vector2.new(size or 205,36)
    gui.LightInfluence=0
    gui.MaxDistance=48
    local label=Instance.new("TextLabel",gui)
    label.BackgroundTransparency=1
    label.Size=UDim2.fromScale(1,1)
    label.TextColor3=C(244,101,111)
    label.TextStrokeColor3=C(76,20,34)
    label.TextStrokeTransparency=0.32
    label.TextSize=20
    label.TextWrapped=true
    label.Font=Enum.Font.Fondamento
    label.Text=text
end
local function prompt(parent,action,object,range)
    local p=Instance.new("ProximityPrompt",parent)
    p.ActionText,p.ObjectText,p.MaxActivationDistance=action,object,range or 8
    p.RequiresLineOfSight=false
    return p
end
Lighting.ClockTime=18.35
Lighting.Ambient=C(74,79,105)
Lighting.OutdoorAmbient=C(100,126,167)
Lighting.Brightness=1.9
Lighting.ExposureCompensation=0.13
Lighting.GlobalShadows=true
Lighting.ShadowSoftness=0.38
local atmosphere=Instance.new("Atmosphere",Lighting)
atmosphere.Color,atmosphere.Decay,atmosphere.Density=C(154,186,235),C(74,94,147),0.22
atmosphere.Haze=0.65
local bloom=Instance.new("BloomEffect",Lighting)
bloom.Intensity,bloom.Size,bloom.Threshold=0.16,18,1.7
local grade=Instance.new("ColorCorrectionEffect",Lighting)
grade.Contrast,grade.Saturation=0.07,-0.04
build("Snowfield",0,-1.3,8,190,2,182,snow,Enum.Material.Snow)
for _,x in {-96,96} do build("Boundary",x,8,8,2,20,184,snow).Transparency=1 end
for _,z in {-85,101} do build("Boundary",0,8,z,192,20,2,snow).Transparency=1 end
local mountainRandom=Random.new(8461)
local function ridge(x,z,width,depth,height,angle)
    local origin=CFrame.new(x,-1,z)*CFrame.Angles(0,angle,0)
    for _,side in {-1,1} do
        local orientation=side==1 and math.pi or 0
        local slope=Instance.new("CornerWedgePart")
        slope.Name="Mountain face"
        slope.Size=V(width,height,depth/2)
        slope.CFrame=origin*CFrame.new(0,height/2,side*depth/4)*CFrame.Angles(0,orientation,0)
        slope.Color=stone:Lerp(C(89,117,153),(side+1)*0.18)
        slope.Material=Enum.Material.Rock
        slope.Anchored,slope.CanCollide=true,false
        slope.Parent=map
        local cap=slope:Clone()
        local snowline=0.32+mountainRandom:NextNumber(0,0.15)
        cap.Name="Mountain snow"
        cap.Size=V(width*0.93,height*snowline,depth*snowline/2)
        cap.CFrame=origin*CFrame.new(0,height-height*snowline/2+0.45,side*depth*snowline/4)*CFrame.Angles(0,orientation,0)
        cap.Material=Enum.Material.Snow
        cap.Color=snow
        cap.Parent=map
    end
end
for side=0,3 do
    for index=-3,3 do
        local angle=side*math.pi/2
        local pos=CFrame.Angles(0,angle,0):PointToWorldSpace(V(index*34+mountainRandom:NextNumber(-5,5),0,102+mountainRandom:NextNumber(-5,14)))
        ridge(pos.X,pos.Z+8,mountainRandom:NextNumber(42,58),mountainRandom:NextNumber(31,46),
            mountainRandom:NextNumber(22,44),angle+mountainRandom:NextNumber(-0.18,0.18))
    end
end
local function tree(x,z,scale)
    build("Trunk",x,scale,z,0.6*scale,scale*2,0.6*scale,dark,Enum.Material.Wood)
    for i=0,4 do
        local w=(4.7-i*0.76)*scale
        local b=build("Pine",x,(2+i*0.79)*scale,z,w,scale*1.4,w,pine:Lerp(snow,i*0.085))
        b.Shape=Enum.PartType.Ball
        b.CanCollide=false
    end
end
local rng=Random.new(20261115)
for i=1,34 do
    local x=(i%2==0 and 1 or -1)*rng:NextNumber(49,90)
    tree(x,rng:NextNumber(-77,91),rng:NextNumber(1.35,2.7))
end
for x=-24,24,8 do tree(x,-64,2.1) end
local function room(name,x,z,w,d)
    build(name.." floor",x,-0.05,z,w,0.6,d,wood,Enum.Material.WoodPlanks)
    local roofAngle=math.rad(25)
    local span=w/2+1.35
    local roofWidth=span/math.cos(roofAngle)
    local ridge=10.45+span*math.tan(roofAngle)
    for _, side in {-1,1} do
        local roof=build(name.." roof",x+side*span/2,(ridge+10.45)/2,z,roofWidth,0.43,d+2.6,C(37,44,63),Enum.Material.Slate)
        roof.CFrame*=CFrame.Angles(0,0,-side*roofAngle)
        local cover=build("Snowcap",x,0,z,roofWidth-0.35,0.31,d+2,snow,Enum.Material.Snow)
        cover.CFrame=roof.CFrame*CFrame.new(0,0.36,0)
        for _, endSide in {-1,1} do
            local fascia=build("Gable fascia",x+side*span/2,(ridge+10.45)/2,z+endSide*(d/2+1.25),roofWidth,0.54,0.46,dark,Enum.Material.Wood)
            fascia.CFrame=roof.CFrame*CFrame.new(0,0,endSide*(d/2+1.25))
        end
    end
    for step=0,math.floor(ridge-11) do
        local width=w+1.1-2*math.max(0,step-0.2)/math.tan(roofAngle)
        if width>0 then
            for _,endSide in {-1,1} do
                build("Gable boards",x,10.4+step,z+endSide*d/2,width,1,0.58,dark,Enum.Material.WoodPlanks)
            end
        end
    end
    for _,offset in {-0.27,0.27} do
        local post=build("Pendant stem",x,9.9,z+d*offset,0.14,3.4,0.14,dark,Enum.Material.Metal)
        post.CanCollide=false
        local shade=build("Pendant shade",x,8.1,z+d*offset,2.45,0.31,2.45,dark,Enum.Material.Metal)
        shade.CanCollide=false
        local bulb=build("Pendant diffuser",x,7.86,z+d*offset,1.85,0.17,1.85,C(255,225,166),Enum.Material.Neon)
        bulb.CanCollide=false
        glow(bulb,C(255,223,180),2.2,25)
    end
    build(name.." back wall",x,5,z-d/2,w,10,0.65,pine,Enum.Material.WoodPlanks)
    for _,side in {-1,1} do
        build(name.." side wall",x+side*w/2,5,z,0.65,10,d,pine,Enum.Material.WoodPlanks)
        local span=w/2-4
        build(name.." front wall",x+side*(4+span/2),5,z+d/2,span,10,0.65,pine,Enum.Material.WoodPlanks)
        build("Rafter",x+side*w*0.31,10.3,z,0.55,0.7,d,dark,Enum.Material.Wood)
        for k=1,4 do
            local bulb=build("String light",x+side*(k*w/9),8.5,z-d/2+0.43,0.25,0.25,0.25,k%2==0 and red or gold,Enum.Material.Neon)
            bulb.Shape=Enum.PartType.Ball
            if k==2 then glow(bulb,gold,1.5,20) end
        end
    end
    for _,side in {-1,1} do
        local wx=x+side*w*0.29
        local wz=z-d/2+0.42
        local frame=build("Window frame",wx,5.65,wz,4.85,3.9,0.34,dark,Enum.Material.Wood)
        frame.CanCollide=false
        local glass=build("Frosted window",wx,5.65,wz+0.21,4.3,3.35,0.12,C(103,160,211),Enum.Material.Glass)
        glass.CanCollide=false
        glow(glass,C(115,172,255),1.35,16)
        for _,v in {-1,1} do
            local divider=build("Window mullion",wx+v*0.72,5.65,wz+0.31,0.11,3.35,0.11,dark,Enum.Material.Wood)
            divider.CanCollide=false
        end
        local latch=build("Window crossbar",wx,5.65,wz+0.31,4.3,0.12,0.11,dark,Enum.Material.Wood)
        latch.CanCollide=false
    end
    build(name.." door header",x,8.7,z+d/2,8,2.6,0.65,dark,Enum.Material.Wood)
    build("Runner",x,0.29,z+1,math.min(w-3,10),0.08,d-4,red,Enum.Material.Fabric)
end
room("Check-in Lodge",0,55,34,28)
room("Great Hall",0,-27,42,40)
room("Wrapping Workshop",-33,-26,21,24)
room("Kitchen",33,-26,21,24)
for z=-3,38,3 do
    build("Flagstone path",0,-0.28,z,7.5,0.23,2.9,stone,Enum.Material.Slate)
    if z%6==0 then
        for _,x in {-5,5} do
            build("Lantern post",x,1.7,z,0.3,4,0.3,dark,Enum.Material.Wood)
            glow(build("Lantern",x,3.7,z,0.64,0.7,0.64,gold,Enum.Material.Neon),gold,2,14)
        end
    end
end
for _,x in {-33,33} do
    for z=-12,0,3 do build("Service path",x,-0.27,z,6,0.2,2.8,stone,Enum.Material.Slate) end
end
build("Service crosswalk",0,-0.29,0,69,0.22,5,stone,Enum.Material.Slate)
sign("Holly Lodge",V(0,8,55),285)
sign("Great Hall",V(0,8,-5),285)
sign("Wrapping Workshop",V(-33,8,-13))
sign("Kitchen",V(33,8,-12.95))
tree(-12,-38,1.8)
tree(12,47,1.65)
for _,spec in {{-33,-31},{33,-31},{-11,51},{11,-21}} do
    for i=-1,1,2 do
        build("Table leg",spec[1]+i*2.6,1.2,spec[2],0.5,2.4,1.6,dark,Enum.Material.Wood)
    end
    build("Worktop",spec[1],2.5,spec[2],7,0.35,2.8,wood,Enum.Material.Wood)
    for i=1,4 do
        local x=spec[1]+(i-2.5)*1.25
        build("Parcel",x,3.1,spec[2],0.88,0.88,0.95,i%2==0 and red or pine)
        build("Ribbon",x,3.1,spec[2],0.16,0.91,0.98,gold)
    end
end
-- Domestic fixtures and distinct work areas.
local brass, enamel, cranberry = C(178,130,70), C(214,227,221), C(129,36,53)
local function decor(name,x,y,z,w,h,d,color,material)
    local item=build(name,x,y,z,w,h,d,color,material)
    item.CanCollide=false
    return item
end
for _,spec in {{0,55,34,28},{0,-27,42,40},{-33,-26,21,24},{33,-26,21,24}} do
    local x,z,w,d=table.unpack(spec)
    for _,side in {-1,1} do
        decor("Interior dado rail",x+side*(w/2-0.45),2.35,z,0.28,0.21,d-0.8,dark,Enum.Material.Wood)
        decor("Door jamb",x+side*4.12,3.8,z+d/2+0.42,0.42,7.6,0.4,dark,Enum.Material.Wood)
        local lantern=decor("Porch sconce",x+side*4.8,5.65,z+d/2+0.68,0.5,0.65,0.42,C(255,184,110),Enum.Material.Neon)
        glow(lantern,C(255,194,125),0.7,11)
    end
    decor("Door lintel",x,7.65,z+d/2+0.42,8.7,0.46,0.4,dark,Enum.Material.Wood)
    for j=0,18 do
        local px=x-4.4+j*0.49
        local py=8.15-0.53*math.sin(j*math.pi/18)
        local light=decor("Porch fairy light",px,py,z+d/2+0.64,0.12,0.17,0.14,j%3==0 and red or gold,Enum.Material.Neon)
        light.Shape=Enum.PartType.Ball
    end
end
-- Kitchen cabinetry, stove, kettle, and hanging pans.
for i=0,4 do
    local x=25.5+i*3.6
    build("Kitchen cabinet",x,1.7,-35.9,3.55,2.9,2.72,i==2 and C(41,53,66) or C(53,102,106),Enum.Material.Wood)
    decor("Inset cabinet door",x,1.61,-34.48,3.13,2.28,0.08,i==2 and C(26,34,44) or C(65,126,125))
    decor("Cabinet pull",x,2.28,-34.38,0.8,0.1,0.1,brass,Enum.Material.Metal)
end
build("Marble counter",32.7,3.24,-35.9,18.2,0.27,2.93,enamel,Enum.Material.Marble)
for i=0,2 do
    for j=0,19 do
        decor("Kitchen backsplash tile",25.15+j*0.79,3.74+i*0.41,-37.5,0.75,0.37,0.12,
            (i+j)%4==0 and C(112,146,148) or C(181,203,194),Enum.Material.CeramicTiles)
    end
end
for i=0,3 do
    local hob=decor("Cast iron hob",31.68+i%2*0.94,3.4,-36.45+math.floor(i/2)*0.88,0.11,0.66,0.66,C(32,37,42),Enum.Material.Metal)
    hob.Shape=Enum.PartType.Cylinder
    hob.CFrame*=CFrame.Angles(0,0,math.pi/2)
end
local kettle=decor("Enamel kettle",33,3.9,-36,0.88,0.9,0.88,cranberry)
kettle.Shape=Enum.PartType.Ball
decor("Kettle handle",33,4.4,-36,0.64,0.12,0.15,dark)
local spout=decor("Kettle spout",33.48,4,-36,0.57,0.14,0.15,cranberry)
spout.CFrame*=CFrame.Angles(0,0,math.rad(34))
-- Wrapping shelves, paper rolls, and labeled bins.
for level=0,3 do
    local y=0.82+level*1.5
    build("Workshop shelf",-37.9,y,-35.75,9.65,0.15,1.8,dark,Enum.Material.Wood)
    for col=0,5 do
        local x=-41.55+col*1.42
        decor("Wrapping carton",x,y+0.48,-35.7,1.02,0.82,1.15,({red,pine,enamel,brass})[(col+level)%4+1],Enum.Material.Cardboard)
        decor("Carton label",x,y+0.52,-35.1,0.56,0.23,0.04,enamel)
    end
end
for i=0,5 do
    local roll=decor("Wrapping paper roll",-28.1+i*0.5,0.95,-33,1.38,0.41,0.41,i%2==0 and red or C(68,116,93))
    roll.Shape=Enum.PartType.Cylinder
    roll.CFrame*=CFrame.Angles(0,0,math.rad(74+i*3))
end
-- Great Hall furnishings and garland.
for _,side in {-1,1} do
    local x=side*16.7
    build("Hall bench seat",x,1.55,-37.4,2.8,0.36,5.5,cranberry,Enum.Material.Fabric)
    build("Hall bench back",x+side*1.21,2.46,-37.4,0.46,1.75,5.5,cranberry,Enum.Material.Fabric)
    for _,dz in {-2.15,2.15} do
        build("Bench support",x,0.85,-37.4+dz,2.1,1.2,0.43,dark,Enum.Material.Wood)
    end
end
for i=0,32 do
    local x=-9.6+i*0.6
    local y=8.55-0.56*math.sin(i*math.pi/16)^2
    local sprig=decor("Evergreen garland",x,y,-43.65,0.95,0.61,0.55,pine:Lerp(C(61,114,66),i%3*0.17))
    sprig.Shape=Enum.PartType.Ball
    if i%3==0 then
        local berry=decor("Holly berry",x,y-0.1,-43.35,0.17,0.17,0.17,red)
        berry.Shape=Enum.PartType.Ball
    end
end
for i=0,6 do
    local x=-3.9+i*1.3
    decor("Stocking cuff",x,6.02,-38.94,0.58,0.23,0.22,enamel,Enum.Material.Fabric)
    decor("Stocking",x,5.69,-38.93,0.46,0.6,0.19,cranberry,Enum.Material.Fabric)
    decor("Stocking foot",x+0.14,5.37,-38.9,0.72,0.25,0.22,cranberry,Enum.Material.Fabric)
end
-- Check-in benches and a framed lodge map.
for i=0,2 do
    build("Lobby seat",11.6,1.48,53+i*2.65,2.6,0.29,2.35,dark,Enum.Material.Wood)
    decor("Lobby seat pad",11.6,1.71,53+i*2.65,2.62,0.2,2.28,cranberry,Enum.Material.Fabric)
    build("Lobby bench base",11.6,0.85,53+i*2.65,1.9,1.24,1.78,dark,Enum.Material.Wood)
end
local lodgeMap=decor("Framed lodge plan",-10.8,5.4,41.47,4,2.65,0.4,brass,Enum.Material.Wood)
local plan=Instance.new("SurfaceGui",lodgeMap)
plan.Face=Enum.NormalId.Back
plan.LightInfluence=0.25
local diagram=Instance.new("Frame",plan)
diagram.Size=UDim2.fromScale(0.91,0.89)
diagram.Position=UDim2.fromScale(0.045,0.055)
diagram.BackgroundColor3=C(225,212,171)
for _,cell in {{0.35,0.2,0.3,0.25},{0.07,0.25,0.21,0.19},{0.73,0.25,0.2,0.19},{0.37,0.66,0.26,0.2}} do
    local marker=Instance.new("Frame",diagram)
    marker.Position=UDim2.fromScale(cell[1],cell[2])
    marker.Size=UDim2.fromScale(cell[3],cell[4])
    marker.BackgroundColor3=pine
    marker.BorderSizePixel=0
end
local spawn=Instance.new("SpawnLocation",workspace)
spawn.Position=V(0,0.5,61)
spawn.Size=V(6,1,6)
spawn.Transparency=1
spawn.Duration=0
spawn.Anchored=true
spawn.CanCollide=false

local lobby=build("Shift board",0,2.5,46,7,5,0.8,dark,Enum.Material.Wood)
sign("CLOCK IN  •  3-MINUTE SHIFT",V(0,5.6,46))
local board=Instance.new("SurfaceGui",lobby)
board.Face=Enum.NormalId.Back
board.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
board.CanvasSize=Vector2.new(560,400)
board.LightInfluence=0.25
local placard=Instance.new("TextLabel",board)
placard.Size=UDim2.fromScale(0.93,0.86)
placard.Position=UDim2.fromScale(0.035,0.07)
placard.BackgroundColor3=C(29,54,47)
placard.TextColor3=C(255,232,186)
placard.Font=Enum.Font.FredokaOne
placard.TextSize=54
placard.Text="HOLLY LODGE\nClock in here"
local start=prompt(lobby,"Clock in","Cleanup shift",10)
local firePos=V(0,2.1,-41.2)
build("Hearth floor",0,0.55,-41,12,0.65,7.8,stone,Enum.Material.Slate)
build("Firebox back",0,3.5,-44.5,12,7,1.3,stone,Enum.Material.Brick)
for _,x in {-5.1,5.1} do build("Firebox pillar",x,3.2,-41.5,1.7,6.4,4.8,stone,Enum.Material.Brick) end
build("Mantel",0,6.5,-41.6,13,0.8,5.1,dark,Enum.Material.Wood)
for i=-4,4 do
    local coal=build("Coals",i*0.77,1.15,-41+(i%2)*0.64,0.85,0.5,0.9,i%2==0 and gold or red,Enum.Material.Neon)
    coal.Shape=Enum.PartType.Ball
end
local flame=part(map,"Hearth flame",V(0.5,0.5,0.5),firePos,gold)
flame.Transparency=1
flame.CanCollide=false
local fire=Instance.new("Fire",flame)
fire.Size,fire.Heat,fire.Color,fire.SecondaryColor=6,8,C(255,177,67),C(186,61,35)
glow(flame,C(255,156,85),2.7,24)
build("Chimney stack",0,11.9,-44.2,5.3,14.8,3.8,stone,Enum.Material.Brick)
build("Chimney crown",0,19.5,-44.2,6.05,0.53,4.5,dark,Enum.Material.Slate)
sign("Fireplace",V(0,7.5,-39.6))
local bin=build("Throw zone",0,1,-35.3,7.5,0.15,3,gold)
bin.CanCollide=false
local throw=prompt(bin,"Throw into fire","Fireplace",9)
throw.KeyboardKeyCode=Enum.KeyCode.F
throw.GamepadKeyCode=Enum.KeyCode.ButtonX
throw.Enabled=false


return {map=map,part=part,build=build,prompt=prompt,start=start,throw=throw,firePos=firePos,flame=flame,bin=bin}
