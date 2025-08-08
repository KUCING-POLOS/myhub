
-- ===== Services =====
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- ===== Helpers =====
local function mk(class, parent, props)
    local o = Instance.new(class)
    if props then for k,v in pairs(props) do o[k]=v end end
    o.Parent = parent
    return o
end
local function corner(inst, r) mk("UICorner", inst, {CornerRadius = UDim.new(0, r or 12)}) end
local function stroke(inst, t) mk("UIStroke", inst, {Color = Color3.fromRGB(60,60,70), Thickness = t or 1}) end

-- Theme
local BG   = Color3.fromRGB(24, 26, 32)
local PANEL= Color3.fromRGB(36, 38, 46)
local TEXT = Color3.fromRGB(235,238,245)
local SUB  = Color3.fromRGB(170,176,190)
local ACC  = Color3.fromRGB(92,156,255)

-- bersihin UI lama
local old = CoreGui:FindFirstChild("KucingHubUI")
if old then old:Destroy() end

-- ===== Root & window size =====
local gui = mk("ScreenGui", CoreGui, {Name="KucingHubUI", ZIndexBehavior=Enum.ZIndexBehavior.Sibling, ResetOnSpawn=false})
local function getWindowSize()
    local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
    local w = math.clamp(math.floor(vw * 0.42), 420, 540)
    local h = math.clamp(math.floor(vh * 0.38), 240, 300)
    return UDim2.fromOffset(w, h)
end

-- ===== Dropdown Overlay (global) =====
local DD_OVERLAY = Instance.new("TextButton")
DD_OVERLAY.Name = "DDOverlay"
DD_OVERLAY.BackgroundTransparency = 1
DD_OVERLAY.AutoButtonColor = false
DD_OVERLAY.Text = ""
DD_OVERLAY.Visible = false
DD_OVERLAY.Size = UDim2.fromScale(1,1)
DD_OVERLAY.ZIndex = 999
DD_OVERLAY.Parent = gui

-- ===== Floating restore button (GitHub avatar + draggable) =====
local GITHUB_USER = "KUCING-POLOS" -- ubah kalau beda
local floatBtn = mk("ImageButton", gui, {
    Name="KucingFloat", Size = UDim2.fromOffset(40,40),
    AnchorPoint = Vector2.new(0.5,1), Position = UDim2.new(0.5, 0, 1, -20),
    BackgroundColor3 = PANEL, AutoButtonColor = true, Visible = false, ZIndex = 1000
})
corner(floatBtn,20); stroke(floatBtn,1)

local http = (syn and syn.request) or request or http_request
local getasset = getcustomasset or getsynasset
local function tryLoadGithubAvatar()
    if not (http and writefile and getasset) then return false end
    local url = ("https://github.com/%s.png?size=100"):format(GITHUB_USER)
    local ok, res = pcall(http, {Url = url, Method = "GET"})
    if not ok or not res or not res.Body then return false end
    local fname = "kucinghub_avatar.png"
    pcall(function() if isfile(fname) then delfile(fname) end end)
    local okW = pcall(writefile, fname, res.Body); if not okW then return false end
    local okA, asset = pcall(getasset, fname); if not okA then return false end
    floatBtn.Image = asset; return true
end
if not tryLoadGithubAvatar() then
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok then floatBtn.Image = img end
end

-- ===== Window =====
local win = mk("Frame", gui, {
    Name="Window", BackgroundColor3 = PANEL, Size = getWindowSize(),
    Position = UDim2.fromScale(.5,.5), AnchorPoint = Vector2.new(.5,.5), ClipsDescendants = true
})
corner(win,14); stroke(win,1)

