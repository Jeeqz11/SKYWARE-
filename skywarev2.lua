-- SkyWare V2 - Arsenal (Final Ultimate Build)
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

-- // UI
local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/DenizenScript/Venyx-UI-Library/main/main.lua"))()
local venyx = Venyx.new("SkyWare V2 - Arsenal", 5013109572)

local visuals = venyx:addPage("Visuals", 5012544693)
local aimbot = venyx:addPage("Aimbot", 5012544693)
local exploits = venyx:addPage("Exploits", 5012544693)
local misc = venyx:addPage("Misc", 5012544693)

-- // ESP Drawing
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

-- Silent Aim hook
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
visuals:addToggle("Enable ESP", true, function(v)
    ESPEnabled = v
end)
visuals:addToggle("Team Check", true, function(v)
    TeamCheckESP = v
end)
visuals:addColorPicker("ESP Color", Color3.fromRGB(0, 255, 0), function(v)
    ESPColor = v
end)

-- // Aimbot tab
aimbot:addToggle("Enable Aimbot", false, function(v)
    AimbotEnabled = v
end)
aimbot:addToggle("Team Check", true, function(v)
    TeamCheckAimbot = v
end)
aimbot:addSlider("Smoothness", 0, 1, 0.15, function(v)
    Smoothness = v
end)
aimbot:addSlider("FOV Radius", 50, 300, 120, function(v)
    FOVRadius = v
end)
aimbot:addToggle("Silent Aim", false, function(v)
    SilentAimEnabled = v
end)
aimbot:addTextbox("Aim Part", "Head", function(v)
    AimPart = v
end)

-- // Exploits tab
exploits:addToggle("Godmode", false, function(v)
    GodmodeEnabled = v
end)
exploits:addToggle("WalkSpeed", false, function(v)
    WalkSpeedEnabled = v
end)
exploits:addToggle("Infinite Jump", false, function(v)
    InfiniteJumpEnabled = v
end)

-- // Misc tab
misc:addButton("Rejoin", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
misc:addKeybind("Toggle UI", Enum.KeyCode.RightControl, function()
    venyx:toggle()
end)
misc:addButton("Unload UI", function()
    venyx:Exit()
end)

-- // FPS Counter & Title
local fps = 0
local lastTick = tick()

RunService.RenderStepped:Connect(function()
    fps = math.floor(1 / (tick() - lastTick))
    lastTick = tick()
    venyx:setTitle("SkyWare V2 - Arsenal | FPS: " .. fps)
end)

venyx:SelectPage(venyx.pages[1], true)
