-- loader.lua
-- Loader for Sell Lemons Auto Buy Script 🍋

if game.PlaceId ~= 79268393072444 then
    game.Players.LocalPlayer:Kick("Game not found in database of script!")
    return
end

local githubUser = "Mike-Vision"
local githubRepo = "Sell-Lemon"
local githubBranch = "main"

local baseUrl = _G.SellLemonBaseUrl or string.format("https://raw.githubusercontent.com/%s/%s/%s/src/", githubUser, githubRepo, githubBranch)
local localPath = _G.SellLemonLocalPath -- e.g. "c:/Users/PC/Downloads/script/Sell-Lemon/src/" to load local files for testing

local function loadModule(name)
    local content
    if localPath then
        local filePath = localPath .. name .. ".lua"
        local success, err = pcall(function()
            content = readfile(filePath)
        end)
        if not success then
            error("Failed to load local module: " .. filePath .. " - " .. tostring(err))
        end
    else
        local success, response = pcall(game.HttpGet, game, baseUrl .. name .. ".lua")
        if not success then
            error("Failed to load remote module: " .. name .. " - " .. tostring(response))
        end
        content = response
    end
    
    local fn, err = loadstring(content)
    if not fn then
        error("Failed to parse module: " .. name .. " - " .. tostring(err))
    end
    return fn()
end

local main = loadModule("main")
main(loadModule)
