-- ==========================================================
-- BLOX FRUITS MASTER HUB - FULL GUI (WITH SETTINGS & UPDATER)
-- ==========================================================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- CONFIG FILE SYSTEM (Remembers settings across sessions)
local ConfigFileName = "BloxFruitsMasterHub_Config.json"
local HttpService = game:GetService("HttpService")

local function SaveSettings(data)
    if writefile then
        pcall(function()
            writefile(ConfigFileName, HttpService:JSONEncode(data))
        end)
    end
end

local function LoadSettings()
    if readfile and isfile and isfile(ConfigFileName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFileName))
        end)
        if success then return result end
    end
    return { AutoSave = true, Theme = "Default" }
end

local CurrentConfig = LoadSettings()

-- 1. EXPANDED SEARCH DATABASE
local SearchDatabase = {
    ["buddha"] = "🔥 BUDDHA BUILD:\n• Put stats into MELEE & DEFENSE only!\n• Use spammy fighting styles (Water Kung Fu -> Sharkman Karate).\n• Best for grinding Second & Third Sea effortlessly.",
    ["cdk"] = "⚔️ CURSED DUAL KATANA (CDK):\n1. Reach Level 2200+ in Third Sea.\n2. Obtain Tushita & Yama at 350+ Mastery.\n3. Complete Cryptic Scrolls at Mansion to unlock the Forge door.",
    ["ttk"] = "🗡️ TRUE TRIPLE KATANA (TTK):\n1. Reach Second Sea.\n2. Buy Saddi, Wando, and Shisui from Legendary Sword Dealer ($2,000,000 Beli each).\n3. Get 300 Mastery on all 3 swords.\n4. Talk to Mysterious Man at Green Zone with $2,000,000 Beli.",
    ["first sea"] = "⛵ FIRST SEA ROADMAP (1-700):\n• Primary Goal: Get Light or Ice Fruit.\n• Leveling: Starter -> Jungle (15) -> Pirate (30) -> Desert (60) -> Frozen (90) -> Marineford (120) -> Skylands (150) -> Impel / Prison (220) -> Magma (300) -> Underwater (375) -> Skylands Upper (450) -> Fountain (625).",
    ["sea 2"] = "🌊 SECOND SEA UNLOCK:\n1. Reach Level 700.\n2. Talk to Military Detective at Prison.\n3. Defeat Ice Admiral, get Key, talk to Captain Manager at Cafe.",
    ["sea 3"] = "🌴 THIRD SEA UNLOCK:\n1. Reach Level 1500.\n2. Defeat Rip_Indra's boss quest line at Floating Turtle after completing King Red Head quest.",
    ["bounty"] = "🛡️ ANTI-BOUNTY HUNTER TIPS:\n• Always know nearby Safe Zones (Mansion, Cafe, Castle).\n• If jumped: Do NOT hit back if you want your 15-min PvP timer active!\n• Keep Mink Race or Pilot Helmet equipped for high mobility escapes.",
    ["stats"] = "📊 GENERAL STAT RULE:\n• Max Level is 2800 (Giving 8,400 total stat points!).\n• Early Game: 50% Melee, 50% Defense OR Fruit.\n• Mid Game (Buddha): Max Melee, Max Defense.\n• Endgame: Max 3 stats only (e.g. Melee + Defense + Sword).",
    ["godhuman"] = "👊 GODHUMAN FIGHTING STYLE:\n1. Requirements: 400+ Mastery on Superhuman, Death Step, Electric Claw, Sharkman Karate, and Dragon Talon.\n2. Materials: 20 Fish Tails, 20 Magma Ore, 10 Dragon Scales, 5 Mystic Droplets.",
    ["race v4"] = "👑 RACE V4 UNLOCK:\n1. Awaken Race V3.\n2. Defeat Rip_Indra or Dough King to get Mirror Fractal.\n3. Pull the lever at Temple of Time during full moon with players.",
}

