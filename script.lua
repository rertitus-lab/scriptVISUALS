local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Connections = {}
local ChamsFolder = Instance.new("Folder", game.CoreGui)
ChamsFolder.Name = "Gemini_Chams_Storage"

-- // КОНФИГУРАЦИЯ
_G.Cfg = {
    AimbotEnabled = false,
    AimbotMaxDistance = 1000,
    AimbotSmoothness = 1,
    AimbotEnabledBind = "None",
    
    TargetHudEnabled = false,
    TargetHudEnabledBind = "None",
    
    KillAuraEnabled = false,
    KillAuraRange = 25,
    KillAuraJump = true,
    KillAuraStrafe = true,
    KillAuraEnabledBind = "None",
    
    TargetESPSquareEnabled = false,
    TargetESPSquareSize = 80,
    TargetESPBorderThickness = 2,
    TargetESPSquareColor = Color3.new(1, 1, 1),
    TargetESPRotationSpeed = 2,
    TargetESPSquareEnabledBind = "None",
    
    TargetStrafeOrbitEnabled = false,
    TargetStrafeOrbitRadius = 10,
    TargetStrafeOrbitSpeed = 5,
    TargetStrafeOrbitEnabledBind = "None",
    
    -- РАСШИРЕННЫЙ CHINA HAT
    ChinaHatAccessoryEnabled = false,
    ChinaHatAccessoryColor = Color3.fromRGB(255, 0, 0),
    ChinaHatHeightOffset = 0.8, -- Высота над головой
    ChinaHatWidthScale = 3,     -- Ширина конуса
    ChinaHatHeightScale = 2,    -- Высота самого конуса
    ChinaHatTransparency = 0,   -- Прозрачность
    ChinaHatAccessoryEnabledBind = "None",
    
    JumpVisualCirclesEnabled = false,
    JumpCircleMaximumSize = 12,
    JumpCircleEffectColor = Color3.fromRGB(0, 255, 255),
    JumpVisualCirclesEnabledBind = "None",
    
    ChamsEnabled = false,
    ChamsColor = Color3.new(1, 0, 0),
    ChamsOutlineColor = Color3.new(1, 1, 1),
    ChamsFillTransparency = 0.5,
    ChamsOutlineTransparency = 0,
    ChamsEnabledBind = "None",
    
    DamageParticlesEnabled = true,
    ParticleColor = Color3.fromRGB(255, 255, 255),
    ParticleSize = 4,
    DamageParticlesEnabledBind = "None",
    
    AspectRatioValue = 70
}

-- // GUI SETUP
local GeminiGui = Instance.new("ScreenGui", game.CoreGui)
GeminiGui.Name = "Gemini_V58_TargetHUD"
GeminiGui.IgnoreGuiInset = true

