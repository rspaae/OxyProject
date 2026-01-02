local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "ARISE ULTRA HUB", HidePremium = false, SaveConfig = true, ConfigFolder = "AriseConfig"})

-- VARIABLES
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local tween

getgenv().farm = false
getgenv().FarmMode = "Nearest"
getgenv().FarmDelay = 0.1 -- Kecepatan serangan
getgenv().TweenSpeed = 200 -- Speed 200 yang kamu minta

-- FUNGSI TWEEN (GERAK)
local function TweenToPosition(targetCFrame)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    
    -- Jika sangat dekat, langsung CFrame
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

-- FUNGSI CARI MUSUH (BERDASARKAN STRUKTUR GAME)
local function FindTarget()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local hrp = character.HumanoidRootPart
    local closest = nil
    local minDist = math.huge
    
    -- Mencari di folder spesifik Arise
    local enemyFolder = workspace.__Main.__Enemies:FindFirstChild("Client")
    if not enemyFolder then return nil end

    for _, v in pairs(enemyFolder:GetChildren()) do
        local healthText = v:FindFirstChild("HealthBar") and v.HealthBar:FindFirstChild("Main") and v.HealthBar.Main:FindFirstChild("Bar") and v.HealthBar.Main.Bar:FindFirstChild("Amount")
        local root = v:FindFirstChild("HumanoidRootPart")
        
        if healthText and root and healthText.ContentText ~= "0 HP" then
            local dist = (hrp.Position - root.Position).Magnitude
            if getgenv().FarmMode == "Nearest" then
                if dist < minDist then
                    minDist = dist
                    closest = {instance = v, name = v.Name, rootPart = root, healthText = healthText}
                end
            else
                -- Mode Free (Acak)
                return {instance = v, name = v.Name, rootPart = root, healthText = healthText}
            end
        end
    end
    return closest
end

-- UI TAB
local Tab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998"})

Tab:AddToggle({
    Name = "Start Auto Farm NPC",
    Default = false,
    Callback = function(Value)
        getgenv().farm = Value
    end    
})

Tab:AddDropdown({
    Name = "Target Mode",
    Default = "Nearest",
    Options = {"Nearest", "Free"},
    Callback = function(Value)
        getgenv().FarmMode = Value
    end    
})

Tab:AddSlider({
    Name = "Tween Speed",
    Min = 50,
    Max = 500,
    Default = 200,
    Color = Color3.fromRGB(0,255,100),
    Increment = 10,
    ValueName = "Speed",
    Callback = function(Value)
        getgenv().TweenSpeed = Value
    end    
})

-- MAIN LOOP (FARMING)
task.spawn(function()
    while task.wait() do
        if getgenv().farm then
            local target = FindTarget()
            if target then
                -- Menuju musuh dengan speed 200
                TweenToPosition(target.rootPart.CFrame * CFrame.new(0, 0, 3))
                
                -- Serang menggunakan Remote Event Game
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
