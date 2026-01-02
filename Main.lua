if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- // // // Services // // // --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- // // // Locals // // // --
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

-- // // // Global Variables // // // --
getgenv().AutoDungeon = false
getgenv().AutoFarmDung = false
getgenv().TweenSpeed = 200

local currentTween = nil
local isAtTarget = false
local processingDungeon = false

-- // // // Functions // // // --

-- 1. Smart Tween (Diam jika sudah sampai)
local function tweenTo(targetCFrame)
    local distance = (HumanoidRootPart.Position - targetCFrame.Position).Magnitude
    if distance < 4 then
        if currentTween then currentTween:Cancel(); currentTween = nil end
        isAtTarget = true
        return
    end
    isAtTarget = false
    local info = TweenInfo.new(distance / getgenv().TweenSpeed, Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(HumanoidRootPart, info, {CFrame = targetCFrame})
    currentTween:Play()
end

-- 2. Instant Dungeon Entry (Remote Logic)
local function InstantEnter()
    -- Trigger Dialog
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\n"})
    task.wait(0.8)
    -- Create Room
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\n"})
    task.wait(0.8)
    -- Start Room (Loop ID 1-3)
    for i = 1, 3 do
        Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\n"})
        task.wait(0.3)
    end
end

-- // // // Fluent UI Setup // // // --
local Fluent = loadstring(game:HttpGet("https://you.whimper.xyz/sources/Fluent/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Arise Crossover [FIXED]",
    SubTitle = "by Adam & Gemini",
    TabWidth = 130,
    Size = UDim2.fromOffset(550, 330),
    Acrylic = false,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "gamepad-2" }),
    Dungeon = Window:AddTab({ Title = "Dungeon", Icon = "swords" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- // // // UI Elements // // // --

-- Tab Main (Contoh dari kodemu)
Tabs.Main:AddParagraph({
    Title = "Status",
    Content = "Karakter: " .. LocalPlayer.DisplayName
})

-- Tab Dungeon
local DungSection = Tabs.Dungeon:AddSection("Dungeon Automation")

DungSection:AddToggle("TglDung", {Title = "Auto Search & Enter Portal", Default = false}):OnChanged(function(Value)
    getgenv().AutoDungeon = Value
end)

DungSection:AddToggle("TglFarmDung", {Title = "Auto Clear (Attack NPC)", Default = false}):OnChanged(function(Value)
    getgenv().AutoFarmDung = Value
end)

DungSection:AddSlider("SliderSpeed", {
    Title = "Tween Speed",
    Default = 200,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) getgenv().TweenSpeed = Value end
})

-- // // // Main Loop Processor // // // --
task.spawn(function()
    while task.wait(0.5) do
        -- Update Character Reference jika mati
        if not LocalCharacter or not LocalCharacter:Parent() then
            LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            HumanoidRootPart = LocalCharacter:WaitForChild("HumanoidRootPart")
        end

        -- LOGIKA 1: AUTO ENTER PORTAL
        if getgenv().AutoDungeon and not processingDungeon then
            local portal = nil
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("portal") or v.Name:lower():find("dungeon")) then
                    portal = v; break
                end
            end

            if portal then
                tweenTo(portal.CFrame)
                if isAtTarget then
                    processingDungeon = true
                    InstantEnter()
                    task.wait(5) -- Cooldown transisi world
                    processingDungeon = false
                end
            end
        end

        -- LOGIKA 2: AUTO CLEAR NPC
        if getgenv().AutoFarmDung then
            local enemies = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
            if enemies and #enemies:GetChildren() > 0 then
                local target = nil
                local minDist = math.huge
                
                for _, v in pairs(enemies:GetChildren()) do
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    local hp = v:FindFirstChild("HealthBar") and v.HealthBar.Main.Bar.Amount
                    if hrp and hp and hp.ContentText ~= "0 HP" then
                        local d = (HumanoidRootPart.Position - hrp.Position).Magnitude
                        if d < minDist then minDist = d; target = v end
                    end
                end

                if target then
                    tweenTo(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                    if isAtTarget then
                        Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = target.Name}, [2] = "\4"}})
                    end
                end
            end
        end
    end
end)

Fluent:Notify({Title = "Arise Fix", Content = "Script Loaded Successfully!", Duration = 3})
