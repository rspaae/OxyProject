--[[
    ARISE ULTRA-CLOSE SCANNER
    Radius: 10 Studs (Hanya objek yang ditempel)
    Output: Developer Console (F9)
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

local function ScanNearby()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Root = Character:WaitForChild("HumanoidRootPart")

    warn("\n" .. "=== SCANNING (RADIUS 10 STUDS) ===")
    
    local foundObjects = {}
    local count = 0

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            if v.Parent ~= Character and v.Name ~= "Terrain" and v.Name ~= "Handle" then
                
                local pos = nil
                if v:IsA("BasePart") then pos = v.Position
                elseif v:IsA("Model") and v.PrimaryPart then pos = v.PrimaryPart.Position end

                if pos then
                    local dist = (Root.Position - pos).Magnitude
                    
                    -- HANYA 10 STUDS (Sangat Dekat)
                    if dist <= 10 then 
                        local parentName = v.Parent and v.Parent.Name or "NoParent"
                        local uniqueKey = v.Name .. parentName
                        
                        if not foundObjects[uniqueKey] then
                            count = count + 1
                            -- Print dengan format jelas
                            print(string.format(">> [JARAK: %d] Nama: %-20s | Parent: %s", math.floor(dist), v.Name, parentName))
                            foundObjects[uniqueKey] = true
                        end
                    end
                end
            end
        end
    end
    
    if count == 0 then
        warn(">> Tidak ada objek ditemukan. Coba tempelkan badan lebih dekat!")
    else
        warn("=== SELESAI (Ditemukan: " .. count .. ") ===" .. "\n")
    end
end

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
if pcall(function() ScreenGui.Parent = CoreGui end) then else ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

local Frame = Instance.new("Frame", ScreenGui)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0.5, -100, 0.85, 0)
Frame.Size = UDim2.new(0, 200, 0, 50)
Frame.Active = true; Frame.Draggable = true

local ScanBtn = Instance.new("TextButton", Frame)
ScanBtn.Size = UDim2.new(1, -30, 1, 0)
ScanBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0) -- Warna Oranye biar beda
ScanBtn.Text = "SCAN (RADIUS 10)"
ScanBtn.TextColor3 = Color3.new(0,0,0)
ScanBtn.Font = Enum.Font.SourceSansBold
ScanBtn.TextSize = 16

local CloseBtn = Instance.new("TextButton", Frame)
CloseBtn.Size = UDim2.new(0, 30, 1, 0); CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.new(1,1,1)

ScanBtn.MouseButton1Click:Connect(function() ScanNearby() end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
