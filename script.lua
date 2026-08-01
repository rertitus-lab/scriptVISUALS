local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- // 1. ЖЕСТКАЯ ОЧИСТКА ВСЕГО И ВСЯ
for _, v in pairs(CoreGui:GetChildren()) do
    if string.match(v.Name, "^Gemini_") then pcall(function() v:Destroy() end) end
end
if workspace:FindFirstChild("Gemini_3D_Chams") then pcall(function() workspace.Gemini_3D_Chams:Destroy() end) end
if workspace:FindFirstChild("Gemini_ChinaHat") then pcall(function() workspace.Gemini_ChinaHat:Destroy() end) end

local Lighting = game:GetService("Lighting")
if Lighting:FindFirstChild("GeminiSaturation") then Lighting.GeminiSaturation:Destroy() end
if Lighting:FindFirstChild("GeminiVibeBloom") then Lighting.GeminiVibeBloom:Destroy() end
if Lighting:FindFirstChild("GeminiVibeCC") then Lighting.GeminiVibeCC:Destroy() end
if Lighting:FindFirstChild("GeminiVibeBlur") then Lighting.GeminiVibeBlur:Destroy() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Connections = {}
_G.ToggleFuncs = {} 
local isMobile = UserInputService.TouchEnabled

local ChamsFolder = Instance.new("Folder", CoreGui); ChamsFolder.Name = "Gemini_Chams_Storage"
local Chams3DFolder = Instance.new("Folder", workspace); Chams3DFolder.Name = "Gemini_3D_Chams"
local FriendsList = {}

-- // КЭШ
local OrigPartData = setmetatable({}, {__mode = "k"})
local OrigNoClipStates = setmetatable({}, {__mode = "k"})
local LowerNameCache = setmetatable({}, {__index = function(t, k) local v = string.lower(k); t[k] = v; return v end})
local EspCache = {} 

local SharedKaTarget = nil 
local lastRealJumpTime = 0
local lastKillStrafeJumpTime = 0
local lastCriticalJumpTime = 0

-- // ЭФФЕКТЫ
local SaturationEffect = Instance.new("ColorCorrectionEffect")
SaturationEffect.Name = "GeminiSaturation"; SaturationEffect.Parent = Lighting; SaturationEffect.Enabled = false

local VibeBloom = Instance.new("BloomEffect")
VibeBloom.Name = "GeminiVibeBloom"; VibeBloom.Intensity = 0.35; VibeBloom.Size = 14; VibeBloom.Threshold = 0.9; VibeBloom.Parent = Lighting; VibeBloom.Enabled = false

local VibeCC = Instance.new("ColorCorrectionEffect")
VibeCC.Name = "GeminiVibeCC"; VibeCC.Contrast = 0.15; VibeCC.Saturation = 0.2; VibeCC.Parent = Lighting; VibeCC.Enabled = false

local VibeBlur = Instance.new("BlurEffect")
VibeBlur.Name = "GeminiVibeBlur"; VibeBlur.Size = 2; VibeBlur.Parent = Lighting; VibeBlur.Enabled = false

-- // КОНФИГ
_G.Cfg = {
    UITheme = "Dark",
    AimbotEnabled = false, AimbotMaxDistance = 1000, AimbotSmoothness = 1, AimbotEnabledBind = "None",
    TargetHudEnabled = false, TargetHudEnabledBind = "None", TargetHudNormalColor = Color3.fromRGB(0, 255, 100), TargetHudDamageColor = Color3.fromRGB(255, 0, 0), TargetHudPosition = UDim2.new(0.5, 50, 0.5, 50), TargetHudOnlyKillaura = false,
    KillAuraEnabled = false, KillAuraNoCamRotation = false, KillStrafeEnabled = false, KillStrafeSpeed = 20, KillStrafeDistance = 1, KillAuraRange = 25, KillAuraClickRange = 15, KillAuraSpeed = 1, KillAuraEnabledBind = "None",
    CriticalsEnabled = false, CriticalsNoKillStrafeJump = false, CriticalsOnlyKillAura = false, CriticalsEnabledBind = "None",
    HitboxEnabled = false, HitboxSize = 1, HitboxOnlyKillaura = false, HitboxEnabledBind = "None",
    SpeedEnabled = false, WalkSpeedValue = 16, SpeedEnabledBind = "None",
    VelocityEnabled = false, VelocityHorizontal = 0, VelocityVertical = 0, VelocityEnabledBind = "None",
    StrafeEnabled = false, StrafeEnabledBind = "None",
    AirStrafeEnabled = false, AirStrafeSpeed = 30, AirStrafeEnabledBind = "None",
    NoClipEnabled = false, NoClipEnabledBind = "None",
    SpiderEnabled = false, SpiderEnabledBind = "None", SpiderSpeed = 45,
    JitterEnabled = false, JitterRange = 45, JitterSpeed = 15, JitterYawMode = 1, JitterSpinAtJump = false, JitterSpinSpeed = 20, JitterEnabledBind = "None",
    AnimLagEnabled = false, AnimLagFPS = 5, AnimLagEnabledBind = "None",
    HitSoundEnabled = false, HitSoundMode = 1, HitSoundEnabledBind = "None",
    TargetESPSquareEnabled = false, TargetESPSquareSize = 110, TargetESPBorderThickness = 6.5, TargetESPSquareColor = Color3.new(1, 1, 1), TargetESPDamageColorEnabled = false, TargetESPDamageColor = Color3.fromRGB(255, 0, 0), TargetESPRotationSpeed = 1, TargetESPSquareEnabledBind = "None", TargetESPOnlyKillaura = false,
    Esp2DBoxEnabled = false, Esp2DBoxSize = 1, Esp2DBoxColor = Color3.fromRGB(0, 255, 200), Esp2DBoxEnabledBind = "None",
    Esp2DBoxNametagsEnabled = false, Esp2DBoxNametagsScale = 14, Esp2DBoxHealthBarEnabled = false, Esp2DBoxHealthBarBorder = 1,
    ArrowsEnabled = false, ArrowsDistance = 100, ArrowsColor = Color3.fromRGB(255, 0, 0), ArrowsEnabledBind = "None", ArrowsSize = 22, ArrowsShowDistance = false,
    TargetStrafeOrbitEnabled = false, TargetStrafeOrbitRadius = 5, TargetStrafeOrbitSpeed = 15, TargetStrafeOrbitEnabledBind = "None",
    ChinaHatAccessoryEnabled = false, ChinaHatAccessoryColor = Color3.fromRGB(255, 0, 0), ChinaHatHeightOffset = 0.8, ChinaHatWidthScale = 3, ChinaHatHeightScale = 2, ChinaHatTransparency = 0, ChinaHatAccessoryEnabledBind = "None",
    JumpVisualCirclesEnabled = false, JumpCircleMaximumSize = 12, JumpCircleEffectColor = Color3.fromRGB(0, 255, 255), JumpVisualCirclesEnabledBind = "None",
    ChamsEnabled = false, ChamsColor = Color3.new(1, 0, 0), ChamsOutlineColor = Color3.new(1, 1, 1), ChamsFillTransparency = 0.5, ChamsEnabledBind = "None",
    DamageParticlesEnabled = false, ParticleColor = Color3.fromRGB(255, 255, 255), ParticleSize = 4, ParticleAmount = 8, DamageParticlesEnabledBind = "None",
    WorldParticlesEnabled = false, WorldParticlesColor = Color3.fromRGB(255, 255, 255), WorldParticlesEnabledBind = "None",
    SaturationEnabled = false, SaturationValue = 1, SaturationEnabledBind = "None",
    ClientSideEnabled = false, ClientSideTransparency = 50, ClientSideColor = Color3.fromRGB(255, 100, 100), ClientSideDelTexture = false, ClientSideEnabledBind = "None",
    ClickFriendEnabled = false, ClickFriendEnabledBind = "None",
    DeleteFriendEnabled = false, DeleteFriendEnabledBind = "None",
    WorldColorEnabled = false, WorldColorValue = Color3.fromRGB(0, 255, 100), WorldColorTransparency = 0.2, WorldColorDarkness = 0, WorldColorShader = false, WorldColorEnabledBind = "None",
    AspectRatioValue = 80,
    CustomFovEnabled = false, CustomFovValue = 100, CustomFovEnabledBind = "None",
    ThirdPersonEnabled = false, ThirdPersonDistance = 15, ThirdPersonEnabledBind = "None",
    BindListPosition = UDim2.new(0, 20, 0.5, 0),
    TimeChangerEnabled = false, TimeChangerHours = 12, TimeChangerEnabledBind = "None",
    FullBrightEnabled = false, FullBrightBrightness = 2, FullBrightEnabledBind = "None"
}

local ThemeObjects = { Backgrounds = {}, Strokes = {}, Texts = {}, SecondaryTexts = {}, Inputs = {}, InputBackgrounds = {} }
local Themes = {
    Dark = { name = "Dark", bg = Color3.fromRGB(20, 20, 20), trans = 0.1, stroke = Color3.fromRGB(45, 45, 45), text = Color3.new(1,1,1), textSec = Color3.fromRGB(180,180,180), inputBg = Color3.fromRGB(35,35,35), accent = Color3.fromRGB(40,40,40) },
    Light = { name = "Light", bg = Color3.fromRGB(235, 235, 235), trans = 0.15, stroke = Color3.fromRGB(180, 180, 180), text = Color3.new(0,0,0), textSec = Color3.fromRGB(60,60,60), inputBg = Color3.fromRGB(200,200,200), accent = Color3.fromRGB(180,180,180) },
    Gray = { name = "Gray", bg = Color3.fromRGB(50, 50, 50), trans = 0.2, stroke = Color3.fromRGB(80, 80, 80), text = Color3.new(1,1,1), textSec = Color3.fromRGB(200,200,200), inputBg = Color3.fromRGB(70,70,70), accent = Color3.fromRGB(80,80,80) },
    Glass = { name = "Glass", bg = Color3.fromRGB(10, 10, 10), trans = 0.65, stroke = Color3.fromRGB(80, 80, 80), text = Color3.new(1,1,1), textSec = Color3.fromRGB(220,220,220), inputBg = Color3.fromRGB(30,30,30), accent = Color3.fromRGB(50,50,50) }
}

local ConfigFileName = "Gemini_Config_Main.json"
local function SaveConfig()
    local copy = {}
    for k, v in pairs(_G.Cfg) do
        if typeof(v) == "Color3" then copy[k] = {R = v.R, G = v.G, B = v.B, isColor = true}
        elseif typeof(v) == "UDim2" then copy[k] = {XScale = v.X.Scale, XOffset = v.X.Offset, YScale = v.Y.Scale, YOffset = v.Y.Offset, isUDim2 = true}
        else copy[k] = v end
    end
    copy.SavedFriends = FriendsList 
    pcall(function() writefile(ConfigFileName, HttpService:JSONEncode(copy)) end)
end

local function LoadConfig()
    if isfile and isfile(ConfigFileName) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFileName)) end)
        if success and type(data) == "table" then
            if type(data.SavedFriends) == "table" then FriendsList = {}; for k, v in pairs(data.SavedFriends) do FriendsList[string.lower(k)] = v end end
            for k, v in pairs(data) do
                if k ~= "SavedFriends" then
                    if type(v) == "table" and v.isColor then _G.Cfg[k] = Color3.new(v.R, v.G, v.B)
                    elseif type(v) == "table" and v.isUDim2 then _G.Cfg[k] = UDim2.new(v.XScale, v.XOffset, v.YScale, v.YOffset)
                    else _G.Cfg[k] = v end
                end
            end
        end
    end
    if not _G.Cfg.UITheme then _G.Cfg.UITheme = "Dark" end
end
LoadConfig()

table.insert(Connections, Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
    if _G.Cfg.CustomFovEnabled and Camera.FieldOfView ~= _G.Cfg.CustomFovValue then Camera.FieldOfView = _G.Cfg.CustomFovValue end
end))

local HitSounds = { "rbxassetid://140604838213617", "rbxassetid://130201387574815", "rbxassetid://135478009117226", "rbxassetid://96735711388006", "rbxassetid://126048302910782", "rbxassetid://7255642553" }

local GeminiGui = Instance.new("ScreenGui", CoreGui)
GeminiGui.Name = "Gemini_Final"
GeminiGui.IgnoreGuiInset = true; GeminiGui.ResetOnSpawn = false 

local Esp2DFolder = Instance.new("Folder", GeminiGui); Esp2DFolder.Name = "ESP2D_Storage"
local ArrowsFolder = Instance.new("Folder", GeminiGui); ArrowsFolder.Name = "Arrows_Storage"
local WorldStarsContainer = Instance.new("Frame", GeminiGui)
WorldStarsContainer.Name = "WorldStars_Storage"; WorldStarsContainer.Size = UDim2.new(1, 0, 1, 0); WorldStarsContainer.BackgroundTransparency = 1; WorldStarsContainer.ZIndex = 1 

local StarsData = {}
local MAX_STARS = 100; local STAR_RANGE = 120
for i = 1, MAX_STARS do
    local img = Instance.new("TextLabel", WorldStarsContainer)
    img.Text = "★"; img.Font = Enum.Font.GothamBlack; img.TextScaled = true; img.BackgroundTransparency = 1; img.Visible = false
    table.insert(StarsData, { gui = img, pos = Vector3.new(math.random(-STAR_RANGE, STAR_RANGE), math.random(-STAR_RANGE, STAR_RANGE), math.random(-STAR_RANGE, STAR_RANGE)), drift = Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5).Unit * math.random(2, 6), rotSpeed = math.random(-50, 50), size = math.random(15, 30) })
end

local TARGET_FONT = Enum.Font.GothamBlack

local function ShowNotify(text, isEnabled)
    local t = Themes[_G.Cfg.UITheme] or Themes.Dark
    local sound = Instance.new("Sound", game:GetService("SoundService"))
    sound.SoundId = isEnabled and "rbxassetid://1053296915" or "rbxassetid://129384639546095"; sound.Volume = 0.5; sound:Play(); game:GetService("Debris"):AddItem(sound, 1)

    local nF = Instance.new("TextLabel", GeminiGui)
    nF.Size = UDim2.new(0, 280, 0, 40); nF.Position = UDim2.new(0.5, -140, 0.4, 0); nF.BackgroundColor3 = t.bg; nF.TextColor3 = t.text; nF.Text = text .. (isEnabled and " ✅" or " ❌"); nF.Font = TARGET_FONT; nF.TextSize = 16; nF.BackgroundTransparency = 1; nF.TextTransparency = 1
    
    local s = Instance.new("UIStroke", nF); s.Thickness = 2; s.Color = isEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0); s.Transparency = 1; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border 
    Instance.new("UICorner", nF).CornerRadius = UDim.new(0, 5)

    local targetTrans = t.trans
    local tI = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(nF, tI, {Position = UDim2.new(0.5, -140, 0.45, 0), BackgroundTransparency = targetTrans, TextTransparency = 0}):Play()
    TweenService:Create(s, tI, {Transparency = 0}):Play()
    
    task.delay(1, function()
        local tO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        TweenService:Create(nF, tO, {Position = UDim2.new(0.5, -140, 0.5, 0), BackgroundTransparency = 1, TextTransparency = 1}):Play()
        TweenService:Create(s, tO, {Transparency = 1}):Play(); task.wait(0.3); nF:Destroy()
    end)
