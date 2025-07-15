-- ✅ Skyware V2 Arsenal - Reworked ESP with advanced features
-- ⚡ By Jeeqz11

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Window = Rayfield:CreateWindow({
    Name = "Skyware V2 - Arsenal",
    LoadingTitle = "SKYWARE 💜",
    LoadingSubtitle = "by Jeeqz11",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Variables
local ESPEnabled, NameESPEnabled, BoxESPEnabled, TracerESPEnabled, HealthESPEnabled = true, true, true, true, true
local AimbotEnabled, FOVRadius, AimPart, Holding = true, 150, "Head", false

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = true

-- ESP storage
local ESPObjects = {}

local function CreateESP(player)
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Health = Drawing.new("Text")
    }

    local obj = ESPObjects[player]

    -- Box
    obj.Box.Color = Color3.fromRGB(255, 0, 0)
    obj.Box.Thickness = 2
    obj.Box.Filled = false

    -- Name
    obj.Name.Color = Color3.fromRGB(255, 255, 255)
    obj.Name.Size = 16
    obj.Name.Center = true
    obj.Name.Outline = true

    -- Tracer
    obj.Tracer.Color = Color3.fromRGB(255, 0, 0)
    obj.Tracer.Thickness = 1

    -- Health
    obj.Health.Color = Color3.fromRGB(0, 255, 0)
    obj.Health.Size = 14
    obj.Health.Center = true
    obj.Health.Outline = true
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            if not ESPObjects[player] then
                CreateESP(player)
            end

            local obj = ESPObjects[player]
            local hrp = player.Character.HumanoidRootPart
            local head = player.Character.Head

            local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.3, 0))
            local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local height = math.abs(footPos.Y - headPos.Y)
                local width = height / 2

                obj.Box.Size = Vector2.new(width, height)
                obj.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                obj.Box.Visible = BoxESPEnabled

                obj.Name.Position = Vector2.new(headPos.X, headPos.Y - 18)
                obj.Name.Text = player.Name
                obj.Name.Visible = NameESPEnabled

                obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                obj.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                obj.Tracer.Visible = TracerESPEnabled

                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    obj.Health.Text = "HP: " .. math.floor(humanoid.Health)
                    obj.Health.Position = Vector2.new(headPos.X, footPos.Y + 10)
                    obj.Health.Visible = HealthESPEnabled
                else
                    obj.Health.Visible = false
                end
            else
                obj.Box.Visible = false
                obj.Name.Visible = false
                obj.Tracer.Visible = false
                obj.Health.Visible = false
            end
        elseif ESPObjects[player] then
            ESPObjects[player].Box.Visible = false
            ESPObjects[player].Name.Visible = false
            ESPObjects[player].Tracer.Visible = false
            ESPObjects[player].Health.Visible = false
        end
    end
end

-- Aimbot logic (optional here)
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
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Holding = true end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Holding = false end
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and Holding then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position)
        end
    end

    local mouse = UIS:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)

    if ESPEnabled then
        UpdateESP()
    end
end)

-- UI Toggles
VisualTab:CreateToggle({ Name = "ESP Enabled", CurrentValue = ESPEnabled, Callback = function(Value) ESPEnabled = Value end })
VisualTab:CreateToggle({ Name = "Box ESP", CurrentValue = BoxESPEnabled, Callback = function(Value) BoxESPEnabled = Value end })
VisualTab:CreateToggle({ Name = "Name ESP", CurrentValue = NameESPEnabled, Callback = function(Value) NameESPEnabled = Value end })
VisualTab:CreateToggle({ Name = "Tracer ESP", CurrentValue = TracerESPEnabled, Callback = function(Value) TracerESPEnabled = Value end })
VisualTab:CreateToggle({ Name = "Health ESP", CurrentValue = HealthESPEnabled, Callback = function(Value) HealthESPEnabled = Value end })

CombatTab:CreateToggle({ Name = "Aimbot (Hold RMB)", CurrentValue = AimbotEnabled, Callback = function(Value) AimbotEnabled = Value end })
CombatTab:CreateSlider({ Name = "FOV Radius", Range = {50, 300}, Increment = 1, CurrentValue = FOVRadius, Callback = function(Value) FOVRadius = Value; FOVCircle.Radius = Value end })

MiscTab:CreateKeybind({ Name = "Toggle UI", CurrentKeybind = "RightControl", HoldToInteract = false, Callback = function() Rayfield:Toggle() end })

print("✅ Skyware V2 Arsenal ESP & Aimbot fully loaded!")