-- // NOTIFICATION SYSTEM
local function ShowNotify(text, isEnabled)
    local sound = Instance.new("Sound", game:GetService("SoundService"))
    sound.SoundId = isEnabled and "rbxassetid://1053296915" or "rbxassetid://1053296721"
    sound.Volume = 0.5
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 1)

    local statusIcon = isEnabled and " ✅" or " ❌"
    local nF = Instance.new("TextLabel", GeminiGui)
    nF.Size = UDim2.new(0, 280, 0, 40)
    nF.Position = UDim2.new(0.5, -140, 0.4, 0)
    nF.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    nF.TextColor3 = Color3.fromRGB(180, 180, 180) 
    nF.Text = text .. statusIcon
    nF.Font = Enum.Font.SourceSans 
    nF.TextSize = 18
    nF.BackgroundTransparency = 1
    nF.TextTransparency = 1
    
    local s = Instance.new("UIStroke", nF)
    s.Thickness = 2
    s.Color = isEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    s.Transparency = 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
    Instance.new("UICorner", nF).CornerRadius = UDim.new(0, 5)

    local tI = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(nF, tI, {Position = UDim2.new(0.5, -140, 0.45, 0), BackgroundTransparency = 0, TextTransparency = 0}):Play()
    TweenService:Create(s, tI, {Transparency = 0}):Play()
    
    task.delay(1, function()
        local tO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        TweenService:Create(nF, tO, {Position = UDim2.new(0.5, -140, 0.5, 0), BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(s, tO, {Transparency = 1}):Play()
        task.wait(0.3)
        nF:Destroy()
    end)
end

-- // TARGET HUD SYSTEM
local TargetHUD = Instance.new("Frame", GeminiGui)
TargetHUD.Size = UDim2.new(0, 200, 0, 70)
TargetHUD.Position = UDim2.new(0.5, 50, 0.5, 50)
TargetHUD.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TargetHUD.BorderSizePixel = 0
TargetHUD.Visible = false
TargetHUD.Active = true
TargetHUD.Draggable = true 

local THudStroke = Instance.new("UIStroke", TargetHUD)
THudStroke.Color = Color3.fromRGB(60, 60, 60)
THudStroke.Thickness = 2

local TargetIcon = Instance.new("ImageLabel", TargetHUD)
TargetIcon.Size = UDim2.new(0, 50, 0, 50)
TargetIcon.Position = UDim2.new(0, 10, 0, 10)
TargetIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local TargetName = Instance.new("TextLabel", TargetHUD)
TargetName.Size = UDim2.new(1, -75, 0, 20)
TargetName.Position = UDim2.new(0, 65, 0, 10)
TargetName.BackgroundTransparency = 1
TargetName.TextColor3 = Color3.new(1, 1, 1)
TargetName.Text = "No Target"
TargetName.TextXAlignment = "Left"
TargetName.Font = "SourceSansBold"
TargetName.TextSize = 16

local HealthBack = Instance.new("Frame", TargetHUD)
HealthBack.Size = UDim2.new(1, -75, 0, 15)
HealthBack.Position = UDim2.new(0, 65, 0, 35)
HealthBack.BackgroundColor3 = Color3.fromRGB(40, 10, 10)

local HealthBar = Instance.new("Frame", HealthBack)
HealthBar.Size = UDim2.new(1, 0, 1, 0)
HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
HealthBar.BorderSizePixel = 0

local HealthText = Instance.new("TextLabel", HealthBack)
HealthText.Size = UDim2.new(1, 0, 1, 0)
HealthText.BackgroundTransparency = 1
HealthText.TextColor3 = Color3.new(1, 1, 1)
HealthText.Text = "100 / 100"
HealthText.TextSize = 12
HealthText.Font = "SourceSansBold"

-- // MAIN FRAME SETUP
local MainFrame = Instance.new("Frame", GeminiGui)
MainFrame.Size = UDim2.new(0, 250, 0, 30)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "тгк: extazz_scripts"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    while task.wait() do
        Title.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
end)

local CollapseBtn = Instance.new("TextButton", MainFrame)
CollapseBtn.Size = UDim2.new(0, 30, 0, 30)
CollapseBtn.Position = UDim2.new(1, -30, 0, 0)
CollapseBtn.Text = "-"
CollapseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CollapseBtn.TextColor3 = Color3.new(1, 1, 1)

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Size = UDim2.new(1, 0, 0, 350)
Content.Position = UDim2.new(0, 0, 0, 30)
Content.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Content.ScrollBarThickness = 2
Content.AutomaticCanvasSize = "Y"

CollapseBtn.MouseButton1Click:Connect(function()
    Content.Visible = not Content.Visible
    CollapseBtn.Text = Content.Visible and "-" or "+"
end)

local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0, 4)
UIList.HorizontalAlignment = "Center"

-- // COLOR PICKER
local CPFrame = Instance.new("Frame", GeminiGui)
CPFrame.Size = UDim2.new(0, 220, 0, 240)
CPFrame.Position = UDim2.new(0.5, -110, 0.5, -120)
CPFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CPFrame.Visible = false
CPFrame.Active = true
CPFrame.Draggable = true
CPFrame.ZIndex = 20
Instance.new("UIStroke", CPFrame).Color = Color3.fromRGB(50, 50, 50)

local SatValBox = Instance.new("Frame", CPFrame)
SatValBox.Size = UDim2.new(0, 200, 0, 150)
SatValBox.Position = UDim2.new(0, 10, 0, 10)
SatValBox.ZIndex = 21

local SVGradientH = Instance.new("UIGradient", SatValBox)
local SatValOverlay = Instance.new("Frame", SatValBox)
SatValOverlay.Size = UDim2.new(1,0,1,0)
SatValOverlay.ZIndex = 22
local SVGradientV = Instance.new("UIGradient", SatValOverlay)
SVGradientV.Rotation = 90
SVGradientV.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
SatValOverlay.BackgroundColor3 = Color3.new(0,0,0)