end

local function GetEspElements(player)
    if not EspCache[player] then
        local cache = {}
        local esp2DBox = Instance.new("Frame", Esp2DFolder); esp2DBox.Name = player.Name .. "_2DBox"; esp2DBox.BackgroundTransparency = 1; esp2DBox.Visible = false; Instance.new("UICorner", esp2DBox).CornerRadius = UDim.new(0, 4)
        local mainStroke = Instance.new("UIStroke", esp2DBox); mainStroke.Name = "MainStroke"; mainStroke.Thickness = 1.5; mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local grad = Instance.new("UIGradient", mainStroke); grad.Name = "StrokeGradient"; grad.Rotation = 45
        local glowFrame = Instance.new("Frame", esp2DBox); glowFrame.Size = UDim2.new(1, 0, 1, 0); glowFrame.BackgroundTransparency = 1; Instance.new("UICorner", glowFrame).CornerRadius = UDim.new(0, 4)
        local outerGlow = Instance.new("UIStroke", glowFrame); outerGlow.Name = "OuterGlow"; outerGlow.Thickness = 5; outerGlow.Transparency = 0.7; outerGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        local nameTag = Instance.new("TextLabel", esp2DBox); nameTag.Name = "Nametag"; nameTag.BackgroundTransparency = 1; nameTag.Font = TARGET_FONT; nameTag.TextColor3 = Color3.new(1, 1, 1); nameTag.TextStrokeTransparency = 0
        
        local hbBack = Instance.new("Frame", esp2DBox); hbBack.Name = "HealthBarBack"; hbBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30); hbBack.BorderColor3 = Color3.new(0, 0, 0)
        local hbFill = Instance.new("Frame", hbBack); hbFill.Name = "HealthBarFill"; hbFill.BorderSizePixel = 0; hbFill.BackgroundColor3 = Color3.new(1, 1, 1); hbFill.ClipsDescendants = true
        local hbGradientFrame = Instance.new("Frame", hbFill); hbGradientFrame.Name = "GradientFrame"; hbGradientFrame.BorderSizePixel = 0; hbGradientFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        local hbGrad = Instance.new("UIGradient", hbGradientFrame); hbGrad.Name = "HealthBarGradient"; hbGrad.Rotation = 90
        hbGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})
        
        cache.Box2D = esp2DBox; cache.BoxStroke = mainStroke; cache.BoxGrad = grad; cache.BoxGlow = outerGlow; cache.NameTag = nameTag; cache.HealthBack = hbBack; cache.HealthFill = hbFill; cache.HealthGradF = hbGradientFrame

        local boxESP = Instance.new("Part", Chams3DFolder); boxESP.Name = player.Name .. "_3DBox"; boxESP.Size = Vector3.new(4.5, 6, 1.5); boxESP.Transparency = 1; boxESP.CanCollide = false; boxESP.Anchored = true
        local hl = Instance.new("Highlight", boxESP); hl.Name = "HL"; hl.Adornee = boxESP; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        cache.Box3D = boxESP; cache.ChamsHighlight = hl

        local arrowUI = Instance.new("Frame", ArrowsFolder); arrowUI.Name = player.Name .. "_Arrow"; arrowUI.Size = UDim2.new(0, 40, 0, 40); arrowUI.BackgroundTransparency = 1; arrowUI.AnchorPoint = Vector2.new(0.5, 0.5); arrowUI.Visible = false
        local arrowSym = Instance.new("TextLabel", arrowUI); arrowSym.Name = "Symbol"; arrowSym.Size = UDim2.new(1, 0, 1, 0); arrowSym.BackgroundTransparency = 1; arrowSym.Text = "▲"; arrowSym.Font = Enum.Font.GothamBlack; arrowSym.TextStrokeTransparency = 0; arrowSym.AnchorPoint = Vector2.new(0.5, 0.5); arrowSym.Position = UDim2.new(0.5, 0, 0.5, 0)
        local distLbl = Instance.new("TextLabel", arrowUI); distLbl.Name = "Distance"; distLbl.Size = UDim2.new(2, 0, 0.5, 0); distLbl.Position = UDim2.new(-0.5, 0, 0.8, 0); distLbl.BackgroundTransparency = 1; distLbl.Font = Enum.Font.GothamBold; distLbl.TextSize = 12; distLbl.TextColor3 = Color3.new(1,1,1); distLbl.TextStrokeTransparency = 0
        
        cache.Arrow = arrowUI; cache.ArrowSym = arrowSym; cache.ArrowDist = distLbl
        EspCache[player] = cache
    end
    return EspCache[player]
end

Players.PlayerRemoving:Connect(function(player)
    if EspCache[player] then
        if EspCache[player].Box2D then EspCache[player].Box2D:Destroy() end
        if EspCache[player].Box3D then EspCache[player].Box3D:Destroy() end
        if EspCache[player].Arrow then EspCache[player].Arrow:Destroy() end
        EspCache[player] = nil
    end
end)

local Island = Instance.new("TextButton", GeminiGui)
Island.Size = UDim2.new(0, 350, 0, 35); Island.Position = UDim2.new(0.5, -175, 0, 10); Island.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Island.BackgroundTransparency = 0; Island.Text = ""; Island.AutoButtonColor = false; Instance.new("UICorner", Island).CornerRadius = UDim.new(0, 6)
table.insert(ThemeObjects.Backgrounds, Island)

if isMobile then local islScale = Instance.new("UIScale", Island); islScale.Scale = 0.7; Island.AnchorPoint = Vector2.new(0.5, 0); Island.Position = UDim2.new(0.5, 0, 0, 10) end
local Island_Glow = Instance.new("Frame", Island); Island_Glow.Size = UDim2.new(1, 4, 1, 4); Island_Glow.Position = UDim2.new(0, -2, 0, -2); Island_Glow.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Island_Glow.BackgroundTransparency = 0.5; Island_Glow.ZIndex = Island.ZIndex - 1; Instance.new("UICorner", Island_Glow).CornerRadius = UDim.new(0, 8)
local IslandStroke = Instance.new("UIStroke", Island); IslandStroke.Thickness = 1; IslandStroke.Color = Color3.fromRGB(45, 45, 45); table.insert(ThemeObjects.Strokes, IslandStroke)
local IslandTitle = Instance.new("TextLabel", Island); IslandTitle.Size = UDim2.new(0.5, 0, 1, 0); IslandTitle.Position = UDim2.new(0, 15, 0, 0); IslandTitle.BackgroundTransparency = 1; IslandTitle.Text = "тгк: extazz_scripts"; IslandTitle.Font = TARGET_FONT; IslandTitle.TextSize = 14; IslandTitle.TextColor3 = Color3.new(1, 1, 1); IslandTitle.TextXAlignment = "Left"; table.insert(ThemeObjects.Texts, IslandTitle)
local StatsLabel = Instance.new("TextLabel", Island); StatsLabel.Size = UDim2.new(0.5, 0, 1, 0); StatsLabel.Position = UDim2.new(0.5, -10, 0, 0); StatsLabel.BackgroundTransparency = 1; StatsLabel.Text = "FPS: 0 | PING: 0ms"; StatsLabel.Font = TARGET_FONT; StatsLabel.TextSize = 12; StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200); StatsLabel.TextXAlignment = "Right"; table.insert(ThemeObjects.SecondaryTexts, StatsLabel)

local MenuOpen = false 
local MainFrame = Instance.new("Frame", GeminiGui)
MainFrame.Size = UDim2.new(0, 750, 0, 450)
MainFrame.Position = isMobile and UDim2.new(0.5, 0, 0.5, 50) or UDim2.new(0.5, -375, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false 
MainFrame.BackgroundTransparency = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
table.insert(ThemeObjects.Backgrounds, MainFrame)
if isMobile then local uiScale = Instance.new("UIScale", MainFrame); uiScale.Scale = 0.65; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) end
local MainFrame_Glow = Instance.new("Frame", MainFrame); MainFrame_Glow.Size = UDim2.new(1, 4, 1, 4); MainFrame_Glow.Position = UDim2.new(0, -2, 0, -2); MainFrame_Glow.BackgroundColor3 = Color3.fromRGB(15, 15, 15); MainFrame_Glow.BackgroundTransparency = 0.5; MainFrame_Glow.ZIndex = MainFrame.ZIndex - 1; Instance.new("UICorner", MainFrame_Glow).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 1; MainStroke.Color = Color3.fromRGB(45, 45, 45); table.insert(ThemeObjects.Strokes, MainStroke)

local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 150, 1, -20); Sidebar.Position = UDim2.new(0, 10, 0, 10); Sidebar.BackgroundTransparency = 1
local CategoryHighlight = Instance.new("Frame", Sidebar); CategoryHighlight.Size = UDim2.new(1, 0, 0, 40); CategoryHighlight.Position = UDim2.new(0, 0, 0, 0); CategoryHighlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", CategoryHighlight).CornerRadius = UDim.new(0, 6)

local categories = {"Combat", "Movement", "Visuals", "Misc"}
local catIcons = {Combat = "🤺", Movement = "🏃", Visuals = "👁️", Misc = "⚙️"}
local catButtons = {}; local moduleFrames = {}; local currentCat = "Combat"

local ContentScroll = Instance.new("ScrollingFrame", MainFrame); ContentScroll.Size = UDim2.new(1, -180, 1, -20); ContentScroll.Position = UDim2.new(0, 170, 0, 10); ContentScroll.BackgroundTransparency = 1; ContentScroll.ScrollBarThickness = 2; ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0); ContentScroll.AutomaticCanvasSize = "Y"
local UIGrid = Instance.new("UIGridLayout", ContentScroll); UIGrid.CellSize = UDim2.new(0, 275, 0, 145); UIGrid.CellPadding = UDim2.new(0, 10, 0, 10)

local function SwitchCategory(catName)
    currentCat = catName; local targetBtn = catButtons[catName]; local t = Themes[_G.Cfg.UITheme] or Themes.Dark
    if targetBtn then
        TweenService:Create(CategoryHighlight, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetBtn.Position}):Play()
        for name, btn in pairs(catButtons) do
            local isActive = (name == catName)
            if t.name == "Light" then btn.TextColor3 = isActive and Color3.new(1,1,1) or Color3.new(0,0,0); CategoryHighlight.BackgroundColor3 = Color3.fromRGB(40,40,40)
            else btn.TextColor3 = isActive and Color3.new(0,0,0) or Color3.new(1,1,1); CategoryHighlight.BackgroundColor3 = Color3.fromRGB(255,255,255) end
        end
    end
    for _, mod in pairs(moduleFrames) do mod.frame.Visible = (mod.category == catName) end
end

for i, cat in ipairs(categories) do
    local yPos = (i - 1) * 45
    local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(1, 0, 0, 40); btn.Position = UDim2.new(0, 0, 0, yPos); btn.BackgroundTransparency = 1; btn.Text = "  " .. catIcons[cat] .. " " .. cat; btn.Font = TARGET_FONT; btn.TextSize = 14; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextXAlignment = Enum.TextXAlignment.Left
    catButtons[cat] = btn; btn.MouseButton1Click:Connect(function() SwitchCategory(cat) end)
end

local function ToggleMenu()
    MenuOpen = not MenuOpen; local t = Themes[_G.Cfg.UITheme] or Themes.Dark
    if MenuOpen then 
        MainFrame.Visible = true; TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = t.trans, Position = isMobile and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, -375, 0.5, -225)}):Play()
    else 
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1, Position = isMobile and UDim2.new(0.5, 0, 0.5, 50) or UDim2.new(0.5, -375, 0.5, -180)})
        tw:Play(); tw.Completed:Connect(function() if not MenuOpen then MainFrame.Visible = false end end) 
    end
end
Island.MouseButton1Click:Connect(ToggleMenu)
UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and input.KeyCode == Enum.KeyCode.RightShift then ToggleMenu() end end)

task.spawn(function()
    local renderFrames = 0; local lastTick = tick(); RunService.RenderStepped:Connect(function() renderFrames = renderFrames + 1 end)
    while task.wait(0.5) do
        local currentTick = tick(); local currentFPS = math.floor(renderFrames / (currentTick - lastTick)); renderFrames = 0; lastTick = currentTick
        local ping = 0; pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        StatsLabel.Text = "FPS: "..currentFPS.." | PING: "..ping.."ms"; IslandTitle.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
end)

local CPFrame = Instance.new("Frame", GeminiGui); CPFrame.Size = UDim2.new(0, 220, 0, 240); CPFrame.Position = UDim2.new(0.5, -110, 0.5, -120); CPFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); CPFrame.Visible = false; CPFrame.Active = true; CPFrame.ZIndex = 20
table.insert(ThemeObjects.Backgrounds, CPFrame)
local cpStroke = Instance.new("UIStroke", CPFrame); cpStroke.Color = Color3.fromRGB(50, 50, 50); table.insert(ThemeObjects.Strokes, cpStroke)
if isMobile then local cpScale = Instance.new("UIScale", CPFrame); cpScale.Scale = 0.7; CPFrame.AnchorPoint = Vector2.new(0.5, 0.5); CPFrame.Position = UDim2.new(0.5, 0, 0.5, 0) end

