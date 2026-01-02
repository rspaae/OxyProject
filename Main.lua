-- SETTINGS & VARIABLES
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")
local running = false

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DungeonAutoV3"

-- Hamburger Button (Minimize Mode)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 40, 0, 40)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -20)
OpenBtn.Text = "☰"
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Visible = false

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Active = true
MainFrame.Draggable = true

-- Header Buttons
local MiniBtn = Instance.new("TextButton", MainFrame)
MiniBtn.Size = UDim2.new(0, 30, 0, 30)
MiniBtn.Position = UDim2.new(1, -60, 0, 0)
MiniBtn.Text = "_"
MiniBtn.TextColor3 = Color3.new(1, 1, 1)
MiniBtn.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0, 200, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0, 60)
ToggleBtn.Text = "AUTO FARM: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.SourceSansBold

-- FUNGSI SMART CLICK (Create & Join)
local function clickByText(txt)
    local pGui = player:WaitForChild("PlayerGui")
    for _, v in pairs(pGui:GetDescendants()) do
        if (v:IsA("TextButton") or v:IsA("TextLabel")) and string.find(string.lower(v.Text or ""), string.lower(txt)) then
            local btn = v:IsA("TextButton") and v or v.Parent
            if btn:IsA("TextButton") then
                local conns = getconnections(btn.MouseButton1Click)
                for _, conn in pairs(conns) do conn:Fire() end
                return true
            end
        end
    end
    return false
end

-- FUNGSI MENCARI NPC
local function getClosestNPC()
    local closest = nil
    local dist = math.huge
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v ~= player.Character then
            if v.Humanoid.Health > 0 then
                local d = (root.Position - v.HumanoidRootPart.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = v.HumanoidRootPart
                end
            end
        end
    end
    return closest
end

-- FUNGSI MENCARI PORTAL (Nama: Dungeon)
local function getPortal()
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if string.find(string.lower(v.Name), "dungeon") and v:IsA("BasePart") then
            return v
        end
    end
    return nil
end

-- LOGIKA UTAMA
local function startLogic()
    while running do
        local targetNPC = getClosestNPC()
        
        if targetNPC then
            -- 1. PRIORITAS: Kejar NPC
            local d = (root.Position - targetNPC.Position).Magnitude
            local t = TweenService:Create(root, TweenInfo.new(d/200, Enum.EasingStyle.Linear), {CFrame = targetNPC.CFrame * CFrame.new(0, 0, 3)})
            t:Play()
            t.Completed:Wait()
            task.wait(0.3) 
        else
            -- 2. JIKA HABIS: Cari Portal "Dungeon"
            local portal = getPortal()
            if portal then
                print("NPC Habis, meluncur ke Portal Dungeon...")
                local d = (root.Position - portal.Position).Magnitude
                local t = TweenService:Create(root, TweenInfo.new(d/200, Enum.EasingStyle.Linear), {CFrame = portal.CFrame})
                t:Play()
                t.Completed:Wait()
                
                -- Mencoba klik otomatis setelah sampai di portal
                task.wait(0.5)
                if clickByText("Create") then
                    local start = tick()
                    repeat task.wait(0.5) until clickByText("Join") or tick() - start > 5 or not running
                end
            end
        end
        task.wait(0.5)
    end
end

-- UI ACTIONS
ToggleBtn.MouseButton1Click:Connect(function()
    running = not running
    ToggleBtn.Text = running and "AUTO FARM: ON" or "AUTO FARM: OFF"
    ToggleBtn.BackgroundColor3 = running and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
    if running then task.spawn(startLogic) end
end)

MiniBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true OpenBtn.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function() running = false ScreenGui:Destroy() end)
