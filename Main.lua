-- SETTINGS
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local VirtualUser = game:GetService("VirtualUser")

local autoFarmActive = false
local speed = 200

-- UI SIMPLE & LEBAR
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 150)
Main.Position = UDim2.new(0.5, -140, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Draggable = true
Main.Active = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "ARISE MULTI-TARGET FARM"
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.TextColor3 = Color3.new(1, 1, 1)

local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(0, 240, 0, 50)
FarmBtn.Position = UDim2.new(0, 20, 0, 55)
FarmBtn.Text = "AUTO FARM ALL NPC: OFF"
FarmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FarmBtn.TextColor3 = Color3.new(1, 1, 1)

-- FUNGSI CARI SEMUA MUSUH (TIDAK PEDULI NAMA)
local function getClosestEnemy()
    local target, dist = nil, math.huge
    
    for _, v in pairs(game.Workspace:GetDescendants()) do
        -- Logika: Cari objek yang punya 'Highlight' (Garis Merah) atau 'Humanoid'
        -- Tapi pastikan itu bukan karakter kita sendiri
        if (v:IsA("Highlight") or v:IsA("Humanoid")) and not v:IsDescendantOf(char) then
            
            local model = (v:IsA("Highlight") and v.Parent) or (v:IsA("Humanoid") and v.Parent)
            local targetPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
            
            -- Cek apakah target masih hidup (jika punya humanoid)
            local isAlive = true
            local targetHum = model:FindFirstChildOfClass("Humanoid")
            if targetHum and targetHum.Health <= 0 then isAlive = false end
            
            if targetPart and isAlive then
                local d = (root.Position - targetPart.Position).Magnitude
                if d < dist then
                    dist = d
                    target = targetPart
                end
            end
        end
    end
    return target
end

-- LOOP UTAMA
task.spawn(function()
    while true do
        if autoFarmActive then
            local enemy = getClosestEnemy()
            if enemy then
                -- Lari ke musuh terdekat
                hum.WalkSpeed = speed
                hum:MoveTo(enemy.Position + (root.Position - enemy.Position).Unit * 2)
                
                -- Klik Otomatis
                VirtualUser:Button1Down(Vector2.new(0,0))
                
                -- Spam Skill (Z dan X)
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "Z", false, game)
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "X", false, game)
            else
                -- Jika musuh di sekitar habis, balik ke speed normal
                hum.WalkSpeed = 16
            end
        else
            hum.WalkSpeed = 16
        end
        task.wait(0.1)
    end
end)

FarmBtn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    FarmBtn.Text = autoFarmActive and "FARMING..." or "AUTO FARM ALL NPC: OFF"
    FarmBtn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)
