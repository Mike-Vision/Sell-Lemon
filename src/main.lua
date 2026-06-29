-- main.lua
return function(loadModule)
    local utils = loadModule("utils")
    local tycoonModule = loadModule("tycoon")
    local uiModule = loadModule("ui")
    local harvestModule = loadModule("harvest")
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalTycoon = require(ReplicatedStorage.Modules.Tycoon.LocalTycoon)
    local ClientTycoonRebirth = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonRebirth)
    local RemoteSignal = require(ReplicatedStorage.Core.RemoteSignal)
    local ClickFruitService = require(ReplicatedStorage.Modules.Service.ClickFruitService)
    
    local tycoon = LocalTycoon.get()
    local rebirthComp = tycoon:GetComponent(ClientTycoonRebirth)
    
    -- Setup Global Session Tracking & Event Cleanup
    getgenv().ENI_SCRIPT_SESSION = os.clock()
    local currentSession = getgenv().ENI_SCRIPT_SESSION
    
    if getgenv().ENI_CONNECTIONS then
        for _, conn in ipairs(getgenv().ENI_CONNECTIONS) do
            pcall(function() conn:Disconnect() end)
        end
    end
    getgenv().ENI_CONNECTIONS = {}
    
    local Running = true
    local AutoBuyEnabled = false
    local AutoRebirthEnabled = false
    local AutoHarvestEnabled = false
    
    local ui
    
    local function updateQuantity(isHarvesting)
        if not ui then return end
        if getgenv().ENI_SCRIPT_SESSION ~= currentSession then return end
        
        pcall(function()
            local totalClicked = ClickFruitService:GetFruitsClicked()
            local readyCount = 0
            for _, item in ipairs(tycoon.Instance:GetDescendants()) do
                if item:IsA("Model") and item.Name:lower():find("tree") then
                    for _, fruit in ipairs(item:GetChildren()) do
                        if fruit.Name == "Fruit" and fruit.Transparency == 0 then
                            readyCount = readyCount + 1
                        end
                    end
                end
            end
            
            if AutoHarvestEnabled then
                if isHarvesting then
                    ui.HarvestStatusLabel.Text = "Status: Harvesting...\nQuantity: " .. readyCount .. " ready | " .. totalClicked .. " clicked\nNote: If Selected Fruit tree is not 'Active Fruit' and does not match your active evolution type, harvesting will be paused for safety."
                else
                    ui.HarvestStatusLabel.Text = "Status: Idle (Selected: " .. tostring(ui.selectedFruit) .. ")\nQuantity: " .. readyCount .. " ready | " .. totalClicked .. " clicked\nNote: If Selected Fruit tree is not 'Active Fruit' and does not match your active evolution type, harvesting will be paused for safety."
                end
            else
                ui.HarvestStatusLabel.Text = "Status: OFF\nQuantity: - ready | " .. totalClicked .. " clicked"
            end
        end)
    end
    
    ui = uiModule.create(
        utils,
        function(enabled)
            AutoBuyEnabled = enabled
        end,
        function(enabled)
            AutoRebirthEnabled = enabled
        end,
        function(enabled)
            AutoHarvestEnabled = enabled
            updateQuantity()
        end,
        function()
            Running = false
        end
    )
    
    -- Listen to fruit click events in real-time
    local clickSignal = RemoteSignal.new("ClickFruitService.Clicked")
    local clickConn = clickSignal.OnClientEvent:Connect(function()
        task.wait(0.05) -- Allow stats replication
        updateQuantity()
    end)
    table.insert(getgenv().ENI_CONNECTIONS, clickConn)
    
    -- Listen to fruit growth changes in real-time (tycoon-wide + newly purchased trees)
    local function connectFruit(fruit)
        if fruit.Name == "Fruit" then
            local transConn = fruit:GetPropertyChangedSignal("Transparency"):Connect(updateQuantity)
            table.insert(getgenv().ENI_CONNECTIONS, transConn)
        end
    end
    
    for _, item in ipairs(tycoon.Instance:GetDescendants()) do
        if item:IsA("Model") and item.Name:lower():find("tree") then
            for _, fruit in ipairs(item:GetChildren()) do
                connectFruit(fruit)
            end
        end
    end
    
    local addedConn = tycoon.Instance.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") and descendant.Name:lower():find("tree") then
            local childConn = descendant.ChildAdded:Connect(function(child)
                if child.Name == "Fruit" then
                    connectFruit(child)
                    updateQuantity()
                end
            end)
            table.insert(getgenv().ENI_CONNECTIONS, childConn)
            
            for _, child in ipairs(descendant:GetChildren()) do
                if child.Name == "Fruit" then
                    connectFruit(child)
                end
            end
            updateQuantity()
        end
    end)
    table.insert(getgenv().ENI_CONNECTIONS, addedConn)
    
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    -- Auto Buy & Rebirth Loop
    task.spawn(function()
        while Running and getgenv().ENI_SCRIPT_SESSION == currentSession do
            local success, err = pcall(function()
                local cash = LocalPlayer.leaderstats.Cash.Value
                
                -- Check Auto Rebirth
                if AutoRebirthEnabled then
                    local target = ui.getTargetInvestors()
                    if target then
                        local potential = rebirthComp:GetPotentialInvestors()
                        if potential >= target then
                            ui.StatusLabel.Text = "Status: Rebirthing..."
                            rebirthComp:RebirthAsync(false)
                            task.wait(1.5)
                            return
                        end
                    end
                end
                
                local buyable = tycoonModule.getBuyableButtons()
                if AutoBuyEnabled then
                    ui.StatusLabel.Text = "Cash: " .. tostring(cash) .. "\nBuyable Upgrades: " .. #buyable
                    
                    if #buyable > 0 then
                        local target = buyable[1]
                        local displayName = target:GetAttribute("DisplayName")
                        local showName = (displayName and displayName ~= "") and displayName or target.Name
                        ui.StatusLabel.Text = "Cash: " .. tostring(cash) .. "\nBuying: " .. showName
                        task.wait(0.1)
                        tycoonModule.purchaseUpgrade(target)
                    end
                else
                    ui.StatusLabel.Text = "Cash: " .. tostring(cash) .. "\nStatus: Paused"
                end
            end)
            
            if not success then
                if ui and ui.StatusLabel then
                    ui.StatusLabel.Text = "Error: " .. tostring(err)
                end
            end
            task.wait(0.5)
        end
    end)
    
    -- Auto Harvest Loop
    task.spawn(function()
        while Running and getgenv().ENI_SCRIPT_SESSION == currentSession do
            if AutoHarvestEnabled then
                local success, err = pcall(function()
                    updateQuantity(true)
                    harvestModule.harvest(ui.selectedFruit, function()
                        return AutoHarvestEnabled and Running and getgenv().ENI_SCRIPT_SESSION == currentSession
                    end)
                    updateQuantity(false)
                end)
                if not success then
                    if ui and ui.HarvestStatusLabel then
                        ui.HarvestStatusLabel.Text = "Status Error: " .. tostring(err)
                    end
                end
            end
            task.wait(3.0)
        end
    end)
    
    -- Initial update
    updateQuantity()
    
    print("[ENI] Auto Buy, Rebirth & Harvest GUI loaded successfully!")
end


