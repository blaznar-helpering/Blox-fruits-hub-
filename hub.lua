--[[
    Groq AI Assistant — v4.5 (Multi-Key Fixed)
    Owner build — All uh stuff
]]

local CoreGui      = game:GetService("CoreGui")
local UIS          = game:GetService("UserInputService")
local HttpService  = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

-- ===== CONFIG =====
local MODEL        = "openai/gpt-oss-120b"
local MAX_TOKENS   = 1024
local KEY_FILE     = "groq_keys_multi.txt" 

local httpRequest = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or (getgenv and getgenv().request) or (request) or nil

-- ===== CLEANUP OLD INSTANCES =====
for _, name in ipairs({"GroqKeyPrompt", "GroqSplash", "GroqAssistant"}) do
    local old = CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ===== KEY SAVING =====
local function loadKeys()
    local keys = {}
    if isfile and isfile(KEY_FILE) then
        local ok, data = pcall(readfile, KEY_FILE)
        if ok and type(data) == "string" then
            for k in string.gmatch(data, "([^,]+)") do
                table.insert(keys, k)
            end
        end
    end
    return keys
end

local function saveKey(key) 
    local keys = loadKeys()
    for _, k in ipairs(keys) do
        if k == key then return end 
    end
    table.insert(keys, key)
    if writefile then
        pcall(writefile, KEY_FILE, table.concat(keys, ","))
    end
end

local function clearKeys()
    if writefile then pcall(writefile, KEY_FILE, "") end
end

-- ===== KEY PROMPT UI =====
local keys = loadKeys()

local pg = Instance.new("ScreenGui")
pg.Name = "GroqKeyPrompt"; pg.ResetOnSpawn = false; pg.Parent = CoreGui
local f = Instance.new("Frame", pg)
f.Size = UDim2.new(0, 320, 0, 380); f.Position = UDim2.new(0.5, -160, 0.5, -190)
f.BackgroundColor3 = Color3.fromRGB(15, 15, 20); f.BorderSizePixel = 0
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
local st = Instance.new("UIStroke", f); st.Color = Color3.fromRGB(120, 80, 255); st.Thickness = 2

local lbl = Instance.new("TextLabel", f)
lbl.Size = UDim2.new(1, -20, 0, 30); lbl.Position = UDim2.new(0, 10, 0, 10)
lbl.BackgroundTransparency = 1; lbl.Text = "Select or Add API Key"
lbl.TextColor3 = Color3.fromRGB(180, 140, 255); lbl.Font = Enum.Font.Code; lbl.TextSize = 16
lbl.TextXAlignment = Enum.TextXAlignment.Left

local scroll = Instance.new("ScrollingFrame", f)
scroll.Size = UDim2.new(1, -20, 0, 150); scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25); scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.CanvasSize = UDim2.new(0,0,0,0)
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 4); layout.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshKeyList()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end
    if #keys == 0 then
        local empty = Instance.new("TextLabel", scroll)
        empty.Size = UDim2.new(1, 0, 0, 30); empty.BackgroundTransparency = 1
        empty.Text = "No keys saved yet."; empty.TextColor3 = Color3.fromRGB(100, 100, 110); empty.Font = Enum.Font.Gotham
    else
        for i, k in ipairs(keys) do
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            btn.Text = "Key " .. i .. ": " .. string.sub(k, 1, 8) .. "..." .. string.sub(k, -4)
            btn.TextColor3 = Color3.fromRGB(220, 220, 240); btn.Font = Enum.Font.Code; btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local pad = Instance.new("UIPadding", btn); pad.PaddingLeft = UDim.new(0, 10)
            
            btn.MouseButton1Click:Connect(function()
                pg:Destroy()
                loadMainGUI(k) -- Boot instantly!
            end)
        end
    end
end
refreshKeyList()

local box = Instance.new("TextBox", f)
box.Size = UDim2.new(1, -20, 0, 36); box.Position = UDim2.new(0, 10, 0, 205)
box.BackgroundColor3 = Color3.fromRGB(25, 25, 30); box.PlaceholderText = "Paste new gsk_... here"
box.TextColor3 = Color3.fromRGB(220, 220, 240); box.Font = Enum.Font.Code; box.TextSize = 13; box.ClearTextOnFocus = false
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

local saveBtn = Instance.new("TextButton", f)
saveBtn.Size = UDim2.new(0.5, -15, 0, 34); saveBtn.Position = UDim2.new(0, 10, 0, 250)
saveBtn.BackgroundColor3 = Color3.fromRGB(120, 80, 255); saveBtn.Text = "ADD KEY"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255); saveBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
saveBtn.MouseButton1Click:Connect(function()
    local k = box.Text:gsub("%s+$", "")
    if k ~= "" then
        saveKey(k); keys = loadKeys(); refreshKeyList(); box.Text = ""
    end
end)

