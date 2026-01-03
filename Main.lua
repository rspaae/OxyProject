--[[ 
    ARISE FINAL - FORCE DETECTION VERSION
    - Fix: Deteksi paksa portal di __Dungeon & LastNpcs
    - Prioritas: NPC > BOSS > REPLAY
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
getgenv().Speed = 250 

-- 1. FUNGSI TWEEN
local function TweenTo(targetCFrame)
    if not Root or not targetCFrame then return end
    local dist = (Root.Position - targetCFrame.Position).Magnitude
    if dist < 4 then return true end
    local info = TweenInfo.new(dist / getgenv().Speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(Root, info, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    return true
end

-- 2. DETEKSI PORTAL PAKSA (Lobby & Replay)
local function FindPortal(parentName)
    local folder = workspace:FindFirstChild(parentName)
    if folder then
        -- Mencari objek bernama "Dungeon" sesuai hasil scan
        local portal = folder:FindFirstChild("Dungeon") or folder:FindFirstChildWhichIsA("BasePart", true)
        if portal then return portal end
    end
    return nil
end

-- 3. DETEKSI MUSUH
local function GetEnemy()
    local client = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
    if client then
        for _, mob in pairs(client:GetChildren()) do
            local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
            if hp and hp.ContentText ~= "0 HP" then return mob end
        end
    end
    return nil
end

-- 4. UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", (game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 180); MainFrame.Position = UDim2.new(0.5, -125, 0.4, -90); MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.Active = true; MainFrame.Draggable = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40); TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 40, 0, 40); CloseBtn.Position = UDim2.new(1, -40, 0, 0); CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().AutoLoop = false end)

local MiniBtn = Instance.new("TextButton", TopBar)
MiniBtn.Text = "-"; MiniBtn.Size = UDim2.new(0, 40, 0, 40); MiniBtn.Position = UDim2.new(1, -80, 0, 0); MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -40); Content.Position = UDim2.new(0, 0, 0, 40); Content.BackgroundTransparency = 1

MiniBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    MainFrame.Size = Content.Visible and UDim2.new(0, 250, 0, 180) or UDim2.new(0, 250, 0, 40)
    MiniBtn.Text = Content.Visible and "-" or "+"
end)

-- Tombol Search Khusus Lobby
local BtnSearch = Instance.new("TextButton", Content)
BtnSearch.Text = "🔍 FORCE SEARCH DUNGEON"; BtnSearch.Size = UDim2.new(0, 230, 0, 50); BtnSearch.Position = UDim2.new(0, 10, 0, 10); BtnSearch.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
BtnSearch.MouseButton1Click:Connect(function()
    local portal = FindPortal("__Dungeon")
    if portal and TweenTo(portal.CFrame) then
        Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
        task.wait(0.5)
        Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\4"})
        task.wait(0.5)
        for i = 1, 3 do Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\4"}) end
    end
end)

-- Tombol Auto Loop
local BtnLoop = Instance.new("TextButton", Content)
BtnLoop.Text = "AUTO LOOP: OFF"; BtnLoop.Size = UDim2.new(0, 230, 0, 50); BtnLoop.Position = UDim2.new(0, 10, 0, 70); BtnLoop.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

-- 5. MAIN LOGIC THREAD
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoLoop then
            local enemy = GetEnemy()
            if enemy then
                -- Bunuh NPC
                TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemy.Name}, [2] = "\4"}})
            else
                -- Cari Replay di LastNpcs
                local replayPortal = FindPortal("LastNpcs")
                if replayPortal then
                    if TweenTo(replayPortal.CFrame) then
                        Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                        task.wait(2)
                    end
                end
            end
        end
    end
end)
