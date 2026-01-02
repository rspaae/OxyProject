local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

-- KONFIGURASI --
local NAMA_TARGET = "Dungeon" 
local TOMBOL_1 = "Create"     -- Tombol pertama
local TOMBOL_2 = "Join"       -- Tombol kedua
local SPEED_TWEEN = 200       -- Kecepatan ditingkatkan menjadi 200

-- Fungsi Klik Tombol berdasarkan Nama
local function klikTombol(namaTombol)
    local pGui = player:WaitForChild("PlayerGui")
    for _, v in pairs(pGui:GetDescendants()) do
        if v.Name == namaTombol and v:IsA("TextButton") and v.Visible then
            -- Simulasi klik untuk Delta/Executor
            local connections = getconnections(v.MouseButton1Click)
            for _, connection in pairs(connections) do
                connection:Fire()
            end
            return true
        end
    end
    return false
end

-- Fungsi Cari Objek Dungeon
local function cariObjek()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), string.lower(NAMA_TARGET)) and obj:IsA("BasePart") then
            return obj
        end
    end
    return nil
end

-- LOGIKA UTAMA
local target = cariObjek()

if target then
    local jarak = (root.Position - target.Position).Magnitude
    local info = TweenInfo.new(jarak / SPEED_TWEEN, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, info, {CFrame = target.CFrame})
    
    print("Meluncur ke Dungeon (Speed 200)...")
    tween:Play()
    
    tween.Completed:Connect(function()
        print("Sampai! Menekan tombol Create...")
        
        -- Tahap 1: Klik Create
        task.wait(0.3) -- Jeda lebih singkat karena speed tinggi
        local suksesCreate = klikTombol(TOMBOL_1)
        
        if suksesCreate then
            print("Berhasil klik Create, menunggu tombol Join...")
            
            -- Tahap 2: Tunggu dan Klik Join
            local start = tick()
            repeat
                task.wait(0.2)
                local suksesJoin = klikTombol(TOMBOL_2)
            until suksesJoin or (tick() - start > 5)
            
            if suksesJoin then
                print("Berhasil masuk ke Dungeon!")
            end
        else
            warn("Tombol Create tidak ditemukan!")
        end
    end)
else
    warn("Objek Dungeon tidak ditemukan!")
end
