--[[ 
    ARISE SCRIPT - FINAL OPTIMIZED
    - Search Dungeon: Khusus Lobby (__Dungeon)
    - Auto Loop: Attack -> Replay (LastNpcs)
    - UI: Draggable, Minimize, and Close
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
local currentTween = nil
local isMinimized = false

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

-- 2. FUNGSI SEARCH DUNGEON (LOBBY ONLY)
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
    else
        warn("Lobby folder not found!")
    end
end

-- 3. FUNGSI TARGET
local function GetEnemy()
    local clientFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
    if clientFolder then
        for _, mob in pairs(clientFolder:GetChildren()) do
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
            if hrp and hp and hp.ContentText ~= "0 HP" then
                return mob
            end
        end
    end
    return nil
end

-- 4. UI CONSTRUCTION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AriseFinalUI"
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -90)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 0

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Text = " ARISE PRO"
Title.Size = UDim2.new(1, -80, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = 0

-- Fitur Close
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().AutoLoop = false end)

-- Fitur Minimize
local MiniBtn = Instance.new("TextButton", TopBar)
MiniBtn.Text = "-"
MiniBtn.Size = UDim2.new(0, 40, 0, 40)
MiniBtn.Position = UDim2.new(1, -80, 0, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MiniBtn.TextColor3 = Color3.new(1,1,1)
MiniBtn.BorderSizePixel = 0

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1

MiniBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Content.Visible = not isMinimized
    MainFrame.Size = isMinimized and UDim2.new(0, 250, 0, 40) or UDim2.new(0, 250, 0, 180)
    MiniBtn.Text = isMinimized and "+" or "-"
end)

-- Buttons
local BtnSearch = Instance.new("TextButton", Content)
BtnSearch.Text = "🔍 SEARCH DUNGEON"
BtnSearch.Size = UDim2.new(0, 230, 0, 50)
BtnSearch.Position = UDim2.new(0, 10, 0, 10)
BtnSearch.BackgroundColor3 = Color3.fromRGB(0, 102, 204)
BtnSearch.TextColor3 = Color3.new(1,1,1)
BtnSearch.Font = Enum.Font.SourceSansBold
BtnSearch.MouseButton1Click:Connect(SearchDungeonLobby)

local BtnLoop = Instance.new("TextButton", Content)
BtnLoop.Text = "AUTO LOOP: OFF"
BtnLoop.Size = UDim2.new(0, 230, 0, 50)
BtnLoop.Position = UDim2.new(0, 10, 0, 70)
BtnLoop.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BtnLoop.TextColor3 = Color3.new(1,1,1)
BtnLoop.Font = Enum.Font.SourceSansBold

BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 153, 76) or Color3.fromRGB(50, 50, 50)
end)

-- 5. MAIN THREAD
task.spawn(function()
    while task.wait(0.3) do
        if not ScreenGui.Parent then break end
        if getgenv().AutoLoop then
            local enemy = GetEnemy()
            if enemy then
                local arrived = TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                if arrived then
                    Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemy.Name}, [2] = "\4"}})
                end
            else
                local replayFolder = workspace:FindFirstChild("LastNpcs")
                if replayFolder then
                    local portal = replayFolder:FindFirstChild("Dungeon")
                    if portal then
                        local arrived = TweenTo(portal.CFrame)
                        if arrived then
                            Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"}})
                            task.wait(1)
                        end
                    end
                end
            end
        end
    end
end)
