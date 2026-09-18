-- ============================================================
-- NEVERLOSE x JAVOR HYBRID
-- ============================================================
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local PL=game:GetService("Players")
local HS=game:GetService("HttpService")
local LP=PL.LocalPlayer
local PG=LP:WaitForChild("PlayerGui")
local CAM=workspace.CurrentCamera
local CHARS=workspace:FindFirstChild("Characters") or workspace:WaitForChild("Characters",15)

-- ============================================================
-- БЕЗОПАСНАЯ ПРОВЕРКА МОДУЛЕЙ BLOX STRIKE
-- ============================================================
local function findNamespace()
    local RS2=game:GetService("ReplicatedStorage")
    local named=RS2:FindFirstChild("Bloxstrike | Frog")
    if named then return named end
    for _,child in ipairs(RS2:GetChildren()) do
        if child:FindFirstChild("Controllers") and child:FindFirstChild("Database") then
            return child
        end
    end
    return RS2
end
local NS=findNamespace()
local function child(root,...)
    local node=root
    for _,name in ipairs({...}) do
        node=node and node:FindFirstChild(name)
        if not node then return nil end
    end
    return node
end
local function safeRequire(module)
    if not module then return false,nil end
    local ok,res=pcall(require,module)
    return ok,res
end

-- ============================================================
-- КОНФИГ
-- ============================================================
local C={
    -- ESP
    ESP=false,ESPBox=true,ESPName=true,ESPHP=true,ESPDist=true,ESPTeam=false,
    -- AA
    AAE=false,AAM="Spin",AAY=180,AAPM="Down",AAS=20,AAB="Disabled",
    -- Legit
    LegitE=false,LegitK="M2",LegitF=200,LegitS=10,LegitHit="Balaclava",
    -- Rage
    RageE=false,RageK="M1",RageF=300,RageHit="Balaclava",
    RageAuto=true,RageS=3,RageTarget="Nearest",
    -- Weapon
    DTap=false,DTapDelay=0.05,
    NoSpread=false,NoRecoil=false,
    SpeedE=false,SpeedV=50,
    -- Movement
    Bhop=false,Fly=false,FlySpeed=60,InfJump=false,
    Noclip=false,EdgeJump=false,
    FakeLag=false,FakeLagMs=110,
    -- View
    TP=false,TPD=15,TPHeight=0,
    Cross=false,CSz=10,
    -- Skins
    Skin=false,Knife=false,
}

-- ============================================================
-- ЦВЕТА
-- ============================================================
local BGC=Color3.fromRGB(15,15,18)
local SIDE=Color3.fromRGB(11,11,14)
local TOP=Color3.fromRGB(17,17,21)
local ROW=Color3.fromRGB(24,24,29)
local TXT=Color3.fromRGB(228,228,234)
local DIM=Color3.fromRGB(105,105,118)
local MID=Color3.fromRGB(150,150,165)
local ACC=Color3.fromRGB(65,130,240)
local ACC2=Color3.fromRGB(90,150,255)
local OFF=Color3.fromRGB(45,45,54)
local DANGER=Color3.fromRGB(200,60,60)

-- ============================================================
-- МЕНЮ
-- ============================================================
local old=PG:FindFirstChild("NL") if old then old:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="NL" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true
gui.DisplayOrder=999 gui.Parent=PG

local W=Instance.new("Frame")
W.Size=UDim2.new(0,780,0,520) W.Position=UDim2.new(0.5,-390,0.5,-260)
W.BackgroundColor3=BGC W.BorderSizePixel=0 W.Active=true W.Parent=gui
Instance.new("UICorner",W).CornerRadius=UDim.new(0,8)

local TB=Instance.new("Frame")
TB.Size=UDim2.new(1,0,0,38) TB.BackgroundColor3=TOP TB.BorderSizePixel=0 TB.Parent=W
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,8)
local TBF=Instance.new("Frame")
TBF.Size=UDim2.new(1,0,0,12) TBF.Position=UDim2.new(0,0,1,-12)
TBF.BackgroundColor3=TOP TBF.BorderSizePixel=0 TBF.Parent=TB

local Logo=Instance.new("TextLabel")
Logo.Size=UDim2.new(0,180,1,0) Logo.Position=UDim2.new(0,18,0,0)
Logo.BackgroundTransparency=1 Logo.Text="NEVERLOSE" Logo.TextColor3=TXT
Logo.TextSize=18 Logo.Font=Enum.Font.GothamBlack
Logo.TextXAlignment=Enum.TextXAlignment.Left Logo.Parent=TB

for i,pos in ipairs({-100,-72,-44}) do
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0,20,0,20) l.Position=UDim2.new(1,pos,0,9)
    l.BackgroundTransparency=1 l.Text=({"◆","▪","○"})[i]
    l.TextColor3=MID l.TextSize=15 l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Center l.Parent=TB
end

local SB=Instance.new("Frame")
SB.Size=UDim2.new(0,158,1,-38) SB.Position=UDim2.new(0,0,0,38)
SB.BackgroundColor3=SIDE SB.BorderSizePixel=0 SB.Parent=W

local pages={} local tabs={} local curTab=nil
local function showPage(id) for k,v in pairs(pages) do v.Visible=(k==id) end end

local yy=10
local function sbGroup(t)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-20,0,18) l.Position=UDim2.new(0,18,0,yy)
    l.BackgroundTransparency=1 l.Text=t l.TextColor3=DIM
    l.TextSize=10 l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=SB
    yy=yy+22
end

