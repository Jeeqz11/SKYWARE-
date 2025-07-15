-- SkyWare V2 - Arsenal Final
-- Made for educational purposes only!

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Variables
local ESPEnabled, TeamCheckESP = false, true
local AimbotEnabled, TeamCheckAimbot, FOVCircleEnabled = false, true, true
local Smoothness, FOVRadius = 0.15, 120
local ESPColor = Color3.fromRGB(0, 255, 0)
local AimPart = "Head"
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false
local Boxes = {}
local Skeletons = {}

-- // UI Library
local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/DenizenScript/Venyx-UI-Library/main/main.lua"))()
local venyx = Venyx.new("SkyWare V2 - Arsenal", 5013109572)

-- Tabs
local visuals = venyx:addPage("Visuals", 5012544693)
local aimbot = venyx:addPage("Aimbot", 5012544693)
local exploits = venyx:addPage("Exploits", 5012544693)
local misc = venyx:addPage("Misc", 5012544693)

-- // FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = FOVCircleEnabled

-- // Aimbot logic
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

RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Visible = FOVCircleEnabled
    FOVCircle.Radius = FOVRadius
end)

-- // ESP logic
local function CreateESP(player)
    if Boxes[player] then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 4)
    box.Color3 = ESPColor
    box.AlwaysOnTop = true
    box.Transparency = 0.5
    box.Adornee = player.Character
    box.Parent = player.Character
    Boxes[player] = box
end

local function RemoveESP(player)
    if Boxes[player] then
        Boxes[player]:Destroy()
        Boxes[player] = nil
    end
end

local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and (not TeamCheckESP or IsEnemy(player)) then
            if ESPEnabled then
                CreateESP(player)
            else
                RemoveESP(player)
            end
        else
            RemoveESP(player)
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- // Visuals tab
visuals:addToggle("Enable ESP", false, function(v)
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

aimbot:addToggle("Show FOV Circle", true, function(v)
    FOVCircleEnabled = v
end)

aimbot:addTextbox("Aim Part", "Head", function(v)
    AimPart = v
end)

-- // Exploits tab
exploits:addButton("God Mode", function()
    if LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Name = "GodHumanoid"
    end
end)

exploits:addButton("Speed Boost", function()
    if LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.WalkSpeed = 100
    end
end)

exploits:addButton("High Jump", function()
    if LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.JumpPower = 150
    end
end)

exploits:addButton("Reset Walk/Jump", function()
    if LocalPlayer.Character then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)

-- // Misc tab
misc:addButton("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

misc:addKeybind("Toggle UI", Enum.KeyCode.RightControl, function()
    venyx:toggle()
end)

misc:addButton("Unload UI", function()
    venyx:Exit()
end)

-- Load pages
venyx:SelectPage(venyx.pages[1], true)

-- Watermark & FPS Counter
local fps = 0
local lastTick = tick()

RunService.RenderStepped:Connect(function()
    fps = math.floor(1 / (tick() - lastTick))
    lastTick = tick()
    venyx:setTitle("SkyWare V2 - Arsenal | FPS: " .. fps)
end)
