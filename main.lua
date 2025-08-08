-- v0.3 - Kucing Hub Sidebar UI
-- Dibuat untuk executor (Delta/Ronix)

-- Fungsi helper
local function mk(typ, parent, props)
    local obj = Instance.new(typ)
    for k,v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

-- Warna
local BG = Color3.fromRGB(20, 20, 20)
local TEXT = Color3.fromRGB(255, 255, 255)

-- UI ScreenGui
local gui = mk("ScreenGui", game:GetService("CoreGui"), {Name = "KucingHubUI"})

-- Frame utama
local mainFrame = mk("Frame", gui, {
    BackgroundColor3 = BG,
    Size = UDim2.new(0, 600, 0, 350),
    Position = UDim2.new(0.5, -300, 0.5, -175),
    BorderSizePixel = 0
})

-- Header
local header = mk("Frame", mainFrame, {
    BackgroundColor3 = BG,
    Size = UDim2.new(1, 0, 0, 30),
    BorderSizePixel = 0
})

mk("TextLabel", header, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -12, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    Font = Enum.Font.GothamBold,
    Text = "Kucing Hub - Premium | v0.3",
    TextColor3 = TEXT,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Sidebar menu
local tabs = {"Main", "Farm", "Shop", "Pet", "Utility", "Misc", "Visual"}
for i, name in ipairs(tabs) do
    mk("TextButton", mainFrame, {
        BackgroundColor3 = BG,
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(0, 0, 0, 30 * i),
        Text = name,
        TextColor3 = TEXT,
        Font = Enum.Font.Gotham,
        TextSize = 14
    })
end

print("[Kucing Hub] Sidebar UI loaded")
