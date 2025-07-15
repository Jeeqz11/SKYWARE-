-- SkyWare V2 - Final Kavo UI Build 💜

local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/o5u3/Ui-Libraries/main/Kavo/Kavo%20Library.lua"))()

local Window = Kavo:CreateLib("SkyWare V2 - Arsenal", "Sentinel")

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local AimbotEnabled = true
local ESPEnabled = true
local BoxESPEnabled = true
local FOVEnabled = true
local Smoothness = 0.3
local FOVRadius = 150
local AimPart = "Head"
local Holding = false

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = FOVEnabled

-- Aimbot
local function GetClosest()
    local closest, shortest = nil, math.huge
    local mouse = UIS:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild(AimPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
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
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position), Smoothness)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local mouse = UIS:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Visible = FOVEnabled
end)

-- ESP Logic
local function CreateESP(player)
    if player.Character and not player.Character:FindFirstChild("SkyBoxESP") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "SkyBoxESP"
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
    if ESPEnabled and BoxESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                CreateESP(player)
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("SkyBoxESP") then
                player.Character:FindFirstChild("SkyBoxESP"):Destroy()
            end
        end
    end
end)

-- Tabs & Sections
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Exploits = Window:NewTab("Exploits")
local Misc = Window:NewTab("Misc")

local CombatSection = Combat:NewSection("Aimbot")
CombatSection:NewButton("Aimbot (RMB)", "Enable aimbot when holding RMB", function()
    AimbotEnabled = not AimbotEnabled
end)
CombatSection:NewSlider("FOV Radius", "Adjust FOV size", 300, 50, function(val)
    FOVRadius = val
    FOVCircle.Radius = val
end)
CombatSection:NewSlider("Smoothness", "Adjust aimbot smoothness", 1, 0, function(val)
    Smoothness = val
end)
CombatSection:NewDropdown("Aim Part", "Choose part", {"Head", "Torso"}, function(val)
    AimPart = val
end)

local VisualSection = Visuals:NewSection("ESP")
VisualSection:NewButton("Toggle ESP Boxes", "Enable or disable box ESP", function()
    BoxESPEnabled = not BoxESPEnabled
end)
VisualSection:NewButton("Toggle FOV Circle", "Enable or disable FOV circle", function()
    FOVEnabled = not FOVEnabled
    FOVCircle.Visible = FOVEnabled
end)

local ExploitSection = Exploits:NewSection("Fun Exploits")
ExploitSection:NewButton("Infinite Jump", "Jump forever", function()
    game:GetService("UserInputService").JumpRequest:Connect(function()
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end)
end)
ExploitSection:NewButton("God Mode", "Godmode (bypass)", function()
    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Name = "GodHumanoid"
end)
ExploitSection:NewButton("Fly (FE)", "Fly script", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/Q2sZb2Vx"))()
end)

local MiscSection = Misc:NewSection("UI & Misc")
MiscSection:NewKeybind("Toggle UI", "Show/Hide UI", Enum.KeyCode.RightControl, function()
    Kavo:ToggleUI()
end)

-- Defaults
AimbotEnabled = true
ESPEnabled = true
BoxESPEnabled = true
FOVEnabled = true

print("✅ SkyWare V2 Arsenal - Final Kavo Build Loaded!")