-- Header
local header = mk("Frame", win, {Size=UDim2.new(1,0,0,36), BackgroundColor3=PANEL})
corner(header,10); stroke(header,1)
mk("TextLabel", header, {
    BackgroundTransparency=1, Size=UDim2.new(1,-120,1,0), Position=UDim2.fromOffset(10,0),
    Font=Enum.Font.GothamBold, Text="Kucing Hub | v1.1", TextColor3=TEXT, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left
})
local btnMin = mk("TextButton", header, {Size=UDim2.fromOffset(22,22), Position=UDim2.new(1,-70,0,7), AnchorPoint=Vector2.new(1,0), Text="–", TextColor3=TEXT, BackgroundColor3=Color3.fromRGB(50,50,58), Font=Enum.Font.GothamBold, TextSize=16})
local btnMax = mk("TextButton", header, {Size=UDim2.fromOffset(22,22), Position=UDim2.new(1,-44,0,7), AnchorPoint=Vector2.new(1,0), Text="□", TextColor3=TEXT, BackgroundColor3=Color3.fromRGB(50,50,58), Font=Enum.Font.GothamBold, TextSize=14})
local btnClose = mk("TextButton", header, {Size=UDim2.fromOffset(22,22), Position=UDim2.new(1,-18,0,7), AnchorPoint=Vector2.new(1,0), Text="×", TextColor3=Color3.fromRGB(255,120,120), BackgroundColor3=Color3.fromRGB(50,50,58), Font=Enum.Font.GothamBold, TextSize=14})
corner(btnMin,8); stroke(btnMin,1); corner(btnMax,8); stroke(btnMax,1); corner(btnClose,8); stroke(btnClose,1)

-- Body
local body = mk("Frame", win, {Size=UDim2.new(1,0,1,-44), Position=UDim2.fromOffset(0,40), BackgroundTransparency=1})

-- Sidebar
local sidebar = mk("ScrollingFrame", body, {
    Size=UDim2.new(0,116,1,0), BackgroundColor3=BG,
    ScrollBarThickness=4, CanvasSize=UDim2.new(0,0,0,0), ClipsDescendants=true
})
corner(sidebar,10); stroke(sidebar,1)
local list = mk("UIListLayout", sidebar, {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder})
mk("UIPadding", sidebar, {PaddingTop=UDim.new(0,6), PaddingLeft=UDim.new(0,6), PaddingRight=UDim.new(0,6)})
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    sidebar.CanvasSize = UDim2.new(0,0,0, list.AbsoluteContentSize.Y + 12)
end)

local content = mk("Frame", body, {Size=UDim2.new(1,-124,1,0), Position=UDim2.fromOffset(124,0), BackgroundTransparency=1})

-- Pages factory
local pages, current = {}, nil
local function addPage(name)
    local page = mk("ScrollingFrame", content, {Name=name.."Page", Size=UDim2.fromScale(1,1), CanvasSize=UDim2.new(0,0,0,0), BackgroundTransparency=1, ScrollBarThickness=4})
    mk("UIListLayout", page, {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder})
    page.Visible = false; pages[name]=page; return page
end
local function switch(name) for n,p in pairs(pages) do p.Visible=(n==name) end current=name end
local function addTab(name)
    local b = mk("TextButton", sidebar, {Size=UDim2.new(1,0,0,28), BackgroundColor3=BG, AutoButtonColor=false, Text="  "..name, Font=Enum.Font.GothamSemibold, TextColor3=SUB, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left})
    corner(b,8); stroke(b,1)
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3=Color3.fromRGB(30,32,38)}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(.12), {BackgroundColor3=BG}):Play() end)
    b.MouseButton1Click:Connect(function()
        for _,x in ipairs(sidebar:GetChildren()) do if x:IsA("TextButton") then x.TextColor3=SUB end end
        b.TextColor3 = ACC; switch(name)
    end)
    if not current then b.TextColor3=ACC; switch(name) end
end
local function card(parent, title, subtitle)
    local f = mk("Frame", parent, {Size=UDim2.new(1,-6,0,52), BackgroundColor3=PANEL})
    corner(f,10); stroke(f,1)
    mk("TextLabel", f, {BackgroundTransparency=1, Text=title, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=TEXT, Size=UDim2.new(1,-10,0,18), TextXAlignment=Enum.TextXAlignment.Left, Position=UDim2.fromOffset(6,6)})
    mk("TextLabel", f, {BackgroundTransparency=1, Text=subtitle or "", Font=Enum.Font.Gotham, TextSize=12, TextColor3=SUB, Size=UDim2.new(1,-10,0,16), TextXAlignment=Enum.TextXAlignment.Left, Position=UDim2.fromOffset(6,26)})
    return f
