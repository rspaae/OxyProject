-- SETTINGS & VARIABLES
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")
local VirtualUser = game:GetService("VirtualUser")

local searchDungeonActive = false
local autoFarmActive = false
local fastSpeed = 200

-- UI SETUP (WIDE UI)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 250) -- Ukuran ditambah untuk Name Spy
MainFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Draggable = true
MainFrame.Active = true

local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Text = "  ARISE HUB + NAME SPY"
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.SourceSansBold

-- NAME SPY DISPLAY (Kotak Info Nama)
local SpyFrame = Instance.new("Frame", MainFrame)
SpyFrame.Size = UDim2.new(0, 270, 0, 50)
SpyFrame.Position = UDim2.new(0, 15, 0, 45)
SpyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local SpyText = Instance.new("TextLabel", SpyFrame)
SpyText.Size = UDim2.new(1, -10, 1, 0)
SpyText.Position = UDim2.new(0, 5, 0, 0)
SpyText.Text = "Scanning for targets..."
SpyText.TextColor3 = Color3.fromRGB(0, 255, 150)
SpyText.TextScaled = true
SpyText.BackgroundTransparency = 1
SpyText.Font = Enum.Font.Code

-- BUTTONS
local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 270, 0, 45)
FarmBtn.Position = UDim2.new(0, 15, 0, 105)
FarmBtn.Text = "AUTO FARM NPC: OFF"
FarmBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FarmBtn.TextColor3 = Color3.new(1, 1, 1)

local SearchBtn = Instance.new("TextButton", MainFrame)
SearchBtn.Size = UDim2.new(0, 270, 0, 45)
SearchBtn.Position = UDim2.new(0, 15, 0, 155)
SearchBtn.Text = "SEARCH DUNGEON: OFF"
SearchBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SearchBtn.TextColor3 = Color3.new(1, 1, 1)

-- FUNGSI DETEKSI & SPY
local function updateSpy()
    local closest, dist = "None", math.huge
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= character and v.Health > 0 then
            local p = v.Parent:FindFirstChild("HumanoidRootPart") or v.Parent:FindFirstChild("Torso")
            if p then
                local d = (root.Position - p.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = v.Parent.Name -- Ambil nama NPC
                end
            end
        end
    end
    SpyText.Text = "Closest NPC: " .. closest
    return closest
end

local function getAnyTarget()
    local target, dist = nil, math.huge
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= character and v.Health > 0 then
            local npcPart = v.Parent:FindFirstChild("HumanoidRootPart") or v.Parent:FindFirstChild("Torso")
            if npcPart then
                local d = (root.Position - npcPart.Position).Magnitude
                if d < dist then dist = d target = npcPart end
            end
        end
    end
    return target
end

-- LOOP UTAMA
task.spawn(function()
    while true do
        local currentName = updateSpy() -- Update Name Spy setiap detik
        
        if autoFarmActive then
            humanoid.WalkSpeed = fastSpeed
            local npc = getAnyTarget()
            if npc then
                humanoid:MoveTo(npc.Position)
                VirtualUser:Button1Down(Vector2.new(0,0))
            end
        elseif searchDungeonActive then
            humanoid.WalkSpeed = fastSpeed
            -- Cari portal berdasarkan nama umum
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("portal") or v.Name:lower():find("dungeon")) then
                    humanoid:MoveTo(v.Position)
                    break
                end
            end
        else
            humanoid.WalkSpeed = 16
        end
        task.wait(0.2)
    end
end)

-- TOGGLES
FarmBtn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    FarmBtn.Text = autoFarmActive and "FARM: ON" or "FARM: OFF"
    FarmBtn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
end)

SearchBtn.MouseButton1Click:Connect(function()
    searchDungeonActive = not searchDungeonActive
    SearchBtn.Text = searchDungeonActive and "SEARCH: ON" or "SEARCH: OFF"
    SearchBtn.BackgroundColor3 = searchDungeonActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
end)
