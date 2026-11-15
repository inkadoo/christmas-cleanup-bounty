local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local C = Color3.fromRGB
local cream = C(255,245,219)
local frost = C(214,235,232)
local ink = C(15,33,37)
local pine = C(26,61,58)
local gold = C(255,196,108)
local coral = C(255,147,139)
local holly = C(153,48,65)
local headline = Enum.Font.FredokaOne
local textFont = Enum.Font.GothamMedium
local bold = Enum.Font.GothamBold

local function new(class, parent, properties)
    local item = Instance.new(class)
    for key, value in properties do item[key] = value end
    item.Parent = parent
    return item
end

local function frame(parent, x, y, w, h, color)
    return new("Frame", parent, {
        Position=UDim2.fromOffset(x,y), Size=UDim2.fromOffset(w,h),
        BackgroundColor3=color, BorderSizePixel=0,
    })
end

local function round(item, radius)
    new("UICorner", item, {CornerRadius=UDim.new(0,radius)})
end

local function line(item, color, width, transparency)
    new("UIStroke", item, {ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Color=color,
        Thickness=width, Transparency=transparency or 0})
end

local function text(parent, value, x,y,w,h,size,font,color,center)
    return new("TextLabel",parent,{
        Text=value, Position=UDim2.fromOffset(x,y), Size=UDim2.fromOffset(w,h),
        TextSize=size,Font=font,TextColor3=color,BackgroundTransparency=1,
        TextXAlignment=center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
    })
end

local function gradient(item, top, bottom)
    new("UIGradient",item,{Color=ColorSequence.new(top,bottom),Rotation=90})
end

local gui = new("ScreenGui", player:WaitForChild("PlayerGui"), {
    Name="ChristmasCleanup", ResetOnSpawn=false, DisplayOrder=5,
    ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,
})

local function pane(w,h)
    local card=frame(gui,0,0,w,h,C(255,255,255))
    round(card,16)
    line(card,C(224,238,218),1.6,0.08)
    gradient(card,pine,ink)
    return card
end

local function pill(parent,label,x,y,w,bg,fg)
    local tile=frame(parent,x,y,w,25,bg)
    round(tile,7)
    text(tile,label,0,0,w,25,11,bold,fg,true)
    return tile
end

local function timeFormat(seconds)
    return string.format("%d:%02d", math.floor(seconds/60), seconds%60)
end

local intro=pane(381,112)
intro.Name="CheckIn"
intro.AnchorPoint=Vector2.new(0.5,0)
intro.Position=UDim2.new(0.5,0,0,11)
local introAccent=frame(intro,13,13,51,86,holly)
round(introAccent,11)
local mitten=frame(introAccent,11,35,29,25,cream)
round(mitten,8)
local thumb=frame(mitten,-4,9,9,13,cream)
round(thumb,4)
local cuff=frame(introAccent,14,58,23,10,gold)
round(cuff,4)
text(intro,"HOLLY LODGE",78,12,280,17,11,bold,gold)
text(intro,"Christmas Cleanup",77,29,290,35,27,headline,cream)
local introHint=text(intro,"Clock in at the shift board.",78,65,290,26,14,textFont,frost)

local hud=pane(381,81)
hud.Name="ShiftHUD"
hud.AnchorPoint=Vector2.new(0.5,0)
hud.Position=UDim2.new(0.5,0,0,11)
local timerTile=frame(hud,12,11,90,59,C(53,81,75))
round(timerTile,9)
local timer=text(timerTile,"3:00",0,1,90,34,25,headline,cream,true)
text(timerTile,"TIME LEFT",0,34,90,17,9,bold,frost,true)
local progress=text(hud,"0 / 10",115,12,81,31,24,headline,cream)
text(hud,"ELVES CLEARED",192,16,172,26,11,bold,gold)
local ticks={}
for i=1,10 do
    local tile=frame(hud,115+(i-1)*25,51,20,9,C(67,101,96))
    round(tile,4)
    ticks[i]=tile
end

local objective=pane(358,57)
objective.Name="Objective"
objective.AnchorPoint=Vector2.new(0.5,1)
objective.Position=UDim2.new(0.5,0,0.91,0)
local objectiveKicker=text(objective,"NEXT",11,7,58,15,9,bold,gold)
local objectiveText=text(objective,"Find a workshop elf",11,21,334,24,16,headline,cream)
local dirtTicks={}
for i=1,8 do
    local dot=frame(objective,224+(i-1)*15,11,10,5,C(58,94,87))
    round(dot,3)
    dot.Visible=false
    dirtTicks[i]=dot
end

