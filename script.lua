local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // ТАБЛИЦА КОНФИГУРАЦИИ (ВСЕ ПАРАМЕТРЫ)
_G.Cfg = {
    -- Aimbot
    AimbotEnabled = false,
    AimbotMaxDistance = 100,
    AimbotSmoothness = 0.2,
    
    -- Target ESP Square
    TargetESPSquareEnabled = true,
    TargetESPRotationSpeed = 0.8,
    TargetESPSquareSize = 4,
    TargetESPSquareColor = Color3.fromRGB(255, 255, 255),
    TargetESPBorderThickness = 8,
    
    -- Orbit Strafe
    TargetStrafeOrbitEnabled = false,
    TargetStrafeOrbitRadius = 10,
    TargetStrafeOrbitSpeed = 5,
    
    -- China Hat
    ChinaHatAccessoryEnabled = false,
    ChinaHatHeightOffset = 0.8,
    ChinaHatWidthScale = 3,
    ChinaHatAccessoryColor = Color3.fromRGB(255, 0, 0),
    
    -- Jump Effects
    JumpVisualCirclesEnabled = false,
    JumpCircleMaximumSize = 12,
    JumpCircleEffectColor = Color3.fromRGB(0, 255, 255)
}

-- // СОЗДАНИЕ ИНТЕРФЕЙСА
local GeminiGui = Instance.new("ScreenGui")
GeminiGui.Name = "Gemini_V25_Full"
GeminiGui.Parent = game.CoreGui

-- // COLOR PICKER (ПОЛНЫЙ БЛОК)
local CPFrame = Instance.new("Frame")
CPFrame.Name = "ColorPicker"
CPFrame.Parent = GeminiGui
CPFrame.Size = UDim2.new(0, 230, 0, 300)
CPFrame.Position = UDim2.new(0.4, 0, 0.3, 0)
CPFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CPFrame.BorderSizePixel = 2
CPFrame.Visible = false
CPFrame.Active = true
CPFrame.Draggable = true

local CloseBtn = Instance.new("TextButton", CPFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.MouseButton1Click:Connect(function() CPFrame.Visible = false end)

local MainCanvas = Instance.new("TextButton", CPFrame)
MainCanvas.Size = UDim2.new(0, 210, 0, 180)
MainCanvas.Position = UDim2.new(0, 10, 0, 40)
MainCanvas.Text = ""
MainCanvas.AutoButtonColor = false
MainCanvas.BackgroundColor3 = Color3.new(1, 0, 0)
MainCanvas.ClipsDescendants = true

local SatGrad = Instance.new("Frame", MainCanvas)
SatGrad.Size = UDim2.new(1, 0, 1, 0)
SatGrad.BorderSizePixel = 0
local SG = Instance.new("UIGradient", SatGrad)
SG.Transparency = NumberSequence.new(0, 1)

local ValGrad = Instance.new("Frame", MainCanvas)
ValGrad.Size = UDim2.new(1, 0, 1, 0)
ValGrad.BorderSizePixel = 0
local VG = Instance.new("UIGradient", ValGrad)
VG.Rotation = 90
VG.Color = ColorSequence.new(Color3.new(0, 0, 0))
VG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})

local PickerCircle = Instance.new("Frame", MainCanvas)
PickerCircle.Size = UDim2.new(0, 8, 0, 8)
PickerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
PickerCircle.BackgroundColor3 = Color3.new(1, 1, 1)
PickerCircle.ZIndex = 10
Instance.new("UICorner", PickerCircle).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", PickerCircle).Thickness = 1.5

local HueSlider = Instance.new("TextButton", CPFrame)
HueSlider.Size = UDim2.new(0, 210, 0, 20)
HueSlider.Position = UDim2.new(0, 10, 0, 240)
HueSlider.Text = ""
HueSlider.AutoButtonColor = false
local HG = Instance.new("UIGradient", HueSlider)
HG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), 
    ColorSequenceKeypoint.new(0.17, Color3.new(1,1,0)), 
    ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)), 
    ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)), 
    ColorSequenceKeypoint.new(0.67, Color3.new(0,0,1)), 
    ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)), 
    ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
})
local HueLine = Instance.new("Frame", HueSlider)
HueLine.Size = UDim2.new(0, 4, 1, 4)
HueLine.Position = UDim2.new(0, 0, 0, -2)
HueLine.BackgroundColor3 = Color3.new(1, 1, 1)
Instance.new("UIStroke", HueLine)

