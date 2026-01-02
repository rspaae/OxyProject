-- =========================================================
-- [ FILE UTAMA: main.lua ]
-- =========================================================
-- Petunjuk: Simpan semua kode ini di GitHub, lalu panggil
-- menggunakan loadstring(game:HttpGet("LINK_RAW"))()
-- =========================================================

-- [[ 1. KONFIGURASI & THEME ]] --
local Theme = {
    Main = Color3.fromRGB(30, 30, 30),
    Sidebar = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(0, 150, 255),
    Text = Color3.fromRGB(255, 255, 255)
}

-- [[ 2. UI LIBRARY (MODUL GUI) ]] --
local Library = {}

function Library:Init(hubName)
    local CoreGui = game:GetService("CoreGui")
    
    -- Anti-Duplikasi (Hapus GUI lama jika ada)
    if CoreGui:FindFirstChild("MyOxygenHub") then
        CoreGui.MyOxygenHub:Destroy()
    end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "MyOxygenHub"

    -- Frame Utama
    local MainFrame = Instance.new("Frame", Screen)
    MainFrame.Size = UDim2.new(0, 450, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    MainFrame.BackgroundColor3 = Theme.Main
    MainFrame.BorderSizePixel = 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    -- Header Bar untuk Drag & Tombol
    local HeaderBar = Instance.new("Frame", MainFrame)
    HeaderBar.Size = UDim2.new(1, 0, 0, 35)
    HeaderBar.BackgroundColor3 = Theme.Sidebar
    HeaderBar.BorderSizePixel = 0
    Instance.new("UICorner", HeaderBar).CornerRadius = UDim.new(0, 8)

    -- Drag Area (Blok sejajar untuk drag)
    local DragArea = Instance.new("TextButton", HeaderBar)
    DragArea.Size = UDim2.new(1, -70, 1, 0)
    DragArea.Position = UDim2.new(0, 0, 0, 0)
    DragArea.BackgroundColor3 = Theme.Sidebar
    DragArea.TextTransparency = 1
    DragArea.BorderSizePixel = 0
    DragArea.AutoButtonColor = false

    -- Judul di Header
    local HeaderTitle = Instance.new("TextLabel", DragArea)
    HeaderTitle.Size = UDim2.new(1, 0, 1, 0)
    HeaderTitle.Text = hubName
    HeaderTitle.TextColor3 = Theme.Accent
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 14
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Position = UDim2.new(0, 10, 0, 0)

    -- Tombol Minimize
    local MinimizeBtn = Instance.new("TextButton", HeaderBar)
    MinimizeBtn.Size = UDim2.new(0, 30, 1, 0)
    MinimizeBtn.Position = UDim2.new(1, -70, 0, 0)
    MinimizeBtn.BackgroundColor3 = Theme.Accent
    MinimizeBtn.TextColor3 = Theme.Main
    MinimizeBtn.Text = "−"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 18
    MinimizeBtn.BorderSizePixel = 0
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

    -- Tombol Close
    local CloseBtn = Instance.new("TextButton", HeaderBar)
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.TextColor3 = Theme.Text
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.BorderSizePixel = 0
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    -- Minimize Logic
    local isMinimized = false
    local originalSize = MainFrame.Size
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            MainFrame.Size = UDim2.new(0, 450, 0, 35)
            MinimizeBtn.Text = "+"
            Container.Visible = false
            Sidebar.Visible = false
        else
            MainFrame.Size = originalSize
            MinimizeBtn.Text = "−"
            Container.Visible = true
            Sidebar.Visible = true
        end
    end)

    -- Close Logic
    CloseBtn.MouseButton1Click:Connect(function()
        Screen:Destroy()
    end)

    -- Drag Logic
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart = Vector2.new(0, 0)
    local frameStart = UDim2.new(0, 0, 0, 0)

    DragArea.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = UserInputService:GetMouseLocation()
            frameStart = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local currentMouse = UserInputService:GetMouseLocation()
            local delta = currentMouse - dragStart
            MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 120, 1, -35)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    local SideCorner = Instance.new("UICorner", Sidebar)
    
    -- Kontainer Halaman
    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, -130, 1, -45)
    Container.Position = UDim2.new(0, 125, 0, 40)
    Container.BackgroundTransparency = 1

    local Elements = {}

    function Elements:CreateTab(name)
        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        
        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0, 5)

        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(0.9, 0, 0, 30)
        TabBtn.Position = UDim2.new(0.05, 0, 0, 50) -- Perlu sistem list otomatis sebenarnya
        TabBtn.Text = name
        TabBtn.BackgroundColor3 = Theme.Main
        TabBtn.TextColor3 = Theme.Text
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.BorderSizePixel = 0
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            Page.Visible = true
        end)

        local TabFunctions = {}
        function TabFunctions:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, -10, 0, 35)
            Btn.BackgroundColor3 = Theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Theme.Text
            Btn.Font = Enum.Font.GothamSemibold
            Instance.new("UICorner", Btn)
            
            Btn.MouseButton1Click:Connect(callback)
        end

        return TabFunctions
    end

    return Elements
end

-- [[ 3. LOGIKA SISTEM (LOGIC) ]] --
local Logic = {}

function Logic:SearchScriptBlox(q)
    -- Simulasi koneksi API
    print("Mencari di ScriptBlox: " .. q)
    -- Disini nanti tempat HttpGet ke ScriptBlox
end

function Logic:SetSpeed(s)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = s
    end
end

-- [[ 4. EKSEKUSI (MENGHUBUNGKAN GUI & LOGIKA) ]] --
local UI = Library:Init("OXYGEN-U HUB")

-- Tab Beranda
local Home = UI:CreateTab("General")
Home:AddButton("Speed 100", function()
    Logic:SetSpeed(100)
end)
Home:AddButton("Reset Speed", function()
    Logic:SetSpeed(16)
end)

-- Tab ScriptBlox
local ScriptBox = UI:CreateTab("ScriptBlox")
ScriptBox:AddButton("Cari Blox Fruits", function()
    Logic:SearchScriptBlox("Blox Fruits")
end)

print("Berhasil memuat Script Terpadu!")
