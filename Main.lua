-- ARISE FINAL CONTROL (Minimize & Close Support)
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

-- 2. LOGIKA TOMBOL LOBBY (__Dungeon)
local function SearchDungeonLobby()
    local lobbyFolder = workspace:FindFirstChild("__Dungeon")
    if lobbyFolder then
        local portal = lobbyFolder:FindFirstChild("Dungeon")
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
            end
        end
    end
end

-- 3. LOGIKA AUTO LOOP (Fight & LastNpcs Replay)
local function GetEnemy()
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

-- 4. UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui", (game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")))
ScreenGui.Name = "AriseFinalUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -90)
MainFrame.Active = true
MainFrame.Draggable = true

-- TopBar (Title, Minimize, Close)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = " ARISE PRO CONTROL"; Title.Size = UDim2.new(1, -85, 1, 0); Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.SourceSansBold

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 40, 0, 40); CloseBtn.Position = UDim2.new(1, -40, 0, 0); CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().AutoLoop = false end)

local MiniBtn = Instance.new("TextButton", TopBar)
MiniBtn.Text = "-"; MiniBtn.Size = UDim2.new(0, 40, 0, 40); MiniBtn.Position = UDim2.new(1, -80, 0, 0); MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); MiniBtn.TextColor3 = Color3.new(1,1,1)

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -40); Content.Position = UDim2.new(0, 0, 0, 40); Content.BackgroundTransparency = 1

MiniBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    MainFrame.Size = Content.Visible and UDim2.new(0, 250, 0, 180) or UDim2.new(0, 250, 0, 40)
    MiniBtn.Text = Content.Visible and "-" or "+"
end)

-- Buttons
local BtnSearch = Instance.new("TextButton", Content)
BtnSearch.Text = "🔍 SEARCH DUNGEON"; BtnSearch.Size = UDim2.new(0, 230, 0, 50); BtnSearch.Position = UDim2.new(0, 10, 0, 10); BtnSearch.BackgroundColor3 = Color3.fromRGB(0, 100, 200); BtnSearch.TextColor3 = Color3.new(1,1,1); BtnSearch.MouseButton1Click:Connect(SearchDungeonLobby)

local BtnLoop = Instance.new("TextButton", Content)
BtnLoop.Text = "AUTO LOOP: OFF"; BtnLoop.Size = UDim2.new(0, 230, 0, 50); BtnLoop.Position = UDim2.new(0, 10, 0, 70); BtnLoop.BackgroundColor3 = Color3.fromRGB(60, 60, 60); BtnLoop.TextColor3 = Color3.new(1,1,1)
BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

-- 5. LOOP UTAMA
task.spawn(function()
    while task.wait(0.3) do
        if getgenv().AutoLoop then
            local enemy = GetEnemy()
            if enemy then
                local arrived = TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                if arrived then
                    Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemy.Name}, [2] = "\4"}})
                end
            else
                -- Musuh habis, cari Replay di LastNpcs
                local replay = workspace:FindFirstChild("LastNpcs")
                if replay then
                    local p = replay:FindFirstChild("Dungeon")
                    if p and TweenTo(p.CFrame) then
                        Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                        task.wait(1)
                    end
                end
            end
        end
    end
end)