local curKey, h, s, v = "", 0, 1, 1
local function UpdateColors()
    local color = Color3.fromHSV(h, s, v)
    if curKey ~= "" then _G.Cfg[curKey] = color end
    MainCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    PickerCircle.Position = UDim2.new(s, 0, 1 - v, 0)
    HueLine.Position = UDim2.new(h, 0, 0, -2)
end

HueSlider.MouseButton1Down:Connect(function()
    local move = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            h = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
            UpdateColors()
        end
    end)
    local release; release = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.MouseButton1 then move:Disconnect(); release:Disconnect() end
    end)
end)

MainCanvas.MouseButton1Down:Connect(function()
    local move = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            s = math.clamp((input.Position.X - MainCanvas.AbsolutePosition.X) / MainCanvas.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((input.Position.Y - MainCanvas.AbsolutePosition.Y) / MainCanvas.AbsoluteSize.Y, 0, 1)
            UpdateColors()
        end
    end)
    local release; release = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.MouseButton1 then move:Disconnect(); release:Disconnect() end
    end)
end)

-- // ГЛАВНОЕ МЕНЮ
local MainFrame = Instance.new("ScrollingFrame", GeminiGui)
MainFrame.Size = UDim2.new(0, 280, 0, 450)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.CanvasSize = UDim2.new(0, 0, 6, 0)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UIListLayout", MainFrame).Padding = UDim.new(0, 10)

local function AddToggle(text, key)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0, 250, 0, 40)
    b.Text = text .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = "SourceSansSemibold"
    b.TextScaled = true
    b.MouseButton1Click:Connect(function()
        _G.Cfg[key] = not _G.Cfg[key]
        b.Text = text .. ": " .. (_G.Cfg[key] and "ON" or "OFF")
        b.BackgroundColor3 = _G.Cfg[key] and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
    end)
end

local function AddInput(text, key)
    local f = Instance.new("Frame", MainFrame)
    f.Size = UDim2.new(0, 250, 0, 35)
    f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.Text = " " .. text
    l.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    l.BackgroundTransparency = 1
    l.TextXAlignment = "Left"
    l.TextScaled = true
    local i = Instance.new("TextBox", f)
    i.Size = UDim2.new(0.25, 0, 0.8, 0)
    i.Position = UDim2.new(0.72, 0, 0.1, 0)
    i.Text = tostring(_G.Cfg[key])
    i.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    i.TextColor3 = Color3.new(1, 1, 1)
    i.FocusLost:Connect(function()
        local n = tonumber(i.Text)
        if n then _G.Cfg[key] = n end
    end)
end

local function AddColorPick(text, key)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0, 250, 0, 35)
    b.Text = "Pick " .. text .. " Color"
    b.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextScaled = true
    b.MouseButton1Click:Connect(function()
        curKey = key
        CPFrame.Visible = true
    end)
end

-- // НАПОЛНЕНИЕ МЕНЮ
AddToggle("Aimbot Master Switch", "AimbotEnabled")
AddInput("Aimbot Max Distance", "AimbotMaxDistance")
AddInput("Aimbot Smoothness", "AimbotSmoothness")
AddToggle("Target ESP Square", "TargetESPSquareEnabled")
AddInput("ESP Rotation Speed", "TargetESPRotationSpeed")
AddInput("ESP Square Size", "TargetESPSquareSize")
AddInput("ESP Thickness", "TargetESPBorderThickness")
AddColorPick("ESP Square", "TargetESPSquareColor")
AddToggle("Orbit Strafe", "TargetStrafeOrbitEnabled")
AddInput("Orbit Radius", "TargetStrafeOrbitRadius")
AddInput("Orbit Speed", "TargetStrafeOrbitSpeed")
AddToggle("China Hat Enabled", "ChinaHatAccessoryEnabled")
AddInput("Hat Height Offset", "ChinaHatHeightOffset")
AddColorPick("China Hat", "ChinaHatAccessoryColor")
AddToggle("Jump Circles", "JumpVisualCirclesEnabled")
AddInput("Jump Circle Size", "JumpCircleMaximumSize")
AddColorPick("Jump Circle", "JumpCircleEffectColor")

