-- main.lua
return function(loadModule)
    local utils = loadModule("utils")
    local tycoonModule = loadModule("tycoon")
    local uiModule = loadModule("ui")
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalTycoon = require(ReplicatedStorage.Modules.Tycoon.LocalTycoon)
    local ClientTycoonRebirth = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonRebirth)
    
    local tycoon = LocalTycoon.get()
    local rebirthComp = tycoon:GetComponent(ClientTycoonRebirth)
    
    local Running = true
    local AutoBuyEnabled = false
    local AutoRebirthEnabled = false
    
    local ui = uiModule.create(
        utils,
        function(enabled)
            AutoBuyEnabled = enabled
        end,
        function(enabled)
            AutoRebirthEnabled = enabled
        end,
        function()
            Running = false
        end
    )
    
    local LocalPlayer = game:GetService("Players").LocalPlayer
    
    task.spawn(function()
        while Running do
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
                ui.StatusLabel.Text = "Error: " .. tostring(err)
            end
            task.wait(0.5)
        end
    end)
    
    print("[ENI] Auto Buy & Rebirth GUI loaded successfully!")
end
