
-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Helpers
local function mk(class, parent, props)
	local o = Instance.new(class)
	if props then for k,v in pairs(props) do o[k]=v end end
	o.Parent = parent
	return o
end
local function corner(inst, r)
	mk("UICorner", inst, {CornerRadius = UDim.new(0, r or 12)})
end
local function stroke(inst, t)
	mk("UIStroke", inst, {Color = Color3.fromRGB(60,60,70), Thickness = t or 1})
end

-- Theme
local BG   = Color3.fromRGB(24, 26, 32)
local PANEL= Color3.fromRGB(36, 38, 46)
local TEXT = Color3.fromRGB(235,238,245)
local SUB  = Color3.fromRGB(170,176,190)
local ACC  = Color3.fromRGB(92,156,255)

-- Clean old
local old = CoreGui:FindFirstChild("KucingHubUI")
if old then old:Destroy() end

-- Root GUI
local gui = mk("ScreenGui", CoreGui, {Name = "KucingHubUI", ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false})

-- Floating profile button (for minimized state)
local floatBtn = mk("ImageButton", gui, {
	Name = "KucingFloat",
	Size = UDim2.fromOffset(56,56),
	Position = UDim2.fromOffset(16, (workspace.CurrentCamera.ViewportSize.Y - 72)),
	BackgroundColor3 = PANEL,
	AutoButtonColor = true,
	Visible = false,
})
corner(floatBtn, 28); stroke(floatBtn,1)

-- set profile image
local ok, img = pcall(function()
	return Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)
if ok then floatBtn.Image = img else floatBtn.Image = "rbxassetid://0" end

-- Main Window
local win = mk("Frame", gui, {
	Name = "Window",
	BackgroundColor3 = PANEL,
	Size = UDim2.fromOffset(720, 420),
	Position = UDim2.fromScale(.5,.5),
	AnchorPoint = Vector2.new(.5,.5),
})
corner(win,14); stroke(win,1)

-- Dragging via header
local dragging, dragStart, startPos

-- Header
local header = mk("Frame", win, {Size = UDim2.new(1,-16,0,44), Position = UDim2.fromOffset(8,8), BackgroundColor3 = PANEL})
corner(header,10); stroke(header,1)
local title = mk("TextLabel", header, {BackgroundTransparency=1, Size=UDim2.new(1,-160,1,0), Position=UDim2.fromOffset(12,0),
	Font=Enum.Font.GothamBold, Text="Kucing Hub - Premium | v0.4", TextColor3 = TEXT, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left})

-- Window controls (minimize, maximize, close)
local btnMin = mk("TextButton", header, {Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-92,0,8), AnchorPoint=Vector2.new(1,0), Text="–", TextColor3=TEXT, BackgroundColor3 = Color3.fromRGB(50,50,58), Font=Enum.Font.GothamBold, TextSize=18})
corner(btnMin,8); stroke(btnMin,1)
local btnMax = mk("TextButton", header, {Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-56,0,8), AnchorPoint=Vector2.new(1,0), Text="□", TextColor3=TEXT, BackgroundColor3 = Color3.fromRGB(50,50,58), Font=Enum.Font.GothamBold, TextSize=16})
corner(btnMax,8); stroke(btnMax,1)
local btnClose = mk("TextButton", header, {Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-20,0,8), AnchorPoint=Vector2.new(1,0), Text="×", TextColor3=Color3.fromRGB(255,120,120), BackgroundColor3 = Color3.fromRGB(50,50,58), Font=Enum.Font.GothamBold, TextSize=16})
corner(btnClose,8); stroke(btnClose,1)

-- Layout: sidebar + content
local body = mk("Frame", win, {Size=UDim2.new(1,-16,1,-60), Position = UDim2.fromOffset(8,52), BackgroundTransparency = 1})
local sidebar = mk("Frame", body, {Size=UDim2.new(0,160,1,0), BackgroundColor3 = BG})
corner(sidebar,12); stroke(sidebar,1)
local content = mk("Frame", body, {Size=UDim2.new(1,-172,1,0), Position=UDim2.fromOffset(172,0), BackgroundTransparency=1})

mk("UIListLayout", sidebar, {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder})
mk("UIPadding", sidebar, {PaddingTop=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10)})