local function sbTab(n,ic,id)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,26) b.Position=UDim2.new(0,0,0,yy)
    b.BackgroundColor3=SIDE b.Text="" b.BorderSizePixel=0
    b.AutoButtonColor=false b.Parent=SB
    yy=yy+26
    local i=Instance.new("TextLabel")
    i.Name="IC" i.Size=UDim2.new(0,14,0,14) i.Position=UDim2.new(0,22,0.5,-7)
    i.BackgroundTransparency=1 i.Text=ic i.TextColor3=DIM i.TextSize=12
    i.Font=Enum.Font.GothamBold i.Parent=b
    local t=Instance.new("TextLabel")
    t.Name="TX" t.Size=UDim2.new(1,-50,1,0) t.Position=UDim2.new(0,44,0,0)
    t.BackgroundTransparency=1 t.Text=n t.TextColor3=MID t.TextSize=11
    t.Font=Enum.Font.Gotham t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=b
    b.MouseEnter:Connect(function()
        if curTab~=b then b.BackgroundColor3=Color3.fromRGB(16,16,20) end
    end)
    b.MouseLeave:Connect(function()
        if curTab~=b then b.BackgroundColor3=SIDE end
    end)
    b.MouseButton1Click:Connect(function()
        if curTab then
            curTab.BackgroundColor3=SIDE
            curTab.IC.TextColor3=DIM
            curTab.TX.TextColor3=MID
        end
        curTab=b b.BackgroundColor3=Color3.fromRGB(24,24,30)
        i.TextColor3=ACC2 t.TextColor3=TXT
        showPage(id)
    end)
    tabs[id]=b
end

-- Профиль
local UB=Instance.new("Frame")
UB.Size=UDim2.new(1,0,0,50) UB.Position=UDim2.new(0,0,1,-50)
UB.BackgroundTransparency=1 UB.Parent=SB
local avBG=Instance.new("Frame")
avBG.Size=UDim2.new(0,30,0,30) avBG.Position=UDim2.new(0,14,0,10)
avBG.BackgroundColor3=ROW avBG.BorderSizePixel=0 avBG.Parent=UB
Instance.new("UICorner",avBG).CornerRadius=UDim.new(1,0)
local av=Instance.new("ImageLabel")
av.Size=UDim2.new(1,-2,1,-2) av.Position=UDim2.new(0,1,0,1)
av.BackgroundTransparency=1 av.Parent=avBG
Instance.new("UICorner",av).CornerRadius=UDim.new(1,0)
pcall(function()
    local t=PL:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
    if t then av.Image=t end
end)
local nm=Instance.new("TextLabel")
nm.Size=UDim2.new(0,120,0,12) nm.Position=UDim2.new(0,52,0,14)
nm.BackgroundTransparency=1 nm.Text=string.upper(LP.Name) nm.TextColor3=TXT
nm.TextSize=10 nm.Font=Enum.Font.GothamBold
nm.TextXAlignment=Enum.TextXAlignment.Left nm.Parent=UB
local tl=Instance.new("TextLabel")
tl.Size=UDim2.new(0,120,0,10) tl.Position=UDim2.new(0,52,0,26)
tl.BackgroundTransparency=1 tl.Text="LIFETIME" tl.TextColor3=ACC2
tl.TextSize=9 tl.Font=Enum.Font.Gotham
tl.TextXAlignment=Enum.TextXAlignment.Left tl.Parent=UB

local CT=Instance.new("Frame")
CT.Size=UDim2.new(1,-158,1,-38) CT.Position=UDim2.new(0,158,0,38)
CT.BackgroundTransparency=1 CT.Parent=W

local function newPage(id)
    local p=Instance.new("ScrollingFrame")
    p.Size=UDim2.new(1,0,1,0) p.BackgroundTransparency=1
    p.BorderSizePixel=0 p.ScrollBarThickness=3 p.ScrollBarImageColor3=OFF
    p.CanvasSize=UDim2.new(0,0,0,0) p.Visible=false p.Parent=CT
    pages[id]=p
    local l=Instance.new("UIListLayout")
    l.Padding=UDim.new(0,8) l.SortOrder=Enum.SortOrder.LayoutOrder l.Parent=p
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        p.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+20)
    end)
    return p
end

local function col(parent,xr)
    local c=Instance.new("Frame")
    c.Size=UDim2.new(0.5,-18,0,0) c.AutomaticSize=Enum.AutomaticSize.Y
    c.Position=UDim2.new(xr,xr==0 and 12 or 6,0,12)
    c.BackgroundTransparency=1 c.Parent=parent
    local l=Instance.new("UIListLayout")
    l.Padding=UDim.new(0,6) l.SortOrder=Enum.SortOrder.LayoutOrder l.Parent=c
    return c
end

local function section(parent,title)
    local s=Instance.new("Frame")
    s.Size=UDim2.new(1,0,0,0) s.AutomaticSize=Enum.AutomaticSize.Y
    s.BackgroundTransparency=1 s.Parent=parent
    local l=Instance.new("UIListLayout")
    l.Padding=UDim.new(0,2) l.SortOrder=Enum.SortOrder.LayoutOrder l.Parent=s
    local t=Instance.new("TextLabel")
    t.Size=UDim2.new(1,0,0,18) t.BackgroundTransparency=1
    t.Text=title t.TextColor3=TXT t.TextSize=12 t.Font=Enum.Font.GothamBold
    t.TextXAlignment=Enum.TextXAlignment.Left t.LayoutOrder=0 t.Parent=s
    return s
end

local function row(parent,name)
    local r=Instance.new("Frame")
    r.Size=UDim2.new(1,0,0,24) r.BackgroundColor3=ROW
    r.BorderSizePixel=0 r.Parent=parent
    Instance.new("UICorner",r).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(0.5,0,1,0) l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1 l.Text=name l.TextColor3=TXT
    l.TextSize=10 l.Font=Enum.Font.Gotham
    l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=r
    return r
end

local function toggle(r,on,cb)
    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,22,0,11) pill.Position=UDim2.new(1,-30,0.5,-5.5)
    pill.BackgroundColor3=on and ACC or OFF pill.BorderSizePixel=0 pill.Parent=r
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local d=Instance.new("Frame")
    d.Size=UDim2.new(0,7,0,7)
    d.Position=on and UDim2.new(1,-9,0.5,-3.5) or UDim2.new(0,2,0.5,-3.5)
    d.BackgroundColor3=Color3.new(1,1,1) d.BorderSizePixel=0 d.Parent=pill
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,60,1,0) btn.Position=UDim2.new(1,-60,0,0)
    btn.BackgroundTransparency=1 btn.Text="" btn.Parent=r
    local st=on
    btn.MouseButton1Click:Connect(function()
        st=not st
        if st then pill.BackgroundColor3=ACC d.Position=UDim2.new(1,-9,0.5,-3.5)
        else pill.BackgroundColor3=OFF d.Position=UDim2.new(0,2,0.5,-3.5) end
        if cb then cb(st) end
    end)
