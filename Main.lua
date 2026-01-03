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
getgenv().Speed = 1000
getgenv().AutoFindDungeon = true
getgenv().CurrentDungeonStage = "Idle" -- Untuk melacak stage dungeon

-- 1. FUNGSI TWEEN (Diperbaiki dengan error handling)
local function TweenTo(targetCFrame)
    if not Root or not targetCFrame then 
        warn("Root atau targetCFrame tidak valid")
        return false 
    end
    
    local dist = (Root.Position - targetCFrame.Position).Magnitude
    if dist < 4 then 
        return true 
    end
    
    local success, errorMsg = pcall(function()
        local info = TweenInfo.new(dist / getgenv().Speed, Enum.EasingStyle.Linear)
        local tw = TweenService:Create(Root, info, {CFrame = targetCFrame})
        tw:Play()
        tw.Completed:Wait()
    end)
    
    if not success then
        warn("Tween gagal:", errorMsg)
        return false
    end
    
    return true
end

-- 2. FUNGSI CARI OBJECT
local function GetPortalObject(folderName)
    local folder = workspace:FindFirstChild(folderName)
    if folder then
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

-- 3. LOGIKA MUSUH DENGAN VERIFIKASI LEBIH KETAT
local function GetEnemy()
    -- Reset untuk menghindari cache lama
    local client = workspace:FindFirstChild("__Main") 
    and workspace.__Main:FindFirstChild("__Enemies") 
    and workspace.__Main.__Enemies:FindFirstChild("Client")
    
    if client then
        for _, mob in pairs(client:GetChildren()) do
            -- Verifikasi bahwa mob valid
            if mob:IsA("Model") then
                local humanoidRootPart = mob:FindFirstChild("HumanoidRootPart")
                local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
                
                -- Pastikan semua komponen ada
                if humanoidRootPart and hp then
                    -- Cek HP tidak 0 dan HP valid
                    if hp.ContentText ~= "0 HP" and hp.ContentText ~= "" then
                        return mob
                    end
                end
            end
        end
    end
    return nil
end

-- 4. FUNGSI UNTUK MENDETEKSI DUNGEON BARU
local function CheckForNewDungeon()
    -- Cek apakah ada object Dungeon baru
    local dungeonFolders = {"__Dungeon", "Dungeon", "_Dungeon"}
    
    for _, folderName in ipairs(dungeonFolders) do
        local obj = GetPortalObject(folderName)
        if obj then
            return true
        end
    end
    
    return false
end

-- 5. FUNGSI UNTUK MASUK DUNGEON
local function EnterDungeon()
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
                getgenv().CurrentDungeonStage = "DungeonEntered"
                return true
            end
        end
    end
    
    return false
end

-- 6. FUNGSI RESET STATE
local function ResetState()
    getgenv().CurrentDungeonStage = "Idle"
    print("State telah direset")
end

-- 7. UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", (game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
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
    if EnterDungeon() then
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
        ResetState()
    else
        StatusLabel.Text = "Status: IDLE"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- 8. MAIN INTEGRATED LOOP (Diperbaiki)
