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
Title.Text = "ARISE NPC ONLY FARM"
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.TextColor3 = Color3.new(1, 1, 1)

local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(0, 240, 0, 50)
FarmBtn.Position = UDim2.new(0, 20, 0, 55)
FarmBtn.Text = "AUTO FARM NPC: OFF"
FarmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FarmBtn.TextColor3 = Color3.new(1, 1, 1)

-- FUNGSI FILTER (UNTUK MEMASTIKAN BUKAN PLAYER)
local function isNotAPlayer(model)
    if game.Players:GetPlayerFromCharacter(model) then
        return false -- Ini adalah Player
    end
    return true -- Ini adalah NPC
end

-- FUNGSI CARI MUSUH (HANYA NPC)
local function getClosestNPC()
    local target, dist = nil, math.huge
    
    for _, v in pairs(game.Workspace:GetDescendants()) do
        -- Cari yang punya Highlight (seperti di fotomu) atau Humanoid
        if (v:IsA("Highlight") or v:IsA("Humanoid")) then
            local model = v:IsA("Highlight") and v.Parent or v.Parent
            
            -- Pastikan model itu bukan kita, dan BUKAN player lain
            if model ~= char and isNotAPlayer(model) then
                local targetPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
                
                -- Cek HP jika ada humanoid
                local targetHum = model:FindFirstChildOfClass("Humanoid")
                local health = targetHum and targetHum.Health or 100 -- Anggap hidup jika tak ada hum
                
                if targetPart and health > 0 then
                    local d = (root.Position - targetPart.Position).Magnitude
                    if d < dist then
                        dist = d
                        target = targetPart
                    end
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
            local npc = getClosestNPC()
            if npc then
                hum.WalkSpeed = speed
                -- Samperin NPC
                hum:MoveTo(npc.Position)
                
                -- Klik & Skill
                VirtualUser:Button1Down(Vector2.new(0,0))
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "Z", false, game)
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "X", false, game)
            else
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
    FarmBtn.Text = autoFarmActive and "FARMING NPC..." or "AUTO FARM NPC: OFF"
    FarmBtn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)