local SatValBox = Instance.new("Frame", CPFrame); SatValBox.Size = UDim2.new(0, 200, 0, 150); SatValBox.Position = UDim2.new(0, 10, 0, 10); SatValBox.ZIndex = 21
local SVGradientH = Instance.new("UIGradient", SatValBox); local SatValOverlay = Instance.new("Frame", SatValBox); SatValOverlay.Size = UDim2.new(1,0,1,0); SatValOverlay.ZIndex = 22; local SVGradientV = Instance.new("UIGradient", SatValOverlay); SVGradientV.Rotation = 90; SVGradientV.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)}); SatValOverlay.BackgroundColor3 = Color3.new(0,0,0)
local HueBox = Instance.new("Frame", CPFrame); HueBox.Size = UDim2.new(0, 200, 0, 15); HueBox.Position = UDim2.new(0, 10, 0, 170); HueBox.ZIndex = 21; local HueGradient = Instance.new("UIGradient", HueBox); HueGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.16, Color3.new(1,1,0)), ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)), ColorSequenceKeypoint.new(0.66, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)), ColorSequenceKeypoint.new(1, Color3.new(1,0,0))})
local SVIndicator = Instance.new("Frame", SatValBox); SVIndicator.Size = UDim2.new(0, 4, 0, 4); SVIndicator.BackgroundColor3 = Color3.new(1,1,1); SVIndicator.ZIndex = 25; SVIndicator.BorderSizePixel = 1
local curKey, h, s, v = "", 0, 1, 1
local function UpdateRGB() local color = Color3.fromHSV(h, s, v); if _G.Cfg[curKey] ~= nil then _G.Cfg[curKey] = color end; SVGradientH.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(h, 1, 1)); SaveConfig() end
local SVTrigger = Instance.new("TextButton", SatValBox); SVTrigger.Size = UDim2.new(1, 0, 1, 0); SVTrigger.BackgroundTransparency = 1; SVTrigger.Text = ""; SVTrigger.ZIndex = 26
local HueTrigger = Instance.new("TextButton", HueBox); HueTrigger.Size = UDim2.new(1, 0, 1, 0); HueTrigger.BackgroundTransparency = 1; HueTrigger.Text = ""; HueTrigger.ZIndex = 26
HueTrigger.MouseButton1Down:Connect(function() local move; move = UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then h = math.clamp((input.Position.X - HueBox.AbsolutePosition.X) / HueBox.AbsoluteSize.X, 0, 1); UpdateRGB() end end); UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end) end)
SVTrigger.MouseButton1Down:Connect(function() local move; move = UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then s = math.clamp((input.Position.X - SatValBox.AbsolutePosition.X) / SatValBox.AbsoluteSize.X, 0, 1); v = math.clamp((input.Position.Y - SatValBox.AbsolutePosition.Y) / SatValBox.AbsoluteSize.Y, 0, 1); SVIndicator.Position = UDim2.new(s, -2, v, -2); UpdateRGB() end end); UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end) end)
local ApplyBtn = Instance.new("TextButton", CPFrame); ApplyBtn.Size = UDim2.new(0, 200, 0, 30); ApplyBtn.Position = UDim2.new(0, 10, 0, 200); ApplyBtn.Text = "APPLY"; ApplyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ApplyBtn.TextColor3 = Color3.new(1,1,1); ApplyBtn.ZIndex = 25; ApplyBtn.Font = TARGET_FONT; table.insert(ThemeObjects.InputBackgrounds, ApplyBtn); table.insert(ThemeObjects.Texts, ApplyBtn); ApplyBtn.MouseButton1Click:Connect(function() CPFrame.Visible = false; SaveConfig() end)

local function IsKeyMatch(inputKeyCode, bindStr)
    local keyName = inputKeyCode.Name:lower(); local bStr = tostring(bindStr)
    local RuToEn = {["й"]="q",["ц"]="w",["у"]="e",["к"]="r",["е"]="t",["н"]="y",["г"]="u",["ш"]="i",["щ"]="o",["з"]="p",["х"]="leftbracket",["ъ"]="rightbracket",["ф"]="a",["ы"]="s",["в"]="d",["а"]="f",["п"]="g",["р"]="h",["о"]="j",["л"]="k",["д"]="l",["ж"]="semicolon",["э"]="quote",["я"]="z",["ч"]="x",["с"]="c",["м"]="v",["и"]="b",["т"]="n",["ь"]="m",["б"]="comma",["ю"]="period"}
    if RuToEn[bStr] then bStr = RuToEn[bStr] else bStr = bStr:lower() end
    if bStr == "ctrl" or bStr == "control" then return keyName == "leftcontrol" or keyName == "rightcontrol" elseif bStr == "shift" then return keyName == "leftshift" or keyName == "rightshift" elseif bStr == "alt" then return keyName == "leftalt" or keyName == "rightalt" end
    return keyName == bStr
end

local function CreateModule(name, key, category)
    local ModFrame = Instance.new("Frame", ContentScroll); ModFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", ModFrame)
    local s = Instance.new("UIStroke", ModFrame); s.Color = Color3.fromRGB(45,45,45); s.Thickness = 1
    table.insert(ThemeObjects.Backgrounds, ModFrame); table.insert(ThemeObjects.Strokes, s); table.insert(moduleFrames, {frame = ModFrame, category = category or "Misc"})
    local Title = Instance.new("TextLabel", ModFrame); Title.Size = UDim2.new(1, -50, 0, 35); Title.Position = UDim2.new(0, 10, 0, 0); Title.Text = name; Title.TextColor3 = Color3.new(1,1,1); Title.Font = TARGET_FONT; Title.TextSize = 14; Title.TextXAlignment = "Left"; Title.BackgroundTransparency = 1; table.insert(ThemeObjects.Texts, Title)
    local Toggle = Instance.new("TextButton", ModFrame); Toggle.Size = UDim2.new(0, 45, 0, 22); Toggle.Position = UDim2.new(1, -55, 0, 7); Toggle.BackgroundColor3 = _G.Cfg[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0); Toggle.Text = ""; Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1,0)
    
    local function RunToggle()
        _G.Cfg[key] = not _G.Cfg[key]; ShowNotify(name, _G.Cfg[key])
        if key == "SpeedEnabled" and not _G.Cfg[key] then if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end
        if key == "FullBrightEnabled" and not _G.Cfg[key] then Lighting.Brightness = 1 end
        if key == "SaturationEnabled" then SaturationEffect.Enabled = _G.Cfg.SaturationEnabled end
        if key == "WorldColorEnabled" and not _G.Cfg[key] then Lighting.Ambient = Color3.fromRGB(128, 128, 128); Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128); Lighting.ExposureCompensation = 0; VibeBloom.Enabled = false; VibeCC.Enabled = false; VibeBlur.Enabled = false end
        SaveConfig() 
    end
    _G.ToggleFuncs[key] = RunToggle; Toggle.MouseButton1Click:Connect(RunToggle)
    task.spawn(function() while task.wait(0.1) do Toggle.BackgroundColor3 = _G.Cfg[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0) end end)
    
    local Inner = Instance.new("ScrollingFrame", ModFrame); Inner.Size = UDim2.new(1, -10, 1, -40); Inner.Position = UDim2.new(0, 5, 0, 35); Inner.BackgroundTransparency = 1; Inner.ScrollBarThickness = 2; Inner.CanvasSize = UDim2.new(0, 0, 0, 0); Inner.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", Inner).Padding = UDim.new(0, 2)
    local bindKey = key .. "Bind"; local bF = Instance.new("Frame", Inner); bF.Size = UDim2.new(1, 0, 0, 20); bF.BackgroundTransparency = 1
    local bL = Instance.new("TextLabel", bF); bL.Size = UDim2.new(0.6, 0, 1, 0); bL.Text = "  Bind Key"; bL.TextColor3 = Color3.new(0.7,0.7,0.7); bL.BackgroundTransparency = 1; bL.TextXAlignment = "Left"; bL.TextSize = 12; bL.Font = TARGET_FONT; table.insert(ThemeObjects.SecondaryTexts, bL)
    local bI = Instance.new("TextBox", bF); bI.Size = UDim2.new(0, 60, 0.9, 0); bI.Position = UDim2.new(1, -65, 0, 0); bI.Text = tostring(_G.Cfg[bindKey]); bI.BackgroundColor3 = Color3.fromRGB(35,35,35); bI.TextColor3 = Color3.new(1,1,1); bI.TextSize = 10; bI.Font = TARGET_FONT; table.insert(ThemeObjects.Inputs, bI)
    bI.FocusLost:Connect(function() local inputStr = bI.Text:gsub("%s+", ""); if inputStr == "" or inputStr:lower() == "none" then _G.Cfg[bindKey] = "None" else _G.Cfg[bindKey] = inputStr end; bI.Text = _G.Cfg[bindKey]; SaveConfig() end)
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe) if gpe and UserInputService:GetFocusedTextBox() ~= nil then return end; if _G.Cfg[bindKey] ~= "None" and input.UserInputType == Enum.UserInputType.Keyboard then if IsKeyMatch(input.KeyCode, _G.Cfg[bindKey]) then RunToggle() end end end))
    return Inner
end

local function AddToggle(parent, text, key)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 18); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = "  " .. text; l.TextColor3 = Color3.new(0.6,0.6,0.6); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"; l.TextSize = 12; l.Font = TARGET_FONT; table.insert(ThemeObjects.SecondaryTexts, l)
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(0, 30, 0, 12); btn.Position = UDim2.new(1, -40, 0, 3); btn.Text = ""; Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    btn.BackgroundColor3 = _G.Cfg[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
    btn.MouseButton1Click:Connect(function() _G.Cfg[key] = not _G.Cfg[key]; btn.BackgroundColor3 = _G.Cfg[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0); SaveConfig() end)
    return f
end

local function AddSlider(parent, text, key)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 18); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = "  " .. text; l.TextColor3 = Color3.new(0.6,0.6,0.6); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"; l.TextSize = 12; l.Font = TARGET_FONT; table.insert(ThemeObjects.SecondaryTexts, l)
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0, 45, 0.9, 0); i.Position = UDim2.new(1, -50, 0, 0); i.Text = tostring(_G.Cfg[key]); i.BackgroundColor3 = Color3.fromRGB(40,40,40); i.TextColor3 = Color3.new(1,1,1); i.TextSize = 10; i.Font = TARGET_FONT; table.insert(ThemeObjects.Inputs, i)
    i.FocusLost:Connect(function() local v = tonumber(i.Text); if v then _G.Cfg[key] = v; SaveConfig() end end)
    return f
end

local function AddColorBtn(parent, text, key)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, 0, 0, 18); b.Text = "  [COLOR] " .. text; b.BackgroundColor3 = Color3.fromRGB(40, 40, 50); b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = "Left"; b.TextSize = 12; b.Font = TARGET_FONT; table.insert(ThemeObjects.InputBackgrounds, b); table.insert(ThemeObjects.Texts, b)
    b.MouseButton1Click:Connect(function() curKey = key; CPFrame.Visible = true end)
    return b
end

do
    local m
    m = CreateModule("AIMBOT", "AimbotEnabled", "Combat"); AddSlider(m, "Smooth", "AimbotSmoothness"); AddSlider(m, "MaxDist", "AimbotMaxDistance")
    m = CreateModule("KILL AURA", "KillAuraEnabled", "Combat"); AddToggle(m, "No Cam Rotate", "KillAuraNoCamRotation"); AddToggle(m, "Kill Strafe", "KillStrafeEnabled"); AddSlider(m, "Strafe Speed", "KillStrafeSpeed"); AddSlider(m, "Strafe Distance", "KillStrafeDistance"); AddSlider(m, "Range", "KillAuraRange"); AddSlider(m, "Click Range", "KillAuraClickRange"); AddSlider(m, "Delay (0.1s)", "KillAuraSpeed")
    m = CreateModule("CRITICALS", "CriticalsEnabled", "Combat"); AddToggle(m, "No Kill Strafe Jump", "CriticalsNoKillStrafeJump"); AddToggle(m, "Only with Kill Aura", "CriticalsOnlyKillAura")
    m = CreateModule("HITBOX", "HitboxEnabled", "Combat"); AddSlider(m, "Size Multiplier", "HitboxSize"); AddToggle(m, "Only Killaura", "HitboxOnlyKillaura")
    m = CreateModule("TARGET STRAFE", "TargetStrafeOrbitEnabled", "Combat"); AddSlider(m, "Radius", "TargetStrafeOrbitRadius"); AddSlider(m, "Speed", "TargetStrafeOrbitSpeed")
    
    m = CreateModule("PLAYER SPEED", "SpeedEnabled", "Movement"); AddSlider(m, "WalkSpeed", "WalkSpeedValue")
    m = CreateModule("VELOCITY (ANTI-KB)", "VelocityEnabled", "Movement"); AddSlider(m, "Horizontal %", "VelocityHorizontal"); AddSlider(m, "Vertical %", "VelocityVertical")
    m = CreateModule("HARD STRAFE", "StrafeEnabled", "Movement")
    m = CreateModule("AIR STRAFE", "AirStrafeEnabled", "Movement"); AddSlider(m, "Speed", "AirStrafeSpeed")
    m = CreateModule("NOCLIP", "NoClipEnabled", "Movement")
    m = CreateModule("SPIDER", "SpiderEnabled", "Movement"); AddSlider(m, "Speed", "SpiderSpeed")
    m = CreateModule("JITTER (ANTI-AIM)", "JitterEnabled", "Movement"); AddSlider(m, "Range (Angle)", "JitterRange"); AddSlider(m, "Speed (Freq)", "JitterSpeed"); AddSlider(m, "Yaw Mode (1=Fwd, 2=Bwd)", "JitterYawMode"); AddToggle(m, "Spin at jump", "JitterSpinAtJump"); AddSlider(m, "Spin Speed", "JitterSpinSpeed")
    m = CreateModule("ANIM LAG", "AnimLagEnabled", "Movement"); AddSlider(m, "Anim FPS (1-60)", "AnimLagFPS")

    m = CreateModule("TARGET HUD", "TargetHudEnabled", "Visuals"); AddColorBtn(m, "Normal HB color", "TargetHudNormalColor"); AddColorBtn(m, "Damage HB color", "TargetHudDamageColor"); AddToggle(m, "Only Killaura", "TargetHudOnlyKillaura")
    m = CreateModule("Target esp", "TargetESPSquareEnabled", "Visuals"); AddSlider(m, "Size", "TargetESPSquareSize"); AddSlider(m, "Border", "TargetESPBorderThickness"); AddColorBtn(m, "[COLOR] Target ESP", "TargetESPSquareColor"); AddToggle(m, "Damage Color Flash", "TargetESPDamageColorEnabled"); AddColorBtn(m, "[COLOR] Damage Color", "TargetESPDamageColor"); AddToggle(m, "Only Killaura", "TargetESPOnlyKillaura")
    m = CreateModule("2D BOX ESP", "Esp2DBoxEnabled", "Visuals"); AddSlider(m, "Size Multiplier", "Esp2DBoxSize"); AddColorBtn(m, "[COLOR] Box Color", "Esp2DBoxColor"); AddToggle(m, "Nametags", "Esp2DBoxNametagsEnabled"); AddSlider(m, "Nametags Scale", "Esp2DBoxNametagsScale"); AddToggle(m, "Healthbar", "Esp2DBoxHealthBarEnabled"); AddSlider(m, "Bar Border", "Esp2DBoxHealthBarBorder")
    m = CreateModule("ARROWS", "ArrowsEnabled", "Visuals"); AddSlider(m, "Range", "ArrowsDistance"); AddSlider(m, "Size", "ArrowsSize"); AddToggle(m, "Show Distance", "ArrowsShowDistance"); AddColorBtn(m, "Arrow Color", "ArrowsColor")
    m = CreateModule("WORLD STARS", "WorldParticlesEnabled", "Visuals"); AddColorBtn(m, "[COLOR] Stars Color", "WorldParticlesColor")
    m = CreateModule("CLIENT SIDE (GHOST)", "ClientSideEnabled", "Visuals"); AddSlider(m, "Transparency (0-100)", "ClientSideTransparency"); AddColorBtn(m, "Ghost Color", "ClientSideColor"); AddToggle(m, "Del Texture", "ClientSideDelTexture")
    m = CreateModule("CHINA HAT", "ChinaHatAccessoryEnabled", "Visuals"); AddSlider(m, "Head Offset", "ChinaHatHeightOffset"); AddSlider(m, "Width", "ChinaHatWidthScale"); AddSlider(m, "Height", "ChinaHatHeightScale"); AddSlider(m, "Transparency", "ChinaHatTransparency"); AddColorBtn(m, "Hat Color", "ChinaHatAccessoryColor")
    m = CreateModule("HIT PARTICLES", "DamageParticlesEnabled", "Visuals"); AddColorBtn(m, "Color", "ParticleColor"); AddSlider(m, "Size", "ParticleSize"); AddSlider(m, "Amount", "ParticleAmount")
    m = CreateModule("FULLBRIGHT", "FullBrightEnabled", "Visuals"); AddSlider(m, "Brightness (0-10)", "FullBrightBrightness")
    m = CreateModule("SATURATION", "SaturationEnabled", "Visuals"); AddSlider(m, "Intensity (0-50)", "SaturationValue")
    m = CreateModule("JUMP CIRCLES", "JumpVisualCirclesEnabled", "Visuals"); AddSlider(m, "Max Size", "JumpCircleMaximumSize"); AddColorBtn(m, "Color", "JumpCircleEffectColor")
    m = CreateModule("TIME CHANGER", "TimeChangerEnabled", "Visuals"); AddSlider(m, "Hours (0-23)", "TimeChangerHours")
    m = CreateModule("WORLD COLOR", "WorldColorEnabled", "Visuals"); AddColorBtn(m, "Map Color", "WorldColorValue"); AddSlider(m, "Intensity (0-1)", "WorldColorTransparency"); AddSlider(m, "Darkness (0-5)", "WorldColorDarkness"); AddToggle(m, "Shader (Vibe)", "WorldColorShader")
    m = CreateModule("HIT SOUND", "HitSoundEnabled", "Visuals"); AddSlider(m, "Sound (1-6)", "HitSoundMode")
    m = CreateModule("CUSTOM FOV", "CustomFovEnabled", "Visuals"); AddSlider(m, "FOV Value", "CustomFovValue")
    m = CreateModule("THIRD PERSON", "ThirdPersonEnabled", "Visuals"); AddSlider(m, "Distance", "ThirdPersonDistance")