-- Pages
local pages = {}
local function addPage(name)
	local page = mk("ScrollingFrame", content, {Name = name.."Page", Size = UDim2.fromScale(1,1), CanvasSize = UDim2.new(0,0,0,0), BackgroundTransparency=1, ScrollBarThickness=4})
	mk("UIListLayout", page, {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
	mk("UIPadding", page, {PaddingTop=UDim.new(0,8), PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,4), PaddingBottom=UDim.new(0,8)})
	page.Visible=false
	pages[name]=page
	return page
end

local current
local function switch(name)
	for n,p in pairs(pages) do p.Visible = (n==name) end
	current = name
end

local function addTab(name)
	local btn = mk("TextButton", sidebar, {Size=UDim2.new(1,0,0,36), BackgroundColor3 = BG, AutoButtonColor=false, Text="  "..name, Font=Enum.Font.GothamSemibold, TextColor3=SUB, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left})
	corner(btn,10); stroke(btn,1)
	btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(.12), {BackgroundColor3 = Color3.fromRGB(30,32,38)}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(.12), {BackgroundColor3 = BG}):Play() end)
	btn.MouseButton1Click:Connect(function()
		for _,b in ipairs(sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3=SUB end end
		btn.TextColor3 = ACC; switch(name)
	end)
	if not current then btn.TextColor3=ACC; switch(name) end
end

local function card(parent, title, subtitle)
	local f = mk("Frame", parent, {Size=UDim2.new(1,-8,0,64), BackgroundColor3=PANEL})
	corner(f,12); stroke(f,1)
	mk("UIPadding", f, {PaddingLeft=UDim.new(0,12), PaddingTop=UDim.new(0,10), PaddingRight=UDim.new(0,12)})
	mk("TextLabel", f, {BackgroundTransparency=1, Text=title, Font=Enum.Font.GothamSemibold, TextSize=16, TextColor3=TEXT, Size=UDim2.new(1,-140,0,20), TextXAlignment=Enum.TextXAlignment.Left})
	mk("TextLabel", f, {BackgroundTransparency=1, Text=subtitle or "", Font=Enum.Font.Gotham, TextSize=13, TextColor3=SUB, Size=UDim2.new(1,-140,0,18), Position=UDim2.fromOffset(0,24), TextXAlignment=Enum.TextXAlignment.Left})
	return f
end

-- Create tabs & pages
local P_Main   = addPage("Main")
local P_Farm   = addPage("Farm")
local P_Shop   = addPage("Shop")
local P_Pet    = addPage("Pet")
local P_Utility= addPage("Utility")
local P_Misc   = addPage("Misc")
local P_Visual = addPage("Visual")

addTab("Main"); addTab("Farm"); addTab("Shop"); addTab("Pet"); addTab("Utility"); addTab("Misc"); addTab("Visual")

-- Example content
local info = card(P_Main, "Information", "Status hub & versi")
mk("TextLabel", info, {BackgroundTransparency=1, Text = "Kucing Hub v0.4 • Executor: "..(identifyexecutor and identifyexecutor() or "Unknown"), Font=Enum.Font.Gotham, TextSize=13, TextColor3=SUB, Size=UDim2.new(1,-12,0,18), Position=UDim2.fromOffset(0,42), TextXAlignment=Enum.TextXAlignment.Left})

-- FARM demo
local demo = card(P_Farm, "Auto Farm", "Toggle demo — nanti diganti logic game")
local toggle = mk("TextButton", demo, {Size=UDim2.fromOffset(52,28), Position=UDim2.new(1,-64,0,18), AnchorPoint=Vector2.new(1,0), BackgroundColor3=Color3.fromRGB(60,60,70), Text="", AutoButtonColor=false})
corner(toggle,14); stroke(toggle,1)
local dot = mk("Frame", toggle, {Size=UDim2.fromOffset(24,24), Position=UDim2.fromOffset(2,2), BackgroundColor3=Color3.fromRGB(255,255,255)})
corner(dot,12)
local on=false; local running=false; local delayVal=2
local function render() if on then toggle.BackgroundColor3=ACC; dot.Position=UDim2.fromOffset(26,2) else toggle.BackgroundColor3=Color3.fromRGB(60,60,70); dot.Position=UDim2.fromOffset(2,2) end end
render()

toggle.MouseButton1Click:Connect(function()
	on = not on; render()
	if on and not running then
		running = true
		task.spawn(function()
			while on do
				print("[Kucing Hub] farm tick")
				task.wait(delayVal + math.random()*0.5)
			end
			running=false
		end)
	end
end)

-- Drag behavior
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging=true; dragStart=input.Position; startPos=win.Position
		input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then dragging=false end
		end)
	end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Minimize / Maximize / Close logic
local minimized = false
local normalSize = win.Size
local normalPos  = win.Position

btnMin.MouseButton1Click:Connect(function()
	-- minimize: hide window, show floating profile button
	minimized = true
	win.Visible = false
	floatBtn.Visible = true
end)

btnMax.MouseButton1Click:Connect(function()
	-- toggle maximize
	if win.Size.X.Offset < 800 then
		TweenService:Create(win, TweenInfo.new(0.2), {Size = UDim2.fromOffset(900, 520)}):Play()
		TweenService:Create(win, TweenInfo.new(0.2), {Position = UDim2.fromScale(.5,.5)}):Play()
	else
		TweenService:Create(win, TweenInfo.new(0.2), {Size = normalSize}):Play()
		TweenService:Create(win, TweenInfo.new(0.2), {Position = normalPos}):Play()
	end
end)

btnClose.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

floatBtn.MouseButton1Click:Connect(function()
	-- restore
	minimized = false
	floatBtn.Visible = false
	win.Visible = true
end)

print("[Kucing Hub] UI loaded v0.4")
