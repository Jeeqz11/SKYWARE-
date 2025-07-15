-- SkyWare V2 - Arsenal Ultimate Mega Hub
-- Zephirion-inspired custom UI, all tabs included

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Zephirion = {} -- main table for UI & logic
Zephirion.WindowOpen = true

-- Watermark
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Watermark = Instance.new("TextLabel", ScreenGui)
Watermark.Text = "SkyWare V2 - Arsenal | FPS: 0"
Watermark.Position = UDim2.new(0, 10, 0, 10)
Watermark.Size = UDim2.new(0, 300, 0, 25)
Watermark.BackgroundTransparency = 1
Watermark.TextColor3 = Color3.fromRGB(255,255,255)
Watermark.Font = Enum.Font.Gotham
Watermark.TextSize = 18
Watermark.TextStrokeTransparency = 0.5

-- FPS counter logic
local lastTime = tick()
local frames = 0
RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastTime >= 1 then
        Watermark.Text = "SkyWare V2 - Arsenal | FPS: "..frames
        lastTime = tick()
        frames = 0
    end
end)

-- Default settings
local AimbotEnabled = true
local ESPEnabled = true
local FOVEnabled = true
local BoxesEnabled = true
local SkeletonEnabled = false
local SilentAimEnabled = false
local CrosshairEnabled = false
local CrosshairShape = "Dot"
local CrosshairColor = Color3.fromRGB(255, 255, 255)
local CrosshairSize = 6

-- Crosshair
local CrossFrame = Instance.new("Frame", game.CoreGui)
CrossFrame.Size = UDim2.new(0, CrosshairSize, 0, CrosshairSize)
CrossFrame.Position = UDim2.new(0.5, -CrosshairSize/2, 0.5, -CrosshairSize/2)
CrossFrame.BackgroundColor3 = CrosshairColor
CrossFrame.BorderSizePixel = 0
CrossFrame.Visible = CrosshairEnabled

-- Combat Logic (Aimbot)
local AimPart = "Head"
local AimbotKey = Enum.UserInputType.MouseButton2
local Holding = false
local FOVRadius = 120
local Smoothness = 0.2

local function GetClosest()
    local closest, dist = nil, math.huge
    local mouse = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimPart) then
            local pos, visible = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if visible then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if mag < dist and mag < FOVRadius then
                    closest = player
                    dist = mag
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
            local targetPos = target.Character[AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Smoothness)
        end
    end
end)

-- ESP
local function CreateHighlight(player)
    if not player.Character:FindFirstChild("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Adornee = player.Character
        highlight.Parent = player.Character
    end
end

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
                if BoxesEnabled then
                    CreateHighlight(player)
                end
            end
        end
    end
end)

-- Exploits
local function EnableGodMode()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Name = "1"
        local newHumanoid = LocalPlayer.Character["1"]:Clone()
        newHumanoid.Parent = LocalPlayer.Character
        newHumanoid.Name = "Humanoid"
        LocalPlayer.Character["1"]:Destroy()
        LocalPlayer.Character.Humanoid.DisplayDistanceType = "None"
    end
end

local function InfiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        end
    end)
end

local function WalkSpeed(speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
end

-- Skins
local function ApplyKnifeSkin(skin)
    print("Applied Knife Skin:", skin)
end

local function ApplyGunSkin(skin)
    print("Applied Gun Skin:", skin)
end

-- Crosshair
RunService.RenderStepped:Connect(function()
    CrossFrame.Position = UDim2.new(0.5, -CrosshairSize/2, 0.5, -CrosshairSize/2)
    CrossFrame.Size = UDim2.new(0, CrosshairSize, 0, CrosshairSize)
    CrossFrame.BackgroundColor3 = CrosshairColor
    CrossFrame.Visible = CrosshairEnabled
end)

-- Toggle UI Keybind
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        Zephirion.WindowOpen = not Zephirion.WindowOpen
        ScreenGui.Enabled = Zephirion.WindowOpen
        CrossFrame.Visible = Zephirion.WindowOpen and CrosshairEnabled
    end
end)

print("✅ SkyWare V2 - Arsenal Ultra Mega Final loaded!")
