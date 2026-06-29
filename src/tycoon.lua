-- tycoon.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalTycoon = require(ReplicatedStorage.Modules.Tycoon.LocalTycoon)
local TycoonPurchases = require(ReplicatedStorage.Modules.Tycoon.Component.TycoonPurchases)
local TycoonBalances = require(ReplicatedStorage.Modules.Tycoon.Component.TycoonBalances)
local TycoonAscension = require(ReplicatedStorage.Modules.Tycoon.Component.TycoonAscension)
local Balance = require(ReplicatedStorage.Balance)
local String = require(ReplicatedStorage.Core.String)
local Huge = require(ReplicatedStorage.Modules.Huge)

local TycoonModule = {}

local tycoon = LocalTycoon.get()
local purchases = tycoon:GetComponent(TycoonPurchases)
local balances = tycoon:GetComponent(TycoonBalances)
local ascension = tycoon:GetComponent(TycoonAscension)

function TycoonModule.getBuyableButtons()
    local list = {}
    local cashLog = balances:GetCash()
    
    local function scan(folder)
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChild("Purchase") then
                local cleanName = String.alphanumeric(child.Name)
                local isPurchased = purchases:IsPurchased(cleanName)
                local isShown = child:GetAttribute("Shown") == true
                local isEnabled = child:GetAttribute("Enabled") ~= false
                
                local lockGui = child:FindFirstChild("Lock", true)
                local lockVisible = lockGui and lockGui.Visible == true
                
                if isShown and not isPurchased and isEnabled and not lockVisible then
                    local priceLog = Balance.PurchasePrices[cleanName]
                    if priceLog and ascension then
                        local penalty = Huge.pow(Huge.toHuge(ascension:GetAscensionPricePenalty()), ascension:GetAscension())
                        priceLog = Huge.multiply(priceLog, penalty)
                    end
                    
                    local canAfford = priceLog and (cashLog >= priceLog) or false
                    if canAfford then
                        table.insert(list, child)
                    end
                end
            elseif child:IsA("Folder") or child:IsA("Configuration") then
                scan(child)
            end
        end
    end
    
    for _, categoryFolder in ipairs(tycoon.Instance.Purchases:GetChildren()) do
        local buttonsFolder = categoryFolder:FindFirstChild("Buttons")
        if buttonsFolder then
            scan(buttonsFolder)
        end
    end
    return list
end

function TycoonModule.purchaseUpgrade(button)
    button.Purchase:InvokeServer(false)
end

return TycoonModule