end

local function slider(r,key,minV,maxV,suf,dec)
    local val=tonumber(C[key]) or minV
    local pct=math.clamp((val-minV)/(maxV-minV),0,1)
    local vl=Instance.new("TextLabel")
    vl.Size=UDim2.new(0,60,1,0) vl.Position=UDim2.new(1,-96,0,0)
    vl.BackgroundTransparency=1
    vl.Text=dec and string.format("%.2f",val)..(suf or "") or tostring(math.floor(val))..(suf or "")
    vl.TextColor3=TXT vl.TextSize=10 vl.Font=Enum.Font.Gotham
    vl.TextXAlignment=Enum.TextXAlignment.Right vl.Parent=r
    local bar=Instance.new("Frame")
    bar.Size=UDim2.new(0,90,0,3) bar.Position=UDim2.new(1,-192,0.5,-1.5)
    bar.BackgroundColor3=OFF bar.BorderSizePixel=0 bar.Parent=r
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(pct,0,1,0) fill.BackgroundColor3=ACC
    fill.BorderSizePixel=0 fill.Parent=bar
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local hit=Instance.new("TextButton")
    hit.Size=UDim2.new(0,90,0,20) hit.Position=UDim2.new(1,-192,0.5,-10)
    hit.BackgroundTransparency=1 hit.Text="" hit.Parent=r
    local drag=false
    local function setX(x)
        local abs=bar.AbsolutePosition.X
        local sz=bar.AbsoluteSize.X
        if sz==0 then return end
        local p=math.clamp((x-abs)/sz,0,1)
        local v=minV+(maxV-minV)*p
        C[key]=v
        fill.Size=UDim2.new(p,0,1,0)
        vl.Text=dec and string.format("%.2f",v)..(suf or "") or tostring(math.floor(v))..(suf or "")
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true setX(i.Position.X) end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then setX(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
end

local function keybind(r,key)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,90,0,18) btn.Position=UDim2.new(1,-100,0.5,-9)
    btn.BackgroundColor3=Color3.fromRGB(30,30,38) btn.Text=tostring(C[key])
    btn.TextColor3=TXT btn.TextSize=10 btn.Font=Enum.Font.Gotham
    btn.BorderSizePixel=0 btn.Parent=r
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,3)
    local listening=false
    btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening=true btn.Text="..." btn.BackgroundColor3=ACC
    end)
    UIS.InputBegan:Connect(function(input,gpe)
        if gpe then return end
        if not listening then return end
        local nk=nil
        if input.UserInputType==Enum.UserInputType.Keyboard then nk=input.KeyCode.Name
        elseif input.UserInputType==Enum.UserInputType.MouseButton1 then nk="M1"
        elseif input.UserInputType==Enum.UserInputType.MouseButton2 then nk="M2"
        elseif input.UserInputType==Enum.UserInputType.MouseButton3 then nk="M3" end
        if not nk then return end
        C[key]=nk btn.Text=nk btn.BackgroundColor3=Color3.fromRGB(30,30,38) listening=false
    end)
end

