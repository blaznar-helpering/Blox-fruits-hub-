--[[
    Windows 11 Terraria 2D Master Sandbox Edition
    Designed for GitHub Hosting & Delta Execution
]]--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean duplicate execution GUIs
for _, child in ipairs(playerGui:GetChildren()) do
    if child.Name == "Win11_Terraria_Master" then
        child:Destroy()
    end
end

-- ScreenGui Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Win11_Terraria_Master"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Main Draggable Window Frame
local window = Instance.new("Frame")
window.Size = UDim2.new(0, 420, 0, 350)
window.Position = UDim2.new(0.5, -210, 0.15, 0)
window.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
window.Parent = screenGui

local wCorner = Instance.new("UICorner") wCorner.CornerRadius = UDim.new(0, 10) wCorner.Parent = window
local wStroke = Instance.new("UIStroke") wStroke.Color = Color3.fromRGB(60, 65, 80) wStroke.Thickness = 1 wStroke.Parent = window

-- Drag Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundTransparency = 1
titleBar.Parent = window

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -35, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "🪟 Windows 11 - Terraria 2D Master Sandbox"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
closeBtn.Text = "✕"
closeBtn.TextSize = 12
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function() window.Visible = false end)

-- Touch & Mouse Window Dragging System
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = window.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Game State & Inventory Variables
local pLvl = 1
local pXp = 0
local pMaxXp = 50
local pHp = 100
local pMaxHp = 100

local resources = {
    wood = 20, stone = 20, ironOre = 10, goldOre = 5, demoniteOre = 0, hallowedOre = 0,
    ironBar = 0, goldBar = 0, demoniteBar = 0, hallowedBar = 0,
    coins = 100
}

local equippedWeapon = "Copper Shortsword"
local weaponDps = 10
local weaponClass = "Melee"

local equippedAccessory = "None"
local accessoryBonusDps = 0

local npcs = {
    Guide = true,
    Merchant = false,
    Nurse = false,
    ArmsDealer = false,
    Dryad = false
}

local selectedBuildTile = "Dirt"

-- Boss Roster (Pre-Hardmode, Hardmode, Endgame)
local bossIndex = 1
local bosses = {
    {name = "1. King Slime", hp = 100, maxHp = 100, atk = 6, xp = 30, boost = 5, color = Color3.fromRGB(40, 100, 220)},
    {name = "2. Eye of Cthulhu", hp = 300, maxHp = 300, atk = 14, xp = 60, boost = 10, color = Color3.fromRGB(180, 40, 40)},
    {name = "3. Eater of Worlds", hp = 550, maxHp = 550, atk = 22, xp = 100, boost = 18, color = Color3.fromRGB(80, 50, 120)},
    {name = "4. Queen Bee", hp = 900, maxHp = 900, atk = 35, xp = 200, boost = 28, color = Color3.fromRGB(220, 170, 30)},
    {name = "5. Skeletron", hp = 1500, maxHp = 1500, atk = 50, xp = 350, boost = 45, color = Color3.fromRGB(140, 140, 140)},
    {name = "6. Wall of Flesh", hp = 2500, maxHp = 2500, atk = 75, xp = 600, boost = 80, color = Color3.fromRGB(150, 20, 50)},
    {name = "7. The Twins", hp = 6000, maxHp = 6000, atk = 120, xp = 1200, boost = 180, color = Color3.fromRGB(200, 30, 80)},
    {name = "8. The Destroyer", hp = 12000, maxHp = 12000, atk = 180, xp = 2000, boost = 280, color = Color3.fromRGB(100, 120, 140)},
    {name = "9. Skeletron Prime", hp = 18000, maxHp = 18000, atk = 250, xp = 3000, boost = 400, color = Color3.fromRGB(180, 50, 50)},
    {name = "10. Plantera", hp = 30000, maxHp = 30000, atk = 350, xp = 5000, boost = 600, color = Color3.fromRGB(40, 180, 80)},
    {name = "11. Golem", hp = 50000, maxHp = 50000, atk = 480, xp = 8000, boost = 900, color = Color3.fromRGB(210, 100, 30)},
    {name = "12. Moon Lord", hp = 200000, maxHp = 200000, atk = 900, xp = 25000, boost = 3000, color = Color3.fromRGB(0, 220, 180)}
}

