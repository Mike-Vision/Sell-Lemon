-- harvest.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local LocalTycoon = require(ReplicatedStorage.Modules.Tycoon.LocalTycoon)
local ClientTycoonEvolution = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonEvolution)
local Config = require(ReplicatedStorage.Config)

local HarvestModule = {}

function HarvestModule.harvest(selectedFruit)
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local tycoon = LocalTycoon.get()
    local evoComp = tycoon:GetComponent(ClientTycoonEvolution)
    if not evoComp then return end
    
    -- Check active fruit
    local activeEvoIndex = evoComp:GetEvolution()
    local activeFruit = Config.Evolutions[activeEvoIndex + 1]
    local activeFruitName = activeFruit and activeFruit.Name or "Lemon"
    
    if selectedFruit ~= "Active Fruit" and selectedFruit ~= activeFruitName then
        -- Selected fruit does not match active fruit, skip to avoid erroring/clicking wrong things
        return
    end
    
    -- Find all ready fruits in the tycoon recursively (starter trees + hills trees + stand trees)
    local readyDetectors = {}
    for _, item in ipairs(tycoon.Instance:GetDescendants()) do
        if item:IsA("Model") and item.Name:lower():find("tree") then
            for _, fruit in ipairs(item:GetChildren()) do
                if fruit.Name == "Fruit" and fruit.Transparency == 0 then
                    local clickPart = fruit:FindFirstChild("ClickPart")
                    local clickDetector = clickPart and clickPart:FindFirstChild("ClickDetector")
                    if clickDetector then
                        table.insert(readyDetectors, clickDetector)
                    end
                end
            end
        end
    end
    
    if #readyDetectors == 0 then return end
    
    -- Save state
    local originalCFrame = rootPart.CFrame
    local camera = workspace.CurrentCamera
    local originalCameraType = camera.CameraType
    
    -- Lock character and camera to prevent falling and screen shake
    rootPart.Anchored = true
    pcall(function()
        camera.CameraType = Enum.CameraType.Scriptable
    end)
    
    -- Harvest loop
    for _, detector in ipairs(readyDetectors) do
        -- Double check that the fruit is still visible
        if detector.Parent and detector.Parent.Parent and detector.Parent.Parent.Transparency == 0 then
            rootPart.CFrame = detector.Parent.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.05)
            fireclickdetector(detector)
        end
    end
    
    -- Restore state
    rootPart.CFrame = originalCFrame
    task.wait(0.05)
    rootPart.Anchored = false
    pcall(function()
        camera.CameraType = originalCameraType
    end)
end

return HarvestModule
