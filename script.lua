local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Connections = {}

-- // КОНФИГУРАЦИЯ
_G.Cfg = {
    AimbotEnabled = false,
    TargetESPSquareEnabled = false,
    TargetStrafeOrbitEnabled = false,
    ChinaHatAccessoryEnabled = false,
    JumpVisualCirclesEnabled = false,
    AimbotMaxDistance = 1000,
    AimbotSmoothness = 0.15,
    TargetESPRotationSpeed = 2,
    TargetESPSquareSize = 80,
    TargetESPBorderThickness = 2,
    TargetESPSquareColor = Color3.new(1, 1, 1),
    TargetStrafeOrbitRadius = 10,
    TargetStrafeOrbitSpeed = 5,
    ChinaHatHeightOffset = 0.8,
    ChinaHatWidthScale = 3,
    ChinaHatAccessoryColor = Color3.fromRGB(255, 0, 0),
    JumpCircleMaximumSize = 12,
    JumpCircleEffectColor = Color3.fromRGB(0, 255, 255),
    AspectRatioValue = 70
}

-- // GUI SETUP
local GeminiGui = Instance.new("ScreenGui", game.CoreGui)
GeminiGui.Name = "Gemini_V51_WhiteFix"
GeminiGui.IgnoreGuiInset = true

-- // ESP FRAME
local ESPMain = Instance.new("Frame", GeminiGui)
ESPMain.Size = UDim2.new(0, 80, 0, 80); ESPMain.BackgroundTransparency = 1; ESPMain.AnchorPoint = Vector2.new(0.5, 0.5); ESPMain.Visible = false
local ESPStroke = Instance.new("UIStroke", ESPMain); ESPStroke.ApplyStrokeMode = "Border"

-- // COLOR PICKER (WHITE FIX)
local CPFrame = Instance.new("Frame", GeminiGui)
CPFrame.Size = UDim2.new(0, 220, 0, 240); CPFrame.Position = UDim2.new(0.5, -110, 0.5, -120); CPFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); CPFrame.Visible = false; CPFrame.Active = true; CPFrame.Draggable = true; CPFrame.ZIndex = 20
Instance.new("UIStroke", CPFrame).Color = Color3.fromRGB(50, 50, 50)

-- Основное поле (Sat/Val)
local SatValBox = Instance.new("Frame", CPFrame)
SatValBox.Size = UDim2.new(0, 200, 0, 150); SatValBox.Position = UDim2.new(0, 10, 0, 10); SatValBox.BackgroundColor3 = Color3.new(1, 0, 0); SatValBox.BorderSizePixel = 0; SatValBox.ZIndex = 21

-- Градиент Белого (Saturation)
local SatGrad = Instance.new("Frame", SatValBox); SatGrad.Size = UDim2.new(1,0,1,0); SatGrad.BackgroundTransparency = 0; SatGrad.BorderSizePixel = 0; SatGrad.ZIndex = 22
local SGrad = Instance.new("UIGradient", SatGrad); SGrad.Color = ColorSequence.new(Color3.new(1,1,1)); SGrad.Transparency = NumberSequence.new(0, 1)

-- Градиент Черного (Value)
local ValGradFrame = Instance.new("Frame", SatValBox); ValGradFrame.Size = UDim2.new(1,0,1,0); ValGradFrame.BackgroundTransparency = 0; ValGradFrame.BorderSizePixel = 0; ValGradFrame.ZIndex = 23
local VGrad = Instance.new("UIGradient", ValGradFrame); VGrad.Rotation = 90; VGrad.Color = ColorSequence.new(Color3.new(0,0,0)); VGrad.Transparency = NumberSequence.new(1, 0)

local SVIndicator = Instance.new("Frame", SatValBox); SVIndicator.Size = UDim2.new(0, 4, 0, 4); SVIndicator.BackgroundColor3 = Color3.new(1,1,1); SVIndicator.ZIndex = 25; SVIndicator.BorderSizePixel = 1