end

-- Collapsible card
local function addCollapsibleCard(parent, title, subtitle, defaultOpen)
    local wrap = mk("Frame", parent, {Size=UDim2.new(1,-6,0,52), BackgroundColor3=PANEL}); corner(wrap,10); stroke(wrap,1)
    local hdr = mk("TextButton", wrap, {Size=UDim2.new(1,0,0,52), BackgroundTransparency=1, Text="", AutoButtonColor=false})
    mk("TextLabel", hdr, {BackgroundTransparency=1, Text=title, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=TEXT, Size=UDim2.new(1,-40,0,20), Position=UDim2.fromOffset(10,6), TextXAlignment=Enum.TextXAlignment.Left})
    mk("TextLabel", hdr, {BackgroundTransparency=1, Text=subtitle or "", Font=Enum.Font.Gotham, TextSize=12, TextColor3=SUB, Size=UDim2.new(1,-40,0,16), Position=UDim2.fromOffset(10,28), TextXAlignment=Enum.TextXAlignment.Left})
    local arrow = mk("TextLabel", hdr, {Size=UDim2.fromOffset(20,20), Position=UDim2.new(1,-28,0,16), BackgroundTransparency=1, Text="›", Font=Enum.Font.GothamBold, TextSize=18, TextColor3=SUB})

    local content = mk("Frame", wrap, {Size=UDim2.new(1,0,0,0), Position=UDim2.fromOffset(0,52), BackgroundTransparency=1, ClipsDescendants=true})
    local cl = mk("UIListLayout", content, {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder})

    local open = (defaultOpen ~= false)
    local function layout()
        local h = open and (52 + cl.AbsoluteContentSize.Y + 12) or 52
        wrap.Size = UDim2.new(1,-6,0,h)
        content.Size = UDim2.new(1,0,0, open and (cl.AbsoluteContentSize.Y + 12) or 0)
        arrow.Rotation = open and 90 or 0
    end
    cl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(layout)
    hdr.MouseButton1Click:Connect(function() open = not open; layout() end)
    layout()
    return content
end

-- Slider
local function addSlider(parent, label, min, max, start, onChange)
    local f = mk("Frame", parent, {Size=UDim2.new(1,-6,0,56), BackgroundColor3=PANEL}); corner(f,10); stroke(f,1)
    mk("TextLabel", f, {BackgroundTransparency=1, Text=label, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=TEXT, Size=UDim2.new(1,-90,0,18), Position=UDim2.fromOffset(10,6), TextXAlignment=Enum.TextXAlignment.Left})
    local valLb = mk("TextLabel", f, {BackgroundTransparency=1, Text=tostring(start), Font=Enum.Font.Gotham, TextSize=13, TextColor3=SUB, Size=UDim2.new(0,80,0,18), Position=UDim2.new(1,-86,0,6), TextXAlignment=Enum.TextXAlignment.Right})

    local track = mk("Frame", f, {Size=UDim2.new(1,-24,0,8), Position=UDim2.fromOffset(12,36), BackgroundColor3=Color3.fromRGB(45,48,58)}); corner(track,4)
    local fill  = mk("Frame", track, {Size=UDim2.fromScale(0,1), BackgroundColor3=ACC}); corner(fill,4)
    local knob  = mk("Frame", track, {Size=UDim2.fromOffset(12,12), BackgroundColor3=Color3.fromRGB(255,255,255), AnchorPoint=Vector2.new(.5,.5)}); corner(knob,6); stroke(knob,1)

    local value = math.clamp(tonumber(start) or min, min, max)
    local function setPct(p)
        p = math.clamp(p, 0, 1)
        fill.Size = UDim2.fromScale(p,1)
        knob.Position = UDim2.fromScale(p,.5)
        value = math.floor(min + (max-min)*p + 0.5)
        valLb.Text = tostring(value)
        if onChange then onChange(value) end
    end
    setPct((value-min)/(max-min))

    local dragging = false
    local function setFromMouseX(x)
        local p = (x - track.AbsolutePosition.X)/track.AbsoluteSize.X
        setPct(p)
    end
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromMouseX(i.Position.X) end end)
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setFromMouseX(i.Position.X) end end)

    return {set=function(v) v=math.clamp(v,min,max); setPct((v-min)/(max-min)) end, get=function() return value end}