end

-- // CORE LOGIC
local function IsVisible(targetPart)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local origin = Camera.CFrame.Position; local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new(); raycastParams.FilterDescendantsInstances = {char, targetPart.Parent, GeminiGui, ChamsFolder}; raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    return workspace:Raycast(origin, direction, raycastParams) == nil 
end

local function GetTarget()
    local t, d = nil, _G.Cfg.AimbotMaxDistance
    local myChar = LocalPlayer.Character; if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and not FriendsList[LowerNameCache[v.Name]] and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local dist = (myPos - v.Character.HumanoidRootPart.Position).Magnitude
            if dist < d then d = dist; t = v end
        end
    end
    return t
end

local KillauraLockedTarget = nil
local function GetKillauraTarget()
    local myChar = LocalPlayer.Character; if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position
    if KillauraLockedTarget then
        local eChar = KillauraLockedTarget.Character
        if eChar and eChar:FindFirstChild("HumanoidRootPart") and eChar:FindFirstChild("Humanoid") and eChar.Humanoid.Health > 0 then return KillauraLockedTarget else KillauraLockedTarget = nil end
    end
    local t, d = nil, _G.Cfg.KillAuraRange
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and not FriendsList[LowerNameCache[v.Name]] and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local dist = (myPos - v.Character.HumanoidRootPart.Position).Magnitude
            if dist <= d and IsVisible(v.Character.HumanoidRootPart) then d = dist; t = v end
        end
    end
    KillauraLockedTarget = t; return t
end

local function CreateStar(position)
    local bgui = Instance.new("BillboardGui", GeminiGui); bgui.Size = UDim2.new(_G.Cfg.ParticleSize*0.5,0,_G.Cfg.ParticleSize*0.5,0); bgui.AlwaysOnTop = true
    local p = Instance.new("Part", workspace); p.Size = Vector3.new(0.1,0.1,0.1); p.Transparency = 1; p.CanCollide = false; p.Anchored = true; p.Position = position; bgui.Adornee = p
    local f = Instance.new("TextLabel", bgui); f.Size = UDim2.new(1,0,1,0); f.BackgroundTransparency = 1; f.Text = "★"; f.TextScaled = true; f.TextColor3 = _G.Cfg.ParticleColor; f.Font = Enum.Font.GothamBlack
    local tI = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out); local rX = math.random(-8, 8); local rY = math.random(-1, 1); local rZ = math.random(-8, 8)
    TweenService:Create(p, tI, {Position = p.Position + Vector3.new(rX, rY, rZ)}):Play()
    TweenService:Create(f, tI, {TextTransparency = 1, Rotation = math.random(-180, 180)}):Play()
    task.delay(0.6, function() p:Destroy(); bgui:Destroy() end)
end

local function CreateJumpCircle(pos)
    if not _G.Cfg.JumpVisualCirclesEnabled then return end
    local p = Instance.new("Part", workspace); p.Shape = Enum.PartType.Cylinder; p.Size = Vector3.new(0.1, 0, 0); p.CFrame = CFrame.new(pos - Vector3.new(0, 2.9, 0)) * CFrame.Angles(0, 0, math.rad(90)); p.Transparency = 0.5; p.Anchored = true; p.CanCollide = false; p.Material = Enum.Material.Neon; p.Color = _G.Cfg.JumpCircleEffectColor
    local tI = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out); TweenService:Create(p, tI, {Size = Vector3.new(0.1, _G.Cfg.JumpCircleMaximumSize, _G.Cfg.JumpCircleMaximumSize), Transparency = 1}):Play(); task.delay(0.8, function() p:Destroy() end)
end

local HatPart = Instance.new("Part", workspace); HatPart.Name = "Gemini_ChinaHat"; HatPart.CanCollide = false; HatPart.Anchored = true; HatPart.Transparency = 1
local HatMesh = Instance.new("SpecialMesh", HatPart); HatMesh.MeshType = "FileMesh"; HatMesh.MeshId = "rbxassetid://1033714"

local TargetHUD = Instance.new("Frame", GeminiGui); TargetHUD.Size = UDim2.new(0, 220, 0, 70); TargetHUD.Position = _G.Cfg.TargetHudPosition; TargetHUD.BackgroundColor3 = Color3.fromRGB(15, 15, 15); TargetHUD.Visible = false; TargetHUD.Active = true; TargetHUD.Draggable = true; table.insert(ThemeObjects.Backgrounds, TargetHUD)
TargetHUD.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then _G.Cfg.TargetHudPosition = TargetHUD.Position; SaveConfig() end end)
local TargetHUD_Glow = Instance.new("Frame", TargetHUD); TargetHUD_Glow.Size = UDim2.new(1, 4, 1, 4); TargetHUD_Glow.Position = UDim2.new(0, -2, 0, -2); TargetHUD_Glow.BackgroundColor3 = Color3.fromRGB(0, 255, 255); TargetHUD_Glow.BackgroundTransparency = 0.8; TargetHUD_Glow.ZIndex = TargetHUD.ZIndex - 1; Instance.new("UICorner", TargetHUD_Glow).CornerRadius = UDim.new(0, 15)
local cornerHUD = Instance.new("UICorner", TargetHUD); cornerHUD.CornerRadius = UDim.new(0, 12)
local strokeHUD = Instance.new("UIStroke", TargetHUD); strokeHUD.Color = Color3.new(0, 0, 0); strokeHUD.Thickness = 2; strokeHUD.Transparency = 0; table.insert(ThemeObjects.Strokes, strokeHUD)
local glowGradientBack = Instance.new("UIGradient", TargetHUD_Glow); glowGradientBack.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))}); glowGradientBack.Rotation = 45
local TargetIconContainer = Instance.new("Frame", TargetHUD); TargetIconContainer.Size = UDim2.new(0, 54, 0, 54); TargetIconContainer.Position = UDim2.new(0, 8, 0, 8); TargetIconContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TargetIconContainer.ClipsDescendants = true; Instance.new("UICorner", TargetIconContainer).CornerRadius = UDim.new(0, 6); table.insert(ThemeObjects.InputBackgrounds, TargetIconContainer)
local TargetIcon = Instance.new("ImageLabel", TargetIconContainer); TargetIcon.Size = UDim2.new(1.2, 0, 1.2, 0); TargetIcon.Position = UDim2.new(-0.1, 0, -0.1, 0); TargetIcon.BackgroundTransparency = 1; TargetIcon.ScaleType = Enum.ScaleType.Crop
local TargetName = Instance.new("TextLabel", TargetHUD); TargetName.Size = UDim2.new(1, -75, 0, 20); TargetName.Position = UDim2.new(0, 70, 0, 8); TargetName.BackgroundTransparency = 1; TargetName.TextColor3 = Color3.new(1, 1, 1); TargetName.Text = "No Target"; TargetName.Font = Enum.Font.GothamBold; TargetName.TextSize = 16; TargetName.TextXAlignment = Enum.TextXAlignment.Left; table.insert(ThemeObjects.Texts, TargetName)
local HealthText = Instance.new("TextLabel", TargetHUD); HealthText.Size = UDim2.new(1, -75, 0, 16); HealthText.Position = UDim2.new(0, 70, 0, 28); HealthText.BackgroundTransparency = 1; HealthText.TextColor3 = Color3.new(1, 1, 1); HealthText.Text = "HP: 100.0"; HealthText.TextSize = 14; HealthText.Font = Enum.Font.GothamBold; HealthText.TextXAlignment = Enum.TextXAlignment.Left; table.insert(ThemeObjects.Texts, HealthText)
local HealthBack = Instance.new("Frame", TargetHUD); HealthBack.Size = UDim2.new(1, -78, 0, 10); HealthBack.Position = UDim2.new(0, 70, 0, 50); HealthBack.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", HealthBack).CornerRadius = UDim.new(0, 5); table.insert(ThemeObjects.InputBackgrounds, HealthBack)
local strokeHB = Instance.new("UIStroke", HealthBack); strokeHB.Color = Color3.fromRGB(60, 60, 60); strokeHB.Thickness = 1; table.insert(ThemeObjects.Strokes, strokeHB)
local HealthBar = Instance.new("Frame", HealthBack); HealthBar.Size = UDim2.new(1, 0, 1, 0); HealthBar.BackgroundColor3 = Color3.new(1, 1, 1); HealthBar.BorderSizePixel = 0; Instance.new("UICorner", HealthBar).CornerRadius = UDim.new(0, 5); local barGradient = Instance.new("UIGradient", HealthBar)

local lastTargetUserId = nil; local lastTargetHealth = nil; local lastDamageTimeHUD = 0; local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out); local currentTween = nil

local ESPMain = Instance.new("Frame", GeminiGui)
ESPMain.BackgroundTransparency = 1; ESPMain.AnchorPoint = Vector2.new(0.5, 0.5); ESPMain.Visible = false
local function CreateCorner(name, pos)
    local corner = Instance.new("Frame", ESPMain); corner.Size = UDim2.new(0.3, 0, 0.3, 0); corner.Position = pos; corner.BackgroundTransparency = 1
    local hL = Instance.new("Frame", corner); hL.BorderSizePixel = 0; hL.ZIndex = 6; hL.Size = UDim2.new(1, 0, 0, 0); hL.Position = (name:find("B")) and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 0, 0)
    local vL = Instance.new("Frame", corner); vL.BorderSizePixel = 0; vL.ZIndex = 6; vL.Size = UDim2.new(0, 0, 1, 0); vL.Position = (name:find("R")) and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
    local hS = Instance.new("UIStroke", hL); hS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; local vS = Instance.new("UIStroke", vL); vS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local hLG1 = Instance.new("Frame", corner); hLG1.BorderSizePixel = 0; hLG1.ZIndex = 5; hLG1.Size = UDim2.new(1, 0, 0, 0); hLG1.Position = hL.Position
    local vLG1 = Instance.new("Frame", corner); vLG1.BorderSizePixel = 0; vLG1.ZIndex = 5; vLG1.Size = UDim2.new(0, 0, 1, 0); vLG1.Position = vL.Position
    local hSG1 = Instance.new("UIStroke", hLG1); hSG1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; hSG1.Transparency = 0.55; local vSG1 = Instance.new("UIStroke", vLG1); vSG1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; vSG1.Transparency = 0.55
    local hLG2 = Instance.new("Frame", corner); hLG2.BorderSizePixel = 0; hLG2.ZIndex = 4; hLG2.Size = UDim2.new(1, 0, 0, 0); hLG2.Position = hL.Position
    local vLG2 = Instance.new("Frame", corner); vLG2.BorderSizePixel = 0; vLG2.ZIndex = 4; vLG2.Size = UDim2.new(0, 0, 1, 0); vLG2.Position = vL.Position
    local hSG2 = Instance.new("UIStroke", hLG2); hSG2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; hSG2.Transparency = 0.8; local vSG2 = Instance.new("UIStroke", vLG2); vSG2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; vSG2.Transparency = 0.8
    return {hL, vL, hS, vS, hSG1, vSG1, hSG2, vSG2}
end
local corners = {CreateCorner("TL", UDim2.new(0,0,0,0)), CreateCorner("TR", UDim2.new(0.7,0,0,0)), CreateCorner("BL", UDim2.new(0,0,0.7,0)), CreateCorner("BR", UDim2.new(0.7,0,0.7,0))}

local lastAttackTime = 0; local lastStrafeJumpTime = 0; local nextStrafeJumpDelay = math.random(1, 8) / 10; local currentKaStrafeDir = 1; local nextKaStrafeDirChange = 0
local lastEspTargetUserId = nil; local lastEspTargetHealth = nil; local lastDamageTimeESP = 0; local lastRenderedEspThickness = nil
local wasThirdPerson = false; local AnimLagAccumulator = 0; local WasAnimLagging = false

