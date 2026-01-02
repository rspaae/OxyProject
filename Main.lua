-- SETTINGS & VARIABLES
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

getgenv().autoDungeon = false
getgenv().autoFarm = false
getgenv().speed = 200

local currentTween

-- FUNGSI GERAK (TWEEN SPEED 200)
local function tweenTo(targetCFrame)
    local distance = (root.Position - targetCFrame.Position).Magnitude
    if distance < 3 then return end
    local info = TweenInfo.new(distance / getgenv().speed, Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = game:GetService("TweenService"):Create(root, info, {CFrame = targetCFrame})
    currentTween:Play()
    return currentTween -- Mengembalikan objek tween untuk dideteksi
end

-- FUNGSI MASUK DUNGEON (LOGIC REMOTE DENGAN JEDA STABIL)
local function InstantEnter()
    print("Mencoba Masuk Dungeon...")
    -- 1. Pemicu awal
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\n"})
    task.wait(1) -- Beri waktu lebih lama agar server merespon posisi kita
    
    -- 2. Create (Seringkali game butuh ini dipanggil 2x jika gagal)
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\n"})
    task.wait(1)
    
    -- 3. Start (Mencoba beberapa kali karena ID bisa berubah di server)
    for i = 1, 5 do
        Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\n"})
        task.wait(0.3)
    end
end

-- UI MINIMIZE & CLOSE (RINGAN)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 180, 0, 150)
Main.Position = UDim2.new(0.5, -90, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -60, 0, 30); Title.Text = "  ARISE PRO"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.TextXAlignment = 0

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0); CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); getgenv().autoDungeon = false; getgenv().autoFarm = false end)

local MinBtn = Instance.new("TextButton", Main)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -60, 0, 0); MinBtn.Text = "-"; MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); MinBtn.TextColor3 = Color3.new(1,1,1)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, -30); Content.Position = UDim2.new(0, 0, 0, 30); Content.BackgroundTransparency = 1

MinBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    Main.Size = Content.Visible and UDim2.new(0, 180, 0, 150) or UDim2.new(0, 180, 0, 30)
    MinBtn.Text = Content.Visible and "-" or "+"
end)

local function CreateBtn(name, pos, callback)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(0, 160, 0, 45); btn.Position = pos; btn.Text = name; btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local b1 = CreateBtn("DUNGEON: OFF", UDim2.new(0, 10, 0, 10), function() getgenv().autoDungeon = not getgenv().autoDungeon end)
local b2 = CreateBtn("FARM: OFF", UDim2.new(0, 10, 0, 65), function() getgenv().autoFarm = not getgenv().autoFarm end)

-- MAIN LOOP
task.spawn(function()
    local isProcessingDungeon = false
    
    while task.wait(0.5) do
        if not ScreenGui.Parent then break end
        b1.Text = getgenv().autoDungeon and "DUNGEON: ON" or "DUNGEON: OFF"
        b1.BackgroundColor3 = getgenv().autoDungeon and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)
        b2.Text = getgenv().autoFarm and "FARM: ON" or "FARM: OFF"
        b2.BackgroundColor3 = getgenv().autoFarm and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 50)

        if getgenv().autoDungeon and not isProcessingDungeon then
            local portal = nil
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("portal") or v.Name:lower():find("dungeon")) then
                    portal = v; break
                end
            end

            if portal then
                local dist = (root.Position - portal.Position).Magnitude
                if dist > 5 then
                    tweenTo(portal.CFrame)
                else
                    -- DETEKSI BERHENTI: Jika sudah sangat dekat dan tidak bergerak lagi
                    if root.AssemblyLinearVelocity.Magnitude < 1 then
                        isProcessingDungeon = true
                        InstantEnter()
                        task.wait(5) -- Cooldown agar tidak spam saat loading
                        isProcessingDungeon = false
                    end
                end
            end
        end

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
                    Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = target.Name}, [2] = "\4"}})
                end
            end
        end
    end
end)
