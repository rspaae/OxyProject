--[[ 
    ARISE SCRIPT - REFINED STABLE VERSION
    - Fix: Error "attempt to call a nil value" dengan pengecekan objek yang ketat
    - Prioritas: Menyerang NPC sampai "Enemies Left" habis
    - Search Lobby: Khusus folder __Dungeon
    - Auto Replay: Mencari portal di LastNpcs HANYA jika musuh sudah 0
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- Pastikan Remote Event tersedia sebelum dipanggil
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2", 10):WaitForChild("dataRemoteEvent", 10)

getgenv().AutoLoop = false
getgenv().Speed = 250 
local currentTween = nil

-- 1. FUNGSI TWEEN AMAN
local function SafeTween(targetCFrame)
    if not Root or not targetCFrame then return false end
    local dist = (Root.Position - targetCFrame.Position).Magnitude
    if dist < 4 then
        if currentTween then currentTween:Cancel() end
        return true
    end
    local info = TweenInfo.new(dist / getgenv().Speed, Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(Root, info, {CFrame = targetCFrame})
    currentTween:Play()
    return false
end

-- 2. SCAN MUSUH (PRIORITAS UTAMA)
local function GetActiveEnemy()
    local main = workspace:FindFirstChild("__Main")
    local enemies = main and main:FindFirstChild("__Enemies")
    local client = enemies and enemies:FindFirstChild("Client")
    
    if client then
        for _, mob in pairs(client:GetChildren()) do
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            local hb = mob:FindFirstChild("HealthBar")
            if hrp and hb and hb.Main.Bar.Amount.ContentText ~= "0 HP" then
                return mob
            end
        end
    end
    return nil
end

-- 3. UI MINIMIZE & CLOSE (FIXED)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AriseProRefined"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 40, 0, 40); CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().AutoLoop = false end)

local MiniBtn = Instance.new("TextButton", TopBar)
MiniBtn.Text = "-"; MiniBtn.Size = UDim2.new(0, 40, 0, 40); MiniBtn.Position = UDim2.new(1, -80, 0, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); MiniBtn.TextColor3 = Color3.new(1,1,1)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -40); Content.Position = UDim2.new(0, 0, 0, 40); Content.BackgroundTransparency = 1

MiniBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    MainFrame.Size = Content.Visible and UDim2.new(0, 250, 0, 180) or UDim2.new(0, 250, 0, 40)
    MiniBtn.Text = Content.Visible and "-" or "+"
end)

local BtnSearch = Instance.new("TextButton", Content)
BtnSearch.Text = "🔍 SEARCH DUNGEON LOBBY"; BtnSearch.Size = UDim2.new(0, 230, 0, 50); BtnSearch.Position = UDim2.new(0, 10, 0, 10)
BtnSearch.BackgroundColor3 = Color3.fromRGB(0, 80, 180); BtnSearch.TextColor3 = Color3.new(1,1,1)

BtnSearch.MouseButton1Click:Connect(function()
    local lobby = workspace:FindFirstChild("__Dungeon")
    local portal = lobby and lobby:FindFirstChild("Dungeon")
    if portal and SafeTween(portal.CFrame) then
        if Remote then
            Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
            task.wait(0.5)
            Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\4"})
            task.wait(0.5)
            for i = 1, 3 do Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\4"}) end
        end
    end
end)

local BtnLoop = Instance.new("TextButton", Content)
BtnLoop.Text = "AUTO LOOP: OFF"; BtnLoop.Size = UDim2.new(0, 230, 0, 50); BtnLoop.Position = UDim2.new(0, 10, 0, 70)
BtnLoop.BackgroundColor3 = Color3.fromRGB(60, 60, 60); BtnLoop.TextColor3 = Color3.new(1,1,1)

BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(60, 60, 60)
end)

-- 4. LOGIKA UTAMA (FOKUS NPC)
task.spawn(function()
    while task.wait(0.4) do
        if not ScreenGui.Parent then break end
        if getgenv().AutoLoop then
            local enemy = GetActiveEnemy()
            
            if enemy then
                -- Fokus bunuh NPC
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                if hrp and SafeTween(hrp.CFrame * CFrame.new(0, 0, 3)) then
                    if Remote then
                        Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemy.Name}, [2] = "\4"}})
                    end
                end
            else
                -- Jika musuh 0, baru cari portal Replay di LastNpcs
                local replay = workspace:FindFirstChild("LastNpcs")
                local portal = replay and replay:FindFirstChild("Dungeon")
                if portal and SafeTween(portal.CFrame) then
                    if Remote then
                        Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                        task.wait(1.5)
                    end
                end
            end
        end
    end
end)