local SVTrigger = Instance.new("TextButton", SatValBox); SVTrigger.Size = UDim2.new(1, 0, 1, 0); SVTrigger.BackgroundTransparency = 1; SVTrigger.Text = ""; SVTrigger.ZIndex = 26

-- Полоска Hue
local HueBox = Instance.new("Frame", CPFrame); HueBox.Size = UDim2.new(0, 200, 0, 15); HueBox.Position = UDim2.new(0, 10, 0, 170); HueBox.ZIndex = 21
local HGrad = Instance.new("UIGradient", HueBox); HGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(0,1,1)), ColorSequenceKeypoint.new(0.16, Color3.fromHSV(0.16,1,1)), ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33,1,1)), ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)), ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66,1,1)), ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83,1,1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1,1,1))})
local HueTrigger = Instance.new("TextButton", HueBox); HueTrigger.Size = UDim2.new(1, 0, 1, 0); HueTrigger.BackgroundTransparency = 1; HueTrigger.Text = ""; HueTrigger.ZIndex = 26

local curKey, h, s, v = "", 0, 1, 1
local function UpdateRGB()
    local color = Color3.fromHSV(h, s, v)
    if _G.Cfg[curKey] then _G.Cfg[curKey] = color end
    SatValBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
end

HueTrigger.MouseButton1Down:Connect(function()
    local move; move = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            h = math.clamp((input.Position.X - HueBox.AbsolutePosition.X) / HueBox.AbsoluteSize.X, 0, 1); UpdateRGB()
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
end)

SVTrigger.MouseButton1Down:Connect(function()
    local move; move = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            s = math.clamp((input.Position.X - SatValBox.AbsolutePosition.X) / SatValBox.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((input.Position.Y - SatValBox.AbsolutePosition.Y) / SatValBox.AbsoluteSize.Y, 0, 1)
            SVIndicator.Position = UDim2.new(s, -2, 1-v, -2); UpdateRGB()
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
end)

local ApplyBtn = Instance.new("TextButton", CPFrame); ApplyBtn.Size = UDim2.new(0, 200, 0, 30); ApplyBtn.Position = UDim2.new(0, 10, 0, 200); ApplyBtn.Text = "APPLY"; ApplyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ApplyBtn.TextColor3 = Color3.new(1,1,1); ApplyBtn.ZIndex = 25
ApplyBtn.MouseButton1Click:Connect(function() CPFrame.Visible = false end)

-- // MAIN WINDOW
local MainFrame = Instance.new("Frame", GeminiGui)
MainFrame.Size = UDim2.new(0, 250, 0, 30); MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0); MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); MainFrame.BorderSizePixel = 0; MainFrame.Active = true; MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame); Title.Size = UDim2.new(1, -40, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0); Title.Text = "GEMINI V51"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"; Title.Font = "SourceSansBold"
local CollapseBtn = Instance.new("TextButton", MainFrame); CollapseBtn.Size = UDim2.new(0, 30, 0, 30); CollapseBtn.Position = UDim2.new(1, -30, 0, 0); CollapseBtn.Text = "_"; CollapseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); CollapseBtn.TextColor3 = Color3.new(1,1,1)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, 0, 0, 320); Content.Position = UDim2.new(0, 0, 0, 30); Content.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Content.ScrollBarThickness = 2; Content.AutomaticCanvasSize = "Y"
local UIList = Instance.new("UIListLayout", Content); UIList.Padding = UDim.new(0, 4); UIList.HorizontalAlignment = "Center"

CollapseBtn.MouseButton1Click:Connect(function() Content.Visible = not Content.Visible; CollapseBtn.Text = Content.Visible and "_" or "+" end)

