
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local old = CoreGui:FindFirstChild("MyHub_Sidebar")
if old then old:Destroy() end

local function mk(c,p,pr) local o=Instance.new(c); if pr then for k,v in pairs(pr) do o[k]=v end end; o.Parent=p; return o end
local function corner(inst,r) mk("UICorner",inst,{CornerRadius=UDim.new(0,r or 10)}) end
local function stroke(inst,a) mk("UIStroke",inst,{Color=Color3.fromRGB(60,60,70),Thickness=a or 1}) end

local BG   = Color3.fromRGB(24, 26, 32)
local PANEL= Color3.fromRGB(36, 38, 46)
local TEXT = Color3.fromRGB(235,238,245)
local SUB  = Color3.fromRGB(170,176,190)
local ACC  = Color3.fromRGB(92,156,255)

local sg = mk("ScreenGui", CoreGui, {Name="MyHub_Sidebar", ZIndexBehavior=Enum.ZIndexBehavior.Sibling})

local root = mk("Frame", sg, {
    Size=UDim2.fromOffset(720, 420),
    Position=UDim2.fromScale(.5,.5), AnchorPoint=Vector2.new(.5,.5),
    BackgroundColor3=PANEL
})
corner(root,14); stroke(root,1)

local drag, start, orig
root.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true; start=i.Position; orig=root.Position
        i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-start; root.Position=UDim2.new(orig.X.Scale, orig.X.Offset+d.X, orig.Y.Scale, orig.Y.Offset+d.Y)
    end
end)

-- header
local header = mk("Frame", root, {Size=UDim2.new(1, -20, 0, 44), Position=UDim2.fromOffset(10,10), BackgroundColor3=PANEL})
corner(header,10); stroke(header,1)
mk("TextLabel", header, {BackgroundTransparency=1, Size=UDim2.new(1, -12, 1, 0), Position=UDim2.fromOffset(12,0),
    Font=Enum.Font.GothamBold, Text="MyHub - Premium | v0.3", TextColor3=TEXT, TextSize=18, TextXAlignment=Enum.TextXAlignment.Left})

local body = mk("Frame", root, {Size=UDim2.new(1,-20,1,-64), Position=UDim2.fromOffset(10,54), BackgroundTransparency=1})
local sidebar = mk("Frame", body, {Size=UDim2.new(0, 160, 1, 0), BackgroundColor3=BG})
corner(sidebar,12); stroke(sidebar,1)
local content = mk("Frame", body, {Size=UDim2.new(1,-172,1,0), Position=UDim2.fromOffset(172,0), BackgroundTransparency=1})

-- tab list
local list = mk("UIListLayout", sidebar, {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder})
mk("UIPadding", sidebar, {PaddingTop=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10)})

-- page container
local pages = {}
local function addPage(name)
    local page = mk("ScrollingFrame", content, {
        Name=name.."Page", Size=UDim2.fromScale(1,1), CanvasSize=UDim2.new(0,0,0,0),
        BackgroundTransparency=1, ScrollBarThickness=4
    })
    mk("UIListLayout", page, {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder})
    mk("UIPadding", page, {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,4), PaddingBottom=UDim.new(0,8)})
    page.Visible = false
    pages[name] = page
    return page
end

local current
local function switch(name)
    for n,p in pairs(pages) do p.Visible = (n==name) end
    current = name
end

