--[[
    ARISE SCRIPT - SIMPLE VERSION
    UI: Classic Box
    Logic: Smart Tween + Remote Entry
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- 1. LAYANAN & VARIABEL
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

-- Config Global
getgenv().AutoDungeon = false
getgenv().AutoFarm = false
getgenv().Speed = 200

-- Status Variables
local currentTween = nil
local isAtTarget = false
local processingDungeon = false

-- 2. FUNGSI LOGIKA (OTAK SKRIP)

-- A. Gerak Pintar (Smart Tween)
-- Karakter terbang, tapi akan BERHENTI TOTAL jika jarak < 4 stud
local function TweenTo(targetCFrame)
    if not Root then return end
    local dist = (Root.Position - targetCFrame.Position).Magnitude

    if dist < 4 then
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
        isAtTarget = true -- Kita sudah sampai
        return
    end

    isAtTarget = false
    local info = TweenInfo.new(dist / getgenv().Speed, Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(Root, info, {CFrame = targetCFrame})
    currentTween:Play()
end

-- B. Masuk Dungeon Instan (Remote)
-- Tidak perlu klik tombol E, langsung tembak server
local function InstantEnter()
    print("Mencoba Masuk Dungeon...")
    -- 1. Pemicu (Trigger)
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\n"})
    task.wait(0.8)
    
    -- 2. Buat Room
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\n"})
    task.wait(0.8)
    
    -- 3. Mulai (Coba ID 1-3 biar pasti masuk)
    for i = 1, 3 do
        Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\n"})
        task.wait(0.2)
    end
end

-- 3. UI SIMPLE (BUATAN SENDIRI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AriseSimpleUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -90, 0.4, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 140)
MainFrame.Active = true
MainFrame.Draggable = true

-- Judul
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "  ARISE SIMPLE"
Title.Size = UDim2.new(1, -60, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

-- Tombol Close (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    getgenv().AutoDungeon = false
    getgenv().AutoFarm = false
end)

-- Tombol Minimize (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = MainFrame
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinBtn.TextColor3 = Color3.new(1, 1, 1)

local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.Size = UDim2.new(1, 0, 1, -30)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundTransparency = 1

MinBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    if Content.Visible then
        MainFrame.Size = UDim2.new(0, 180, 0, 140)
        MinBtn.Text = "-"
    else
        MainFrame.Size = UDim2.new(0, 180, 0, 30)
        MinBtn.Text = "+"
    end
end)

-- Fungsi Helper Tombol
local function CreateButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = Content
    btn.Text = text
    btn.Size = UDim2.new(0, 160, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Tombol 1: Dungeon
local BtnDungeon = CreateButton("DUNGEON: OFF", 10, function()
    getgenv().AutoDungeon = not getgenv().AutoDungeon
end)

-- Tombol 2: Farm
local BtnFarm = CreateButton("FARM: OFF", 65, function()
    getgenv().AutoFarm = not getgenv().AutoFarm
end)

-- 4. LOOP UTAMA (JALAN TERUS)
task.spawn(function()
    while task.wait(0.3) do
        -- Update UI Warna & Teks
        if ScreenGui.Parent then
            BtnDungeon.Text = getgenv().AutoDungeon and "DUNGEON: ON" or "DUNGEON: OFF"
            BtnDungeon.BackgroundColor3 = getgenv().AutoDungeon and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
            
            BtnFarm.Text = getgenv().AutoFarm and "FARM: ON" or "FARM: OFF"
            BtnFarm.BackgroundColor3 = getgenv().AutoFarm and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
        else
            break -- Stop loop jika UI dihapus
        end

        -- Update Character jika mati/respawn
        if not Character or not Character.Parent then
            Character = Player.Character or Player.CharacterAdded:Wait()
            Root = Character:WaitForChild("HumanoidRootPart")
        end

        -- === LOGIKA AUTO DUNGEON ===
        if getgenv().AutoDungeon and not processingDungeon then
            local targetPortal = nil
            -- Cari objek bernama "Portal" atau "Dungeon" di map
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("portal") or v.Name:lower():find("dungeon")) then
                    targetPortal = v
                    break
                end
            end

            if targetPortal then
                TweenTo(targetPortal.CFrame)
                
                -- Jika sudah diam di tempat (isAtTarget = true), eksekusi Remote
                if isAtTarget then
                    processingDungeon = true
                    InstantEnter()
                    task.wait(5) -- Delay panjang biar gak spam waktu loading
                    processingDungeon = false
                end
            end
        end

        -- === LOGIKA AUTO FARM ===
        if getgenv().AutoFarm then
            local EnemyFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
            
            if EnemyFolder then
                local target = nil
                local minDist = math.huge
                
                -- Cari musuh terdekat yang masih hidup
                for _, mob in pairs(EnemyFolder:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
                    
                    if hrp and hp and hp.ContentText ~= "0 HP" then
                        local d = (Root.Position - hrp.Position).Magnitude
                        if d < minDist then
                            minDist = d
                            target = mob
                        end
                    end
                end
                
                -- Dekati & Serang
                if target then
                    TweenTo(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                    
                    if isAtTarget then
                        -- Serangan Remote (\4)
                        Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = target.Name}, [2] = "\4"}})
                    end
                end
            end
        end
    end
end)
