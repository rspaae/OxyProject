-- SETTINGS & VARIABLES
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

local searchDungeonActive = false
local autoFarmActive = false
local speed = 200

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DungeonWideHub"

-- Hamburger Button (Muncul saat di-minimize)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -25)
OpenBtn.Text = "☰"
OpenBtn.TextSize = 25
OpenBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Visible = false -- Sembunyi saat menu utama terbuka

-- Main Frame (DIPERLEBAR)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 180) -- Ukuran lebar 280 agar lega
MainFrame.Position = UDim2.new(0.5, -140, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Header Title
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Text = "  DUNGEON AUTO FARM"
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Header.TextColor3 = Color3.new(1, 1, 1)
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Font = Enum.Font.SourceSansBold
Header.TextSize = 18

-- Minimize Button (_)
local MiniBtn = Instance.new("TextButton", MainFrame)
MiniBtn.Size = UDim2.new(0, 35, 0, 35)
MiniBtn.Position = UDim2.new(1, -75, 0, 2)
MiniBtn.Text = "_"
MiniBtn.TextSize = 20
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextColor3 = Color3.new(1, 1, 1)

-- Close Button (X)
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.Text = "X"
CloseBtn.TextSize = 20
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)

-- Tombol Fitur 1: Search Dungeon
local SearchBtn = Instance.new("TextButton", MainFrame)
SearchBtn.Size = UDim2.new(0, 250, 0, 45)
SearchBtn.Position = UDim2.new(0, 15, 0, 55)
SearchBtn.Text = "SEARCH DUNGEON: OFF"
SearchBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SearchBtn.TextColor3 = Color3.new(1, 1, 1)
SearchBtn.Font = Enum.Font.SourceSansBold
SearchBtn.TextSize = 16

-- Tombol Fitur 2: Auto Farm NPC
local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 250, 0, 45)
FarmBtn.Position = UDim2.new(0, 15, 0, 115)
FarmBtn.Text = "AUTO FARM NPC: OFF"
FarmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
FarmBtn.Font = Enum.Font.SourceSansBold
FarmBtn.TextSize = 16

-- FUNCTIONS (Click & Detection)
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

local function getClosestNPC()
    local closest, dist = nil, math.huge
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= player.Character then
            if v.Humanoid.Health > 0 then
                local d = (root.Position - v.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d closest = v.HumanoidRootPart end
            end
        end
    end
    return closest
end

local function getPortal()
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if string.find(string.lower(v.Name), "dungeon") and v:IsA("BasePart") then return v end
    end
    return nil
end

-- LOGIC LOOP
task.spawn(function()
    while true do
        if searchDungeonActive then
            local p = getPortal()
            if p then
                local t = TweenService:Create(root, TweenInfo.new((root.Position - p.Position).Magnitude/speed, Enum.EasingStyle.Linear), {CFrame = p.CFrame})
                t:Play() t.Completed:Wait()
                task.wait(0.5)
                if clickByText("Create") then
                    local s = tick() repeat task.wait(0.5) until clickByText("Join") or tick()-s > 5 or not searchDungeonActive
                end
            end
        elseif autoFarmActive then
            local npc = getClosestNPC()
            if npc then
                local t = TweenService:Create(root, TweenInfo.new((root.Position - npc.Position).Magnitude/speed, Enum.EasingStyle.Linear), {CFrame = npc.CFrame * CFrame.new(0,0,3)})
                t:Play() t.Completed:Wait()
            else
                local p = getPortal()
                if p then
                    local t = TweenService:Create(root, TweenInfo.new((root.Position - p.Position).Magnitude/speed, Enum.EasingStyle.Linear), {CFrame = p.CFrame})
                    t:Play() t.Completed:Wait()
                    task.wait(0.5)
                    if clickByText("Create") then
                        local s = tick() repeat task.wait(0.5) until clickByText("Join") or tick()-s > 5 or not autoFarmActive
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- UI EVENTS (Minimize/Close/Toggles)
MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

SearchBtn.MouseButton1Click:Connect(function()
    searchDungeonActive = not searchDungeonActive
    autoFarmActive = false
    SearchBtn.Text = searchDungeonActive and "SEARCH: ON" or "SEARCH: OFF"
    SearchBtn.BackgroundColor3 = searchDungeonActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    FarmBtn.Text = "AUTO FARM: OFF"
    FarmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

FarmBtn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    searchDungeonActive = false
    FarmBtn.Text = autoFarmActive and "FARM: ON" or "FARM: OFF"
    FarmBtn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    SearchBtn.Text = "SEARCH: OFF"
    SearchBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)
