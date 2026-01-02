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
    local UserInputService = game:GetService("UserInputService")
    
    -- Anti-Duplikasi
    if CoreGui:FindFirstChild("MyOxygenHub") then
        CoreGui.MyOxygenHub:Destroy()
    end

    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "MyOxygenHub"
    Screen.ResetOnSpawn = false

    -- Frame Utama
    local MainFrame = Instance.new("Frame", Screen)
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = Theme.Main
    MainFrame.BorderSizePixel = 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    -- Header Bar
    local HeaderBar = Instance.new("Frame", MainFrame)
    HeaderBar.Size = UDim2.new(1, 0, 0, 35)
    HeaderBar.BackgroundColor3 = Theme.Sidebar
    HeaderBar.BorderSizePixel = 0
    Instance.new("UICorner", HeaderBar).CornerRadius = UDim.new(0, 8)

    -- Judul Header
    local HeaderTitle = Instance.new("TextLabel", HeaderBar)
    HeaderTitle.Size = UDim2.new(1, -70, 1, 0)
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
    MinimizeBtn.AutoButtonColor = false
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
    CloseBtn.AutoButtonColor = false
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    -- Content Area (Halaman Tunggal)
    local ContentArea = Instance.new("ScrollingFrame", MainFrame)
    ContentArea.Size = UDim2.new(1, 0, 1, -35)
    ContentArea.Position = UDim2.new(0, 0, 0, 35)
    ContentArea.BackgroundColor3 = Theme.Main
    ContentArea.BorderSizePixel = 0
    ContentArea.ScrollBarThickness = 5
    ContentArea.CanvasSize = UDim2.new(1, 0, 0, 0)

    local Layout = Instance.new("UIListLayout", ContentArea)
    Layout.Padding = UDim.new(0, 10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Drag Logic
    local dragging = false
    local dragStart = Vector2.new(0, 0)
    local frameStart = UDim2.new(0, 0, 0, 0)

    HeaderBar.InputBegan:Connect(function(input, gameProcessed)
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

    -- Minimize Logic
    local isMinimized = false
    local originalSize = MainFrame.Size
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            MainFrame.Size = UDim2.new(0, 500, 0, 35)
            MinimizeBtn.Text = "+"
            ContentArea.Visible = false
        else
            MainFrame.Size = originalSize
            MinimizeBtn.Text = "−"
            ContentArea.Visible = true
        end
    end)

    -- Close Logic
    CloseBtn.MouseButton1Click:Connect(function()
        Screen:Destroy()
    end)

    -- Elements untuk menambah konten
    local Elements = {}

    function Elements:AddSection(title)
        local Section = Instance.new("Frame", ContentArea)
        Section.Size = UDim2.new(1, 0, 0, 0)
        Section.BackgroundColor3 = Theme.Sidebar
        Section.BorderSizePixel = 0
        Section.LayoutOrder = #ContentArea:GetChildren()
        Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 6)

        local SectionTitle = Instance.new("TextLabel", Section)
        SectionTitle.Size = UDim2.new(1, 0, 0, 25)
        SectionTitle.Text = title
        SectionTitle.TextColor3 = Theme.Accent
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.Font = Enum.Font.GothamSemibold
        SectionTitle.TextSize = 12

        local SectionLayout = Instance.new("UIListLayout", Section)
        SectionLayout.Padding = UDim.new(0, 8)
        SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local SectionFunctions = {}
        function SectionFunctions:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Section)
            Btn.Size = UDim2.new(1, -10, 0, 35)
            Btn.Position = UDim2.new(0, 5, 0, 0)
            Btn.BackgroundColor3 = Theme.Accent
            Btn.Text = text
            Btn.TextColor3 = Theme.Main
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 11
            Btn.BorderSizePixel = 0
            Btn.AutoButtonColor = false
            Btn.LayoutOrder = #Section:GetChildren()
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

            -- Hover Effect
            Btn.MouseEnter:Connect(function()
                Btn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            end)
            Btn.MouseLeave:Connect(function()
                Btn.BackgroundColor3 = Theme.Accent
            end)

            Btn.MouseButton1Click:Connect(callback)
        end

        -- Update ukuran section
        local function updateSectionSize()
            local totalHeight = 35
            for _, child in pairs(Section:GetChildren()) do
                if child:IsA("TextButton") then
                    totalHeight = totalHeight + 35 + 8
                end
            end
            Section.Size = UDim2.new(1, -10, 0, totalHeight)
        end

        -- Update canvas size
        local function updateCanvasSize()
            local totalHeight = 10
            for _, child in pairs(ContentArea:GetChildren()) do
                if child:IsA("Frame") then
                    totalHeight = totalHeight + child.Size.Y.Offset + 10
                end
            end
            ContentArea.CanvasSize = UDim2.new(1, 0, 0, totalHeight)
        end

        game:GetService("RunService").Heartbeat:Connect(updateSectionSize)
        game:GetService("RunService").Heartbeat:Connect(updateCanvasSize)

        return SectionFunctions
    end

    return Elements
end

-- [[ 3. LOGIKA SISTEM (LOGIC) ]] --
local Logic = {}

function Logic:SetSpeed(s)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = s
    end
end

-- [[ 4. EKSEKUSI ]] --
local UI = Library:Init("OXYGEN-U HUB")

-- Section 1: General
local General = UI:AddSection("⚙️ General")
General:AddButton("Speed 100", function()
    Logic:SetSpeed(100)
end)
General:AddButton("Speed 50", function()
    Logic:SetSpeed(50)
end)
General:AddButton("Reset Speed", function()
    Logic:SetSpeed(16)
end)

-- Section 2: ScriptBlox
local ScriptBox = UI:AddSection("📚 ScriptBlox")
ScriptBox:AddButton("Blox Fruits", function()
    print("Loading Blox Fruits Script...")
end)
ScriptBox:AddButton("Anime Fighting", function()
    print("Loading Anime Fighting Script...")
end)

-- Section 3: Settings
local Settings = UI:AddSection("⚙️ Settings")
Settings:AddButton("Toggle Visibility", function()
    print("Toggle visibility feature")
end)

print("Berhasil memuat Script Terpadu!")
