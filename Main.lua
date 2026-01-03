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
getgenv().Speed = 250 

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

-- 3. LOGIKA MUSUH
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
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 40, 0, 40); CloseBtn.Position = UDim2.new(1, -40, 0, 0); CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().AutoLoop = false end)

local MiniBtn = Instance.new("TextButton", TopBar)
MiniBtn.Text = "-"; MiniBtn.Size = UDim2.new(0, 40, 0, 40); MiniBtn.Position = UDim2.new(1, -80, 0, 0); MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); MiniBtn.TextColor3 = Color3.new(1,1,1)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -40); Content.Position = UDim2.new(0, 0, 0, 40); Content.BackgroundTransparency = 1

MiniBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    MainFrame.Size = Content.Visible and UDim2.new(0, 250, 0, 180) or UDim2.new(0, 250, 0, 40)
    MiniBtn.Text = Content.Visible and "-" or "+"
end)

local BtnSearch = Instance.new("TextButton", Content)
BtnSearch.Text = "🔍 SEARCH LOBBY OBJECT"; BtnSearch.Size = UDim2.new(0, 230, 0, 50); BtnSearch.Position = UDim2.new(0, 10, 0, 10); BtnSearch.BackgroundColor3 = Color3.fromRGB(0, 100, 200); BtnSearch.TextColor3 = Color3.new(1,1,1)

BtnSearch.MouseButton1Click:Connect(function()
    local obj = GetPortalObject("__Dungeon")
    if obj then
        if TweenTo(obj.CFrame) then
            Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
            task.wait(0.5)
            Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\4"})
            task.wait(0.5)
            for i = 1, 3 do Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\4"}) end
        end
    else
        warn("Tidak ada Object ditemukan di __Dungeon!")
    end
end)

local BtnLoop = Instance.new("TextButton", Content)
BtnLoop.Text = "AUTO LOOP: OFF"; BtnLoop.Size = UDim2.new(0, 230, 0, 50); BtnLoop.Position = UDim2.new(0, 10, 0, 70); BtnLoop.BackgroundColor3 = Color3.fromRGB(60, 60, 60); BtnLoop.TextColor3 = Color3.new(1,1,1)

BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

-- 5. MAIN INTEGRATED LOOP
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoLoop then
            local enemy = GetEnemy()
            if enemy then
                TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemy.Name}, [2] = "\4"}})
            else
                -- Cari Object apapun di LastNpcs jika musuh sudah 0
                local replayObj = GetPortalObject("LastNpcs")
                if replayObj and TweenTo(replayObj.CFrame) then
                    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                    task.wait(2)
                end
            end
        end
    end
end)
