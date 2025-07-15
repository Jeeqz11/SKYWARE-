-- SkyWare V2 - Arsenal - FULL FINAL FUNCTIONAL SCRIPT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Setup
local SkyWareGUI = Instance.new("ScreenGui")
SkyWareGUI.Name = "SkyWareV2"
SkyWareGUI.ResetOnSpawn = false
SkyWareGUI.Parent = game:GetService("CoreGui")

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = SkyWareGUI

-- Watermark
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 300, 0, 30)
Watermark.Position = UDim2.new(0, 10, 0, 10)
Watermark.BackgroundTransparency = 1
Watermark.Text = "SkyWare V2 - Arsenal"
Watermark.TextColor3 = Color3.fromRGB(0, 175, 255)
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 18
Watermark.TextXAlignment = Enum.TextXAlignment.Left
Watermark.Parent = SkyWareGUI

-- Main Panel
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(1, -160, 1, 0)
MainPanel.Position = UDim2.new(0, 160, 0, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainPanel.BorderSizePixel = 0
MainPanel.Parent = SkyWareGUI

-- Panel Title
local PanelTitle = Instance.new("TextLabel")
PanelTitle.Size = UDim2.new(1, 0, 0, 50)
PanelTitle.BackgroundTransparency = 1
PanelTitle.Text = "Welcome to SkyWare V2"
PanelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
PanelTitle.Font = Enum.Font.GothamBold
PanelTitle.TextSize = 22
PanelTitle.Parent = MainPanel

-- Tabs
local tabs = {
    "Combat",
    "Visuals",
    "Exploit",
    "Miscellaneous"
}

local contentFrames = {}

-- Function to create content frame for each tab
local function CreateContentFrame(tabName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, -50)
    frame.Position = UDim2.new(0, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = MainPanel

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Text = tabName.." Settings"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20
    label.BackgroundTransparency = 1
    label.Parent = frame

    contentFrames[tabName] = frame
end

for _, tabName in ipairs(tabs) do
    CreateContentFrame(tabName)
end

-- Create sidebar buttons
for i, tabName in ipairs(tabs) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, 0, (i - 1) * 45 + 50)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Text = tabName
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = Sidebar

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end)

    button.MouseButton1Click:Connect(function()
        for _, frame in pairs(contentFrames) do
            frame.Visible = false
        end
        PanelTitle.Text = tabName .. " Tab"
        contentFrames[tabName].Visible = true
    end)
end

-------------------------------------
-- ACTUAL FUNCTIONALITY
-------------------------------------

-- Combat Tab
local CombatFrame = contentFrames["Combat"]
local AimbotEnabled = false
local SilentAimEnabled = false
local AimPart = "Head"

local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(0, 200, 0, 30)
AimbotToggle.Position = UDim2.new(0, 20, 0, 50)
AimbotToggle.Text = "Enable Aimbot [OFF]"
AimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.Gotham
AimbotToggle.TextSize = 14
AimbotToggle.Parent = CombatFrame

AimbotToggle.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotToggle.Text = "Enable Aimbot ["..(AimbotEnabled and "ON" or "OFF").."]"
end)

local function GetClosest()
    local closest, dist = nil, math.huge
    local mouse = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild(AimPart) then
            local pos, visible = Camera:WorldToViewportPoint(player.Character[AimPart].Position)
            if visible then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if mag < dist then
                    closest, dist = player, mag
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild(AimPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position)
        end
    end
end)

-- Visuals Tab
local VisualsFrame = contentFrames["Visuals"]
local ESPEnabled = true
local Highlights = {}

local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(0, 200, 0, 30)
ESPToggle.Position = UDim2.new(0, 20, 0, 50)
ESPToggle.Text = "Enable Box ESP [ON]"
ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Font = Enum.Font.Gotham
ESPToggle.TextSize = 14
ESPToggle.Parent = VisualsFrame

ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggle.Text = "Enable Box ESP ["..(ESPEnabled and "ON" or "OFF").."]"
end)

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
            if ESPEnabled then
                if not Highlights[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = player.Character
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = player.Character
                    Highlights[player] = highlight
                end
            else
                if Highlights[player] then
                    Highlights[player]:Destroy()
                    Highlights[player] = nil
                end
            end
        end
    end
end)

-- Exploit Tab
local ExploitFrame = contentFrames["Exploit"]

local GodModeButton = Instance.new("TextButton")
GodModeButton.Size = UDim2.new(0, 200, 0, 30)
GodModeButton.Position = UDim2.new(0, 20, 0, 50)
GodModeButton.Text = "Enable God Mode"
GodModeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
GodModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GodModeButton.Font = Enum.Font.Gotham
GodModeButton.TextSize = 14
GodModeButton.Parent = ExploitFrame

GodModeButton.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Name = "1"
        local clone = LocalPlayer.Character.Humanoid:Clone()
        clone.Name = "Humanoid"
        clone.Parent = LocalPlayer.Character
        wait(0.1)
        LocalPlayer.Character["1"]:Destroy()
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        print("God Mode Activated!")
    end
end)

-- Miscellaneous Tab
local MiscFrame = contentFrames["Miscellaneous"]

local CloseKeybind = Instance.new("TextButton")
CloseKeybind.Size = UDim2.new(0, 200, 0, 30)
CloseKeybind.Position = UDim2.new(0, 20, 0, 50)
CloseKeybind.Text = "Toggle UI [Insert]"
CloseKeybind.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CloseKeybind.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseKeybind.Font = Enum.Font.Gotham
CloseKeybind.TextSize = 14
CloseKeybind.Parent = MiscFrame

local UISOpen = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        UISOpen = not UISOpen
        SkyWareGUI.Enabled = UISOpen
    end
end)

-------------------------------------

-- Show default first tab
contentFrames["Combat"].Visible = true
PanelTitle.Text = "Combat Tab"
