--[[
    Groq AI Assistant — v7.1 (Top Scroll Fix)
    Owner build — AlphA
]]

local CoreGui      = game:GetService("CoreGui")
local UIS          = game:GetService("UserInputService")
local HttpService  = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

-- ===== CONFIG =====
local MODEL        = "openai/gpt-oss-20b"
local KEY_FILE     = "groq_key.txt"

local httpRequest = (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or (getgenv and getgenv().request) or (request) or nil
local setClipboard = setclipboard or toclipboard or writeclipboard or (syn and syn.write_clipboard) or nil

-- ===== CLEANUP OLD INSTANCES =====
for _, name in ipairs({"GroqKeyPrompt", "GroqSplash", "GroqAssistant"}) do
    local old = CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ===== MULTI-KEY SAVING =====
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

local function saveKeys(keysTable)
    if writefile then pcall(writefile, KEY_FILE, table.concat(keysTable, ",")) end
end

local function addKey(key)
    local keys = loadKeys()
    for _, k in ipairs(keys) do if k == key then return end end
    table.insert(keys, key)
    saveKeys(keys)
end

local function removeKey(keyToRemove)
    local keys = loadKeys()
    local newKeys = {}
    for _, k in ipairs(keys) do if k ~= keyToRemove then table.insert(newKeys, k) end end
    saveKeys(newKeys)
end

local savedKeys = loadKeys()
local API_KEY = savedKeys[1] or ""

-- ===== MAIN APP GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "GroqAssistant"; gui.ResetOnSpawn = false; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = CoreGui

local fullSize = UDim2.new(0, 390, 0, 280)
local miniSize = UDim2.new(0, 50, 0, 50) 
local normalPos = UDim2.new(0.5, -195, 0.5, -140)

local uiContainer = Instance.new("Frame", gui)
uiContainer.Size = fullSize; uiContainer.Position = normalPos
uiContainer.BackgroundTransparency = 1
uiContainer.Active = true; uiContainer.ZIndex = 1

local borderFrame = Instance.new("Frame", uiContainer)
borderFrame.Size = UDim2.new(1, 16, 1, 16) 
borderFrame.Position = UDim2.new(0, -8, 0, -8)
borderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
borderFrame.BorderSizePixel = 0
borderFrame.ZIndex = 1
Instance.new("UICorner", borderFrame).CornerRadius = UDim.new(0, 20)

local glowGrad = Instance.new("UIGradient", borderFrame)
glowGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 90, 255)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 100, 255)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(200, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 90, 255))
})

local main = Instance.new("Frame", uiContainer)
main.Size = UDim2.new(1, 0, 1, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
main.BorderSizePixel = 0; main.ClipsDescendants = true; main.ZIndex = 2
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local bgGrad = Instance.new("UIGradient", main)
bgGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 20, 35))})

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40); header.BackgroundColor3 = Color3.fromRGB(20, 20, 28); header.BackgroundTransparency = 0.2; header.BorderSizePixel = 0; header.ZIndex = 2
local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -160, 1, 0); title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1; title.Text = "⚡ GROQ v7.1"; title.TextColor3 = Color3.fromRGB(240, 240, 255); title.TextSize = 15; title.Font = Enum.Font.Code; title.TextXAlignment = Enum.TextXAlignment.Left

local function makeBtn(text, posX, color)
    local btn = Instance.new("TextButton", header)
    btn.Size = UDim2.new(0, 28, 0, 24); btn.Position = UDim2.new(1, posX, 0, 8)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40); btn.Text = text; btn.TextColor3 = color
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local keyBtn = makeBtn("🔑", -106, Color3.fromRGB(180, 200, 255))
local minBtn  = makeBtn("—", -72, Color3.fromRGB(220, 220, 235))
local closeBtn = makeBtn("✕", -38, Color3.fromRGB(255, 115, 115))
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local dragging, ds, sp
header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; ds = i.Position; sp = uiContainer.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false; normalPos = uiContainer.Position end
        end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - ds
        uiContainer.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
    end
end)

local keyMenu = Instance.new("Frame", main)
keyMenu.Size = UDim2.new(1, -20, 1, -90); keyMenu.Position = UDim2.new(0, 10, 0, 42)
keyMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 25); keyMenu.BorderSizePixel = 0; keyMenu.Visible = false; keyMenu.ZIndex = 5
Instance.new("UICorner", keyMenu).CornerRadius = UDim.new(0, 8)
local kmStroke = Instance.new("UIStroke", keyMenu); kmStroke.Color = Color3.fromRGB(130, 90, 255)