task.spawn(function()
    local lastDungeonSearchTime = 0
    local dungeonSearchCooldown = 5
    local consecutiveNoEnemyCount = 0
    local lastValidEnemyTime = 0
    
    while task.wait(0.5) do
        if getgenv().AutoLoop then
            local currentTime = tick()
            
            -- Cek apakah ada Dungeon baru tersedia
            local newDungeonAvailable = CheckForNewDungeon()
            
            -- Jika ada Dungeon baru, reset state
            if newDungeonAvailable and getgenv().CurrentDungeonStage == "DungeonEntered" then
                ResetState()
                StatusLabel.Text = "Status: NEW DUNGEON DETECTED"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            end
            
            -- Dapatkan NPC dengan verifikasi ketat
            local enemy = GetEnemy()
            
            if enemy then
                -- Verifikasi bahwa enemy benar-benar ada dan valid
                local humanoidRootPart = enemy:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    lastValidEnemyTime = currentTime
                    consecutiveNoEnemyCount = 0
                    
                    -- Update status
                    StatusLabel.Text = "Status: ATTACKING NPC"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                    
                    -- Coba Tween dengan error handling
                    local tweenSuccess = TweenTo(humanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                    
                    if tweenSuccess then
                        -- Serang setelah tween berhasil
                        Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemy.Name}, [2] = "\4"}})
                    else
                        StatusLabel.Text = "Status: TWEEN FAILED"
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    end
                else
                    -- Jika enemy tidak memiliki HumanoidRootPart, anggap invalid
                    consecutiveNoEnemyCount = consecutiveNoEnemyCount + 1
                end
            else
                consecutiveNoEnemyCount = consecutiveNoEnemyCount + 1
                
                -- Jika tidak ada NPC selama 3 detik
                if consecutiveNoEnemyCount >= 6 then -- 6 x 0.5 = 3 detik
                    StatusLabel.Text = "Status: NO NPC FOUND"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    
                    -- Cek apakah sudah ada di stage Dungeon
                    if getgenv().CurrentDungeonStage == "DungeonEntered" then
                        StatusLabel.Text = "Status: WAITING FOR NEW DUNGEON"
                        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 0)
                        
                        -- Tunggu 5 detik sebelum mencari Dungeon lagi
                        if (currentTime - lastDungeonSearchTime) > dungeonSearchCooldown then
                            if CheckForNewDungeon() then
                                StatusLabel.Text = "Status: NEW DUNGEON AVAILABLE"
                                StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
                            end
                        end
                    else
                        -- Jika belum masuk Dungeon dan fitur aktif, cari Dungeon
                        if getgenv().AutoFindDungeon and (currentTime - lastDungeonSearchTime) > dungeonSearchCooldown then
                            StatusLabel.Text = "Status: SEARCHING DUNGEON..."
                            StatusLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
                            
                            local dungeonFound = false
                            local replayObj = GetPortalObject("LastNpcs")
                            
                            if replayObj then
                                if TweenTo(replayObj.CFrame) then
                                    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                                    dungeonFound = true
                                    task.wait(2)
                                end
                            end
                            
                            if not dungeonFound then
                                dungeonFound = EnterDungeon()
                            end
                            
                            lastDungeonSearchTime = currentTime
                            
                            if dungeonFound then
                                StatusLabel.Text = "Status: DUNGEON ENTERED"
                                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                                task.wait(3)
                            else
                                StatusLabel.Text = "Status: DUNGEON NOT FOUND"
                                StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                            end
                        else
                            -- Tampilkan cooldown
                            local remainingTime = math.floor(dungeonSearchCooldown - (currentTime - lastDungeonSearchTime))
                            if remainingTime > 0 then
                                StatusLabel.Text = "Status: COOLDOWN " .. remainingTime .. "s"
                                StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                            end
                        end
                    end
                else
                    -- Tampilkan countdown
                    local timeUntilSearch = math.ceil((6 - consecutiveNoEnemyCount) * 0.5)
                    StatusLabel.Text = "Status: Checking NPCs (" .. timeUntilSearch .. "s)"
                    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 0)
                end
            end
        end
    end
end)

-- 9. AUTO RESET WHEN DUNGEON CHANGES
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoLoop then
            -- Cek jika ada perubahan pada folder Dungeon
            local hasDungeon = CheckForNewDungeon()
            
            -- Jika sebelumnya tidak ada Dungeon tapi sekarang ada, reset state
            if hasDungeon and getgenv().CurrentDungeonStage == "Idle" then
                StatusLabel.Text = "Status: DUNGEON READY"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
            end
            
            -- Jika lebih dari 10 detik tanpa enemy dan sudah di Dungeon, reset
            if getgenv().CurrentDungeonStage == "DungeonEntered" then
                local client = workspace:FindFirstChild("__Main") 
                and workspace.__Main:FindFirstChild("__Enemies") 
                and workspace.__Main.__Enemies:FindFirstChild("Client")
                
                if client and #client:GetChildren() == 0 then
                    -- Tunggu 10 detik sebelum reset
                    task.wait(10)
                    if #client:GetChildren() == 0 then
                        ResetState()
                        StatusLabel.Text = "Status: DUNGEON COMPLETED - RESET"
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
                    end
                end
            end
        end
    end
end)

print("ARISE FINAL Script Loaded!")
print("Auto Loop dengan deteksi NPC yang diperbaiki")
print("Auto Find Dungeon: " .. (getgenv().AutoFindDungeon and "Enabled" or "Disabled"))
