local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local C = Color3.fromRGB
local cream, pine, holly = C(255,245,216), C(27,57,50), C(177,50,62)
local gold, muted = C(255,195,102), C(207,219,207)

local function new(class,parent,properties)
    local instance=Instance.new(class)
    for key,value in properties do instance[key]=value end
    instance.Parent=parent
    return instance
end
local gui=new("ScreenGui",player:WaitForChild("PlayerGui"),{Name="ChristmasCleanup",ResetOnSpawn=false})
local function frame(parent,x,y,w,h,color)
    return new("Frame",parent,{
        Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BackgroundColor3=color,BorderSizePixel=0
    })
end
local function corner(parent,radius)
    new("UICorner",parent,{CornerRadius=UDim.new(0,radius)})
end
local function stroke(parent,color,thickness)
    new("UIStroke",parent,{Color=color,Thickness=thickness,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
end
local function label(parent,text,x,y,w,h,size,font,color)
    local item=new("TextLabel",parent,{
        Text=text,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,
        TextColor3=color or cream,TextSize=size,Font=font or Enum.Font.GothamBold
    })
    return item
end
local function panel(height)
    local item=frame(gui,0,0,348,height,pine)
    item.AnchorPoint=Vector2.new(0.5,0)
    item.Position=UDim2.new(0.5,0,0,9)
    corner(item,14)
    stroke(item,cream,2)
    local shadow=frame(item,0,0,348,height+5,C(13,26,32))
    shadow.ZIndex=0
    corner(shadow,15)
    return item
end
local function badge(parent,x,y,kind,color)
    local tile=frame(parent,x,y,36,36,color)
    corner(tile,8)
    if kind=="clock" then
        local face=frame(tile,8,8,20,20,cream)
        corner(face,12)
        local dial=frame(face,2,2,16,16,color)
        corner(dial,9)
        frame(dial,7,3,2,6,cream)
        frame(dial,7,7,5,2,cream)
    elseif kind=="parcel" then
        frame(tile,9,16,18,11,cream)
        frame(tile,7,12,22,4,cream)
        frame(tile,16,12,4,15,color)
        local bow=frame(tile,11,8,6,3,cream)
        bow.Rotation=24
        local bow2=frame(tile,19,8,6,3,cream)
        bow2.Rotation=-24
    else
        local roof=frame(tile,10,9,16,16,cream)
        roof.Rotation=45
        corner(roof,3)
        frame(tile,9,16,18,12,cream)
        frame(tile,16,21,5,7,color)
    end
end

local intro=panel(89)
badge(intro,15,24,"house",holly)
local title=label(intro,"Christmas Cleanup",65,12,270,34,25,Enum.Font.FredokaOne)
local message=label(intro,"Clock in at the lobby shift board.",66,49,266,23,14,Enum.Font.GothamMedium,muted)

local hud=panel(104)
badge(hud,13,12,"clock",holly)
badge(hud,181,12,"parcel",C(49,102,78))
label(hud,"TIME LEFT",59,9,92,16,11,Enum.Font.GothamBold,gold)
label(hud,"ELVES CLEANED",226,9,114,16,11,Enum.Font.GothamBold,gold)
local time=label(hud,"3:00",59,25,102,30,25,Enum.Font.FredokaOne)
local count=label(hud,"0 / 10",226,25,100,30,25,Enum.Font.FredokaOne)
frame(hud,167,14,1,32,C(88,120,102))
local track=frame(hud,14,60,320,5,C(79,113,98))
corner(track,3)
local fill=frame(track,0,0,320,5,gold)
corner(fill,3)
local objective=label(hud,"Find an elf ragdoll",15,73,320,21,14,Enum.Font.GothamBold,muted)
objective.TextXAlignment=Enum.TextXAlignment.Center

local report=frame(gui,0,0,370,236,pine)
report.Name="ShiftReport"
report.AnchorPoint=Vector2.new(0.5,0.5)
report.Position=UDim2.fromScale(0.5,0.51)
corner(report,19)
stroke(report,cream,3)
local banner=frame(report,16,16,338,92,holly)
corner(banner,12)
local reportTitle=label(banner,"Shift complete!",0,8,338,49,34,Enum.Font.FredokaOne)
reportTitle.TextXAlignment=Enum.TextXAlignment.Center
local reportSub=label(banner,"Holly Lodge cleanup report",0,54,338,26,15,Enum.Font.GothamMedium)
reportSub.TextXAlignment=Enum.TextXAlignment.Center
local reportStats={}
for i,caption in {"ELVES CLEARED","STAINS MOPPED","TIME LEFT"} do
    local x=17+(i-1)*112
    local tile=frame(report,x,121,106,60,C(45,82,68))
    corner(tile,8)
    local value=label(tile,"",0,3,106,30,24,Enum.Font.FredokaOne)
    value.TextXAlignment=Enum.TextXAlignment.Center
    local titleLabel=label(tile,caption,0,31,106,19,9,Enum.Font.GothamBold,gold)
    titleLabel.TextXAlignment=Enum.TextXAlignment.Center
    reportStats[i]=value
end
local dismiss=new("TextButton",report,{
    Name="ReturnToLobby",Text="Back to check-in",Position=UDim2.fromOffset(88,193),
    Size=UDim2.fromOffset(194,30),BackgroundColor3=gold,TextColor3=pine,
    Font=Enum.Font.GothamBold,TextSize=15,Selectable=true
})
corner(dismiss,7)
local dismissed=false
dismiss.Activated:Connect(function() dismissed=true end)
local function fit()
    local viewport=workspace.CurrentCamera.ViewportSize
    local scale=math.clamp(math.min((viewport.X-24)/370,(viewport.Y-60)/236),0.55,1)
    for _,item in {intro,hud,report} do
        local scaling=item:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",item)
        scaling.Scale=scale
    end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
fit()
local oldCount=-1
local pulse
while true do
    local status=player:GetAttribute("ShiftState")
    hud.Visible=status=="playing"
    local finished=status=="complete" or status=="expired"
    if not finished then dismissed=false end
    report.Visible=finished and not dismissed
    intro.Visible=not (hud.Visible or report.Visible)
    local cleaned=player:GetAttribute("Cleared") or 0
    if hud.Visible then
        local deadline=player:GetAttribute("ShiftDeadline") or workspace:GetServerTimeNow()
        local left=math.max(0,math.ceil(deadline-workspace:GetServerTimeNow()))
        time.Text=string.format("%d:%02d",math.floor(left/60),left%60)
        time.TextColor3=left<=30 and C(255,142,139) or cream
        count.Text=string.format("%d / 10",cleaned)
        if cleaned~=oldCount then
            if pulse then pulse:Cancel() end
            fill.Size=UDim2.fromScale(cleaned/10,1)
            count.TextColor3=gold
            pulse=TweenService:Create(count,TweenInfo.new(0.5),{TextColor3=cream})
            pulse:Play()
            oldCount=cleaned
        end
        local mop=player.Character and player.Character:FindFirstChild("Mop")
        if mop then
            local dirt=mop:GetAttribute("Dirt") or 0
            objective.Text=dirt>=8 and "Mop is dirty. Rinse it in the bucket."
                or string.format("Mop nearby blood  •  %d / 8 strokes used",dirt)
        else
            objective.Text=player:GetAttribute("HoldingElf") and "Take the elf to the Great Hall fireplace" or "Find and pick up an elf ragdoll"
        end
    elseif finished then
        reportTitle.Text=status=="complete" and "Shift complete!" or "Time's up!"
        reportStats[1].Text=string.format("%d / 10",cleaned)
        reportStats[2].Text=tostring(player:GetAttribute("Mopped") or 0)
        local remaining=player:GetAttribute("TimeRemaining") or 0
        reportStats[3].Text=string.format("%d:%02d",math.floor(remaining/60),remaining%60)
        title.Text="Christmas Cleanup"
        message.Text="Clock in at the shift board to replay."
        oldCount=-1
    else
        title.Text="Christmas Cleanup"
        message.Text="Clock in at the lobby shift board."
    end
    task.wait(0.1)
end