local function addTab(name, icon)
    local btn = mk("TextButton", sidebar, {
        Size=UDim2.new(1, -0, 0, 36), BackgroundColor3 = BG, AutoButtonColor = false,
        Text = "  "..name, Font=Enum.Font.GothamSemibold, TextColor3=SUB, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
    })
    corner(btn,10); stroke(btn,1)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(.12), {BackgroundColor3=Color3.fromRGB(30,32,38)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(.12), {BackgroundColor3=BG}):Play() end)
    btn.MouseButton1Click:Connect(function()
        for _,b in ipairs(sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3=SUB end end
        btn.TextColor3 = ACC; switch(name)
    end)
    if not current then btn.TextColor3=ACC; switch(name) end
end

-- card helper
local function card(parent, title, subtitle)
    local f = mk("Frame", parent, {Size=UDim2.new(1,-8,0,64), BackgroundColor3=PANEL})
    corner(f,12); stroke(f,1); mk("UIPadding", f, {PaddingLeft=UDim.new(0,12), PaddingTop=UDim.new(0,10), PaddingRight=UDim.new(0,12)})
    mk("TextLabel", f, {BackgroundTransparency=1, Text=title, Font=Enum.Font.GothamSemibold, TextSize=16, TextColor3=TEXT,
        Size=UDim2.new(1,-140,0,20), TextXAlignment=Enum.TextXAlignment.Left})
    mk("TextLabel", f, {BackgroundTransparency=1, Text=subtitle or "", Font=Enum.Font.Gotham, TextSize=13, TextColor3=SUB,
        Size=UDim2.new(1,-140,0,18), Position=UDim2.fromOffset(0,24), TextXAlignment=Enum.TextXAlignment.Left})
    return f
end

-- ====== Tabs ======
local P_Main   = addPage("Main")
local P_Farm   = addPage("Farm")
local P_Shop   = addPage("Shop")
local P_Pet    = addPage("Pet")
local P_Utility= addPage("Utility")
local P_Misc   = addPage("Misc")
local P_Visual = addPage("Visual")

addTab("Main")
addTab("Farm")
addTab("Shop")
addTab("Pet")
addTab("Utility")
addTab("Misc")
addTab("Visual")

-- ====== Contoh isi ======
-- Main
do
    local c = card(P_Main, "Information", "Status hub & versi")
    local lbl = mk("TextLabel", c, {BackgroundTransparency=1, Text="MyHub v0.3 • Executor: "..(identifyexecutor and identifyexecutor() or "Unknown"),
        Font=Enum.Font.Gotham, TextSize=13, TextColor3=SUB, Size=UDim2.new(1, -12, 0, 18), Position=UDim2.fromOffset(0, 42), TextXAlignment=Enum.TextXAlignment.Left})
end

-- Farm (toggle + slider demo, nanti dihubungkan ke modul)
local on=false; local running=false; local delayVal=2
do
    local c = card(P_Farm, "Auto Farm", "Nyalakan untuk mulai (demo)")
    local toggle = mk("TextButton", c, {Size=UDim2.fromOffset(52,28), Position=UDim2.new(1,-64,0,18), AnchorPoint=Vector2.new(1,0),
        BackgroundColor3=Color3.fromRGB(60,60,70), Text="", AutoButtonColor=false})
    corner(toggle,14); stroke(toggle,1)
    local dot = mk("Frame", toggle, {Size=UDim2.fromOffset(24,24), Position=UDim2.fromOffset(2,2), BackgroundColor3=Color3.fromRGB(255,255,255)})
    corner(dot,12)

    local function render()
        if on then toggle.BackgroundColor3=ACC; dot.Position=UDim2.fromOffset(26,2) else
            toggle.BackgroundColor3=Color3.fromRGB(60,60,70); dot.Position=UDim2.fromOffset(2,2) end
    end; render()

    toggle.MouseButton1Click:Connect(function()
        on=not on; render()
        if on and not running then
            running=true
            task.spawn(function()
                while on do
                    print("[MyHub] farm tick (delay="..tostring(delayVal)..")")
                    task.wait(delayVal + math.random()*0.5) -- delay acak biar human-like
                end
                running=false
            end)
        end
    end)

    -- slider sederhana (3 tombol +/-)
    local minus = mk("TextButton", c, {Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-200,0,18), AnchorPoint=Vector2.new(1,0),
        BackgroundColor3=Color3.fromRGB(60,60,70), Text="-", TextColor3=TEXT, Font=Enum.Font.GothamBold, TextSize=16})
    corner(minus,8); stroke(minus,1)
    local cur = mk("TextLabel", c, {Size=UDim2.fromOffset(96,28), Position=UDim2.new(1,-100,0,18), AnchorPoint=Vector2.new(1,0),
        BackgroundColor3=Color3.fromRGB(50,50,58), Text="", TextColor3=TEXT, Font=Enum.Font.GothamSemibold, TextSize=14})
    corner(cur,8); stroke(cur,1)
    local plus = mk("TextButton", c, {Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-60,0,18), AnchorPoint=Vector2.new(1,0),
        BackgroundColor3=Color3.fromRGB(60,60,70), Text="+", TextColor3=TEXT, Font=Enum.Font.GothamBold, TextSize=16})
    corner(plus,8); stroke(plus,1)
    local function show() cur.Text=("Delay: "..string.format("%.1f",delayVal).."s") end; show()
    minus.MouseButton1Click:Connect(function() delayVal=math.clamp(delayVal-0.5,0.5,10); show() end)
    plus.MouseButton1Click:Connect(function() delayVal=math.clamp(delayVal+0.5,0.5,10); show() end)
end

-- Placeholder kartu pada tab lain
card(P_Shop, "Shop", "Tempat aksi beli/jual nanti")
card(P_Pet, "Pet", "Fitur hewan peliharaan nanti")
card(P_Utility, "Utility", "Server hop / misc tools")
card(P_Misc, "Misc", "Fitur ekstra")
card(P_Visual, "Visual", "ESP/Theme dsb (jika perlu)")

print("[MyHub] Sidebar UI loaded")
