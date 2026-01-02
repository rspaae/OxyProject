local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local root = player.Character:WaitForChild("HumanoidRootPart")

-- KONFIGURASI
local NAMA_TARGET = "Dungeon" 
local TEKS_TOMBOL_1 = "Create" -- Mencari tombol yang ada tulisan "Create"
local TEKS_TOMBOL_2 = "Join"   -- Mencari tombol yang ada tulisan "Join"
local SPEED_TWEEN = 200       

-- Fungsi Klik berdasarkan TEKS yang terlihat di tombol
local function klikBerdasarkanTeks(targetText)
    local pGui = player:WaitForChild("PlayerGui")
    for _, v in pairs(pGui:GetDescendants()) do
        -- Cek apakah ini tombol dan apakah teksnya cocok
        if v:IsA("TextButton") or v:IsA("TextLabel") then
            local objectText = v:IsA("TextButton") and v.Text or v.Parent:IsA("TextButton") and v.Parent.Text or ""
            
            if string.find(string.lower(v.Text), string.lower(targetText)) then
                local realButton = v:IsA("TextButton") and v or v.Parent
                
                if realButton:IsA("TextButton") then
                    -- Simulasi klik
                    local connections = getconnections(realButton.MouseButton1Click)
                    for _, connection in pairs(connections) do
                        connection:Fire()
                    end
                    return true
                end
            end
        end
    end
    return false
end

-- Fungsi Cari Objek
local function cariObjek()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), string.lower(NAMA_TARGET)) and obj:IsA("BasePart") then
            return obj
        end
    end
    return nil
end

-- JALANKAN
local target = cariObjek()
if target then
    local jarak = (root.Position - target.Position).Magnitude
    local tween = TweenService:Create(root, TweenInfo.new(jarak / SPEED_TWEEN, Enum.EasingStyle.Linear), {CFrame = target.CFrame})
    
    print("Meluncur ke Dungeon...")
    tween:Play()
    
    tween.Completed:Connect(function()
        task.wait(0.5) -- Beri waktu UI muncul
        
        -- Coba klik tombol yang ada tulisan "Create"
        local ok1 = klikBerdasarkanTeks(TEKS_TOMBOL_1)
        if ok1 then
            print("Berhasil klik tombol Create!")
            
            -- Tunggu dan klik tombol yang ada tulisan "Join"
            local start = tick()
            repeat
                task.wait(0.5)
                local ok2 = klikBerdasarkanTeks(TEKS_TOMBOL_2)
            until ok2 or (tick() - start > 5)
        else
            print("Gagal menemukan tombol dengan teks Create. Coba cek ejaan atau bahasa game.")
        end
    end)
end