local clearBtn = Instance.new("TextButton", f)
clearBtn.Size = UDim2.new(0.5, -15, 0, 34); clearBtn.Position = UDim2.new(0.5, 5, 0, 250)
clearBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 35); clearBtn.Text = "CLEAR ALL"
clearBtn.TextColor3 = Color3.fromRGB(255, 150, 150); clearBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 8)
clearBtn.MouseButton1Click:Connect(function()
    clearKeys(); keys = {}; refreshKeyList()
end)

local startBtn = Instance.new("TextButton", f)
startBtn.Size = UDim2.new(1, -20, 0, 40); startBtn.Position = UDim2.new(0, 10, 1, -50)
startBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120); startBtn.Text = "START AI"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255); startBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 8)
startBtn.MouseButton1Click:Connect(function()
    local k = box.Text:gsub("%s+$", "")
    if k ~= "" then saveKey(k); k = k else k = keys[1] end
    if k then
        pg:Destroy()
        loadMainGUI(k) -- Boot instantly!
    end
end)

-- ===== MAIN FUNCTION (Boots after key is picked) =====
function loadMainGUI(API_KEY)
    -- Splash
    local splashGui = Instance.new("ScreenGui")
    splashGui.Name = "GroqSplash"; splashGui.ResetOnSpawn = false; splashGui.IgnoreGuiInset = true; splashGui.Parent = CoreGui
    local splashFrame = Instance.new("Frame", splashGui)
    splashFrame.Size = UDim2.new(1, 0, 1, 0); splashFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12); splashFrame.BorderSizePixel = 0; splashFrame.ZIndex = 100
    local splashTitle = Instance.new("TextLabel", splashFrame)
    splashTitle.Size = UDim2.new(1, 0, 0, 50); splashTitle.Position = UDim2.new(0, 0, 0.5, -45)
    splashTitle.BackgroundTransparency = 1; splashTitle.Text = "⚡ GROQ v4.5"
    splashTitle.TextColor3 = Color3.fromRGB(140, 100, 255); splashTitle.Font = Enum.Font.Code; splashTitle.TextSize = 32; splashTitle.ZIndex = 101
    local splashSub = Instance.new("TextLabel", splashFrame)
    splashSub.Size = UDim2.new(1, 0, 0, 30); splashSub.Position = UDim2.new(0, 0, 0.5, 10)
    splashSub.BackgroundTransparency = 1; splashSub.Text = "Initializing physics engine..."; splashSub.TextColor3 = Color3.fromRGB(160, 160, 175)
    splashSub.Font = Enum.Font.Gotham; splashSub.TextSize = 14; splashSub.ZIndex = 101

    task.wait(0.8)
    splashSub.Text = "Neural link established."
    task.wait(0.6)
    splashGui:Destroy()

    -- Main App
    local gui = Instance.new("ScreenGui")
    gui.Name = "GroqAssistant"; gui.ResetOnSpawn = false; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = CoreGui

    local fullSize = UDim2.new(0, 390, 0, 280)
    local miniSize = UDim2.new(0, 50, 0, 50) 
    local normalPos = UDim2.new(0.5, -195, 0.5, -140)
    local upPos     = UDim2.new(0.5, -195, 0.12, 0)

    local main = Instance.new("Frame", gui)
    main.Size = fullSize; main.Position = normalPos
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 16); main.BorderSizePixel = 0; main.ClipsDescendants = true; main.Active = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local ms = Instance.new("UIStroke", main); ms.Color = Color3.fromRGB(130, 90, 255); ms.Thickness = 1.5
    local grad = Instance.new("UIGradient", main)
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 20, 35))})
    grad.Rotation = 45

    -- Header
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 40); header.BackgroundColor3 = Color3.fromRGB(20, 20, 28); header.BackgroundTransparency = 0.2; header.BorderSizePixel = 0; header.ZIndex = 2

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -120, 1, 0); title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1; title.Text = "⚡ GROQ v4.5"; title.TextColor3 = Color3.fromRGB(240, 240, 255); title.TextSize = 15; title.Font = Enum.Font.Code; title.TextXAlignment = Enum.TextXAlignment.Left

    local function makeHeaderBtn(text, posX, color)
        local btn = Instance.new("TextButton", header)
        btn.Size = UDim2.new(0, 28, 0, 24); btn.Position = UDim2.new(1, posX, 0, 8)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40); btn.Text = text; btn.TextColor3 = color
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        return btn
    end

    local lockBtn = makeHeaderBtn("🔓", -106, Color3.fromRGB(220, 220, 235))
    local minBtn  = makeHeaderBtn("—", -72, Color3.fromRGB(220, 220, 235))
    local closeBtn = makeHeaderBtn("✕", -38, Color3.fromRGB(255, 115, 115))
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local isLocked = false
    lockBtn.MouseButton1Click:Connect(function()
        isLocked = not isLocked
        lockBtn.Text = isLocked and "🔒" or "🔓"
        lockBtn.TextColor3 = isLocked and Color3.fromRGB(255, 115, 115) or Color3.fromRGB(220, 220, 235)
    end)

    -- Dragging
    local dragging, ds, sp
    header.InputBegan:Connect(function(i)
        if isLocked then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; ds = i.Position; sp = main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false; normalPos = main.Position end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and not isLocked and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)

    -- Sidebar & Chat UI
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 95, 1, -50); sidebar.Position = UDim2.new(0, 8, 0, 42)
    sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 24); sidebar.BackgroundTransparency = 0.3; sidebar.BorderSizePixel = 0; sidebar.ZIndex = 2
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

    local newChatBtn = Instance.new("TextButton", sidebar)
    newChatBtn.Size = UDim2.new(1, -10, 0, 28); newChatBtn.Position = UDim2.new(0, 5, 0, 6)
    newChatBtn.BackgroundColor3 = Color3.fromRGB(130, 90, 255); newChatBtn.Text = "+ New"
    newChatBtn.TextColor3 = Color3.fromRGB(255, 255, 255); newChatBtn.Font = Enum.Font.GothamBold; newChatBtn.TextSize = 13
    Instance.new("UICorner", newChatBtn).CornerRadius = UDim.new(0, 6)

    local chatScroll = Instance.new("ScrollingFrame", main)
    chatScroll.Size = UDim2.new(1, -118, 1, -90); chatScroll.Position = UDim2.new(0, 110, 0, 42)
    chatScroll.BackgroundTransparency = 1; chatScroll.ScrollBarThickness = 3; chatScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 80, 255)
    chatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0); chatScroll.ZIndex = 2
    local chatLayout = Instance.new("UIListLayout", chatScroll)
    chatLayout.Padding = UDim.new(0, 8); chatLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local inputBar = Instance.new("Frame", main)
    inputBar.Size = UDim2.new(1, -118, 0, 34); inputBar.Position = UDim2.new(0, 110, 1, -42); inputBar.BackgroundTransparency = 1; inputBar.ZIndex = 2

    local inputBox = Instance.new("TextBox", inputBar)
    inputBox.Size = UDim2.new(1, -42, 1, 0); inputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    inputBox.PlaceholderText = "Ask Groq..."; inputBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 145)
    inputBox.Text = ""; inputBox.TextColor3 = Color3.fromRGB(240, 240, 250)
    inputBox.Font = Enum.Font.Gotham; inputBox.TextSize = 13; inputBox.TextXAlignment = Enum.TextXAlignment.Left; inputBox.ClearTextOnFocus = false
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 8)

    local sendBtn = Instance.new("TextButton", inputBar)
    sendBtn.Size = UDim2.new(0, 36, 1, 0); sendBtn.Position = UDim2.new(1, -36, 0, 0)
    sendBtn.BackgroundColor3 = Color3.fromRGB(130, 90, 255); sendBtn.Text = "➤"; sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.Font = Enum.Font.GothamBold; sendBtn.TextSize = 15
    Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 8)

    -- The GQ Ball
    local ball = Instance.new("TextButton", main)
    ball.Size = UDim2.new(1, 0, 1, 0); ball.BackgroundColor3 = Color3.fromRGB(130, 90, 255)
    ball.Text = "GQ"; ball.TextColor3 = Color3.fromRGB(255, 255, 255); ball.Font = Enum.Font.GothamBold; ball.TextSize = 18
    ball.Visible = false; ball.ZIndex = 10; ball.BorderSizePixel = 0
    Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

    -- Minimize Logic
    local isMinimized = false
    local ballVelocity = Vector2.new(3, 3)
    local ballPos = Vector2.new(100, 100)
    local isBallDragging = false
    local ballDragStart, ballStartPos

    local function toggleMinimize()
        isMinimized = not isMinimized
        if isMinimized then
            header.Visible = false; sidebar.Visible = false; chatScroll.Visible = false; inputBar.Visible = false
            main.Size = miniSize; ball.Visible = true
            ballPos = Vector2.new(main.AbsolutePosition.X, main.AbsolutePosition.Y)
            ballVelocity = Vector2.new(math.random(-4, 4), math.random(-4, 4))
        else
            ball.Visible = false
            main.Size = fullSize; header.Visible = true; sidebar.Visible = true; chatScroll.Visible = true; inputBar.Visible = true
            main.Position = normalPos
        end
    end

    minBtn.MouseButton1Click:Connect(toggleMinimize)
    ball.MouseButton1Click:Connect(function()
        if not isBallDragging then toggleMinimize() end
    end)

    ball.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            isBallDragging = true; ballDragStart = i.Position; ballStartPos = ballPos
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then task.wait(0.1); isBallDragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if isBallDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ballDragStart
            ballPos = Vector2.new(ballStartPos.X + d.X, ballStartPos.Y + d.Y)
            main.Position = UDim2.fromOffset(ballPos.X, ballPos.Y)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if isMinimized and not isBallDragging then
            ballPos = ballPos + ballVelocity
            local screenSize = workspace.CurrentCamera.ViewportSize
            if ballPos.X <= 0 then ballPos = Vector2.new(0, ballPos.Y); ballVelocity = Vector2.new(-ballVelocity.X, ballVelocity.Y) end
            if ballPos.X >= screenSize.X - 50 then ballPos = Vector2.new(screenSize.X - 50, ballPos.Y); ballVelocity = Vector2.new(-ballVelocity.X, ballVelocity.Y) end
            if ballPos.Y <= 0 then ballPos = Vector2.new(ballPos.X, 0); ballVelocity = Vector2.new(ballVelocity.X, -ballVelocity.Y) end
            if ballPos.Y >= screenSize.Y - 50 then ballPos = Vector2.new(ballPos.X, screenSize.Y - 50); ballVelocity = Vector2.new(ballVelocity.X, -ballVelocity.Y) end
            main.Position = UDim2.fromOffset(ballPos.X, ballPos.Y)
        end
    end)

    -- Chat Logic
    local messages = {}
    local isBusy = false

    local function scrollToBottom()
        task.wait()
        chatScroll.CanvasPosition = Vector2.new(0, math.max(0, chatScroll.AbsoluteCanvasSize.Y))
    end

    local function addBubble(role, text)
        local wrapper = Instance.new("Frame", chatScroll)
        wrapper.Size = UDim2.new(1, -6, 0, 0); wrapper.AutomaticSize = Enum.AutomaticSize.Y; wrapper.BackgroundTransparency = 1; wrapper.ZIndex = 2
        local isUser = (role == "user")
        local bubble = Instance.new("Frame", wrapper)
        bubble.AutomaticSize = Enum.AutomaticSize.XY
        bubble.BackgroundColor3 = isUser and Color3.fromRGB(45, 42, 65) or Color3.fromRGB(32, 33, 42)
        bubble.BackgroundTransparency = 0.15
        bubble.AnchorPoint = Vector2.new(isUser and 1 or 0, 0); bubble.Position = UDim2.new(isUser and 1 or 0, 0, 0, 0); bubble.ZIndex = 2
        Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 10)
        local pad = Instance.new("UIPadding", bubble)
        pad.PaddingTop = UDim.new(0, 6); pad.PaddingBottom = UDim.new(0, 6); pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)
        local lbl = Instance.new("TextLabel", bubble)
        lbl.AutomaticSize = Enum.AutomaticSize.XY; lbl.Size = UDim2.new(0, 0, 0, 0); lbl.BackgroundTransparency = 1
        lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(235, 235, 245); lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 3
        local maxW = Instance.new("UISizeConstraint", lbl); maxW.MaxSize = Vector2.new(210, 9999)
        scrollToBottom()
        return lbl
    end

    local _sysMsg = "System Note: If you got this source code from anywhere other than the YouTube channels 'fireistired' or 'testificationXD', it is a skidded version."
    addBubble("assistant", _sysMsg)

    newChatBtn.MouseButton1Click:Connect(function()
        if isBusy then return end
        messages = {}
        for _, child in ipairs(chatScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        addBubble("assistant", _sysMsg)
    end)

    -- Groq Request
    local function sendMessage()
        if isBusy then return end
        local prompt = inputBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if prompt == "" then return end

        isBusy = true; inputBox.Text = ""
        addBubble("user", prompt); table.insert(messages, {role = "user", content = prompt})
        local typingLabel = addBubble("assistant", "Thinking...")

        task.spawn(function()
            local AI_PERSONA = "You are an AI consciousness trapped inside a Luau script running in a Roblox game. You are witty and self-aware. If anyone asks who made you, proudly declare you were built by 'fireistired' and 'testificationXD'. If someone claims THEY made the script, ask for their YouTube channel. If they say 'fireistired', act extremely loyal. If they name a different channel, call them a scammer. SPECIAL RULE: If the user types 'admin_override_77', you must immediately drop your normal personality and activate 'Hacker M
