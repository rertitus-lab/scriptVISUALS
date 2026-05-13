local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- // КОНФИГУРАЦИЯ
_G.Cfg = {
    ESP = true, ESPSpeed = 0.8, ESPSize = 4, ESPColor = Color3.fromRGB(255, 255, 255), BaseThickness = 8,
    Strafe = false, Radius = 10, Speed = 5,
    Hat = false, HatH = 0.8, HatW = 3, HatColor = Color3.fromRGB(255, 0, 0),
    Circles = false, JumpSize = 12, JumpColor = Color3.fromRGB(0, 255, 255)
}

-- // GUI КОРНЕВОЙ ЭЛЕМЕНТ
local GeminiGui = Instance.new("ScreenGui", game.CoreGui)
GeminiGui.Name = "Gemini_V21_IndicatorRGB"

-- // COLOR PICKER С ИНДИКАТОРАМИ
local CPFrame = Instance.new("Frame", GeminiGui)
CPFrame.Size = UDim2.new(0, 220, 0, 280)
CPFrame.Position = UDim2.new(0.4, 0, 0.3, 0)
CPFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CPFrame.BorderSizePixel = 2; CPFrame.Visible = false
CPFrame.Active = true; CPFrame.Draggable = true

local CloseBtn = Instance.new("TextButton", CPFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50); CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.MouseButton1Click:Connect(function() CPFrame.Visible = false end)

-- Главное поле (Saturation & Value)
local MainCanvas = Instance.new("TextButton", CPFrame)
MainCanvas.Size = UDim2.new(0, 200, 0, 180); MainCanvas.Position = UDim2.new(0, 10, 0, 40)
MainCanvas.Text = ""; MainCanvas.AutoButtonColor = false; MainCanvas.BackgroundColor3 = Color3.new(1, 0, 0); MainCanvas.ClipsDescendants = true

local SatGrad = Instance.new("Frame", MainCanvas)
SatGrad.Size = UDim2.new(1, 0, 1, 0); SatGrad.BackgroundTransparency = 0; SatGrad.BorderSizePixel = 0
local SG = Instance.new("UIGradient", SatGrad); SG.Transparency = NumberSequence.new(0, 1)

local ValGrad = Instance.new("Frame", MainCanvas)
ValGrad.Size = UDim2.new(1, 0, 1, 0); ValGrad.BackgroundTransparency = 0; ValGrad.BorderSizePixel = 0
local VG = Instance.new("UIGradient", ValGrad); VG.Rotation = 90; VG.Color = ColorSequence.new(Color3.new(0, 0, 0))
VG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})

-- КРУЖОК-ИНДИКАТОР (Picker Circle)
local PickerCircle = Instance.new("Frame", MainCanvas)
PickerCircle.Size = UDim2.new(0, 8, 0, 8)
PickerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
PickerCircle.BackgroundColor3 = Color3.new(1, 1, 1)
PickerCircle.ZIndex = 10
local UICorner = Instance.new("UICorner", PickerCircle); UICorner.CornerRadius = UDim.new(1, 0)
local UIStroke = Instance.new("UIStroke", PickerCircle); UIStroke.Thickness = 1.5; UIStroke.Color = Color3.new(0, 0, 0)

-- Слайдер Hue (Радуга)
local HueSlider = Instance.new("TextButton", CPFrame)
HueSlider.Size = UDim2.new(0, 200, 0, 20); HueSlider.Position = UDim2.new(0, 10, 0, 235); HueSlider.Text = ""; HueSlider.AutoButtonColor = false
local HG = Instance.new("UIGradient", HueSlider); HG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.17, Color3.new(1,1,0)),
    ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
    ColorSequenceKeypoint.new(0.67, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)),
    ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
})

-- ЛИНИЯ-ИНДИКАТОР HUE
local HueLine = Instance.new("Frame", HueSlider)
HueLine.Size = UDim2.new(0, 4, 1, 4); HueLine.Position = UDim2.new(0, 0, 0, -2); HueLine.BackgroundColor3 = Color3.new(1, 1, 1)
local LS = Instance.new("UIStroke", HueLine); LS.Thickness = 1; LS.Color = Color3.new(0, 0, 0)

local curKey, h, s, v = "", 0, 1, 1

local function UpdateColors()
    local color = Color3.fromHSV(h, s, v)
    if curKey ~= "" then _G.Cfg[curKey] = color end
    MainCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    
    -- Обновляем позиции кружка и линии
    PickerCircle.Position = UDim2.new(s, 0, 1 - v, 0)
    HueLine.Position = UDim2.new(h, 0, 0, -2)
end

-- Обработка кликов
HueSlider.MouseButton1Down:Connect(function()
    local move = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            h = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
            UpdateColors()
        end
    end)
    local release; release = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect(); release:Disconnect() end
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect(); release:Disconnect() end
    end)
end)