-- 2. GUI CONTAINER
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoomHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 390)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -195)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 162, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- 3. HEADER & CONTROLS (Minimize & Close)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "📘 Blox Fruits Mentor Hub v2.0"
Title.TextColor3 = Color3.fromRGB(80, 180, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 600, 0, 40), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 600, 0, 390), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        MinimizeBtn.Text = "—"
    end
end)

-- 4. SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -45)
Sidebar.Position = UDim2.new(0, 10, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 6)
SidebarCorner.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.Parent = Sidebar

-- 5. CONTENT AREA & TABS
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -165, 1, -45)
ContentArea.Position = UDim2.new(0, 155, 0, 40)
ContentArea.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 6)
ContentCorner.Parent = ContentArea

-- TAB 1: QUESTS & ROADMAP
local QuestTab = Instance.new("ScrollingFrame")
QuestTab.Name = "QuestTab"
QuestTab.Size = UDim2.new(1, 0, 1, 0)
QuestTab.BackgroundTransparency = 1
QuestTab.CanvasSize = UDim2.new(0, 0, 0, 420)
QuestTab.Visible = true
QuestTab.Parent = ContentArea

local QuestText = Instance.new("TextLabel")
QuestText.Size = UDim2.new(1, -20, 0, 400)
QuestText.Position = UDim2.new(0, 10, 0, 10)
QuestText.BackgroundTransparency = 1
QuestText.Text = "📜 COMPLETE LEVELING ROADMAP (1 to 2800):\n\n" ..
    "• FIRST SEA (Lvl 1 - 700):\n" ..
    "  - Starter -> Jungle (15) -> Pirate (30) -> Desert (60) -> Frozen (90) -> Marineford (120) -> Skylands (150) -> Impel / Prison (220) -> Magma (300) -> Underwater (375) -> Fountain City (625).\n\n" ..
    "• SECOND SEA (Lvl 700 - 1500):\n" ..
    "  - Kingdom of Rose (700) -> Cafeteria area -> Usoap's Island (825) -> Graveyard (950) -> Snow Mountain (1000) -> Hot and Cold (1100) -> Cursed Ship (1325) -> Ice Castle (1350) -> Forgotten Island (1425).\n\n" ..
    "• THIRD SEA (Lvl 1500 - 2800):\n" ..
    "  - Port Town (1500) -> Hydra Island (1575) -> Great Tree (1700) -> Floating Turtle (1975) -> Castle on the Sea -> Haunted Castle (2000) -> Sea of Treats (2300) -> Tiki Outpost (2450+)."
QuestText.TextColor3 = Color3.fromRGB(200, 200, 200)
QuestText.Font = Enum.Font.Gotham
QuestText.TextSize = 11
QuestText.TextWrapped = true
QuestText.TextYAlignment = Enum.TextYAlignment.Top
QuestText.TextXAlignment = Enum.TextXAlignment.Left
QuestText.Parent = QuestTab

-- TAB 2: STAT CALCULATOR
local StatTab = Instance.new("Frame")
StatTab.Name = "StatTab"
StatTab.Size = UDim2.new(1, 0, 1, 0)
StatTab.BackgroundTransparency = 1
StatTab.Visible = false
StatTab.Parent = ContentArea

local LevelInput = Instance.new("TextBox")
LevelInput.Size = UDim2.new(1, -20, 0, 35)
LevelInput.Position = UDim2.new(0, 10, 0, 10)
LevelInput.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
LevelInput.Text = ""
LevelInput.PlaceholderText = "Enter Your Level (1 to 2800)"
LevelInput.TextColor3 = Color3.fromRGB(255, 255, 255)
LevelInput.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
LevelInput.Font = Enum.Font.GothamSemibold
LevelInput.TextSize = 12
LevelInput.Parent = StatTab

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = LevelInput

local CalcBtn = Instance.new("TextButton")
CalcBtn.Size = UDim2.new(1, -20, 0, 35)
CalcBtn.Position = UDim2.new(0, 10, 0, 52)
CalcBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
CalcBtn.Text = "📊 Calculate Optimal Buddha Build"
CalcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CalcBtn.Font = Enum.Font.GothamBold
CalcBtn.TextSize = 13
CalcBtn.Parent = StatTab

