-- SkyWare V2 💜 Arsenal (Stable Exploits Only)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "SkyWare V2 - Arsenal",
    LoadingTitle = "SKYWARE 💜",
    LoadingSubtitle = "by Jeeqz11",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local ExploitTab = Window:CreateTab("Exploits", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Vars
local AimbotEnabled, BoxESPEnabled, FOVRadius, Smoothness = true, true, 150, 0.3
local AimPart, Holding = "Head", false

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = true

-- Find closest target
local function GetClosestTarget()
    local closest, shortest = nil, math.huge
    local mousePos = UIS:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild(AimPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if onScreen then
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
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position), Smoothness)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local mouse = UIS:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
end)

-- ESP
local function CreateESP(player)
    if player.Character and not player.Character:FindFirstChild("SkywareESP") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "SkywareESP"
        box.Adornee = player.Character
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Size = Vector3.new(4, 7, 4)
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.5
        box.Parent = player.Character
    end
end

RunService.RenderStepped:Connect(function()
    if BoxESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                CreateESP(player)
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("SkywareESP") then
                player.Character:FindFirstChild("SkywareESP"):Destroy()
            end
        end
    end
end)

-- Exploits
ExploitTab:CreateButton({
    Name = "God Mode",
    Callback = function()
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
            hum:GetPropertyChangedSignal("Health"):Connect(function()
                if hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
        end
    end,
})

ExploitTab:CreateButton({
    Name = "Fly Mode",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/Q2sZb2Vx"))()
    end,
})

ExploitTab:CreateButton({
    Name = "Infinite Jump",
    Callback = function()
        game:GetService("UserInputService").JumpRequest:Connect(function()
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end)
    end,
})

-- UI Controls
CombatTab:CreateToggle({
    Name = "Aimbot (Hold RMB)",
    CurrentValue = AimbotEnabled,
    Callback = function(Value) AimbotEnabled = Value end,
})

CombatTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = FOVRadius,
    Callback = function(Value)
        FOVRadius = Value
        FOVCircle.Radius = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = Smoothness,
    Callback = function(Value) Smoothness = Value end,
})

VisualTab:CreateToggle({
    Name = "ESP Boxes",
    CurrentValue = BoxESPEnabled,
    Callback = function(Value) BoxESPEnabled = Value end,
})

VisualTab:CreateToggle({
    Name = "FOV Circle",
    CurrentValue = true,
    Callback = function(Value) FOVCircle.Visible = Value end,
})

MiscTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Callback = function() Rayfield:Toggle() end,
})

MiscTab:CreateParagraph({
    Title = "SkyWare V2 💜",
    Content = "Aimbot, ESP, God, Fly, IJ\nStable & Clean Build 💜"
})

print("✅ SkyWare V2 (Stable) loaded!") 
