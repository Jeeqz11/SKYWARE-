-- SkyWare V2 - Arsenal Mega Hub
if not game:IsLoaded() then game.Loaded:Wait() end

-- Services
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
local GodMode, RapidFire, InfiniteAmmo = false, false, false

-- Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = FOVCircleEnabled

local fps, lastTick, frameCount = 0, tick(), 0
local TextLabel = Drawing.new("Text")
TextLabel.Visible = true
TextLabel.Center = false
TextLabel.Outline = true
TextLabel.Font = 2
TextLabel.Size = 18
TextLabel.Color = Color3.fromRGB(255, 255, 255)

local ESPObjects = {}

-- Functions
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
        for _, line in pairs(ESPObjects[player].Lines) do
            line:Remove()
        end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and (not TeamCheckESP or IsEnemy(player)) then
            if not ESPObjects[player] then
                CreateESP(player)
            end

            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local head = player.Character:FindFirstChild("Head")
            local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
            if root and head and torso then
                local pos, onscreen = Camera:WorldToViewportPoint(root.Position)
                if onscreen and ESPEnabled then
                    -- Box ESP
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

                    -- Skeleton ESP
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
                        for _, line in pairs(ESPObjects[player].Lines) do
                            line.Visible = false
                        end
                    end
                else
                    ESPObjects[player].Box.Visible = false
                    for _, line in pairs(ESPObjects[player].Lines) do
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
    if input.UserInputType == AimbotKey then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimbotKey then
        Holding = false
    end
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

    frameCount = frameCount + 1
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

if hookmetamethod then
    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        if SilentAimEnabled and getnamecallmethod() == "FindPartOnRayWithIgnoreList" then
            local target = GetClosest()
            if target and target.Character and target.Character:FindFirstChild(AimPart) then
                args[1] = Ray.new(Camera.CFrame.Position, (target.Character[AimPart].Position - Camera.CFrame.Position).Unit * 1000)
                return old(self, unpack(args))
            end
        end
        return old(self, ...)
    end)
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SkyWare V2 - Arsenal", "Sentinel")

-- Visuals
local VisualTab = Window:NewTab("Visuals")
local VisualSection = VisualTab:NewSection("ESP")
VisualSection:NewToggle("Enable ESP", "Toggle ESP", function(state) ESPEnabled = state end)
VisualSection:NewToggle("Team Check", "Only enemies", function(state) TeamCheckESP = state end)
VisualSection:NewToggle("Box ESP", "Show boxes", function(state) BoxESP = state end)
VisualSection:NewToggle("Skeleton ESP", "Show skeleton", function(state) SkeletonESP = state end)
VisualSection:NewColorPicker("ESP Color", "Pick color", Color3.fromRGB(0, 255, 0), function(color) ESPColor = color end)

-- Aimbot
local AimbotTab = Window:NewTab("Aimbot")
local AimbotSection = AimbotTab:NewSection("Aimbot Settings")
AimbotSection:NewToggle("Enable Aimbot", "Toggle Aimbot", function(state) AimbotEnabled = state end)
AimbotSection:NewToggle("Team Check", "Only enemies", function(state) TeamCheckAimbot = state end)
AimbotSection:NewSlider("Smoothness", "Aimbot smoothness", 1, 0, function(val) Smoothness = val end)
AimbotSection:NewSlider("FOV Radius", "FOV size", 300, 50, function(val) FOVRadius = val end)
AimbotSection:NewKeybind("Aimbot Key", "Key to hold", Enum.KeyCode.MouseButton2, function() end)
AimbotSection:NewDropdown("Aim Part", "Target part", {"Head", "Torso"}, function(val) AimPart = val end)
AimbotSection:NewToggle("Show FOV Circle", "Circle", function(state) FOVCircleEnabled = state end)

-- Exploits
local ExploitsTab = Window:NewTab("Exploits")
local ExploitsSection = ExploitsTab:NewSection("Exploits")
ExploitsSection:NewToggle("God Mode", "Infinite HP", function(state) GodMode = state end)
ExploitsSection:NewToggle("Silent Aim", "Silent Aim", function(state) SilentAimEnabled = state end)
ExploitsSection:NewSlider("Walk Speed", "Move faster", 250, 16, function(val) WalkSpeed = val end)
ExploitsSection:NewSlider("Jump Power", "Jump higher", 250, 50, function(val) JumpPower = val end)

-- Misc
local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Misc Settings")
MiscSection:NewButton("Rejoin", "Rejoin game", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
MiscSection:NewButton("Unload", "Unload UI", function() Library:Destroy(); FOVCircle:Remove(); TextLabel:Remove() end)
MiscSection:NewToggle("Crosshair", "Show mouse", function(state) game:GetService("StarterGui"):SetCore("ToggleMouseIcon", state) end)
MiscSection:NewButton("Unlock FPS", "360 FPS", function() setfpscap(360) end)
MiscSection:NewColorPicker("UI Color", "Theme", Color3.fromRGB(44, 120, 224), function(color) Library:ChangeColorScheme(color) end)
MiscSection:NewKeybind("Toggle UI", "Open/Close UI", Enum.KeyCode.RightShift, function() Library:ToggleUI() end)

-- Credits
local CreditsTab = Window:NewTab("Credits")
local CreditsSection = CreditsTab:NewSection("SkyWare V2 - Arsenal")
CreditsSection:NewLabel("Script by SkyWare Team")
CreditsSection:NewLabel("Version: FINAL PREMIUM")

print("✅ SkyWare V2 Mega Hub Loaded (Final)!")