-- Top Main Stats Header
local statsHUD = Instance.new("TextLabel")
statsHUD.Size = UDim2.new(1, -20, 0, 22)
statsHUD.Position = UDim2.new(0, 10, 0, 32)
statsHUD.BackgroundColor3 = Color3.fromRGB(12, 15, 20)
statsHUD.TextColor3 = Color3.fromRGB(255, 255, 255)
statsHUD.Text = "❤️ 100/100 | Lvl: 1 | 🗡️ Copper Shortsword (10 DPS) | 🪙 Coins: 100"
statsHUD.Font = Enum.Font.Gotham
statsHUD.TextSize = 9
statsHUD.Parent = window

-- Navigation Tabs Bar
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 26)
tabContainer.Position = UDim2.new(0, 10, 0, 58)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = window

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabContainer

-- Tab Content Frames
local frames = {}
local function createTab(name, id)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 75, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.Parent = tabContainer
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = btn

    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 0, 250)
    f.Position = UDim2.new(0, 10, 0, 90)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.Parent = window
    frames[id] = f

    btn.MouseButton1Click:Connect(function()
        for _, frame in pairs(frames) do frame.Visible = false end
        f.Visible = true
    end)
end

createTab("⚔️ Combat", "combat")
createTab("⛏️ Gather", "gather")
createTab("🧱 Build", "build")
createTab("🛠️ Craft", "craft")
createTab("🏡 Town", "town")
frames["combat"].Visible = true -- Default Active Tab

local function updateUI()
    local totalDps = weaponDps + accessoryBonusDps
    statsHUD.Text = string.format("❤️ %d/%d | Lvl: %d | 🗡️ %s (%d DPS) | 🪙 Coins: %d", pHp, pMaxHp, pLvl, equippedWeapon, totalDps, resources.coins)
end

local function resetHardcore()
    pLvl = 1 pXp = 0 pMaxXp = 50 pHp = 100 pMaxHp = 100
    resources.wood = 20 resources.stone = 20 resources.coins = 50
    equippedWeapon = "Copper Shortsword" weaponDps = 10
    bossIndex = 1
    for _, b in ipairs(bosses) do b.hp = b.maxHp end
    updateUI()
end

-- ==================== TAB 1: COMBAT & BOSS ARENA ====================
local bossCard = Instance.new("Frame")
bossCard.Size = UDim2.new(1, 0, 0, 70)
bossCard.Position = UDim2.new(0, 0, 0, 5)
bossCard.BackgroundColor3 = bosses[1].color
bossCard.Parent = frames["combat"]
local bcCorner = Instance.new("UICorner") bcCorner.CornerRadius = UDim.new(0, 6) bcCorner.Parent = bossCard

local bossTitle = Instance.new("TextLabel")
bossTitle.Size = UDim2.new(1, 0, 0, 22)
bossTitle.Position = UDim2.new(0, 0, 0, 5)
bossTitle.BackgroundTransparency = 1
bossTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
bossTitle.Text = bosses[1].name
bossTitle.Font = Enum.Font.GothamBold
bossTitle.TextSize = 12
bossTitle.Parent = bossCard

local hpBack = Instance.new("Frame")
hpBack.Size = UDim2.new(0.8, 0, 0, 10)
hpBack.Position = UDim2.new(0.1, 0, 0.65, 0)
hpBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hpBack.Parent = bossCard

local hpFill = Instance.new("Frame")
hpFill.Size = UDim2.new(1, 0, 1, 0)
hpFill.BackgroundColor3 = Color3.fromRGB(40, 200, 60)
hpFill.BorderSizePixel = 0
hpFill.Parent = hpBack

