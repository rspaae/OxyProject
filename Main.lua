-- SETTINGS
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local Remote = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

getgenv().autoDungeon = false
getgenv().autoFarm = false
getgenv().speed = 200

-- FUNGSI GERAK (TWEEN)
local function tweenTo(targetCFrame)
    local dist = (root.Position - targetCFrame.Position).Magnitude
    if dist < 2 then return end -- Sudah sampai
    local info = TweenInfo.new(dist / getgenv().speed, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(root, info, {CFrame = targetCFrame})
    tween:Play()
end

-- FUNGSI MASUK DUNGEON (LOGIKA REMOTE SCRIPT PRO)
local function InstantEnter()
    -- Mengirim perintah untuk memicu Dialog/UI muncul di server
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\n"})
    task.wait(0.5)
    -- Membuat Dungeon
    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\n"})
    task.wait(0.5)
    -- Memulai Dungeon (ID 1)
    Remote:FireServer({[1] = {["Dungeon"] = 1, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\n"})
end

-- UI POLOS RINGAN
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 140)
Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Active = true
Main.Draggable = true

local function CreateBtn(name, pos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 45)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local b1 = CreateBtn("AUTO DUNGEON: OFF", UDim2.new(0, 10, 0, 15), function() getgenv().autoDungeon = not getgenv().autoDungeon end)
local b2 = CreateBtn("AUTO FARM: OFF", UDim2.new(0, 10, 0, 75), function() getgenv().autoFarm = not getgenv().autoFarm end)

-- MAIN LOOP
task.spawn(function()
    while task.wait(0.5) do
        -- Update Tampilan Tombol
        b1.Text = getgenv().autoDungeon and "DUNGEON: ON" or "AUTO DUNGEON: OFF"
        b1.BackgroundColor3 = getgenv().autoDungeon and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
        b2.Text = getgenv().autoFarm and "FARM: ON" or "AUTO FARM: OFF"
        b2.BackgroundColor3 = getgenv().autoFarm and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)

        -- LOGIKA DUNGEON
        if getgenv().autoDungeon then
            -- 1. Cari Portal di Folder __Main.__World
            local portal = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__World") and workspace.__Main.__World:FindFirstChild("Dungeon")
            
            -- Jika tidak ada di folder khusus, cari manual di Workspace
            if not portal then
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name:lower():find("portal") then
                        portal = v break
                    end
                end
            end

            if portal then
                local dist = (root.Position - portal.Position).Magnitude
                if dist > 10 then
                    tweenTo(portal.CFrame) -- Terbang ke portal
                else
                    -- Jika sudah sampai (dist < 10), jalankan fungsi masuk
                    InstantEnter()
                end
            end
        end

        -- LOGIKA FARM (HANYA JALAN JIKA ADA MUSUH)
        if getgenv().autoFarm then
            local enemyFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
            if enemyFolder and #enemyFolder:GetChildren() > 0 then
                for _, v in pairs(enemyFolder:GetChildren()) do
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    local hp = v:FindFirstChild("HealthBar") and v.HealthBar.Main.Bar.Amount
                    if hrp and hp and hp.ContentText ~= "0 HP" then
                        tweenTo(hrp.CFrame * CFrame.new(0, 0, 5))
                        -- Serang sesuai script pro (\4)
                        Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = v.Name}, [2] = "\4"}})
                        break
                    end
                end
            end
        end
    end
end)
