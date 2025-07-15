-- ✅ Skyware V2 Arsenal Script - ESP fully reworked with team check, advanced toggles, and visuals

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- ESP Settings
local ESPEnabled = true
local BoxESPEnabled = true
local NameESPEnabled = true
local TracerESPEnabled = true
local HealthESPEnabled = true
local TeamCheck = true -- ✅ New team check

local ESPObjects = {}

-- Clear ESP objects
local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        for _, v in pairs(obj) do
            if v and v.Remove then
                v:Remove()
            end
        end
    end
    ESPObjects = {}
end

-- Create ESP for player
local function CreateESP(player)
    if ESPObjects[player] then return end

    ESPObjects[player] = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Health = Drawing.new("Text")
    }

    local obj = ESPObjects[player]

    obj.Box.Color = Color3.fromRGB(255, 0, 0)
    obj.Box.Thickness = 2
    obj.Box.Filled = false

    obj.Name.Color = Color3.fromRGB(255, 255, 255)
    obj.Name.Size = 16
    obj.Name.Center = true
    obj.Name.Outline = true

    obj.Tracer.Color = Color3.fromRGB(255, 0, 0)
    obj.Tracer.Thickness = 1

    obj.Health.Color = Color3.fromRGB(0, 255, 0)
    obj.Health.Size = 14
    obj.Health.Center = true
    obj.Health.Outline = true
end

-- Update ESP per frame
local function UpdateESP()
    if not ESPEnabled then
        ClearESP()
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            if TeamCheck and player.Team == LocalPlayer.Team then
                if ESPObjects[player] then
                    for _, v in pairs(ESPObjects[player]) do
                        v.Visible = false
                    end
                end
                continue
            end

            if not ESPObjects[player] then
                CreateESP(player)
            end

            local obj = ESPObjects[player]
            local hrp = player.Character.HumanoidRootPart
            local head = player.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.3, 0))
            local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

            if onScreen then
                local height = math.abs(footPos.Y - headPos.Y)
                local width = height / 2

                -- Box
                obj.Box.Size = Vector2.new(width, height)
                obj.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                obj.Box.Visible = BoxESPEnabled

                -- Name
                obj.Name.Text = player.Name
                obj.Name.Position = Vector2.new(headPos.X, headPos.Y - 18)
                obj.Name.Visible = NameESPEnabled

                -- Tracer
                obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                obj.Tracer.To = Vector2.new(pos.X, pos.Y)
                obj.Tracer.Visible = TracerESPEnabled

                -- Health
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    obj.Health.Text = "HP: " .. math.floor(humanoid.Health)
                    obj.Health.Position = Vector2.new(headPos.X, footPos.Y + 10)
                    obj.Health.Visible = HealthESPEnabled
                else
                    obj.Health.Visible = false
                end
            else
                obj.Box.Visible = false
                obj.Name.Visible = false
                obj.Tracer.Visible = false
                obj.Health.Visible = false
            end
        elseif ESPObjects[player] then
            for _, v in pairs(ESPObjects[player]) do
                v.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

print("✅ Skyware V2 Arsenal ESP loaded with team check!")
