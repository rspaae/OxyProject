--[[
    ARISE SCRIPT - FIXED PORTAL & NPC BLACKLIST
    Logic: Priority Target (Enemy > Dungeon Portal)
    Note: Menghindari NPC "Crafts" dan "Rune Shop"
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- 1. LAYANAN & VARIABEL
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
getgenv().Speed = 700 -- Default sesuai screenshot kamu

-- Status
local currentTween = nil
local isAtTarget = false
local processingDungeon = false

-- 2. FUNGSI LOGIKA
local function TweenTo(targetCFrame)
    if not Root then return end
    local dist = (Root.Position - targetCFrame.Position).Magnitude

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

local function InstantEnter()
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\n"})
    task.wait(0.8)
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\n"})
    task.wait(0.8)
    for i = 1, 3 do
        Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\n"})
        task.wait(0.2)
    end
end

-- 3. UI (Sesuai Gambar Kamu)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, 100, 0.5, 50)
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "ARISE: AUTO LOOP"
Title.Size = UDim2.new(1, -30, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().AutoLoop = false end)

local BtnLoop = Instance.new("TextButton", MainFrame)
BtnLoop.Text = "AUTO LOOP: OFF"
BtnLoop.Size = UDim2.new(0, 200, 0, 50)
BtnLoop.Position = UDim2.new(0, 10, 0, 40)
BtnLoop.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
BtnLoop.TextColor3 = Color3.new(1, 1, 1)
BtnLoop.Font = Enum.Font.SourceSansBold

BtnLoop.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    BtnLoop.Text = getgenv().AutoLoop and "AUTO LOOP: ON" or "AUTO LOOP: OFF"
    BtnLoop.BackgroundColor3 = getgenv().AutoLoop and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(45, 45, 45)
end)

local SliderText = Instance.new("TextLabel", MainFrame)
SliderText.Text = "TWEEN SPEED: " .. getgenv().Speed
SliderText.Size = UDim2.new(1, 0, 0, 20)
SliderText.Position = UDim2.new(0, 0, 0, 100)
SliderText.TextColor3 = Color3.new(1, 1, 1)
SliderText.BackgroundTransparency = 1

local SliderBar = Instance.new("Frame", MainFrame)
SliderBar.Size = UDim2.new(0, 200, 0, 10)
SliderBar.Position = UDim2.new(0, 10, 0, 130)
SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local SliderKnob = Instance.new("Frame", SliderBar)
SliderKnob.Size = UDim2.new(0, 15, 0, 25)
SliderKnob.Position = UDim2.new(getgenv().Speed/700, -7, 0.5, -12)
SliderKnob.BackgroundColor3 = Color3.fromRGB(100, 100, 255)

-- Logic Slider
local dragging = false
SliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local percentage = math.clamp((UserInputService:GetMouseLocation().X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        getgenv().Speed = math.max(1, math.floor(percentage * 700))
        SliderKnob.Position = UDim2.new(percentage, -7, 0.5, -12)
        SliderText.Text = "TWEEN SPEED: " .. getgenv().Speed
    end
end)

-- 4. LOGIKA UTAMA
task.spawn(function()
    while task.wait(0.3) do
        if not ScreenGui.Parent then break end
        if not Character or not Character.Parent or not Root then
            Character = Player.Character or Player.CharacterAdded:Wait()
            Root = Character:WaitForChild("HumanoidRootPart")
            continue
        end

        if getgenv().AutoLoop then
            -- Cek Musuh
            local EnemyFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
            local targetEnemy = nil
            local minDist = math.huge

            if EnemyFolder then
                for _, mob in pairs(EnemyFolder:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
                    if hrp and hp and hp.ContentText ~= "0 HP" then
                        local d = (Root.Position - hrp.Position).Magnitude
                        if d < minDist then minDist = d; targetEnemy = mob end
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
                -- Jika musuh habis (Room Clear), cari Portal "Dungeon"
                if not processingDungeon then
                    local targetPortal = nil
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") and v.Name == "Dungeon" then
                            -- Tambahan filter: Pastikan bukan bagian dari NPC Shop/Craft
                            local parentName = v.Parent.Name:lower()
                            if not parentName:find("craft") and not parentName:find("shop") and not parentName:find("rune") then
                                targetPortal = v
                                break
                            end
                        end
                    end
                    
                    if targetPortal then
                        TweenTo(targetPortal.CFrame)
                        if isAtTarget then
                            processingDungeon = true
                            InstantEnter()
                            task.wait(4)
                            processingDungeon = false
                        end
                    end
                end
            end
        end
    end
end)
