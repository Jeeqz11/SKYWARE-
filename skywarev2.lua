-- SkyWare V2 - Arsenal (Material UI Shlexware Style)
-- Educational purposes only!

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Variables
local ESPEnabled, TeamCheckESP = true, true
local BoxESP, SkeletonESP, TracerESP = true, false, false
local ESPColor = Color3.fromRGB(0, 255, 0)
local AimbotEnabled, TeamCheckAimbot, FOVCircleEnabled = false, true, true
local SilentAimEnabled = false
local GodmodeEnabled = false
local WalkSpeedEnabled = false
local InfiniteJumpEnabled = false
local Smoothness, FOVRadius = 0.15, 120
local AimPart = "Head"
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false
local Drawings = {}

-- // UI Library
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/main/Module.lua"))()

local UI = Material.Load({
    Title = "SkyWare V2 - Arsenal",
    Style = 1,
    SizeX = 500,
    SizeY = 450,
    Theme = "Dark"
})

-- // Tabs
local VisualsTab = UI.New({Title = "Visuals"})
local AimbotTab = UI.New({Title = "Aimbot"})
local ExploitsTab = UI.New({Title = "Exploits"})
local MiscTab = UI.New({Title = "Misc"})

-- // ESP
local function ClearESP()
    for _, v in pairs(Drawings) do
        if v.Remove then v:Remove() end
    end
    Drawings = {}
end

local function AddESP(player)
    ClearESP()
    if not player.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = ESPColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = ESPColor
    highlight.OutlineTransparency = 0
    highlight.Adornee = player.Character
    highlight.Parent = player.Character
    Drawings[player] = highlight
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and (not TeamCheckESP or player.Team ~= LocalPlayer.Team) then
            if ESPEnabled and BoxESP then
                AddESP(player)
            else
                if Drawings[player] then
                    Drawings[player]:Destroy()
                    Drawings[player] = nil
                end
            end
        end
    end
end)

-- // Aimbot & Silent Aim
local function GetClosest()
    local closest, dist = nil, math.huge
    local mouse = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) and (not TeamCheckAimbot or player.Team ~= LocalPlayer.Team) then
            local pos, vis = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if vis then
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
            local targetPos = target.Character[AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Smoothness)
        end
    end
end)

local __namecall
__namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if SilentAimEnabled and method == "FindPartOnRayWithIgnoreList" then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            args[1] = Ray.new(Camera.CFrame.Position, (target.Character[AimPart].Position - Camera.CFrame.Position).Unit * 1000)
            return __namecall(self, unpack(args))
        end
    end
    return __namecall(self, ...)
end)

-- // Godmode
RunService.RenderStepped:Connect(function()
    if GodmodeEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
    end
end)

-- // WalkSpeed & Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

RunService.RenderStepped:Connect(function()
    if WalkSpeedEnabled and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.WalkSpeed = 100
    else
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

-- // Visuals tab
VisualsTab.Toggle({
    Text = "Enable ESP",
    Callback = function(Value) ESPEnabled = Value end,
    Enabled = true
})
VisualsTab.Toggle({
    Text = "Team Check",
    Callback = function(Value) TeamCheckESP = Value end,
    Enabled = true
})
VisualsTab.ColorPicker({
    Text = "ESP Color",
    Default = ESPColor,
    Callback = function(Value) ESPColor = Value end
})

-- // Aimbot tab
AimbotTab.Toggle({
    Text = "Enable Aimbot",
    Callback = function(Value) AimbotEnabled = Value end,
    Enabled = false
})
AimbotTab.Toggle({
    Text = "Team Check",
    Callback = function(Value) TeamCheckAimbot = Value end,
    Enabled = true
})
AimbotTab.Toggle({
    Text = "Silent Aim",
    Callback = function(Value) SilentAimEnabled = Value end,
    Enabled = false
})
AimbotTab.Slider({
    Text = "Smoothness",
    Min = 0,
    Max = 1,
    Def = 0.15,
    Callback = function(Value) Smoothness = Value end
})
AimbotTab.Slider({
    Text = "FOV Radius",
    Min = 50,
    Max = 300,
    Def = 120,
    Callback = function(Value) FOVRadius = Value end
})
AimbotTab.TextField({
    Text = "Aim Part",
    Placeholder = "Head",
    Callback = function(Value) AimPart = Value end
})

-- // Exploits tab
ExploitsTab.Toggle({
    Text = "Godmode",
    Callback = function(Value) GodmodeEnabled = Value end,
    Enabled = false
})
ExploitsTab.Toggle({
    Text = "WalkSpeed",
    Callback = function(Value) WalkSpeedEnabled = Value end,
    Enabled = false
})
ExploitsTab.Toggle({
    Text = "Infinite Jump",
    Callback = function(Value) InfiniteJumpEnabled = Value end,
    Enabled = false
})

-- // Misc tab
MiscTab.Button({
    Text = "Rejoin",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})
MiscTab.Keybind({
    Text = "Toggle UI",
    Key = Enum.KeyCode.RightControl,
    Callback = function()
        UI.Toggle()
    end
})
MiscTab.Button({
    Text = "Unload UI",
    Callback = function()
        UI.Break()
    end
})

-- // FPS & watermark
local fps = 0
local lastTick = tick()

RunService.RenderStepped:Connect(function()
    fps = math.floor(1 / (tick() - lastTick))
    lastTick = tick()
    UI:SetTitle("SkyWare V2 - Arsenal | FPS: " .. fps)
end)
