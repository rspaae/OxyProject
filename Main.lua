-- ARISE FINAL CONTROL - FOCUS NPC FIRST
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

getgenv().AutoLoop = false
getgenv().Speed = 250 
local currentTween = nil

-- 1. FUNGSI TWEEN
local function TweenTo(targetCFrame)
    if not Root then return end
    local dist = (Root.Position - targetCFrame.Position).Magnitude
    if dist < 4 then
        if currentTween then currentTween:Cancel(); currentTween = nil end
        return true
    end
    local info = TweenInfo.new(dist / getgenv().Speed, Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(Root, info, {CFrame = targetCFrame})
    currentTween:Play()
    return false
end

-- 2. FUNGSI CEK JUMLAH MUSUH (SANGAT KETAT)
local function GetEnemyCount()
    local clientFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
    if clientFolder then
        local count = 0
        for _, mob in pairs(clientFolder:GetChildren()) do
            local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
            if hp and hp.ContentText ~= "0 HP" then
                count = count + 1
            end
        end
        return count
    end
    return 0
end

local function GetFirstEnemy()
    local clientFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
    if clientFolder then
        for _, mob in pairs(clientFolder:GetChildren()) do
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
            if hrp and hp and hp.ContentText ~= "0 HP" then return mob end
        end
    end
    return nil
end

-- 3. UI (MINIMIZE & CLOSE)
local ScreenGui = Instance.new("ScreenGui", (game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 180); MainFrame.Position = UDim2.new(0.5, -125, 0.4, -90); MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.Draggable = true; MainFrame.Active = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40); TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 40, 0, 40); CloseBtn.Position = UDim2.new(1, -40, 0, 0); CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().AutoLoop = false end)

local BtnSearch = Instance.new("TextButton", MainFrame)
BtnSearch.Text = "🔍 SEARCH DUNGEON"; BtnSearch.Size = UDim2.new(0, 230, 0, 50); BtnSearch.Position = UDim2.new(0, 10, 0, 50); BtnSearch.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
BtnSearch.MouseButton1Click:Connect(function()
    local lobby = workspace:FindFirstChild("__Dungeon")
    if lobby and lobby:FindFirstChild("Dungeon") then
        if TweenTo(lobby.Dungeon.CFrame) then
            Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
            task.wait(0.5)
            Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\4"})
            task.wait(0.5)
            for i = 1, 3 do Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\4"}) end
        end
    end
end)

local BtnLoop = Instance.new("TextButton", MainFrame)
BtnLoop.Text = "AUTO LOOP: OFF"; BtnLoop.Size = UDim2.new(0, 230, 0, 50); BtnLoop.Position = UDim2.new(0, 10, 0, 110); BtnLoop.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

-- 4. MAIN LOOP (NPC FOCUS)
task.spawn(function()
    while task.wait(0.3) do
        if getgenv().AutoLoop then
            local count = GetEnemyCount()
            
            if count > 0 then
                -- FOKUS TOTAL KE NPC
                local enemy = GetFirstEnemy()
                if enemy then
                    local arrived = TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                    if arrived then
                        Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemy.Name}, [2] = "\4"}})
                    end
                end
            else
                -- HANYA JIKA MUSUH BENAR-BENAR 0, BARU CARI PORTAL
                local replay = workspace:FindFirstChild("LastNpcs")
                if replay and replay:FindFirstChild("Dungeon") then
                    if TweenTo(replay.Dungeon.CFrame) then
                        Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                        task.wait(2) -- Jeda lebih lama agar tidak bug
                    end
                end
            end
        end
    end
end)