local portrait=new("ViewportFrame",objective,{
    Name="CarriedElfPortrait",Position=UDim2.fromOffset(300,3),Size=UDim2.fromOffset(53,51),
    BackgroundColor3=C(53,87,80),BorderSizePixel=0,Ambient=C(193,209,194),LightColor=C(255,229,187),
    LightDirection=Vector3.new(-1,-1,1),Visible=false,
})
round(portrait,9)
local portraitCamera=new("Camera",portrait,{
    CFrame=CFrame.lookAt(Vector3.new(0.13,0.26,-2.56),Vector3.new(0,0.12,0)),
    FieldOfView=38,
})
portrait.CurrentCamera=portraitCamera
local portraitWorld=Instance.new("WorldModel",portrait)
local currentPortrait
local function showPortrait(carrying)
    local rig
    if carrying and player.Character then
        for _, candidate in player.Character:GetChildren() do
            if candidate:IsA("Model") and candidate:GetAttribute("ElfName") then rig=candidate break end
        end
    end
    if rig==currentPortrait then return end
    portraitWorld:ClearAllChildren()
    currentPortrait=rig
    portrait.Visible=rig~=nil
    local head=rig and rig:FindFirstChild("Head")
    if not head then
        currentPortrait=nil
        portrait.Visible=false
        return
    end
    for _, piece in rig:GetChildren() do
        local weld=piece:FindFirstChildOfClass("WeldConstraint")
        if piece:IsA("BasePart") and weld and weld.Part0==head then
            local copy=piece:Clone()
            copy:FindFirstChildOfClass("WeldConstraint"):Destroy()
            copy.CFrame=head.CFrame:ToObjectSpace(piece.CFrame)
            copy.Anchored=true
            copy.Parent=portraitWorld
        end
    end
end

local notice=text(gui,"",0,0,255,27,16,headline,gold,true)
notice.Name="ActionFeedback"
notice.AnchorPoint=Vector2.new(0.5,0)
notice.Position=UDim2.new(0.5,0,0,102)
notice.TextStrokeColor3=ink
notice.TextStrokeTransparency=0.25
notice.TextTransparency=1
local noticeTween
local cueSerial=0
local function cue(message,color)
    cueSerial+=1
    local serial=cueSerial
    if noticeTween then noticeTween:Cancel() end
    notice.Text,notice.TextColor3,notice.TextTransparency=message,color,0
    notice.Position=UDim2.new(0.5,0,0,107)
    noticeTween=TweenService:Create(notice,TweenInfo.new(0.22,Enum.EasingStyle.Back),{
        Position=UDim2.new(0.5,0,0,98),
    })
    noticeTween:Play()
    task.delay(0.82,function()
        if serial~=cueSerial then return end
        noticeTween=TweenService:Create(notice,TweenInfo.new(0.27),{TextTransparency=1})
        noticeTween:Play()
    end)
end

local settings=new("TextButton",gui,{
    Name="ToggleSound",Text="SFX ON",Font=bold,TextSize=11,TextColor3=frost,
    Size=UDim2.fromOffset(74,44),Position=UDim2.new(1,-12,0,11),AnchorPoint=Vector2.new(1,0),
    BackgroundColor3=ink,BorderSizePixel=0,Selectable=true,
})
round(settings,11)
line(settings,C(155,199,177),1,0.29)
local muted=false
settings.Activated:Connect(function()
    muted=not muted
    local bus=SoundService:FindFirstChild("Holly Lodge SFX")
    if bus then bus.Volume=muted and 0 or 0.9 end
    settings.Text=muted and "SFX OFF" or "SFX ON"
end)
SoundService.ChildAdded:Connect(function(child)
    if child.Name=="Holly Lodge SFX" and child:IsA("SoundGroup") and muted then child.Volume=0 end
end)

local report=pane(434,248)
report.Name="ShiftReport"
report.AnchorPoint=Vector2.new(0.5,0.5)
report.Position=UDim2.fromScale(0.5,0.51)
local banner=frame(report,15,15,404,87,C(255,255,255))
round(banner,11)
gradient(banner,C(173,58,71),C(108,33,55))
text(banner,"HOLLY LODGE  /  SHIFT REPORT",0,12,404,19,11,bold,gold,true)
local reportTitle=text(banner,"Shift complete!",0,31,404,43,35,headline,cream,true)
local reportStats={}
for i,caption in {"ELVES CLEARED","STAINS MOPPED","TIME LEFT"} do
    local x=15+(i-1)*137
    local tile=frame(report,x,116,130,63,C(48,81,76))
    round(tile,9)
    local value=text(tile,"",0,4,130,34,25,headline,cream,true)
    text(tile,caption,0,39,130,17,10,bold,gold,true)
    reportStats[i]=value
