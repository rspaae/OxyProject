local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "ARISE DUNGEON MASTER V6", HidePremium = false, SaveConfig = true, ConfigFolder = "AriseDungeon"})

-- SETTINGS
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local tween

getgenv().farm = false
getgenv().searchDungeon = false
getgenv().FarmMode = "Nearest"
getgenv().TweenSpeed = 200
getgenv().FarmDelay = 0.1

-- FUNGSI TWEEN (GERAK)
local function TweenToPosition(targetCFrame)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    
    if distance <= 10 then
        if tween then tween:Cancel() end
        rootPart.CFrame = targetCFrame
        return
    end

    local tweenInfo = TweenInfo.new(distance / getgenv().TweenSpeed, Enum.EasingStyle.Linear)
    if tween then tween:Cancel() end
    tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
end

-- FUNGSI KLIK UI OTOMATIS
local function AutoClickUI(text)
    local pGui = LocalPlayer:WaitForChild("PlayerGui")
    for _, v in pairs(pGui:GetDescendants()) do
        if (v:IsA("TextButton") or v:IsA("TextLabel")) and string.find(string.lower(v.Text or ""), string.lower(text)) then
            local btn = v:IsA("TextButton") and v or v.Parent
            if btn:IsA("TextButton") then
                local conns = getconnections(btn.MouseButton1Click)
                for _, conn in pairs(conns) do conn:Fire() end
                return true
            end
        end
    end
    return false
end

-- FUNGSI CARI MUSUH (FOLDER SPECIFIC)
local function FindTarget()
    local enemyFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
    if not enemyFolder then return nil end

    local closest, minDist = nil, math.huge
    for _, v in pairs(enemyFolder:GetChildren()) do
        local healthText = v:FindFirstChild("HealthBar") and v.HealthBar:FindFirstChild("Main") and v.HealthBar.Main:FindFirstChild("Bar") and v.HealthBar.Main.Bar:FindFirstChild("Amount")
        local root = v:FindFirstChild("HumanoidRootPart")
        
        if healthText and root and healthText.ContentText ~= "0 HP" then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = {instance = v, name = v.Name, rootPart = root}
            end
        end
    end
    return closest
end

-- FUNGSI CARI PORTAL
local function FindPortal()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("dungeon") or v.Name:lower():find("portal")) then
            return v
        end
    end
    return nil
end

-- TABS
local MainTab = Window:MakeTab({Name = "Dungeon & Farm", Icon = "rbxassetid://4483345998"})

MainTab:AddToggle({
    Name = "Auto Search & Start Dungeon",
    Default = false,
    Callback = function(Value)
        getgenv().searchDungeon = Value
    end    
})

MainTab:AddToggle({
    Name = "Auto Farm NPC (Inside)",
    Default = false,
    Callback = function(Value)
        getgenv().farm = Value
    end    
})

MainTab:AddSlider({
    Name = "Tween Speed",
    Min = 50,
    Max = 500,
    Default = 200,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 10,
    ValueName = "Speed",
    Callback = function(Value)
        getgenv().TweenSpeed = Value
    end    
})

-- MAIN LOOP
task.spawn(function()
    while task.wait() do
        -- LOGIKA 1: SEARCH DUNGEON
        if getgenv().searchDungeon then
            local portal = FindPortal()
            if portal then
                TweenToPosition(portal.CFrame)
                task.wait(0.5)
                if AutoClickUI("Create") then
                    task.wait(1)
                    AutoClickUI("Join")
                end
            end
        end

        -- LOGIKA 2: AUTO FARM NPC
        if getgenv().farm then
            local target = FindTarget()
            if target then
                TweenToPosition(target.rootPart.CFrame * CFrame.new(0, 0, 3))
                
                -- Serang via BridgeNet2 (Sesuai skrip asalmu)
                local args = {
                    { { Event = "PunchAttack", Enemy = target.name }, "\4" }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
                task.wait(getgenv().FarmDelay)
            end
        end
    end
end)

OrionLib:Init()