-- // HELPER FUNCTIONS
local function CreateModule(name, key)
    local Mod = Instance.new("Frame", Content); Mod.Size = UDim2.new(0, 230, 0, 35); Mod.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Mod.AutomaticSize = "Y"
    local Btn = Instance.new("TextButton", Mod); Btn.Size = UDim2.new(1, 0, 0, 35); Btn.Text = "  " .. name; Btn.TextXAlignment = "Left"; Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Btn.TextColor3 = Color3.new(1,1,1)
    local Ind = Instance.new("Frame", Btn); Ind.Size = UDim2.new(0, 4, 1, 0); Ind.Position = UDim2.new(1, -4, 0, 0); Ind.BackgroundColor3 = Color3.new(1,0,0)
    local Arr = Instance.new("TextButton", Btn); Arr.Size = UDim2.new(0, 25, 1, 0); Arr.Position = UDim2.new(1, -35, 0, 0); Arr.Text = ">"; Arr.BackgroundColor3 = Color3.fromRGB(45,45,45); Arr.TextColor3 = Color3.new(1,1,1)
    local Inner = Instance.new("Frame", Mod); Inner.Size = UDim2.new(1, 0, 0, 0); Inner.Position = UDim2.new(0, 0, 0, 35); Inner.Visible = false; Inner.AutomaticSize = "Y"; Inner.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Instance.new("UIListLayout", Inner)
    Btn.MouseButton1Click:Connect(function() _G.Cfg[key] = not _G.Cfg[key]; Ind.BackgroundColor3 = _G.Cfg[key] and Color3.new(0,1,0) or Color3.new(1,0,0) end)
    Arr.MouseButton1Click:Connect(function() Inner.Visible = not Inner.Visible; Arr.Text = Inner.Visible and "v" or ">" end)
    return Inner
end

local function AddSlider(parent, text, key)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 25); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = "  " .. text; l.TextColor3 = Color3.new(0.7,0.7,0.7); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0, 45, 0.8, 0); i.Position = UDim2.new(1, -50, 0.1, 0); i.Text = tostring(_G.Cfg[key]); i.BackgroundColor3 = Color3.fromRGB(45,45,45); i.TextColor3 = Color3.new(1,1,1)
    i.FocusLost:Connect(function() local v = tonumber(i.Text); if v then _G.Cfg[key] = v end end)
end

local function AddColorBtn(parent, text, key)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, 0, 0, 25); b.Text = "  [COLOR] " .. text; b.BackgroundColor3 = Color3.fromRGB(40, 40, 50); b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = "Left"
    b.MouseButton1Click:Connect(function() curKey = key; CPFrame.Visible = true end)
end

-- СБОРКА
local mAim = CreateModule("AIMBOT", "AimbotEnabled"); AddSlider(mAim, "Smooth", "AimbotSmoothness"); AddSlider(mAim, "FOV", "AspectRatioValue")
local mEsp = CreateModule("TARGET ESP", "TargetESPSquareEnabled"); AddSlider(mEsp, "Size", "TargetESPSquareSize"); AddSlider(mEsp, "Thickness", "TargetESPBorderThickness"); AddColorBtn(mEsp, "ESP Color", "TargetESPSquareColor")
local mOrb = CreateModule("STRAFE ORBIT", "TargetStrafeOrbitEnabled"); AddSlider(mOrb, "Radius", "TargetStrafeOrbitRadius"); AddSlider(mOrb, "Speed", "TargetStrafeOrbitSpeed")
local mHat = CreateModule("CHINA HAT", "ChinaHatAccessoryEnabled"); AddSlider(mHat, "Height", "ChinaHatHeightOffset"); AddSlider(mHat, "Scale", "ChinaHatWidthScale"); AddColorBtn(mHat, "Hat Color", "ChinaHatAccessoryColor")
local mJmp = CreateModule("JUMP CIRCLES", "JumpVisualCirclesEnabled"); AddSlider(mJmp, "Size", "JumpCircleMaximumSize"); AddColorBtn(mJmp, "Jump Color", "JumpCircleEffectColor")

