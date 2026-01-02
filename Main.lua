-- SETTINGS & VARIABLES
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")
local running = false

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DungeonHub"

-- Hamburger / Open Button (Muncul kalau menu ditutup)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 40, 0, 40)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -20)
OpenBtn.Text = "☰"
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Visible = false -- Sembunyi di awal

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 130)
MainFrame.Position = UDim2.new(0.5, -100, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true -- Bisa digeser di layar

-- Header Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Text = "  Dungeon Hub"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold

-- Minimize Button (_)
local MiniBtn = Instance.new("TextButton", MainFrame)
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -60, 0, 0)
MiniBtn.Text = "_"
MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MiniBtn.TextColor3 = Color3.new(1, 1, 1)

-- Close Button (X)
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)

-- Toggle Button (On/Off)
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0, 180, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0, 50)
ToggleBtn.Text = "Search Dungeon: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.SourceSansBold

-- FUNGSI UI
MiniBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    running = false
    ScreenGui:Destroy()
end)

-- LOGIKA CLICK & TWEEN (SPEED 200)
local function clickByText(txt)
    local pGui = player:WaitForChild("PlayerGui")
    for _, v in pairs(pGui:GetDescendants()) do
        if (v:IsA("TextButton") or v:IsA("TextLabel")) and string.find(string.lower(v.Text or ""), string.lower(txt)) then
            local btn = v:IsA("TextButton") and v or v.Parent
            if btn:IsA("TextButton") then
                local conns = getconnections(btn.MouseButton1Click)
                for _, conn in pairs(conns) do conn:Fire() end
                return true
            end
        end
    end
    return false
end

local function loopDungeon()
    while running do
        local target = nil
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if string.find(string.lower(obj.Name), "dungeon") and obj:IsA("BasePart") then
                target = obj
                break
            end
        end

        if target and running then
            local dist = (root.Position - target.Position).Magnitude
            local tween = TweenService:Create(root, TweenInfo.new(dist / 200, Enum.EasingStyle.Linear), {CFrame = target.CFrame})
            tween:Play()
            tween.Completed:Wait()
            
            task.wait(0.5)
            if running and clickByText("Create") then
                local start = tick()
                repeat task.wait(0.5) until clickByText("Join") or tick() - start > 5 or not running
            end
        end
        task.wait(2)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    running = not running
    if running then
        ToggleBtn.Text = "Search Dungeon: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        task.spawn(loopDungeon)
    else
        ToggleBtn.Text = "Search Dungeon: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end
end)
