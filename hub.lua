-- Create the main screen layer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DoomWarningGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
-- CUSTOMIZE THIS PART:
warningFrame.Size = UDim2.new(0, 300, 0, 200) -- Change 300 (width) and 200 (height) to whatever you like!
warningFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Change these numbers to pick your background color!
local warningText = Instance.new("TextLabel")
warningText.Parent = warningFrame

-- CUSTOMIZE THIS PART:
warningText.Text ="this script is risky to use use it at your risk" -- Type your exact warning words inside the quotes!
warningText.TextColor3 = Color3.fromRGB(255, 255, 255) -- Pick your text color
local yesButton = Instance.new("TextButton")
yesButton.Parent = warningFrame
yesButton.Text = "YES(the main gui will appewr)"
  
local noButton = Instance.new("TextButton")
noButton.Parent = warningFrame
noButton.Text = "NO(the gui will be destroyed)"
-- The Brain for the NO button
noButton.MouseButton1Click:Connect(function()
    screenGui:Destroy() -- Wipes the warning screen completely!
end)

-- =======================================================
-- START BUILDING THE MAIN HUB PANEL HERE
-- =======================================================
local mainHubFrame = Instance.new("Frame")
mainHubFrame.Name = "MainHubPanel"
mainHubFrame.Size = UDim2.new(0, 450, 0, 300)
mainHubFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
mainHubFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Modern dark gray
mainHubFrame.BorderSizePixel = 0 -- No old-school borders!
mainHubFrame.Parent = screenGui

-- Keep it completely hidden when the script first injects!
mainHubFrame.Visible = false 

-- Smooth 12-pixel rounded corners
local hubCorner = Instance.new("UICorner")
hubCorner.CornerRadius = UDim.new(0, 12)
hubCorner.Parent = mainHubFrame
-- =======================================================
-- THE GOD MODE SYSTEM (AT THE ABSOLUTE BOTTOM)
-- =======================================================
local godModeButton = Instance.new("TextButton")
godModeButton.Name = "GodModeToggle"
godModeButton.Size = UDim2.new(0, 200, 0, 45)
godModeButton.Position = UDim2.new(0.5, -100, 0.5, -22) -- Centers it in the hub
godModeButton.Text = "God Mode: OFF"
godModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
godModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
godModeButton.Font = Enum.Font.GothamBold
godModeButton.TextSize = 14
godModeButton.Parent = mainHubFrame -- Attaches perfectly to the main hub panel

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = godModeButton

local godModeActive = false

godModeButton.MouseButton1Click:Connect(function()
    godModeActive = not godModeActive
    if godModeActive == true then
        godModeButton.Text = "God Mode: ON"
        godModeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
    else
        godModeButton.Text = "God Mode: OFF"
        godModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)

task.spawn(function()
    while true do
        if godModeActive == true then
            local player = game.Players.LocalPlayer
            local character = player.Character
            if character then
                if not character:FindFirstChildOfClass("ForceField") then
                    Instance.new("ForceField", character)
                end
            end
        end
        task.wait(0.3)
    end
end)
-- The Fixed Bridge (At the absolute bottom)
yesButton.MouseButton1Click:Connect(function()
    warningFrame.Visible = false  -- Hides the warning panel
    mainHubFrame.Visible = true   -- Reveals the main hub panel safely!
    print("PROJECT_DOOM has successfully launched!")
end)      