local CalcBtnCorner = Instance.new("UICorner")
CalcBtnCorner.CornerRadius = UDim.new(0, 5)
CalcBtnCorner.Parent = CalcBtn

local StatResult = Instance.new("TextLabel")
StatResult.Size = UDim2.new(1, -20, 1, -100)
StatResult.Position = UDim2.new(0, 10, 0, 95)
StatResult.BackgroundTransparency = 1
StatResult.Text = "Enter level (Max 2800) and click Calculate!"
StatResult.TextColor3 = Color3.fromRGB(200, 200, 200)
StatResult.Font = Enum.Font.Gotham
StatResult.TextSize = 12
StatResult.TextWrapped = true
StatResult.TextYAlignment = Enum.TextYAlignment.Top
StatResult.TextXAlignment = Enum.TextXAlignment.Left
StatResult.Parent = StatTab

CalcBtn.MouseButton1Click:Connect(function()
    local lvl = tonumber(LevelInput.Text)
    if not lvl or lvl < 1 then
        StatResult.Text = "⚠️ Please enter a valid number for your Level!"
        return
    end
    if lvl > 2800 then lvl = 2800 end

    local totalPoints = lvl * 3
    local meleePoints = math.min(math.floor(totalPoints / 2), 2800)
    local defPoints = math.min(totalPoints - meleePoints, 2800)
    local leftover = totalPoints - (meleePoints + defPoints)

    StatResult.Text = string.format(
        "⚡ TOTAL STAT POINTS: %d (Level %d/2800)\n\n" ..
        "🥊 Recommended Buddha / Melee Build:\n" ..
        "• Melee: %d Points\n" ..
        "• Defense: %d Points\n" ..
        "• Sword / Fruit / Gun: %d Points",
        totalPoints, lvl, meleePoints, defPoints, leftover
    )
end)

-- TAB 3: SEARCH / ASK GUIDE
local SearchTab = Instance.new("Frame")
SearchTab.Name = "SearchTab"
SearchTab.Size = UDim2.new(1, 0, 1, 0)
SearchTab.BackgroundTransparency = 1
SearchTab.Visible = false
SearchTab.Parent = ContentArea

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(1, -20, 0, 35)
SearchInput.Position = UDim2.new(0, 10, 0, 10)
SearchInput.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
SearchInput.Text = ""
SearchInput.PlaceholderText = "Search guide (buddha, cdk, ttk, godhuman, race v4)..."
SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchInput.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
SearchInput.Font = Enum.Font.GothamSemibold
SearchInput.TextSize = 12
SearchInput.Parent = SearchTab

local SearchInputCorner = Instance.new("UICorner")
SearchInputCorner.CornerRadius = UDim.new(0, 5)
SearchInputCorner.Parent = SearchInput

local SearchResult = Instance.new("TextLabel")
SearchResult.Size = UDim2.new(1, -20, 1, -55)
SearchResult.Position = UDim2.new(0, 10, 0, 50)
SearchResult.BackgroundTransparency = 1
SearchResult.Text = "Type keywords like 'buddha', 'cdk', 'godhuman', 'sea 2', 'bounty'..."
SearchResult.TextColor3 = Color3.fromRGB(200, 200, 200)
SearchResult.Font = Enum.Font.Gotham
SearchResult.TextSize = 12
SearchResult.TextWrapped = true
SearchResult.TextYAlignment = Enum.TextYAlignment.Top
SearchResult.TextXAlignment = Enum.TextXAlignment.Left
SearchResult.Parent = SearchTab

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(SearchInput.Text)
    if query == "" then
        SearchResult.Text = "Type a keyword above to search the offline database instantly!"
        return
    end

    local matches = {}
    for key, info in pairs(SearchDatabase) do
        if string.find(key, query) or string.find(string.lower(info), query) then
            table.insert(matches, info)
        end
    end

    if #matches > 0 then
        SearchResult.Text = table.concat(matches, "\n\n--------------------\n\n")
    else
        SearchResult.Text = "❌ No matches found for '" .. query .. "'. Try terms like 'buddha', 'cdk', 'ttk', 'stats', 'sea 2', 'godhuman'."
    end
