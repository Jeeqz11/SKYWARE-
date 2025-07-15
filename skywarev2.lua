-- ⚡ Skyware V2 Arsenal Script - Premium All-In-One Hub
-- Features: Aimbot, ESP, FOV Circle, Triggerbot, Infinite Jump

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Skyware V2 Hub - Arsenal",
    LoadingTitle = "Skyware Arsenal 💜",
    LoadingSubtitle = "By Jeeqz11",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local AimbotEnabled, TriggerBotEnabled, ESPEnabled = false, false, false
local FOVRadius, AimPart = 150, "Head"

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = false

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
    if input.UserInputType == Enum.UserInputType.MouseButton2 then _G.Aiming = true end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then _G.Aiming = false end
end)

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and _G.Aiming then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position)
        end
    end

    local mouse = UIS:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
end)

-- Triggerbot logic
local function GetCrossTarget()
    local mouse = UIS:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen and (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude < 10 then
                return player
            end
        end
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if TriggerBotEnabled then
        local target = GetCrossTarget()
        if target then
            mouse1press()
            wait(0.05)
            mouse1release()
        end
    end
end)

-- Infinite Jump
_G.JumpHeight = 50
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and (humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall) then
            local hrp = humanoid.Parent:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, _G.JumpHeight, 0)
            end
        end
    end
end)

-- ESP
local function EnableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local Billboard = Instance.new("BillboardGui")
            Billboard.Adornee = player.Character.Head
            Billboard.Size = UDim2.new(0, 100, 0, 40)
            Billboard.AlwaysOnTop = true
            Billboard.Parent = player.Character

            local NameLabel = Instance.new("TextLabel")
            NameLabel.Text = player.Name
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.TextColor3 = Color3.new(1, 1, 1)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Size = UDim2.new(1, 0, 1, 0)
            NameLabel.Parent = Billboard
        end
    end
end

-- Rayfield UI
local CombatTab = Window:CreateTab("Combat", 4483362458)
CombatTab:CreateToggle({ Name = "Aimbot (Hold RMB)", CurrentValue = AimbotEnabled, Callback = function(val) AimbotEnabled = val end })
CombatTab:CreateToggle({ Name = "Triggerbot", CurrentValue = TriggerBotEnabled, Callback = function(val) TriggerBotEnabled = val end })
CombatTab:CreateSlider({ Name = "FOV Radius", Range = {50, 300}, Increment = 1, CurrentValue = FOVRadius, Callback = function(val) FOVRadius = val FOVCircle.Radius = val end })

local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateToggle({ Name = "ESP", CurrentValue = ESPEnabled, Callback = function(val) ESPEnabled = val if val then EnableESP() end end })
VisualTab:CreateToggle({ Name = "FOV Circle", CurrentValue = true, Callback = function(val) FOVCircle.Visible = val end })

local MiscTab = Window:CreateTab("Misc", 4483362458)
MiscTab:CreateParagraph({ Title = "Skyware V2 Arsenal 💜", Content = "Aimbot, Triggerbot, ESP, FOV, Infinite Jump. Premium Skyware Edition." })
MiscTab:CreateKeybind({ Name = "Toggle UI", CurrentKeybind = "RightControl", HoldToInteract = false, Callback = function() Rayfield:Toggle() end })

print("✅ Skyware Arsenal Hub Loaded!")