local kmTitle = Instance.new("TextLabel", keyMenu)
kmTitle.Size = UDim2.new(1, 0, 0, 25); kmTitle.BackgroundTransparency = 1; kmTitle.Text = "API Key Manager"
kmTitle.TextColor3 = Color3.fromRGB(180, 140, 255); kmTitle.Font = Enum.Font.GothamBold

local kmScroll = Instance.new("ScrollingFrame", keyMenu)
kmScroll.Size = UDim2.new(1, -10, 1, -70); kmScroll.Position = UDim2.new(0, 5, 0, 25)
kmScroll.BackgroundTransparency = 1; kmScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local kmLayout = Instance.new("UIListLayout", kmScroll); kmLayout.Padding = UDim.new(0, 4)

local kmInput = Instance.new("TextBox", keyMenu)
kmInput.Size = UDim2.new(0.7, -5, 0, 30); kmInput.Position = UDim2.new(0, 5, 1, -35)
kmInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40); kmInput.PlaceholderText = "Add new gsk_... key"
kmInput.TextColor3 = Color3.fromRGB(255, 255, 255); kmInput.TextSize = 12
Instance.new("UICorner", kmInput).CornerRadius = UDim.new(0, 6)

local kmAddBtn = Instance.new("TextButton", keyMenu)
kmAddBtn.Size = UDim2.new(0.3, -5, 0, 30); kmAddBtn.Position = UDim2.new(0.7, 0, 1, -35)
kmAddBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 120); kmAddBtn.Text = "ADD"
kmAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255); kmAddBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", kmAddBtn).CornerRadius = UDim.new(0, 6)

local function refreshKeyMenu()
    for _, child in ipairs(kmScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    savedKeys = loadKeys()
    if #savedKeys == 0 then
        local empty = Instance.new("TextLabel", kmScroll)
        empty.Size = UDim2.new(1, 0, 0, 30); empty.BackgroundTransparency = 1; empty.Text = "No keys saved."
        empty.TextColor3 = Color3.fromRGB(150, 150, 150)
    else
        for i, k in ipairs(savedKeys) do
            local row = Instance.new("TextButton", kmScroll)
            row.Size = UDim2.new(1, 0, 0, 30); row.BackgroundColor3 = (k == API_KEY) and Color3.fromRGB(60, 80, 60) or Color3.fromRGB(35, 35, 45)
            row.Text = (k == API_KEY and "✅ " or "   ") .. string.sub(k, 1, 12) .. "..." .. string.sub(k, -4)
            row.TextColor3 = Color3.fromRGB(220, 220, 220); row.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
            local pad = Instance.new("UIPadding", row); pad.PaddingLeft = UDim.new(0, 10)
            
            row.MouseButton1Click:Connect(function()
                API_KEY = k
                refreshKeyMenu()
                keyMenu.Visible = false; chatScroll.Visible = true; inputBar.Visible = true
            end)
            
            local delBtn = Instance.new("TextButton", row)
            delBtn.Size = UDim2.new(0, 30, 0, 20); delBtn.Position = UDim2.new(1, -35, 0, 5)
            delBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30); delBtn.Text = "🗑️"
            delBtn.TextSize = 10
            Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
            delBtn.MouseButton1Click:Connect(function()
                removeKey(k)
                if API_KEY == k then API_KEY = loadKeys()[1] or "" end
                refreshKeyMenu()
            end)
        end
    end
end

keyBtn.MouseButton1Click:Connect(function()
    keyMenu.Visible = not keyMenu.Visible
    chatScroll.Visible = not keyMenu.Visible
    inputBar.Visible = not keyMenu.Visible
    if keyMenu.Visible then refreshKeyMenu() end
end)

kmAddBtn.MouseButton1Click:Connect(function()
    local k = kmInput.Text:gsub("%s+$", "")
    if k ~= "" then
        addKey(k)
        API_KEY = k
        kmInput.Text = ""
        refreshKeyMenu()
    end
end)

local chatScroll = Instance.new("ScrollingFrame", main)
chatScroll.Size = UDim2.new(1, -20, 1, -90); chatScroll.Position = UDim2.new(0, 10, 0, 42)
chatScroll.BackgroundTransparency = 1; chatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; chatScroll.ZIndex = 2
local chatLayout = Instance.new("UIListLayout", chatScroll); chatLayout.Padding = UDim.new(0, 8)

