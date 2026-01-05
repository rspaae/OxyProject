--[[ 
    ARISE FINAL - FIX TWEEN BUG
    Perbaikan khusus untuk bug "Attacking NPC" tapi tidak tween
]]

-- 1. GANTI FUNGSI TWEEN DENGAN VERSI YANG LEBIH STABIL
local function TweenTo(targetCFrame, timeout)
    if not Root or not targetCFrame then 
        warn("Root atau targetCFrame tidak valid")
        return false 
    end
    
    -- Cek apakah Root masih ada dan valid
    if not Root:IsDescendantOf(workspace) then
        warn("Root tidak ada di workspace")
        return false
    end
    
    local dist = (Root.Position - targetCFrame.Position).Magnitude
    
    -- Jika sudah dekat, tidak perlu tween
    if dist < 8 then 
        Root.CFrame = CFrame.new(Root.Position, targetCFrame.Position) * CFrame.new(0, 0, -3)
        return true 
    end
    
    -- Batasi jarak maksimal
    if dist > 1000 then
        warn("Jarak terlalu jauh: " .. dist)
        return false
    end
    
    local success = false
    local tweenCompleted = false
    
    pcall(function()
        -- Hitung waktu tween berdasarkan speed
        local travelTime = dist / getgenv().Speed
        travelTime = math.clamp(travelTime, 0.5, 5) -- Batasi antara 0.5-5 detik
        
        local info = TweenInfo.new(
            travelTime,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out,
            0,
            false,
            0
        )
        
        -- Target CFrame dengan offset
        local targetPos = targetCFrame.Position
        local lookAt = CFrame.new(Root.Position, targetPos)
        local finalCFrame = lookAt + (targetPos - Root.Position).Unit * math.min(dist - 3, 100)
        
        local tw = TweenService:Create(Root, info, {CFrame = finalCFrame})
        
        tw.Completed:Connect(function()
            tweenCompleted = true
            success = true
        end)
        
        tw:Play()
        
        -- Timeout handling
        local startTime = tick()
        while tick() - startTime < (timeout or travelTime + 2) do
            if tweenCompleted then break end
            task.wait(0.1)
            
            -- Safety check: jika karakter mati selama tween
            if not Root or not Root:IsDescendantOf(workspace) then
                tw:Cancel()
                return false
            end
        end
        
        if not tweenCompleted then
            tw:Cancel()
            warn("Tween timeout")
            -- Teleport langsung jika tween gagal
            if dist < 100 then
                Root.CFrame = CFrame.new(targetCFrame.Position + Vector3.new(0, 3, 0), targetCFrame.Position)
                success = true
            end
        end
    end)
    
    return success
end

-- 2. PERBAIKI FUNGSI GET ENEMY UNTUK PASTIKAN POSISI VALID
local function GetEnemy()
    local client = workspace:FindFirstChild("__Main") 
    and workspace.__Main:FindFirstChild("__Enemies") 
    and workspace.__Main.__Enemies:FindFirstChild("Client")
    
    if not client then return nil end
    
    local closestEnemy = nil
    local closestDist = math.huge
    
    for _, mob in pairs(client:GetChildren()) do
        if mob:IsA("Model") then
            local humanoidRootPart = mob:FindFirstChild("HumanoidRootPart")
            local hp = mob:FindFirstChild("HealthBar") and mob.HealthBar.Main.Bar.Amount
            
            if humanoidRootPart and hp then
                -- Filter HP lebih baik
                local hpText = hp.ContentText
                if hpText and hpText ~= "0 HP" and hpText ~= "" then
                    -- Cek apakah NPC masih hidup
                    local humanoid = mob:FindFirstChildOfClass("Humanoid")
                    if not humanoid or humanoid.Health > 0 then
                        -- Hitung jarak
                        local dist = (Root.Position - humanoidRootPart.Position).Magnitude
                        if dist < closestDist and dist < 500 then -- Batasi jarak maksimal
                            closestDist = dist
                            closestEnemy = mob
                        end
                    end
                end
            end
        end
    end
    
    return closestEnemy
end

-- 3. FUNGSI ATTACK YANG DIPERBAIKI
local function AttackEnemy(enemy)
    if not enemy then return false end
    
    local humanoidRootPart = enemy:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    -- Debug: tampilkan info NPC
    print("Attacking NPC:", enemy.Name)
    print("NPC Position:", humanoidRootPart.Position)
    print("Our Position:", Root.Position)
    
    -- Coba tween ke NPC
    local tweenSuccess = TweenTo(humanoidRootPart.CFrame * CFrame.new(0, 0, 4), 3)
    
    if tweenSuccess then
        -- Tunggu sebentar setelah tween
        task.wait(0.2)
        
        -- Serang NPC
        Remote:FireServer({
            [1] = {
                [1] = {
                    ["Event"] = "PunchAttack", 
                    ["Enemy"] = enemy.Name
                }, 
                [2] = "\4"
            }
        })
        
        -- Attack multiple times
        for i = 1, 2 do
            task.wait(0.1)
            Remote:FireServer({
                [1] = {
                    [1] = {
                        ["Event"] = "PunchAttack", 
                        ["Enemy"] = enemy.Name
                    }, 
                    [2] = "\4"
                }
            })
        end
        
        return true
    else
        -- Jika tween gagal, coba teleport atau attack dari jarak jauh
        warn("Tween gagal, coba attack dari jarak jauh")
        
        local dist = (Root.Position - humanoidRootPart.Position).Magnitude
        if dist < 100 then
            Remote:FireServer({
                [1] = {
                    [1] = {
                        ["Event"] = "PunchAttack", 
                        ["Enemy"] = enemy.Name
                    }, 
                    [2] = "\4"
                }
            })
            return true
        end
    end
    
    return false