table.insert(Connections, RunService.Stepped:Connect(function(time, dt)
    if _G.Cfg.NoClipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then if OrigNoClipStates[part] == nil then OrigNoClipStates[part] = part.CanCollide end; part.CanCollide = false end end
    elseif not _G.Cfg.NoClipEnabled and LocalPlayer.Character then
        if next(OrigNoClipStates) ~= nil then for part, state in pairs(OrigNoClipStates) do if part and part.Parent then part.CanCollide = state end end; table.clear(OrigNoClipStates) end
    end
    
    if _G.Cfg.VelocityEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then for _, v in ipairs(hrp:GetChildren()) do if v:IsA("BodyVelocity") or v:IsA("BodyThrust") or v:IsA("BodyForce") or v:IsA("LinearVelocity") or v:IsA("VectorForce") then v:Destroy() end end end
    end
    
    if _G.Cfg.AnimLagEnabled and LocalPlayer.Character then
        local char = LocalPlayer.Character; local hum = char:FindFirstChild("Humanoid")
        if hum then
            local animator = hum:FindFirstChild("Animator")
            if animator then
                AnimLagAccumulator = AnimLagAccumulator + dt
                local interval = 1 / math.clamp(tonumber(_G.Cfg.AnimLagFPS) or 5, 1, 60)
                local doUpdate = AnimLagAccumulator >= interval
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do track:AdjustSpeed(0); if doUpdate then track.TimePosition = track.TimePosition + AnimLagAccumulator end end
                if doUpdate then AnimLagAccumulator = 0 end
                WasAnimLagging = true
            end
        end
    elseif WasAnimLagging then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local animator = LocalPlayer.Character.Humanoid:FindFirstChild("Animator")
            if animator then for _, track in ipairs(animator:GetPlayingAnimationTracks()) do track:AdjustSpeed(1) end end
        end
        WasAnimLagging = false; AnimLagAccumulator = 0
    end
end))

