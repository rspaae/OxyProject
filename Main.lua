--[[
    ARISE CROSSOVER - ALL-IN-ONE SCRIPT
    Fitur: 
    - Auto Loop (Farm & Dungeon)
    - Smart Tween (Anti-Stuck & Jarak Berhenti)
    - Speed Slider (Maks 700)
    - Auto Target Priority (Enemy > Portal)
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- // // // SERVICES // // // --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // // // VARIABLES // // // --
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

-- // // // CONFIG // // // --
getgenv().AutoLoop = false
getgenv().Speed = 200

local currentTween = nil
local isAtTarget = false
local processingDungeon = false

-- // // // FUNCTIONS // // // --

-- 1. Gerak Tween Pintar
local function TweenTo(targetCFrame)
    if not Root then return end
    local dist = (Root.Position - targetCFrame.Position).Magnitude

    -- Berhenti jika sudah sampai di area (Jarak 3-4 studs)
    if dist < 4 then
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

-- 2. Remote Masuk Dungeon (Instant)
local function InstantEnter()
    -- Mengirim sinyal masuk, buat room, dan mulai dungeon
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\n"})
    task.wait(0.8)
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\n"})
    task.wait(0.8)
    for i = 1, 3 do
        Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\n"})
        task.wait(0.2)
    end
end

-- // // // UI SETUP // // // --
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -100, 0.4, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = " ARISE: AUTO LOOP"
Title.Size = UDim2.new(1, -30, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"; CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().AutoLoop = false end)

local BtnLoop = Instance.new("TextButton", MainFrame)
BtnLoop.Text = "AUTO LOOP: OFF"
BtnLoop.Size = UDim2.new(0, 180, 0, 45)
BtnLoop.Position = UDim2.new(0, 10, 0, 40)
BtnLoop.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BtnLoop.TextColor3 = Color3.new(1,1,1)
BtnLoop.Font = Enum.Font.SourceSansBold
BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

-- Slider Speed
local SliderFrame = Instance.new("Frame", MainFrame)
SliderFrame.Size = UDim2.new(0, 180, 0, 60); SliderFrame.Position = UDim2.new(0, 10, 0, 100); SliderFrame.BackgroundTransparency = 1
local SliderText = Instance.new("TextLabel", SliderFrame)
SliderText.Text = "SPEED: " .. getgenv().Speed; SliderText.Size = UDim2.new(1, 0, 0, 20); SliderText.TextColor3 = Color3.new(1, 1, 1); SliderText.BackgroundTransparency = 1
local SliderBar = Instance.new("Frame", SliderFrame)
SliderBar.Size = UDim2.new(1, 0, 0, 10); SliderBar.Position = UDim2.new(0, 0, 0, 30); SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
local SliderKnob = Instance.new("TextButton", SliderBar)
SliderKnob.Size = UDim2.new(0, 20, 0, 20); SliderKnob.Position = UDim2.new(getgenv().Speed/700, -10, 0.5, -10); SliderKnob.BackgroundColor3 = Color3.fromRGB(100, 100, 255); SliderKnob.Text = ""

local dragging = false
SliderKnob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local relativePos = UserInputService:GetMouseLocation().X - SliderBar.AbsolutePosition.X
        local percentage = math.clamp(relativePos / SliderBar.AbsoluteSize.X, 0, 1)
        getgenv().Speed = math.floor(percentage * 700)
        SliderKnob.Position = UDim2.new(percentage, -10, 0.5, -10)
        SliderText.Text = "SPEED: " .. getgenv().Speed
    end
end)

-- // // // MAIN LOOP // // // --
task.spawn(function()
    while task.wait(0.3) do
        if not ScreenGui.Parent then break end
        
        -- Cek Karakter
        if not Character or not Character.Parent or not Root then
            Character = Player.Character or Player.CharacterAdded:Wait()
            Root = Character:WaitForChild("HumanoidRootPart")
            continue
        end

        if getgenv().AutoLoop then
            -- A. CEK MUSUH (Prioritas Utama)
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

            -- B. EKSEKUSI TARGET
            if targetEnemy then
                -- ADA MUSUH: Bantai
                processingDungeon = false
                TweenTo(targetEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                if isAtTarget then
                    Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = targetEnemy.Name}, [2] = "\4"}})
                end
            else
                -- TIDAK ADA MUSUH: Cari Portal (Lobby atau Exit Dungeon)
                if not processingDungeon then
                    local targetPortal = nil
                    local maxDist = 0

                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") then
                            local name = v.Name:lower()
                            -- Deteksi nama portal/area/zone/dungeon
                            if name:find("portal") or name:find("area") or name:find("zone") or name:find("gate") or name:find("teleport") or name:find("dungeon") then
                                if not v:IsDescendantOf(Character) and not v:IsDescendantOf(workspace:FindFirstChild("__Main") or workspace) then
                                    local dist = (Root.Position - v.Position).Magnitude
                                    -- Mencari yang terjauh (Pintu Keluar) atau terdekat jika di Lobby
                                    if dist > 15 and dist > maxDist then
                                        maxDist = dist
                                        targetPortal = v
                                    end
                                end
                            end
                        end
                    end

                    if targetPortal then
                        TweenTo(targetPortal.CFrame)
                        if isAtTarget then
                            processingDungeon = true
                            InstantEnter()
                            task.wait(5)
                            processingDungeon = false
                        end
                    end
                end
            end
        end
    end
end)
