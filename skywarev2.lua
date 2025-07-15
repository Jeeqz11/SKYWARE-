-- // SkyWare V2 Arsenal (Basic Version with Rayfield) \\ --

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESPEnabled = false
local AimbotEnabled = false
local AimbotPart = "Head"
local FOV = 120
local Smoothness = 0.2
local Holding = false

-- // FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOV
FOVCircle.Visible = true

-- // Get Closest Enemy
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

-- // Aimbot Logic
RunService.RenderStepped:Connect(function()
    if Holding and AimbotEnabled then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild(AimbotPart) then
            local aimPos = target.Character[AimbotPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), Smoothness)
        end
    end
end)

-- // FOV Circle Follow Mouse
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = FOV
end)

-- // Right Mouse Input
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

-- // ESP
local Highlights = {}

local function EnableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
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

local function DisableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if Highlights[player] then
            Highlights[player]:Destroy()
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

-- // UI (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
    Name = "SkyWare V2 - Arsenal",
    LoadingTitle = "SkyWare V2",
    LoadingSubtitle = "by Jeeqz11",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SkyWareV2",
        FileName = "ArsenalConfig"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Tabs
local AimbotTab = Window:CreateTab("Aimbot")
local VisualsTab = Window:CreateTab("Visuals")

-- Aimbot Toggles
AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end,
})

AimbotTab:CreateDropdown({
    Name = "Aim Part",
    Options = { "Head", "Torso" },
    CurrentOption = "Head",
    Callback = function(Value)
        AimbotPart = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {0.1, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.2,
    Callback = function(Value)
        Smoothness = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 300},
    Increment = 10,
    Suffix = "",
    CurrentValue = 120,
    Callback = function(Value)
        FOV = Value
    end,
})

-- Visuals Toggles
VisualsTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            EnableESP()
        else
            DisableESP()
        end
    end,
})

VisualsTab:CreateColorPicker({
    Name = "ESP Color (Box)",
    Color = Color3.fromRGB(0, 255, 0),
    Callback = function(Color)
        for _, highlight in pairs(Highlights) do
            highlight.FillColor = Color
        end
    end,
})

Rayfield:LoadConfiguration()
