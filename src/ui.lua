-- ui.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 260, 0, 160)
    MainFrame.Position = UDim2.new(0.5, -130, 0.4, -80)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "ENI Auto Buy 🍋"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 14
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function()
        closeCallback()
        ScreenGui:Destroy()
    end)
    
    ScreenGui.Destroying:Connect(function()
        closeCallback()
    end)
    
    utils.makeDraggable(TitleBar, MainFrame)
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -30, 0, 40)
    ToggleBtn.Position = UDim2.new(0, 15, 0, 50)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    ToggleBtn.Text = "Auto Buy: OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 14
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = MainFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleBtn
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -30, 0, 45)
    StatusLabel.Position = UDim2.new(0, 15, 0, 100)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Cash: Loading...\nStatus: Idle"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = MainFrame
    
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
