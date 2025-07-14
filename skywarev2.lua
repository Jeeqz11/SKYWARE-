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
local ESPColor = Color3.fromRGB(0, 255, 0)

local AimbotEnabled, TeamCheckAimbot, FOVCircleEnabled, SilentAimEnabled = false, true, true, false
local Smoothness, FOVRadius = 0.2, 120
local AimPart = "Head"
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false

local WalkSpeed, JumpPower = 16, 50
local GodMode = false

-- Drawings
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = FOVCircleEnabled

local TextLabel = Drawing.new("Text")
TextLabel.Visible = true
TextLabel.Center = false
TextLabel.Outline = true
TextLabel.Font = 2
TextLabel.Size = 18
TextLabel.Color = Color3.fromRGB(255, 255, 255)

local fps, lastTick, frameCount = 0, tick(), 0

-- Functions
local function IsEnemy(player)
    return player.Team ~= LocalPlayer.Team
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

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and (not TeamCheckESP or IsEnemy(player)) then
            if ESPEnabled then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local esp = Drawing.new("Text")
                    esp.Text = player.Name
                    esp.Color = ESPColor
                    esp.Size = 16
                    esp.Center = true
                    esp.Outline = true
                    esp.Position = Vector2.new(pos.X, pos.Y - 20)
                    task.delay(0.03, function()
                        esp:Remove()
                    end)
                end
            end
        end
    end
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
    -- Aimbot
    if AimbotEnabled and Holding then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            local pos = target.Character[AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), Smoothness)
        end
    end

    -- FOV circle
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = FOVRadius

    -- ESP
    UpdateESP()

    -- FPS + watermark
    frameCount = frameCount + 1
    if tick() - lastTick >= 1 then
        fps = frameCount
        frameCount = 0
        lastTick = tick()
    end
    TextLabel.Text = string.format("SkyWare V2 - Arsenal | FPS: %d", fps)
    TextLabel.Position = Vector2.new(10, 10)

    -- Exploit stats
    if GodMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = math.huge
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = JumpPower
    end
end)

-- Silent Aim (basic example, only works with some executors)
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

-- UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("SkyWare V2 - Arsenal", "Sentinel")

-- Visuals
local VisualTab = Window:NewTab("Visuals")
local VisualSection = VisualTab:NewSection("ESP Settings")
VisualSection:NewToggle("Enable ESP", "Toggle ESP", function(state)
    ESPEnabled = state
end)
VisualSection:NewToggle("Team Check", "Only show enemies", function(state)
    TeamCheckESP = state
end)
VisualSection:NewColorPicker("ESP Color", "Pick color", Color3.fromRGB(0, 255, 0), function(color)
    ESPColor = color
end)

-- Aimbot
local AimbotTab = Window:NewTab("Aimbot")
local AimbotSection = AimbotTab:NewSection("Aimbot Settings")
AimbotSection:NewToggle("Enable Aimbot", "Toggle aimbot", function(state)
    AimbotEnabled = state
end)
AimbotSection:NewToggle("Team Check", "Only target enemies", function(state)
    TeamCheckAimbot = state
end)
AimbotSection:NewSlider("Smoothness", "Aim smoothness", 1, 0, function(val)
    Smoothness = val
end)
AimbotSection:NewSlider("FOV Radius", "FOV Radius", 300, 50, function(val)
    FOVRadius = val
end)
AimbotSection:NewKeybind("Aimbot Key", "Key to hold", Enum.KeyCode.MouseButton2, function() end)
AimbotSection:NewDropdown("Aim Part", "Where to aim", {"Head", "Torso"}, function(val)
    AimPart = val
end)
AimbotSection:NewToggle("Show FOV Circle", "Show FOV Circle", function(state)
    FOVCircleEnabled = state
end)

-- Exploits
local ExploitsTab = Window:NewTab("Exploits")
local ExploitsSection = ExploitsTab:NewSection("Exploits")
ExploitsSection:NewToggle("God Mode", "Infinite health (bannable)", function(state)
    GodMode = state
end)
ExploitsSection:NewToggle("Silent Aim", "Legit silent aim (bannable)", function(state)
    SilentAimEnabled = state
end)
ExploitsSection:NewSlider("Walk Speed", "Change speed", 250, 16, function(val)
    WalkSpeed = val
end)
ExploitsSection:NewSlider("Jump Power", "Change jump power", 250, 50, function(val)
    JumpPower = val
end)

-- Misc
local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Misc Settings")
MiscSection:NewButton("Rejoin", "Rejoin game", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
MiscSection:NewButton("Unload", "Unload UI", function()
    Library:Destroy()
    FOVCircle:Remove()
    TextLabel:Remove()
end)
MiscSection:NewToggle("Crosshair", "Show crosshair", function(state)
    game:GetService("StarterGui"):SetCore("ToggleMouseIcon", state)
end)
MiscSection:NewButton("Unlock FPS", "Set FPS cap to 360", function()
    setfpscap(360)
end)
MiscSection:NewButton("Chat Spam", "Spam chat", function()
    while true do
        wait(1)
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("SkyWare V2 on top!", "All")
    end
end)

-- Credits
local CreditsTab = Window:NewTab("Credits")
local CreditsSection = CreditsTab:NewSection("SkyWare V2 - Arsenal")
CreditsSection:NewLabel("Script by SkyWare Team")
CreditsSection:NewLabel("Discord: SkyWareV2")
CreditsSection:NewLabel("Version: Final")

print("✅ SkyWare V2 Mega Hub Loaded!")
