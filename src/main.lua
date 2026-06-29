-- main.lua
return function(loadModule)
    local utils = loadModule("utils")
    local tycoonModule = loadModule("tycoon")
    local uiModule = loadModule("ui")
    
    local Running = true
    local AutoBuyEnabled = false
    
    local ui = uiModule.create(
        utils,
        function(enabled)
            AutoBuyEnabled = enabled
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
    
    print("[ENI] Auto Buy GUI loaded successfully!")
end