local btnAtk = Instance.new("TextButton")
btnAtk.Size = UDim2.new(1, 0, 0, 45)
btnAtk.Position = UDim2.new(0, 0, 0, 85)
btnAtk.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
btnAtk.TextColor3 = Color3.fromRGB(255, 255, 255)
btnAtk.Text = "⚔️ ATTACK BOSS"
btnAtk.Font = Enum.Font.GothamBold
btnAtk.TextSize = 12
btnAtk.Parent = frames["combat"]
local bAtkC = Instance.new("UICorner") bAtkC.CornerRadius = UDim.new(0, 6) bAtkC.Parent = btnAtk

local btnHeal = Instance.new("TextButton")
btnHeal.Size = UDim2.new(1, 0, 0, 35)
btnHeal.Position = UDim2.new(0, 0, 0, 140)
btnHeal.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
btnHeal.TextColor3 = Color3.fromRGB(255, 255, 255)
btnHeal.Text = "🧪 RESTORE HEALTH (Cost: 🪙 20 Coins)"
btnHeal.Font = Enum.Font.GothamBold
btnHeal.TextSize = 10
btnHeal.Parent = frames["combat"]
local bHealC = Instance.new("UICorner") bHealC.CornerRadius = UDim.new(0, 6) bHealC.Parent = btnHeal

btnAtk.MouseButton1Click:Connect(function()
    local b = bosses[bossIndex]
    local totalDps = weaponDps + accessoryBonusDps
    
    b.hp = math.max(0, b.hp - totalDps)
    pHp = math.max(0, pHp - b.atk)

    if pHp <= 0 then
        resetHardcore()
        return
    end

    if b.hp <= 0 then
        pXp = pXp + b.xp
        resources.coins = resources.coins + math.floor(b.xp * 1.5)
        if pXp >= pMaxXp then
            pLvl = pLvl + 1
            pMaxXp = math.floor(pMaxXp * 1.5)
            pMaxHp = pMaxHp + 25
            pHp = pMaxHp
        end
        
        if bossIndex < #bosses then
            bossIndex = bossIndex + 1
        else
            b.hp = b.maxHp
        end
    end

    local currentB = bosses[bossIndex]
    bossTitle.Text = currentB.name .. " (Deals " .. currentB.atk .. " Atk)"
    bossCard.BackgroundColor3 = currentB.color
    hpFill.Size = UDim2.new(math.clamp(currentB.hp / currentB.maxHp, 0, 1), 0, 1, 0)
    updateUI()
end)

btnHeal.MouseButton1Click:Connect(function()
    if resources.coins >= 20 then
        resources.coins = resources.coins - 20
        pHp = pMaxHp
        updateUI()
    end
end)

-- ==================== TAB 2: MINING & GATHERING ====================
local resLabel = Instance.new("TextLabel")
resLabel.Size = UDim2.new(1, 0, 0, 25)
resLabel.BackgroundTransparency = 1
resLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
resLabel.Text = "🪵 Wood: 20 | 🪨 Stone: 20 | ⛏️ Iron Ore: 10 | 🪙 Gold Ore: 5"
resLabel.Font = Enum.Font.GothamBold
resLabel.TextSize = 9
resLabel.Parent = frames["gather"]

local function createGatherRow(name, color, yPos, resourceKey, yield)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = frames["gather"]
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        resources[resourceKey] = resources[resourceKey] + yield
        resLabel.Text = string.format("🪵 Wood: %d | 🪨 Stone: %d | ⛏️ Iron: %d | 🪙 Gold: %d", resources.wood, resources.stone, resources.ironOre, resources.goldOre)
        updateUI()
    end)
end

createGatherRow("🌲 Chop Trees (+3 Wood)", Color3.fromRGB(120, 70, 20), 35, "wood", 3)
createGatherRow("🪨 Mine Stone Quarry (+3 Stone)", Color3.fromRGB(90, 100, 110), 80, "stone", 3)
createGatherRow("⛏️ Dig Iron Vein (+2 Iron Ore)", Color3.fromRGB(70, 80, 95), 125, "ironOre", 2)
createGatherRow("🪙 Mine Gold Vein (+1 Gold Ore)", Color3.fromRGB(180, 140, 20), 170, "goldOre", 1)