local HueBox = Instance.new("Frame", CPFrame)
HueBox.Size = UDim2.new(0, 200, 0, 15)
HueBox.Position = UDim2.new(0, 10, 0, 170)
HueBox.ZIndex = 21
local HueGradient = Instance.new("UIGradient", HueBox)
HueGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.16, Color3.new(1,1,0)),
    ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
    ColorSequenceKeypoint.new(0.66, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)),
    ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
})

local SVIndicator = Instance.new("Frame", SatValBox)
SVIndicator.Size = UDim2.new(0, 4, 0, 4)
SVIndicator.BackgroundColor3 = Color3.new(1,1,1)
SVIndicator.ZIndex = 25
SVIndicator.BorderSizePixel = 1

local SVTrigger = Instance.new("TextButton", SatValBox)
SVTrigger.Size = UDim2.new(1, 0, 1, 0)
SVTrigger.BackgroundTransparency = 1
SVTrigger.Text = ""
SVTrigger.ZIndex = 26

local HueTrigger = Instance.new("TextButton", HueBox)
HueTrigger.Size = UDim2.new(1, 0, 1, 0)
HueTrigger.BackgroundTransparency = 1
HueTrigger.Text = ""
HueTrigger.ZIndex = 26

local curKey, h, s, v = "", 0, 1, 1
local function UpdateRGB()
    local color = Color3.fromHSV(h, s, v)
    if _G.Cfg[curKey] ~= nil then _G.Cfg[curKey] = color end
    SVGradientH.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(h, 1, 1))
end

HueTrigger.MouseButton1Down:Connect(function()
    local move; move = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            h = math.clamp((input.Position.X - HueBox.AbsolutePosition.X) / HueBox.AbsoluteSize.X, 0, 1)
            UpdateRGB()
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
end)

SVTrigger.MouseButton1Down:Connect(function()
    local move; move = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            s = math.clamp((input.Position.X - SatValBox.AbsolutePosition.X) / SatValBox.AbsoluteSize.X, 0, 1)
            v = math.clamp((input.Position.Y - SatValBox.AbsolutePosition.Y) / SatValBox.AbsoluteSize.Y, 0, 1)
            SVIndicator.Position = UDim2.new(s, -2, v, -2)
            UpdateRGB()
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
end)

local ApplyBtn = Instance.new("TextButton", CPFrame)
ApplyBtn.Size = UDim2.new(0, 200, 0, 30)
ApplyBtn.Position = UDim2.new(0, 10, 0, 200)
ApplyBtn.Text = "APPLY"
ApplyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ApplyBtn.TextColor3 = Color3.new(1,1,1)
ApplyBtn.ZIndex = 25
ApplyBtn.MouseButton1Click:Connect(function() CPFrame.Visible = false end)