local function dropdown(r,key,opts)
    local vl=Instance.new("TextButton")
    vl.Size=UDim2.new(0,150,1,0) vl.Position=UDim2.new(1,-174,0,0)
    vl.BackgroundTransparency=1 vl.Text=tostring(C[key] or "None")
    vl.TextColor3=MID vl.TextSize=10 vl.Font=Enum.Font.Gotham
    vl.TextXAlignment=Enum.TextXAlignment.Right vl.Parent=r
    local ar=Instance.new("TextLabel")
    ar.Size=UDim2.new(0,10,1,0) ar.Position=UDim2.new(1,-14,0,0)
    ar.BackgroundTransparency=1 ar.Text="▾" ar.TextColor3=MID
    ar.TextSize=10 ar.Font=Enum.Font.GothamBold ar.Parent=r
    local open=false local lf
    vl.MouseButton1Click:Connect(function()
        if open then if lf then lf:Destroy() end open=false return end
        open=true
        lf=Instance.new("Frame")
        lf.Size=UDim2.new(0,130,0,#opts*18+4) lf.Position=UDim2.new(1,-140,1,2)
        lf.BackgroundColor3=Color3.fromRGB(28,28,33) lf.BorderSizePixel=0
        lf.ZIndex=20 lf.Parent=r
        Instance.new("UICorner",lf).CornerRadius=UDim.new(0,3)
        local ll=Instance.new("UIListLayout",lf) ll.Padding=UDim.new(0,1)
        for _,o in ipairs(opts) do
            local ob=Instance.new("TextButton")
            ob.Size=UDim2.new(1,-4,0,17)
            ob.BackgroundColor3=Color3.fromRGB(28,28,33) ob.Text=o
            ob.TextColor3=TXT ob.TextSize=10 ob.Font=Enum.Font.Gotham
            ob.BorderSizePixel=0 ob.ZIndex=21 ob.AutoButtonColor=false ob.Parent=lf
            Instance.new("UICorner",ob).CornerRadius=UDim.new(0,2)
            ob.MouseEnter:Connect(function() ob.BackgroundColor3=Color3.fromRGB(40,40,48) end)
            ob.MouseLeave:Connect(function() ob.BackgroundColor3=Color3.fromRGB(28,28,33) end)
            ob.MouseButton1Click:Connect(function()
                C[key]=o vl.Text=o lf:Destroy() open=false
            end)
        end
    end)
end

-- ============================================================
-- ВКЛАДКИ
-- ============================================================
local R=newPage("Rage") local rL=col(R,0) local rR=col(R,0.5)
local r1=section(rL,"MAIN")
toggle(row(r1,"Enable Ragebot"),false,function(v) C.RageE=v end)
keybind(row(r1,"Keybind"),"RageK")
slider(row(r1,"Field of View"),"RageF",50,800,"°")
slider(row(r1,"Aim Speed"),"RageS",1,15,"")
dropdown(row(r1,"Hitbox"),"RageHit",{"Balaclava","UpperTorso","LowerTorso"})
local r2=section(rR,"TARGET")
toggle(row(r2,"Auto Fire"),true,function(v) C.RageAuto=v end)
dropdown(row(r2,"Priority"),"RageTarget",{"Nearest","Lowest HP","Closest to Crosshair"})
local r3=section(rR,"EXTRA")
toggle(row(r3,"Double Tap"),false,function(v) C.DTap=v end)
slider(row(r3,"DT Delay"),"DTapDelay",0.02,0.3,"s",true)
toggle(row(r3,"No Spread"),false,function(v) C.NoSpread=v end)
toggle(row(r3,"No Recoil"),false,function(v) C.NoRecoil=v end)

local AA=newPage("AA") local aL=col(AA,0) local aR=col(AA,0.5)
local a1=section(aL,"ANTI-AIM")
toggle(row(a1,"Enable AA"),false,function(v) C.AAE=v end)
dropdown(row(a1,"Mode"),"AAM",{"Static","Jitter","Spin","Spin 360","Random"})
dropdown(row(a1,"Pitch Mode"),"AAPM",{"Disabled","Down","Up","Zero","Custom"})
slider(row(a1,"Yaw"),"AAY",-180,180,"°")
slider(row(a1,"Spin Speed"),"AAS",1,60,"")
local a2=section(aR,"BODY")
dropdown(row(a2,"Body Yaw"),"AAB",{"Disabled","Left","Right","Back"})

local L=newPage("Legit") local lL=col(L,0) local lR=col(L,0.5)
local l1=section(lL,"MAIN")
toggle(row(l1,"Enabled"),false,function(v) C.LegitE=v end)
keybind(row(l1,"Keybind"),"LegitK")
slider(row(l1,"Field of View"),"LegitF",10,500,"px")
slider(row(l1,"Smooth"),"LegitS",1,40,"")
local l2=section(lR,"METHOD")
dropdown(row(l2,"Hitbox"),"LegitHit",{"Balaclava","UpperTorso","LowerTorso"})

local P=newPage("Players") local pL=col(P,0) local pR=col(P,0.5)
local e1=section(pL,"ESP")
toggle(row(e1,"Enable ESP"),false,function(v) C.ESP=v end)
toggle(row(e1,"Box"),true,function(v) C.ESPBox=v end)
toggle(row(e1,"Name"),true,function(v) C.ESPName=v end)
toggle(row(e1,"Health Bar"),true,function(v) C.ESPHP=v end)
toggle(row(e1,"Distance"),true,function(v) C.ESPDist=v end)
toggle(row(e1,"Team Check"),false,function(v) C.ESPTeam=v end)

-- MOVEMENT (новое)
local MV=newPage("Move") local mvL=col(MV,0) local mvR=col(MV,0.5)
local m1=section(mvL,"MOVEMENT")
toggle(row(m1,"Speed Hack"),false,function(v) C.SpeedE=v end)
slider(row(m1,"Speed Value"),"SpeedV",16,200,"")
toggle(row(m1,"Bunny Hop"),false,function(v) C.Bhop=v end)
toggle(row(m1,"Edge Jump"),false,function(v) C.EdgeJump=v end)
toggle(row(m1,"Infinite Jump"),false,function(v) C.InfJump=v end)
toggle(row(m1,"Noclip"),false,function(v) C.Noclip=v end)
local m2=section(mvR,"FLIGHT")
toggle(row(m2,"Fly"),false,function(v) C.Fly=v end)
slider(row(m2,"Fly Speed"),"FlySpeed",10,200,"")
local m3=section(mvR,"FAKE LAG")
toggle(row(m3,"Fake Lag"),false,function(v) C.FakeLag=v end)
slider(row(m3,"Delay"),"FakeLagMs",20,300,"ms")

local V=newPage("View") local vL=col(V,0) local vR=col(V,0.5)
local v1=section(vL,"CAMERA")
toggle(row(v1,"Third Person"),false,function(v) C.TP=v end)
slider(row(v1,"TP Distance"),"TPD",5,50,"")
slider(row(v1,"TP Height"),"TPHeight",-3,10,"")
local v2=section(vR,"HUD")
toggle(row(v2,"Crosshair"),false,function(v) C.Cross=v end)
slider(row(v2,"Cross Size"),"CSz",5,30,"px")

local M=newPage("Main") local mL=col(M,0) local mR=col(M,0.5)
local mm=section(mR,"MENU")
local uRow=row(mm,"Uninject")
local uBtn=Instance.new("TextButton")
uBtn.Size=UDim2.new(0,80,0,18) uBtn.Position=UDim2.new(1,-88,0.5,-9)
uBtn.BackgroundColor3=DANGER uBtn.Text="UNINJECT"
uBtn.TextColor3=Color3.new(1,1,1) uBtn.TextSize=9 uBtn.Font=Enum.Font.GothamBold
uBtn.BorderSizePixel=0 uBtn.Parent=uRow
Instance.new("UICorner",uBtn).CornerRadius=UDim.new(0,3)

sbGroup("Aimbot")
sbTab("Ragebot","◆","Rage")
sbTab("Anti Aim","◇","AA")
sbTab("Legitbot","○","Legit")
sbGroup("Visuals")
sbTab("Players","●","Players")
sbTab("View","◎","View")
sbGroup("Movement")
sbTab("Movement","▶","Move")
sbGroup("Misc")
sbTab("Main","✕","Main")

curTab=tabs.Players
if curTab then
    curTab.BackgroundColor3=Color3.fromRGB(24,24,30)
    curTab.IC.TextColor3=ACC2
    curTab.TX.TextColor3=TXT
end
showPage("Players")

-- ============================================================
-- ОБЩИЕ ФУНКЦИИ
-- ============================================================
local function hasVest(c)
    if not c then return false end
    local a=c:FindFirstChild("CharacterArmor")
    return a and a:FindFirstChild("VestDetails")~=nil
end
local function isAlly(t)
    if not LP.Character then return false end
    return hasVest(LP.Character)==hasVest(t)
end
local function getChars() return workspace:FindFirstChild("Characters") or CHARS end
local function isAlive(f)
    if not f or not f.Parent then return false end
    local d=f:GetAttribute("Dead")
    if d==true or d=="true" or d==1 then return false end
    local hp=f:GetAttribute("Health")
    if hp and tonumber(hp) and tonumber(hp)<=0 then return false end
    return true
end
local function getEnemies(hb)
    hb=hb or "Balaclava"
    local list={}
    local ch=getChars() if not ch then return list end
    for _,f in ipairs(ch:GetChildren()) do
        if f.Name~=LP.Name and #f:GetChildren()>3 and isAlive(f) and not isAlly(f) then
            local p=f:FindFirstChild(hb,true) or f:FindFirstChild("Balaclava",true) or f:FindFirstChild("UpperTorso",true)
            if p then table.insert(list,{part=p,char=f}) end
        end
    end
    return list
end

local isLegit,isRage=false,false
local function keyMatch(input,kn)
    if kn=="M1" then return input.UserInputType==Enum.UserInputType.MouseButton1 end
    if kn=="M2" then return input.UserInputType==Enum.UserInputType.MouseButton2 end
    if kn=="M3" then return input.UserInputType==Enum.UserInputType.MouseButton3 end
    local ok,kc=pcall(function() return Enum.KeyCode[kn] end)
    if ok and kc then return input.KeyCode==kc end
    return false
end

UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if keyMatch(i,C.LegitK) then isLegit=true end
    if keyMatch(i,C.RageK) then isRage=true end
    if i.KeyCode==Enum.KeyCode.Insert then W.Visible=not W.Visible end
end)
UIS.InputEnded:Connect(function(i)
    if keyMatch(i,C.LegitK) then isLegit=false end
    if keyMatch(i,C.RageK) then isRage=false end
end)