-- ==================== TAB 3: 2D BUILDING GRID ====================
local tilePalette = {"Dirt", "Wood", "Stone", "Brick"}
local tileColors = {Dirt = Color3.fromRGB(120, 80, 40), Wood = Color3.fromRGB(150, 100, 40), Stone = Color3.fromRGB(100, 100, 100), Brick = Color3.fromRGB(180, 60, 40)}

local palHolder = Instance.new("Frame")
palHolder.Size = UDim2.new(1, 0, 0, 25)
palHolder.BackgroundTransparency = 1
palHolder.Parent = frames["build"]

local palLayout = Instance.new("UIListLayout")
palLayout.FillDirection = Enum.FillDirection.Horizontal
palLayout.Padding = UDim.new(0, 4)
palLayout.Parent = palHolder

for _, tName in ipairs(tilePalette) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 85, 1, 0)
    b.BackgroundColor3 = tileColors[tName]
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = tName
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.Parent = palHolder
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = b
    
    b.MouseButton1Click:Connect(function()
        selectedBuildTile = tName
    end)
end

-- 8x5 Tile Grid Screen
local gridFrame = Instance.new("Frame")
gridFrame.Size = UDim2.new(1, 0, 0, 180)
gridFrame.Position = UDim2.new(0, 0, 0, 35)
gridFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
gridFrame.Parent = frames["build"]
local gfC = Instance.new("UICorner") gfC.CornerRadius = UDim.new(0, 6) gfC.Parent = gridFrame

local gLayout = Instance.new("UIGridLayout")
gLayout.CellSize = UDim2.new(0, 42, 0, 32)
gLayout.CellPadding = UDim2.new(0, 4, 0, 4)
gLayout.Parent = gridFrame

for i = 1, 40 do
    local tileBtn = Instance.new("TextButton")
    tileBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    tileBtn.Text = ""
    tileBtn.Parent = gridFrame
    
    tileBtn.MouseButton1Click:Connect(function()
        if tileBtn.BackgroundColor3 == tileColors[selectedBuildTile] then
            tileBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 45) -- Erase
        else
            tileBtn.BackgroundColor3 = tileColors[selectedBuildTile] -- Build
        end
    end)
end

-- ==================== TAB 4: MULTI-TIER CRAFTING ====================
local craftScroll = Instance.new("ScrollingFrame")
craftScroll.Size = UDim2.new(1, 0, 1, 0)
craftScroll.CanvasSize = UDim2.new(0, 0, 0, 320)
craftScroll.BackgroundTransparency = 1
craftScroll.Parent = frames["craft"]

local cList = Instance.new("UIListLayout")
cList.Padding = UDim.new(0, 6)
cList.Parent = craftScroll

local function addCraftRecipe(name, reqText, costCheck, applyCraft)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 42, 56)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name .. "\n(" .. reqText .. ")"
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 9
    btn.Parent = craftScroll
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if costCheck() then
            applyCraft()
            updateUI()
        end
    end)
end

addCraftRecipe("🧱 Smelt Iron Bars (+1 Iron Bar)", "2 Iron Ore", 
    function() return resources.ironOre >= 2 end, 
    function() resources.ironOre = resources.ironOre - 2 resources.ironBar = resources.ironBar + 1 end)

addCraftRecipe("🪙 Smelt Gold Bars (+1 Gold Bar)", "2 Gold Ore", 
    function() return resources.goldOre >= 2 end, 
    function() resources.goldOre = resources.goldOre - 2 resources.goldBar = resources.goldBar + 1 end)

addCraftRecipe("⚔️ Craft Iron Broadsword (35 DPS)", "5 Iron Bars, 10 Wood", 
    function() return resources.ironBar >= 5 and resources.wood >= 10 end, 
    function() resources.ironBar = resources.ironBar - 5 resources.wood = resources.wood - 10 equippedWeapon = "Iron Broadsword" weaponDps = 35 end)

addCraftRecipe("🪄 Craft Gold Staff (65 DPS)", "5 Gold Bars, 15 Stone", 
    function() return resources.goldBar >= 5 and resources.stone >= 15 end, 
    function() resources.goldBar = resources.goldBar - 5 resources.stone = resources.stone - 15 equippedWeapon = "Gold Staff" weaponDps = 65 end)