-- // UI BUILDERS
local function CreateModule(name, key)
    local Mod = Instance.new("Frame", Content)
    Mod.Size = UDim2.new(0, 230, 0, 35)
    Mod.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Mod.AutomaticSize = "Y"
    
    local Btn = Instance.new("TextButton", Mod)
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.Text = "  " .. name
    Btn.TextXAlignment = "Left"
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.TextColor3 = Color3.new(1,1,1)
    
    local Ind = Instance.new("Frame", Btn)
    Ind.Size = UDim2.new(0, 4, 1, 0)
    Ind.Position = UDim2.new(1, -4, 0, 0)
    Ind.BackgroundColor3 = _G.Cfg[key] and Color3.new(0,1,0) or Color3.new(1,0,0)
    
    local Arr = Instance.new("TextButton", Btn)
    Arr.Size = UDim2.new(0, 25, 1, 0)
    Arr.Position = UDim2.new(1, -35, 0, 0)
    Arr.Text = ">"
    Arr.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Arr.TextColor3 = Color3.new(1,1,1)
    
    local Inner = Instance.new("Frame", Mod)
    Inner.Size = UDim2.new(1, 0, 0, 0)
    Inner.Position = UDim2.new(0, 0, 0, 35)
    Inner.Visible = false
    Inner.AutomaticSize = "Y"
    Inner.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Instance.new("UIListLayout", Inner)
    
    local function Toggle()
        _G.Cfg[key] = not _G.Cfg[key]
        local isEnabled = _G.Cfg[key]
        Ind.BackgroundColor3 = isEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
        ShowNotify(name, isEnabled)
    end
    
    Btn.MouseButton1Click:Connect(Toggle)
    Arr.MouseButton1Click:Connect(function()
        Inner.Visible = not Inner.Visible
        Arr.Text = Inner.Visible and "v" or ">"
    end)

    local bindKey = key .. "Bind"
    local bF = Instance.new("Frame", Inner)
    bF.Size = UDim2.new(1, 0, 0, 25)
    bF.BackgroundTransparency = 1
    
    local bL = Instance.new("TextLabel", bF)
    bL.Size = UDim2.new(0.6, 0, 1, 0)
    bL.Text = "  Bind"
    bL.TextColor3 = Color3.new(0.7,0.7,0.7)
    bL.BackgroundTransparency = 1
    bL.TextXAlignment = "Left"
    
    local bI = Instance.new("TextBox", bF)
    bI.Size = UDim2.new(0, 60, 0.8, 0)
    bI.Position = UDim2.new(1, -65, 0.1, 0)
    bI.Text = tostring(_G.Cfg[bindKey])
    bI.BackgroundColor3 = Color3.fromRGB(45,45,45)
    bI.TextColor3 = Color3.new(1,1,1)
    
    bI.FocusLost:Connect(function()
        local inputStr = bI.Text:gsub("%s+", "") 
        if inputStr == "" then _G.Cfg[bindKey] = "None" else _G.Cfg[bindKey] = inputStr end
        bI.Text = _G.Cfg[bindKey]
    end)
    
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if _G.Cfg[bindKey] ~= "None" and input.KeyCode.Name:lower() == _G.Cfg[bindKey]:lower() then
            Toggle()
        end
    end))

    return Inner
end

local function AddSlider(parent, text, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 25)
    f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.6, 0, 1, 0)
    l.Text = "  " .. text
    l.TextColor3 = Color3.new(0.7,0.7,0.7)
    l.BackgroundTransparency = 1
    l.TextXAlignment = "Left"
    local i = Instance.new("TextBox", f)
    i.Size = UDim2.new(0, 45, 0.8, 0)
    i.Position = UDim2.new(1, -50, 0.1, 0)
    i.Text = tostring(_G.Cfg[key])
    i.BackgroundColor3 = Color3.fromRGB(45,45,45)
    i.TextColor3 = Color3.new(1,1,1)
    i.FocusLost:Connect(function()
        local v = tonumber(i.Text)
        if v then _G.Cfg[key] = v end
    end)
end

local function AddColorBtn(parent, text, key)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 25)
    b.Text = "  [COLOR] " .. text
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextXAlignment = "Left"
    b.MouseButton1Click:Connect(function()
        curKey = key
        CPFrame.Visible = true
    end)
end

-- // CORE FUNCTIONS
local function GetTarget()
    local t, d = nil, _G.Cfg.AimbotMaxDistance
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if dist < d then d = dist; t = v end
        end
    end
    return t
end

local function CreateStar(position)
    local bgui = Instance.new("BillboardGui", GeminiGui)
    bgui.Size = UDim2.new(_G.Cfg.ParticleSize*0.5,0,_G.Cfg.ParticleSize*0.5,0)
    bgui.AlwaysOnTop = true
    local p = Instance.new("Part", workspace)
    p.Size = Vector3.new(0.1,0.1,0.1)
    p.Transparency = 1; p.CanCollide = false; p.Anchored = true; p.Position = position
    bgui.Adornee = p
    local f = Instance.new("Frame", bgui)
    f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = _G.Cfg.ParticleColor
    Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
    local tI = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(p, tI, {Position = p.Position + Vector3.new(math.random(-5,5), math.random(4,8), math.random(-5,5))}):Play()
    TweenService:Create(f, tI, {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0)}):Play()
    task.delay(0.6, function() p:Destroy(); bgui:Destroy() end)
end