-- // НЕВИДИМЫЙ ХИТБОКС ГОЛОВЫ С ФЕЙКОВОЙ ГОЛОВОЙ (ОБНОВЛЕНО - УБРАН КЭШ ДЛЯ НАДЕЖНОСТИ)
task.spawn(function()
    while task.wait(0.2) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                pcall(function()
                    local plChar = player.Character
                    if plChar then
                        local isFriend = FriendsList[LowerNameCache[player.Name]]
                        local isHitboxActive = false
                        local mult = 1
                        
                        if _G.Cfg.HitboxEnabled and not isFriend then 
                            if not _G.Cfg.HitboxOnlyKillaura or player == SharedKaTarget then 
                                isHitboxActive = true
                                mult = tonumber(_G.Cfg.HitboxSize) or 1 
                            end 
                        end
                        
                        -- Ищем голову напрямую, без кэширования списка частей
                        local head = plChar:FindFirstChild("Head")
                        if head and head:IsA("BasePart") then
                            if not OrigPartData[head] then 
                                OrigPartData[head] = {Size = head.Size, Trans = head.Transparency, CanCollide = head.CanCollide, Massless = head.Massless} 
                            end
                            
                            if isHitboxActive then
                                local targetSize = OrigPartData[head].Size * mult
                                if head.Size ~= targetSize then
                                    head.Size = targetSize
                                    head.Transparency = 1
                                    head.CanCollide = false
                                    head.Massless = true
                                    
                                    local face = head:FindFirstChildOfClass("Decal")
                                    if face then 
                                        if not OrigPartData[face] then OrigPartData[face] = {Trans = face.Transparency} end
                                        face.Transparency = 1 
                                    end
                                    
                                    if not plChar:FindFirstChild("Gemini_FakeHead") then
                                        local fakeHead = head:Clone()
                                        fakeHead.Name = "Gemini_FakeHead"
                                        for _, v in ipairs(fakeHead:GetChildren()) do
                                            if v:IsA("Attachment") or v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") or v:IsA("Script") or v:IsA("LocalScript") then
                                                v:Destroy()
                                            end
                                        end
                                        fakeHead.Size = OrigPartData[head].Size
                                        fakeHead.Transparency = OrigPartData[head].Trans
                                        fakeHead.CanCollide = false
                                        fakeHead.Massless = true
                                        
                                        local fakeFace = fakeHead:FindFirstChildOfClass("Decal")
                                        if fakeFace and OrigPartData[face] then fakeFace.Transparency = OrigPartData[face].Trans end
                                        
                                        local w = Instance.new("WeldConstraint")
                                        w.Part0 = head
                                        w.Part1 = fakeHead
                                        w.Parent = fakeHead
                                        fakeHead.Parent = plChar
                                    end
                                end
                            else
                                if head.Size ~= OrigPartData[head].Size or head.Transparency ~= OrigPartData[head].Trans then
                                    head.Size = OrigPartData[head].Size
                                    head.Transparency = OrigPartData[head].Trans
                                    head.CanCollide = OrigPartData[head].CanCollide
                                    head.Massless = OrigPartData[head].Massless
                                    
                                    local face = head:FindFirstChildOfClass("Decal")
                                    if face and OrigPartData[face] then face.Transparency = OrigPartData[face].Trans end
                                    local fakeH = plChar:FindFirstChild("Gemini_FakeHead")
                                    if fakeH then fakeH:Destroy() end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if _G.Cfg.WorldColorEnabled then
            local baseColor = _G.Cfg.WorldColorValue; local trans = math.clamp(_G.Cfg.WorldColorTransparency, 0, 1); local dark = math.clamp(_G.Cfg.WorldColorDarkness, 0, 5)
            local defaultAmbient = Color3.fromRGB(128, 128, 128); local blendedColor = defaultAmbient:Lerp(baseColor, trans)
            Lighting.Ambient = blendedColor; Lighting.OutdoorAmbient = blendedColor; Lighting.ExposureCompensation = -dark
            if _G.Cfg.WorldColorShader then 
                VibeBloom.Enabled = true; VibeCC.Enabled = true; VibeBlur.Enabled = true; 
                VibeCC.TintColor = Color3.new(1, 1, 1):Lerp(baseColor, 0.4)
            else 
                VibeBloom.Enabled = false; VibeCC.Enabled = false; VibeBlur.Enabled = false 
            end
        else 
            VibeBloom.Enabled = false; VibeCC.Enabled = false; VibeBlur.Enabled = false 
        end
    end
end)

-- GHOST VARIABLES
local GhostModel = nil
local GhostPartsMap = {}
local GhostHistory = {}
local lastGhostColor = nil
local lastGhostTrans = nil
local lastGhostDelTex = nil
local currentGhostCharRef = nil

local function UpdateGhostAppearance()
    if not GhostModel then return end
    local trans = (tonumber(_G.Cfg.ClientSideTransparency) or 50) / 100
    local delTex = _G.Cfg.ClientSideDelTexture
    local gColor = _G.Cfg.ClientSideColor
    
    pcall(function()
        local bc = GhostModel:FindFirstChildOfClass("BodyColors")
        if bc then bc:Destroy() end
    end)
    
    for _, p in ipairs(GhostModel:GetDescendants()) do
        pcall(function()
            if delTex then
                if p:IsA("Shirt") or p:IsA("Pants") or p:IsA("ShirtGraphic") or p:IsA("Decal") or p:IsA("Texture") or p:IsA("SurfaceAppearance") or p:IsA("WrapLayer") or p:IsA("WrapTarget") then
                    p:Destroy()
                    return
                end
                
                if p:IsA("CharacterMesh") then
                    p.BaseTextureId = 0
                    p.OverlayTextureId = 0
                end
                
                if p:IsA("SpecialMesh") then
                    p.TextureId = ""
                end
                
                if p:IsA("MeshPart") then
                    p.TextureID = ""
                end
            end
            
            if p:IsA("BasePart") then
                p.Transparency = trans
                p.Color = gColor
                if delTex then
                    p.Material = Enum.Material.SmoothPlastic
                    if p:IsA("MeshPart") then
                        p.TextureID = ""
                    end
                end
            end
        end)
    end
end

table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
    local target = GetTarget(); local char = LocalPlayer.Character; local currentKaTarget = nil
    if _G.Cfg.KillAuraEnabled then currentKaTarget = GetKillauraTarget() else KillauraLockedTarget = nil end
    SharedKaTarget = currentKaTarget 

    local hudTarget = target; if _G.Cfg.TargetHudOnlyKillaura then hudTarget = currentKaTarget end
    local espTarget = target; if _G.Cfg.TargetESPOnlyKillaura then espTarget = currentKaTarget end

    if _G.Cfg.CustomFovEnabled then Camera.FieldOfView = _G.Cfg.CustomFovValue else Camera.FieldOfView = _G.Cfg.AspectRatioValue end
    if _G.Cfg.TimeChangerEnabled then Lighting.ClockTime = math.clamp(_G.Cfg.TimeChangerHours, 0, 23) end
    if _G.Cfg.FullBrightEnabled then Lighting.Brightness = math.clamp(_G.Cfg.FullBrightBrightness, 0, 10) end
    
    if _G.Cfg.ThirdPersonEnabled then LocalPlayer.CameraMode = Enum.CameraMode.Classic; LocalPlayer.CameraMaxZoomDistance = _G.Cfg.ThirdPersonDistance or 15; LocalPlayer.CameraMinZoomDistance = _G.Cfg.ThirdPersonDistance or 15; wasThirdPerson = true
    elseif wasThirdPerson then LocalPlayer.CameraMinZoomDistance = 0.5; LocalPlayer.CameraMaxZoomDistance = 400; wasThirdPerson = false end
    
    if _G.Cfg.SaturationEnabled then SaturationEffect.Enabled = true; SaturationEffect.Saturation = tonumber(_G.Cfg.SaturationValue) or 1 else SaturationEffect.Enabled = false end
    
    if glowGradientBack then glowGradientBack.Rotation = (tick() * 35) % 360 end
    
    if _G.Cfg.WorldParticlesEnabled then
        WorldStarsContainer.Visible = true; local camPos = Camera.CFrame.Position; local dtSafe = dt or 0.016 
        for _, star in ipairs(StarsData) do
            star.pos = star.pos + star.drift * dtSafe; local diff = star.pos - camPos
            local wx = (diff.X + STAR_RANGE) % (STAR_RANGE * 2) - STAR_RANGE; local wy = (diff.Y + STAR_RANGE) % (STAR_RANGE * 2) - STAR_RANGE; local wz = (diff.Z + STAR_RANGE) % (STAR_RANGE * 2) - STAR_RANGE
            star.pos = camPos + Vector3.new(wx, wy, wz)
            local screenPos, onScreen = Camera:WorldToViewportPoint(star.pos)
            if onScreen and screenPos.Z > 1 and screenPos.Z < STAR_RANGE then
                star.gui.Visible = true; local scale = math.clamp(50 / screenPos.Z, 0.1, 2); local currentSize = star.size * scale
                star.gui.Size = UDim2.fromOffset(currentSize, currentSize); star.gui.Position = UDim2.fromOffset(screenPos.X - currentSize/2, screenPos.Y - currentSize/2)
                star.gui.Rotation = star.gui.Rotation + star.rotSpeed * dtSafe; star.gui.TextColor3 = _G.Cfg.WorldParticlesColor
                local fade = 1 - math.clamp(screenPos.Z / STAR_RANGE, 0, 1); star.gui.TextTransparency = 1 - (fade ^ 1.5)
            else star.gui.Visible = false end
        end
    else WorldStarsContainer.Visible = false end

    if _G.Cfg.SpeedEnabled and char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = _G.Cfg.WalkSpeedValue end
    
    -- // AIR STRAFE LOGIC
    if _G.Cfg.AirStrafeEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        local hrp = char.HumanoidRootPart
        if hum.FloorMaterial == Enum.Material.Air and hum.MoveDirection.Magnitude > 0 then
            local speed = tonumber(_G.Cfg.AirStrafeSpeed) or 30
            local currentVel = hrp.AssemblyLinearVelocity
            local targetVel = hum.MoveDirection.Unit * speed
            hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, currentVel.Y, targetVel.Z)
        end
    end
    
    if _G.Cfg.VelocityEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hrp = char.HumanoidRootPart; local hum = char.Humanoid; local hMult = tonumber(_G.Cfg.VelocityHorizontal) or 0; local vMult = tonumber(_G.Cfg.VelocityVertical) or 0
        if hMult == 0 then if hum.MoveDirection.Magnitude == 0 then hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) elseif not _G.Cfg.StrafeEnabled and not (_G.Cfg.AirStrafeEnabled and hum.FloorMaterial == Enum.Material.Air) then local currentSpeed = _G.Cfg.SpeedEnabled and _G.Cfg.WalkSpeedValue or hum.WalkSpeed; local targetVel = hum.MoveDirection.Unit * currentSpeed; hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, hrp.AssemblyLinearVelocity.Y, targetVel.Z) end end
        if vMult == 0 then if hrp.AssemblyLinearVelocity.Y > 0 and (tick() - lastRealJumpTime > 0.3) and (tick() - lastKillStrafeJumpTime > 0.3) and (tick() - lastCriticalJumpTime > 0.3) and not UserInputService:IsKeyDown(Enum.KeyCode.Space) then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z) end end
    end
    if _G.Cfg.StrafeEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid; local rootPart = char.HumanoidRootPart
        if hum.MoveDirection.Magnitude > 0 then 
            if not (_G.Cfg.AirStrafeEnabled and hum.FloorMaterial == Enum.Material.Air) then
                local currentSpeed = _G.Cfg.SpeedEnabled and _G.Cfg.WalkSpeedValue or hum.WalkSpeed; local instantVel = hum.MoveDirection.Unit * currentSpeed; rootPart.AssemblyLinearVelocity = Vector3.new(instantVel.X, rootPart.AssemblyLinearVelocity.Y, instantVel.Z) 
            end
        else 
            rootPart.AssemblyLinearVelocity = Vector3.new(0, rootPart.AssemblyLinearVelocity.Y, 0) 
        end
    end
    if _G.Cfg.SpiderEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local hrp = char.HumanoidRootPart; local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {char, ChamsFolder, Chams3DFolder}; rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local dirs = {hrp.CFrame.LookVector, -hrp.CFrame.LookVector, hrp.CFrame.RightVector, -hrp.CFrame.RightVector}; local touching = false
            for _, dir in ipairs(dirs) do
                local ray1 = workspace:Raycast(hrp.Position, dir * 2.5, rayParams); local ray2 = workspace:Raycast(hrp.Position + Vector3.new(0, 1, 0), dir * 2.5, rayParams); local ray3 = workspace:Raycast(hrp.Position - Vector3.new(0, 1, 0), dir * 2.5, rayParams)
                local function checkRay(r) return r and r.Instance and r.Instance:IsA("BasePart") and r.Instance.CanCollide end
                if checkRay(ray1) or checkRay(ray2) or checkRay(ray3) then touching = true; break end
            end
            if touching then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, tonumber(_G.Cfg.SpiderSpeed) or 45, hrp.AssemblyLinearVelocity.Z) end
        end
    end

    -- // 5. CLIENT SIDE GHOST LOGIC
    if _G.Cfg.ClientSideEnabled and char and char:FindFirstChild("HumanoidRootPart") then
        if currentGhostCharRef ~= char then
            if GhostModel then GhostModel:Destroy() end
            GhostModel = nil
            GhostPartsMap = {}
            GhostHistory = {}
            currentGhostCharRef = char
        end
        
        -- Динамическая перезагрузка при смене Del Texture
        if lastGhostDelTex ~= nil and lastGhostDelTex ~= _G.Cfg.ClientSideDelTexture then
            if GhostModel then GhostModel:Destroy() end
            GhostModel = nil 
            GhostPartsMap = {}
            lastGhostDelTex = _G.Cfg.ClientSideDelTexture
        end
        
        if not GhostModel or GhostModel.Parent ~= Chams3DFolder then
            char.Archivable = true
            GhostModel = char:Clone()
            GhostModel.Name = "Gemini_Ghost"
            GhostModel.Parent = Chams3DFolder
            GhostPartsMap = {}
            
            -- Удаляем Humanoid и HRP
            local hum = GhostModel:FindFirstChildOfClass("Humanoid")
            if hum then hum:Destroy() end
            local hrp = GhostModel:FindFirstChild("HumanoidRootPart")
            if hrp then hrp:Destroy() end
            
            for _, v in ipairs(GhostModel:GetDescendants()) do
                if v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() end
                if v:IsA("BasePart") then 
                    v.Anchored = true 
                    v.CanCollide = false 
                    v.CanQuery = false 
                    v.CanTouch = false 
                    v.Massless = true 
                end
            end
            
            for _, realPart in ipairs(char:GetDescendants()) do
                if realPart:IsA("BasePart") and realPart.Name ~= "HumanoidRootPart" then
                    local ghostPart = nil
                    if realPart.Parent == char then
                        ghostPart = GhostModel:FindFirstChild(realPart.Name)
                    elseif realPart.Parent:IsA("Accessory") then
                        local acc = GhostModel:FindFirstChild(realPart.Parent.Name)
                        if acc then ghostPart = acc:FindFirstChild(realPart.Name) end
                    end
                    
                    if ghostPart and ghostPart:IsA("BasePart") then
                        GhostPartsMap[realPart] = ghostPart
                    end
                end
            end
            
            lastGhostColor = _G.Cfg.ClientSideColor
            lastGhostTrans = _G.Cfg.ClientSideTransparency
            lastGhostDelTex = _G.Cfg.ClientSideDelTexture
            UpdateGhostAppearance()
        end

        local currentTrans = tonumber(_G.Cfg.ClientSideTransparency) or 50
        if lastGhostColor ~= _G.Cfg.ClientSideColor or lastGhostTrans ~= currentTrans then
            lastGhostColor = _G.Cfg.ClientSideColor; lastGhostTrans = currentTrans 
            UpdateGhostAppearance()
        end

        local currentPose = { t = tick(), parts = {} }
        for realPart, ghostPart in pairs(GhostPartsMap) do
            if realPart and realPart.Parent then
                currentPose.parts[ghostPart] = realPart.CFrame
            end
        end
        table.insert(GhostHistory, currentPose)
        
        while #GhostHistory > 0 and tick() - GhostHistory[1].t > 2 do table.remove(GhostHistory, 1) end
        
        local ping = 0; pcall(function() ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        ping = math.clamp(ping / 1000, 0, 2)
        local targetTime = tick() - ping
        local targetPose = GhostHistory[#GhostHistory]
        
        for i = #GhostHistory, 1, -1 do
            if GhostHistory[i].t <= targetTime then targetPose = GhostHistory[i]; break end
        end
        
        if targetPose then
            for ghostPart, cframe in pairs(targetPose.parts) do
                if ghostPart and ghostPart.Parent then ghostPart.CFrame = cframe end
            end
        end
    else
        if GhostModel then GhostModel:Destroy(); GhostModel = nil; GhostPartsMap = {}; GhostHistory = {}; currentGhostCharRef = nil end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local plChar = player.Character; local isFriend = FriendsList[LowerNameCache[player.Name]]; local espCache = GetEspElements(player)
            if isFriend then
                espCache.Box3D.CFrame = CFrame.new(0, -10000, 0) 
                local friendHighlight = plChar and plChar:FindFirstChild("FriendHighlight")
                if not friendHighlight and plChar then friendHighlight = Instance.new("Highlight", plChar); friendHighlight.Name = "FriendHighlight"; friendHighlight.FillColor = Color3.fromRGB(0, 255, 0); friendHighlight.OutlineColor = Color3.fromRGB(0, 200, 0); friendHighlight.FillTransparency = 0.8; friendHighlight.DepthMode = Enum.HighlightDepthMode.Occluded end
            elseif _G.Cfg.ChamsEnabled and plChar and plChar:FindFirstChild("HumanoidRootPart") then
                if plChar:FindFirstChild("FriendHighlight") then plChar.FriendHighlight:Destroy() end
                espCache.Box3D.CFrame = plChar.HumanoidRootPart.CFrame
                espCache.ChamsHighlight.FillColor = _G.Cfg.ChamsColor; espCache.ChamsHighlight.OutlineColor = _G.Cfg.ChamsOutlineColor; espCache.ChamsHighlight.FillTransparency = _G.Cfg.ChamsFillTransparency; espCache.ChamsHighlight.OutlineTransparency = 0
            else espCache.Box3D.CFrame = CFrame.new(0, -10000, 0); if plChar and plChar:FindFirstChild("FriendHighlight") then plChar.FriendHighlight:Destroy() end end

            if _G.Cfg.Esp2DBoxEnabled and plChar and plChar:FindFirstChild("HumanoidRootPart") and not isFriend then
                local hrp = plChar.HumanoidRootPart; local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local head = plChar:FindFirstChild("Head"); local topPos = head and head.Position + Vector3.new(0, 1, 0) or hrp.Position + Vector3.new(0, 3, 0); local bottomPos = hrp.Position - Vector3.new(0, 3.5, 0)
                    local topScreen = Camera:WorldToViewportPoint(topPos); local bottomScreen = Camera:WorldToViewportPoint(bottomPos)
                    local height = math.abs(bottomScreen.Y - topScreen.Y); local baseMultiplier = tonumber(_G.Cfg.Esp2DBoxSize) or 1; local finalHeight = height * baseMultiplier; local width = (height / 1.5) * baseMultiplier 
                    
                    espCache.Box2D.Size = UDim2.new(0, width, 0, finalHeight); espCache.Box2D.Position = UDim2.new(0, pos.X - width/2, 0, pos.Y - finalHeight/2)
                    espCache.BoxStroke.Color = _G.Cfg.Esp2DBoxColor; espCache.BoxGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, _G.Cfg.Esp2DBoxColor), ColorSequenceKeypoint.new(1, Color3.new(1,1,1):Lerp(_G.Cfg.Esp2DBoxColor, 0.5))}); espCache.BoxGrad.Rotation = (tick() * 50) % 360; espCache.BoxGlow.Color = _G.Cfg.Esp2DBoxColor 
                    
                    espCache.NameTag.Visible = _G.Cfg.Esp2DBoxNametagsEnabled == true
                    if _G.Cfg.Esp2DBoxNametagsEnabled then espCache.NameTag.TextSize = tonumber(_G.Cfg.Esp2DBoxNametagsScale) or 14; espCache.NameTag.Size = UDim2.new(1, 0, 0, espCache.NameTag.TextSize); espCache.NameTag.Position = UDim2.new(0, 0, 0, -espCache.NameTag.TextSize - 5); espCache.NameTag.Text = player.DisplayName end
                    
                    espCache.HealthBack.Visible = _G.Cfg.Esp2DBoxHealthBarEnabled == true
                    if _G.Cfg.Esp2DBoxHealthBarEnabled then
                        local border = tonumber(_G.Cfg.Esp2DBoxHealthBarBorder) or 1
                        espCache.HealthBack.BorderSizePixel = border; espCache.HealthBack.Size = UDim2.new(0, 4, 1, 0); espCache.HealthBack.Position = UDim2.new(0, -(6 + border), 0, 0)
                        local hum = plChar:FindFirstChild("Humanoid")
                        if hum then local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0.01, 1); espCache.HealthFill.Size = UDim2.new(1, 0, hpPercent, 0); espCache.HealthFill.Position = UDim2.new(0, 0, 1 - hpPercent, 0); espCache.HealthGradF.Size = UDim2.new(1, 0, 1 / hpPercent, 0); espCache.HealthGradF.Position = UDim2.new(0, 0, -((1 - hpPercent) / hpPercent), 0) end
                    end
                    espCache.Box2D.Visible = true
                else espCache.Box2D.Visible = false end
            else espCache.Box2D.Visible = false end

            if _G.Cfg.ArrowsEnabled and plChar and plChar:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") and not isFriend then
                local targetHRP = plChar.HumanoidRootPart; local localHRP = char.HumanoidRootPart; local dist = (targetHRP.Position - localHRP.Position).Magnitude
                if dist <= (tonumber(_G.Cfg.ArrowsDistance) or 100) then
                    local arrColor = _G.Cfg.ArrowsColor or Color3.fromRGB(255, 0, 0); local arrSize = tonumber(_G.Cfg.ArrowsSize) or 22
                    espCache.ArrowSym.TextColor3 = arrColor; espCache.ArrowSym.TextSize = arrSize
                    if _G.Cfg.ArrowsShowDistance then espCache.ArrowDist.Visible = true; espCache.ArrowDist.Text = math.floor(dist) .. "m"; espCache.ArrowDist.TextColor3 = arrColor else espCache.ArrowDist.Visible = false end
                    local relativeToCam = Camera.CFrame:PointToObjectSpace(targetHRP.Position); local angle = math.atan2(relativeToCam.X, -relativeToCam.Z)
                    local center = Camera.ViewportSize / 2; local radius = 150; local x = center.X + math.sin(angle) * radius; local y = center.Y - math.cos(angle) * radius
                    espCache.Arrow.Position = UDim2.new(0, x, 0, y); espCache.ArrowSym.Rotation = math.deg(angle); espCache.Arrow.Visible = true
                else espCache.Arrow.Visible = false end
            else espCache.Arrow.Visible = false end
        end
    end
    
    if _G.Cfg.ChinaHatAccessoryEnabled and char and char:FindFirstChild("Head") then HatPart.Transparency = _G.Cfg.ChinaHatTransparency; HatPart.Color = _G.Cfg.ChinaHatAccessoryColor; HatMesh.Scale = Vector3.new(_G.Cfg.ChinaHatWidthScale, _G.Cfg.ChinaHatHeightScale, _G.Cfg.ChinaHatWidthScale); HatPart.CFrame = char.Head.CFrame * CFrame.new(0, _G.Cfg.ChinaHatHeightOffset, 0) else HatPart.Transparency = 1 end

    if _G.Cfg.TargetHudEnabled and hudTarget and hudTarget.Character and hudTarget.Character:FindFirstChild("Humanoid") then
        TargetHUD.Visible = true; local hum = hudTarget.Character.Humanoid
        if lastTargetUserId ~= hudTarget.UserId then
            lastTargetUserId = hudTarget.UserId; TargetName.Text = hudTarget.DisplayName; TargetIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. hudTarget.UserId .. "&w=150&h=150"; lastTargetHealth = hum.Health 
            local initialHealthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            HealthBar.Size = UDim2.new(initialHealthPercent, 0, 1, 0); lastDamageTimeHUD = 0; TargetIcon.ImageColor3 = Color3.new(1, 1, 1)
        end
        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        if lastTargetHealth and hum.Health < lastTargetHealth then lastDamageTimeHUD = tick(); TargetIcon.ImageColor3 = _G.Cfg.TargetHudDamageColor or Color3.fromRGB(255, 0, 0); TweenService:Create(TargetIcon, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageColor3 = Color3.new(1, 1, 1)}):Play() end
        lastTargetHealth = hum.Health; local normColor = _G.Cfg.TargetHudNormalColor or Color3.fromRGB(0, 255, 100); local dmgColor = _G.Cfg.TargetHudDamageColor or Color3.fromRGB(255, 0, 0)
        local currentBarColor = normColor; local timeSinceDmgHud = tick() - lastDamageTimeHUD; if timeSinceDmgHud < 0.3 then currentBarColor = dmgColor:Lerp(normColor, timeSinceDmgHud / 0.3) end
        barGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, currentBarColor:Lerp(Color3.new(0, 0, 0), 0.2)), ColorSequenceKeypoint.new(1, currentBarColor)})
        if currentTween then currentTween:Cancel() end; currentTween = TweenService:Create(HealthBar, tweenInfo, {Size = UDim2.new(healthPercent, 0, 1, 0)}); currentTween:Play(); HealthText.Text = string.format("HP: %.1f", hum.Health)
    else TargetHUD.Visible = false; lastTargetUserId = nil; lastTargetHealth = nil; if currentTween then currentTween:Cancel() end end

    if _G.Cfg.TargetESPSquareEnabled and espTarget and espTarget.Character:FindFirstChild("HumanoidRootPart") then
        local espHum = espTarget.Character:FindFirstChild("Humanoid")
        if espHum then if lastEspTargetUserId ~= espTarget.UserId then lastEspTargetUserId = espTarget.UserId; lastEspTargetHealth = espHum.Health; lastDamageTimeESP = 0 end; if lastEspTargetHealth and espHum.Health < lastEspTargetHealth then lastDamageTimeESP = tick() end; lastEspTargetHealth = espHum.Health end
        local currentEspColor = _G.Cfg.TargetESPSquareColor
        if _G.Cfg.TargetESPDamageColorEnabled then local timeSinceDmgEsp = tick() - lastDamageTimeESP; if timeSinceDmgEsp < 0.6 then currentEspColor = _G.Cfg.TargetESPDamageColor:Lerp(_G.Cfg.TargetESPSquareColor, timeSinceDmgEsp / 0.6) end end
        local pos, onScreen = Camera:WorldToViewportPoint(espTarget.Character.HumanoidRootPart.Position)
        if onScreen then
            ESPMain.Visible = true; ESPMain.Position = UDim2.new(0, pos.X, 0, pos.Y); ESPMain.Size = UDim2.new(0, _G.Cfg.TargetESPSquareSize, 0, _G.Cfg.TargetESPSquareSize); ESPMain.Rotation = (tick() * 60 * _G.Cfg.TargetESPRotationSpeed) % 360 
            local updateThickness = false; if lastRenderedEspThickness ~= _G.Cfg.TargetESPBorderThickness then updateThickness = true; lastRenderedEspThickness = _G.Cfg.TargetESPBorderThickness end
            for _, c in pairs(corners) do 
                if updateThickness then c[3].Thickness = _G.Cfg.TargetESPBorderThickness; c[4].Thickness = _G.Cfg.TargetESPBorderThickness; c[5].Thickness = _G.Cfg.TargetESPBorderThickness + 4.5; c[6].Thickness = _G.Cfg.TargetESPBorderThickness + 4.5; c[7].Thickness = _G.Cfg.TargetESPBorderThickness + 11; c[8].Thickness = _G.Cfg.TargetESPBorderThickness + 11; end
                c[3].Color = currentEspColor; c[4].Color = currentEspColor; c[5].Color = currentEspColor; c[6].Color = currentEspColor; c[7].Color = currentEspColor; c[8].Color = currentEspColor
            end
        else ESPMain.Visible = false end
    else ESPMain.Visible = false; lastEspTargetUserId = nil; lastEspTargetHealth = nil end

    if _G.Cfg.TargetStrafeOrbitEnabled and target and target.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
        local angle = tick() * _G.Cfg.TargetStrafeOrbitSpeed; local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * _G.Cfg.TargetStrafeOrbitRadius; char.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + offset, target.Character.HumanoidRootPart.Position)
    end

    local didRotateHRP = false
    
    if _G.Cfg.KillAuraEnabled and char and char:FindFirstChild("HumanoidRootPart") then
        local kaTarget = currentKaTarget
        if kaTarget and kaTarget.Character and kaTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = kaTarget.Character.HumanoidRootPart; local hrp = char.HumanoidRootPart; local dist = (hrp.Position - targetPart.Position).Magnitude
            if dist <= _G.Cfg.KillAuraRange and IsVisible(targetPart) then
                if _G.Cfg.KillStrafeEnabled and char:FindFirstChild("Humanoid") then
                    local flatToTarget = Vector3.new(targetPart.Position.X - hrp.Position.X, 0, targetPart.Position.Z - hrp.Position.Z); local distFlat = flatToTarget.Magnitude
                    if distFlat > 0.1 then
                        if tick() > nextKaStrafeDirChange then currentKaStrafeDir = -currentKaStrafeDir; nextKaStrafeDirChange = tick() + (math.random(40, 90) / 100) end
                        local dirToTarget = flatToTarget.Unit; local rightDir = dirToTarget:Cross(Vector3.new(0, 1, 0)).Unit * currentKaStrafeDir; local noise = math.sin(tick() * 4) * 0.3; local currentOrbitDist = tonumber(_G.Cfg.KillStrafeDistance) or 1; local distanceError = distFlat - (currentOrbitDist + noise); local moveDir = (dirToTarget * distanceError + rightDir * 3).Unit
                        char.Humanoid:Move(moveDir, false); local kStrafeSpeed = tonumber(_G.Cfg.KillStrafeSpeed) or 20; hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * kStrafeSpeed, hrp.AssemblyLinearVelocity.Y, moveDir.Z * kStrafeSpeed)
                        local shouldJump = true; if _G.Cfg.CriticalsNoKillStrafeJump then shouldJump = false end
                        if shouldJump and tick() - lastStrafeJumpTime > nextStrafeJumpDelay then if char.Humanoid.FloorMaterial ~= Enum.Material.Air then char.Humanoid.Jump = true; lastStrafeJumpTime = tick(); lastKillStrafeJumpTime = tick(); nextStrafeJumpDelay = math.random(1, 8) / 10 end end
                    end
                end

                if _G.Cfg.KillAuraNoCamRotation then
                    local savedVel = hrp.AssemblyLinearVelocity
                    char.Humanoid.AutoRotate = false; hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPart.Position.X, hrp.Position.Y, targetPart.Position.Z))
                    hrp.AssemblyLinearVelocity = savedVel
                    didRotateHRP = true 
                else 
                    local savedVel = hrp.AssemblyLinearVelocity
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), _G.Cfg.AimbotSmoothness); hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPart.Position.X, hrp.Position.Y, targetPart.Position.Z))
                    hrp.AssemblyLinearVelocity = savedVel
                end
                
                if dist <= (_G.Cfg.KillAuraClickRange or 15) then
                    local attackDelay = (_G.Cfg.KillAuraSpeed / 10)
                    if tick() - lastAttackTime > attackDelay then
                        lastAttackTime = tick()
                        task.spawn(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1); task.wait(0.01); VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1) end)
                        if _G.Cfg.HitSoundEnabled then local sIdx = math.clamp(math.floor(_G.Cfg.HitSoundMode), 1, 6); local s = Instance.new("Sound", game:GetService("SoundService")); s.SoundId = HitSounds[sIdx]; s.Volume = 2; s:Play(); game:GetService("Debris"):AddItem(s, 1) end
                        if _G.Cfg.DamageParticlesEnabled then local pAmt = tonumber(_G.Cfg.ParticleAmount) or 8; for i = 1, pAmt do CreateStar(targetPart.Position) end end
                    end
                end
            end
        end
    end

    if not didRotateHRP and _G.Cfg.JitterEnabled and char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        char.Humanoid.AutoRotate = false
        
        local state = char.Humanoid:GetState()
        if _G.Cfg.JitterSpinAtJump and (state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping) then 
            local spinSpeed = tonumber(_G.Cfg.JitterSpinSpeed) or 20
            local spinAngle = math.rad((tick() * spinSpeed * 15) % 360)
            
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
        else 
            local jitterSign = (math.floor(tick() * (_G.Cfg.JitterSpeed or 15)) % 2 == 0) and 1 or -1
            local jitterYaw = math.rad(_G.Cfg.JitterRange or 45) * jitterSign
            local baseYaw = (tonumber(_G.Cfg.JitterYawMode) == 2) and math.pi or 0
            local totalYaw = baseYaw + jitterYaw 
            
            local lookVec = Camera.CFrame.LookVector; if char.Humanoid.MoveDirection.Magnitude > 0 then lookVec = char.Humanoid.MoveDirection end
            local lookAtTarget = hrp.Position + lookVec; local baseRot = CFrame.lookAt(hrp.Position, Vector3.new(lookAtTarget.X, hrp.Position.Y, lookAtTarget.Z))
            
            hrp.CFrame = baseRot * CFrame.Angles(0, totalYaw, 0)
        end
        didRotateHRP = true
    end
    
    if not didRotateHRP and char and char:FindFirstChild("Humanoid") then char.Humanoid.AutoRotate = true end

    if _G.Cfg.CriticalsEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local canCrit = true; if _G.Cfg.CriticalsOnlyKillAura and not _G.Cfg.KillAuraEnabled then canCrit = false end
        if canCrit and char.Humanoid.FloorMaterial ~= Enum.Material.Air then
            char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0); char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(char.HumanoidRootPart.AssemblyLinearVelocity.X, 0, char.HumanoidRootPart.AssemblyLinearVelocity.Z); lastCriticalJumpTime = tick()
        end
    end

    if not _G.Cfg.KillAuraEnabled and _G.Cfg.AimbotEnabled and target and target.Character and target.Character:FindFirstChild("Head") and char and char:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), _G.Cfg.AimbotSmoothness)
    end
