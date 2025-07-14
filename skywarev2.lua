if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- States
local ESPEnabled, TeamCheckESP = false, true
local BoxESP, SkeletonESP = false, false
local ESPColor = Color3.fromRGB(0, 255, 0)

local AimbotEnabled, TeamCheckAimbot, FOVCircleEnabled, SilentAimEnabled = false, true, true, false
local Smoothness, FOVRadius = 0.2, 120
local AimPart = "Head"
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false

local WalkSpeed, JumpPower = 16, 50
local GodMode = false

-- FPS Counter
local fps, lastTick, frameCount = 0, tick(), 0
local TextLabel = Drawing.new("Text")
TextLabel.Visible = true
TextLabel.Center = false
TextLabel.Outline = true
TextLabel.Font = 2
TextLabel.Size = 18
TextLabel.Color = Color3.fromRGB(255, 255, 255)

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = FOVCircleEnabled

-- ESP Data
local ESPObjects = {}

local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
end

local function CreateESP(player)
    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        Lines = {}
    }
    for i = 1, 6 do
        ESPObjects[player].Lines[i] = Drawing.new("Line")
    end
end

local function RemoveESP(player)
    if ESPObjects[player] then
        ESPObjects[player].Box:Remove()
        for _, line in ipairs(ESPObjects[player].Lines) do
            line:Remove()
        end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and (not TeamCheckESP or IsEnemy(player)) then
            if not ESPObjects[player] then CreateESP(player) end

            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local head = player.Character:FindFirstChild("Head")
            local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
            if root and head and torso then
                local pos, onscreen = Camera:WorldToViewportPoint(root.Position)
                if onscreen and ESPEnabled then
                    if BoxESP then
                        local size = Vector3.new(4, 6, 0)
                        local topLeft = Camera:WorldToViewportPoint(root.Position + Vector3.new(-size.X, size.Y, 0))
                        local bottomRight = Camera:WorldToViewportPoint(root.Position + Vector3.new(size.X, -size.Y, 0))
                        ESPObjects[player].Box.Visible = true
                        ESPObjects[player].Box.Color = ESPColor
                        ESPObjects[player].Box.Size = Vector2.new(math.abs(topLeft.X - bottomRight.X), math.abs(topLeft.Y - bottomRight.Y))
                        ESPObjects[player].Box.Position = Vector2.new(math.min(topLeft.X, bottomRight.X), math.min(topLeft.Y, bottomRight.Y))
                        ESPObjects[player].Box.Thickness = 2
                        ESPObjects[player].Box.Transparency = 1
                        ESPObjects[player].Box.Filled = false
                    else
                        ESPObjects[player].Box.Visible = false
                    end

                    if SkeletonESP then
                        local function DrawLine(i, from, to)
                            local fPos, fOn = Camera:WorldToViewportPoint(from.Position)
                            local tPos, tOn = Camera:WorldToViewportPoint(to.Position)
                            local line = ESPObjects[player].Lines[i]
                            if fOn and tOn then
                                line.Visible = true
                                line.From = Vector2.new(fPos.X, fPos.Y)
                                line.To = Vector2.new(tPos.X, tPos.Y)
                                line.Color = ESPColor
                                line.Thickness = 2
                            else
                                line.Visible = false
                            end
                        end

                        local lArm = player.Character:FindFirstChild("LeftUpperArm")
                        local rArm = player.Character:FindFirstChild("RightUpperArm")
                        local lLeg = player.Character:FindFirstChild("LeftUpperLeg")
                        local rLeg = player.Character:FindFirstChild("RightUpperLeg")

                        if lArm and rArm and lLeg and rLeg then
                            DrawLine(1, head, torso)
                            DrawLine(2, torso, lArm)
                            DrawLine(3, torso, rArm)
                            DrawLine(4, torso, lLeg)
                            DrawLine(5, torso, rLeg)
                            DrawLine(6, lLeg, rLeg)
                        end
                    else
                        for _, line in ipairs(ESPObjects[player].Lines) do
                            line.Visible = false
                        end
                    end
                else
                    ESPObjects[player].Box.Visible = false
                    for _, line in ipairs(ESPObjects[player].Lines) do
                        line.Visible = false
                    end
                end
            end
        else
            RemoveESP(player)
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
    if input.UserInputType == AimbotKey then Holding = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimbotKey then Holding = false end
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and Holding then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local pos = target.Character[AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), Smoothness)
        end
    end

    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = FOVRadius

    frameCount += 1
    if tick() - lastTick >= 1 then
        fps = frameCount
        frameCount = 0
        lastTick = tick()
    end
    TextLabel.Text = string.format("SkyWare V2 - Arsenal | FPS: %d", fps)
    TextLabel.Position = Vector2.new(10, 10)

    if GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = math.huge
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = JumpPower
    end

    UpdateESP()
