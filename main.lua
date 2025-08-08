-- MyHub v0.2 - UI simpel + Toggle
local CoreGui = game:GetService("CoreGui")

-- bersihin kalau sudah ada
local old = CoreGui:FindFirstChild("MyHubUI")
if old then old:Destroy() end

-- tema terang + aksen biru
local BG = Color3.fromRGB(245,247,250)
local PANEL = Color3.fromRGB(255,255,255)
local TEXT = Color3.fromRGB(30,41,59)
local SUB  = Color3.fromRGB(71,85,105)
local ACC  = Color3.fromRGB(92,156,255)

local sg = Instance.new("ScreenGui")
sg.Name = "MyHubUI"
sg.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(360, 180)
frame.Position = UDim2.fromScale(0.5, 0.18)
frame.AnchorPoint = Vector2.new(0.5,0)
frame.BackgroundColor3 = PANEL
frame.Parent = sg
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(226,232,240)
stroke.Thickness = 1

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -20, 0, 34)
title.Position = UDim2.fromOffset(10, 10)
title.Font = Enum.Font.GothamBold
title.Text = "MyHub"
title.TextSize = 20
title.TextColor3 = TEXT
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- kartu toggle
local card = Instance.new("Frame")
card.Size = UDim2.new(1, -20, 0, 60)
card.Position = UDim2.fromOffset(10, 54)
card.BackgroundColor3 = PANEL
card.Parent = frame
Instance.new("UICorner", card).CornerRadius = UDim.new(0,12)
local cstroke = Instance.new("UIStroke", card)
cstroke.Color = Color3.fromRGB(226,232,240)
cstroke.Thickness = 1

local label = Instance.new("TextLabel")
label.BackgroundTransparency = 1
label.Text = "Auto Mode"
label.Font = Enum.Font.GothamSemibold
label.TextSize = 16
label.TextColor3 = TEXT
label.Position = UDim2.fromOffset(12, 10)
label.Size = UDim2.fromOffset(220, 20)
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = card

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Text = "Nyalain untuk mulai loop (demo)"
hint.Font = Enum.Font.Gotham
hint.TextSize = 13
hint.TextColor3 = SUB
hint.Position = UDim2.fromOffset(12, 32)
hint.Size = UDim2.fromOffset(240, 18)
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = card

-- toggle switch
local toggle = Instance.new("TextButton")
toggle.AutoButtonColor = false
toggle.Text = ""
toggle.Size = UDim2.fromOffset(52, 28)
toggle.Position = UDim2.new(1, -64, 0, 16)
toggle.AnchorPoint = Vector2.new(1,0)
toggle.BackgroundColor3 = Color3.fromRGB(226,232,240)
toggle.Parent = card
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,14)
Instance.new("UIStroke", toggle).Color = Color3.fromRGB(226,232,240)

local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(24,24)
dot.Position = UDim2.fromOffset(2,2)
dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
dot.Parent = toggle
Instance.new("UICorner", dot).CornerRadius = UDim.new(0,12)

local on = false
local running = false

local function render()
    if on then
        toggle.BackgroundColor3 = ACC
        dot.Position = UDim2.fromOffset(26,2)
    else
        toggle.BackgroundColor3 = Color3.fromRGB(226,232,240)
        dot.Position = UDim2.fromOffset(2,2)
    end
end
render()

-- demo loop aman (cuma print), nanti kita ganti ke aksi game
local function demoLoop()
    if running then return end
    running = true
    while on do
        print("[MyHub] demo tick")
        task.wait(2) -- nanti jadi delay farming
    end
    running = false
end

toggle.MouseButton1Click:Connect(function()
    on = not on
    render()
    if on then demoLoop() end
end)

-- pesan sukses
print("[MyHub] UI loaded")