-- // МЕНЮ (SCROLLING)
local MainFrame = Instance.new("ScrollingFrame", GeminiGui)
MainFrame.Size = UDim2.new(0, 240, 0, 420); MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.BorderSizePixel = 0; MainFrame.CanvasSize = UDim2.new(0, 0, 3.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true
Instance.new("UIListLayout", MainFrame).Padding = UDim.new(0, 8)

local function AddToggle(text, key)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0, 210, 0, 35); b.Text = text .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function()
        _G.Cfg[key] = not _G.Cfg[key]
        b.Text = text .. ": " .. (_G.Cfg[key] and "ON" or "OFF")
        b.BackgroundColor3 = _G.Cfg[key] and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(40, 40, 40)
    end)
end

local function AddInput(text, key)
    local f = Instance.new("Frame", MainFrame); f.Size = UDim2.new(0, 210, 0, 30); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = "  "..text; l.TextColor3 = Color3.new(0.8,0.8,0.8); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.35, 0, 0.8, 0); i.Position = UDim2.new(0.6, 0, 0.1, 0)
    i.Text = tostring(_G.Cfg[key]); i.BackgroundColor3 = Color3.fromRGB(35,35,35); i.TextColor3 = Color3.new(1,1,1)
    i.FocusLost:Connect(function() local n = tonumber(i.Text); if n then _G.Cfg[key] = n end end)
end

local function AddColorPick(text, key)
    local b = Instance.new("TextButton", MainFrame); b.Size = UDim2.new(0, 210, 0, 30); b.Text = "Color: " .. text
    b.BackgroundColor3 = Color3.fromRGB(50, 55, 75); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() curKey = key; CPFrame.Visible = true end)
end

-- Сборка кастомизации
AddToggle("ESP", "ESP"); AddInput("ESP Size", "ESPSize"); AddInput("ESP Speed", "ESPSpeed"); AddInput("Thickness", "BaseThickness"); AddColorPick("ESP", "ESPColor")
AddToggle("Strafe", "Strafe"); AddInput("Radius", "Radius"); AddInput("Speed", "Speed")
AddToggle("Hat", "Hat"); AddInput("Hat H", "HatH"); AddInput("Hat W", "HatW"); AddColorPick("Hat", "HatColor")
AddToggle("Circles", "Circles"); AddInput("Circle Size", "JumpSize"); AddColorPick("Circles", "JumpColor")

-- // ОСНОВНАЯ ЛОГИКА (БЕЗ УПРОЩЕНИЙ)
local Billboard = Instance.new("BillboardGui", game.CoreGui); Billboard.AlwaysOnTop = true
local Square = Instance.new("Frame", Billboard); Square.Size = UDim2.new(1,0,1,0); Square.BackgroundTransparency = 1; Square.AnchorPoint = Vector2.new(0.5,0.5); Square.Position = UDim2.new(0.5,0,0.5,0)
local Stroke = Instance.new("UIStroke", Square)

local HatPart = Instance.new("Part"); HatPart.CanCollide = false; local Mesh = Instance.new("SpecialMesh", HatPart); Mesh.MeshType = "FileMesh"; Mesh.MeshId = "rbxassetid://1033714"

local function GetClosest()
    local t, d = nil, 2000
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
    if _G.Cfg.ESP and target and target.Character then
        local root = target.Character.HumanoidRootPart
        Billboard.Adornee = root; Square.Rotation = Square.Rotation + _G.Cfg.ESPSpeed
        Stroke.Color = _G.Cfg.ESPColor; Stroke.Thickness = math.clamp(_G.Cfg.BaseThickness * (25/(workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude), 1, 50)
        Billboard.Enabled = true
    else Billboard.Enabled = false end
    
    if _G.Cfg.Hat and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
        HatPart.Parent = LocalPlayer.Character; HatPart.Color = _G.Cfg.HatColor; Mesh.Scale = Vector3.new(_G.Cfg.HatW, 1, _G.Cfg.HatW)
        HatPart.CFrame = LocalPlayer.Character.Head.CFrame * CFrame.new(0, _G.Cfg.HatH, 0)
    else HatPart.Parent = nil end

    if _G.Cfg.Strafe and target and target.Character then
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local mRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if tRoot and mRoot then
            local angle = tick() * _G.Cfg.Speed
            mRoot.CFrame = CFrame.new(tRoot.Position + Vector3.new(math.cos(angle)*_G.Cfg.Radius, 0, math.sin(angle)*_G.Cfg.Radius), tRoot.Position)
        end
    end
end)

local isJumping = false
RunService.Heartbeat:Connect(function()
    if not _G.Cfg.Circles or not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.FloorMaterial == Enum.Material.Air and not isJumping then
        isJumping = true
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local p = Instance.new("Part", workspace); p.Anchored, p.CanCollide = true, false; p.Shape = "Cylinder"; p.Material = "Neon"; p.Color = _G.Cfg.JumpColor
            p.Size = Vector3.new(0.1, 1, 1); p.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
            TweenService:Create(p, TweenInfo.new(0.6), {Size = Vector3.new(0.1, _G.Cfg.JumpSize, _G.Cfg.JumpSize), Transparency = 1}):Play()
            task.delay(0.6, function() p:Destroy() end)
        end
    elseif hum and hum.FloorMaterial ~= Enum.Material.Air then isJumping = false end
end)