end)

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local Window = Rayfield:CreateWindow({
    Name = "SkyWare V2 - Arsenal",
    LoadingTitle = "SkyWare V2",
    LoadingSubtitle = "by SkyTeam",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SkyWareV2",
        FileName = "ArsenalConfig"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

local VisualTab = Window:CreateTab("Visuals", 4483362458)
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local ExploitsTab = Window:CreateTab("Exploits", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local CreditsTab = Window:CreateTab("Credits", 4483362458)

-- Visual
VisualTab:CreateToggle("Enable ESP", nil, function(val) ESPEnabled = val end)
VisualTab:CreateToggle("Team Check", nil, function(val) TeamCheckESP = val end)
VisualTab:CreateToggle("Box ESP", nil, function(val) BoxESP = val end)
VisualTab:CreateToggle("Skeleton ESP", nil, function(val) SkeletonESP = val end)
VisualTab:CreateColorPicker("ESP Color", ESPColor, function(val) ESPColor = val end)

-- Aimbot
AimbotTab:CreateToggle("Enable Aimbot", nil, function(val) AimbotEnabled = val end)
AimbotTab:CreateToggle("Team Check", nil, function(val) TeamCheckAimbot = val end)
AimbotTab:CreateSlider("Smoothness", 0, 1, 0.2, false, function(val) Smoothness = val end)
AimbotTab:CreateSlider("FOV Radius", 50, 300, 120, false, function(val) FOVRadius = val end)
AimbotTab:CreateKeybind("Aimbot Key", Enum.KeyCode.MouseButton2, function() end)
AimbotTab:CreateDropdown("Aim Part", {"Head", "Torso"}, function(val) AimPart = val end)
AimbotTab:CreateToggle("Show FOV Circle", nil, function(val) FOVCircleEnabled = val end)

-- Exploits
ExploitsTab:CreateToggle("God Mode", nil, function(val) GodMode = val end)
ExploitsTab:CreateSlider("Walk Speed", 16, 250, 16, false, function(val) WalkSpeed = val end)
ExploitsTab:CreateSlider("Jump Power", 50, 250, 50, false, function(val) JumpPower = val end)

-- Misc
MiscTab:CreateButton("Rejoin", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
MiscTab:CreateButton("Unload UI", function() Rayfield:Destroy(); FOVCircle:Remove(); TextLabel:Remove() end)
MiscTab:CreateToggle("Crosshair", nil, function(val) game:GetService("StarterGui"):SetCore("ToggleMouseIcon", val) end)
MiscTab:CreateButton("Unlock FPS", function() setfpscap(360) end)
MiscTab:CreateColorPicker("UI Color", Color3.fromRGB(44, 120, 224), function(color) Rayfield:ChangeTheme(color) end)
MiscTab:CreateKeybind("Toggle UI", Enum.KeyCode.RightShift, function() Rayfield:Toggle() end)

-- Credits
CreditsTab:CreateLabel("Script by SkyWare Team")
CreditsTab:CreateLabel("Version: Final Pro Rayfield")

print("✅ SkyWare V2 - Arsenal Pro Version Loaded (Rayfield UI)!")
