-- SETTINGS & VARIABLES
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")
local VirtualUser = game:GetService("VirtualUser")

local searchDungeonActive = false
local autoFarmActive = false
local speed = 200

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DungeonHub_Arise_Final"

-- Tombol Buka (Muncul saat di-minimize)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -25)
OpenBtn.Text = "☰"
OpenBtn.TextSize = 25
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Visible = false

-- Frame Utama (UI Lebar)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Header
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Text = "  ARISE DUNGEON HUB"
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.TextColor3 = Color3.new(1, 1, 1)
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Font = Enum.Font.SourceSansBold

-- Tombol Minimize
local MiniBtn = Instance.new("TextButton", MainFrame)
MiniBtn.Size = UDim2.new(0, 35, 0, 35)
MiniBtn.Position = UDim2.new(1, -75, 0, 2)
MiniBtn.Text = "_"
MiniBtn.BackgroundTransparency = 1
MiniBtn.TextColor3 = Color3.new(1, 1, 1)
MiniBtn.TextSize = 20

-- Tombol Close
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.Text = "X"
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 20

-- Scrolling Frame
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, 0, 1, -40)
Scroll.Position = UDim2.new(0, 0, 0, 40)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 220)
Scroll.ScrollBarThickness = 6
Scroll.BackgroundTransparency = 1

-- Tombol Fitur 1: Search Dungeon
local SearchBtn = Instance.new("TextButton", Scroll)
SearchBtn.Size = UDim2.new(0, 260, 0, 50)
SearchBtn.Position = UDim2.new(0, 20, 0, 15)
SearchBtn.Text = "SEARCH DUNGEON: OFF"
SearchBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SearchBtn.TextColor3 = Color3.new(1, 1, 1)
SearchBtn.Font = Enum.Font.SourceSansBold

-- Tombol Fitur 2: Auto Farm NPC
local FarmBtn = Instance.new("TextButton", Scroll)
FarmBtn.Size = UDim2.new(0, 260, 0, 50)
FarmBtn.Position = UDim2.new(0, 20, 0, 75)
FarmBtn.Text = "AUTO FARM NPC: OFF"
FarmBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
FarmBtn.Font = Enum.Font.SourceSansBold

-- FUNGSI-FUNGSI UTAMA
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
    local target, dist = nil, math.huge
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= player.Character and v.Health > 0 then
            local npcRoot = v.Parent:FindFirstChild("HumanoidRootPart")
            if npcRoot then
                local d = (root.Position - npcRoot.Position).Magnitude
                if d < dist then dist = d target = npcRoot end
            end
        end
    end
    return target
end

local function autoAttack()
    VirtualUser:CaptureController()
    VirtualUser:Button1Down(Vector2.new(0,0))
    -- Auto Skill Z & X (Simulasi tekan keyboard)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "Z", false, game)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "X", false, game)
end

local function findPortal()
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if string.find(string.lower(v.Name), "dungeon") and v:IsA("BasePart") then return v end
    end
    return nil
end

-- LOOP LOGIKA UTAMA
task.spawn(function()
    while true do
        if autoFarmActive then
            local target = getClosestNPC()
            if target then
                -- Menuju ke NPC
                local d = (root.Position - target.Position).Magnitude
                TweenService:Create(root, TweenInfo.new(d/speed, Enum.EasingStyle.Linear), {CFrame = target.CFrame * CFrame.new(0, 0, 3)}):Play()
                autoAttack()
            else
                -- Jika NPC habis, menuju Portal
                local portal = findPortal()
                if portal then
                    local d = (root.Position - portal.Position).Magnitude
                    local t = TweenService:Create(root, TweenInfo.new(d/speed, Enum.EasingStyle.Linear), {CFrame = portal.CFrame})
                    t:Play() t.Completed:Wait()
                    task.wait(0.5)
                    if clickByText("Create") then
                        local s = tick() repeat task.wait(0.5) until clickByText("Join") or tick()-s > 5 or not autoFarmActive
                    end
                end
            end
        elseif searchDungeonActive then
            local portal = findPortal()
            if portal then
                local d = (root.Position - portal.Position).Magnitude
                local t = TweenService:Create(root, TweenInfo.new(d/speed, Enum.EasingStyle.Linear), {CFrame = portal.CFrame})
                t:Play() t.Completed:Wait()
                task.wait(0.5)
                if clickByText("Create") then
                    local s = tick() repeat task.wait(0.5) until clickByText("Join") or tick()-s > 5 or not searchDungeonActive
                end
            end
        end
        task.wait(0.2)
    end
end)

-- LOGIKA UI (MINIMIZE/CLOSE/TOGGLE)
MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

SearchBtn.MouseButton1Click:Connect(function()
    searchDungeonActive = not searchDungeonActive
    autoFarmActive = false
    SearchBtn.Text = searchDungeonActive and "SEARCH: ON" or "SEARCH: OFF"
    SearchBtn.BackgroundColor3 = searchDungeonActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    FarmBtn.Text = "AUTO FARM: OFF"
    FarmBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

FarmBtn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    searchDungeonActive = false
    FarmBtn.Text = autoFarmActive and "FARM: ON" or "FARM: OFF"
    FarmBtn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    SearchBtn.Text = "SEARCH: OFF"
    SearchBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)