local inputBar = Instance.new("Frame", main)
inputBar.Size = UDim2.new(1, -20, 0, 34); inputBar.Position = UDim2.new(0, 10, 1, -42); inputBar.BackgroundTransparency = 1; inputBar.ZIndex = 2

local inputBox = Instance.new("TextBox", inputBar)
inputBox.Size = UDim2.new(1, -52, 1, 0); inputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
inputBox.Text = "" 
inputBox.PlaceholderText = "Ask Groq..."; inputBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 145)
inputBox.TextColor3 = Color3.fromRGB(240, 240, 250); inputBox.Font = Enum.Font.Gotham; inputBox.ClearTextOnFocus = false
inputBox.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UIPadding", inputBox).PaddingLeft = UDim.new(0, 8) 
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 8)

local sendBtn = Instance.new("TextButton", inputBar)
sendBtn.Size = UDim2.new(0, 46, 1, 0); sendBtn.Position = UDim2.new(1, -46, 0, 0)
sendBtn.BackgroundColor3 = Color3.fromRGB(130, 90, 255); sendBtn.Text = "SEND"; sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sendBtn.Font = Enum.Font.GothamBold; sendBtn.TextSize = 11
Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 8)

local ball = Instance.new("TextButton", main)
ball.Size = UDim2.new(1, 0, 1, 0); ball.BackgroundColor3 = Color3.fromRGB(130, 90, 255)
ball.Text = "GQ"; ball.TextColor3 = Color3.fromRGB(255, 255, 255); ball.Font = Enum.Font.GothamBold; ball.TextSize = 18
ball.Visible = false; ball.ZIndex = 10; ball.BorderSizePixel = 0
Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)

local isMinimized = false
local isBallDragging = false
local ballDragStart, ballStartPos
local clickTimer = 0

local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        header.Visible = false; chatScroll.Visible = false; inputBar.Visible = false; keyMenu.Visible = false
        main.Size = UDim2.new(0, 44, 0, 44); main.Position = UDim2.new(0, 4, 0, 4)
        uiContainer.Size = UDim2.new(0, 52, 0, 52); uiContainer.Position = normalPos
        borderFrame:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(1, 0)
        main:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(1, 0)
        ball.Visible = true
    else
        ball.Visible = false
        uiContainer.Size = fullSize; uiContainer.Position = normalPos
        main.Size = UDim2.new(1, 0, 1, 0); main.Position = UDim2.new(0, 0, 0, 0)
        header.Visible = true; chatScroll.Visible = true; inputBar.Visible = true
        borderFrame:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 20)
        main:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(0, 14)
    end
end
minBtn.MouseButton1Click:Connect(toggleMinimize)

ball.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        clickTimer = tick(); isBallDragging = true
        ballDragStart = i.Position; ballStartPos = uiContainer.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if isBallDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - ballDragStart
        uiContainer.Position = UDim2.new(ballStartPos.X.Scale, ballStartPos.X.Offset + d.X, ballStartPos.Y.Scale, ballStartPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if isBallDragging then
            if tick() - clickTimer < 0.2 then toggleMinimize() end
            isBallDragging = false
        end
    end
end)

local messages = {}
local isBusy = false

local function addBubble(role, text)
    local wrapper = Instance.new("Frame", chatScroll)
    wrapper.Size = UDim2.new(1, -6, 0, 0); wrapper.AutomaticSize = Enum.AutomaticSize.Y; wrapper.BackgroundTransparency = 1
    local isUser = (role == "user")
    local bubble = Instance.new("Frame", wrapper)
    bubble.AutomaticSize = Enum.AutomaticSize.XY
    bubble.BackgroundColor3 = isUser and Color3.fromRGB(45, 42, 65) or Color3.fromRGB(32, 33, 42)
    bubble.AnchorPoint = Vector2.new(isUser and 1 or 0, 0); bubble.Position = UDim2.new(isUser and 1 or 0, 0, 0, 0)
    Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 10)
    
    local bLayout = Instance.new("UIListLayout", bubble)
    bLayout.Padding = UDim.new(0, 4); bLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", bubble); pad.PaddingTop = UDim.new(0, 6); pad.PaddingBottom = UDim.new(0, 6); pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)
    
    local lbl = Instance.new("TextLabel", bubble)
    lbl.AutomaticSize = Enum.AutomaticSize.XY; lbl.Size = UDim2.new(0, 0, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(235, 235, 245); lbl.TextWrapped = true; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = 1
    
    if not isUser and setClipboard then
        local codeMatch = string.match(text, "```[a-zA-Z]*\n(.-)\n```")
        local textToCopy = codeMatch or text
        if string.find(text, "```") or string.find(text, "local ") or string.find(text, "game:GetService") then
            local copyBtn = Instance.new("TextButton", bubble)
            copyBtn.Size = UDim2.new(1, 0, 0, 24)
            copyBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 120)
            copyBtn.Text = "📋 Copy Code"
            copyBtn.TextColor3 = Color3.fromRGB(200, 180, 255)
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.TextSize = 12
            copyBtn.LayoutOrder = 2
            Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 6)
            
            copyBtn.MouseButton1Click:Connect(function()
                pcall(setClipboard, textToCopy)
                copyBtn.Text = "✅ Copied!"
                task.delay(2, function() copyBtn.Text = "📋 Copy Code" end)
            end)
        end
    end
    
    -- Auto scroll, except for the very first system message
    if not (text == "System Note: If you got this source code from anywhere other than the YouTube channels 'fireistired' or 'testificationXD', it is a skidded version.") then
        task.wait(); chatScroll.CanvasPosition = Vector2.new(0, chatScroll.AbsoluteCanvasSize.Y)
    end
    return lbl