end))

local BindListFrame = Instance.new("Frame", GeminiGui)
BindListFrame.Size = UDim2.new(0, 180, 0, 30); BindListFrame.Position = _G.Cfg.BindListPosition; BindListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); BindListFrame.Visible = false
Instance.new("UICorner", BindListFrame).CornerRadius = UDim.new(0, 6); table.insert(ThemeObjects.Backgrounds, BindListFrame)
local BLStroke = Instance.new("UIStroke", BindListFrame); BLStroke.Color = Color3.fromRGB(60, 60, 60); BLStroke.Thickness = 1.5; table.insert(ThemeObjects.Strokes, BLStroke)
local BLTitle = Instance.new("TextLabel", BindListFrame); BLTitle.Size = UDim2.new(1, 0, 0, 25); BLTitle.Text = "Keybind List"; BLTitle.TextColor3 = Color3.new(1, 1, 1); BLTitle.Font = TARGET_FONT; BLTitle.TextSize = 14; BLTitle.BackgroundTransparency = 1; table.insert(ThemeObjects.Texts, BLTitle)
local BLContainer = Instance.new("Frame", BindListFrame); BLContainer.Size = UDim2.new(1, -10, 1, -30); BLContainer.Position = UDim2.new(0, 5, 0, 25); BLContainer.BackgroundTransparency = 1; Instance.new("UIListLayout", BLContainer).Padding = UDim.new(0, 2)

local dragging, dragInput, dragStart, startPos
BindListFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = BindListFrame.Position end end)
BindListFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; BindListFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then if dragging then dragging = false; _G.Cfg.BindListPosition = BindListFrame.Position; SaveConfig() end end end)

local function UpdateKeybindList()
    local t = Themes[_G.Cfg.UITheme] or Themes.Dark
    for _, child in pairs(BLContainer:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end
    local activeCount = 0
    local modules = {"AimbotEnabled", "KillAuraEnabled", "HitboxEnabled", "CriticalsEnabled", "SpeedEnabled", "VelocityEnabled", "StrafeEnabled", "AirStrafeEnabled", "NoClipEnabled", "SpiderEnabled", "JitterEnabled", "AnimLagEnabled", "HitSoundEnabled", "TargetHudEnabled", "TargetESPSquareEnabled", "Esp2DBoxEnabled", "ArrowsEnabled", "TargetStrafeOrbitEnabled", "ChinaHatAccessoryEnabled", "JumpVisualCirclesEnabled", "ChamsEnabled", "DamageParticlesEnabled", "WorldParticlesEnabled", "SaturationEnabled", "ClientSideEnabled", "ClickFriendEnabled", "DeleteFriendEnabled", "WorldColorEnabled", "CustomFovEnabled", "ThirdPersonEnabled", "TimeChangerEnabled", "FullBrightEnabled"}
    for _, key in ipairs(modules) do
        local bindKey = key .. "Bind"
        if _G.Cfg[key] == true and _G.Cfg[bindKey] ~= "None" then
            activeCount = activeCount + 1
            local label = Instance.new("TextLabel", BLContainer); label.Size = UDim2.new(1, 0, 0, 18); label.BackgroundTransparency = 1; label.Text = " " .. key:gsub("Enabled", ""):upper() .. " [" .. tostring(_G.Cfg[bindKey]):upper() .. "]"; label.TextColor3 = t.textSec; label.TextSize = 13; label.Font = TARGET_FONT; label.TextXAlignment = Enum.TextXAlignment.Left
        end
    end
    BindListFrame.Visible = activeCount > 0
    if activeCount > 0 then BindListFrame.Size = UDim2.new(0, 180, 0, 30 + (activeCount * 20)) end
end

local MobileButtonsFrame = Instance.new("Frame", GeminiGui); MobileButtonsFrame.Size = UDim2.new(1, 0, 1, 0); MobileButtonsFrame.BackgroundTransparency = 1; MobileButtonsFrame.Visible = isMobile; MobileButtonsFrame.ZIndex = 50
local globalMobileDragging = false

local function UpdateMobileBinds()
    if not isMobile then return end
    local t = Themes[_G.Cfg.UITheme] or Themes.Dark
    local modulesList = {"AimbotEnabled", "KillAuraEnabled", "HitboxEnabled", "CriticalsEnabled", "SpeedEnabled", "VelocityEnabled", "StrafeEnabled", "AirStrafeEnabled", "NoClipEnabled", "SpiderEnabled", "JitterEnabled", "AnimLagEnabled", "HitSoundEnabled", "TargetHudEnabled", "TargetESPSquareEnabled", "Esp2DBoxEnabled", "ArrowsEnabled", "TargetStrafeOrbitEnabled", "ChinaHatAccessoryEnabled", "JumpVisualCirclesEnabled", "ChamsEnabled", "DamageParticlesEnabled", "WorldParticlesEnabled", "SaturationEnabled", "ClientSideEnabled", "ClickFriendEnabled", "DeleteFriendEnabled", "WorldColorEnabled", "CustomFovEnabled", "ThirdPersonEnabled", "TimeChangerEnabled", "FullBrightEnabled"}
    local activeModules = {}
    for _, key in ipairs(modulesList) do local bindKey = key .. "Bind"; if _G.Cfg[bindKey] and tostring(_G.Cfg[bindKey]) ~= "None" then activeModules[key] = tostring(_G.Cfg[bindKey]):upper() end end
    for _, child in pairs(MobileButtonsFrame:GetChildren()) do if not activeModules[child.Name] then child:Destroy() end end
    for key, bindLetter in pairs(activeModules) do
        local btn = MobileButtonsFrame:FindFirstChild(key)
        if not btn then
            btn = Instance.new("TextButton", MobileButtonsFrame); btn.Name = key; btn.Size = UDim2.new(0, 50, 0, 50)
            local savedPos = _G.Cfg["MobilePos_"..key]; if savedPos then btn.Position = UDim2.new(savedPos.XScale, savedPos.XOffset, savedPos.YScale, savedPos.YOffset) else btn.Position = UDim2.new(0.8, math.random(-50, 50), 0.5, math.random(-50, 50)) end
            btn.BackgroundColor3 = _G.Cfg[key] and Color3.fromRGB(0, 180, 0) or t.inputBg; btn.TextColor3 = t.text; btn.Font = TARGET_FONT; btn.TextSize = 22; btn.Text = bindLetter; Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            local str = Instance.new("UIStroke", btn); str.Color = Color3.fromRGB(0, 255, 255); str.Thickness = 2
            local mDragging = false; local dragStartPos = nil; local btnStartPos = nil; local mDragInput = nil; local isTap = true
            
            btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then if not globalMobileDragging then globalMobileDragging = true; mDragging = true; isTap = true; dragStartPos = input.Position; btnStartPos = btn.Position; btn.ZIndex = 100 end end end)
            btn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then mDragInput = input end end)
            UserInputService.InputChanged:Connect(function(input) if input == mDragInput and mDragging then local delta = input.Position - dragStartPos; if delta.Magnitude > 8 then isTap = false end; btn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then if mDragging then mDragging = false; globalMobileDragging = false; btn.ZIndex = 1; if isTap then if _G.ToggleFuncs[key] then _G.ToggleFuncs[key]() end else _G.Cfg["MobilePos_"..key] = {XScale = btn.Position.X.Scale, XOffset = btn.Position.X.Offset, YScale = btn.Position.Y.Scale, YOffset = btn.Position.Y.Offset, isUDim2 = true}; SaveConfig() end end end end)
        else btn.Text = bindLetter; btn.BackgroundColor3 = _G.Cfg[key] and Color3.fromRGB(0, 180, 0) or t.inputBg; btn.TextColor3 = t.text end
    end
end
task.spawn(function() while task.wait(0.5) do UpdateKeybindList(); UpdateMobileBinds() end end)

