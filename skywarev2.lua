local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("SkyWare V2 - Arsenal", "Sentinel")

-- Tabs
local AimbotTab = Window:NewTab("Aimbot")
local VisualsTab = Window:NewTab("Visuals")

-- Sections
local AimbotSection = AimbotTab:NewSection("Aimbot Settings")
local VisualsSection = VisualsTab:NewSection("ESP Settings")

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local AimbotEnabled = false
local ESPEnabled = false
local AimbotPart = "Head"
local FOV = 120
local Smoothness = 0.2
local Holding = false

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOV
FOVCircle.Visible = true

-- Functions
local function GetClosestEnemy()
    local closest = nil
    local shortestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild(AimbotPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character[AimbotPart].Position)
            if onScreen then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if dist < shortestDistance and dist < FOV then
                    shortestDistance = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Aimbot logic
RunService.RenderStepped:Connect(function()
    if Holding and AimbotEnabled then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild(AimbotPart) then
            local aimPos = target.Character[AimbotPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), Smoothness)
        end
    end
end)

-- FOV circle update
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = FOV
end)

-- Right mouse input
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

-- ESP
local Highlights = {}

local function EnableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
            if not player.Character:FindFirstChild("SkyWareESP") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SkyWareESP"
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
                Highlights[player] = highlight
            end
        end
    end
end

local function DisableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("SkyWareESP") then
            player.Character.SkyWareESP:Destroy()
            Highlights[player] = nil
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if ESPEnabled then
            wait(1)
            EnableESP()
        end
    end)
end)

-- Aimbot UI
AimbotSection:NewToggle("Enable Aimbot", "Toggle aimbot on/off", false, function(value)
    AimbotEnabled = value
end)

AimbotSection:NewDropdown("Aim Part", "Select target part", {"Head", "Torso"}, function(option)
    AimbotPart = option
end)

AimbotSection:NewSlider("Smoothness", "Aimbot smoothness", 1, 0.1, 0.2, function(value)
    Smoothness = value
end)

AimbotSection:NewSlider("FOV Radius", "Adjust FOV", 300, 50, 120, function(value)
    FOV = value
    FOVCircle.Radius = value
end)

-- ESP UI
VisualsSection:NewToggle("Enable ESP", "Toggle ESP boxes", false, function(value)
    ESPEnabled = value
    if value then
        EnableESP()
    else
        DisableESP()
    end
end)

VisualsSection:NewColorPicker("ESP Color", "Pick ESP color", Color3.fromRGB(0, 255, 0), function(color)
    for _, highlight in pairs(Highlights) do
        highlight.FillColor = color
    end
end)
