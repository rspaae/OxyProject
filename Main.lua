--[[ 
    ARISE FINAL - OBJECT-BASED DETECTION
    - Lobby Search: Mencari Object (BasePart) di dalam folder "__Dungeon"
    - Auto Loop: Fokus NPC -> Cari Object (BasePart) di dalam folder "LastNpcs"
    - UI: Minimize & Close
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

getgenv().AutoLoop = false
getgenv().Speed = 700
getgenv().AutoFindDungeon = true -- Fitur baru: otomatis cari Dungeon setelah NPC habis

-- 1. FUNGSI TWEEN
local function TweenTo(targetCFrame)
    if not Root or not targetCFrame then return end
    local dist = (Root.Position - targetCFrame.Position).Magnitude
    if dist < 4 then return true end
    local info = TweenInfo.new(dist / getgenv().Speed, Enum.EasingStyle.Linear)
    local tw = TweenService:Create(Root, info, {CFrame = targetCFrame})
    tw:Play()
    tw.Completed:Wait()
    return true
end

-- 2. FUNGSI CARI OBJECT (Bukan cuma nama "Dungeon")
local function GetPortalObject(folderName)
    local folder = workspace:FindFirstChild(folderName)
    if folder then
        -- Mencari objek fisik pertama (Part/MeshPart) di dalam folder tersebut
        for _, obj in pairs(folder:GetChildren()) do
            if obj:IsA("BasePart") then
                return obj
            elseif obj:FindFirstChildWhichIsA("BasePart") then
                return obj:FindFirstChildWhichIsA("BasePart")
            end
        end
    end
    return nil
end

-- 3. LOGIKA MUSUH SESUAI KODE ASLI ANDA
local function GetEnemy()
    local client = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
    if client then
        for _, mob in pairs(client:GetChildren()) do
            local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
            if hp and hp.ContentText ~= "0 HP" then 
                return mob 
            end
        end
    end
    return nil
end

-- 4. FUNGSI UNTUK MENDETEKSI APAKAH MASIH ADA NPC YANG HIDUP (Versi sederhana)
local function AreEnemiesAlive()
    local client = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
    if not client then return false end
    
    for _, mob in pairs(client:GetChildren()) do
        local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
        if hp and hp.ContentText ~= "0 HP" then
            return true -- Masih ada NPC yang hidup
        end
    end
    
    return false -- Semua NPC sudah mati
end

-- 5. FUNGSI UNTUK MENCARI DAN MASUK DUNGEON
local function FindAndEnterDungeon()
    -- Cari object Dungeon di berbagai lokasi yang mungkin
    local dungeonFolders = {
        "__Dungeon",
        "Dungeon",
        "_Dungeon",
        "LastNpcs",
        "LastNPCs"
    }
    
    for _, folderName in ipairs(dungeonFolders) do
        local obj = GetPortalObject(folderName)
        if obj then
            print("Dungeon object ditemukan di folder:", folderName)
            if TweenTo(obj.CFrame) then
                Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                task.wait(0.5)
                Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\4"})
                task.wait(0.5)
                for i = 1, 3 do 
                    Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\4"}) 
                    task.wait(0.1)
                end
                return true
            end
        end
    end
    
    warn("Tidak ada Dungeon object ditemukan!")
    return false
end

-- 6. UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", (game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 220) -- Diperbesar sedikit
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.MouseButton1Click:Connect(function() 
    ScreenGui:Destroy() 
    getgenv().AutoLoop = false 
end)

local MiniBtn = Instance.new("TextButton", TopBar)
MiniBtn.Text = "-"
MiniBtn.Size = UDim2.new(0, 40, 0, 40)
MiniBtn.Position = UDim2.new(1, -80, 0, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MiniBtn.TextColor3 = Color3.new(1,1,1)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1

MiniBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    MainFrame.Size = Content.Visible and UDim2.new(0, 250, 0, 220) or UDim2.new(0, 250, 0, 40)
    MiniBtn.Text = Content.Visible and "-" or "+"
end)

-- Status Label
local StatusLabel = Instance.new("TextLabel", Content)
StatusLabel.Text = "Status: IDLE"
StatusLabel.Size = UDim2.new(0, 230, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 10)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Auto Find Dungeon
local DungeonToggle = Instance.new("TextButton", Content)
DungeonToggle.Text = "AUTO FIND DUNGEON: " .. (getgenv().AutoFindDungeon and "ON" or "OFF")
DungeonToggle.Size = UDim2.new(0, 230, 0, 30)
DungeonToggle.Position = UDim2.new(0, 10, 0, 45)
DungeonToggle.BackgroundColor3 = getgenv().AutoFindDungeon and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
DungeonToggle.TextColor3 = Color3.new(1,1,1)

DungeonToggle.MouseButton1Click:Connect(function()
    getgenv().AutoFindDungeon = not getgenv().AutoFindDungeon
    DungeonToggle.Text = "AUTO FIND DUNGEON: " .. (getgenv().AutoFindDungeon and "ON" or "OFF")
    DungeonToggle.BackgroundColor3 = getgenv().AutoFindDungeon and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

local BtnSearch = Instance.new("TextButton", Content)
BtnSearch.Text = "🔍 SEARCH LOBBY OBJECT"
BtnSearch.Size = UDim2.new(0, 230, 0, 40)
BtnSearch.Position = UDim2.new(0, 10, 0, 85)
BtnSearch.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
BtnSearch.TextColor3 = Color3.new(1,1,1)

BtnSearch.MouseButton1Click:Connect(function()
    if FindAndEnterDungeon() then
        StatusLabel.Text = "Status: Dungeon Found"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        StatusLabel.Text = "Status: No Dungeon Found"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

local BtnLoop = Instance.new("TextButton", Content)
BtnLoop.Text = "AUTO LOOP: OFF"
BtnLoop.Size = UDim2.new(0, 230, 0, 40)
BtnLoop.Position = UDim2.new(0, 10, 0, 135)
BtnLoop.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnLoop.TextColor3 = Color3.new(1,1,1)

BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    
    if getgenv().AutoLoop then
        StatusLabel.Text = "Status: AUTO LOOP ACTIVE"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        StatusLabel.Text = "Status: IDLE"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- 7. MAIN INTEGRATED LOOP
task.spawn(function()
    local lastDungeonSearchTime = 0
    local dungeonSearchCooldown = 5 -- Cooldown 5 detik antara pencarian Dungeon
    local enemyCheckCounter = 0
    local consecutiveNoEnemyCount = 0 -- Untuk deteksi konsisten tidak ada musuh
    
    while task.wait(0.5) do
        if getgenv().AutoLoop then
            local currentTime = tick()
            
            -- Gunakan fungsi GetEnemy sesuai kode asli Anda
            local enemy = GetEnemy()
            
            if enemy then
                -- Reset counter jika menemukan musuh
                consecutiveNoEnemyCount = 0
                
                -- Jika ada NPC, serang
                StatusLabel.Text = "Status: ATTACKING NPC"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                
                if TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)) then
                    Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemy.Name}, [2] = "\4"}})
                end
            else
                -- Tambah counter jika tidak ada musuh
                consecutiveNoEnemyCount = consecutiveNoEnemyCount + 1
                
                -- Hanya cari Dungeon jika konsisten tidak ada musuh selama beberapa detik (2.5 detik)
                if consecutiveNoEnemyCount >= 5 then -- 5 x 0.5 detik = 2.5 detik
                    StatusLabel.Text = "Status: NO NPC FOUND"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    
                    -- Cek apakah fitur Auto Find Dungeon aktif dan cooldown sudah selesai
                    if getgenv().AutoFindDungeon and (currentTime - lastDungeonSearchTime) > dungeonSearchCooldown then
                        StatusLabel.Text = "Status: SEARCHING DUNGEON..."
                        StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
                        
                        -- Cari object Dungeon
                        local dungeonFound = false
                        
                        -- Coba cari di LastNpcs terlebih dahulu
                        local replayObj = GetPortalObject("LastNpcs")
                        if replayObj then
                            if TweenTo(replayObj.CFrame) then
                                Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                                dungeonFound = true
                                task.wait(2)
                            end
                        end
                        
                        -- Jika tidak ditemukan di LastNpcs, cari di folder Dungeon lainnya
                        if not dungeonFound then
                            dungeonFound = FindAndEnterDungeon()
                        end
                        
                        lastDungeonSearchTime = currentTime
                        
                        if dungeonFound then
                            StatusLabel.Text = "Status: DUNGEON ENTERED"
                            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                            task.wait(3) -- Tunggu sebentar setelah masuk dungeon
                        else
                            StatusLabel.Text = "Status: DUNGEON NOT FOUND"
                            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        end
                    else
                        -- Jika sedang cooldown, tunggu
                        local remainingTime = math.floor(dungeonSearchCooldown - (currentTime - lastDungeonSearchTime))
                        if remainingTime > 0 then
                            StatusLabel.Text = "Status: COOLDOWN " .. remainingTime .. "s"
                            StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                        end
                    end
                else
                    -- Tampilkan countdown sampai pencarian Dungeon
                    local timeUntilSearch = math.ceil((5 - consecutiveNoEnemyCount) * 0.5)
                    StatusLabel.Text = "Status: Waiting " .. timeUntilSearch .. "s"
                    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 0)
                end
            end
        end
    end
end)

print("ARISE FINAL Script Loaded!")
print("Menggunakan deteksi NPC sesuai kode asli")
print("Auto Find Dungeon: " .. (getgenv().AutoFindDungeon and "Enabled" or "Disabled"))
