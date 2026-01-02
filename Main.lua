-- SETTINGS & VARIABLES
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

getgenv().autoDungeon = false
getgenv().autoFarm = false
getgenv().speed = 200

local currentTween = nil
local isAtTarget = false

-- FUNGSI GERAK (TWEEN STABIL)
local function tweenTo(targetCFrame)
    local distance = (root.Position - targetCFrame.Position).Magnitude
    
    -- Jika sudah sangat dekat, hentikan tween agar karakter diam total
    if distance < 4 then
        if currentTween then 
            currentTween:Cancel() 
            currentTween = nil
        end
        isAtTarget = true
        return
    end

    -- Jika jarak jauh, jalankan tween
    isAtTarget = false
    local info = TweenInfo.new(distance / getgenv().speed, Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = game:GetService("TweenService"):Create(root, info, {CFrame = targetCFrame})
    currentTween:Play()
end

-- FUNGSI MASUK DUNGEON (REMOTE PRO)
local function InstantEnter()
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\n"})
    task.wait(0.8)
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\n"})
    task.wait(0.8)
    for i = 1, 3 do
        Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\n"})
        task.wait(0.3)
    end
end

-- UI LIGHTWEIGHT (MINIMIZE & CLOSE)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 150); Main.Position = UDim2.new(0.5, -90, 0.4, 0); Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Main.Active = true; Main.Draggable = true

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0); CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().autoDungeon = false; getgenv().autoFarm = false end)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, -30); Content.Position = UDim2.new(0, 0, 0, 30); Content.BackgroundTransparency = 1

local b1 = Instance.new("TextButton", Content)
b1.Size = UDim2.new(0, 160, 0, 45); b1.Position = UDim2.new(0, 10, 0, 10); b1.BackgroundColor3 = Color3.fromRGB(50,50,50); b1.TextColor3 = Color3.new(1,1,1)
b1.MouseButton1Click:Connect(function() getgenv().autoDungeon = not getgenv().autoDungeon end)

local b2 = Instance.new("TextButton", Content)
b2.Size = UDim2.new(0, 160, 0, 45); b2.Position = UDim2.new(0, 10, 0, 65); b2.BackgroundColor3 = Color3.fromRGB(50,50,50); b2.TextColor3 = Color3.new(1,1,1)
b2.MouseButton1Click:Connect(function() getgenv().autoFarm = not getgenv().autoFarm end)

-- MAIN LOOP
task.spawn(function()
    local processingDungeon = false
    while task.wait(0.5) do
        if not ScreenGui.Parent then break end
        b1.Text = getgenv().autoDungeon and "DUNGEON: ON" or "DUNGEON: OFF"
        b1.BackgroundColor3 = getgenv().autoDungeon and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        b2.Text = getgenv().autoFarm and "FARM: ON" or "FARM: OFF"
        b2.BackgroundColor3 = getgenv().autoFarm and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)

        -- LOGIKA DUNGEON
        if getgenv().autoDungeon and not processingDungeon then
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
                    task.wait(5) -- Delay biar gak spam pas loading
                    processingDungeon = false
                end
            end
        end

        -- LOGIKA FARM
        if getgenv().autoFarm then
            local enemyFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
            if enemyFolder then
                local target = nil; local minDist = math.huge
                for _, v in pairs(enemyFolder:GetChildren()) do
                    local hp = v:FindFirstChild("HealthBar") and v.HealthBar.Main.Bar.Amount
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hrp and hp and hp.ContentText ~= "0 HP" then
                        local d = (root.Position - hrp.Position).Magnitude
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