addCraftRecipe("⚡ Craft Terra Blade (250 DPS)", "10 Demonite Bars, 10 Hallowed Bars", 
    function() return resources.demoniteBar >= 10 and resources.hallowedBar >= 10 end, 
    function() resources.demoniteBar = resources.demoniteBar - 10 resources.hallowedBar = resources.hallowedBar - 10 equippedWeapon = "Terra Blade" weaponDps = 250 end)

addCraftRecipe("🌟 Craft Zenith (1000 DPS)", "50 Gold Bars, 50 Demonite Bars", 
    function() return resources.goldBar >= 50 and resources.demoniteBar >= 50 end, 
    function() resources.goldBar = resources.goldBar - 50 resources.demoniteBar = resources.demoniteBar - 50 equippedWeapon = "Zenith" weaponDps = 1000 end)
  
addCraftRecipe("🛡️ Craft Ankh Shield (+50% Max HP)", "20 Iron Bars, 10 Gold Bars", 
    function() return resources.ironBar >= 20 and resources.goldBar >= 10 end, 
    function() 
        resources.ironBar = resources.ironBar - 20 
        resources.goldBar = resources.goldBar - 10 
        maxHp = maxHp + 100 
        pHp = maxHp 
    end)

addCraftRecipe("🔥 Craft Solar Eruption (450 DPS)", "15 Hallowed Bars, 30 Gold Ore", 
    function() return resources.hallowedBar >= 15 and resources.goldOre >= 30 end, 
    function() 
        resources.hallowedBar = resources.hallowedBar - 15 
        resources.goldOre = resources.goldOre - 30 
        equippedWeapon = "Solar Eruption" 
        weaponDps = 450 
    end)

addCraftRecipe("🌟 Craft Star Wrath (750 DPS)", "20 Hallowed Bars, 50 Iron Bars", 
    function() return resources.hallowedBar >= 20 and resources.ironBar >= 50 end, 
    function() 
        resources.hallowedBar = resources.hallowedBar - 20 
        resources.ironBar = resources.ironBar - 50 
        equippedWeapon = "Star Wrath" 
        weaponDps = 750 
    end)

-- ==================== TAB 5: TOWN & NPCS ====================
local townLabel = Instance.new("TextLabel")
townLabel.Size = UDim2.new(1, 0, 0, 30)
townLabel.BackgroundTransparency = 1
townLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
townLabel.Text = "🏡 Town Housing & Active NPCs"
townLabel.Font = Enum.Font.GothamBold
townLabel.TextSize = 11
townLabel.Parent = frames["town"]

local npcGrid = Instance.new("Frame")
npcGrid.Size = UDim2.new(1, 0, 0, 180)
npcGrid.Position = UDim2.new(0, 0, 0, 35)
npcGrid.BackgroundTransparency = 1
npcGrid.Parent = frames["town"]

local npcLayout = Instance.new("UIGridLayout")
npcLayout.CellSize = UDim2.new(0, 120, 0, 50)
npcLayout.CellPadding = UDim2.new(0, 8, 0, 8)
npcLayout.Parent = npcGrid

local function addNpcCard(name, desc, costWood)
    local card = Instance.new("TextButton")
    card.BackgroundColor3 = Color3.fromRGB(35, 42, 56)
    card.TextColor3 = Color3.fromRGB(255, 255, 255)
    card.Text = name .. "\n(" .. desc .. ")"
    card.Font = Enum.Font.GothamBold
    card.TextSize = 8
    card.Parent = npcGrid
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = card

    card.MouseButton1Click:Connect(function()
        if resources.wood >= costWood then
            resources.wood = resources.wood - costWood
            npcs[name] = true
            card.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
            updateUI()
        end
    end)
end

addNpcCard("Merchant", "Shop Items\nCost: 20 Wood", 20)
addNpcCard("Nurse", "Instant Heal\nCost: 30 Wood", 30)
addNpcCard("Arms Dealer", "Guns & Ammo\nCost: 40 Wood", 40)
addNpcCard("Dryad", "+20% Max HP\nCost: 50 Wood", 50)

print("Windows 11 Master Terraria Script Loaded Successfully!")
