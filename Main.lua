-- SETTINGS & VARIABLES
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

local searchDungeonActive = false
local autoFarmActive = false
local speed = 200

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DungeonMultiHub"

-- Hamburger Button
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 40, 0, 40)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -20)
OpenBtn.Text = "☰"
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Visible = false

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Active = true
MainFrame.Draggable = true

-- Header Buttons
local MiniBtn = Instance.new("TextButton", MainFrame)
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -60, 0, 0)
MiniBtn.Text = "_"
MiniBtn.TextColor3 = Color3.new(1, 1, 1)
MiniBtn.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)

-- Fitur 1: Search Dungeon Button
local SearchBtn = Instance.new("TextButton", MainFrame)
SearchBtn.Size = UDim2.new(0, 200, 0, 45)
SearchBtn.Position = UDim2.new(0, 10, 0, 45)
SearchBtn.Text = "Search Dungeon: OFF"
SearchBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SearchBtn.TextColor3 = Color3.new(1, 1, 1)
SearchBtn.Font = Enum.Font.SourceSansBold

-- Fitur 2: Auto Farm Button
local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 200, 0, 45)
FarmBtn.Position = UDim2.new(0, 10, 0, 100)
FarmBtn.Text = "Auto Farm NPC: OFF"
FarmBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
FarmBtn.Font = Enum.Font.SourceSansBold

-- FUNCTIONS
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

-- LOGIC LOOPS
task.spawn(function()
    while true do
        if searchDungeonActive and not autoFarmActive then
            local p = getPortal()
            if p then
                local d = (root.Position - p.Position).Magnitude
                local t = TweenService:Create(root, TweenInfo.new(d/speed, Enum.EasingStyle.Linear), {CFrame = p.CFrame})
                t:Play() t.Completed:Wait()
                task.wait(0.5)
                if clickByText("Create") then
                    local s = tick() repeat task.wait(0.5) until clickByText("Join") or tick()-s > 5 or not searchDungeonActive
                end
            end
        elseif autoFarmActive then
            local npc = getClosestNPC()
            if npc then
                local d = (root.Position - npc.Position).Magnitude
                local t = TweenService:Create(root, TweenInfo.new(d/speed, Enum.EasingStyle.Linear), {CFrame = npc.CFrame * CFrame.new(0,0,3)})
                t:Play() t.Completed:Wait()
            else
                local p = getPortal()
                if p then
                    local d = (root.Position - p.Position).Magnitude
                    local t = TweenService:Create(root, TweenInfo.new(d/speed, Enum.EasingStyle.Linear), {CFrame = p.CFrame})
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

-- UI EVENTS
SearchBtn.MouseButton1Click:Connect(function()
    searchDungeonActive = not searchDungeonActive
    autoFarmActive = false -- Matikan farm kalau search nyala
    SearchBtn.Text = searchDungeonActive and "Search Dungeon: ON" or "Search Dungeon: OFF"
    SearchBtn.BackgroundColor3 = searchDungeonActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    FarmBtn.Text = "Auto Farm NPC: OFF"
    FarmBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end)

FarmBtn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    searchDungeonActive = false -- Matikan search kalau farm nyala
    FarmBtn.Text = autoFarmActive and "Auto Farm NPC: ON" or "Auto Farm NPC: OFF"
    FarmBtn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    SearchBtn.Text = "Search Dungeon: OFF"
    SearchBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end)

MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