-- // ЛОГИКА МИРА (ESP, AIM, HAT)
local Billboard = Instance.new("BillboardGui", game.CoreGui)
Billboard.AlwaysOnTop = true
local TargetESPSquare = Instance.new("Frame", Billboard)
TargetESPSquare.Size = UDim2.new(1, 0, 1, 0)
TargetESPSquare.AnchorPoint = Vector2.new(0.5, 0.5)
TargetESPSquare.Position = UDim2.new(0.5, 0, 0.5, 0)
TargetESPSquare.BackgroundTransparency = 1
local SquareCorner = Instance.new("UICorner", TargetESPSquare)
SquareCorner.CornerRadius = UDim.new(0, 0) 
local SquareStroke = Instance.new("UIStroke", TargetESPSquare)
SquareStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
SquareStroke.LineJoinMode = Enum.LineJoinMode.Miter

local HatPart = Instance.new("Part")
HatPart.CanCollide = false
local Mesh = Instance.new("SpecialMesh", HatPart)
Mesh.MeshType = "FileMesh"
Mesh.MeshId = "rbxassetid://1033714"

local function GetClosest()
    local t, d = nil, _G.Cfg.AimbotMaxDistance
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if dist < d then d = dist; t = v end
        end
    end
    return t
end

RunService.RenderStepped:Connect(function()
    local target = GetClosest()
    
    -- AIMBOT
    if _G.Cfg.AimbotEnabled and target and target.Character and target.Character:FindFirstChild("Head") then
        local lookCFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        Camera.CFrame = Camera.CFrame:Lerp(lookCFrame, _G.Cfg.AimbotSmoothness)
    end

    -- ESP SQUARE
    if _G.Cfg.TargetESPSquareEnabled and target and target.Character then
        Billboard.Adornee = target.Character.HumanoidRootPart
        Billboard.Size = UDim2.new(_G.Cfg.TargetESPSquareSize, 0, _G.Cfg.TargetESPSquareSize, 0)
        TargetESPSquare.Rotation = TargetESPSquare.Rotation + _G.Cfg.TargetESPRotationSpeed
        SquareStroke.Color = _G.Cfg.TargetESPSquareColor
        local camDist = (Camera.CFrame.Position - target.Character.HumanoidRootPart.Position).Magnitude
        SquareStroke.Thickness = math.clamp(_G.Cfg.TargetESPBorderThickness * (25/camDist), 1, 60)
        Billboard.Enabled = true
    else Billboard.Enabled = false end
    
    -- CHINA HAT
    if _G.Cfg.ChinaHatAccessoryEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        HatPart.Parent = LocalPlayer.Character
        HatPart.Color = _G.Cfg.ChinaHatAccessoryColor
        Mesh.Scale = Vector3.new(_G.Cfg.ChinaHatWidthScale, 1, _G.Cfg.ChinaHatWidthScale)
        HatPart.CFrame = LocalPlayer.Character.Head.CFrame * CFrame.new(0, _G.Cfg.ChinaHatHeightOffset, 0)
    else HatPart.Parent = nil end

    -- ORBIT
    if _G.Cfg.TargetStrafeOrbitEnabled and target and target.Character then
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local mRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if tRoot and mRoot then
            local angle = tick() * _G.Cfg.TargetStrafeOrbitSpeed
            mRoot.CFrame = CFrame.new(tRoot.Position + Vector3.new(math.cos(angle)*_G.Cfg.TargetStrafeOrbitRadius, 0, math.sin(angle)*_G.Cfg.TargetStrafeOrbitRadius), tRoot.Position)
        end
    end
end)

-- JUMP CIRCLES
local isJumping = false
RunService.Heartbeat:Connect(function()
    if not _G.Cfg.JumpVisualCirclesEnabled or not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.FloorMaterial == Enum.Material.Air and not isJumping then
        isJumping = true
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local p = Instance.new("Part", workspace)
            p.Anchored, p.CanCollide = true, false
            p.Shape = "Cylinder"; p.Material = "Neon"; p.Color = _G.Cfg.JumpCircleEffectColor
            p.Size = Vector3.new(0.1, 1, 1)
            p.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
            TweenService:Create(p, TweenInfo.new(0.6), {Size = Vector3.new(0.1, _G.Cfg.JumpCircleMaximumSize, _G.Cfg.JumpCircleMaximumSize), Transparency = 1}):Play()
            task.delay(0.6, function() p:Destroy() end)
        end
    elseif hum and hum.FloorMaterial ~= Enum.Material.Air then isJumping = false end
end)
