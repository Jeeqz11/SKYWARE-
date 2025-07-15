--[[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠑⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⢣⠀⠀⠀⠀⠀⢀⣀⣤⣤⣤⣄⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣴⠋⠀⠀⠀⠀⠀⠘⣆⠀⠀⣠⡾⠛⠋⠁⠀⠈⠻⣦⠀⠀
⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠀⢸⡆⢠⡏⠀⠀⠀SKYWARE⠀⠙⣇⠀
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣸⡇⠀⠀⠀V2 HUB⠀⠀⠀⠸⡄
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
]]

-- 🌟 SKYWARE V2 ULTIMATE MEGA HUB 🌟
-- 💜 Aimbot, ESP, Exploits, all in one. Final master build.

-- Libraries
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/UI-Libraries/main/Kavo/UI.lua"))()

local Window = Kavo:CreateLib("SkyWare V2 - Arsenal & FPS Hub", "Sentinel") -- Purple gradient theme

-- Tabs
local CombatTab = Window:NewTab("Combat")
local VisualTab = Window:NewTab("Visuals")
local ExploitTab = Window:NewTab("Exploits")
local MiscTab = Window:NewTab("Misc")

-- Sections
local AimbotSection = CombatTab:NewSection("Aimbot")
local VisualSection = VisualTab:NewSection("ESP Options")
local ExploitSection = ExploitTab:NewSection("Powerful Exploits")
local MiscSection = MiscTab:NewSection("Miscellaneous")

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Holding = false

local AimbotEnabled = true
local ESPEnabled = true
local BoxESPEnabled = true
local FOVCircleEnabled = true
local SilentAimEnabled = false

local AimPart = "Head"
local FOVRadius = 150
local Smoothness = 0.3

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = FOVCircleEnabled

-- Aimbot Logic
local function GetClosestTarget()
    local closest = nil
    local shortest = math.huge
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

-- Update FOV
RunService.RenderStepped:Connect(function()
    local mouse = UIS:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Visible = FOVCircleEnabled
end)

-- ESP Logic
local function CreateESP(player)
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = player.Character
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Size = Vector3.new(4, 7, 4)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.5
    box.Parent = player.Character
end

local function RemoveESP(player)
    for _, v in pairs(player.Character:GetChildren()) do
        if v:IsA("BoxHandleAdornment") then
            v:Destroy()
        end
    end
end

RunService.RenderStepped:Connect(function()
    if ESPEnabled and BoxESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and not player.Character:FindFirstChildWhichIsA("BoxHandleAdornment") then
                CreateESP(player)
            elseif not ESPEnabled then
                RemoveESP(player)
            end
        end
    end
end)

-- Exploits
ExploitSection:NewButton("Infinite Jump", "Jump infinitely", function()
    game:GetService("UserInputService").JumpRequest:connect(function()
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end)
end)

ExploitSection:NewButton("Fly Mode", "Fly around the map", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/Q2sZb2Vx"))()
end)

ExploitSection:NewButton("God Mode", "Become invincible", function()
    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Name = "GodHumanoid"
end)

ExploitSection:NewButton("Silent Aim", "Shoot without aiming at target", function()
    SilentAimEnabled = true
end)

ExploitSection:NewButton("No Recoil", "Removes weapon recoil", function()
    print("No recoil activated (placeholder logic)")
end)

ExploitSection:NewButton("No Spread", "Removes weapon spread", function()
    print("No spread activated (placeholder logic)")
end)

ExploitSection:NewButton("Rapid Fire", "Shoot super fast", function()
    print("Rapid fire activated (placeholder logic)")
end)

ExploitSection:NewButton("Kill Aura", "Auto kill nearby enemies", function()
    print("Kill Aura activated (placeholder logic)")
end)

ExploitSection:NewButton("Teleport to Enemy", "Teleport to closest enemy", function()
    local target = GetClosestTarget()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    end
end)

ExploitSection:NewButton("AI Auto Play", "Let AI play for you", function()
    print("AI Auto Play activated (basic placeholder logic)")
end)

ExploitSection:NewButton("Anti-AFK", "Never get kicked", function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)

ExploitSection:NewSlider("WalkSpeed", "Adjust walk speed", 100, 16, function(value)
    LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
end)

ExploitSection:NewButton("Rainbow Gun", "Cycle weapon colors", function()
    print("Rainbow Gun activated (placeholder logic)")
end)

ExploitSection:NewButton("Rainbow Player", "Cycle player colors", function()
    print("Rainbow Player activated (placeholder logic)")
end)

-- Misc
MiscSection:NewKeybind("Toggle UI", "Show or hide GUI", Enum.KeyCode.RightControl, function()
    Kavo:ToggleUI()
end)

MiscSection:NewLabel("SkyWare V2 by Jeeqz11 💜")

-- Defaults
AimbotEnabled = true
ESPEnabled = true
BoxESPEnabled = true
FOVCircleEnabled = true

-- Done
print("✅ SkyWare V2 Ultimate Mega Hub loaded successfully!")
