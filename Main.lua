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

    -- Sidebar
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 120, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    local SideCorner = Instance.new("UICorner", Sidebar)
    
    -- Judul Hub
    local Title = Instance.new("TextLabel", Sidebar)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = hubName
    Title.TextColor3 = Theme.Accent
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14

    -- Kontainer Halaman
    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, -130, 1, -10)
    Container.Position = UDim2.new(0, 125, 0, 5)
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
        Instance.new("UICorner", TabBtn)

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