local function ConnectJump(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Jumping:Connect(function() lastRealJumpTime = tick(); if _G.Cfg.JumpVisualCirclesEnabled then CreateJumpCircle(char.HumanoidRootPart.Position) end end)
end
LocalPlayer.CharacterAdded:Connect(ConnectJump); if LocalPlayer.Character then ConnectJump(LocalPlayer.Character) end

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if tick() - lastAttackTime < 0.1 then return end
        local mousePos = UserInputService:GetMouseLocation(); local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y); local res = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
        if res and res.Instance then
            local hitChar = res.Instance:FindFirstAncestorOfClass("Model"); local p = Players:GetPlayerFromCharacter(hitChar)
            if hitChar and hitChar:FindFirstChildOfClass("Humanoid") and hitChar ~= LocalPlayer.Character and not FriendsList[LowerNameCache[hitChar.Name]] then 
                if _G.Cfg.DamageParticlesEnabled then local pAmt = tonumber(_G.Cfg.ParticleAmount) or 8; for i = 1, pAmt do CreateStar(res.Position) end end
                if _G.Cfg.HitSoundEnabled then local sIdx = math.clamp(math.floor(_G.Cfg.HitSoundMode), 1, 6); local sId = HitSounds[sIdx]; local s = Instance.new("Sound", game:GetService("SoundService")); s.SoundId = sId; s.Volume = 2; s:Play(); game:GetService("Debris"):AddItem(s, 1) end
            end
        end
    end
end)

do
    local function mkMisc(title)
        local f = Instance.new("Frame", ContentScroll); f.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", f); 
        local str = Instance.new("UIStroke", f); str.Color = Color3.fromRGB(45, 45, 45); 
        table.insert(moduleFrames, {frame = f, category = "Misc"}); table.insert(ThemeObjects.Backgrounds, f); table.insert(ThemeObjects.Strokes, str)
        local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1, -10, 0, 20); t.Position = UDim2.new(0, 5, 0, 5); t.Text = title; t.TextColor3 = Color3.new(1,1,1); t.Font = TARGET_FONT; t.TextSize = 14; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"; table.insert(ThemeObjects.Texts, t)
        return f
    end

    local UI = {}
    
    UI.fF = mkMisc("FRIENDS MANAGER")
    UI.fInp = Instance.new("TextBox", UI.fF); UI.fInp.Size = UDim2.new(1, -40, 0, 24); UI.fInp.Position = UDim2.new(0, 5, 0, 25); UI.fInp.BackgroundColor3 = Color3.fromRGB(15, 15, 15); UI.fInp.TextColor3 = Color3.new(1,1,1); UI.fInp.Font = TARGET_FONT; UI.fInp.TextSize = 12; UI.fInp.Text = "Username"; UI.fInp.ClearTextOnFocus = true; Instance.new("UICorner", UI.fInp).CornerRadius = UDim.new(0,4); table.insert(ThemeObjects.Inputs, UI.fInp)
    UI.fAdd = Instance.new("TextButton", UI.fF); UI.fAdd.Size = UDim2.new(0, 24, 0, 24); UI.fAdd.Position = UDim2.new(1, -30, 0, 25); UI.fAdd.BackgroundColor3 = Color3.fromRGB(40, 40, 40); UI.fAdd.TextColor3 = Color3.new(0, 1, 0); UI.fAdd.Text = "+"; UI.fAdd.Font = TARGET_FONT; UI.fAdd.TextSize = 16; Instance.new("UICorner", UI.fAdd).CornerRadius = UDim.new(0,4); table.insert(ThemeObjects.InputBackgrounds, UI.fAdd)
    UI.fScr = Instance.new("ScrollingFrame", UI.fF); UI.fScr.Size = UDim2.new(1, -10, 1, -60); UI.fScr.Position = UDim2.new(0, 5, 0, 55); UI.fScr.BackgroundTransparency = 1; UI.fScr.ScrollBarThickness = 2; UI.fScr.CanvasSize = UDim2.new(0, 0, 0, 0); UI.fScr.AutomaticCanvasSize = "Y"; Instance.new("UIListLayout", UI.fScr).Padding = UDim.new(0, 2)
    
    local function RefreshFriends()
        local th = Themes[_G.Cfg.UITheme] or Themes.Dark
        for _, c in pairs(UI.fScr:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        for fname, _ in pairs(FriendsList) do
            local i = Instance.new("Frame", UI.fScr); i.Size = UDim2.new(1, 0, 0, 20); i.BackgroundTransparency = 1
            local b = Instance.new("TextButton", i); b.Size = UDim2.new(0, 20, 0, 20); b.BackgroundColor3 = th.accent; b.TextColor3 = Color3.new(1, 0.2, 0.2); b.Text = "-"; b.Font = TARGET_FONT; b.TextSize = 14; Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
            local l = Instance.new("TextLabel", i); l.Size = UDim2.new(1, -25, 1, 0); l.Position = UDim2.new(0, 25, 0, 0); l.BackgroundTransparency = 1; l.Text = fname; l.TextColor3 = th.textSec; l.Font = TARGET_FONT; l.TextSize = 12; l.TextXAlignment = "Left"
            b.MouseButton1Click:Connect(function() FriendsList[fname] = nil; for _, tp in ipairs(Players:GetPlayers()) do if string.lower(tp.Name) == fname then if tp.Character and tp.Character:FindFirstChild("FriendHighlight") then tp.Character.FriendHighlight:Destroy() end break end end; SaveConfig(); RefreshFriends(); ShowNotify("Friend Removed: " .. fname, false) end)
        end
    end
    UI.fAdd.MouseButton1Click:Connect(function() local t = UI.fInp.Text:gsub("%s+", ""); if t ~= "" and t ~= "Username" then local lt = LowerNameCache[t]; FriendsList[lt] = true; UI.fInp.Text = "Username"; SaveConfig(); RefreshFriends(); ShowNotify("Friend Added: " .. lt, true) end end)
    local lastF = ""; task.spawn(function() while task.wait(0.2) do local c = HttpService:JSONEncode(FriendsList); if c ~= lastF then lastF = c; RefreshFriends() end end end)

    UI.gC = mkMisc("GENERATE CONFIG KEY")
    UI.gB = Instance.new("TextBox", UI.gC); UI.gB.Size = UDim2.new(1, -20, 0, 40); UI.gB.Position = UDim2.new(0, 10, 0, 35); UI.gB.BackgroundColor3 = Color3.fromRGB(15, 15, 15); UI.gB.TextColor3 = Color3.fromRGB(150, 150, 150); UI.gB.Font = Enum.Font.Code; UI.gB.TextSize = 10; UI.gB.TextWrapped = true; UI.gB.Text = "Your key will appear here"; UI.gB.ClearTextOnFocus = false; UI.gB.TextEditable = false; Instance.new("UICorner", UI.gB).CornerRadius = UDim.new(0,4); table.insert(ThemeObjects.Inputs, UI.gB)
    UI.gG = Instance.new("TextButton", UI.gC); UI.gG.Size = UDim2.new(1, -20, 0, 24); UI.gG.Position = UDim2.new(0, 10, 0, 80); UI.gG.BackgroundColor3 = Color3.fromRGB(40, 40, 40); UI.gG.TextColor3 = Color3.new(1,1,1); UI.gG.Text = "GENERATE"; UI.gG.Font = TARGET_FONT; UI.gG.TextSize = 14; Instance.new("UICorner", UI.gG).CornerRadius = UDim.new(0,4); table.insert(ThemeObjects.InputBackgrounds, UI.gG); table.insert(ThemeObjects.Texts, UI.gG)
    UI.gCp = Instance.new("TextButton", UI.gC); UI.gCp.Size = UDim2.new(1, -20, 0, 16); UI.gCp.Position = UDim2.new(0, 10, 0, 108); UI.gCp.BackgroundColor3 = Color3.fromRGB(30, 30, 30); UI.gCp.TextColor3 = Color3.fromRGB(200, 200, 200); UI.gCp.Text = "COPY"; UI.gCp.Font = TARGET_FONT; UI.gCp.TextSize = 10; Instance.new("UICorner", UI.gCp).CornerRadius = UDim.new(0,4); table.insert(ThemeObjects.InputBackgrounds, UI.gCp); table.insert(ThemeObjects.SecondaryTexts, UI.gCp)
    UI.gG.MouseButton1Click:Connect(function() UI.gB.Text = PackConfigString(); ShowNotify("Config Key Generated", true) end)
    UI.gCp.MouseButton1Click:Connect(function() if setclipboard then setclipboard(UI.gB.Text); ShowNotify("Copied to clipboard", true) else ShowNotify("Executor not supported", false) end end)

    UI.lC = mkMisc("LOAD CONFIG KEY")
    UI.lB = Instance.new("TextBox", UI.lC); UI.lB.Size = UDim2.new(1, -20, 0, 40); UI.lB.Position = UDim2.new(0, 10, 0, 35); UI.lB.BackgroundColor3 = Color3.fromRGB(15, 15, 15); UI.lB.TextColor3 = Color3.new(1,1,1); UI.lB.Font = Enum.Font.Code; UI.lB.TextSize = 10; UI.lB.TextWrapped = true; UI.lB.Text = "Paste key here"; UI.lB.ClearTextOnFocus = true; Instance.new("UICorner", UI.lB).CornerRadius = UDim.new(0,4); table.insert(ThemeObjects.Inputs, UI.lB)
    UI.lL = Instance.new("TextButton", UI.lC); UI.lL.Size = UDim2.new(1, -20, 0, 24); UI.lL.Position = UDim2.new(0, 10, 0, 80); UI.lL.BackgroundColor3 = Color3.fromRGB(40, 40, 40); UI.lL.TextColor3 = Color3.new(1,1,1); UI.lL.Text = "LOAD"; UI.lL.Font = TARGET_FONT; UI.lL.TextSize = 14; Instance.new("UICorner", UI.lL).CornerRadius = UDim.new(0,4); table.insert(ThemeObjects.InputBackgrounds, UI.lL); table.insert(ThemeObjects.Texts, UI.lL)
    UI.lP = Instance.new("TextButton", UI.lC); UI.lP.Size = UDim2.new(1, -20, 0, 16); UI.lP.Position = UDim2.new(0, 10, 0, 108); UI.lP.BackgroundColor3 = Color3.fromRGB(30, 30, 30); UI.lP.TextColor3 = Color3.fromRGB(200, 200, 200); UI.lP.Text = "PASTE"; UI.lP.Font = TARGET_FONT; UI.lP.TextSize = 10; Instance.new("UICorner", UI.lP).CornerRadius = UDim.new(0,4); table.insert(ThemeObjects.InputBackgrounds, UI.lP); table.insert(ThemeObjects.SecondaryTexts, UI.lP)
    UI.lL.MouseButton1Click:Connect(function() local txt = UI.lB.Text; if txt == "" or txt:find("Paste key") then return end; local cln = txt:gsub("%s+", ""); if UnpackConfigString(cln) then ShowNotify("Config Loaded", true) else ShowNotify("Invalid Key", false) end end)
    UI.lP.MouseButton1Click:Connect(function() if getclipboard then UI.lB.Text = tostring(getclipboard()); ShowNotify("Pasted from clipboard", true) else ShowNotify("Executor not supported", false) end end)

    UI.kC = mkMisc("")
    UI.kBtn = Instance.new("TextButton", UI.kC); UI.kBtn.Size = UDim2.new(1, -20, 0, 40); UI.kBtn.Position = UDim2.new(0, 10, 0.5, -20); UI.kBtn.Text = "KILL SCRIPT"; UI.kBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20); UI.kBtn.TextColor3 = Color3.new(1,1,1); UI.kBtn.Font = TARGET_FONT; UI.kBtn.TextSize = 16; Instance.new("UICorner", UI.kBtn)
    UI.kBtn.MouseButton1Click:Connect(function() 
        for _, c in pairs(Connections) do c:Disconnect() end 
        GeminiGui:Destroy(); HatPart:Destroy(); ChamsFolder:Destroy();
        if SaturationEffect then SaturationEffect:Destroy() end; if VibeBloom then VibeBloom:Destroy() end; if VibeCC then VibeCC:Destroy() end; if VibeBlur then VibeBlur:Destroy() end
        if workspace:FindFirstChild("Gemini_3D_Chams") then workspace.Gemini_3D_Chams:Destroy() end
    end)

    UI.tC = mkMisc("UI THEME (CYCLE)")
    UI.tBtn = Instance.new("TextButton", UI.tC); UI.tBtn.Size = UDim2.new(1, -20, 0, 40); UI.tBtn.Position = UDim2.new(0, 10, 0, 35); UI.tBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); UI.tBtn.TextColor3 = Color3.new(1,1,1); UI.tBtn.Text = "Theme: " .. tostring(_G.Cfg.UITheme); UI.tBtn.Font = TARGET_FONT; UI.tBtn.TextSize = 14; Instance.new("UICorner", UI.tBtn).CornerRadius = UDim.new(0,4); table.insert(ThemeObjects.InputBackgrounds, UI.tBtn); table.insert(ThemeObjects.Texts, UI.tBtn)

    local function ApplyTheme()
        local t = Themes[_G.Cfg.UITheme] or Themes.Dark
        for _, obj in ipairs(ThemeObjects.Backgrounds) do if obj and obj.Parent then obj.BackgroundColor3 = t.bg; if obj.Name == "TargetHUD" then obj.BackgroundTransparency = t.trans else obj.BackgroundTransparency = t.trans end end end
        for _, obj in ipairs(ThemeObjects.Strokes) do if obj and obj.Parent then obj.Color = t.stroke end end
        for _, obj in ipairs(ThemeObjects.Texts) do if obj and obj.Parent then obj.TextColor3 = t.text end end
        for _, obj in ipairs(ThemeObjects.SecondaryTexts) do if obj and obj.Parent then obj.TextColor3 = t.textSec end end
        for _, obj in ipairs(ThemeObjects.Inputs) do if obj and obj.Parent then obj.BackgroundColor3 = t.inputBg; obj.TextColor3 = t.text end end
        for _, obj in ipairs(ThemeObjects.InputBackgrounds) do if obj and obj.Parent then obj.BackgroundColor3 = t.accent end end
        UpdateKeybindList(); RefreshFriends(); SwitchCategory(currentCat)
    end

    local ThemesList = {"Dark", "Light", "Gray", "Glass"}
    UI.tBtn.MouseButton1Click:Connect(function() local idx = table.find(ThemesList, _G.Cfg.UITheme) or 1; idx = idx + 1; if idx > #ThemesList then idx = 1 end; _G.Cfg.UITheme = ThemesList[idx]; UI.tBtn.Text = "Theme: " .. _G.Cfg.UITheme; SaveConfig(); ApplyTheme() end)
    ApplyTheme()
end

SwitchCategory("Combat")
