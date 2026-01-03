--[[
    SIMPLE OBJECT SCANNER
    Fungsi: Hanya untuk melihat nama objek di sekitar (Radius 50 Studs)
    Output: Cek di Developer Console (Tekan F9)
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui") -- Mencoba akses CoreGui agar UI lebih aman
local Player = Players.LocalPlayer

-- FUNGSI SCANNER UTAMA
local function ScanNearby()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Root = Character:WaitForChild("HumanoidRootPart")

    warn("\n" .. "================ START SCANNING (Radius 50) ================")
    print("Mencari objek di sekitar karakter...")
    
    local count = 0
    local foundObjects = {}

    for _, v in pairs(workspace:GetDescendants()) do
        -- Kita cari Part atau Model yang punya posisi fisik
        if v:IsA("BasePart") or v:IsA("Model") then
            
            -- Filter: Abaikan bagian tubuh sendiri dan terrain
            if v.Parent ~= Character and v.Name ~= "Terrain" and v.Name ~= "Handle" then
                
                -- Dapatkan posisi
                local pos = nil
                if v:IsA("BasePart") then
                    pos = v.Position
                elseif v:IsA("Model") and v.PrimaryPart then
                    pos = v.PrimaryPart.Position
                end

                if pos then
                    local dist = (Root.Position - pos).Magnitude
                    if dist < 50 then -- Radius scan 50 studs
                        -- Cek agar tidak spam nama yang sama berulang kali
                        local uniqueKey = v.Name .. (v.Parent and v.Parent.Name or "NoParent")
                        if not foundObjects[uniqueKey] then
                            count = count + 1
                            -- Format print agar rapi di F9
                            print(string.format("► Jarak: %-4d | NAMA: %-25s | PARENT: %s", math.floor(dist), v.Name, v.Parent.Name))
                            foundObjects[uniqueKey] = true
                        end
                    end
                end
            end
        end
    end
    warn("================ SCAN FINISHED (Ditemukan: " .. count .. ") ================" .. "\n")
end

-- SETUP UI SIMPEL
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleScannerUI"
-- Coba pasang di CoreGui, jika gagal pasang di PlayerGui biasa
if pcall(function() ScreenGui.Parent = CoreGui end) then
    -- Berhasil di CoreGui
else
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame", ScreenGui)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.Position = UDim2.new(0.5, -100, 0.85, 0) -- Posisi di bawah tengah
Frame.Size = UDim2.new(0, 200, 0, 60)
Frame.Active = true
Frame.Draggable = true

local ScanBtn = Instance.new("TextButton", Frame)
ScanBtn.Size = UDim2.new(1, -30, 1, 0)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ScanBtn.Text = "SCAN AREA\n(Buka F9)"
ScanBtn.TextColor3 = Color3.new(1,1,1)
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 16

local CloseBtn = Instance.new("TextButton", Frame)
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18

-- EVENT HANDLER
ScanBtn.MouseButton1Click:Connect(function()
    ScanBtn.Text = "Scanning..."
    ScanBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ScanNearby()
    task.wait(0.5)
    ScanBtn.Text = "SCAN AREA\n(Buka F9)"
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
