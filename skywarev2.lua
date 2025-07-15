local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SkyWare V2 HUB - Ultimate", "BloodTheme")

-- Tabs
local AimbotTab = Window:NewTab("Aimbot")
local VisualsTab = Window:NewTab("Visuals")
local ExploitsTab = Window:NewTab("Exploits")
local MiscTab = Window:NewTab("Misc")

-- Sections
local AimbotSection = AimbotTab:NewSection("Aimbot Settings")
local VisualsSection = VisualsTab:NewSection("ESP Settings")
local ExploitsSection = ExploitsTab:NewSection("Game Exploits")
local MiscSection = MiscTab:NewSection("Misc Options")

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local AimbotEnabled = true
local ESPEnabled = true
local SilentAim = false
local GodMode = false
local WalkSpeed = 16
local InfJump = false
local CrosshairVisible = false

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

-- Aimbot functions
local function GetClosestEnemy()
    local closest, shortest = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild(AimbotPart) then
            local pos, vis = Camera:WorldToViewportPoint(player.Character[AimbotPart].Position)
            if vis then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if dist < shortest and dist < FOV then
                    shortest = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and Holding then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild(AimbotPart) then
            local aimPos = target.Character[AimbotPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), Smoothness)
        end
    end
end)

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

-- ESP functions
local Highlights = {}

local function EnableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
            if not player.Character:FindFirstChild("SkyESP") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SkyESP"
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
        if player.Character and player.Character:FindFirstChild("SkyESP") then
            player.Character.SkyESP:Destroy()
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

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        EnableESP()
    else
        DisableESP()
    end

    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = FOV
end)

-- Aimbot UI
AimbotSection:NewToggle("Enable Aimbot", "Toggle Aimbot", true, function(value)
    AimbotEnabled = value
end)

AimbotSection:NewDropdown("Aim Part", "Select body part", {"Head", "Torso"}, function(option)
    AimbotPart = option
end)

AimbotSection:NewSlider("Smoothness", "Aim smoothing", 1, 0.1, 0.2, function(value)
    Smoothness = value
end)

AimbotSection:NewSlider("FOV Radius", "Adjust FOV", 300, 50, 120, function(value)
    FOV = value
    FOVCircle.Radius = value
end)

-- Visuals UI
VisualsSection:NewToggle("Enable ESP", "Toggle ESP", true, function(value)
    ESPEnabled = value
end)

VisualsSection:NewColorPicker("ESP Color", "Pick ESP color", Color3.fromRGB(0, 255, 0), function(color)
    for _, highlight in pairs(Highlights) do
        highlight.FillColor = color
    end
end)

-- Exploits UI
ExploitsSection:NewToggle("Silent Aim", "Silent aim (may be risky)", false, function(value)
    SilentAim = value
end)

ExploitsSection:NewToggle("God Mode", "May not work everywhere", false, function(value)
    GodMode = value
    if value then
        if LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Name = "God"
        end
    else
        if LocalPlayer.Character:FindFirstChild("God") then
            LocalPlayer.Character.God.Name = "Humanoid"
        end
    end
end)

ExploitsSection:NewSlider("WalkSpeed", "Adjust speed", 100, 16, 16, function(value)
    WalkSpeed = value
    if LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeed
    end
end)

ExploitsSection:NewButton("Infinite Jump", "Toggle infinite jump", function()
    InfJump = not InfJump
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if InfJump and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character:FindFirstChild("Humanoid"):ChangeState("Jumping")
        end
    end)
end)

-- Misc UI
MiscSection:NewToggle("Show Crosshair", "Toggle custom crosshair", false, function(value)
    CrosshairVisible = value
end)

MiscSection:NewKeybind("Toggle UI", "Key to open/close", Enum.KeyCode.RightShift, function()
    Library:ToggleUI()
end)

MiscSection:NewColorPicker("Theme Color", "Change theme", Color3.fromRGB(255, 0, 0), function(color)
    -- Example: Change drawing colors, background, etc. if you want.
end)

---

## ✅ ⭐ **How to use**

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/skywarev2.lua"))()
