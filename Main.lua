local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

-- Koordinat dari foto yang kamu kirim
local targetPos = Vector3.new(460.7, 28.9, 46.6) 

local function mulaiTween(dest)
    local distance = (root.Position - dest).Magnitude
    
    -- Kecepatan diatur ke 70 sesuai permintaanmu
    local speed = 70 
    
    local info = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(dest)}
    
    local tween = TweenService:Create(root, info, goal)
    
    print("Meluncur dengan kecepatan pelan (70)...")
    tween:Play()
    
    tween.Completed:Connect(function()
        print("Sampai di tujuan dengan selamat!")
    end)
end

-- Jalankan pergerakan otomatis
mulaiTween(targetPos)

