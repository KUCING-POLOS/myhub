-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- Helpers
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

-- Clean old
local old = CoreGui:FindFirstChild("KucingHubUI")
if old then old:Destroy() end

-- Root GUI
local gui = mk("ScreenGui", CoreGui, {Name = "KucingHubUI", ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false})

-- Responsive size with smaller default
local function getWindowSize()
	local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
	local w = math.clamp(math.floor(vw * 0.45), 420, 560)
	local h = math.clamp(math.floor(vh * 0.45), 260, 340)
	return UDim2.fromOffset(w, h)
end

-- Floating profile button
local floatBtn = mk("ImageButton", gui, {Name = "KucingFloat", Size = UDim2.fromOffset(36,36), Position = UDim2.fromOffset(16, Camera.ViewportSize.Y - 52), BackgroundColor3 = PANEL, AutoButtonColor = true, Visible = false})
corner(floatBtn, 18); stroke(floatBtn,1)
local ok, img = pcall(function()
	return Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
end)
if ok then floatBtn.Image = img end

-- Main Window
local win = mk("Frame", gui, {Name = "Window", BackgroundColor3 = PANEL, Size = getWindowSize(), Position = UDim2.fromScale(.5,.5), AnchorPoint = Vector2.new(.5,.5)})
corner(win,14); stroke(win,1)

-- Header
local header = mk("Frame", win, {Size = UDim2.new(1,0,0,36), BackgroundColor3 = PANEL})
corner(header,10); stroke(header,1)
mk("TextLabel", header, {BackgroundTransparency=1, Size=UDim2.new(1,-120,1,0), Position=UDim2.fromOffset(10,0), Font=Enum.Font.GothamBold, Text="Kucing Hub - Premium | v0.5", TextColor3 = TEXT, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})

-- Controls
local btnMin = mk("TextButton", header, {Size=UDim2.fromOffset(22,22), Position=UDim2.new(1,-70,0,7), AnchorPoint=Vector2.new(1,0), Text="–", TextColor3=TEXT, BackgroundColor3 = Color3.fromRGB(50,50,58), Font=Enum.Font.GothamBold, TextSize=16})
corner(btnMin,8); stroke(btnMin,1)
local btnMax = mk("TextButton", header, {Size=UDim2.fromOffset(22,22), Position=UDim2.new(1,-44,0,7), AnchorPoint=Vector2.new(1,0), Text="□", TextColor3=TEXT, BackgroundColor3 = Color3.fromRGB(50,50,58), Font=Enum.Font.GothamBold, TextSize=14})
corner(btnMax,8); stroke(btnMax,1)
local btnClose = mk("TextButton", header, {Size=UDim2.fromOffset(22,22), Position=UDim2.new(1,-18,0,7), AnchorPoint=Vector2.new(1,0), Text="×", TextColor3=Color3.fromRGB(255,120,120), BackgroundColor3 = Color3.fromRGB(50,50,58), Font=Enum.Font.GothamBold, TextSize=14})
corner(btnClose,8); stroke(btnClose,1)

-- Body
local body = mk("Frame", win, {Size=UDim2.new(1,0,1,-44), Position = UDim2.fromOffset(0,40), BackgroundTransparency = 1})
local sidebar = mk("Frame", body, {Size=UDim2.new(0,120,1,0), BackgroundColor3 = BG})
corner(sidebar,10); stroke(sidebar,1)
local content = mk("Frame", body, {Size=UDim2.new(1,-128,1,0), Position=UDim2.fromOffset(128,0), BackgroundTransparency=1})
mk("UIListLayout", sidebar, {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder})
mk("UIPadding", sidebar, {PaddingTop=UDim.new(0,6), PaddingLeft=UDim.new(0,6), PaddingRight=UDim.new(0,6)})

-- Pages
local pages, current = {}, nil
local function addPage(name)
	local page = mk("ScrollingFrame", content, {Name = name.."Page", Size = UDim2.fromScale(1,1), CanvasSize = UDim2.new(0,0,0,0), BackgroundTransparency=1, ScrollBarThickness=4})
	mk("UIListLayout", page, {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder})
	page.Visible=false
	pages[name]=page
	return page
end
local function switch(name)
	for n,p in pairs(pages) do p.Visible = (n==name) end
	current = name
end
local function addTab(name)
	local btn = mk("TextButton", sidebar, {Size=UDim2.new(1,0,0,28), BackgroundColor3 = BG, AutoButtonColor=false, Text="  "..name, Font=Enum.Font.GothamSemibold, TextColor3=SUB, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left})
	corner(btn,8); stroke(btn,1)
	btn.MouseButton1Click:Connect(function()
		for _,b in ipairs(sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3=SUB end end
		btn.TextColor3 = ACC; switch(name)
	end)
	if not current then btn.TextColor3=ACC; switch(name) end
end

-- Cards
local function card(parent, title, subtitle)
	local f = mk("Frame", parent, {Size=UDim2.new(1,-6,0,52), BackgroundColor3=PANEL})
	corner(f,10); stroke(f,1)
	mk("TextLabel", f, {BackgroundTransparency=1, Text=title, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=TEXT, Size=UDim2.new(1,-10,0,18), TextXAlignment=Enum.TextXAlignment.Left, Position=UDim2.fromOffset(6,6)})
	mk("TextLabel", f, {BackgroundTransparency=1, Text=subtitle or "", Font=Enum.Font.Gotham, TextSize=12, TextColor3=SUB, Size=UDim2.new(1,-10,0,16), Position=UDim2.fromOffset(6,26), TextXAlignment=Enum.TextXAlignment.Left})
	return f
end

-- Tabs
local P_Main = addPage("Main")
addTab("Main")
card(P_Main, "Information", "Kucing Hub v0.5 • Executor: "..(identifyexecutor and identifyexecutor() or "Unknown"))

-- Dragging
local dragging, dragStart, startPos
local function beginDrag(input)
	dragging=true; dragStart=input.Position; startPos=win.Position
	input.Changed:Connect(function()
		if input.UserInputState==Enum.UserInputState.End then dragging=false end
	end)
end
header.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then beginDrag(input) end end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Minimize/Maximize/Close
local normalSize, normalPos = win.Size, win.Position
btnMin.MouseButton1Click:Connect(function()
	win.Visible = false; floatBtn.Visible = true
end)
btnMax.MouseButton1Click:Connect(function()
	if win.Size.X.Offset < 700 then
		TweenService:Create(win, TweenInfo.new(0.2), {Size = UDim2.fromOffset(700, 480)}):Play()
		TweenService:Create(win, TweenInfo.new(0.2), {Position = UDim2.fromScale(.5,.5)}):Play()
	else
		TweenService:Create(win, TweenInfo.new(0.2), {Size = normalSize}):Play()
		TweenService:Create(win, TweenInfo.new(0.2), {Position = normalPos}):Play()
	end
end)
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Floating button restore
floatBtn.MouseButton1Click:Connect(function()
	win.Visible = true; floatBtn.Visible = false
end)

-- Responsive resize
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	if win.Visible then
		win.Size = getWindowSize()
		win.Position = UDim2.fromScale(.5,.5)
	else
		floatBtn.Position = UDim2.fromOffset(16, Camera.ViewportSize.Y - 52)
	end
end)

print("[Kucing Hub] UI loaded v0.5")