end

-- Toggle
local function addToggle(parent, label, default, onToggle)
    local f = mk("Frame", parent, {Size=UDim2.new(1,-6,0,44), BackgroundColor3=PANEL}); corner(f,10); stroke(f,1)
    mk("TextLabel", f, {BackgroundTransparency=1, Text=label, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=TEXT, Size=UDim2.new(1,-80,1,0), Position=UDim2.fromOffset(10,0), TextXAlignment=Enum.TextXAlignment.Left})
    local toggle = mk("TextButton", f, {Size=UDim2.fromOffset(48,26), Position=UDim2.new(1,-58,0.5,-13), BackgroundColor3=Color3.fromRGB(60,60,70), Text="", AutoButtonColor=false}); corner(toggle,14); stroke(toggle,1)
    local dot = mk("Frame", toggle, {Size=UDim2.fromOffset(22,22), Position=UDim2.fromOffset(2,2), BackgroundColor3=Color3.fromRGB(255,255,255)}); corner(dot,11)
    local on = default
    local function render() if on then toggle.BackgroundColor3=ACC; dot.Position=UDim2.fromOffset(24,2) else toggle.BackgroundColor3=Color3.fromRGB(60,60,70); dot.Position=UDim2.fromOffset(2,2) end end
    toggle.MouseButton1Click:Connect(function() on = not on; render(); if onToggle then onToggle(on) end end)
    render()
    return {set=function(v) on=not not v; render(); if onToggle then onToggle(on) end end, get=function() return on end}
end

-- Button
local function addButton(parent, label, onClick)
  local f = Instance.new("Frame", parent)
  f.Size = UDim2.new(1,-6,0,40); f.BackgroundColor3 = PANEL
  corner(f,10); stroke(f,1)
  local b = Instance.new("TextButton", f)
  b.Size = UDim2.new(1,-12,1,-10); b.Position = UDim2.fromOffset(6,5)
  b.Text = label; b.Font = Enum.Font.GothamSemibold; b.TextSize = 14
  b.TextColor3 = TEXT; b.BackgroundColor3 = Color3.fromRGB(50,50,58)
  corner(b,8); stroke(b,1)
  b.MouseButton1Click:Connect(function() if onClick then onClick() end end)
  return b
end

