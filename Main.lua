-- SETTINGS & VARIABLES
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local TweenService = game:GetService("TweenService")

getgenv().autoSearch = false
getgenv().autoClear = false
getgenv().speed = 200

local currentTween

-- FUNGSI GERAK (TWEEN SPEED 200)
local function tweenTo(targetCFrame)
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local info = TweenInfo.new(distance / getgenv().speed, Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(root, info, {CFrame = targetCFrame})
    currentTween:Play()
end

-- FUNGSI SERANG (BRIDGENET2)
local function attack(targetName)
    local args = {
        { { Event = "PunchAttack", Enemy = targetName }, "\4" }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))
end

-- FUNGSI KLIK UI OTOMATIS (JOIN/CREATE)
local function clickButtons()
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return end
    for _, v in pairs(gui:GetDescendants()) do
        if v:IsA("TextButton") and v.Visible then
            local t = v.Text:lower()
            if t:find("create") or t:find("join") or t:find("start") or t:find("enter") then
                local events = {"MouseButton1Click", "Activated"}
                for _, ev in pairs(events) do
                    for _, conn in pairs(getconnections(v[ev])) do conn:Fire() end
                end
            end
        end
    end
end

-- UI POLOS (LIGHTWEIGHT)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 160)
Frame.Position = UDim2.new(0.5, -100, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "ARISE LIGHT FIX"
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)

local SearchBtn = Instance.new("TextButton", Frame)
SearchBtn.Size = UDim2.new(0, 180, 0, 50)
SearchBtn.Position = UDim2.new(0, 10, 0, 40)
SearchBtn.Text = "AUTO SEARCH: OFF"
SearchBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local ClearBtn = Instance.new("TextButton", Frame)
ClearBtn.Size = UDim2.new(0, 180, 0, 50)
ClearBtn.Position = UDim2.new(0, 10, 0, 100)
ClearBtn.Text = "AUTO CLEAR: OFF"
ClearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

-- TOGGLE LOGIC
SearchBtn.MouseButton1Click:Connect(function()
    getgenv().autoSearch = not getgenv().autoSearch
    SearchBtn.Text = getgenv().autoSearch and "SEARCH: ON" or "SEARCH: OFF"
    SearchBtn.BackgroundColor3 = getgenv().autoSearch and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

ClearBtn.MouseButton1Click:Connect(function()
    getgenv().autoClear = not getgenv().autoClear
    ClearBtn.Text = getgenv().autoClear and "CLEAR: ON" or "CLEAR: OFF"
    ClearBtn.BackgroundColor3 = getgenv().autoClear and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end)

-- MAIN LOOP
task.spawn(function()
    while task.wait(0.1) do
        -- 1. SEARCH LOGIC
        if getgenv().autoSearch then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("portal") or v.Name:lower():find("dungeon")) then
                    tweenTo(v.CFrame)
                    clickButtons()
                    break
                end
            end
        end

        -- 2. CLEAR LOGIC (BERDASARKAN STRUKTUR GAME KAMU)
        if getgenv().autoClear then
            local enemyFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
            if enemyFolder then
                local target = nil
                local dist = math.huge
                for _, v in pairs(enemyFolder:GetChildren()) do
                    local hp = v:FindFirstChild("HealthBar") and v.HealthBar.Main.Bar.Amount
                    local hrp = v:FindFirstChild("HumanoidRootPart")
                    if hp and hrp and hp.ContentText ~= "0 HP" then
                        local d = (root.Position - hrp.Position).Magnitude
                        if d < dist then dist = d target = v end
                    end
                end
                if target then
                    tweenTo(target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
                    attack(target.Name)
                end
            end
        end
    end
end)