-- ============================================================
-- ANTI-AIM (__newindex)
-- ============================================================
local aaAngle=0
local aaRandom=0

RS.Heartbeat:Connect(function(dt)
    if not C.AAE then return end
    aaAngle=aaAngle+dt*C.AAS
    if C.AAM=="Random" and math.random()<0.15 then
        aaRandom=math.rad(math.random(-180,180))
    end
end)

local function getAAYaw()
    if C.AAM=="Spin" or C.AAM=="Spin 360" then return aaAngle
    elseif C.AAM=="Jitter" then return math.rad(C.AAY)+math.sin(aaAngle*8)*math.rad(60)
    elseif C.AAM=="Random" then return math.rad(C.AAY)+aaRandom
    else return math.rad(C.AAY) end
end

local function getAAPitch()
    if C.AAPM=="Down" then return math.rad(89)
    elseif C.AAPM=="Up" then return math.rad(-89)
    elseif C.AAPM=="Custom" then return math.rad(45)
    else return 0 end
end

local function getAABody()
    if C.AAB=="Left" then return math.rad(-90)
    elseif C.AAB=="Right" then return math.rad(90)
    elseif C.AAB=="Back" then return math.rad(180)
    else return 0 end
end

pcall(function()
    if not hookmetamethod then return end
    local mt=getrawmetatable(game)
    if not mt then return end
    local oldNI=mt.__newindex    setreadonly(mt,false)
    mt.__newindex=newcclosure(function(self,key,value)
        if C.AAE and key=="CFrame" and typeof(value)=="CFrame" and typeof(self)=="Instance" then
            local char=LP.Character
            if char and self:IsDescendantOf(char) then
                local n=self.Name
                if n=="UpperTorso" or n=="Torso" then
                    local yaw=getAAYaw()+getAABody()
                    return oldNI(self,key,CFrame.new(value.Position)*CFrame.Angles(0,yaw,0))
                elseif n=="LowerTorso" then
                    local by=getAABody()
                    return oldNI(self,key,CFrame.new(value.Position)*CFrame.Angles(0,by,0))
                elseif n=="Balaclava" then
                    if C.RageE and isRage then return oldNI(self,key,value) end
                    local yaw=getAAYaw()
                    local pt=getAAPitch()
                    return oldNI(self,key,CFrame.new(value.Position)*CFrame.Angles(pt,yaw,0))
                end
            end
        end
        return oldNI(self,key,value)
    end)
    setreadonly(mt,true)
end)

-- ============================================================
-- SPEED (базовый)
-- ============================================================
RS.Heartbeat:Connect(function()
    if not C.SpeedE then return end
    local char=LP.Character if not char then return end
    pcall(function() char:SetAttribute("Speed",C.SpeedV) end)
    pcall(function() char:SetAttribute("WalkSpeed",C.SpeedV) end)
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.WalkSpeed=C.SpeedV end) end
end)

-- ============================================================
-- BHOP (MovementV2)
-- ============================================================
local VU=game:GetService("VirtualUser")
local bhopAutoHeld=false
local bhopConn=nil

local function startBhop()
    if bhopConn then return end
    bhopConn=RS.Heartbeat:Connect(function()
        if not C.Bhop then
            bhopAutoHeld=false
            return
        end
        if UIS:GetFocusedTextBox() then bhopAutoHeld=false return end
        local char=LP.Character
        if not char then bhopAutoHeld=false return end
        local root=char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not root then bhopAutoHeld=false return end
        local p=RaycastParams.new()
        p.FilterDescendantsInstances={char}
        p.FilterType=Enum.RaycastFilterType.Exclude
        local ground=workspace:Raycast(root.Position,Vector3.new(0,-5,0),p)
        if ground then
            pcall(function() if hum then hum.Jump=true end end)
            pcall(function() VU:ButtonDown(2,Enum.KeyCode.Space) end)
            task.wait(0.02)
            pcall(function() VU:ButtonUp(2,Enum.KeyCode.Space) end)
            pcall(function()
                local vel=root.AssemblyLinearVelocity
                if vel and math.abs(vel.Y)<5 then
                    root.AssemblyLinearVelocity=Vector3.new(vel.X,50,vel.Z)
                end
            end)
        end
    end)
end

-- ============================================================
-- EDGE JUMP
-- ============================================================
local wasGrounded=true
local lastGroundAt=0
RS.Heartbeat:Connect(function()
    if not C.EdgeJump then return end
    local char=LP.Character if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    local p=RaycastParams.new()
    p.FilterDescendantsInstances={char}
    p.FilterType=Enum.RaycastFilterType.Exclude
    local ground=workspace:Raycast(root.Position,Vector3.new(0,-3.6,0),p)
    local grounded=ground~=nil
    local now=tick()
    if grounded then lastGroundAt=now end
    if wasGrounded and not grounded and root.AssemblyLinearVelocity.Y<2 and now-lastGroundAt<0.12 then
        hum.Jump=true
    end
    wasGrounded=grounded
end)

