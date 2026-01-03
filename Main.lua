--[[
    ARISE SCRIPT - PRO CONTROL FIX
    - High Precision NPC Blacklist (Crafts & Rune Shop)
    - Real-time Tween Speed Fix
    - Minimize & Close Feature
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- 1. SERVICES & VARIABLES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

-- Config Global
getgenv().AutoLoop = false
getgenv().Speed = 700 
local isMinimized = false

-- 2. CORE FUNCTIONS
local function TweenTo(targetCFrame)
    if not Root then return end
    local dist = (Root.Position - targetCFrame.Position).Magnitude

    if dist < 4 then
        if _G.currentTween then _G.currentTween:Cancel() end
        return true
    end

    -- Fix: Selalu ambil speed terbaru dari slider
    local tweenTime = dist / math.max(getgenv().Speed, 1)
    local info = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    
    if _G.currentTween then _G.currentTween:Cancel() end
    _G.currentTween = TweenService:Create(Root, info, {CFrame = targetCFrame})
    _G.currentTween:Play()
    return false
end

local function IsBlacklisted(obj)
    -- Daftar nama NPC yang harus dihindari
    local blacklistNames = {"crafts!", "rune shop", "craft menu"}
    local current = obj
    
    -- Cek sampai 5 tingkat ke atas untuk mencari nama NPC
    for i = 1, 5 do
        if not current or not current.Parent then break end
        local pName = current.Parent.Name:lower()
        for _, name in pairs(blacklistNames) do
            if pName:find(name) then return true end
        end
        current = current.Parent
    end
    return false
end

local function FindValidPortal()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Dungeon" then
            if not IsBlacklisted(v) then
                return v
            end
        end
    end
    return nil
end

-- 3. UI CONSTRUCTION (ENLARGED)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Position = UDim2.new(0.5, 50, 0.5, -140)
MainFrame.Active = true
MainFrame.Draggable = true

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = " ARISE: PRO CONTROL"
Title.Size = UDim2.new(1, -90, 1, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = 0

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -40)
Content.Position = UDim2.new(0, 0, 0, 40)
Content.BackgroundTransparency = 1

-- Minimize Button
local MiniBtn = Instance.new("TextButton", TopBar)
MiniBtn.Text = "_"; MiniBtn.Size = UDim2.new(0, 40, 0, 40); MiniBtn.Position = UDim2.new(1, -85, 0, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); MiniBtn.TextColor3 = Color3.new(1,1,1)
MiniBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Content.Visible = not isMinimized
    MainFrame.Size = isMinimized and UDim2.new(0, 260, 0, 40) or UDim2.new(0, 260, 0, 280)
    MiniBtn.Text = isMinimized and "+" or "_"
end)

-- Close Button
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 40, 0, 40); CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().AutoLoop = false end)

local BtnLoop = Instance.new("TextButton", Content)
BtnLoop.Text = "AUTO LOOP: OFF"; BtnLoop.Size = UDim2.new(0, 240, 0, 50); BtnLoop.Position = UDim2.new(0, 10, 0, 10)
BtnLoop.BackgroundColor3 = Color3.fromRGB(45, 45, 45); BtnLoop.TextColor3 = Color3.new(1,1,1); BtnLoop.Font = Enum.Font.SourceSansBold
BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(45, 45, 45)
end)

local BtnFind = Instance.new("TextButton", Content)
BtnFind.Text = "FIND LOBBY PORTAL"; BtnFind.Size = UDim2.new(0, 240, 0, 50); BtnFind.Position = UDim2.new(0, 10, 0, 70)
BtnFind.BackgroundColor3 = Color3.fromRGB(45, 45, 45); BtnFind.TextColor3 = Color3.new(1,1,1); BtnFind.Font = Enum.Font.SourceSansBold
BtnFind.MouseButton1Click:Connect(function()
    local p = FindValidPortal()
    if p then TweenTo(p.CFrame) end
end)

local SliderText = Instance.new("TextLabel", Content)
SliderText.Text = "SPEED: " .. getgenv().Speed; SliderText.Size = UDim2.new(1, 0, 0, 30); SliderText.Position = UDim2.new(0, 0, 0, 130); SliderText.TextColor3 = Color3.new(1,1,1); SliderText.BackgroundTransparency = 1

local SliderBar = Instance.new("Frame", Content)
SliderBar.Size = UDim2.new(0, 220, 0, 10); SliderBar.Position = UDim2.new(0, 20, 0, 170); SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local SliderKnob = Instance.new("Frame", SliderBar)
SliderKnob.Size = UDim2.new(0, 20, 0, 30); SliderKnob.Position = UDim2.new(getgenv().Speed/700, -10, 0.5, -15); SliderKnob.BackgroundColor3 = Color3.fromRGB(100, 100, 255)

local dragging = false
SliderBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local p = math.clamp((UserInputService:GetMouseLocation().X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        getgenv().Speed = math.max(50, math.floor(p * 700))
        SliderKnob.Position = UDim2.new(p, -10, 0.5, -15)
        SliderText.Text = "SPEED: " .. getgenv().Speed
    end
end)

-- 4. MAIN THREAD
task.spawn(function()
    while task.wait(0.3) do
        if not ScreenGui.Parent then break end
        if not Character or not Character.Parent or not Root then
            Character = Player.Character or Player.CharacterAdded:Wait(); Root = Character:WaitForChild("HumanoidRootPart")
            continue
        end

        if getgenv().AutoLoop then
            local Enemies = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
            local target = nil
            local dMin = math.huge

            if Enemies then
                for _, mob in pairs(Enemies:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
                    if hrp and hp and hp.ContentText ~= "0 HP" then
                        local d = (Root.Position - hrp.Position).Magnitude
                        if d < dMin then dMin = d; target = mob end
                    end
                end
            end

            if target then
                local arrived = TweenTo(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                if arrived then
                    Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = target.Name}, [2] = "\4"}})
                end
            else
                local portal = FindValidPortal()
                if portal then
                    local arrived = TweenTo(portal.CFrame)
                    if arrived then
                        -- Sequence masuk portal
                        Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                        task.wait(0.5)
                        Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\4"})
                        task.wait(0.5)
                        for i = 1, 3 do
                            Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\4"})
                        end
                        task.wait(3)
                    end
                end
            end
        end
    end
end)