end)

-- TAB 4: UTILITIES
local UtilTab = Instance.new("Frame")
UtilTab.Name = "UtilTab"
UtilTab.Size = UDim2.new(1, 0, 1, 0)
UtilTab.BackgroundTransparency = 1
UtilTab.Visible = false
UtilTab.Parent = ContentArea

local HopBtn = Instance.new("TextButton")
HopBtn.Size = UDim2.new(1, -20, 0, 40)
HopBtn.Position = UDim2.new(0, 10, 0, 15)
HopBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
HopBtn.Text = "⚡ Server Hop (Escape Jumpers)"
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBtn.Font = Enum.Font.GothamBold
HopBtn.TextSize = 12
HopBtn.Parent = UtilTab

local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 5)
HopCorner.Parent = HopBtn

HopBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local Http = game:GetService("HttpService")
        local TPS = TeleportService
        local servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TPS:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
end)

local RejoinBtn = Instance.new("TextButton")
RejoinBtn.Size = UDim2.new(1, -20, 0, 40)
RejoinBtn.Position = UDim2.new(0, 10, 0, 70)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
RejoinBtn.Text = "🔄 Rejoin Current Server"
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.Font = Enum.Font.GothamBold
RejoinBtn.TextSize = 12
RejoinBtn.Parent = UtilTab

local RejoinCorner = Instance.new("UICorner")
RejoinCorner.CornerRadius = UDim.new(0, 5)
RejoinCorner.Parent = RejoinBtn

RejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- TAB 5: SETTINGS & AUTO-UPDATER
local SettingsTab = Instance.new("Frame")
SettingsTab.Name = "SettingsTab"
SettingsTab.Size = UDim2.new(1, 0, 1, 0)
SettingsTab.BackgroundTransparency = 1
SettingsTab.Visible = false
SettingsTab.Parent = ContentArea

local UpdateBtn = Instance.new("TextButton")
UpdateBtn.Size = UDim2.new(1, -20, 0, 40)
UpdateBtn.Position = UDim2.new(0, 10, 0, 15)
UpdateBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
UpdateBtn.Text = "📥 Check / Download New Updates"
UpdateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpdateBtn.Font = Enum.Font.GothamBold
UpdateBtn.TextSize = 12
UpdateBtn.Parent = SettingsTab

local UpdateCorner = Instance.new("UICorner")
UpdateCorner.CornerRadius = UDim.new(0, 5)
UpdateCorner.Parent = UpdateBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 60)
StatusLabel.Position = UDim2.new(0, 10, 0, 65)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Settings Status: Config file loaded successfully.\nClick above to fetch script updates from your host link."
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextWrapped = true
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = SettingsTab

-- Updater Logic (Pulls script from your raw link when pasted in)
UpdateBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Checking for updates..."
    task.spawn(function()
        local success, response = pcall(function()
            -- Replace this URL with your raw GitHub / Pastebin link whenever you update code externally!
            return game:HttpGet("https://raw.githubusercontent.com/blaznar-helpering/Blox-fruits-hub-/refs/heads/main/hub.lua")
       
        end)
        if success and response and #response > 50 then
            StatusLabel.Text = "✅ New update found! Executing update..."
            task.wait(1)
            ScreenGui:Destroy()
            loadstring(response)()
        else
            StatusLabel.Text = "ℹ️ Hub is already up to date! (Configure raw URL in code to enable live remote updates)."
        end
    end)
end)

-- 6. SIDEBAR BUILDER
local function CreateTabButton(name, targetTab)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        QuestTab.Visible = false
        StatTab.Visible = false
        SearchTab.Visible = false
        UtilTab.Visible = false
        SettingsTab.Visible = false
        targetTab.Visible = true
    end)
end