-- ============================================================
-- INFINITE JUMP
-- ============================================================
local ijHeld=false
UIS.JumpRequest:Connect(function()
    if not C.InfJump then return end
    if UIS:GetFocusedTextBox() then return end
    local char=LP.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    local root=char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    if hum.FloorMaterial==Enum.Material.Air then
        root.AssemblyLinearVelocity=Vector3.new(root.AssemblyLinearVelocity.X,50,root.AssemblyLinearVelocity.Z)
    end
end)

-- ============================================================
-- NOCLIP
-- ============================================================
local noclipOrig={}
local noclipChar=nil
local noclipConn=nil

local function restoreNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn=nil end
    for part,val in pairs(noclipOrig) do
        if part.Parent then pcall(function() part.CanCollide=val end) end
    end
    table.clear(noclipOrig)
    noclipChar=nil
end

local function enableNoclip(char)
    if noclipChar~=char then
        restoreNoclip()
        noclipChar=char
        for _,item in ipairs(char:GetDescendants()) do
            if item:IsA("BasePart") then
                if noclipOrig[item]==nil then noclipOrig[item]=item.CanCollide end
                item.CanCollide=false
            end
        end
        noclipConn=char.DescendantAdded:Connect(function(item)
            if C.Noclip and item:IsA("BasePart") then
                if noclipOrig[item]==nil then noclipOrig[item]=item.CanCollide end
                item.CanCollide=false
            end
        end)
    end
end

RS.Heartbeat:Connect(function()
    if not C.Noclip then
        if noclipChar then restoreNoclip() end
        return
    end
    local char=LP.Character if not char then return end
    enableNoclip(char)
end)

-- ============================================================
-- FLY
-- ============================================================
local flyBodyVel=nil
local flyBodyGyro=nil
local flyActive=false

local function stopFly()
    flyActive=false
    if flyBodyVel then pcall(function() flyBodyVel:Destroy() end) flyBodyVel=nil end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) flyBodyGyro=nil end
end

RS.Heartbeat:Connect(function()
    if not C.Fly then if flyActive then stopFly() end return end
    local char=LP.Character if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if not flyBodyVel then
        pcall(function()
            flyBodyVel=Instance.new("BodyVelocity")
            flyBodyVel.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
            flyBodyVel.Velocity=Vector3.zero
            flyBodyVel.Parent=root
        end)
        pcall(function()
            flyBodyGyro=Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque=Vector3.new(math.huge,math.huge,math.huge)
            flyBodyGyro.P=9
            flyBodyGyro.D=1.5
            flyBodyGyro.CFrame=root.CFrame
            flyBodyGyro.Parent=root
        end)
        flyActive=true
    end
    local move=Vector3.zero
    if not UIS:GetFocusedTextBox() then
        local cf=CAM.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then move=move+cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move=move-cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move=move+cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move=move-cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move=move-Vector3.new(0,1,0) end
    end
    if flyBodyVel then
        flyBodyVel.Velocity=move.Magnitude>0 and move.Unit*C.FlySpeed or Vector3.zero
    end
    if flyBodyGyro then
        flyBodyGyro.CFrame=CAM.CFrame
    end
end)

-- ============================================================
-- FAKE LAG
-- ============================================================
local fakeLagRemote=nil
local fakeLagQueue={}
local fakeLagLastRelease=0

local function findMovementRemote()
    local remotes=child(NS,"Database","Security","Remotes")
    local ok,res=safeRequire(remotes)
    if ok and type(res)=="table" and res.Movement and res.Movement.Input then
        return res.Movement.Input
    end
    return nil
end

