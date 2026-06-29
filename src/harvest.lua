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
        return
    end
    
    -- Find all ready fruits recursively (starter trees + hills trees + stand trees)
    local readyFruits = {}
    for _, item in ipairs(tycoon.Instance:GetDescendants()) do
        if item:IsA("Model") and item.Name:lower():find("tree") then
            for _, fruit in ipairs(item:GetChildren()) do
                if fruit.Name == "Fruit" and fruit.Transparency == 0 then
                    local clickPart = fruit:FindFirstChild("ClickPart")
                    local clickDetector = clickPart and clickPart:FindFirstChild("ClickDetector")
                    if clickDetector then
                        table.insert(readyFruits, fruit)
                    end
                end
            end
        end
    end
    
    if #readyFruits == 0 then return end
    
    -- Group into clusters of max 25 studs to minimize teleports
    local clusters = {}
    local CLUSTER_RADIUS = 25
    
    for _, fruit in ipairs(readyFruits) do
        local pos = fruit.Position
        local detector = fruit.ClickPart.ClickDetector
        local addedToCluster = false
        
        for _, cluster in ipairs(clusters) do
            if (cluster.centerPos - pos).Magnitude <= CLUSTER_RADIUS then
                table.insert(cluster.detectors, detector)
                addedToCluster = true
                break
            end
        end
        
        if not addedToCluster then
            table.insert(clusters, {
                centerPos = pos,
                detectors = {detector}
            })
        end
    end
    
    -- Save state
    local originalCFrame = rootPart.CFrame
    local camera = workspace.CurrentCamera
    local originalCameraType = camera.CameraType
    
    -- Lock camera to prevent screen shaking
    pcall(function()
        camera.CameraType = Enum.CameraType.Scriptable
    end)
    
    -- Noclip function to avoid getting bumped/collision offsets
    local function setNoclip(state)
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
    
    setNoclip(true)
    
    -- Harvest loop
    for _, cluster in ipairs(clusters) do
        rootPart.CFrame = CFrame.new(cluster.centerPos + Vector3.new(0, 2, 0))
        rootPart.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.08) -- Wait for position replication to the server (crucial!)
        
        for _, detector in ipairs(cluster.detectors) do
            if detector.Parent and detector.Parent.Parent and detector.Parent.Parent.Transparency == 0 then
                fireclickdetector(detector)
                task.wait(0.15) -- Rate limit wait to bypass the game's click anticheat
            end
        end
    end
    
    -- Restore state
    rootPart.CFrame = originalCFrame
    task.wait(0.05)
    setNoclip(false)
    pcall(function()
        camera.CameraType = originalCameraType
    end)
end

return HarvestModule