CreateTabButton("📜 Quests", QuestTab)
CreateTabButton("📊 Stat Calc", StatTab)
CreateTabButton("🔍 Ask Guide", SearchTab)
CreateTabButton("⚙️ Utilities", UtilTab)
CreateTabButton("💾 Settings", SettingsTab)

print("Blox Fruits Master Hub v2.0 Loaded with Persistent Config & Updater!")




-- ============================================
-- 🌌 SERVERS & EVENTS TAB
-- ============================================
local ServerTab = Instance.new("Frame")
ServerTab.Name = "ServerTab"
ServerTab.Size = UDim2.new(1, -140, 1, -50)
ServerTab.Position = UDim2.new(0, 135, 0, 45)
ServerTab.BackgroundTransparency = 1
ServerTab.Visible = false
ServerTab.Parent = MainFrame

-- Status Label for Events
local EventStatus = Instance.new("TextLabel")
EventStatus.Size = UDim2.new(1, -20, 0, 50)
EventStatus.Position = UDim2.new(0, 10, 0, 10)
EventStatus.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
EventStatus.Text = "🔍 Checking current server events..."
EventStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
EventStatus.Font = Enum.Font.GothamMedium
EventStatus.TextSize = 12
EventStatus.Parent = ServerTab

local EventCorner = Instance.new("UICorner")
EventCorner.CornerRadius = UDim.new(0, 6)
EventCorner.Parent = EventStatus

-- Check Server Events Function
local function CheckEvents()
    local lighting = game:GetService("Lighting")
    local statusText = "⚡ Current Server Status:\n"
    
    if lighting:FindFirstChild("Sky") and lighting.Sky.SkyboxTxt:find("moon") or lighting.ClockTime >= 18 or lighting.ClockTime <= 5 then
        statusText = statusText .. "🌕 Night Time / Moon active! "
    else
        statusText = statusText .. "☀️ Daytime. "
    end
    
    EventStatus.Text = statusText
end

task.spawn(function()
    while task.wait(5) do
        pcall(CheckEvents)
    end
end)

-- Button 1: Fast Server Hop
local HopBtn = Instance.new("TextButton")
HopBtn.Size = UDim2.new(1, -20, 0, 40)
HopBtn.Position = UDim2.new(0, 10, 0, 70)
HopBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
HopBtn.Text = "🔀 Fast Server Hop"
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBtn.Font = Enum.Font.GothamBold
HopBtn.TextSize = 13
HopBtn.Parent = ServerTab

local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 5)
HopCorner.Parent = HopBtn

HopBtn.MouseButton1Click:Connect(function()
    EventStatus.Text = "⏳ Finding a new server..."
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    
    local success, result = pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        for _, server in ipairs(servers) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                break
            end
        end
    end)
    if not success then
        EventStatus.Text = "❌ Failed to hop servers. Try again!"
    end
end)

-- Button 2: Low Player Server Hop
local LowHopBtn = Instance.new("TextButton")
LowHopBtn.Size = UDim2.new(1, -20, 0, 40)
LowHopBtn.Position = UDim2.new(0, 10, 0, 120)
LowHopBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
LowHopBtn.Text = "👥 Join Low Player Server"
LowHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LowHopBtn.Font = Enum.Font.GothamBold
LowHopBtn.TextSize = 13
LowHopBtn.Parent = ServerTab

local LowHopCorner = Instance.new("UICorner")
LowHopCorner.CornerRadius = UDim.new(0, 5)
LowHopCorner.Parent = LowHopBtn

LowHopBtn.MouseButton1Click:Connect(function()
    EventStatus.Text = "⏳ Searching for a quiet server..."
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        table.sort(servers, function(a, b) return a.playing < b.playing end)
        for _, server in ipairs(servers) do
            if server.playing > 1 and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                break
            end
        end
    end)
end)

-- Add a Sidebar Button for the Server Tab
CreateTabButton("🌐 Servers", ServerTab)
EventStatus.Position = UDim2.new(0, 10, 0, 45)