local function installFakeLag()
    if fakeLagRemote then return true end
    fakeLagRemote=findMovementRemote()
    if not fakeLagRemote then return false end
    local mt=getrawmetatable(game)
    if not mt or not mt.__namecall then return false end
    local oldNC=mt.__namecall
    setreadonly(mt,false)
    mt.__namecall=newcclosure(function(self,...)
        if self==fakeLagRemote and C.FakeLag then
            local method=getnamecallmethod()
            if method=="FireServer" or method=="Send" then
                local now=tick()
                local args=table.pack(...)
                fakeLagQueue[#fakeLagQueue+1]=args
                local target=C.FakeLagMs/1000
                if now-fakeLagLastRelease>=target or #fakeLagQueue>=20 then
                    fakeLagLastRelease=now
                    for _,pack in ipairs(fakeLagQueue) do
                        oldNC(self,table.unpack(pack,1,pack.n))
                    end
                    table.clear(fakeLagQueue)
                end
                return
            end
        end
        return oldNC(self,...)
    end)
    setreadonly(mt,true)
    return true
end

RS.Heartbeat:Connect(function()
    if C.FakeLag then
        if not fakeLagRemote then installFakeLag() end
    elseif #fakeLagQueue>0 then
        if fakeLagRemote then
            local mt=getrawmetatable(game)
            if mt and mt.__namecall then
                for _,pack in ipairs(fakeLagQueue) do
                    pcall(function() fakeLagRemote.Send(fakeLagRemote,table.unpack(pack,1,pack.n)) end)
                end
            end
        end
        table.clear(fakeLagQueue)
    end
end)

-- ============================================================
-- LEGIT AIM
-- ============================================================
RS.RenderStepped:Connect(function()
    if not C.LegitE or not isLegit then return end
    local mp=UIS:GetMouseLocation()
    local en=getEnemies(C.LegitHit)
    local best,bd=nil,C.LegitF/2
    for _,e in ipairs(en) do
        local sp,on=CAM:WorldToViewportPoint(e.part.Position)
        if on then
            local d=(Vector2.new(sp.X,sp.Y)-mp).Magnitude
            if d<bd then bd=d best=e.part end
        end
    end
    if best then
        local sp=CAM:WorldToViewportPoint(best.Position)
        local dx=sp.X-mp.X
        local dy=sp.Y-mp.Y
        local dist=math.sqrt(dx*dx+dy*dy)
        if dist>5 then
            local speed=C.LegitS
            local mx=dx/speed
            local my=dy/speed
            if math.abs(mx)>10 then mx=(mx>0 and 10 or -10) end
            if math.abs(my)>10 then my=(my>0 and 10 or -10) end
            if mousemoverel then pcall(function() mousemoverel(mx,my) end) end
        end
    end
end)

-- ============================================================
-- RAGE AIM
-- ============================================================
local lastFireTick=0
RS.RenderStepped:Connect(function()
    if not C.RageE or not isRage then return end
    local en=getEnemies(C.RageHit)
    if #en==0 then return end
    local target=en[1]
    if C.RageTarget=="Lowest HP" then
        local lowest=math.huge
        for _,e in ipairs(en) do
            local hp=tonumber(e.char:GetAttribute("Health")) or 100
            if hp<lowest then lowest=hp target=e end
        end
    elseif C.RageTarget=="Closest to Crosshair" then
        local center=CAM.ViewportSize/2
        local bd=math.huge
        for _,e in ipairs(en) do
            local sp,on=CAM:WorldToViewportPoint(e.part.Position)
            if on then
                local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
                if d<bd then bd=d target=e end
            end
        end
    end
    local sp,on=CAM:WorldToViewportPoint(target.part.Position)
    if on then
        local mp=UIS:GetMouseLocation()
        local dx=sp.X-mp.X
        local dy=sp.Y-mp.Y
        local dist=math.sqrt(dx*dx+dy*dy)
        if dist>5 then
            local speed=C.RageS
            local mx=dx/speed
            local my=dy/speed
            if math.abs(mx)>10 then mx=(mx>0 and 10 or -10) end
            if math.abs(my)>10 then my=(my>0 and 10 or -10) end
            if mousemoverel then pcall(function() mousemoverel(mx,my) end) end
        end
    end
    if C.RageAuto then
        local now=tick()
        if now-lastFireTick>0.05 then
            lastFireTick=now
            pcall(function() if mouse1click then mouse1click() end end)
        end
    end
end)

-- ============================================================
-- DT + NOSPREAD (__namecall)
-- ============================================================
local lastDT=0
pcall(function()
    if not hookmetamethod then return end
    local oldNC
    oldNC=hookmetamethod(game,"__namecall",function(self,...)
        local method=getnamecallmethod()
        local lm=string.lower(method)
        if C.NoSpread and (lm:find("spread") or lm:find("inaccuracy")) then
            return 0
        end
        if C.NoRecoil and (lm:find("recoil") or lm:find("kick")) then
            return CFrame.new()
        end
        if method=="FireServer" and C.DTap and C.RageE and isRage then
            local now=tick()
            if now-lastDT>0.1 then
                lastDT=now
                local args={...}
                oldNC(self,table.unpack(args))
                task.spawn(function()
                    task.wait(C.DTapDelay)
                    pcall(function() oldNC(self,table.unpack(args)) end)
                end)
                return
            end
        end
        return oldNC(self,...)
    end)
end)

-- DT fallback через мышь
local lastDT2=0
UIS.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.UserInputType==Enum.UserInputType.MouseButton1 and C.DTap and C.RageE and isRage then
        local now=tick()
        if now-lastDT2>0.15 then
            lastDT2=now
            task.spawn(function()
                task.wait(C.DTapDelay)
                pcall(function() if mouse1click then mouse1click() end end)
            end)
        end
    end
end)

-- ============================================================
-- THIRD PERSON
-- ============================================================
local function setVis(sh)
    local c=LP.Character if not c then return end
    for _,o in ipairs(c:GetDescendants()) do
        pcall(function()
            if o:IsA("BasePart") then
                if sh then
                    if not o:GetAttribute("OrigTM") then o:SetAttribute("OrigTM",o.LocalTransparencyModifier) end
                    o.LocalTransparencyModifier=0
                else
                    if o:GetAttribute("OrigTM") then o.LocalTransparencyModifier=o:GetAttribute("OrigTM") end
                end
            end
        end)
    end
end

RS:BindToRenderStep("TP_Cam",Enum.RenderPriority.Camera.Value+10,function()
    if not C.TP then setVis(false) return end
    local c=LP.Character if not c then return end
    if not (c:FindFirstChild("UpperTorso") or c:FindFirstChild("HumanoidRootPart")) then return end
    setVis(true)
    pcall(function()
        local curCF=CAM.CFrame
        local look=curCF.LookVector
        local newPos=curCF.Position - look*C.TPD + Vector3.new(0,C.TPHeight,0)
        CAM.CFrame=CFrame.new(newPos, newPos + look)
    end)
end)

-- ============================================================
-- CROSSHAIR
-- ============================================================
local crossHolder=Instance.new("Frame")
crossHolder.Name="Cross"
crossHolder.Size=UDim2.fromScale(1,1)
crossHolder.BackgroundTransparency=1
crossHolder.Parent=gui
local crossArms={}
for i=1,4 do
    local arm=Instance.new("Frame")
    arm.Size=UDim2.new(0,1,0,1)
    arm.BackgroundColor3=Color3.new(1,1,1)
    arm.BorderSizePixel=0
    arm.AnchorPoint=Vector2.new(0.5,0.5)
    arm.Visible=false
    arm.Parent=crossHolder
    crossArms[i]=arm
end
local crossDot=Instance.new("Frame")
crossDot.Size=UDim2.new(0,2,0,2)
crossDot.BackgroundColor3=Color3.new(1,1,1)
crossDot.BorderSizePixel=0
crossDot.AnchorPoint=Vector2.new(0.5,0.5)
crossDot.Visible=false
crossDot.Parent=crossHolder