local KillBtn = Instance.new("TextButton", Content); KillBtn.Size = UDim2.new(0, 230, 0, 35); KillBtn.Text = "KILL SCRIPT"; KillBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20); KillBtn.TextColor3 = Color3.new(1,1,1)

-- // ENGINE FUNCTIONS
local HatPart = Instance.new("Part", workspace); HatPart.CanCollide, HatPart.Anchored, HatPart.Transparency = false, false, 1
local HatMesh = Instance.new("SpecialMesh", HatPart); HatMesh.MeshType = "FileMesh"; HatMesh.MeshId = "rbxassetid://1033714"

local function GetTarget()
    local t, d = nil, _G.Cfg.AimbotMaxDistance
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if dist < d then d = dist; t = v end
        end
    end
    return t
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
    local target = GetTarget()
    local char = LocalPlayer.Character
    Camera.FieldOfView = _G.Cfg.AspectRatioValue

    if _G.Cfg.TargetESPSquareEnabled and target and target.Character:FindFirstChild("HumanoidRootPart") then
        local pos, onScreen = Camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
        if onScreen then
            ESPMain.Visible = true; ESPMain.Position = UDim2.new(0, pos.X, 0, pos.Y)
            ESPMain.Size = UDim2.new(0, _G.Cfg.TargetESPSquareSize, 0, _G.Cfg.TargetESPSquareSize)
            ESPStroke.Thickness = _G.Cfg.TargetESPBorderThickness; ESPStroke.Color = _G.Cfg.TargetESPSquareColor
            ESPMain.Rotation = (tick() * 100 * _G.Cfg.TargetESPRotationSpeed) % 360
        else ESPMain.Visible = false end
    else ESPMain.Visible = false end

    if _G.Cfg.TargetStrafeOrbitEnabled and target and target.Character:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
        for _, v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide = false end end
        local t = tick() * _G.Cfg.TargetStrafeOrbitSpeed
        char.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(math.cos(t)*_G.Cfg.TargetStrafeOrbitRadius, 0, math.sin(t)*_G.Cfg.TargetStrafeOrbitRadius), target.Character.HumanoidRootPart.Position)
    end

    if _G.Cfg.ChinaHatAccessoryEnabled and char and char:FindFirstChild("Head") then
        HatPart.Parent = char; HatPart.Transparency = 0.3; HatPart.Color = _G.Cfg.ChinaHatAccessoryColor; HatMesh.Scale = Vector3.new(_G.Cfg.ChinaHatWidthScale, 1, _G.Cfg.ChinaHatWidthScale)
        HatPart.CFrame = char.Head.CFrame * CFrame.new(0, _G.Cfg.ChinaHatHeightOffset, 0)
    else HatPart.Transparency = 1 end

    if _G.Cfg.AimbotEnabled and target and target.Character:FindFirstChild("Head") then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), _G.Cfg.AimbotSmoothness)
    end
end))

local jumping = false
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not _G.Cfg.JumpVisualCirclesEnabled then return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.FloorMaterial == Enum.Material.Air and not jumping then
        jumping = true
        local p = Instance.new("Part", workspace); p.Anchored, p.CanCollide = true, false; p.Shape = "Cylinder"; p.Material = "Neon"; p.Color = _G.Cfg.JumpCircleEffectColor; p.Size = Vector3.new(0.1, 1, 1)
        p.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, -2.8, 0) * CFrame.Angles(0, 0, math.rad(90))
        TweenService:Create(p, TweenInfo.new(0.5), {Size = Vector3.new(0.1, _G.Cfg.JumpCircleMaximumSize, _G.Cfg.JumpCircleMaximumSize), Transparency = 1}):Play()
        task.delay(0.5, function() p:Destroy() end)
    elseif hum and hum.FloorMaterial ~= Enum.Material.Air then jumping = false end
end))

KillBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(Connections) do c:Disconnect() end
    GeminiGui:Destroy(); HatPart:Destroy(); _G.Cfg = nil
end)