-- Dropdown (FIX: overlay + root + ZIndex + freeze scroll)
local function addDropdown(parent, label, options, defaultIndex, onChange)
    options = options or {}

    local f = mk("Frame", parent, {Size=UDim2.new(1,-6,0,56), BackgroundColor3=PANEL})
    corner(f,10); stroke(f,1); f.ZIndex = 40

    mk("TextLabel", f, {
        BackgroundTransparency=1, Text=label, Font=Enum.Font.GothamSemibold, TextSize=14,
        TextColor3=TEXT, Size=UDim2.new(1,-70,0,18), Position=UDim2.fromOffset(10,6),
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex = 41
    })

    local btn = mk("TextButton", f, {
        Size=UDim2.new(1,-20,0,26), Position=UDim2.fromOffset(10,28),
        Text="", BackgroundColor3=Color3.fromRGB(40,42,50), AutoButtonColor=false, ZIndex=42
    })
    corner(btn,8); stroke(btn,1)

    local txt = mk("TextLabel", btn, {
        Size=UDim2.new(1,-30,1,0), Position=UDim2.fromOffset(10,0),
        BackgroundTransparency=1, Text="Select", Font=Enum.Font.Gotham, TextSize=13,
        TextColor3=TEXT, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=43
    })
    mk("TextLabel", btn, {
        Size=UDim2.fromOffset(20,20), Position=UDim2.new(1,-20,0.5,-10),
        BackgroundTransparency=1, Text="▾", TextColor3=SUB, Font=Enum.Font.GothamBold,
        TextSize=14, ZIndex=43
    })

    -- list di root (supaya gak ke-clip) + ZIndex tinggi
    local listFrame = mk("Frame", gui, {Visible=false, BackgroundColor3=PANEL, ZIndex=100})
    corner(listFrame,8); stroke(listFrame,1)

    local sf = mk("ScrollingFrame", listFrame, {
        Size=UDim2.fromScale(1,1), CanvasSize=UDim2.new(0,0,0,0),
        BackgroundTransparency=1, ScrollBarThickness=4, ZIndex=101
    })
    local l = mk("UIListLayout", sf, {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder})
    mk("UIPadding", sf, {PaddingTop=UDim.new(0,4), PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,4), PaddingBottom=UDim.new(0,4)})
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0,0,0, l.AbsoluteContentSize.Y+8)
    end)

    local value, index = nil, defaultIndex or 1
    local function setIndex(i)
        index = math.clamp(i,1,math.max(1,#options))
        value = options[index]; txt.Text = tostring(value or "Select")
        if onChange then onChange(value) end
    end

    for i,opt in ipairs(options) do
        local item = mk("TextButton", sf, {
            Size=UDim2.new(1,-8,0,22), Text=tostring(opt),
            BackgroundColor3=Color3.fromRGB(44,46,54), TextColor3=TEXT,
            Font=Enum.Font.Gotham, TextSize=13, AutoButtonColor=true, ZIndex=102
        })
        corner(item,6); stroke(item,1)
        item.MouseButton1Click:Connect(function()
            setIndex(i)
            listFrame.Visible=false; DD_OVERLAY.Visible=false
            local page = parent
            while page and not page:IsA("ScrollingFrame") do page = page.Parent end
            if page then page.ScrollingEnabled = true end
        end)
    end

    local function openList()
        local absPos = btn.AbsolutePosition
        local absSize = btn.AbsoluteSize
        listFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 4)
        listFrame.Size     = UDim2.fromOffset(absSize.X, math.min(#options,6)*26 + 8)

        DD_OVERLAY.Visible = true
        listFrame.Visible  = true

        local page = parent
        while page and not page:IsA("ScrollingFrame") do page = page.Parent end
        if page then page.ScrollingEnabled = false end
    end
    local function closeList()
        listFrame.Visible=false
        DD_OVERLAY.Visible=false
        local page = parent
        while page and not page:IsA("ScrollingFrame") do page = page.Parent end
        if page then page.ScrollingEnabled = true end
    end

    btn.MouseButton1Click:Connect(function()
        if listFrame.Visible then closeList() else openList() end
    end)
    DD_OVERLAY.MouseButton1Click:Connect(closeList)

    setIndex(index)
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if listFrame.Visible then
            local absPos = btn.AbsolutePosition
            local absSize = btn.AbsoluteSize
            listFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 4)
            listFrame.Size     = UDim2.fromOffset(absSize.X, listFrame.Size.Y.Offset)
        end
    end)

    return {set=function(v) local i = table.find(options, v); if i then setIndex(i) end end, get=function() return value end}
end

-- Number Input
local function addNumberInput(parent, label, placeholder, default, onChange)
    local f = mk("Frame", parent, {Size=UDim2.new(1,-6,0,56), BackgroundColor3=PANEL}); corner(f,10); stroke(f,1)
    mk("TextLabel", f, {BackgroundTransparency=1, Text=label, Font=Enum.Font.GothamSemibold, TextSize=14,
        TextColor3=TEXT, Size=UDim2.new(1,-110,0,18), Position=UDim2.fromOffset(10,6), TextXAlignment=Enum.TextXAlignment.Left})
    local box = mk("TextBox", f, {Size=UDim2.new(0,140,0,26), Position=UDim2.new(1,-150,0,26), PlaceholderText=placeholder or "Ex: 20", Text=tostring(default or ""), Font=Enum.Font.Gotham, TextSize=13, TextColor3=TEXT, PlaceholderColor3=SUB, BackgroundColor3=Color3.fromRGB(40,42,50), ClearTextOnFocus=false})
    corner(box,8); stroke(box,1)
    local function apply() local n = tonumber(box.Text); if n and onChange then onChange(n) end end
    box.FocusLost:Connect(apply)
    return {set=function(v) box.Text = tostring(v or "") end, get=function() return tonumber(box.Text) end}
end

-- Pages & Tabs
local P_Main   = addPage("Main")
local P_Farm   = addPage("Farm")
local P_Shop   = addPage("Shop")
local P_Pet    = addPage("Pet")
local P_Utility= addPage("Utility")
local P_Misc   = addPage("Misc")
local P_Visual = addPage("Visual")
addTab("Main"); addTab("Farm"); addTab("Shop"); addTab("Pet"); addTab("Utility"); addTab("Misc"); addTab("Visual")

-- Info
card(P_Main, "Information", "Kucing Hub v1.1")

-- ===== Character =====
do
    local content = addCollapsibleCard(P_Main, "Character", "Basic movement & utility", true)

    addSlider(content, "Walk Speed", 8, 200, 16, function(v)
        local h = (LP.Character or LP.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v end
    end)

    addSlider(content, "Jump Power", 20, 200, 50, function(v)
        local h = (LP.Character or LP.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
        if h then h.UseJumpPower = true; h.JumpPower = v end
    end)

    local flyConn, flying = {}, false
    local function stopFly()
        flying = false
        for _,c in ipairs(flyConn) do pcall(function() c:Disconnect() end) end
        flyConn = {}
        local char = LP.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        for _,x in ipairs(hrp:GetChildren()) do if x:IsA("BodyGyro") or x:IsA("BodyVelocity") then x:Destroy() end end
    end
    local function startFly()
        local char = LP.Character or LP.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        stopFly(); flying = true
        local bg = Instance.new("BodyGyro", hrp); bg.P = 9e4; bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.CFrame = hrp.CFrame
        local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        local keys = {W=false,S=false,A=false,D=false,Up=false,Down=false}
        table.insert(flyConn, UIS.InputBegan:Connect(function(i,g)
            if g then return end
            if     i.KeyCode==Enum.KeyCode.W then keys.W=true
            elseif i.KeyCode==Enum.KeyCode.S then keys.S=true
            elseif i.KeyCode==Enum.KeyCode.A then keys.A=true
            elseif i.KeyCode==Enum.KeyCode.D then keys.D=true
            elseif i.KeyCode==Enum.KeyCode.Space then keys.Up=true
            elseif i.KeyCode==Enum.KeyCode.LeftShift then keys.Down=true end
        end))
        table.insert(flyConn, UIS.InputEnded:Connect(function(i)
            if     i.KeyCode==Enum.KeyCode.W then keys.W=false
            elseif i.KeyCode==Enum.KeyCode.S then keys.S=false
            elseif i.KeyCode==Enum.KeyCode.A then keys.A=false
            elseif i.KeyCode==Enum.KeyCode.D then keys.D=false
            elseif i.KeyCode==Enum.KeyCode.Space then keys.Up=false
            elseif i.KeyCode==Enum.KeyCode.LeftShift then keys.Down=false end
        end))
        table.insert(flyConn, RS.RenderStepped:Connect(function()
            if not flying then return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            bg.CFrame = cam.CFrame
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            local speed = (h and h.WalkSpeed or 16) * 1.2
            local dir = Vector3.new()
            if keys.W then dir += cam.CFrame.LookVector end
            if keys.S then dir -= cam.CFrame.LookVector end
            if keys.A then dir -= cam.CFrame.RightVector end
            if keys.D then dir += cam.CFrame.RightVector end
            if keys.Up then dir += Vector3.new(0,1,0) end
            if keys.Down then dir -= Vector3.new(0,1,0) end
            bv.Velocity = dir.Magnitude>0 and dir.Unit*speed or Vector3.new()
        end))
    end
    addToggle(content, "Fly (WASD + Space/Shift)", false, function(on) if on then startFly() else stopFly() end end)

    local afkConn
    addToggle(content, "Anti AFK", true, function(on)
        if afkConn then afkConn:Disconnect(); afkConn=nil end
        if on then
            local vu = game:GetService("VirtualUser")
            afkConn = LP.Idled:Connect(function() pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end) end)
        end
    end)

    local noclipConn
    addToggle(content, "No Clip", false, function(on)
        if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
        if on then
            noclipConn = RS.Stepped:Connect(function()
                local char = LP.Character
                if char then
                    for _,p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
    end)

    local infConn
    addToggle(content, "Infinite Jump", false, function(on)
        if infConn then infConn:Disconnect(); infConn=nil end
        if on then
            infConn = UIS.JumpRequest:Connect(function()
                local h = (LP.Character or LP.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end)
end

-- ===== SHOP =====
do
    local top = addCollapsibleCard(P_Shop, "Auto Sell Fruit", "", false)
    addToggle(top, "Auto Sell Fruit", false, function(on) print("AutoSellFruit:", on) end)

    local petCard = addCollapsibleCard(P_Shop, "Auto Sell Pet", "", false)
    addToggle(petCard, "Auto Sell Pet", false, function(on) print("AutoSellPet:", on) end)

    local buyCard = addCollapsibleCard(P_Shop, "Auto Buy", "", true)
    addToggle(buyCard, "Auto Buy (stock)", false, function(on) print("AutoBuy:", on) end)

    local seeds = {"All","Wheat","Carrot","Mango","Pumpkin"}
    local gears = {"All","Hoe","Sprinkler","Rod"}
    local eggs  = {"All","Common","Rare","Epic","Legendary"}

    addDropdown(buyCard, "Select Seed", seeds, 1, function(v) print("Seed:", v) end)
    addDropdown(buyCard, "Select Gear", gears, 1, function(v) print("Gear:", v) end)
    addDropdown(buyCard, "Select Egg",  eggs,  1, function(v) print("Egg:", v) end)
    addDropdown(buyCard, "Select Traveling Merchant Shop", {"Off","ItemA","ItemB","ItemC"}, 1, function(v) print("Merchant:", v) end)
end

-- ===== MISC =====
do
    card(P_Misc, "Tips", "Auto execute, jangan skip loading, webhook opsional")

    addNumberInput(P_Misc, "Auto Rejoin Delay", "Ex: 20", "", function(n) print("RejoinDelay:", n) end)
    addToggle(P_Misc, "Auto Rejoin", false, function(on) print("AutoRejoin:", on) end)

    local midPet = addCollapsibleCard(P_Misc, "Middle Pet", "", false)
    addButton(midPet, "Open", function() print("MiddlePet open") end)

    local infSpr = addCollapsibleCard(P_Misc, "Inf Sprinkler", "", false)
    addButton(infSpr, "Enable", function() print("InfSprinkler enable") end)

    local steal  = addCollapsibleCard(P_Misc, "Steal", "", false)
    addButton(steal, "Open", function() print("Steal open") end)

    local seedPack = addCollapsibleCard(P_Misc, "Seed Pack", "", false)
    addButton(seedPack, "Open", function() print("SeedPack open") end)

    local perf = addCollapsibleCard(P_Misc, "Performance", "", true)
    addToggle(perf, "Hide Plant", false, function(on) print("HidePlant:", on) end)
    addToggle(perf, "Hide Fruit", false, function(on) print("HideFruit:", on) end)
    addToggle(perf, "Remove Other Garden", false, function(on) print("RemoveGarden:", on) end)
    addToggle(perf, "Boost FPS (one-way)", false, function(on)
        if on then pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            game:GetService("Lighting").GlobalShadows = false
        end) end
        print("BoostFPS:", on)
    end)
    addToggle(perf, "Disable 3D Rendering", false, function(on)
        pcall(function() RS:Set3dRenderingEnabled(not on) end)
        print("Disable3D:", on)
    end)
    addToggle(perf, "Black Screen", false, function(on)
        if not gui:FindFirstChild("BlackOverlay") then mk("Frame", gui, {Name="BlackOverlay", BackgroundColor3=Color3.new(0,0,0), Size=UDim2.fromScale(1,1), Visible=false, ZIndex=999}) end
        gui.BlackOverlay.Visible = on
        print("BlackScreen:", on)
    end)
end

-- ===== Farm demo (placeholder) =====
do
    local c = card(P_Farm, "Auto Farm", "Toggle demo — ganti dengan logic game kamu")
    local toggle = mk("TextButton", c, {Size=UDim2.fromOffset(48,26), Position=UDim2.new(1,-60,0,18), AnchorPoint=Vector2.new(1,0), BackgroundColor3=Color3.fromRGB(60,60,70), Text="", AutoButtonColor=false})
    corner(toggle,14); stroke(toggle,1)
    local dot = mk("Frame", toggle, {Size=UDim2.fromOffset(22,22), Position=UDim2.fromOffset(2,2), BackgroundColor3=Color3.fromRGB(255,255,255)})
    corner(dot,11)
    local on,running,delayVal=false,false,2
    local function render() if on then toggle.BackgroundColor3=ACC; dot.Position=UDim2.fromOffset(24,2) else toggle.BackgroundColor3=Color3.fromRGB(60,60,70); dot.Position=UDim2.fromOffset(2,2) end end
    render()
    toggle.MouseButton1Click:Connect(function()
        on = not on; render()
        if on and not running then
            running = true
            task.spawn(function()
                while on do
                    print("[Kucing Hub] farm tick"); task.wait(delayVal + math.random()*0.5)
                end
                running=false
            end)
        end
    end)
end

-- ===== Drag window + clamp =====
local dragging, dragStart, startPos
local function clampToViewport(pos, size)
    local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
    local x = math.clamp(pos.X.Offset, 8 - size.X.Offset/2, vw - 8 - size.X.Offset/2)
    local y = math.clamp(pos.Y.Offset, 8 - size.Y.Offset/2, vh - 8 - size.Y.Offset/2)
    return UDim2.new(.5, x, .5, y)
end
header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=i.Position; startPos=win.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position - dragStart
        local newPos=UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        win.Position = clampToViewport(newPos, win.Size)
    end
end)

-- ===== Min / Max / Close =====
local normalSize, normalPos = win.Size, win.Position
btnMin.MouseButton1Click:Connect(function()
    win.Visible=false
    floatBtn.Visible=true
end)
btnMax.MouseButton1Click:Connect(function()
    if win.Size.X.Offset < 680 then
        TweenService:Create(win, TweenInfo.new(.2), {Size=UDim2.fromOffset(680, 420), Position=UDim2.fromScale(.5,.5)}):Play()
    else
        TweenService:Create(win, TweenInfo.new(.2), {Size=normalSize, Position=normalPos}):Play()
    end
end)
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Restore dari tombol kecil
floatBtn.MouseButton1Click:Connect(function()
    floatBtn.Visible=false; win.Visible=true
end)

-- Drag tombol kecil (clamp)
local draggingF, dragStartF, startPosF
floatBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        draggingF=true; dragStartF=i.Position; startPosF=floatBtn.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then draggingF=false end end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if draggingF and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStartF
        local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
        local bw, bh = floatBtn.AbsoluteSize.X, floatBtn.AbsoluteSize.Y
        local nx = math.clamp(startPosF.X.Offset + d.X, bw/2, vw - bw/2)
        local ny = math.clamp(startPosF.Y.Offset + d.Y, bh, vh)
        floatBtn.Position = UDim2.fromOffset(nx, ny)
    end
end)

-- Responsive (window + tombol kecil)
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if win.Visible then
        win.Size = getWindowSize()
        normalSize = win.Size
        win.Position = UDim2.fromScale(.5,.5)
        normalPos = win.Position
    else
        local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
        local bw, bh = floatBtn.AbsoluteSize.X, floatBtn.AbsoluteSize.Y
        local x = math.clamp(floatBtn.Position.X.Offset, bw/2, vw - bw/2)
        local y = math.clamp(floatBtn.Position.Y.Offset, bh, vh)
        floatBtn.Position = UDim2.fromOffset(x, y)
    end
end)

print("[Kucing Hub] loaded v1.1")
