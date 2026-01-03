--[[
    ARISE SCRIPT - AREA TRIGGER FIX
    Logic: Prioritas Musuh -> Cari Zona Area Terjauh
    Sistem: Masuk ke tengah area pemicu UI otomatis.
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

-- Config
getgenv().AutoLoop = false
getgenv().Speed = 200

-- Status
local currentTween = nil
local isAtTarget = false
local processingDungeon = false

-- 2. SMART FUNCTIONS
local function TweenTo(targetCFrame)
    if not Root then return end
    local dist = (Root.Position - targetCFrame.Position).Magnitude

    if dist < 3 then -- Jarak lebih rapat agar pasti masuk area
        if currentTween then currentTween:Cancel(); currentTween = nil end
        isAtTarget = true
        return
    end

    isAtTarget = false
    local info = TweenInfo.new(dist / getgenv().Speed, Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(Root, info, {CFrame = targetCFrame})
    currentTween:Play()
end

local function InstantEnter()
    -- Remote tetap ditembak sebagai backup jika UI tidak muncul otomatis
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\n"})
    task.wait(0.8)
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\n"})
    task.wait(0.8)
    for i = 1, 3 do
        Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\n"})
        task.wait(0.2)
    end
end

-- 3. UI SETUP (DENGAN SLIDER)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.Position = UDim2.new(0.5, -100, 0.4, 0); MainFrame.Size = UDim2.new(0, 200, 0, 180); MainFrame.Active = true; MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = " ARISE: AUTO LOOP"; Title.Size = UDim2.new(1, -30, 0, 30); Title.BackgroundTransparency = 1; Title.TextColor3 = Color3.new(1, 1, 1); Title.Font = Enum.Font.SourceSansBold; Title.TextSize = 16; Title.TextXAlignment = 0

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0); CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().AutoLoop = false end)

local BtnLoop = Instance.new("TextButton", MainFrame)
BtnLoop.Text = "AUTO LOOP: OFF"; BtnLoop.Size = UDim2.new(0, 180, 0, 45); BtnLoop.Position = UDim2.new(0, 10, 0, 40); BtnLoop.BackgroundColor3 = Color3.fromRGB(50, 50, 50); BtnLoop.TextColor3 = Color3.new(1,1,1); BtnLoop.Font = Enum.Font.SourceSansBold
BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

local SliderFrame = Instance.new("Frame", MainFrame); SliderFrame.Size = UDim2.new(0, 180, 0, 60); SliderFrame.Position = UDim2.new(0, 10, 0, 100); SliderFrame.BackgroundTransparency = 1
local SliderText = Instance.new("TextLabel", SliderFrame); SliderText.Text = "TWEEN SPEED: " .. getgenv().Speed; SliderText.Size = UDim2.new(1, 0, 0, 20); SliderText.TextColor3 = Color3.new(1, 1, 1); SliderText.BackgroundTransparency = 1; SliderText.Font = Enum.Font.SourceSans
local SliderBar = Instance.new("Frame", SliderFrame); SliderBar.Size = UDim2.new(1, 0, 0, 10); SliderBar.Position = UDim2.new(0, 0, 0, 30); SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
local SliderKnob = Instance.new("TextButton", SliderBar); SliderKnob.Size = UDim2.new(0, 20, 0, 20); SliderKnob.Position = UDim2.new(getgenv().Speed/700, -10, 0.5, -10); SliderKnob.BackgroundColor3 = Color3.fromRGB(100, 100, 255); SliderKnob.Text = ""

local dragging = false
SliderKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local relativePos = UserInputService:GetMouseLocation().X - SliderBar.AbsolutePosition.X
        local percentage = math.clamp(relativePos / SliderBar.AbsoluteSize.X, 0, 1)
        getgenv().Speed = math.floor(percentage * 700)
        SliderKnob.Position = UDim2.new(percentage, -10, 0.5, -10)
        SliderText.Text = "TWEEN SPEED: " .. getgenv().Speed
    end
end)

-- 4. MAIN LOOP LOGIC
task.spawn(function()
    while task.wait(0.3) do
        if not ScreenGui.Parent then break end
        if not Character or not Character.Parent or not Root then
            Character = Player.Character or Player.CharacterAdded:Wait()
            Root = Character:WaitForChild("HumanoidRootPart")
            continue
        end

        if getgenv().AutoLoop then
            -- A. PRIORITAS: CEK MUSUH
            local EnemyFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
            local targetEnemy = nil
            local minDistEnemy = math.huge

            if EnemyFolder then
                for _, mob in pairs(EnemyFolder:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
                    if hrp and hp and hp.ContentText ~= "0 HP" then
                        local d = (Root.Position - hrp.Position).Magnitude
                        if d < minDistEnemy then minDistEnemy = d; targetEnemy = mob end
                    end
                end
            end

            if targetEnemy then
                processingDungeon = false
                TweenTo(targetEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                if isAtTarget then
                    Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = targetEnemy.Name}, [2] = "\4"}})
                end
            else
                -- B. CARI AREA PORTAL TERJAUH
                if not processingDungeon then
                    local targetPortal = nil
                    local maxDist = 0 

                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") then
                            local name = v.Name:lower()
                            -- Mencari pemicu zona (Portal/Area/Zone/Teleport)
                            if name:find("portal") or name:find("area") or name:find("zone") or name:find("teleport") or name:find("dungeon") then
                                -- Pastikan bukan part dari player/musuh
                                if not v:IsDescendantOf(Character) and not v:IsDescendantOf(workspace.__Main) then
                                    local d = (Root.Position - v.Position).Magnitude
                                    if d > maxDist then
                                        maxDist = d
                                        targetPortal = v
                                    end
                                end
                            end
                        end
                    end

                    if targetPortal then
                        TweenTo(targetPortal.CFrame) -- Langsung masuk ke tengah pemicu
                        if isAtTarget then
                            processingDungeon = true
                            InstantEnter() -- Tembak remote sebagai backup
                            task.wait(5)
                            processingDungeon = false
                        end
                    end
                end
            end
        end
    end
end)
