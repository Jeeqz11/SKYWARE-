if not game:IsLoaded() then game.Loaded:Wait() end

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
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

local AimbotEnabled, TeamCheckAimbot, FOVCircleEnabled = false, true, true
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

            local root = player.Character.HumanoidRootPart
            local head = player.Character.Head
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

-- Orion UI Setup
local Window = OrionLib:MakeWindow({Name = "SkyWare V2 - Arsenal", HidePremium = false, SaveConfig = true, ConfigFolder = "SkyWareV2"})

-- Visuals Tab
local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})
VisualsTab:AddToggle({Name = "Enable ESP", Default = false, Callback = function(val) ESPEnabled = val end})
VisualsTab:AddToggle({Name = "Team Check", Default = true, Callback = function(val) TeamCheckESP = val end})
VisualsTab:AddToggle({Name = "Box ESP", Default = false, Callback = function(val) BoxESP = val end})
VisualsTab:AddToggle({Name = "Skeleton ESP", Default = false, Callback = function(val) SkeletonESP = val end})
VisualsTab:AddColorpicker({Name = "ESP Color", Default = ESPColor, Callback = function(val) ESPColor = val end})

-- Aimbot Tab
local AimbotTab = Window:MakeTab({Name = "Aimbot", Icon = "rbxassetid://4483345998", PremiumOnly = false})
AimbotTab:AddToggle({Name = "Enable Aimbot", Default = false, Callback = function(val) AimbotEnabled = val end})
AimbotTab:AddToggle({Name = "Team Check", Default = true, Callback = function(val) TeamCheckAimbot = val end})
AimbotTab:AddSlider({Name = "Smoothness", Min = 0, Max = 1, Default = 0.2, Increment = 0.01, Callback = function(val) Smoothness = val end})
AimbotTab:AddSlider({Name = "FOV Radius", Min = 50, Max = 300, Default = 120, Increment = 1, Callback = function(val) FOVRadius = val end})
AimbotTab:AddDropdown({Name = "Aim Part", Options = {"Head", "Torso"}, Default = "Head", Callback = function(val) AimPart = val end})
AimbotTab:AddToggle({Name = "Show FOV Circle", Default = true, Callback = function(val) FOVCircleEnabled = val end})

-- Exploits Tab
local ExploitsTab = Window:MakeTab({Name = "Exploits", Icon = "rbxassetid://4483345998", PremiumOnly = false})
ExploitsTab:AddToggle({Name = "God Mode", Default = false, Callback = function(val) GodMode = val end})
ExploitsTab:AddSlider({Name = "Walk Speed", Min = 16, Max = 250, Default = 16, Increment = 1, Callback = function(val) WalkSpeed = val end})
ExploitsTab:AddSlider({Name = "Jump Power", Min = 50, Max = 250, Default = 50, Increment = 1, Callback = function(val) JumpPower = val end})

-- Misc Tab
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})
MiscTab:AddButton({Name = "Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end})
MiscTab:AddButton({Name = "Unload UI", Callback = function() OrionLib:Destroy(); FOVCircle:Remove(); TextLabel:Remove() end})
MiscTab:AddButton({Name = "Unlock FPS", Callback = function() setfpscap(360) end})
MiscTab:AddKeybind({Name = "Toggle UI", Default = Enum.KeyCode.RightShift, Hold = false, Callback = function() OrionLib:Toggle() end})

-- Credits Tab
local CreditsTab = Window:MakeTab({Name = "Credits", Icon = "rbxassetid://4483345998", PremiumOnly = false})
CreditsTab:AddParagraph("SkyWare V2", "Script by SkyTeam\nVersion: Orion Final Pro")

print("✅ SkyWare V2 - Arsenal FINAL PRO Orion UI Loaded!")
