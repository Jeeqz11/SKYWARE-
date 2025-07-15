-- SkyWare V2 Arsenal FULL Cheat 💜 (Fixed Execution)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local ESPEnabled, EnemyOnly, AimbotEnabled = true, true, true
local ESPObjects = {}
local AimPart, Holding, FOVRadius, Smoothness = "Head", false, 150, 0.2

-- Fix: Wait for character to load
repeat task.wait() until LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- Clear ESP
local function ClearESP()
    for _, v in pairs(ESPObjects) do
        if v.Box then v.Box:Remove() end
    end
    ESPObjects = {}
end

-- Create ESP
local function CreateESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    box.Visible = false
    ESPObjects[player] = {Box = box}
end

-- Update ESP
local function UpdateESP()
    if not ESPEnabled then ClearESP() return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            if EnemyOnly and player.Team == LocalPlayer.Team then
                if ESPObjects[player] then ESPObjects[player].Box.Visible = false end
                goto continue
            end
            if not ESPObjects[player] then CreateESP(player) end
            local hrp = player.Character.HumanoidRootPart
            local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
            local sizeY = math.clamp(3000 / (hrp.Position - Camera.CFrame.Position).Magnitude, 2, 50)
            local sizeX = sizeY / 2
            local obj = ESPObjects[player]
            obj.Box.Size = Vector2.new(sizeX, sizeY)
            obj.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
            obj.Box.Visible = onscreen
            ::continue::
        elseif ESPObjects[player] then
            ESPObjects[player].Box.Visible = false
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- Aimbot
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = true

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Holding = true end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then Holding = false end
end)

local function GetClosestTarget()
    local closest, shortest = nil, math.huge
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

RunService.RenderStepped:Connect(function()
    if AimbotEnabled and Holding then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position), Smoothness)
        end
    end
    local mouse = UIS:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
end)

-- Stable Exploits
local function EnableInfiniteJump()
    UIS.JumpRequest:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end

local function EnableGodMode()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        end)
    end
end

EnableInfiniteJump()
EnableGodMode()

print("✅ SkyWare V2 FULL Cheat fixed and fully loaded!")
