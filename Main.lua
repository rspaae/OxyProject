-- SETTINGS
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 280)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Draggable = true
MainFrame.Active = true

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Text = "  ARISE OBJECT SPY (ADVANCED)"
Header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Header.TextColor3 = Color3.new(1, 1, 1)

-- DISPLAY INFO
local InfoBox = Instance.new("TextLabel", MainFrame)
InfoBox.Size = UDim2.new(1, -20, 0, 100)
InfoBox.Position = UDim2.new(0, 10, 0, 45)
InfoBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InfoBox.Text = "Mencari Nama NPC & Portal..."
InfoBox.TextColor3 = Color3.fromRGB(0, 255, 0)
InfoBox.TextSize = 14
InfoBox.TextWrapped = true
InfoBox.TextXAlignment = Enum.TextXAlignment.Left
InfoBox.TextYAlignment = Enum.TextYAlignment.Top

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 280, 0, 45)
FarmBtn.Position = UDim2.new(0, 20, 0, 155)
FarmBtn.Text = "START AUTO TEST"
FarmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FarmBtn.TextColor3 = Color3.new(1, 1, 1)

-- FUNGSI SCANNER AGRESIF
local function scanEnvironment()
    local npcName = "Belum Ketemu"
    local portalName = "Belum Ketemu"
    local closestDist = 50 -- Scan radius 50 meter
    
    for _, v in pairs(game.Workspace:GetDescendants()) do
        -- 1. Cari NPC berdasarkan "Highlight" (Garis merah di fotomu)
        if v:IsA("Highlight") then
            npcName = v.Parent.Name .. " (Punya Highlight)"
        end
        
        -- 2. Cari Portal berdasarkan nama yang mengandung 'Gate' atau 'Tele'
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("gate") or n:find("room") or n:find("tele") or n:find("dungeon") then
                portalName = v.Name
            end
        end
        
        -- 3. Cari Model terdekat yang punya Health (walau bukan Humanoid)
        if v:IsA("NumberValue") and v.Name:lower():find("health") then
            npcName = v.Parent.Name .. " (Health Detect)"
        end
    end
    
    InfoBox.Text = "HASIL SCAN:\n\nNPC Terdeteksi: " .. npcName .. "\nPortal Terdeteksi: " .. portalName .. "\n\nDekati target agar scan lebih akurat!"
end

-- LOOP SCAN
task.spawn(function()
    while true do
        scanEnvironment()
        task.wait(1)
    end
end)

-- LOGIKA TEST JALAN
FarmBtn.MouseButton1Click:Connect(function()
    print("Testing move to object...")
    -- Jika NPC ketemu, kita coba dekati satu kali sebagai test
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v.Name:find("Luryu") or v:IsA("Highlight") then
            local target = v:IsA("Highlight") and v.Parent:FindFirstChildWhichIsA("BasePart") or v
            if target then
                character.Humanoid:MoveTo(target.Position)
                FarmBtn.Text = "MOVING TO: " .. target.Name
            end
            break
        end
    end
end)
