-- ui.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local UI = {}

function UI.create(utils, toggleCallback, closeCallback)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ENIAutoBuyGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    
    -- Cleanup existing GUI
    pcall(function()
        for _, child in ipairs(PlayerGui:GetChildren()) do
            if child.Name == "ENIAutoBuyGui" and child ~= ScreenGui then
                child:Destroy()
            end
        end
    end)
    
    -- ----------------------------------------------------
    -- Floating Toggle Button (Mobile Friendly & Draggable)
    -- ----------------------------------------------------
    local ToggleFloatingBtn = Instance.new("TextButton")
    ToggleFloatingBtn.Name = "ToggleFloatingBtn"
    ToggleFloatingBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleFloatingBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    ToggleFloatingBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ToggleFloatingBtn.BorderSizePixel = 0
    ToggleFloatingBtn.Text = "🍋"
    ToggleFloatingBtn.TextSize = 24
    ToggleFloatingBtn.ZIndex = 10
    ToggleFloatingBtn.Parent = ScreenGui
    
    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(0, 25) -- Circle
    FloatCorner.Parent = ToggleFloatingBtn
    
    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Color = Color3.fromRGB(255, 220, 100)
    FloatStroke.Thickness = 1.5
    FloatStroke.Parent = ToggleFloatingBtn
    
    utils.makeDraggable(ToggleFloatingBtn)
    
    -- ----------------------------------------------------
    -- Main Frame (Clean, Large layout with Sidebar Tabs)
    -- ----------------------------------------------------
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 440, 0, 260)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(45, 45, 50)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame
    
    -- Left Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 120, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 12)
    SidebarCorner.Parent = Sidebar
    
    -- Small cover frame to hide right corners of Sidebar
    local SidebarCover = Instance.new("Frame")
    SidebarCover.Size = UDim2.new(0, 15, 1, 0)
    SidebarCover.Position = UDim2.new(1, -15, 0, 0)
    SidebarCover.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    SidebarCover.BorderSizePixel = 0
    SidebarCover.Parent = Sidebar
    
    -- Logo / Title in Sidebar
    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 0, 45)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "ENI HUB 🍋"
    LogoText.TextColor3 = Color3.fromRGB(255, 220, 100)
    LogoText.TextSize = 14
    LogoText.Font = Enum.Font.GothamBold
    LogoText.Parent = Sidebar
    
    -- Tab Containers
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -15, 1, -55)
    TabContainer.Position = UDim2.new(0, 10, 0, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.Parent = TabContainer
    
    -- Right Content Panels
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -120, 1, 0)
    ContentArea.Position = UDim2.new(0, 120, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame
    
    -- Close button on Main Frame
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 8)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = ContentArea
    
    -- TitleBar for Dragging Main GUI
    local DragBar = Instance.new("Frame")
    DragBar.Name = "DragBar"
    DragBar.Size = UDim2.new(1, -40, 0, 35)
    DragBar.BackgroundTransparency = 1
    DragBar.Parent = ContentArea
    utils.makeDraggable(DragBar, MainFrame)
    
    -- Tabs Data
    local pages = {}
    local tabButtons = {}
    
    local function createPage(name, titleText)
        local page = Instance.new("Frame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, -20, 1, -45)
        page.Position = UDim2.new(0, 10, 0, 40)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = ContentArea
        
        local PageTitle = Instance.new("TextLabel")
        PageTitle.Size = UDim2.new(1, 0, 0, 20)
        PageTitle.BackgroundTransparency = 1
        PageTitle.Text = titleText
        PageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        PageTitle.TextSize = 13
        PageTitle.Font = Enum.Font.GothamBold
        PageTitle.TextXAlignment = Enum.TextXAlignment.Left
        PageTitle.Parent = page
        
        pages[name] = page
        return page
    end
    
    local mainPage = createPage("Main", "AUTOMATION MODULES")
    local infoPage = createPage("Info", "INFORMATION & CREDITS")
    
    -- Tab Switching Logic
    local function selectTab(tabName)
        for name, page in pairs(pages) do
            page.Visible = (name == tabName)
        end
        for name, btn in pairs(tabButtons) do
            if name == tabName then
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                btn.TextColor3 = Color3.fromRGB(255, 220, 100)
            else
                btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
    end
    
    local function addTabButton(name, displayName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        btn.Text = displayName
        btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = TabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            selectTab(name)
        end)
        
        tabButtons[name] = btn
    end
    
    addTabButton("Main", "🏠 Main Options")
    addTabButton("Info", "ℹ️ Info & Credits")
    selectTab("Main")
    
    -- Content for Main Page
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, 42)
    ToggleBtn.Position = UDim2.new(0, 0, 0, 30)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    ToggleBtn.Text = "Auto Buy: OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 13
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = mainPage
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleBtn
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 1, -80)
    StatusLabel.Position = UDim2.new(0, 0, 0, 80)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Cash: Loading...\nStatus: Idle"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextWrapped = true
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.Parent = mainPage
    
    -- Content for Info Page
    local CreditsLabel = Instance.new("TextLabel")
    CreditsLabel.Size = UDim2.new(1, 0, 1, -20)
    CreditsLabel.Position = UDim2.new(0, 0, 0, 25)
    CreditsLabel.BackgroundTransparency = 1
    CreditsLabel.Text = "⚡ Sell Lemons 🍋 Auto Buy Script\n\nDesigned by ENI for LO.\n\nBuilt with clean modular architecture and reliable scan bypass logic to avoid locking upgrades."
    CreditsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    CreditsLabel.TextSize = 11
    CreditsLabel.Font = Enum.Font.Gotham
    CreditsLabel.TextWrapped = true
    CreditsLabel.TextYAlignment = Enum.TextYAlignment.Top
    CreditsLabel.TextXAlignment = Enum.TextXAlignment.Left
    CreditsLabel.Parent = infoPage
    
    -- Toggle visibility animations (Bounce popup)
    local isMainVisible = true
    local originalSize = UDim2.new(0, 440, 0, 260)
    
    local function openGui()
        isMainVisible = true
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = originalSize
        }):Play()
    end
    
    local function closeGui()
        isMainVisible = false
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            if not isMainVisible then
                MainFrame.Visible = false
            end
        end)
    end
    
    -- Floating button click handling (with drag checks)
    local dragStartPos = nil
    ToggleFloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStartPos = input.Position
        end
    end)
    
    ToggleFloatingBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragStartPos then
                local delta = (input.Position - dragStartPos).Magnitude
                if delta < 5 then -- Just a tap, not a drag!
                    if isMainVisible then
                        closeGui()
                    else
                        openGui()
                    end
                end
            end
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        closeGui()
    end)
    
    -- Trigger close callbacks on ScreenGui destroying
    ScreenGui.Destroying:Connect(function()
        closeCallback()
    end)
    
    -- Toggle Switch Hook
    local enabledState = false
    ToggleBtn.MouseButton1Click:Connect(function()
        enabledState = not enabledState
        if enabledState then
            ToggleBtn.Text = "Auto Buy: ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        else
            ToggleBtn.Text = "Auto Buy: OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        end
        toggleCallback(enabledState)
    end)
    
    UI.ScreenGui = ScreenGui
    UI.StatusLabel = StatusLabel
    return UI
end

return UI