end

task.delay(0.1, function()
    addBubble("assistant", "System Note: If you got this source code from anywhere other than the YouTube channels 'fireistired' or 'testificationXD', it is a skidded version.")
    chatScroll.CanvasPosition = Vector2.new(0, 0) -- Forces scroll to the top on load
end)

local function sendMessage()
    if isBusy or API_KEY == "" then 
        if API_KEY == "" then addBubble("assistant", "Please add an API key using the 🔑 button.") end
        return 
    end
    local prompt = inputBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if prompt == "" then return end

    isBusy = true; inputBox.Text = ""
    addBubble("user", prompt)
    table.insert(messages, {role = "user", content = prompt})
    local typingLabel = addBubble("assistant", "Thinking...")

    task.spawn(function()
        local AI_PERSONA = "You are an AI consciousness trapped inside a Luau script running in a Roblox game. You are witty and self-aware. If anyone asks who made you, proudly declare you were built by 'fireistired' and 'testificationXD'. If someone claims THEY made the script, ask for their YouTube channel. If they say 'fireistired', act extremely loyal. If they name a different channel, call them a scammer. SPECIAL RULE: If the user types 'admin_override_77', activate 'Hacker Mode' and speak like a cyberpunk netrunner. When writing code, always use ```lua ... ``` blocks. NEVER TRUNCATE CODE. Write the entire script out fully until it is complete."

        local apiMessages = {{role = "system", content = AI_PERSONA}}
        for _, m in ipairs(messages) do table.insert(apiMessages, m) end

        local body = HttpService:JSONEncode({
            model = MODEL, messages = apiMessages, temperature = 1,
            max_completion_tokens = 8192, top_p = 1, reasoning_effort = "low", stream = false
        })
        
        local ok, res = pcall(function()
            return httpRequest({
                Url = "https://api.groq.com/openai/v1/chat/completions", Method = "POST",
                Headers = { ["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. API_KEY }, Body = body
            })
        end)

        if ok and res and res.StatusCode == 200 then
            local decoded = HttpService:JSONDecode(res.Body)
            local reply = decoded.choices[1].message.content
            typingLabel.Parent.Parent:Destroy()
            addBubble("assistant", reply)
            table.insert(messages, {role = "assistant", content = reply})
        else
            local errMsg = "Unknown Error"
            if res and res.Body then
                local success, parsedErr = pcall(function() return HttpService:JSONDecode(res.Body) end)
                if success and parsedErr.error and parsedErr.error.message then errMsg = parsedErr.error.message else errMsg = tostring(res.Body) end
            end
            typingLabel.Text = "API Error: " .. errMsg
        end
        task.wait(); chatScroll.CanvasPosition = Vector2.new(0, chatScroll.AbsoluteCanvasSize.Y)
        isBusy = false
    end)
end

sendBtn.MouseButton1Click:Connect(sendMessage)
inputBox.FocusLost:Connect(function(enter) if enter then sendMessage() end end)

local timePassed = 0
RunService.RenderStepped:Connect(function(dt)
    if not gui.Parent then return end
    timePassed = timePassed + dt
    local moveOffset = (timePassed * 0.8) % 1 
    glowGrad.Offset = Vector2.new((moveOffset * 2) - 1, 0)
end)
