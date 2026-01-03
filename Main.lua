--[[ 
    ARISE SCRIPT - AUTO REPLAY VERSION
    - Membunuh semua musuh & Bos.
    - Menunggu portal "Dungeon" muncul di LastNpcs.
    - Otomatis "Retry" (Lanjut Dungeon) tanpa ke Lobby.
]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Remote = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

getgenv().AutoLoop = false
getgenv().Speed = 250 -- Kecepatan tween
local currentTween = nil

local function TweenTo(targetCFrame)
    if not Root then return end
    local dist = (Root.Position - targetCFrame.Position).Magnitude
    if dist < 4 then
        if currentTween then currentTween:Cancel(); currentTween = nil end
        return true
    end
    local info = TweenInfo.new(dist / math.max(getgenv().Speed, 1), Enum.EasingStyle.Linear)
    if currentTween then currentTween:Cancel() end
    currentTween = TweenService:Create(Root, info, {CFrame = targetCFrame})
    currentTween:Play()
    return false
end

local function GetTargetEnemy()
    local Enemies = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__Enemies") and workspace.__Main.__Enemies:FindFirstChild("Client")
    local target = nil
    local dMin = math.huge
    if Enemies then
        for _, mob in pairs(Enemies:GetChildren()) do
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
            if hrp and hp and hp.ContentText ~= "0 HP" then
                local d = (Root.Position - hrp.Position).Magnitude
                if d < dMin then dMin = d; target = mob end
            end
        end
    end
    return target
end

-- LOGIKA PORTAL KHUSUS REPLAY
local function FindReplayPortal()
    -- Cek folder LastNpcs sesuai hasil scan F9 kamu
    local LastNpcs = workspace:FindFirstChild("LastNpcs")
    if LastNpcs then
        local p = LastNpcs:FindFirstChild("Dungeon")
        if p and p:IsA("BasePart") then
            return p
        end
    end
    
    -- Fallback: Cari di seluruh workspace jika tidak di LastNpcs
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "Dungeon" then
            -- Pastikan bukan NPC Craft/Shop di Lobby
            local parentName = v.Parent.Name:lower()
            if not parentName:find("craft") and not parentName:find("runeshop") then
                return v
            end
        end
    end
    return nil
end

-- [ BAGIAN UI TETAP MENGGUNAKAN UI SEBELUMNYA ]

task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().AutoLoop then continue end
        
        if not Character or not Character.Parent or not Root then
            Character = Player.Character or Player.CharacterAdded:Wait(); Root = Character:WaitForChild("HumanoidRootPart")
            continue
        end

        local enemy = GetTargetEnemy()

        if enemy then
            -- PRIORITAS 1: BUNUH MUSUH
            local arrived = TweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
            if arrived then
                Remote:FireServer({[1] = {[1] = {["Event"] = "PunchAttack", ["Enemy"] = enemy.Name}, [2] = "\4"}})
            end
        else
            -- PRIORITAS 2: MUSUH HABIS, CARI PORTAL REPLAY/NEXT
            local portal = FindReplayPortal()
            if portal then
                local arrived = TweenTo(portal.CFrame)
                if arrived then
                    -- Trigger Replay/Retry Sequence
                    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "TestEnter"}, [2] = "\4"})
                    task.wait(0.5)
                    Remote:FireServer({[1] = {["Event"] = "DungeonAction", ["Action"] = "Create"}, [2] = "\4"})
                    task.wait(0.5)
                    -- Mencoba start dungeon kembali (Replay)
                    for i = 1, 3 do
                        Remote:FireServer({[1] = {["Dungeon"] = i, ["Event"] = "DungeonAction", ["Action"] = "Start"}, [2] = "\4"})
                    end
                    task.wait(5) -- Tunggu teleport/loading
                end
            end
        end
    end
end)
