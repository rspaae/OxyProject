--[[ 
    ARISE SCRIPT - REPLAY & SEARCH FIX
    - Berdasarkan hasil scan: Blacklist LastNpcs & RuneShop
    - Fitur Search: Mencari portal replay di LastNpcs setelah bos mati
    - UI Fix: Dipastikan muncul untuk semua executor mobile
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

-- Konfigurasi Global
getgenv().AutoLoop = false
getgenv().Speed = 250 
local currentTween = nil
local isMinimized = false

-- 1. FUNGSI GERAK (TWEEN)
local function TweenTo(targetCFrame)
    if not Root then return end
    local dist = (Root.Position - targetCFrame.Position).Magnitude
    if dist < 4 then
        if currentTween then currentTween:Cancel(); currentTween = nil end
        return true
    end
    local info = TweenInfo.new(dist / math.max(getgenv().Speed, 1), Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(Root, info, {CFrame = targetCFrame})
    currentTween:Play()
    return false
end

-- 2. FUNGSI PENCARIAN PORTAL (CARI PORTAL REPLAY)
local function SearchDungeonPortal()
    -- Prioritas 1: Cari di LastNpcs (Portal yang muncul di depan NPC setelah selesai)
    local lastNpcs = workspace:FindFirstChild("LastNpcs")
    if lastNpcs then
        local p = lastNpcs:FindFirstChild("Dungeon")
        if p and p:IsA("BasePart") then return p end
    end

    -- Prioritas 2: Cari di seluruh workspace yang bukan NPC pengganggu
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Dungeon" then
            local pName = v.Parent.Name:lower()
            -- Abaikan jika di dalam folder NPC yang terdeteksi di scan kamu
            if not pName:find("craft") and not pName:find("runeshop") and not pName:find("shop") then
                return v
            end
        end
    end
    return nil
end

-- 3. FUNGSI TARGET MUSUH
local function GetTargetEnemy()
    local Enemies = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
    if Enemies then
        for _, mob in pairs(Enemies:GetChildren()) do
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
            if hrp and hp and hp.ContentText ~= "0 HP" then
                return mob
            end
        end
    end
    return nil
end

-- 4. PEMBUATAN UI (Disesuaikan agar pasti muncul)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AriseReplayUI"
ScreenGui.ResetOnSpawn = false
local success, err = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not success then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -110)
MainFrame.Active = true; MainFrame.Draggable = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35); TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = " ARISE: AUTO REPLAY"; Title.Size = UDim2.new(1, -70, 1, 0); Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1; Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 14; Title.TextXAlignment = 0

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -35); Content.Position = UDim2.new(0, 0, 0, 35); Content.BackgroundTransparency = 1

local BtnLoop = Instance.new("TextButton", Content)
BtnLoop.Text = "AUTO LOOP: OFF"; BtnLoop.Size = UDim2.new(0, 230, 0, 45); BtnLoop.Position = UDim2.new(0, 10, 0, 10)
BtnLoop.BackgroundColor3 = Color3.fromRGB(50, 50, 50); BtnLoop.TextColor3 = Color3.new(1,1,1); BtnLoop.Font = Enum.Font.SourceSansBold

local SliderText = Instance.new("TextLabel", Content)
SliderText.Text = "SPEED: " .. getgenv().Speed; SliderText.Size = UDim2.new(1, 0, 0, 25); SliderText.Position = UDim2.new(0, 0, 0, 65); SliderText.TextColor3 = Color3.new(1,1,1); SliderText.BackgroundTransparency = 1

local SliderBar = Instance.new("Frame", Content)
SliderBar.Size = UDim2.new(0, 210, 0, 8); SliderBar.Position = UDim2.new(0, 20, 0, 95); SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
local SliderKnob = Instance.new("Frame", SliderBar)
SliderKnob.Size = UDim2.new(0, 18, 0, 24); SliderKnob.Position = UDim2.new(getgenv().Speed/700, -9, 0.5, -12); SliderKnob.BackgroundColor3 = Color3.fromRGB(0, 150, 255)

-- Logika UI
BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

local dragging = false
SliderBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local p = math.clamp((UserInputService:GetMouseLocation().X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        getgenv().Speed = math.max(1, math.floor(p * 700))
        SliderKnob.Position = UDim2.new(p, -9, 0.5, -12)
        SliderText.Text = "SPEED: " .. getgenv().Speed
    end
end)

-- 5. MAIN LOOP
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().AutoLoop then continue end
        
        if not Character or not Character.Parent or not Root then
            Character = Player.Character or Player.CharacterAdded:Wait(); Root = Character:WaitForChild("HumanoidRootPart")
            continue
        end

        local enemy = GetTargetEnemy()
        if enemy then
            -- Bunuh musuh terlebih dahulu
            local arrived = TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
            if arrived then
                Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemy.Name}, [2] = "\4"}})
            end
        else
            -- Cari portal Replay setelah musuh habis
            local portal = SearchDungeonPortal()
            if portal then
                local arrived = TweenTo(portal.CFrame)
                if arrived then
                    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                    task.wait(0.5)
                    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\4"})
                    task.wait(0.5)
                    for i = 1, 3 do
                        Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\4"})
                    end
                    task.wait(4)
                end
            end
        end
    end
end)