RS.RenderStepped:Connect(function()
    if not C.Cross then
        for _,a in ipairs(crossArms) do a.Visible=false end
        crossDot.Visible=false
        return
    end
    local vp=CAM.ViewportSize
    local cx,cy=vp.X/2,vp.Y/2
    local gap=6
    local len=C.CSz
    local th=2
    for i,arm in ipairs(crossArms) do
        local horiz=i<=2
        local sign=(i%2==1) and -1 or 1
        if horiz then
            arm.Size=UDim2.fromOffset(len,th)
            arm.Position=UDim2.fromOffset(cx+sign*(gap+len/2),cy)
        else
            arm.Size=UDim2.fromOffset(th,len)
            arm.Position=UDim2.fromOffset(cx,cy+sign*(gap+len/2))
        end
        arm.Visible=true
    end
    crossDot.Position=UDim2.fromOffset(cx,cy)
    crossDot.Visible=true
end)

-- ============================================================
-- ESP
-- ============================================================
local espC={}
local function mkESP()
    local e={}
    e.bOut=Drawing.new("Square") e.b=Drawing.new("Square")
    e.n=Drawing.new("Text") e.hOut=Drawing.new("Line")
    e.h=Drawing.new("Line") e.d=Drawing.new("Text")
    e.bOut.Thickness=3 e.bOut.Filled=false e.bOut.Color=Color3.new(0,0,0)
    e.b.Thickness=1 e.b.Filled=false e.b.Color=Color3.fromRGB(255,80,80)
    e.n.Center=true e.n.Outline=true e.n.Color=Color3.new(1,1,1) e.n.Size=15
    e.d.Center=true e.d.Outline=true e.d.Color=Color3.fromRGB(200,200,200) e.d.Size=12
    e.hOut.Thickness=3 e.hOut.Color=Color3.new(0,0,0)
    e.h.Thickness=1 e.h.Color=Color3.fromRGB(0,255,0)
    return e
end
local function hideE(e)
    e.bOut.Visible=false e.b.Visible=false e.n.Visible=false
    e.hOut.Visible=false e.h.Visible=false e.d.Visible=false
end
local function delE(e)
    for _,d in pairs(e) do pcall(function() d:Remove() end) end
end
local function cBox(parts)
    local x0,y0,z0=math.huge,math.huge,math.huge
    local x1,y1,z1=-math.huge,-math.huge,-math.huge
    for _,p in ipairs(parts) do
        if p:IsA("BasePart") then
            local s=p.Size
            local hx,hy,hz=s.X*.5,s.Y*.5,s.Z*.5
            local px,py,pz=p.Position.X,p.Position.Y,p.Position.Z
            if px-hx<x0 then x0=px-hx end
            if py-hy<y0 then y0=py-hy end
            if pz-hz<z0 then z0=pz-hz end
            if px+hx>x1 then x1=px+hx end
            if py+hy>y1 then y1=py+hy end
            if pz+hz>z1 then z1=pz+hz end
        end
    end
    if x0==math.huge then return nil end
    return x0,y0,z0,x1,y1,z1
end

RS.RenderStepped:Connect(function()
    for f,e in pairs(espC) do
        if not f or not f.Parent then delE(e) espC[f]=nil
        elseif not isAlive(f) or not C.ESP then hideE(e) end
    end
    if not C.ESP then return end
    local ch=getChars() if not ch then return end
    for _,f in ipairs(ch:GetChildren()) do
        if f.Name~=LP.Name and #f:GetChildren()>3 and isAlive(f) then
            if not C.ESPTeam or not isAlly(f) then
                local parts={}
                for _,o in ipairs(f:GetDescendants()) do
                    if o:IsA("BasePart") and o.Name~="CameraPart" then table.insert(parts,o) end
                end
                local x0,y0,z0,x1,y1,z1=cBox(parts)
                if x0 then
                    if not espC[f] then espC[f]=mkESP() end
                    local e=espC[f]
                    local cx,cy,cz=(x0+x1)*.5,(y0+y1)*.5,(z0+z1)*.5
                    local sp,vis=CAM:WorldToViewportPoint(Vector3.new(cx,cy,cz))
                    if vis and sp.Z>0 then
                        local sc=20/sp.Z
                        local w,h=86*sc,155*sc
                        local bx,by=sp.X-w*.5,sp.Y-h*.5
                        if C.ESPBox then
                            e.bOut.Size=Vector2.new(w,h) e.bOut.Position=Vector2.new(bx,by) e.bOut.Visible=true
                            e.b.Size=Vector2.new(w,h) e.b.Position=Vector2.new(bx,by) e.b.Visible=true
                        else e.bOut.Visible=false e.b.Visible=false end
                        if C.ESPName then
                            e.n.Text=f.Name e.n.Position=Vector2.new(sp.X,by-16) e.n.Visible=true
                        else e.n.Visible=false end
                        local hp=tonumber(f:GetAttribute("Health"))
                        if C.ESPHP and hp then
                            local mh=tonumber(f:GetAttribute("MaxHealth")) or 100
                            local pct=math.clamp(hp/mh,0,1)
                            local hx=bx-6
                            e.hOut.From=Vector2.new(hx,by) e.hOut.To=Vector2.new(hx,by+h) e.hOut.Visible=true
                            e.h.From=Vector2.new(hx,by+h) e.h.To=Vector2.new(hx,by+h-h*pct) e.h.Color=Color3.new(1-pct,pct,0) e.h.Visible=true
                        else e.hOut.Visible=false e.h.Visible=false end
                        if C.ESPDist then
                            local d=math.floor((CAM.CFrame.Position-Vector3.new(cx,cy,cz)).Magnitude)
                            e.d.Text="["..d.."m]" e.d.Position=Vector2.new(sp.X,by+h+2) e.d.Visible=true
                        else e.d.Visible=false end
                    else hideE(e) end
                else
                    if espC[f] then hideE(espC[f]) end
                end
            else
                if espC[f] then hideE(espC[f]) end
            end
        end
    end
end)

-- ============================================================
-- UNINJECT
-- ============================================================
uBtn.MouseButton1Click:Connect(function()
    for f,e in pairs(espC) do delE(e) end
    pcall(function() setVis(false) end)
    pcall(function() stopFly() end)
    pcall(function() restoreNoclip() end)
    pcall(function() gui:Destroy() end)
end)

-- ============================================================
-- ПЕРЕТАСКИВАНИЕ
-- ============================================================
local drag,ds,sp
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true ds=i.Position sp=W.Position
    end
end)
TB.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-ds
        W.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)

print("[NL] Loaded. Bhop/Speed/Noclip/Fly/DT ready.")
