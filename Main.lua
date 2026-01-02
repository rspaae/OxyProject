local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local PosLabel = Instance.new("TextLabel")
local CopyButton = Instance.new("TextButton")

-- Setting UI agar muncul di tengah atas layar
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CoordinateFinder"

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0.5, -100, 0.1, 0)
Frame.Size = UDim2.new(0, 200, 0, 80)
Frame.Active = true
Frame.Draggable = true -- Bisa digeser jika menutupi layar

PosLabel.Parent = Frame
PosLabel.Size = UDim2.new(1, 0, 0.5, 0)
PosLabel.Text = "X: 0, Y: 0, Z: 0"
PosLabel.TextColor3 = Color3.new(1, 1, 1)
PosLabel.BackgroundTransparency = 1

CopyButton.Parent = Frame
CopyButton.Position = UDim2.new(0.1, 0, 0.5, 0)
CopyButton.Size = UDim2.new(0.8, 0, 0.4, 0)
CopyButton.Text = "Print & Simpan"
CopyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
CopyButton.TextColor3 = Color3.new(1, 1, 1)

-- Update posisi setiap detik di label
game:GetService("RunService").RenderStepped:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    PosLabel.Text = string.format("X: %.1f, Y: %.1f, Z: %.1f", p.X, p.Y, p.Z)
end)

-- Fungsi saat tombol diklik
CopyButton.MouseButton1Click:Connect(function()
    local p = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    local formattedPos = string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)
    print("KOORDINAT TERCATAT: " .. formattedPos)
    CopyButton.Text = "Tercatat!"
    task.wait(1)
    CopyButton.Text = "Print & Simpan"
end)