end
local dismiss=new("TextButton",report,{
    Name="ReturnToLobby",Text="Back to check-in",Position=UDim2.fromOffset(112,190),
    Size=UDim2.fromOffset(210,43),BackgroundColor3=gold,TextColor3=ink,
    Font=headline,TextSize=17,Selectable=true,BorderSizePixel=0,
})
round(dismiss,9)
line(dismiss,cream,1,0.22)
local dismissed=false
dismiss.Activated:Connect(function()
    dismissed=true
    report.Visible=false
    intro.Visible=true
    if GuiService.SelectedObject==dismiss then GuiService.SelectedObject=nil end
end)

local dimensions={{intro,381,112},{hud,381,81},{objective,358,57},{report,434,248}}
local function fit()
    local view=workspace.CurrentCamera.ViewportSize
    for _,row in dimensions do
        local item,w,h=table.unpack(row)
        local scale=item:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",item)
        scale.Scale=math.clamp(math.min((view.X-22)/w,(view.Y-48)/h),0.55,1)
    end
    -- Move SFX out of the top HUD's footprint on narrow phones.
    settings.Position=view.X<540 and UDim2.new(1,-11,0,145) or UDim2.new(1,-12,0,11)
end
local camera=workspace.CurrentCamera
if not camera then
    workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
    camera=workspace.CurrentCamera
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
fit()

local previousState
local previousCleared=0
local previousMopped=0
local function redraw()
    local status=player:GetAttribute("ShiftState") or "lobby"
    local active=status=="playing"
    local finished=status=="complete" or status=="expired"
    if not finished then dismissed=false end
    local cleared=player:GetAttribute("Cleared") or 0
    local mopped=player:GetAttribute("Mopped") or 0
    local total=player:GetAttribute("ElfTotal") or 10

    hud.Visible,objective.Visible=active,active
    report.Visible=finished and not dismissed
    intro.Visible=not (active or report.Visible)
    local busy=workspace:GetAttribute("ShiftOccupied")
    introHint.Text=busy and not active and "Another cleaner is on shift."
        or (finished and "Clock in again to replay." or "Clock in at the shift board.")

    if active then
        local deadline=player:GetAttribute("ShiftDeadline") or workspace:GetServerTimeNow()
        local left=math.max(0,math.ceil(deadline-workspace:GetServerTimeNow()))
        timer.Text=timeFormat(left)
        timer.TextColor3=left<=25 and coral or cream
        timerTile.BackgroundColor3=left<=25 and C(115,44,56) or C(53,81,75)
        progress.Text=string.format("%d / %d",cleared,total)
        for index,cell in ticks do cell.BackgroundColor3=index<=cleared and gold or C(67,101,96) end
        local mop=player.Character and player.Character:FindFirstChild("Mop")
        local holding=player:GetAttribute("HoldingElf")
        showPortrait(holding)
        local dirt=mop and mop:GetAttribute("Dirt") or 0
        for index,dot in dirtTicks do
            dot.Visible=mop~=nil and not holding
            dot.BackgroundColor3=index<=dirt and coral or C(58,94,87)
        end
        if holding then
            objectiveKicker.Text="CARRYING"
            objectiveText.Text=(player:GetAttribute("CarriedElf") or "Elf").." → Great Hall fireplace"
        elseif mop then
            objectiveKicker.Text="MOP"
            objectiveText.Text=dirt>=8 and "Rinse the mop at the bucket" or "Swipe near a bloodstain"
        else
            objectiveKicker.Text="NEXT"
            objectiveText.Text="Find and carry a workshop elf"
        end
        if previousState=="playing" then
            if cleared>previousCleared then cue("Elf cleared",gold)
            elseif mopped>previousMopped then cue("Stain removed",frost) end
        end
    elseif finished then
        showPortrait(false)
        reportTitle.Text=status=="complete" and "Shift complete!" or "Shift ended"
        reportStats[1].Text=string.format("%d / %d",cleared,total)
        reportStats[2].Text=tostring(mopped)
        reportStats[3].Text=timeFormat(player:GetAttribute("TimeRemaining") or 0)
        if previousState~=status and UserInputService:GetLastInputType().Name:find("Gamepad") then
            GuiService.SelectedObject=dismiss
        end
    end
    previousState,previousCleared,previousMopped=status,cleared,mopped
end

for _,attribute in {"ShiftState","ShiftDeadline","Cleared","Mopped","HoldingElf","CarriedElf","TimeRemaining","ElfTotal"} do
    player:GetAttributeChangedSignal(attribute):Connect(redraw)
end
workspace:GetAttributeChangedSignal("ShiftOccupied"):Connect(redraw)
redraw()
while gui.Parent do
    if player:GetAttribute("ShiftState")=="playing" then redraw() end
    task.wait(0.2)
end
