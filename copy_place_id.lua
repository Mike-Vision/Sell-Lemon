-- copy_place_id.lua
-- Place ID Finder script by ENI 🍋

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Cleanup existing GUI
pcall(function()
    if PlayerGui:FindFirstChild("PlaceIdFinderGui") then
        PlayerGui.PlaceIdFinderGui:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlaceIdFinderGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Main Container Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 240, 0, 70)
Frame.Position = UDim2.new(0.5, -120, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 220, 100)
Stroke.Thickness = 1.5
Stroke.Parent = Frame

-- Title Label
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 25)
Title.Position = UDim2.new(0, 10, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "Place ID Finder 🔍"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

-- Copy Button
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, -20, 0, 30)
CopyBtn.Position = UDim2.new(0, 10, 0, 32)
CopyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
CopyBtn.Text = tostring(game.PlaceId)
CopyBtn.TextColor3 = Color3.fromRGB(255, 220, 100)
CopyBtn.TextSize = 13
CopyBtn.Font = Enum.Font.Code
CopyBtn.BorderSizePixel = 0
CopyBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = CopyBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(50, 50, 55)
BtnStroke.Thickness = 1
BtnStroke.Parent = CopyBtn

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -28, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 10
CloseBtn.Active = true
CloseBtn.Parent = Frame

-- Close Button Handling
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Copy Functionality
local copying = false
CopyBtn.MouseButton1Click:Connect(function()
    if copying then return end
    copying = true
    
    local placeIdStr = tostring(game.PlaceId)
    local copied = false
    
    -- Attempt standard executors clipboard functions
    pcall(function()
        if setclipboard then
            setclipboard(placeIdStr)
            copied = true
        elseif toclipboard then
            toclipboard(placeIdStr)
            copied = true
        end
    end)
    
    if copied then
        CopyBtn.Text = "Copied to clipboard!"
        CopyBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        CopyBtn.Text = "Click to Copy (Failed to access clipboard)"
        CopyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
    
    task.wait(1.5)
    CopyBtn.Text = placeIdStr
    CopyBtn.TextColor3 = Color3.fromRGB(255, 220, 100)
    copying = false
end)

-- Draggable implementation
local dragging = false
local dragInput, dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("[ENI] Place ID Finder script loaded! Place ID: " .. tostring(game.PlaceId))
