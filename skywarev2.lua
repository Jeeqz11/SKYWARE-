-- ⚠️ This script is for educational purposes only. Do not use in live games.
-- Arsenal Kavo UI script with advanced features: aimbot, ESP, chams, exploits, misc, and cosmetic spoofer.

loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Library.CreateLib("Arsenal Hub", "Midnight")

-- Aimbot Tab
local AimbotTab = Window:NewTab("Aimbot")
local AimbotSection = AimbotTab:NewSection("Aimbot")

local aimbotEnabled = false
AimbotSection:NewToggle("Enable Aimbot", "Toggle aimbot on/off", function(state)
    aimbotEnabled = state
end)

local silentAim = false
AimbotSection:NewToggle("Silent Aim", "Shoot enemies without aiming directly", function(state)
    silentAim = state
end)

local aimFOV = 100
AimbotSection:NewSlider("Aimbot FOV", "Field of view for aimbot", 360, 10, function(value)
    aimFOV = value
end)

-- Visuals Tab
local VisualTab = Window:NewTab("Visuals")
local VisualSection = VisualTab:NewSection("ESP & Chams")

local espEnabled = false
VisualSection:NewToggle("Enable ESP", "Show enemies through walls", function(state)
    espEnabled = state
end)

local chamsEnabled = false
VisualSection:NewToggle("Enable Chams", "Color enemy models", function(state)
    chamsEnabled = state
end)

-- Exploits Tab
local ExploitTab = Window:NewTab("Exploits")
local ExploitSection = ExploitTab:NewSection("Exploits")

ExploitSection:NewButton("Fly (F Key)", "Toggle fly mode", function()
    local fly = false
    local uis = game:GetService("UserInputService")
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0,0,0)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = hrp

    local function toggleFly()
        fly = not fly
        bv.MaxForce = fly and Vector3.new(9e9, 9e9, 9e9) or Vector3.new(0, 0, 0)
    end

    uis.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F then
            toggleFly()
        end
    end)

    game:GetService("RunService").Heartbeat:Connect(function()
        if fly then
            bv.Velocity = plr:GetMouse().Hit.LookVector * 100
        end
    end)
end)

ExploitSection:NewButton("No Fall Damage", "Remove fall damage", function()
    game.Players.LocalPlayer.Character.FallDamageScript:Destroy()
end)

ExploitSection:NewButton("Infinite Jump", "Jump infinitely", function()
    game:GetService("UserInputService").JumpRequest:Connect(function()
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end)
end)

-- Misc Tab
local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Misc Features")

MiscSection:NewButton("Cosmetic Spoofer", "Spoof skins and cosmetics", function()
    local player = game.Players.LocalPlayer
    local cosmetics = player:FindFirstChild("Cosmetics")
    if cosmetics then
        cosmetics:Destroy()
        local spoof = Instance.new("Folder")
        spoof.Name = "Cosmetics"
        spoof.Parent = player
    end
end)

MiscSection:NewButton("Unlock All Skins", "Visually unlock all skins", function()
    for _, v in pairs(game.ReplicatedStorage.Skins:GetChildren()) do
        v.Value = true
    end
end)

-- Logic for aimbot and visuals
local function getClosestTarget()
    local plr = game.Players.LocalPlayer
    local mouse = plr:GetMouse()
    local closest = nil
    local shortest = math.huge

    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Team ~= plr.Team then
            local screenPoint = workspace.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude

            if dist < shortest and dist < aimFOV then
                shortest = dist
                closest = v
            end
        end
    end
    return closest
end

game:GetService("RunService").RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end

    if espEnabled then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                if not v.Character:FindFirstChild("ESPBox") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "ESPBox"
                    box.Adornee = v.Character.HumanoidRootPart
                    box.Size = Vector3.new(4, 6, 4)
                    box.Transparency = 0.5
                    box.Color3 = Color3.new(1, 0, 0)
                    box.AlwaysOnTop = true
                    box.Parent = v.Character
                end
            end
        end
    end

    if chamsEnabled then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character then
                for _, part in pairs(v.Character:GetDescendants()) do
                    if part:IsA("BasePart") and not part:FindFirstChild("Cham") then
                        local cham = Instance.new("BoxHandleAdornment")
                        cham.Name = "Cham"
                        cham.Adornee = part
                        cham.Size = part.Size
                        cham.Color3 = Color3.new(0, 1, 0)
                        cham.Transparency = 0.5
                        cham.AlwaysOnTop = true
                        cham.Parent = part
                    end
                end
            end
        end
    end
end)

print("✅ Arsenal script loaded with advanced features.")
