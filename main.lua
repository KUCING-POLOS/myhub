-- MyHub visual test (harus muncul kotak di layar)
local CoreGui = game:GetService("CoreGui")

-- hapus kalau pernah ada
local old = CoreGui:FindFirstChild("MyHubTest")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "MyHubTest"
sg.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 80)
frame.Position = UDim2.fromScale(0.5, 0.15)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.Parent = sg

local txt = Instance.new("TextLabel")
txt.Size = UDim2.fromScale(1, 1)
txt.BackgroundTransparency = 1
txt.Font = Enum.Font.GothamBold
txt.TextSize = 20
txt.TextColor3 = Color3.fromRGB(255,255,255)
txt.Text = "MyHub loaded ✅"
txt.Parent = frame

task.delay(6, function()
    if sg then sg:Destroy() end
end)
