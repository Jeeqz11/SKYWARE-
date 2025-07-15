-- ✅ Full SkyWare V2 Arsenal Script (Final Full Version)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "SkyWare V2 - Arsenal",
    LoadingTitle = "SKYWARE 💜",
    LoadingSubtitle = "by Jeeqz11",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local AimbotEnabled, BoxESPEnabled, FOVRadius, NameESPEnabled, TracerESPEnabled = true, true, 150, true, true
local AimPart, Holding = "Head", false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = true

local ESPObjects = {}

local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        for _, v in pairs(obj) do
            if v and v.Remove then v:Remove() end
        end
    end
    ESPObjects = {}
end

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
end)

local function UpdateESP()
    if not BoxESPEnabled then ClearESP() return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then

            if not ESPObjects[player] then
                ESPObjects[player] = {
                    Box = Drawing.new("Square"),
                    Name = Drawing.new("Text"),
                    Tracer = Drawing.new("Line"),
                    Health = Drawing.new("Text")
                }

                ESPObjects[player].Box.Color = Color3.fromRGB(255, 0, 0)
                ESPObjects[player].Box.Thickness = 2
                ESPObjects[player].Box.Filled = false

                ESPObjects[player].Name.Color = Color3.fromRGB(255, 255, 255)
                ESPObjects[player].Name.Size = 16
                ESPObjects[player].Name.Center = true
                ESPObjects[player].Name.Outline = true

                ESPObjects[player].Tracer.Color = Color3.fromRGB(255, 0, 0)
                ESPObjects[player].Tracer.Thickness = 1

                ESPObjects[player].Health.Color = Color3.fromRGB(0, 255, 0)
                ESPObjects[player].Health.Size = 14
                ESPObjects[player].Health.Center = true
                ESPObjects[player].Health.Outline = true
            end

            local hrp = player.Character.HumanoidRootPart
            local head = player.Character.Head
            local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.3, 0))
            local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local height = math.abs(footPos.Y - headPos.Y)
                local width = height / 2

                ESPObjects[player].Box.Size = Vector2.new(width, height)
                ESPObjects[player].Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                ESPObjects[player].Box.Visible = true

                ESPObjects[player].Name.Position = Vector2.new(headPos.X, headPos.Y - 18)
                ESPObjects[player].Name.Text = player.Name
                ESPObjects[player].Name.Visible = NameESPEnabled

                ESPObjects[player].Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                ESPObjects[player].Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                ESPObjects[player].Tracer.Visible = TracerESPEnabled

                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    ESPObjects[player].Health.Text = "HP: " .. math.floor(humanoid.Health)
                    ESPObjects[player].Health.Position = Vector2.new(headPos.X, footPos.Y + 10)
                    ESPObjects[player].Health.Visible = true
                else
                    ESPObjects[player].Health.Visible = false
                end
            else
                ESPObjects[player].Box.Visible = false
                ESPObjects[player].Name.Visible = false
                ESPObjects[player].Tracer.Visible = false
                ESPObjects[player].Health.Visible = false
            end
        elseif ESPObjects[player] then
            ESPObjects[player].Box.Visible = false
            ESPObjects[player].Name.Visible = false
            ESPObjects[player].Tracer.Visible = false
            ESPObjects[player].Health.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

CombatTab:CreateToggle({ Name = "Aimbot (Hold RMB)", CurrentValue = AimbotEnabled, Callback = function(Value) AimbotEnabled = Value end })
CombatTab:CreateSlider({ Name = "FOV Radius", Range = {50, 300}, Increment = 1, CurrentValue = FOVRadius, Callback = function(Value) FOVRadius = Value; FOVCircle.Radius = Value end })

VisualTab:CreateToggle({ Name = "ESP Boxes", CurrentValue = BoxESPEnabled, Callback = function(Value) BoxESPEnabled = Value end })
VisualTab:CreateToggle({ Name = "ESP Names", CurrentValue = NameESPEnabled, Callback = function(Value) NameESPEnabled = Value end })
VisualTab:CreateToggle({ Name = "ESP Tracers", CurrentValue = TracerESPEnabled, Callback = function(Value) TracerESPEnabled = Value end })
VisualTab:CreateToggle({ Name = "FOV Circle", CurrentValue = true, Callback = function(Value) FOVCircle.Visible = Value end })

MiscTab:CreateKeybind({ Name = "Toggle UI", CurrentKeybind = "RightControl", HoldToInteract = false, Callback = function() Rayfield:Toggle() end })
MiscTab:CreateParagraph({ Title = "SkyWare V2 💜", Content = "Aimbot (Hard Lock) & Full-Body ESP with Names, Tracers, Health\nFinal Stable Version 💜" })

print("✅ SkyWare V2 Fully Loaded with 100% Lock-On & Reworked ESP!")
