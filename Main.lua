-- SETTINGS
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

getgenv().autoDungeon = false
getgenv().autoFarm = false
getgenv().speed = 200

-- 1. FUNGSI REMOTE ENTRY (DARI SCRIPT PRO)
-- Ini akan langsung masuk dungeon tanpa perlu klik tombol UI
local function RemoteDungeonEntry()
    -- Perintah Create
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\n"})
    task.wait(0.3)
    -- Perintah Start (Dungeon ID 1)
    Remote:FireServer({[1] = {["Dungeon"] = 1, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\n"})
end

-- 2. FUNGSI SERANG (REMOTE PUNCH)
local function RemoteAttack(enemyName)
    local args = {[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemyName}, [2] = "\4"}}
    Remote:FireServer(unpack(args))
end

-- 3. FUNGSI GERAK (TWEEN)
local function tweenTo(targetCFrame)
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local info = TweenInfo.new(dist / getgenv().speed, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(root, info, {CFrame = targetCFrame})
    tween:Play()
end

-- UI POLOS RINGAN
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 130)
Main.Position = UDim2.new(0.5, -90, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local function CreateBtn(name, pos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 160, 0, 40)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local btnDungeon = CreateBtn("AUTO DUNGEON: OFF", UDim2.new(0, 10, 0, 20), function()
    getgenv().autoDungeon = not getgenv().autoDungeon
end)

local btnFarm = CreateBtn("AUTO FARM: OFF", UDim2.new(0, 10, 0, 70), function()
    getgenv().autoFarm = not getgenv().autoFarm
end)

-- MAIN LOOP (LOGIKA GABUNGAN)
task.spawn(function()
    while task.wait(0.2) do
        -- Update UI Text
        btnDungeon.Text = getgenv().autoDungeon and "DUNGEON: ON" or "DUNGEON: OFF"
        btnDungeon.BackgroundColor3 = getgenv().autoDungeon and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
        btnFarm.Text = getgenv().autoFarm and "FARM: ON" or "FARM: OFF"
        btnFarm.BackgroundColor3 = getgenv().autoFarm and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)

        -- LOGIKA AUTO MASUK & CARI PORTAL
        if getgenv().autoDungeon then
            RemoteDungeonEntry() -- Panggil fungsi Remote Pro
            
            -- Cari portal terdekat untuk mendekat (opsional agar tidak dikira cheat diam)
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:lower():find("portal") then
                    tweenTo(v.CFrame)
                    break
                end
            end
        end

        -- LOGIKA PEMBANTAI NPC (FOLDER CLIENT)
        if getgenv().autoFarm then
            local enemyFolder = workspace:FindFirstChild("__Main") and workspace.__Main.__Enemies:FindFirstChild("Client")
            if enemyFolder then
                local target, minDist = nil, math.huge
                for _, v in pairs(enemyFolder:GetChildren()) do
                    local hp = v:FindFirstChild("HealthBar") and v.HealthBar.Main.Bar.Amount
                    if hp and hp.ContentText ~= "0 HP" and v:FindFirstChild("HumanoidRootPart") then
                        local d = (root.Position - v.HumanoidRootPart.Position).Magnitude
                        if d < minDist then minDist = d target = v end
                    end
                end
                
                if target then
                    tweenTo(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4))
                    RemoteAttack(target.Name)
                end
            end
        end
    end
end)
