local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "ARISE: AUTO DUNGEON", HidePremium = false, SaveConfig = true, ConfigFolder = "AriseDungeon"})

-- SETTINGS
getgenv().autoSearch = false
getgenv().autoClear = false
getgenv().TweenSpeed = 200

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local tween

-- FUNGSI GERAK TWEEN
local function TweenTo(targetCFrame)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local rootPart = character.HumanoidRootPart
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    
    local tweenInfo = TweenInfo.new(distance / getgenv().TweenSpeed, Enum.EasingStyle.Linear)
    if tween then tween:Cancel() end
    tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
end

-- FUNGSI KLIK UI (PENTING UNTUK MASUK DUNGEON)
local function ClickDungeonUI()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return end
    for _, v in pairs(pGui:GetDescendants()) do
        if v:IsA("TextButton") and v.Visible then
            local txt = v.Text:lower()
            if txt:find("create") or txt:find("join") or txt:find("start") or txt:find("enter") then
                -- Simulasi klik
                local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
                for _, event in pairs(events) do
                    for _, conn in pairs(getconnections(v[event])) do
                        conn:Fire()
                    end
                end
            end
        end
    end
end

-- TABS
local DungeonTab = Window:MakeTab({Name = "Dungeon Automation", Icon = "rbxassetid://4483345998"})

DungeonTab:AddToggle({
    Name = "1. AUTO SEARCH PORTAL (Lobby)",
    Default = false,
    Callback = function(Value)
        getgenv().autoSearch = Value
    end    
})

DungeonTab:AddToggle({
    Name = "2. AUTO CLEAR DUNGEON (Inside)",
    Default = false,
    Callback = function(Value)
        getgenv().autoClear = Value
    end    
})

DungeonTab:AddSlider({
    Name = "Movement Speed",
    Min = 50, Max = 500, Default = 200,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 10,
    ValueName = "Speed",
    Callback = function(Value)
        getgenv().TweenSpeed = Value
    end    
})

-- MAIN LOOP
task.spawn(function()
    while task.wait(0.1) do
        -- LOGIKA SEARCH (DILUAR/LOBBY)
        if getgenv().autoSearch then
            local portal = nil
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("portal") or v.Name:lower():find("dungeon")) then
                    portal = v
                    break
                end
            end
            
            if portal then
                TweenTo(portal.CFrame)
                ClickDungeonUI() -- Mencoba klik tombol Create/Join yang muncul
            end
        end

        -- LOGIKA CLEAR (DIDALAM DUNGEON)
        if getgenv().autoClear then
            local enemyFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
            
            if enemyFolder then
                local target = nil
                local minDist = math.huge
                
                for _, v in pairs(enemyFolder:GetChildren()) do
                    local hp = v:FindFirstChild("HealthBar") and v.HealthBar:FindFirstChild("Main") and v.HealthBar.Main:FindFirstChild("Bar") and v.HealthBar.Main.Bar:FindFirstChild("Amount")
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    
                    if hp and hrp and hp.ContentText ~= "0 HP" then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            target = {root = hrp, name = v.Name}
                        end
                    end
                end
                
                if target then
                    TweenTo(target.root.CFrame * CFrame.new(0, 0, 3))
                    -- Serang
                    local args = {
                        { { Event = "PunchAttack", Enemy = target.name }, "\4" }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
                end
            end
        end
    end
end)

OrionLib:Init()
