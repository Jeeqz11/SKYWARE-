-- SkyWare V2 Mega Arsenal Hub

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- States
local ESPEnabled, TeamCheckESP, BoxESP, Tracers, NameESP, HealthESP, DistanceESP = false, true, false, false, false, false, false
local ESPColor = Color3.fromRGB(0, 255, 0)

local AimbotEnabled, TeamCheckAimbot, FOVCircleEnabled, TargetLineEnabled, PredictionEnabled, SilentAim = false, true, true, false, false, false
local Smoothness, FOVRadius = 0.2, 120
local AimPart = "Head"
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false
local Highlights = {}

-- Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Visible = FOVCircleEnabled
FOVCircle.Radius = FOVRadius

local TargetLine = Drawing.new("Line")
TargetLine.Color = Color3.fromRGB(255, 0, 0)
TargetLine.Thickness = 1
TargetLine.Visible = false

-- Watermark FPS
local TextLabel = Drawing.new("Text")
TextLabel.Visible = true
TextLabel.Center = false
TextLabel.Outline = true
TextLabel.Font = 2
TextLabel.Size = 18
TextLabel.Color = Color3.fromRGB(255, 255, 255)

local fps, lastTick, frameCount = 0, tick(), 0

-- Functions
local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function CreateHighlight(player)
    if Highlights[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = ESPColor
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    Highlights[player] = highlight
end

local function RemoveHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and (not TeamCheckESP or IsEnemy(player)) then
            if ESPEnabled then
                CreateHighlight(player)
            else
                RemoveHighlight(player)
            end
        else
            RemoveHighlight(player)
        end
    end
end

local function GetClosest()
    local closest, dist = nil, math.huge
    local mouse = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and (not TeamCheckAimbot or IsEnemy(player)) then
            local pos, visible = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if visible then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if mag < dist and mag < FOVRadius then
                    closest, dist = player, mag
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AimbotKey then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimbotKey then
        Holding = false
        TargetLine.Visible = false
    end
end)

RunService.RenderStepped:Connect(function()
    -- Aimbot logic
    if AimbotEnabled and Holding then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local pos = target.Character[AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), Smoothness)

            if TargetLineEnabled then
                local screenPos = Camera:WorldToViewportPoint(pos)
                local mouse = UserInputService:GetMouseLocation()
                TargetLine.From = Vector2.new(mouse.X, mouse.Y)
                TargetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                TargetLine.Visible = true
            else
                TargetLine.Visible = false
            end
        else
            TargetLine.Visible = false
        end
    else
        TargetLine.Visible = false
    end

    -- FOV circle
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = FOVRadius

    UpdateESP()

    -- FPS & watermark
    frameCount = frameCount + 1
    if tick() - lastTick >= 1 then
        fps = frameCount
        frameCount = 0
        lastTick = tick()
    end
    TextLabel.Text = string.format("SkyWare V2 - Arsenal | FPS: %d", fps)
    TextLabel.Position = Vector2.new(10, 10)
end)

-- Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SkyWare V2 - Arsenal", "Sentinel")

-- Visuals
local VisualTab = Window:NewTab("Visuals")
local VisualSection = VisualTab:NewSection("ESP Settings")

VisualSection:NewToggle("Enable ESP", "Toggle ESP", function(state)
    ESPEnabled = state
end)
VisualSection:NewToggle("Team Check", "Only highlight enemies", function(state)
    TeamCheckESP = state
end)
VisualSection:NewToggle("Box ESP", "Draw box", function(state)
    BoxESP = state
end)
VisualSection:NewToggle("Tracers", "Draw tracers", function(state)
    Tracers = state
end)
VisualSection:NewToggle("Name ESP", "Show player names", function(state)
    NameESP = state
end)
VisualSection:NewToggle("Health ESP", "Show health", function(state)
    HealthESP = state
end)
VisualSection:NewToggle("Distance ESP", "Show distance", function(state)
    DistanceESP = state
end)
VisualSection:NewColorPicker("ESP Color", "Pick ESP Color", Color3.fromRGB(0, 255, 0), function(color)
    ESPColor = color
    for _, h in pairs(Highlights) do
        h.FillColor = color
    end
end)

-- Aimbot
local AimbotTab = Window:NewTab("Aimbot")
local AimbotSection = AimbotTab:NewSection("Aimbot Settings")

AimbotSection:NewToggle("Enable Aimbot", "Toggle Aimbot", function(state)
    AimbotEnabled = state
end)
AimbotSection:NewToggle("Team Check", "Only target enemies", function(state)
    TeamCheckAimbot = state
end)
AimbotSection:NewSlider("Smoothness", "Aimbot smoothness", 1, 0, function(val)
    Smoothness = val
end)
AimbotSection:NewSlider("FOV Radius", "FOV Radius", 300, 50, function(val)
    FOVRadius = val
end)
AimbotSection:NewKeybind("Aimbot Key", "Key to hold for aimbot", Enum.KeyCode.MouseButton2, function() end)
AimbotSection:NewDropdown("Aim Part", "Part to aim at", {"Head", "Torso"}, function(val)
    AimPart = val
end)
AimbotSection:NewToggle("Show FOV Circle", "Display FOV Circle", function(state)
    FOVCircleEnabled = state
end)
AimbotSection:NewToggle("Target Line", "Draw line to target", function(state)
    TargetLineEnabled = state
end)
AimbotSection:NewToggle("Prediction", "Enable prediction", function(state)
    PredictionEnabled = state
end)
AimbotSection:NewToggle("Silent Aim", "Enable silent aim", function(state)
    SilentAim = state
end)

-- Misc
local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Misc Settings")

MiscSection:NewButton("Unload UI", "Unload script", function()
    Library:Destroy()
    FOVCircle:Remove()
    TargetLine:Remove()
    TextLabel:Remove()
    for _, h in pairs(Highlights) do
        h:Destroy()
    end
end)
MiscSection:NewButton("Rejoin", "Rejoin server", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
MiscSection:NewToggle("Crosshair", "Enable crosshair", function(state)
    StarterGui:SetCore("ToggleMouseIcon", state)
end)
MiscSection:NewButton("Unlock FPS", "Set FPS cap to 360", function()
    setfpscap(360)
end)
MiscSection:NewButton("Chat Spam", "Spam message in chat", function()
    while true do
        wait(1)
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("SkyWare V2 on top!", "All")
    end
end)

print("✅ SkyWare V2 Mega Arsenal Hub Loaded!")
