-- =========================================================================
-- BLOX FRUITS HUB - MAIN SCRIPT
-- =========================================================================

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Blox Fruits Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "BloxFruitsHub"})

-- =========================================================================
-- TABS
-- =========================================================================
local MainTab = Window:MakeTab({
    Name = "Main / Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- =========================================================================
-- AUTO FARM SECTION
-- =========================================================================
MainTab:AddParagraph("Auto Farm Status", "Select your farming preferences below.")

local AutoFarmEnabled = false

MainTab:AddToggle({
    Name = "Enable Auto Farm",
    Default = false,
    Callback = function(Value)
        AutoFarmEnabled = Value
        print("Auto Farm set to: " .. tostring(AutoFarmEnabled))
        
        -- Task loop for auto-farming
        task.spawn(function()
            while AutoFarmEnabled do
                task.wait(1)
                -- Add your core auto-farm tween/mob targeting logic here
            end
        end)
    end
})

MainTab:AddDropdown({
    Name = "Select Quest / Mob",
    Default = "Bandit",
    Options = {"Bandit", "Marine", "Monkey", "Gorilla"},
    Callback = function(Value)
        print("Selected target: " .. Value)
    end
})

-- =========================================================================
-- PLAYER STATS SECTION
-- =========================================================================
PlayerTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 250,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end)
    end
})

PlayerTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 350,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end)
    end
})

-- =========================================================================
-- INITIALIZATION
-- =========================================================================
OrionLib:Init()
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Blox Fruits Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "BloxFruitsHub"})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddParagraph("Status", "Test working!")

OrionLib:Init()
