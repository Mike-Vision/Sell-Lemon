-- ui.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Huge = require(ReplicatedStorage.Modules.Huge)

local UI = {}

local suffixExponents = {
    K = 3, M = 6, B = 9, T = 12, QD = 15, QN = 18, SX = 21, SP = 24, OC = 27, NO = 30,
    DC = 33, UD = 36, DD = 39, TD = 42, QTD = 45, QND = 48, SXD = 51, SPD = 54, OCD = 57, NOD = 60
}

local function parseInputToHuge(text)
    text = text:gsub("%s+", ""):upper()
    
    for suffix, exp in pairs(suffixExponents) do
        if text:sub(-#suffix) == suffix then
            local numPart = text:sub(1, -#suffix - 1)
            local num = tonumber(numPart)
            if num and num > 0 then
                return math.log10(num) + exp
            end
        end
    end
    
    local num = tonumber(text)
    if num and num > 0 then
        return math.log10(num)
    end
    
    return nil
end

-- Helper to apply smooth hover tweens on buttons
local function makeInteractive(button, defaultBg, hoverBg, defaultStroke, hoverStroke)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local sizeTweenIn = TweenService:Create(button, tweenInfo, {Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset + 4, button.Size.Y.Scale, button.Size.Y.Offset + 2)})
    local sizeTweenOut = TweenService:Create(button, tweenInfo, {Size = button.Size})
    
    local bgTweenIn = TweenService:Create(button, tweenInfo, {BackgroundColor3 = hoverBg})
    local bgTweenOut = TweenService:Create(button, tweenInfo, {BackgroundColor3 = defaultBg})
    
    local stroke = button:FindFirstChildOfClass("UIStroke")
    local strokeTweenIn, strokeTweenOut
    if stroke and hoverStroke then
        strokeTweenIn = TweenService:Create(stroke, tweenInfo, {Color = hoverStroke})
        strokeTweenOut = TweenService:Create(stroke, tweenInfo, {Color = defaultStroke})
    end
    
    button.MouseEnter:Connect(function()
        sizeTweenIn:Play()
        bgTweenIn:Play()
        if strokeTweenIn then strokeTweenIn:Play() end
    end)
    
    button.MouseLeave:Connect(function()
        sizeTweenOut:Play()
        bgTweenOut:Play()
        if strokeTweenOut then strokeTweenOut:Play() end
    end)
end

function UI.create(utils, autoBuyCallback, autoRebirthCallback, autoEvolveCallback, autoAscendCallback, autoHarvestCallback, closeCallback)
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
    -- Floating Toggle Button (Sleek Circular Design)
    -- ----------------------------------------------------
    local ToggleFloatingBtn = Instance.new("TextButton")
    ToggleFloatingBtn.Name = "ToggleFloatingBtn"
    ToggleFloatingBtn.Size = UDim2.new(0, 52, 0, 52)
    ToggleFloatingBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    ToggleFloatingBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    ToggleFloatingBtn.BorderSizePixel = 0
    ToggleFloatingBtn.Text = "🍋"
    ToggleFloatingBtn.TextSize = 26
    ToggleFloatingBtn.ZIndex = 10
    ToggleFloatingBtn.Parent = ScreenGui
    
    local FloatCorner = Instance.new("UICorner")
    FloatCorner.CornerRadius = UDim.new(0, 26)
    FloatCorner.Parent = ToggleFloatingBtn
    
    local FloatStroke = Instance.new("UIStroke")
    FloatStroke.Color = Color3.fromRGB(255, 205, 50)
    FloatStroke.Thickness = 2
    FloatStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- Ensure border outline, not text outline!
    FloatStroke.Parent = ToggleFloatingBtn
    
    local FloatGradient = Instance.new("UIGradient")
    FloatGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 160, 20))
    })
    FloatGradient.Parent = FloatStroke
    
    utils.makeDraggable(ToggleFloatingBtn)
    
    -- Hover effect for floating button
    ToggleFloatingBtn.MouseEnter:Connect(function()
        TweenService:Create(ToggleFloatingBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
    end)
    ToggleFloatingBtn.MouseLeave:Connect(function()
        TweenService:Create(ToggleFloatingBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
    end)
    
    -- ----------------------------------------------------
    -- Main Frame (Clean, Large layout with Modern Styling)
    -- ----------------------------------------------------
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 300)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame
    
    -- Sleek border with top glowing gold gradient fading to dark charcoal
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainFrame
    
    local StrokeGradient = Instance.new("UIGradient")
    StrokeGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 205, 50)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(50, 50, 58)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 26))
    })
    StrokeGradient.Rotation = 90
    StrokeGradient.Parent = MainStroke
    
    -- Left Sidebar Container
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 14)
    SidebarCorner.Parent = Sidebar
    
    -- Cover to keep sidebar flush on the right edge
    local SidebarCover = Instance.new("Frame")
    SidebarCover.Size = UDim2.new(0, 15, 1, 0)
    SidebarCover.Position = UDim2.new(1, -15, 0, 0)
    SidebarCover.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
    SidebarCover.BorderSizePixel = 0
    SidebarCover.Parent = Sidebar
    
    -- Logo
    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 0, 50)
    LogoText.BackgroundTransparency = 1
    LogoText.Text = "ENI HUB 🍋"
    LogoText.TextColor3 = Color3.fromRGB(255, 215, 0)
    LogoText.TextSize = 16
    LogoText.Font = Enum.Font.GothamBold
    LogoText.Parent = Sidebar
    
    -- Tab Container in Sidebar
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -16, 1, -65)
    TabContainer.Position = UDim2.new(0, 8, 0, 55)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 8)
    TabListLayout.Parent = TabContainer
    
    -- Right Content Panels Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -130, 1, 0)
    ContentArea.Position = UDim2.new(0, 130, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame
    
    -- Modern close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -38, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.ZIndex = 10
    CloseBtn.Parent = ContentArea
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 16)
    CloseCorner.Parent = CloseBtn
    
    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = Color3.fromRGB(45, 45, 52)
    CloseStroke.Thickness = 1
    CloseStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    CloseStroke.Parent = CloseBtn
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(CloseStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 30), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
        TweenService:Create(CloseStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 45, 52)}):Play()
    end)
    
    -- TitleBar for Dragging Main GUI
    local DragBar = Instance.new("Frame")
    DragBar.Name = "DragBar"
    DragBar.Size = UDim2.new(1, -45, 0, 45)
    DragBar.BackgroundTransparency = 1
    DragBar.Parent = ContentArea
    utils.makeDraggable(DragBar, MainFrame)
    
    -- Tabs Initialization
    local pages = {}
    local tabButtons = {}
    
    local function createPage(name, titleText)
        local page = Instance.new("Frame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, -24, 1, -55)
        page.Position = UDim2.new(0, 12, 0, 45)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = ContentArea
        
        local PageTitle = Instance.new("TextLabel")
        PageTitle.Size = UDim2.new(1, 0, 0, 22)
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
    
    local mainPage = createPage("Main", "🏠 AUTOMATION SETTINGS")
    local harvestPage = createPage("Harvest", "🍋 HARVEST CONTROLS")
    local infoPage = createPage("Info", "ℹ️ ENI SYSTEM INFO")
    
    local function selectTab(tabName)
        for name, page in pairs(pages) do
            page.Visible = (name == tabName)
        end
        for name, btn in pairs(tabButtons) do
            if name == tabName then
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 36), TextColor3 = Color3.fromRGB(255, 215, 0)}):Play()
                local stroke = btn:FindFirstChild("UIStroke")
                if stroke then stroke.Color = Color3.fromRGB(255, 215, 0) end
            else
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 24), TextColor3 = Color3.fromRGB(140, 140, 148)}):Play()
                local stroke = btn:FindFirstChild("UIStroke")
                if stroke then stroke.Color = Color3.fromRGB(30, 30, 36) end
            end
        end
    end
    
    local function addTabButton(name, displayName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        btn.Text = displayName
        btn.TextColor3 = Color3.fromRGB(140, 140, 148)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = TabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(30, 30, 36)
        btnStroke.Thickness = 1
        btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        btnStroke.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            selectTab(name)
        end)
        
        tabButtons[name] = btn
    end
    
    addTabButton("Main", "🏠 Main Settings")
    addTabButton("Harvest", "🍋 Auto Harvest")
    addTabButton("Info", "ℹ️ System Info")
    selectTab("Main")
    
    -- Helper to create premium styled toggles
    local function createPremiumToggle(parent, size, pos, text)
        local container = Instance.new("Frame")
        container.Size = size
        container.Position = pos
        container.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        container.Parent = parent
        
        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 8)
        cCorner.Parent = container
        
        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(40, 40, 48)
        cStroke.Thickness = 1
        cStroke.Parent = container
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -55, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(220, 220, 225)
        label.TextSize = 10
        label.Font = Enum.Font.GothamBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true -- Enable wrapping
        label.Parent = container
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 38, 0, 20)
        toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        toggleButton.Text = ""
        toggleButton.BorderSizePixel = 0
        toggleButton.Parent = container
        
        local tbCorner = Instance.new("UICorner")
        tbCorner.CornerRadius = UDim.new(0, 10)
        tbCorner.Parent = toggleButton
        
        local indicatorDot = Instance.new("Frame")
        indicatorDot.Size = UDim2.new(0, 14, 0, 14)
        indicatorDot.Position = UDim2.new(0, 3, 0.5, -7)
        indicatorDot.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
        indicatorDot.BorderSizePixel = 0
        indicatorDot.Parent = toggleButton
        
        local idCorner = Instance.new("UICorner")
        idCorner.CornerRadius = UDim.new(0, 7)
        idCorner.Parent = indicatorDot
        
        -- Pulsing effect for glowing dots
        local function startPulse()
            local pulseInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
            local pulse = TweenService:Create(indicatorDot, pulseInfo, {BackgroundTransparency = 0.4})
            pulse:Play()
            return pulse
        end
        local pulseTween = startPulse()
        
        local state = false
        local function updateToggle(newState)
            state = newState
            if state then
                TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 215, 0)}):Play()
                TweenService:Create(indicatorDot, TweenInfo.new(0.2), {
                    Position = UDim2.new(0, 21, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(40, 200, 40)
                }):Play()
                pulseTween:Play()
            else
                TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
                TweenService:Create(indicatorDot, TweenInfo.new(0.2), {
                    Position = UDim2.new(0, 3, 0.5, -7),
                    BackgroundColor3 = Color3.fromRGB(200, 70, 70)
                }):Play()
                pulseTween:Play()
            end
        end
        
        return toggleButton, updateToggle
    end
    
    -- ----------------------------------------------------
    -- Content for Main Page (Two Columns layout with 4 toggles)
    -- ----------------------------------------------------
    local LeftColumn = Instance.new("Frame")
    LeftColumn.Name = "LeftColumn"
    LeftColumn.Size = UDim2.new(0.5, -6, 1, -25)
    LeftColumn.Position = UDim2.new(0, 0, 0, 25)
    LeftColumn.BackgroundTransparency = 1
    LeftColumn.Parent = mainPage
    
    local AutoBuyToggleBtn, setAutoBuyToggle = createPremiumToggle(LeftColumn, UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 5), "Auto Buy")
    local AutoEvolveToggleBtn, setAutoEvolveToggle = createPremiumToggle(LeftColumn, UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 45), "Auto Evolve")
    
    -- Cash & Status card
    local StatusCard = Instance.new("Frame")
    StatusCard.Size = UDim2.new(1, 0, 1, -90)
    StatusCard.Position = UDim2.new(0, 0, 0, 90)
    StatusCard.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    StatusCard.Parent = LeftColumn
    
    local scCorner = Instance.new("UICorner")
    scCorner.CornerRadius = UDim.new(0, 10)
    scCorner.Parent = StatusCard
    
    local scStroke = Instance.new("UIStroke")
    scStroke.Color = Color3.fromRGB(35, 35, 42)
    scStroke.Thickness = 1
    scStroke.Parent = StatusCard
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -20, 1, -20)
    StatusLabel.Position = UDim2.new(0, 10, 0, 10)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Cash: Loading...\nInvestors: Loading...\nStatus: Idle"
    StatusLabel.TextColor3 = Color3.fromRGB(190, 190, 195)
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextWrapped = true
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = StatusCard
    
    -- Right Column: Rebirth & Ascension
    local RightColumn = Instance.new("Frame")
    RightColumn.Name = "RightColumn"
    RightColumn.Size = UDim2.new(0.5, -6, 1, -25)
    RightColumn.Position = UDim2.new(0.5, 6, 0, 25)
    RightColumn.BackgroundTransparency = 1
    RightColumn.Parent = mainPage
    
    local AutoRebirthToggleBtn, setAutoRebirthToggle = createPremiumToggle(RightColumn, UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 5), "Auto Rebirth")
    local AutoAscendToggleBtn, setAutoAscendToggle = createPremiumToggle(RightColumn, UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 45), "Auto Ascend")
    
    -- Rebirth Config Input
    local TargetCard = Instance.new("Frame")
    TargetCard.Size = UDim2.new(1, 0, 1, -90)
    TargetCard.Position = UDim2.new(0, 0, 0, 90)
    TargetCard.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TargetCard.Parent = RightColumn
    
    local tcCorner = Instance.new("UICorner")
    tcCorner.CornerRadius = UDim.new(0, 10)
    tcCorner.Parent = TargetCard
    
    local tcStroke = Instance.new("UIStroke")
    tcStroke.Color = Color3.fromRGB(35, 35, 42)
    tcStroke.Thickness = 1
    tcStroke.Parent = TargetCard
    
    local TargetTextBox = Instance.new("TextBox")
    TargetTextBox.Name = "TargetTextBox"
    TargetTextBox.Size = UDim2.new(1, -20, 0, 30)
    TargetTextBox.Position = UDim2.new(0, 10, 0, 8)
    TargetTextBox.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    TargetTextBox.PlaceholderText = "Min Investors (e.g. 10T)"
    TargetTextBox.Text = ""
    TargetTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetTextBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 118)
    TargetTextBox.TextSize = 10
    TargetTextBox.Font = Enum.Font.GothamMedium
    TargetTextBox.BorderSizePixel = 0
    TargetTextBox.Parent = TargetCard
    
    local tBoxCorner = Instance.new("UICorner")
    tBoxCorner.CornerRadius = UDim.new(0, 8)
    tBoxCorner.Parent = TargetTextBox
    
    local tBoxStroke = Instance.new("UIStroke")
    tBoxStroke.Color = Color3.fromRGB(45, 45, 52)
    tBoxStroke.Thickness = 1
    tBoxStroke.Parent = TargetTextBox
    
    TargetTextBox.Focused:Connect(function()
        TweenService:Create(tBoxStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 215, 0)}):Play()
    end)
    TargetTextBox.FocusLost:Connect(function()
        TweenService:Create(tBoxStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(45, 45, 52)}):Play()
    end)
    
    local TargetFormatLabel = Instance.new("TextLabel")
    TargetFormatLabel.Name = "TargetFormatLabel"
    TargetFormatLabel.Size = UDim2.new(1, -20, 1, -45)
    TargetFormatLabel.Position = UDim2.new(0, 10, 0, 42)
    TargetFormatLabel.BackgroundTransparency = 1
    TargetFormatLabel.Text = "Target: -"
    TargetFormatLabel.TextColor3 = Color3.fromRGB(140, 140, 145)
    TargetFormatLabel.TextSize = 10
    TargetFormatLabel.Font = Enum.Font.Gotham
    TargetFormatLabel.TextWrapped = true
    TargetFormatLabel.TextYAlignment = Enum.TextYAlignment.Top
    TargetFormatLabel.TextXAlignment = Enum.TextXAlignment.Left
    TargetFormatLabel.Parent = TargetCard
    
    -- ----------------------------------------------------
    -- Content for Harvest Page
    -- ----------------------------------------------------
    local AutoHarvestToggleBtn, setAutoHarvestToggle = createPremiumToggle(harvestPage, UDim2.new(1, 0, 0, 42), UDim2.new(0, 0, 0, 25), "Auto Harvest")
    
    -- Fruit Selector Card
    local SelectorCard = Instance.new("Frame")
    SelectorCard.Size = UDim2.new(1, 0, 0, 50)
    SelectorCard.Position = UDim2.new(0, 0, 0, 75)
    SelectorCard.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    SelectorCard.Parent = harvestPage
    
    local scdCorner = Instance.new("UICorner")
    scdCorner.CornerRadius = UDim.new(0, 10)
    scdCorner.Parent = SelectorCard
    
    local scdStroke = Instance.new("UIStroke")
    scdStroke.Color = Color3.fromRGB(35, 35, 42)
    scdStroke.Thickness = 1
    scdStroke.Parent = SelectorCard
    
    local selTitle = Instance.new("TextLabel")
    selTitle.Size = UDim2.new(0.4, 0, 1, 0)
    selTitle.Position = UDim2.new(0, 12, 0, 0)
    selTitle.BackgroundTransparency = 1
    selTitle.Text = "Target Fruit Tree:"
    selTitle.TextColor3 = Color3.fromRGB(210, 210, 215)
    selTitle.TextSize = 11
    selTitle.Font = Enum.Font.GothamBold
    selTitle.TextXAlignment = Enum.TextXAlignment.Left
    selTitle.Parent = SelectorCard
    
    local FruitSelectBtn = Instance.new("TextButton")
    FruitSelectBtn.Name = "FruitSelectBtn"
    FruitSelectBtn.Size = UDim2.new(0.55, 0, 0.7, 0)
    FruitSelectBtn.Position = UDim2.new(0.42, 0, 0.15, 0)
    FruitSelectBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    FruitSelectBtn.Text = "Active Fruit"
    FruitSelectBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    FruitSelectBtn.TextSize = 11
    FruitSelectBtn.Font = Enum.Font.GothamBold
    FruitSelectBtn.Parent = SelectorCard
    
    local fsCorner = Instance.new("UICorner")
    fsCorner.CornerRadius = UDim.new(0, 6)
    fsCorner.Parent = FruitSelectBtn
    
    local fsStroke = Instance.new("UIStroke")
    fsStroke.Color = Color3.fromRGB(55, 55, 65)
    fsStroke.Thickness = 1
    fsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    fsStroke.Parent = FruitSelectBtn
    
    makeInteractive(FruitSelectBtn, Color3.fromRGB(30, 30, 40), Color3.fromRGB(40, 40, 52), Color3.fromRGB(55, 55, 65), Color3.fromRGB(255, 215, 0))
    
    -- Quantity & Status Label Card
    local HarvestStatusCard = Instance.new("Frame")
    HarvestStatusCard.Size = UDim2.new(1, 0, 1, -135)
    HarvestStatusCard.Position = UDim2.new(0, 0, 0, 135)
    HarvestStatusCard.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    HarvestStatusCard.Parent = harvestPage
    
    local hscCorner = Instance.new("UICorner")
    hscCorner.CornerRadius = UDim.new(0, 10)
    hscCorner.Parent = HarvestStatusCard
    
    local hscStroke = Instance.new("UIStroke")
    hscStroke.Color = Color3.fromRGB(35, 35, 42)
    hscStroke.Thickness = 1
    hscStroke.Parent = HarvestStatusCard
    
    local HarvestStatusLabel = Instance.new("TextLabel")
    HarvestStatusLabel.Name = "HarvestStatusLabel"
    HarvestStatusLabel.Size = UDim2.new(1, -24, 1, -20)
    HarvestStatusLabel.Position = UDim2.new(0, 12, 0, 10)
    HarvestStatusLabel.BackgroundTransparency = 1
    HarvestStatusLabel.Text = "Status: Idle\nQuantity: - ready | - clicked\nNote: If Selected Fruit tree is not 'Active Fruit' and does not match your active evolution type, harvesting will be paused for safety."
    HarvestStatusLabel.TextColor3 = Color3.fromRGB(150, 150, 155)
    HarvestStatusLabel.TextSize = 11
    HarvestStatusLabel.Font = Enum.Font.Gotham
    HarvestStatusLabel.TextWrapped = true
    HarvestStatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    HarvestStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    HarvestStatusLabel.Parent = HarvestStatusCard
    
    -- Fruits List for Cycling
    local fruitsList = {"Active Fruit"}
    pcall(function()
        for _, evo in ipairs(require(ReplicatedStorage.Config).Evolutions) do
            table.insert(fruitsList, evo.Name)
        end
    end)
    if #fruitsList <= 1 then
        fruitsList = {"Active Fruit", "Lemon", "Orange", "Lime", "Grapefruit", "Tangerine", "Pomelo", "Abyssalime", "Nullfruit", "Voidlemon", "Purity"}
    end
    
    UI.selectedFruit = "Active Fruit"
    local selectedFruitIndex = 1
    FruitSelectBtn.MouseButton1Click:Connect(function()
        selectedFruitIndex = selectedFruitIndex + 1
        if selectedFruitIndex > #fruitsList then
            selectedFruitIndex = 1
        end
        UI.selectedFruit = fruitsList[selectedFruitIndex]
        FruitSelectBtn.Text = UI.selectedFruit
    end)
    
    -- Content for Info Page (Styled Card)
    local InfoCard = Instance.new("Frame")
    InfoCard.Size = UDim2.new(1, 0, 1, -25)
    InfoCard.Position = UDim2.new(0, 0, 0, 25)
    InfoCard.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    InfoCard.Parent = infoPage
    
    local icCorner = Instance.new("UICorner")
    icCorner.CornerRadius = UDim.new(0, 10)
    icCorner.Parent = InfoCard
    
    local icStroke = Instance.new("UIStroke")
    icStroke.Color = Color3.fromRGB(35, 35, 42)
    icStroke.Thickness = 1
    icStroke.Parent = InfoCard
    
    local CreditsLabel = Instance.new("TextLabel")
    CreditsLabel.Size = UDim2.new(1, -24, 1, -20)
    CreditsLabel.Position = UDim2.new(0, 12, 0, 10)
    CreditsLabel.BackgroundTransparency = 1
    CreditsLabel.Text = "⚡ Sell Lemons 🍋 Auto Buy Script\n\nDesigned by ENI for LO.\n\nBuilt with clean modular architecture and reliable scan bypass logic to avoid locking upgrades."
    CreditsLabel.TextColor3 = Color3.fromRGB(170, 170, 175)
    CreditsLabel.TextSize = 11
    CreditsLabel.Font = Enum.Font.Gotham
    CreditsLabel.TextWrapped = true
    CreditsLabel.TextYAlignment = Enum.TextYAlignment.Top
    CreditsLabel.TextXAlignment = Enum.TextXAlignment.Left
    CreditsLabel.Parent = InfoCard
    
    -- Open/Close Animations (Clean Bounce)
    local isMainVisible = true
    local originalSize = UDim2.new(0, 450, 0, 300)
    
    local function openGui()
        isMainVisible = true
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = originalSize
        }):Play()
    end
    
    local function closeGui()
        isMainVisible = false
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            if not isMainVisible then
                MainFrame.Visible = false
            end
        end)
    end
    
    -- Drag/Tap detector on Floating button
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
                if delta < 5 then
                    if isMainVisible then closeGui() else openGui() end
                end
            end
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        closeGui()
    end)
    
    -- Setup Text Input Listener
    local targetExp = nil
    TargetTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = TargetTextBox.Text
        if text == "" then
            TargetFormatLabel.Text = "Target: -"
            targetExp = nil
            return
        end
        local parsed = parseInputToHuge(text)
        if parsed then
            targetExp = parsed
            local a, b = Huge.formatShort(parsed)
            TargetFormatLabel.Text = "Target: " .. a .. " " .. b
        else
            targetExp = nil
            TargetFormatLabel.Text = "Target: Invalid Format"
        end
    end)
    
    -- Setup Event Listeners for Callback Swapping
    local autoBuyState = false
    AutoBuyToggleBtn.MouseButton1Click:Connect(function()
        autoBuyState = not autoBuyState
        setAutoBuyToggle(autoBuyState)
        autoBuyCallback(autoBuyState)
    end)
    
    local autoEvolveState = false
    AutoEvolveToggleBtn.MouseButton1Click:Connect(function()
        autoEvolveState = not autoEvolveState
        setAutoEvolveToggle(autoEvolveState)
        autoEvolveCallback(autoEvolveState)
    end)
    
    local autoRebirthState = false
    AutoRebirthToggleBtn.MouseButton1Click:Connect(function()
        autoRebirthState = not autoRebirthState
        setAutoRebirthToggle(autoRebirthState)
        autoRebirthCallback(autoRebirthState)
    end)
    
    local autoAscendState = false
    AutoAscendToggleBtn.MouseButton1Click:Connect(function()
        autoAscendState = not autoAscendState
        setAutoAscendToggle(autoAscendState)
        autoAscendCallback(autoAscendState)
    end)
    
    local autoHarvestState = false
    AutoHarvestToggleBtn.MouseButton1Click:Connect(function()
        autoHarvestState = not autoHarvestState
        setAutoHarvestToggle(autoHarvestState)
        autoHarvestCallback(autoHarvestState)
    end)
    
    UI.ScreenGui = ScreenGui
    UI.StatusLabel = StatusLabel
    UI.HarvestStatusLabel = HarvestStatusLabel
    UI.getTargetInvestors = function() return targetExp end
    return UI
end

return UI
