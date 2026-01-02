local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

-- Fungsi untuk mencari objek bernama "Dungeon"
local function cariDungeon()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        -- Mencari objek yang namanya mengandung kata "Dungeon"
        if string.find(obj.Name, "Dungeon") and obj:IsA("BasePart") then
            return obj
        end
    end
    return nil
end

local target = cariDungeon()

if target then
    local jarak = (root.Position - target.Position).Magnitude
    local kecepatan = 70 -- Kecepatan sesuai permintaanmu
    
    local info = TweenInfo.new(jarak / kecepatan, Enum.EasingStyle.Linear)
    local gerak = TweenService:Create(root, info, {CFrame = target.CFrame})
    
    print("Menemukan: " .. target.Name .. ". Meluncur dengan speed 70...")
    gerak:Play()
    
    gerak.Completed:Connect(function()
        print("Sudah sampai di Dungeon!")
    end)
else
    warn("Objek bernama 'Dungeon' tidak ditemukan di Workspace!")
end
