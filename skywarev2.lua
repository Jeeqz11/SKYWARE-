-- SkyWare V2 - Arsenal Mega Hub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Watermark
local watermark = Instance.new("TextLabel")
watermark.Text = "SkyWare V2 - Arsenal"
watermark.Size = UDim2.new(0, 300, 0, 30)
watermark.Position = UDim2.new(0, 10, 0, 10)
watermark.BackgroundTransparency = 1
watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
watermark.Font = Enum.Font.GothamBold
watermark.TextSize = 20
watermark.Parent = game:GetService("CoreGui")

-- Main UI Container
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "SkyWareV2"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 450)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local TabFolder = Instance.new("Folder", MainFrame)
TabFolder.Name = "Tabs"

-- Tab Buttons
local Tabs = {"Combat", "Exploit", "Skin Changer", "Misc"}
local Frames = {}

for i, tabName in ipairs(Tabs) do
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 120, 0, 30)
    Button.Position = UDim2.new(0, 10 + (i-1)*130, 0, 10)
    Button.Text = tabName
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.Parent = MainFrame

    local HoverAnim = Instance.new("UICorner", Button)
    HoverAnim.CornerRadius = UDim.new(0, 6)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 1, -50)
    Frame.Position = UDim2.new(0, 10, 0, 50)
    Frame.BackgroundTransparency = 1
    Frame.Visible = (i == 1)
    Frame.Parent = TabFolder
    Frames[tabName] = Frame

    Button.MouseButton1Click:Connect(function()
        for _, f in pairs(TabFolder:GetChildren()) do
            f.Visible = false
        end
        Frame.Visible = true
    end)

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)
end

------------------------------------
-- 🟢 COMBAT TAB
------------------------------------
local CombatFrame = Frames["Combat"]

local AimbotEnabled, SilentAimEnabled, NoRecoilEnabled, HitboxExpandEnabled = false, false, false, false
local HitboxSize = Vector3.new(10, 10, 10)

-- Aimbot Toggle
local AimbotBtn = Instance.new("TextButton")
AimbotBtn.Size = UDim2.new(0, 200, 0, 30)
AimbotBtn.Position = UDim2.new(0, 20, 0, 20)
AimbotBtn.Text = "Aimbot [OFF]"
AimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotBtn.Font = Enum.Font.Gotham
AimbotBtn.TextSize = 14
AimbotBtn.Parent = CombatFrame

AimbotBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotBtn.Text = "Aimbot ["..(AimbotEnabled and "ON" or "OFF").."]"
end)

-- Silent Aim Toggle
local SilentBtn = AimbotBtn:Clone()
SilentBtn.Text = "Silent Aim [OFF]"
SilentBtn.Position = UDim2.new(0, 20, 0, 60)
SilentBtn.Parent = CombatFrame

SilentBtn.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    SilentBtn.Text = "Silent Aim ["..(SilentAimEnabled and "ON" or "OFF").."]"
end)

-- No Recoil Toggle
local RecoilBtn = AimbotBtn:Clone()
RecoilBtn.Text = "No Recoil [OFF]"
RecoilBtn.Position = UDim2.new(0, 20, 0, 100)
RecoilBtn.Parent = CombatFrame

RecoilBtn.MouseButton1Click:Connect(function()
    NoRecoilEnabled = not NoRecoilEnabled
    RecoilBtn.Text = "No Recoil ["..(NoRecoilEnabled and "ON" or "OFF").."]"
end)

-- Hitbox Expander Toggle
local HitboxBtn = AimbotBtn:Clone()
HitboxBtn.Text = "Hitbox Expander [OFF]"
HitboxBtn.Position = UDim2.new(0, 20, 0, 140)
HitboxBtn.Parent = CombatFrame

HitboxBtn.MouseButton1Click:Connect(function()
    HitboxExpandEnabled = not HitboxExpandEnabled
    HitboxBtn.Text = "Hitbox Expander ["..(HitboxExpandEnabled and "ON" or "OFF").."]"
end)

------------------------------------
-- 💣 EXPLOIT TAB
------------------------------------
local ExploitFrame = Frames["Exploit"]
local WalkSpeedEnabled, InfiniteJumpEnabled, GodModeEnabled, FlyEnabled = false, false, false, false

-- Walk Speed Toggle
local WSBtn = AimbotBtn:Clone()
WSBtn.Text = "Walk Speed [OFF]"
WSBtn.Position = UDim2.new(0, 20, 0, 20)
WSBtn.Parent = ExploitFrame

WSBtn.MouseButton1Click:Connect(function()
    WalkSpeedEnabled = not WalkSpeedEnabled
    WSBtn.Text = "Walk Speed ["..(WalkSpeedEnabled and "ON" or "OFF").."]"
    if WalkSpeedEnabled then
        LocalPlayer.Character.Humanoid.WalkSpeed = 30
    else
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Infinite Jump
local IJBtn = WSBtn:Clone()
IJBtn.Text = "Infinite Jump [OFF]"
IJBtn.Position = UDim2.new(0, 20, 0, 60)
IJBtn.Parent = ExploitFrame

IJBtn.MouseButton1Click:Connect(function()
    InfiniteJumpEnabled = not InfiniteJumpEnabled
    IJBtn.Text = "Infinite Jump ["..(InfiniteJumpEnabled and "ON" or "OFF").."]"
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- God Mode
local GMBtn = WSBtn:Clone()
GMBtn.Text = "God Mode [OFF]"
GMBtn.Position = UDim2.new(0, 20, 0, 100)
GMBtn.Parent = ExploitFrame

GMBtn.MouseButton1Click:Connect(function()
    GodModeEnabled = not GodModeEnabled
    GMBtn.Text = "God Mode ["..(GodModeEnabled and "ON" or "OFF").."]"
    -- Placeholder logic (real god mode needs hooking or custom methods)
end)

------------------------------------
-- 🎨 SKIN CHANGER TAB
------------------------------------
local SkinFrame = Frames["Skin Changer"]

local SkinLabel = Instance.new("TextLabel")
SkinLabel.Size = UDim2.new(0, 300, 0, 30)
SkinLabel.Position = UDim2.new(0, 20, 0, 20)
SkinLabel.Text = "Skin changer placeholder (to be added)"
SkinLabel.BackgroundTransparency = 1
SkinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SkinLabel.Font = Enum.Font.Gotham
SkinLabel.TextSize = 14
SkinLabel.Parent = SkinFrame

------------------------------------
-- ⚙️ MISC TAB
------------------------------------
local MiscFrame = Frames["Misc"]

local CrosshairBtn = AimbotBtn:Clone()
CrosshairBtn.Text = "Toggle Crosshair [OFF]"
CrosshairBtn.Position = UDim2.new(0, 20, 0, 20)
CrosshairBtn.Parent = MiscFrame

CrosshairBtn.MouseButton1Click:Connect(function()
    -- Placeholder crosshair logic
end)

local CloseKeybindLabel = Instance.new("TextLabel")
CloseKeybindLabel.Size = UDim2.new(0, 300, 0, 30)
CloseKeybindLabel.Position = UDim2.new(0, 20, 0, 60)
CloseKeybindLabel.Text = "Press Right Ctrl to toggle UI"
CloseKeybindLabel.BackgroundTransparency = 1
CloseKeybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseKeybindLabel.Font = Enum.Font.Gotham
CloseKeybindLabel.TextSize = 14
CloseKeybindLabel.Parent = MiscFrame

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

------------------------------------
-- ✅ END OF BIG MEGA SCRIPT
------------------------------------

print("SkyWare V2 Arsenal Mega Hub loaded!")
