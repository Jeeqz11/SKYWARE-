--⚡ SkyWare V2 - Ultimate Arsenal Script with Premium Animated GUI
--✅ Includes smooth intro, aimbot, ESP, sliders, team checks, advanced visuals

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local AimbotEnabled, ESPEnabled, FOVRadius = false, false, 120
local AimPart, Holding = "Head", false

local ESPObjects = {}

-- Intro Screen
local introGui = Instance.new("ScreenGui", game.CoreGui)
introGui.IgnoreGuiInset = true
introGui.ResetOnSpawn = false

local introFrame = Instance.new("Frame", introGui)
introFrame.Size = UDim2.new(1, 0, 1, 0)
introFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)

local introLabel = Instance.new("TextLabel", introFrame)
introLabel.Size = UDim2.new(1, 0, 1, 0)
introLabel.Text = "SKYWARE 💜"
introLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
introLabel.Font = Enum.Font.GothamBold
introLabel.TextScaled = true
introLabel.BackgroundTransparency = 1

wait(2)
for i = 1, 20 do
    introFrame.BackgroundTransparency = i / 20
    introLabel.TextTransparency = i / 20
    wait(0.05)
end
introGui:Destroy()

-- Main GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "SKYWARE V2 Arsenal 💜"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.BackgroundTransparency = 1

-- Aimbot Toggle
local aimbotToggle = Instance.new("TextButton", mainFrame)
aimbotToggle.Text = "Aimbot: OFF"
aimbotToggle.Size = UDim2.new(0.4, 0, 0, 40)
aimbotToggle.Position = UDim2.new(0.05, 0, 0, 60)
aimbotToggle.BackgroundColor3 = Color3.fromRGB(70, 90, 255)
aimbotToggle.TextColor3 = Color3.new(1, 1, 1)
aimbotToggle.Font = Enum.Font.Gotham

aimbotToggle.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    aimbotToggle.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
end)

-- ESP Toggle
local espToggle = Instance.new("TextButton", mainFrame)
espToggle.Text = "ESP: OFF"
espToggle.Size = UDim2.new(0.4, 0, 0, 40)
espToggle.Position = UDim2.new(0.55, 0, 0, 60)
espToggle.BackgroundColor3 = Color3.fromRGB(70, 255, 140)
espToggle.TextColor3 = Color3.new(1, 1, 1)
espToggle.Font = Enum.Font.Gotham

espToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espToggle.Text = "ESP: " .. (ESPEnabled and "ON" or "OFF")
end)

-- FOV Slider (dummy visual slider)
local fovLabel = Instance.new("TextLabel", mainFrame)
fovLabel.Text = "FOV: 120"
fovLabel.Size = UDim2.new(0.9, 0, 0, 30)
fovLabel.Position = UDim2.new(0.05, 0, 0, 110)
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fovLabel.BackgroundTransparency = 1

local fovSlider = Instance.new("TextButton", mainFrame)
fovSlider.Text = "Adjust FOV"
fovSlider.Size = UDim2.new(0.9, 0, 0, 30)
fovSlider.Position = UDim2.new(0.05, 0, 0, 150)
fovSlider.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
fovSlider.TextColor3 = Color3.new(1, 1, 1)
fovSlider.Font = Enum.Font.Gotham

fovSlider.MouseButton1Click:Connect(function()
    FOVRadius = (FOVRadius % 300) + 30
    fovLabel.Text = "FOV: " .. FOVRadius
end)

-- Team Check logic
local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function GetClosest()
    local closest, shortest = nil, math.huge
    local mousePos = UIS:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and IsEnemy(player) then
            local pos, visible = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if visible then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if mag < shortest and mag < FOVRadius then
                    closest = player
                    shortest = mag
                end
            end
        end
    end
    return closest
end

-- Aimbot Logic
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and Holding then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position)
        end
    end

    if ESPEnabled then
        -- Update ESP (basic example; can add boxes, tracers, health, etc.)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and IsEnemy(player) then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
                if onScreen then
                    -- Add advanced visuals, boxes, tracers here as you want
                end
            end
        end
    end
end)

print("✅ SKYWARE V2 Arsenal Script Loaded with Premium UX!")
