
-- FTAP CLIENT
-- For your own Roblox Studio test game

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("FTAPRemote")

local gui = Instance.new("ScreenGui")
gui.Name = "FTAPGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 220)
frame.Position = UDim2.new(0.5, -130, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(22, 12, 18)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(120, 15, 35)
title.Text = "FTAP CONTROL"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = frame

local function makeButton(text, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 38)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = Color3.fromRGB(145, 20, 45)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = text
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    button.Activated:Connect(callback)
    return button
end

local consent = false
local consentButton

consentButton = makeButton("CONSENT: OFF", 55, function()
    consent = not consent
    remote:FireServer("Consent", consent)
    consentButton.Text = consent and "CONSENT: ON" or "CONSENT: OFF"
end)

local function nearestConsentingPlayer()
    local myCharacter = player.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local nearest, nearestDistance = nil, 20

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other:GetAttribute("FTAPConsent") then
            local character = other.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if root then
                local distance = (root.Position - myRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearest = other
                    nearestDistance = distance
                end
            end
        end
    end

    return nearest
end

makeButton("THROW NEAREST CONSENTING PLAYER", 102, function()
    if not consent then
        return
    end

    local target = nearestConsentingPlayer()
    if target then
        remote:FireServer("Throw", target)
    end
end)

makeButton("RECOVER MY CHARACTER", 149, function()
    remote:FireServer("Recover")
end)

-- Right Shift toggles the GUI on desktop.
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)