local function CreateJumpCircle(pos)
    if not _G.Cfg.JumpVisualCirclesEnabled then return end
    local p = Instance.new("Part", workspace)
    p.Shape = Enum.PartType.Cylinder; p.Size = Vector3.new(0.1, 0, 0)
    p.CFrame = CFrame.new(pos - Vector3.new(0, 2.9, 0)) * CFrame.Angles(0, 0, math.rad(90))
    p.Transparency = 0.5; p.Anchored = true; p.CanCollide = false; p.Material = Enum.Material.Neon; p.Color = _G.Cfg.JumpCircleEffectColor
    local tI = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(p, tI, {Size = Vector3.new(0.1, _G.Cfg.JumpCircleMaximumSize, _G.Cfg.JumpCircleMaximumSize), Transparency = 1}):Play()
    task.delay(0.8, function() p:Destroy() end)
end

-- // CHINA HAT SETUP
local HatPart = Instance.new("Part", workspace)
HatPart.Name = "Gemini_ChinaHat"; HatPart.CanCollide = false; HatPart.Anchored = true; HatPart.Transparency = 1
local HatMesh = Instance.new("SpecialMesh", HatPart)
HatMesh.MeshType = "FileMesh"; HatMesh.MeshId = "rbxassetid://1033714"

-- // TARGET ESP SQUARE
local ESPMain = Instance.new("Frame", GeminiGui)
ESPMain.BackgroundTransparency = 1; ESPMain.AnchorPoint = Vector2.new(0.5, 0.5); ESPMain.Visible = false
local ESPStroke = Instance.new("UIStroke", ESPMain); ESPStroke.ApplyStrokeMode = "Border"

-- // CHAMS FUNCTION
local function UpdateChams()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local highlight = ChamsFolder:FindFirstChild(player.Name)
            
            if _G.Cfg.ChamsEnabled and char then
                if not highlight then
                    highlight = Instance.new("Highlight", ChamsFolder)
                    highlight.Name = player.Name
                end
                highlight.Adornee = char
                highlight.FillColor = _G.Cfg.ChamsColor
                highlight.OutlineColor = _G.Cfg.ChamsOutlineColor
                highlight.FillTransparency = _G.Cfg.ChamsFillTransparency
                highlight.OutlineTransparency = _G.Cfg.ChamsOutlineTransparency
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

-- // MAIN RENDER LOOP
table.insert(Connections, RunService.RenderStepped:Connect(function()
    local target = GetTarget()
    local char = LocalPlayer.Character
    Camera.FieldOfView = _G.Cfg.AspectRatioValue
    
    UpdateChams()
    
    if _G.Cfg.ChinaHatAccessoryEnabled and char and char:FindFirstChild("Head") then
        HatPart.Transparency = _G.Cfg.ChinaHatTransparency; HatPart.Color = _G.Cfg.ChinaHatAccessoryColor
        HatMesh.Scale = Vector3.new(_G.Cfg.ChinaHatWidthScale, _G.Cfg.ChinaHatHeightScale, _G.Cfg.ChinaHatWidthScale)
        HatPart.CFrame = char.Head.CFrame * CFrame.new(0, _G.Cfg.ChinaHatHeightOffset, 0)
    else HatPart.Transparency = 1 end

    if _G.Cfg.TargetHudEnabled and target and target.Character:FindFirstChild("Humanoid") then
        TargetHUD.Visible = true
        local hum = target.Character.Humanoid
        TargetName.Text = target.DisplayName
        TargetIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. target.UserId .. "&w=150&h=150"
        HealthBar.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
        HealthText.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
    else TargetHUD.Visible = false end

    if _G.Cfg.TargetESPSquareEnabled and target and target.Character:FindFirstChild("HumanoidRootPart") then
        local pos, onScreen = Camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
        if onScreen then
            ESPMain.Visible = true; ESPMain.Position = UDim2.new(0, pos.X, 0, pos.Y)
            ESPMain.Size = UDim2.new(0, _G.Cfg.TargetESPSquareSize, 0, _G.Cfg.TargetESPSquareSize)
            ESPStroke.Thickness = _G.Cfg.TargetESPBorderThickness; ESPStroke.Color = _G.Cfg.TargetESPSquareColor
            ESPMain.Rotation = (tick() * 100 * _G.Cfg.TargetESPRotationSpeed) % 360
        else ESPMain.Visible = false end
    else ESPMain.Visible = false end

    if _G.Cfg.TargetStrafeOrbitEnabled and target and target.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
        local angle = tick() * _G.Cfg.TargetStrafeOrbitSpeed
        local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * _G.Cfg.TargetStrafeOrbitRadius
        char.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + offset, target.Character.HumanoidRootPart.Position)
    end

    if _G.Cfg.KillAuraEnabled and target and target.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (char.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
        if dist <= _G.Cfg.KillAuraRange then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position), _G.Cfg.AimbotSmoothness)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(); VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end
    elseif _G.Cfg.AimbotEnabled and target and target.Character:FindFirstChild("Head") then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), _G.Cfg.AimbotSmoothness)
    end
