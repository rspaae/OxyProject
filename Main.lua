--[[
    SIMPLE ARISE AUTOMATION BASE
    Dibuat untuk: Remake & Customization
    Fitur: Auto Dungeon (Remote), Auto Farm, Smart Tween (Stop at Target)
]]

-- 1. LAYANAN & VARIABEL UTAMA
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

-- Pengaturan Awal (Bisa kamu ubah default-nya)
getgenv().Config = {
    AutoDungeon = false,
    AutoFarm = false,
    TweenSpeed = 200,    -- Kecepatan terbang
    StopDistance = 4     -- Jarak berhenti dari target
}

-- Variabel Status (Jangan diubah)
local currentTween = nil
local isAtTarget = false
local isBusy = false -- Supaya tidak spam perintah masuk dungeon

-- 2. FUNGSI GERAKAN (SMART TWEEN)
-- Fungsi ini otomatis berhenti jika sudah dekat target
local function SmartMove(targetCFrame)
    local Character = LocalPlayer.Character
    if not Character then return end
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end

    local distance = (Root.Position - targetCFrame.Position).Magnitude

    -- Jika sudah dekat (di bawah jarak berhenti), matikan tween & diam
    if distance < getgenv().Config.StopDistance then
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end
        isAtTarget = true -- Memberitahu skrip bahwa kita sudah sampai
        return
    end

    -- Jika masih jauh, terbang ke sana
    isAtTarget = false
    local info = TweenInfo.new(distance / getgenv().Config.TweenSpeed, Enum.EasingStyle.Linear)
    
    -- Mencegah pembuatan tween baru jika targetnya sama (Optimasi)
    if currentTween and currentTween.PlaybackState == Enum.PlaybackState.Playing then
        -- Opsional: Bisa tambahkan cek target disini jika mau lebih canggih
    else
        currentTween = TweenService:Create(Root, info, {CFrame = targetCFrame})
        currentTween:Play()
    end
end

-- 3. FUNGSI LOGIKA GAME (REMOTE)
-- Fungsi untuk membantai musuh
local function AttackMob(mobName)
    local args = {
        [1] = {
            [1] = {
                ["Event"] = "PunchAttack",
                ["Enemy"] = mobName
            },
            [2] = "\4" -- Signature serangan Arise
        }
    }
    Remote:FireServer(unpack(args))
end

-- Fungsi urutan masuk Dungeon otomatis
local function EnterDungeon()
    if isBusy then return end
    isBusy = true
    
    -- Urutan Remote (Bisa kamu tambah print untuk debug)
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\n"})
    task.wait(0.8)
    
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\n"})
    task.wait(0.8)
    
    -- Loop ID jaga-jaga
    for i = 1, 3 do
        Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\n"})
        task.wait(0.2)
    end
    
    task.wait(3) -- Cooldown loading screen
    isBusy = false
end

-- 4. PEMBUATAN UI SEDERHANA (Mudah di-remake)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AriseSimpleGUI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true

-- Judul
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "ARISE CUSTOM"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

-- Tombol Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = MainFrame
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    getgenv().Config.AutoDungeon = false
    getgenv().Config.AutoFarm = false
end)

-- Tombol Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = MainFrame
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinBtn.TextColor3 = Color3.new(1, 1, 1)

local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1

MinBtn.MouseButton1Click:Connect(function()
    ContentFrame.Visible = not ContentFrame.Visible
    if ContentFrame.Visible then
        MainFrame.Size = UDim2.new(0, 200, 0, 150)
        MinBtn.Text = "-"
    else
        MainFrame.Size = UDim2.new(0, 200, 0, 30)
        MinBtn.Text = "+"
    end
end)

-- Helper Function untuk Membuat Tombol Toggle
local function CreateToggleBtn(text, yPos, configKey)
    local btn = Instance.new("TextButton")
    btn.Parent = ContentFrame
    btn.Text = text .. ": OFF"
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    
    btn.MouseButton1Click:Connect(function()
        getgenv().Config[configKey] = not getgenv().Config[configKey]
        local status = getgenv().Config[configKey]
        btn.Text = text .. (status and ": ON" or ": OFF")
        btn.BackgroundColor3 = status and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end)
    return btn
end

-- Buat Tombolnya
CreateToggleBtn("AUTO DUNGEON", 15, "AutoDungeon")
CreateToggleBtn("AUTO FARM", 65, "AutoFarm")

-- 5. LOOP UTAMA (LOGIKA JALAN DISINI)
task.spawn(function()
    while task.wait(0.2) do -- Loop cek setiap 0.2 detik
        -- Cek karakter hidup atau mati
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            continue
        end

        -- LOGIKA A: AUTO DUNGEON
        if getgenv().Config.AutoDungeon then
            local targetPortal = nil
            -- Cari objek bernama Portal atau Dungeon
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("portal") or obj.Name:lower():find("dungeon")) then
                    targetPortal = obj
                    break
                end
            end

            if targetPortal then
                SmartMove(targetPortal.CFrame)
                
                -- Jika sudah sampai dan skrip tidak sedang sibuk
                if isAtTarget and not isBusy then
                    EnterDungeon()
                end
            end
        end

        -- LOGIKA B: AUTO FARM
        if getgenv().Config.AutoFarm then
            local EnemiesFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
            
            if EnemiesFolder then
                local target = nil
                local minDist = math.huge
                
                -- Cari musuh terdekat
                for _, mob in pairs(EnemiesFolder:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hpBar = mob:FindFirstChild("HealthBar")
                    
                    -- Pastikan musuh punya darah dan belum mati
                    if hrp and hpBar and hpBar.Main.Bar.Amount.ContentText ~= "0 HP" then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            target = mob
                        end
                    end
                end
                
                -- Eksekusi Target
                if target then
                    SmartMove(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)) -- Jarak serang 5 studs
                    
                    if isAtTarget then
                        AttackMob(target.Name)
                    end
                end
            end
        end
    end
end)