end

-- 4. MODIFIKASI MAIN LOOP UNTUK HANDLE TWEEN BUG
task.spawn(function()
    local lastDungeonSearchTime = 0
    local dungeonSearchCooldown = 5
    local consecutiveNoEnemyCount = 0
    local lastAttackTime = 0
    local tweenFailCount = 0
    
    while task.wait(0.3) do -- Ubah jadi 0.3 detik untuk respons lebih cepat
        if getgenv().AutoLoop then
            -- Update status connection
            if not Root or not Root:IsDescendantOf(workspace) then
                -- Karakter mati atau respawn
                Character = Player.Character or Player.CharacterAdded:Wait()
                Root = Character:WaitForChild("HumanoidRootPart")
                StatusLabel.Text = "Status: CHARACTER RESPAWNED"
                task.wait(2)
                continue
            end
            
            local currentTime = tick()
            local enemy = GetEnemy()
            
            if enemy then
                local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                
                if enemyRoot then
                    -- Debug info
                    local dist = (Root.Position - enemyRoot.Position).Magnitude
                    print("Enemy found:", enemy.Name, "Distance:", dist)
                    
                    -- Jika NPC terlalu jauh, reset fail count
                    if dist > 200 then
                        tweenFailCount = 0
                    end
                    
                    -- Coba attack
                    StatusLabel.Text = "Status: ATTACKING " .. enemy.Name
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                    
                    local attackSuccess = AttackEnemy(enemy)
                    
                    if attackSuccess then
                        lastAttackTime = currentTime
                        tweenFailCount = 0
                        consecutiveNoEnemyCount = 0
                        
                        -- Tampilkan sukses
                        StatusLabel.Text = "Status: ATTACK SUCCESS"
                        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    else
                        tweenFailCount = tweenFailCount + 1
                        StatusLabel.Text = "Status: ATTACK FAILED (" .. tweenFailCount .. ")"
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        
                        -- Jika terlalu banyak gagal, coba reset
                        if tweenFailCount >= 5 then
                            StatusLabel.Text = "Status: RESETTING POSITION"
                            -- Coba teleport ke spawn point atau safe location
                            task.wait(1)
                            tweenFailCount = 0
                        end
                    end
                    
                    -- Tunggu sebentar sebelum cari NPC lain
                    task.wait(0.5)
                else
                    consecutiveNoEnemyCount = consecutiveNoEnemyCount + 1
                end
            else
                consecutiveNoEnemyCount = consecutiveNoEnemyCount + 1
                tweenFailCount = 0
                
                -- Cek apakah perlu cari dungeon
                if consecutiveNoEnemyCount >= 6 then
                    StatusLabel.Text = "Status: NO NPC - SEARCHING"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    
                    -- Logika cari dungeon tetap sama...
                    -- ... [kode mencari dungeon]
                end
            end
        end
    end
end)

-- 5. FUNGSI UTAMA UNTUK FORCE TELEPORT JIKA TWEEN STUCK
local function ForceTeleportTo(position)
    if not Root then return false end
    
    pcall(function()
        -- Gunakan CFrame langsung
        Root.CFrame = CFrame.new(position)
        
        -- Jika tidak bisa, coba dengan humanoid
        if Character and Character:FindFirstChild("Humanoid") then
            Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.1)
            Root.CFrame = CFrame.new(position)
        end
    end)
    
    return true
end

-- 6. TAMBAHKAN DEBUG BUTTON DI UI
local DebugBtn = Instance.new("TextButton", Content)
DebugBtn.Text = "DEBUG: FORCE STOP TWEEN"
DebugBtn.Size = UDim2.new(0, 230, 0, 30)
DebugBtn.Position = UDim2.new(0, 10, 0, 180)
DebugBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
DebugBtn.TextColor3 = Color3.new(1,1,1)

DebugBtn.MouseButton1Click:Connect(function()
    -- Cancel semua tween yang aktif
    pcall(function()
        for _, conn in pairs(getconnections(Root.Changed)) do
            -- Coba hentikan tween
            conn:Disable()
        end
    end)
    
    -- Reset position ke tempat aman
    local safePosition = Vector3.new(0, 10, 0)
    ForceTeleportTo(safePosition)
    
    StatusLabel.Text = "Status: DEBUG - RESET"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
end)

print("ARISE FINAL Script Loaded dengan perbaikan TWEEN BUG!")
print("Speed:", getgenv().Speed)
print("Auto Loop:", getgenv().AutoLoop)