end))

-- // JUMP DETECTION
local function ConnectJump(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Jumping:Connect(function() if _G.Cfg.JumpVisualCirclesEnabled then CreateJumpCircle(char.HumanoidRootPart.Position) end end)
end
LocalPlayer.CharacterAdded:Connect(ConnectJump)
if LocalPlayer.Character then ConnectJump(LocalPlayer.Character) end

-- // HIT PARTICLES
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not _G.Cfg.DamageParticlesEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local res = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
        if res and res.Instance then
            local char = res.Instance:FindFirstAncestorOfClass("Model")
            if char and char:FindFirstChildOfClass("Humanoid") and char ~= LocalPlayer.Character then
                for i = 1, 8 do CreateStar(res.Position) end
            end
        end
    end
end)

-- // ИНИЦИАЛИЗАЦИЯ МЕНЮ
local mAim = CreateModule("AIMBOT", "AimbotEnabled"); AddSlider(mAim, "Smooth", "AimbotSmoothness"); AddSlider(mAim, "MaxDist", "AimbotMaxDistance")
local mKilla = CreateModule("KILL AURA", "KillAuraEnabled"); AddSlider(mKilla, "Range", "KillAuraRange")
local mHud = CreateModule("TARGET HUD", "TargetHudEnabled")
local mEsp = CreateModule("TARGET ESP", "TargetESPSquareEnabled"); AddSlider(mEsp, "Size", "TargetESPSquareSize"); AddSlider(mEsp, "Border", "TargetESPBorderThickness"); AddColorBtn(mEsp, "Color", "TargetESPSquareColor")
local mOrb = CreateModule("TARGET STRAFE", "TargetStrafeOrbitEnabled"); AddSlider(mOrb, "Radius", "TargetStrafeOrbitRadius"); AddSlider(mOrb, "Speed", "TargetStrafeOrbitSpeed")

-- ОБНОВЛЕННЫЙ МОДУЛЬ CHINA HAT
local mHat = CreateModule("CHINA HAT", "ChinaHatAccessoryEnabled")
AddSlider(mHat, "Head Offset", "ChinaHatHeightOffset")
AddSlider(mHat, "Hat Width", "ChinaHatWidthScale")
AddSlider(mHat, "Hat Height", "ChinaHatHeightScale")
AddSlider(mHat, "Transparency", "ChinaHatTransparency")
AddColorBtn(mHat, "Hat Color", "ChinaHatAccessoryColor")

local mJmp = CreateModule("JUMP CIRCLES", "JumpVisualCirclesEnabled"); AddSlider(mJmp, "Max Size", "JumpCircleMaximumSize"); AddColorBtn(mJmp, "Circle Color", "JumpCircleEffectColor")
local mCha = CreateModule("CHAMS (Wallhack)", "ChamsEnabled"); AddColorBtn(mCha, "Fill Color", "ChamsColor"); AddColorBtn(mCha, "Outline Color", "ChamsOutlineColor")
local mHit = CreateModule("HIT PARTICLES", "DamageParticlesEnabled"); AddColorBtn(mHit, "Color", "ParticleColor")

local KillBtn = Instance.new("TextButton", Content); KillBtn.Size = UDim2.new(0, 230, 0, 35); KillBtn.Text = "KILL SCRIPT"; KillBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20); KillBtn.TextColor3 = Color3.new(1,1,1)
KillBtn.MouseButton1Click:Connect(function() for _, c in pairs(Connections) do c:Disconnect() end GeminiGui:Destroy(); HatPart:Destroy(); ChamsFolder:Destroy() end)
