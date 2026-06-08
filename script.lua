local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- // Очистка старых версий
if CoreGui:FindFirstChild("Gemini_V60_Final") then
    CoreGui.Gemini_V60_Final:Destroy()
end
if CoreGui:FindFirstChild("Gemini_Chams_Storage") then
    CoreGui.Gemini_Chams_Storage:Destroy()
end
if workspace:FindFirstChild("Gemini_3D_Chams") then
    workspace.Gemini_3D_Chams:Destroy()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Connections = {}
_G.ToggleFuncs = {} 
local isMobile = UserInputService.TouchEnabled

local ChamsFolder = Instance.new("Folder", CoreGui)
ChamsFolder.Name = "Gemini_Chams_Storage"

local Chams3DFolder = Instance.new("Folder", workspace)
Chams3DFolder.Name = "Gemini_3D_Chams"

local FriendsList = {}

-- // КЭШ
local OrigPartData = setmetatable({}, {__mode = "k"})
local PlayerPartsCache = setmetatable({}, {__mode = "k"})
local OrigNoClipStates = setmetatable({}, {__mode = "k"})
local LowerNameCache = setmetatable({}, {
    __index = function(t, k)
        local v = string.lower(k)
        t[k] = v
        return v
    end
})

local SharedKaTarget = nil -- Для связи хитбоксов и киллауры

-- // КОНФИГ
_G.Cfg = {
    AimbotEnabled = false, AimbotMaxDistance = 1000, AimbotSmoothness = 1, AimbotEnabledBind = "None",
    TargetHudEnabled = false, TargetHudEnabledBind = "None", TargetHudNormalColor = Color3.fromRGB(0, 255, 100), TargetHudDamageColor = Color3.fromRGB(255, 0, 0), TargetHudPosition = UDim2.new(0.5, 50, 0.5, 50), TargetHudOnlyKillaura = false,
    KillAuraEnabled = false, KillStrafeEnabled = false, KillStrafeSpeed = 20, KillStrafeDistance = 1, KillAuraRange = 25, KillAuraClickRange = 15, KillAuraSpeed = 1, KillAuraEnabledBind = "None",
    HitboxEnabled = false, HitboxSize = 1, HitboxOnlyKillaura = false, HitboxEnabledBind = "None",
    SpeedEnabled = false, WalkSpeedValue = 16, SpeedEnabledBind = "None",
    StrafeEnabled = false, StrafeEnabledBind = "None",
    NoClipEnabled = false, NoClipEnabledBind = "None",
    SpiderEnabled = false, SpiderEnabledBind = "None", SpiderSpeed = 45,
    HitSoundEnabled = false, HitSoundMode = 1, HitSoundEnabledBind = "None",
    TargetESPSquareEnabled = false, TargetESPSquareSize = 110, TargetESPBorderThickness = 6.5, TargetESPSquareColor = Color3.new(1, 1, 1), TargetESPDamageColorEnabled = false, TargetESPDamageColor = Color3.fromRGB(255, 0, 0), TargetESPRotationSpeed = 1, TargetESPSquareEnabledBind = "None", TargetESPOnlyKillaura = false,
    Esp2DBoxEnabled = false, Esp2DBoxSize = 1, Esp2DBoxColor = Color3.fromRGB(0, 255, 200), Esp2DBoxEnabledBind = "None",
    Esp2DBoxNametagsEnabled = false, Esp2DBoxNametagsScale = 14, Esp2DBoxHealthBarEnabled = false, Esp2DBoxHealthBarBorder = 1,
    TargetStrafeOrbitEnabled = false, TargetStrafeOrbitRadius = 5, TargetStrafeOrbitSpeed = 15, TargetStrafeOrbitEnabledBind = "None",
    ChinaHatAccessoryEnabled = false, ChinaHatAccessoryColor = Color3.fromRGB(255, 0, 0), ChinaHatHeightOffset = 0.8, ChinaHatWidthScale = 3, ChinaHatHeightScale = 2, ChinaHatTransparency = 0, ChinaHatAccessoryEnabledBind = "None",
    JumpVisualCirclesEnabled = false, JumpCircleMaximumSize = 12, JumpCircleEffectColor = Color3.fromRGB(0, 255, 255), JumpVisualCirclesEnabledBind = "None",
    ChamsEnabled = false, ChamsColor = Color3.new(1, 0, 0), ChamsOutlineColor = Color3.new(1, 1, 1), ChamsFillTransparency = 0.5, ChamsEnabledBind = "None",
    DamageParticlesEnabled = false, ParticleColor = Color3.fromRGB(255, 255, 255), ParticleSize = 4, ParticleAmount = 8, DamageParticlesEnabledBind = "None",
    WorldParticlesEnabled = false, WorldParticlesColor = Color3.fromRGB(255, 255, 255), WorldParticlesEnabledBind = "None",
    ClickFriendEnabled = false, ClickFriendEnabledBind = "None",
    DeleteFriendEnabled = false, DeleteFriendEnabledBind = "None",
    WorldColorEnabled = false, WorldColorValue = Color3.fromRGB(255, 0, 0), WorldColorTransparency = 0.5, WorldColorDarkness = 0, WorldColorEnabledBind = "None",
    AspectRatioValue = 80,
    CustomFovEnabled = false, CustomFovValue = 100, CustomFovEnabledBind = "None",
    BindListPosition = UDim2.new(0, 20, 0.5, 0),
    TimeChangerEnabled = false, TimeChangerHours = 12, TimeChangerEnabledBind = "None",
    FullBrightEnabled = false, FullBrightBrightness = 2, FullBrightEnabledBind = "None"
}

local ConfigLayout = {
    "AimbotEnabled", "AimbotMaxDistance", "AimbotSmoothness", "AimbotEnabledBind",
    "TargetHudEnabled", "TargetHudEnabledBind", "TargetHudNormalColor", "TargetHudDamageColor", "TargetHudPosition", "TargetHudOnlyKillaura",
    "KillAuraEnabled", "KillStrafeEnabled", "KillStrafeSpeed", "KillStrafeDistance", "KillAuraRange", "KillAuraClickRange", "KillAuraSpeed", "KillAuraEnabledBind",
    "HitboxEnabled", "HitboxSize", "HitboxOnlyKillaura", "HitboxEnabledBind",
    "SpeedEnabled", "WalkSpeedValue", "SpeedEnabledBind",
    "StrafeEnabled", "StrafeEnabledBind",
    "NoClipEnabled", "NoClipEnabledBind",
    "SpiderEnabled", "SpiderEnabledBind", "SpiderSpeed",
    "HitSoundEnabled", "HitSoundMode", "HitSoundEnabledBind",
    "TargetESPSquareEnabled", "TargetESPSquareSize", "TargetESPBorderThickness", "TargetESPSquareColor", "TargetESPDamageColorEnabled", "TargetESPDamageColor", "TargetESPRotationSpeed", "TargetESPSquareEnabledBind", "TargetESPOnlyKillaura",
    "Esp2DBoxEnabled", "Esp2DBoxSize", "Esp2DBoxColor", "Esp2DBoxEnabledBind", "Esp2DBoxNametagsEnabled", "Esp2DBoxNametagsScale", "Esp2DBoxHealthBarEnabled", "Esp2DBoxHealthBarBorder",
    "TargetStrafeOrbitEnabled", "TargetStrafeOrbitRadius", "TargetStrafeOrbitSpeed", "TargetStrafeOrbitEnabledBind",
    "ChinaHatAccessoryEnabled", "ChinaHatAccessoryColor", "ChinaHatHeightOffset", "ChinaHatWidthScale", "ChinaHatHeightScale", "ChinaHatTransparency", "ChinaHatAccessoryEnabledBind",
    "JumpVisualCirclesEnabled", "JumpCircleMaximumSize", "JumpCircleEffectColor", "JumpVisualCirclesEnabledBind",
    "ChamsEnabled", "ChamsColor", "ChamsOutlineColor", "ChamsFillTransparency", "ChamsEnabledBind",
    "DamageParticlesEnabled", "ParticleColor", "ParticleSize", "ParticleAmount", "DamageParticlesEnabledBind",
    "WorldParticlesEnabled", "WorldParticlesColor", "WorldParticlesEnabledBind",
    "ClickFriendEnabled", "ClickFriendEnabledBind",
    "DeleteFriendEnabled", "DeleteFriendEnabledBind",
    "WorldColorEnabled", "WorldColorValue", "WorldColorTransparency", "WorldColorDarkness", "WorldColorEnabledBind",
    "AspectRatioValue",
    "CustomFovEnabled", "CustomFovValue", "CustomFovEnabledBind",
    "BindListPosition",
    "TimeChangerEnabled", "TimeChangerHours", "TimeChangerEnabledBind",
    "FullBrightEnabled", "FullBrightBrightness", "FullBrightEnabledBind"
}

local ConfigFileName = "Gemini_V60_Config.json"
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
end
LoadConfig()

table.insert(Connections, Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
    if _G.Cfg.CustomFovEnabled and Camera.FieldOfView ~= _G.Cfg.CustomFovValue then Camera.FieldOfView = _G.Cfg.CustomFovValue end
end))

local HitSounds = {
    [1] = "rbxassetid://140604838213617", [2] = "rbxassetid://130201387574815", [3] = "rbxassetid://135478009117226", [4] = "rbxassetid://96735711388006", [5] = "rbxassetid://126048302910782", [6] = "rbxassetid://7255642553"
}

local GeminiGui = Instance.new("ScreenGui", CoreGui)
GeminiGui.Name = "Gemini_V60_Final"
GeminiGui.IgnoreGuiInset = true
GeminiGui.ResetOnSpawn = false 

local Esp2DFolder = Instance.new("Folder", GeminiGui)
Esp2DFolder.Name = "ESP2D_Storage"

local WorldStarsContainer = Instance.new("Frame", GeminiGui)
WorldStarsContainer.Name = "WorldStars_Storage"
WorldStarsContainer.Size = UDim2.new(1, 0, 1, 0)
WorldStarsContainer.BackgroundTransparency = 1
WorldStarsContainer.ZIndex = 1 

local StarsData = {}
local MAX_STARS = 300
local STAR_RANGE = 120

for i = 1, MAX_STARS do
    local img = Instance.new("TextLabel", WorldStarsContainer)
    img.Text = "★" 
    img.Font = Enum.Font.GothamBlack
    img.TextScaled = true
    img.BackgroundTransparency = 1
    img.Visible = false
    
    table.insert(StarsData, {
        gui = img,
        pos = Vector3.new(math.random(-STAR_RANGE, STAR_RANGE), math.random(-STAR_RANGE, STAR_RANGE), math.random(-STAR_RANGE, STAR_RANGE)),
        drift = Vector3.new(math.random()-0.5, math.random()-0.5, math.random()-0.5).Unit * math.random(2, 6),
        rotSpeed = math.random(-50, 50),
        size = math.random(15, 30)
    })
end

local TARGET_FONT = Enum.Font.GothamBlack

local function ShowNotify(text, isEnabled)
    local sound = Instance.new("Sound", game:GetService("SoundService"))
    sound.SoundId = isEnabled and "rbxassetid://1053296915" or "rbxassetid://129384639546095"
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
    nF.Font = TARGET_FONT 
    nF.TextSize = 16
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

local function StartFriendProcess(isDelete)
    local BigLabel = Instance.new("TextLabel", GeminiGui)
    BigLabel.Size = UDim2.new(1, 0, 0, 100)
    BigLabel.Position = UDim2.new(0, 0, 0.2, 0)
    BigLabel.BackgroundTransparency = 1
    BigLabel.Text = isDelete and "нажмите три раза по игроку чтобы удалить из друзей" or "кликните по своему другу три раза в течении 5 секунд!"
    BigLabel.TextColor3 = isDelete and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    BigLabel.Font = TARGET_FONT
    BigLabel.TextSize = 30
    BigLabel.TextStrokeTransparency = 0
    
    local ClickData = {}
    local ForceStop = false
    
    local ClickCon = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local res = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
            if res and res.Instance then
                local char = res.Instance:FindFirstAncestorOfClass("Model")
                local p = Players:GetPlayerFromCharacter(char)
                if p and p ~= LocalPlayer then
                    local lowerName = LowerNameCache[p.Name]
                    if isDelete and not FriendsList[lowerName] then return end
                    ClickData[p.Name] = (ClickData[p.Name] or 0) + 1
                    if ClickData[p.Name] >= 3 then
                        if isDelete then
                            FriendsList[lowerName] = nil
                            if char:FindFirstChild("FriendHighlight") then char.FriendHighlight:Destroy() end
                            ShowNotify("Friend Removed: " .. p.DisplayName, false)
                            _G.Cfg.DeleteFriendEnabled = false
                        else
                            FriendsList[lowerName] = true
                            ShowNotify("Friend Added: " .. p.DisplayName, true)
                            _G.Cfg.ClickFriendEnabled = false
                        end
                        SaveConfig() 
                        ForceStop = true
                    end
                end
            end
        end
    end)
    
    task.spawn(function()
        local start = tick()
        repeat task.wait() until tick() - start > 5 or ForceStop
        ClickCon:Disconnect()
        if BigLabel.Parent then BigLabel:Destroy() end
        if isDelete then _G.Cfg.DeleteFriendEnabled = false else _G.Cfg.ClickFriendEnabled = false end
        SaveConfig()
    end)
end

local Island = Instance.new("TextButton", GeminiGui)
Island.Size = UDim2.new(0, 350, 0, 35)
Island.Position = UDim2.new(0.5, -175, 0, 10)
Island.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Island.BackgroundTransparency = 0
Island.Text = ""
Island.AutoButtonColor = false
Instance.new("UICorner", Island).CornerRadius = UDim.new(0, 6)

if isMobile then
    local islScale = Instance.new("UIScale", Island)
    islScale.Scale = 0.7
    Island.AnchorPoint = Vector2.new(0.5, 0)
    Island.Position = UDim2.new(0.5, 0, 0, 10)
end

local Island_Glow = Instance.new("Frame", Island)
Island_Glow.Size = UDim2.new(1, 4, 1, 4)
Island_Glow.Position = UDim2.new(0, -2, 0, -2)
Island_Glow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Island_Glow.BackgroundTransparency = 0.5
Island_Glow.ZIndex = Island.ZIndex - 1
Instance.new("UICorner", Island_Glow).CornerRadius = UDim.new(0, 8)

local IslandStroke = Instance.new("UIStroke", Island)
IslandStroke.Thickness = 1
IslandStroke.Color = Color3.fromRGB(45, 45, 45)

local IslandTitle = Instance.new("TextLabel", Island)
IslandTitle.Size = UDim2.new(0.5, 0, 1, 0)
IslandTitle.Position = UDim2.new(0, 15, 0, 0)
IslandTitle.BackgroundTransparency = 1
IslandTitle.Text = "тгк: extazz_scripts"
IslandTitle.Font = TARGET_FONT
IslandTitle.TextSize = 14
IslandTitle.TextColor3 = Color3.new(1, 1, 1)
IslandTitle.TextXAlignment = "Left"

local StatsLabel = Instance.new("TextLabel", Island)
StatsLabel.Size = UDim2.new(0.5, 0, 1, 0)
StatsLabel.Position = UDim2.new(0.5, -10, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: 0 | PING: 0ms"
StatsLabel.Font = TARGET_FONT
StatsLabel.TextSize = 12
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextXAlignment = "Right"

local MainFrame = Instance.new("Frame", GeminiGui)
MainFrame.Size = UDim2.new(0, 750, 0, 450)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -180) 
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false 
MainFrame.BackgroundTransparency = 1 
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

if isMobile then
    local uiScale = Instance.new("UIScale", MainFrame)
    uiScale.Scale = 0.65
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 50) 
end

local MainFrame_Glow = Instance.new("Frame", MainFrame)
MainFrame_Glow.Size = UDim2.new(1, 4, 1, 4)
MainFrame_Glow.Position = UDim2.new(0, -2, 0, -2)
MainFrame_Glow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame_Glow.BackgroundTransparency = 0.5
MainFrame_Glow.ZIndex = MainFrame.ZIndex - 1
Instance.new("UICorner", MainFrame_Glow).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(45, 45, 45)

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 150, 1, -20)
Sidebar.Position = UDim2.new(0, 10, 0, 10)
Sidebar.BackgroundTransparency = 1

local CategoryHighlight = Instance.new("Frame", Sidebar)
CategoryHighlight.Size = UDim2.new(1, 0, 0, 40)
CategoryHighlight.Position = UDim2.new(0, 0, 0, 0)
CategoryHighlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", CategoryHighlight).CornerRadius = UDim.new(0, 6)

local categories = {"Combat", "Movement", "Visuals", "Misc"}
local catIcons = {Combat = "🤺", Movement = "🏃", Visuals = "👁️", Misc = "⚙️"}
local catButtons = {}
local moduleFrames = {}

local ContentScroll = Instance.new("ScrollingFrame", MainFrame)
ContentScroll.Size = UDim2.new(1, -180, 1, -20)
ContentScroll.Position = UDim2.new(0, 170, 0, 10)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 2
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = "Y"

local UIGrid = Instance.new("UIGridLayout", ContentScroll)
UIGrid.CellSize = UDim2.new(0, 275, 0, 145)
UIGrid.CellPadding = UDim2.new(0, 10, 0, 10)

local function SwitchCategory(catName)
    local targetBtn = catButtons[catName]
    if targetBtn then
        TweenService:Create(CategoryHighlight, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetBtn.Position}):Play()
        
        for name, btn in pairs(catButtons) do
            if name == catName then btn.TextColor3 = Color3.fromRGB(0, 0, 0) else btn.TextColor3 = Color3.fromRGB(255, 255, 255) end
        end
    end
    for _, mod in pairs(moduleFrames) do mod.frame.Visible = (mod.category == catName) end
end

for i, cat in ipairs(categories) do
    local yPos = (i - 1) * 45
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 40); btn.Position = UDim2.new(0, 0, 0, yPos); btn.BackgroundTransparency = 1
    btn.Text = "  " .. catIcons[cat] .. " " .. cat; btn.Font = TARGET_FONT; btn.TextSize = 14; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextXAlignment = Enum.TextXAlignment.Left
    catButtons[cat] = btn
    btn.MouseButton1Click:Connect(function() SwitchCategory(cat) end)
end

local MenuOpen = false 
local function ToggleMenu()
    MenuOpen = not MenuOpen
    if MenuOpen then
        MainFrame.Visible = true
        if isMobile then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Position = UDim2.new(0.5, -375, 0.5, -225)}):Play()
        end
    else
        if isMobile then
            local t = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 50)})
            t:Play()
            t.Completed:Connect(function() if not MenuOpen then MainFrame.Visible = false end end)
        else
            local t = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1, Position = UDim2.new(0.5, -375, 0.5, -180)})
            t:Play()
            t.Completed:Connect(function() if not MenuOpen then MainFrame.Visible = false end end)
        end
    end
end
Island.MouseButton1Click:Connect(ToggleMenu)

task.spawn(function()
    local renderFrames = 0
    local lastTick = tick()
    
    local conn = RunService.RenderStepped:Connect(function()
        renderFrames = renderFrames + 1
    end)
    
    while task.wait(0.5) do
        local currentTick = tick()
        local timePassed = currentTick - lastTick
        local currentFPS = math.floor(renderFrames / timePassed)
        renderFrames = 0
        lastTick = currentTick
        
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        
        StatsLabel.Text = "FPS: "..currentFPS.." | PING: "..ping.."ms"
        IslandTitle.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
end)

local CPFrame = Instance.new("Frame", GeminiGui)
CPFrame.Size = UDim2.new(0, 220, 0, 240); CPFrame.Position = UDim2.new(0.5, -110, 0.5, -120); CPFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CPFrame.Visible = false; CPFrame.Active = true; CPFrame.ZIndex = 20
Instance.new("UIStroke", CPFrame).Color = Color3.fromRGB(50, 50, 50)

if isMobile then
    local cpScale = Instance.new("UIScale", CPFrame)
    cpScale.Scale = 0.7
    CPFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    CPFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
end

local SatValBox = Instance.new("Frame", CPFrame)
SatValBox.Size = UDim2.new(0, 200, 0, 150); SatValBox.Position = UDim2.new(0, 10, 0, 10); SatValBox.ZIndex = 21

local SVGradientH = Instance.new("UIGradient", SatValBox)
local SatValOverlay = Instance.new("Frame", SatValBox)
SatValOverlay.Size = UDim2.new(1,0,1,0); SatValOverlay.ZIndex = 22
local SVGradientV = Instance.new("UIGradient", SatValOverlay)
SVGradientV.Rotation = 90; SVGradientV.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
SatValOverlay.BackgroundColor3 = Color3.new(0,0,0)

local HueBox = Instance.new("Frame", CPFrame)
HueBox.Size = UDim2.new(0, 200, 0, 15); HueBox.Position = UDim2.new(0, 10, 0, 170); HueBox.ZIndex = 21
local HueGradient = Instance.new("UIGradient", HueBox)
HueGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.16, Color3.new(1,1,0)), ColorSequenceKeypoint.new(0.33, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)), ColorSequenceKeypoint.new(0.66, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.83, Color3.new(1,0,1)), ColorSequenceKeypoint.new(1, Color3.new(1,0,0))})

local SVIndicator = Instance.new("Frame", SatValBox)
SVIndicator.Size = UDim2.new(0, 4, 0, 4); SVIndicator.BackgroundColor3 = Color3.new(1,1,1); SVIndicator.ZIndex = 25; SVIndicator.BorderSizePixel = 1

local curKey, h, s, v = "", 0, 1, 1
local function UpdateRGB()
    local color = Color3.fromHSV(h, s, v)
    if _G.Cfg[curKey] ~= nil then _G.Cfg[curKey] = color end
    SVGradientH.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(h, 1, 1))
    SaveConfig() 
end

local SVTrigger = Instance.new("TextButton", SatValBox); SVTrigger.Size = UDim2.new(1, 0, 1, 0); SVTrigger.BackgroundTransparency = 1; SVTrigger.Text = ""; SVTrigger.ZIndex = 26
local HueTrigger = Instance.new("TextButton", HueBox); HueTrigger.Size = UDim2.new(1, 0, 1, 0); HueTrigger.BackgroundTransparency = 1; HueTrigger.Text = ""; HueTrigger.ZIndex = 26

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

local ApplyBtn = Instance.new("TextButton", CPFrame); ApplyBtn.Size = UDim2.new(0, 200, 0, 30); ApplyBtn.Position = UDim2.new(0, 10, 0, 200); ApplyBtn.Text = "APPLY"; ApplyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ApplyBtn.TextColor3 = Color3.new(1,1,1); ApplyBtn.ZIndex = 25; ApplyBtn.Font = TARGET_FONT
ApplyBtn.MouseButton1Click:Connect(function() CPFrame.Visible = false; SaveConfig() end)

local function CreateModule(name, key, category)
    local ModFrame = Instance.new("Frame", ContentScroll); ModFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", ModFrame)
    local s = Instance.new("UIStroke", ModFrame); s.Color = Color3.fromRGB(45,45,45); s.Thickness = 1
    table.insert(moduleFrames, {frame = ModFrame, category = category or "Misc"})
    local Title = Instance.new("TextLabel", ModFrame); Title.Size = UDim2.new(1, -50, 0, 35); Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = name; Title.TextColor3 = Color3.new(1,1,1); Title.Font = TARGET_FONT; Title.TextSize = 14; Title.TextXAlignment = "Left"; Title.BackgroundTransparency = 1
    local Toggle = Instance.new("TextButton", ModFrame); Toggle.Size = UDim2.new(0, 45, 0, 22); Toggle.Position = UDim2.new(1, -55, 0, 7)
    Toggle.BackgroundColor3 = _G.Cfg[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0); Toggle.Text = ""; Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1,0)
    
    local function RunToggle()
        _G.Cfg[key] = not _G.Cfg[key]
        ShowNotify(name, _G.Cfg[key])
        if key == "SpeedEnabled" and not _G.Cfg[key] then if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end
        if key == "ClickFriendEnabled" and _G.Cfg[key] then StartFriendProcess(false) elseif key == "DeleteFriendEnabled" and _G.Cfg[key] then StartFriendProcess(true) end
        if key == "WorldColorEnabled" and not _G.Cfg[key] then Lighting.Ambient = Color3.fromRGB(128, 128, 128); Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128); Lighting.ExposureCompensation = 0 end
        if key == "FullBrightEnabled" and not _G.Cfg[key] then Lighting.Brightness = 1 end
        SaveConfig() 
    end
    _G.ToggleFuncs[key] = RunToggle
    
    Toggle.MouseButton1Click:Connect(RunToggle)
    task.spawn(function() while task.wait(0.1) do Toggle.BackgroundColor3 = _G.Cfg[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0) end end)
    
    local Inner = Instance.new("ScrollingFrame", ModFrame)
    Inner.Size = UDim2.new(1, -10, 1, -40); Inner.Position = UDim2.new(0, 5, 0, 35); Inner.BackgroundTransparency = 1; Inner.ScrollBarThickness = 2; Inner.CanvasSize = UDim2.new(0, 0, 0, 0); Inner.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local l = Instance.new("UIListLayout", Inner); l.Padding = UDim.new(0, 2)
    local bindKey = key .. "Bind"
    local bF = Instance.new("Frame", Inner); bF.Size = UDim2.new(1, 0, 0, 20); bF.BackgroundTransparency = 1
    local bL = Instance.new("TextLabel", bF); bL.Size = UDim2.new(0.6, 0, 1, 0); bL.Text = "  Bind Key"; bL.TextColor3 = Color3.new(0.7,0.7,0.7); bL.BackgroundTransparency = 1; bL.TextXAlignment = "Left"; bL.TextSize = 12; bL.Font = TARGET_FONT
    local bI = Instance.new("TextBox", bF); bI.Size = UDim2.new(0, 60, 0.9, 0); bI.Position = UDim2.new(1, -65, 0, 0); bI.Text = tostring(_G.Cfg[bindKey]); bI.BackgroundColor3 = Color3.fromRGB(35,35,35); bI.TextColor3 = Color3.new(1,1,1); bI.TextSize = 10; bI.Font = TARGET_FONT
    bI.FocusLost:Connect(function() local inputStr = bI.Text:gsub("%s+", ""); if inputStr == "" or inputStr:lower() == "none" then _G.Cfg[bindKey] = "None" else _G.Cfg[bindKey] = inputStr end; bI.Text = _G.Cfg[bindKey]; SaveConfig() end)
    
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe and UserInputService:GetFocusedTextBox() ~= nil then return end 
        if _G.Cfg[bindKey] ~= "None" and input.UserInputType == Enum.UserInputType.Keyboard then if input.KeyCode.Name:lower() == tostring(_G.Cfg[bindKey]):lower() then RunToggle() end end
    end))
    return Inner
end

local function AddToggle(parent, text, key)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 18); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = "  " .. text; l.TextColor3 = Color3.new(0.6,0.6,0.6); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"; l.TextSize = 12; l.Font = TARGET_FONT
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(0, 30, 0, 12); btn.Position = UDim2.new(1, -40, 0, 3); btn.Text = ""; Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    btn.BackgroundColor3 = _G.Cfg[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
    btn.MouseButton1Click:Connect(function() _G.Cfg[key] = not _G.Cfg[key]; btn.BackgroundColor3 = _G.Cfg[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0); SaveConfig() end)
end

local function AddSlider(parent, text, key)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 18); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = "  " .. text; l.TextColor3 = Color3.new(0.6,0.6,0.6); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"; l.TextSize = 12; l.Font = TARGET_FONT
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0, 45, 0.9, 0); i.Position = UDim2.new(1, -50, 0, 0); i.Text = tostring(_G.Cfg[key]); i.BackgroundColor3 = Color3.fromRGB(40,40,40); i.TextColor3 = Color3.new(1,1,1); i.TextSize = 10; i.Font = TARGET_FONT
    i.FocusLost:Connect(function() local v = tonumber(i.Text); if v then _G.Cfg[key] = v; SaveConfig() end end)
end

local function AddColorBtn(parent, text, key)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, 0, 0, 18); b.Text = "  [COLOR] " .. text; b.BackgroundColor3 = Color3.fromRGB(40, 40, 50); b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = "Left"; b.TextSize = 12; b.Font = TARGET_FONT
    b.MouseButton1Click:Connect(function() curKey = key; CPFrame.Visible = true end)
end

local function IsVisible(targetPart)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char, targetPart.Parent, GeminiGui, ChamsFolder}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil 
end

local function GetTarget()
    local t, d = nil, _G.Cfg.AimbotMaxDistance
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
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
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    if KillauraLockedTarget then
        local eChar = KillauraLockedTarget.Character
        if eChar and eChar:FindFirstChild("HumanoidRootPart") and eChar:FindFirstChild("Humanoid") and eChar.Humanoid.Health > 0 then
            return KillauraLockedTarget
        else
            KillauraLockedTarget = nil
        end
    end

    local t, d = nil, _G.Cfg.KillAuraRange
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and not FriendsList[LowerNameCache[v.Name]] and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local dist = (myPos - v.Character.HumanoidRootPart.Position).Magnitude
            if dist <= d and IsVisible(v.Character.HumanoidRootPart) then 
                d = dist
                t = v 
            end
        end
    end
    KillauraLockedTarget = t
    return t
end

local function CreateStar(position)
    local bgui = Instance.new("BillboardGui", GeminiGui)
    bgui.Size = UDim2.new(_G.Cfg.ParticleSize*0.5,0,_G.Cfg.ParticleSize*0.5,0); bgui.AlwaysOnTop = true
    local p = Instance.new("Part", workspace); p.Size = Vector3.new(0.1,0.1,0.1); p.Transparency = 1; p.CanCollide = false; p.Anchored = true; p.Position = position
    bgui.Adornee = p
    
    local f = Instance.new("TextLabel", bgui)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundTransparency = 1
    f.Text = "★"
    f.TextScaled = true
    f.TextColor3 = _G.Cfg.ParticleColor
    f.Font = Enum.Font.GothamBlack
    
    local tI = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local rX = math.random(-8, 8); local rY = math.random(-1, 1); local rZ = math.random(-8, 8)
    
    TweenService:Create(p, tI, {Position = p.Position + Vector3.new(rX, rY, rZ)}):Play()
    TweenService:Create(f, tI, {TextTransparency = 1, Rotation = math.random(-180, 180)}):Play()
    task.delay(0.6, function() p:Destroy(); bgui:Destroy() end)
end

local function CreateJumpCircle(pos)
    if not _G.Cfg.JumpVisualCirclesEnabled then return end
    local p = Instance.new("Part", workspace); p.Shape = Enum.PartType.Cylinder; p.Size = Vector3.new(0.1, 0, 0); p.CFrame = CFrame.new(pos - Vector3.new(0, 2.9, 0)) * CFrame.Angles(0, 0, math.rad(90)); p.Transparency = 0.5; p.Anchored = true; p.CanCollide = false; p.Material = Enum.Material.Neon; p.Color = _G.Cfg.JumpCircleEffectColor
    local tI = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(p, tI, {Size = Vector3.new(0.1, _G.Cfg.JumpCircleMaximumSize, _G.Cfg.JumpCircleMaximumSize), Transparency = 1}):Play()
    task.delay(0.8, function() p:Destroy() end)
end

local HatPart = Instance.new("Part", workspace); HatPart.Name = "Gemini_ChinaHat"; HatPart.CanCollide = false; HatPart.Anchored = true; HatPart.Transparency = 1
local HatMesh = Instance.new("SpecialMesh", HatPart); HatMesh.MeshType = "FileMesh"; HatMesh.MeshId = "rbxassetid://1033714"

local TargetHUD = Instance.new("Frame", GeminiGui)
TargetHUD.Size = UDim2.new(0, 220, 0, 70) 
TargetHUD.Position = _G.Cfg.TargetHudPosition
TargetHUD.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
TargetHUD.BackgroundTransparency = 0.05 
TargetHUD.Visible = false
TargetHUD.Active = true
TargetHUD.Draggable = true 

TargetHUD.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        _G.Cfg.TargetHudPosition = TargetHUD.Position
        SaveConfig()
    end
end)

local TargetHUD_Glow = Instance.new("Frame", TargetHUD)
TargetHUD_Glow.Size = UDim2.new(1, 4, 1, 4)
TargetHUD_Glow.Position = UDim2.new(0, -2, 0, -2)
TargetHUD_Glow.BackgroundColor3 = Color3.fromRGB(0, 255, 255) 
TargetHUD_Glow.BackgroundTransparency = 0.8
TargetHUD_Glow.ZIndex = TargetHUD.ZIndex - 1
Instance.new("UICorner", TargetHUD_Glow).CornerRadius = UDim.new(0, 15)

local cornerHUD = Instance.new("UICorner", TargetHUD)
cornerHUD.CornerRadius = UDim.new(0, 12)

local strokeHUD = Instance.new("UIStroke", TargetHUD)
strokeHUD.Color = Color3.new(0, 0, 0)
strokeHUD.Thickness = 2
strokeHUD.Transparency = 0

local glowGradientBack = Instance.new("UIGradient", TargetHUD_Glow)
glowGradientBack.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))})
glowGradientBack.Rotation = 45

local TargetIconContainer = Instance.new("Frame", TargetHUD)
TargetIconContainer.Size = UDim2.new(0, 54, 0, 54)
TargetIconContainer.Position = UDim2.new(0, 8, 0, 8)
TargetIconContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TargetIconContainer.ClipsDescendants = true
Instance.new("UICorner", TargetIconContainer).CornerRadius = UDim.new(0, 6)

local TargetIcon = Instance.new("ImageLabel", TargetIconContainer)
TargetIcon.Size = UDim2.new(1.2, 0, 1.2, 0) 
TargetIcon.Position = UDim2.new(-0.1, 0, -0.1, 0)
TargetIcon.BackgroundTransparency = 1
TargetIcon.ScaleType = Enum.ScaleType.Crop

local TargetName = Instance.new("TextLabel", TargetHUD)
TargetName.Size = UDim2.new(1, -75, 0, 20)
TargetName.Position = UDim2.new(0, 70, 0, 8)
TargetName.BackgroundTransparency = 1
TargetName.TextColor3 = Color3.new(1, 1, 1)
TargetName.Text = "No Target"
TargetName.Font = Enum.Font.GothamBold
TargetName.TextSize = 16
TargetName.TextXAlignment = Enum.TextXAlignment.Left

local HealthText = Instance.new("TextLabel", TargetHUD)
HealthText.Size = UDim2.new(1, -75, 0, 16)
HealthText.Position = UDim2.new(0, 70, 0, 28)
HealthText.BackgroundTransparency = 1
HealthText.TextColor3 = Color3.new(1, 1, 1)
HealthText.Text = "HP: 100.0"
HealthText.TextSize = 14
HealthText.Font = Enum.Font.GothamBold
HealthText.TextXAlignment = Enum.TextXAlignment.Left

local HealthBack = Instance.new("Frame", TargetHUD)
HealthBack.Size = UDim2.new(1, -78, 0, 10)
HealthBack.Position = UDim2.new(0, 70, 0, 50)
HealthBack.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", HealthBack).CornerRadius = UDim.new(0, 5)
local strokeHB = Instance.new("UIStroke", HealthBack)
strokeHB.Color = Color3.fromRGB(60, 60, 60)
strokeHB.Thickness = 1

local HealthBar = Instance.new("Frame", HealthBack)
HealthBar.Size = UDim2.new(1, 0, 1, 0)
HealthBar.BackgroundColor3 = Color3.new(1, 1, 1)
HealthBar.BorderSizePixel = 0
Instance.new("UICorner", HealthBar).CornerRadius = UDim.new(0, 5)
local barGradient = Instance.new("UIGradient", HealthBar)

local lastTargetUserId = nil
local lastTargetHealth = nil
local lastDamageTimeHUD = 0
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local currentTween = nil

local ESPMain = Instance.new("Frame", GeminiGui)
ESPMain.BackgroundTransparency = 1; ESPMain.AnchorPoint = Vector2.new(0.5, 0.5); ESPMain.Visible = false

local function CreateCorner(name, pos)
    local corner = Instance.new("Frame", ESPMain); corner.Size = UDim2.new(0.3, 0, 0.3, 0); corner.Position = pos; corner.BackgroundTransparency = 1
    local hL = Instance.new("Frame", corner); hL.BorderSizePixel = 0; hL.ZIndex = 6; hL.Size = UDim2.new(1, 0, 0, 0); hL.Position = (name:find("B")) and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 0, 0)
    local vL = Instance.new("Frame", corner); vL.BorderSizePixel = 0; vL.ZIndex = 6; vL.Size = UDim2.new(0, 0, 1, 0); vL.Position = (name:find("R")) and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
    local hS = Instance.new("UIStroke", hL); hS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local vS = Instance.new("UIStroke", vL); vS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local hLG1 = Instance.new("Frame", corner); hLG1.BorderSizePixel = 0; hLG1.ZIndex = 5; hLG1.Size = UDim2.new(1, 0, 0, 0); hLG1.Position = hL.Position
    local vLG1 = Instance.new("Frame", corner); vLG1.BorderSizePixel = 0; vLG1.ZIndex = 5; vLG1.Size = UDim2.new(0, 0, 1, 0); vLG1.Position = vL.Position
    local hSG1 = Instance.new("UIStroke", hLG1); hSG1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; hSG1.Transparency = 0.55
    local vSG1 = Instance.new("UIStroke", vLG1); vSG1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; vSG1.Transparency = 0.55
    local hLG2 = Instance.new("Frame", corner); hLG2.BorderSizePixel = 0; hLG2.ZIndex = 4; hLG2.Size = UDim2.new(1, 0, 0, 0); hLG2.Position = hL.Position
    local vLG2 = Instance.new("Frame", corner); vLG2.BorderSizePixel = 0; vLG2.ZIndex = 4; vLG2.Size = UDim2.new(0, 0, 1, 0); vLG2.Position = vL.Position
    local hSG2 = Instance.new("UIStroke", hLG2); hSG2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; hSG2.Transparency = 0.8
    local vSG2 = Instance.new("UIStroke", vLG2); vSG2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; vSG2.Transparency = 0.8
    return {hL, vL, hS, vS, hSG1, vSG1, hSG2, vSG2}
end
local corners = {CreateCorner("TL", UDim2.new(0,0,0,0)), CreateCorner("TR", UDim2.new(0.7,0,0,0)), CreateCorner("BL", UDim2.new(0,0,0.7,0)), CreateCorner("BR", UDim2.new(0.7,0,0.7,0))}

local lastAttackTime = 0
local lastStrafeJumpTime = 0
local nextStrafeJumpDelay = math.random(1, 8) / 10 
local currentKaStrafeDir = 1
local nextKaStrafeDirChange = 0

local lastEspTargetUserId = nil
local lastEspTargetHealth = nil
local lastDamageTimeESP = 0
local lastRenderedEspThickness = nil

table.insert(Connections, RunService.Stepped:Connect(function()
    if _G.Cfg.NoClipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if OrigNoClipStates[part] == nil then
                    OrigNoClipStates[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    elseif not _G.Cfg.NoClipEnabled and LocalPlayer.Character then
        if next(OrigNoClipStates) ~= nil then
            for part, state in pairs(OrigNoClipStates) do
                if part and part.Parent then
                    part.CanCollide = state
                end
            end
            table.clear(OrigNoClipStates)
        end
    end
end))

task.spawn(function()
    while task.wait(0.2) do
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
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
                    
                    local partsList = PlayerPartsCache[plChar]
                    if not partsList then
                        partsList = {}
                        for _, p in ipairs(plChar:GetChildren()) do if p:IsA("BasePart") then table.insert(partsList, p) end end
                        PlayerPartsCache[plChar] = partsList
                    end
                    
                    for _, part in ipairs(partsList) do
                        if not OrigPartData[part] then OrigPartData[part] = {Size = part.Size, CanCollide = part.CanCollide, Massless = part.Massless} end
                        local origData = OrigPartData[part]
                        local targetSize = isHitboxActive and (origData.Size * mult) or origData.Size
                        
                        if part.Size ~= targetSize then
                            part.Size = targetSize
                            if isHitboxActive then part.CanCollide = false; part.Massless = true else part.CanCollide = origData.CanCollide; part.Massless = origData.Massless end
                        end
                    end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    local esp2D = Esp2DFolder:FindFirstChild(plr.Name .. "_2DBox")
    if esp2D then esp2D:Destroy() end
    local esp3D = Chams3DFolder:FindFirstChild(plr.Name .. "_3DBox")
    if esp3D then esp3D:Destroy() end
end)

table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
    local target = GetTarget() 
    local char = LocalPlayer.Character
    local currentKaTarget = nil
    if _G.Cfg.KillAuraEnabled then currentKaTarget = GetKillauraTarget() else KillauraLockedTarget = nil end
    SharedKaTarget = currentKaTarget 

    local hudTarget = target; if _G.Cfg.TargetHudOnlyKillaura then hudTarget = currentKaTarget end
    local espTarget = target; if _G.Cfg.TargetESPOnlyKillaura then espTarget = currentKaTarget end

    if _G.Cfg.CustomFovEnabled then Camera.FieldOfView = _G.Cfg.CustomFovValue else Camera.FieldOfView = _G.Cfg.AspectRatioValue end
    if _G.Cfg.TimeChangerEnabled then Lighting.ClockTime = math.clamp(_G.Cfg.TimeChangerHours, 0, 23) end
    if _G.Cfg.FullBrightEnabled then Lighting.Brightness = math.clamp(_G.Cfg.FullBrightBrightness, 0, 10) end
    
    local rotationSpeed = (tick() * 35) % 360
    if glowGradientBack then glowGradientBack.Rotation = rotationSpeed end
    
    if _G.Cfg.WorldParticlesEnabled then
        WorldStarsContainer.Visible = true
        local camPos = Camera.CFrame.Position
        local dtSafe = dt or 0.016 
        
        for _, star in ipairs(StarsData) do
            star.pos = star.pos + star.drift * dtSafe
            
            local diff = star.pos - camPos
            local wx = (diff.X + STAR_RANGE) % (STAR_RANGE * 2) - STAR_RANGE
            local wy = (diff.Y + STAR_RANGE) % (STAR_RANGE * 2) - STAR_RANGE
            local wz = (diff.Z + STAR_RANGE) % (STAR_RANGE * 2) - STAR_RANGE
            star.pos = camPos + Vector3.new(wx, wy, wz)
            
            local screenPos, onScreen = Camera:WorldToViewportPoint(star.pos)
            
            if onScreen and screenPos.Z > 1 and screenPos.Z < STAR_RANGE then
                star.gui.Visible = true
                local scale = math.clamp(50 / screenPos.Z, 0.1, 2)
                local currentSize = star.size * scale
                
                star.gui.Size = UDim2.fromOffset(currentSize, currentSize)
                star.gui.Position = UDim2.fromOffset(screenPos.X - currentSize/2, screenPos.Y - currentSize/2)
                star.gui.Rotation = star.gui.Rotation + star.rotSpeed * dtSafe
                star.gui.TextColor3 = _G.Cfg.WorldParticlesColor
                
                local fade = 1 - math.clamp(screenPos.Z / STAR_RANGE, 0, 1)
                star.gui.TextTransparency = 1 - (fade ^ 1.5)
            else
                star.gui.Visible = false
            end
        end
    else
        WorldStarsContainer.Visible = false
    end

    if _G.Cfg.SpeedEnabled and char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = _G.Cfg.WalkSpeedValue end

    if _G.Cfg.StrafeEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        local rootPart = char.HumanoidRootPart
        if hum.MoveDirection.Magnitude > 0 then
            local currentSpeed = _G.Cfg.SpeedEnabled and _G.Cfg.WalkSpeedValue or hum.WalkSpeed
            local instantVel = hum.MoveDirection.Unit * currentSpeed
            rootPart.AssemblyLinearVelocity = Vector3.new(instantVel.X, rootPart.AssemblyLinearVelocity.Y, instantVel.Z)
        else
            rootPart.AssemblyLinearVelocity = Vector3.new(0, rootPart.AssemblyLinearVelocity.Y, 0)
        end
    end

    if _G.Cfg.SpiderEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local hrp = char.HumanoidRootPart
            local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {char, ChamsFolder, Chams3DFolder}; rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local dirs = {hrp.CFrame.LookVector, -hrp.CFrame.LookVector, hrp.CFrame.RightVector, -hrp.CFrame.RightVector}
            local touching = false
            for _, dir in ipairs(dirs) do
                local ray1 = workspace:Raycast(hrp.Position, dir * 2.5, rayParams)
                local ray2 = workspace:Raycast(hrp.Position + Vector3.new(0, 1, 0), dir * 2.5, rayParams)
                local ray3 = workspace:Raycast(hrp.Position - Vector3.new(0, 1, 0), dir * 2.5, rayParams)
                local function checkRay(r) return r and r.Instance and r.Instance:IsA("BasePart") and r.Instance.CanCollide end
                if checkRay(ray1) or checkRay(ray2) or checkRay(ray3) then touching = true; break end
            end
            if touching then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, tonumber(_G.Cfg.SpiderSpeed) or 45, hrp.AssemblyLinearVelocity.Z) end
        end
    end

    if _G.Cfg.WorldColorEnabled then
        local baseColor = _G.Cfg.WorldColorValue
        local trans = math.clamp(_G.Cfg.WorldColorTransparency, 0, 1)
        local dark = math.clamp(_G.Cfg.WorldColorDarkness, 0, 5)
        local defaultAmbient = Color3.fromRGB(128, 128, 128)
        local blendedColor = defaultAmbient:Lerp(baseColor, trans)
        Lighting.Ambient = blendedColor; Lighting.OutdoorAmbient = blendedColor; Lighting.ExposureCompensation = -dark
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local plChar = player.Character
            local lowerName = LowerNameCache[player.Name]
            local isFriend = FriendsList[lowerName]
            local boxESP = Chams3DFolder:FindFirstChild(player.Name .. "_3DBox")
            local esp2DBox = Esp2DFolder:FindFirstChild(player.Name .. "_2DBox")

            if isFriend then
                if boxESP then boxESP:Destroy() end
                local friendHighlight = plChar and plChar:FindFirstChild("FriendHighlight")
                if not friendHighlight and plChar then
                    friendHighlight = Instance.new("Highlight", plChar)
                    friendHighlight.Name = "FriendHighlight"; friendHighlight.FillColor = Color3.fromRGB(0, 255, 0); friendHighlight.OutlineColor = Color3.fromRGB(0, 200, 0); friendHighlight.FillTransparency = 0.8; friendHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
                end
            elseif _G.Cfg.ChamsEnabled and plChar and plChar:FindFirstChild("HumanoidRootPart") then
                if plChar:FindFirstChild("FriendHighlight") then plChar.FriendHighlight:Destroy() end
                if not boxESP then 
                    boxESP = Instance.new("Part", Chams3DFolder)
                    boxESP.Name = player.Name .. "_3DBox"; boxESP.Size = Vector3.new(4.5, 6, 1.5); boxESP.Transparency = 1; boxESP.CanCollide = false; boxESP.Anchored = true
                    local hl = Instance.new("Highlight", boxESP)
                    hl.Name = "HL"; hl.Adornee = boxESP; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                boxESP.CFrame = plChar.HumanoidRootPart.CFrame
                local hl = boxESP.HL; hl.FillColor = _G.Cfg.ChamsColor; hl.OutlineColor = _G.Cfg.ChamsOutlineColor; hl.FillTransparency = _G.Cfg.ChamsFillTransparency; hl.OutlineTransparency = 0
            else 
                if boxESP then boxESP:Destroy() end
                if plChar and plChar:FindFirstChild("FriendHighlight") then plChar.FriendHighlight:Destroy() end
            end

            if _G.Cfg.Esp2DBoxEnabled and plChar and plChar:FindFirstChild("HumanoidRootPart") and not isFriend then
                local hrp = plChar.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    if not esp2DBox then
                        esp2DBox = Instance.new("Frame", Esp2DFolder)
                        esp2DBox.Name = player.Name .. "_2DBox"; esp2DBox.BackgroundTransparency = 1
                        Instance.new("UICorner", esp2DBox).CornerRadius = UDim.new(0, 4)
                        local mainStroke = Instance.new("UIStroke", esp2DBox)
                        mainStroke.Name = "MainStroke"; mainStroke.Thickness = 1.5; mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        local grad = Instance.new("UIGradient", mainStroke)
                        grad.Name = "StrokeGradient"; grad.Rotation = 45
                        local glowFrame = Instance.new("Frame", esp2DBox)
                        glowFrame.Size = UDim2.new(1, 0, 1, 0); glowFrame.BackgroundTransparency = 1; Instance.new("UICorner", glowFrame).CornerRadius = UDim.new(0, 4)
                        local outerGlow = Instance.new("UIStroke", glowFrame)
                        outerGlow.Name = "OuterGlow"; outerGlow.Thickness = 5; outerGlow.Transparency = 0.7; outerGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        
                        local nameTag = Instance.new("TextLabel", esp2DBox)
                        nameTag.Name = "Nametag"
                        nameTag.BackgroundTransparency = 1
                        nameTag.Font = TARGET_FONT
                        nameTag.TextColor3 = Color3.new(1, 1, 1)
                        nameTag.TextStrokeTransparency = 0
                        
                        local hbBack = Instance.new("Frame", esp2DBox)
                        hbBack.Name = "HealthBarBack"
                        hbBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        hbBack.BorderColor3 = Color3.new(0, 0, 0)
                        
                        local hbFill = Instance.new("Frame", hbBack)
                        hbFill.Name = "HealthBarFill"
                        hbFill.BorderSizePixel = 0
                        hbFill.BackgroundColor3 = Color3.new(1, 1, 1)
                        hbFill.ClipsDescendants = true
                        
                        local hbGradientFrame = Instance.new("Frame", hbFill)
                        hbGradientFrame.Name = "GradientFrame"
                        hbGradientFrame.BorderSizePixel = 0
                        hbGradientFrame.BackgroundColor3 = Color3.new(1, 1, 1)
                        
                        local hbGrad = Instance.new("UIGradient", hbGradientFrame)
                        hbGrad.Name = "HealthBarGradient"
                        hbGrad.Rotation = 90
                        hbGrad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        })
                    end
                    
                    local head = plChar:FindFirstChild("Head")
                    local topPos = head and head.Position + Vector3.new(0, 1, 0) or hrp.Position + Vector3.new(0, 3, 0)
                    local bottomPos = hrp.Position - Vector3.new(0, 3.5, 0)
                    local topScreen = Camera:WorldToViewportPoint(topPos); local bottomScreen = Camera:WorldToViewportPoint(bottomPos)
                    local height = math.abs(bottomScreen.Y - topScreen.Y)
                    local baseMultiplier = tonumber(_G.Cfg.Esp2DBoxSize) or 1
                    local finalHeight = height * baseMultiplier
                    local width = (height / 1.5) * baseMultiplier 
                    
                    esp2DBox.Size = UDim2.new(0, width, 0, finalHeight)
                    esp2DBox.Position = UDim2.new(0, pos.X - width/2, 0, pos.Y - finalHeight/2)
                    
                    local mainStroke = esp2DBox:FindFirstChild("MainStroke")
                    if mainStroke then 
                        mainStroke.Color = _G.Cfg.Esp2DBoxColor 
                        local grad = mainStroke:FindFirstChild("StrokeGradient")
                        if grad then
                            grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, _G.Cfg.Esp2DBoxColor), ColorSequenceKeypoint.new(1, Color3.new(1,1,1):Lerp(_G.Cfg.Esp2DBoxColor, 0.5))})
                            grad.Rotation = (tick() * 50) % 360 
                        end
                    end
                    local glowFrame = esp2DBox:FindFirstChildOfClass("Frame")
                    if glowFrame and glowFrame.Name ~= "HealthBarBack" then 
                        local outerGlow = glowFrame:FindFirstChild("OuterGlow"); 
                        if outerGlow then outerGlow.Color = _G.Cfg.Esp2DBoxColor end 
                    end
                    
                    local nameTag = esp2DBox:FindFirstChild("Nametag")
                    if nameTag then
                        nameTag.Visible = _G.Cfg.Esp2DBoxNametagsEnabled == true
                        if _G.Cfg.Esp2DBoxNametagsEnabled then
                            nameTag.TextSize = tonumber(_G.Cfg.Esp2DBoxNametagsScale) or 14
                            nameTag.Size = UDim2.new(1, 0, 0, nameTag.TextSize)
                            nameTag.Position = UDim2.new(0, 0, 0, -nameTag.TextSize - 5)
                            nameTag.Text = player.DisplayName
                        end
                    end
                    
                    local hbBack = esp2DBox:FindFirstChild("HealthBarBack")
                    if hbBack then
                        hbBack.Visible = _G.Cfg.Esp2DBoxHealthBarEnabled == true
                        if _G.Cfg.Esp2DBoxHealthBarEnabled then
                            local border = tonumber(_G.Cfg.Esp2DBoxHealthBarBorder) or 1
                            hbBack.BorderSizePixel = border
                            hbBack.Size = UDim2.new(0, 4, 1, 0)
                            hbBack.Position = UDim2.new(0, -(6 + border), 0, 0)
                            
                            local hbFill = hbBack:FindFirstChild("HealthBarFill")
                            local hum = plChar:FindFirstChild("Humanoid")
                            if hbFill and hum then
                                local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0.01, 1)
                                hbFill.Size = UDim2.new(1, 0, hpPercent, 0)
                                hbFill.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
                                
                                local gradFrame = hbFill:FindFirstChild("GradientFrame")
                                if gradFrame then
                                    gradFrame.Size = UDim2.new(1, 0, 1 / hpPercent, 0)
                                    gradFrame.Position = UDim2.new(0, 0, -((1 - hpPercent) / hpPercent), 0)
                                end
                            end
                        end
                    end
                    
                    esp2DBox.Visible = true
                else
                    if esp2DBox then esp2DBox.Visible = false end
                end
            else
                if esp2DBox then esp2DBox.Visible = false end
            end
        end
    end
    
    if _G.Cfg.ChinaHatAccessoryEnabled and char and char:FindFirstChild("Head") then
        HatPart.Transparency = _G.Cfg.ChinaHatTransparency; HatPart.Color = _G.Cfg.ChinaHatAccessoryColor; HatMesh.Scale = Vector3.new(_G.Cfg.ChinaHatWidthScale, _G.Cfg.ChinaHatHeightScale, _G.Cfg.ChinaHatWidthScale); HatPart.CFrame = char.Head.CFrame * CFrame.new(0, _G.Cfg.ChinaHatHeightOffset, 0)
    else HatPart.Transparency = 1 end

    if _G.Cfg.TargetHudEnabled and hudTarget and hudTarget.Character and hudTarget.Character:FindFirstChild("Humanoid") then
        TargetHUD.Visible = true
        local hum = hudTarget.Character.Humanoid
        
        if lastTargetUserId ~= hudTarget.UserId then
            lastTargetUserId = hudTarget.UserId; TargetName.Text = hudTarget.DisplayName; TargetIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. hudTarget.UserId .. "&w=150&h=150"; lastTargetHealth = hum.Health 
            local initialHealthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            HealthBar.Size = UDim2.new(initialHealthPercent, 0, 1, 0); lastDamageTimeHUD = 0
            TargetIcon.ImageColor3 = Color3.new(1, 1, 1)
        end

        local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        if lastTargetHealth and hum.Health < lastTargetHealth then 
            lastDamageTimeHUD = tick()
            TargetIcon.ImageColor3 = _G.Cfg.TargetHudDamageColor or Color3.fromRGB(255, 0, 0)
            TweenService:Create(TargetIcon, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {ImageColor3 = Color3.new(1, 1, 1)}):Play()
        end
        
        lastTargetHealth = hum.Health
        local normColor = _G.Cfg.TargetHudNormalColor or Color3.fromRGB(0, 255, 100); local dmgColor = _G.Cfg.TargetHudDamageColor or Color3.fromRGB(255, 0, 0)
        
        local currentBarColor = normColor
        local timeSinceDmgHud = tick() - lastDamageTimeHUD
        if timeSinceDmgHud < 0.3 then
            currentBarColor = dmgColor:Lerp(normColor, timeSinceDmgHud / 0.3)
        end
        
        barGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, currentBarColor:Lerp(Color3.new(0, 0, 0), 0.2)), ColorSequenceKeypoint.new(1, currentBarColor)})
        
        if currentTween then currentTween:Cancel() end 
        currentTween = TweenService:Create(HealthBar, tweenInfo, {Size = UDim2.new(healthPercent, 0, 1, 0)}); currentTween:Play()
        HealthText.Text = string.format("HP: %.1f", hum.Health)
    else
        TargetHUD.Visible = false; lastTargetUserId = nil; lastTargetHealth = nil
        if currentTween then currentTween:Cancel() end 
    end

    if _G.Cfg.TargetESPSquareEnabled and espTarget and espTarget.Character:FindFirstChild("HumanoidRootPart") then
        local espHum = espTarget.Character:FindFirstChild("Humanoid")
        if espHum then
            if lastEspTargetUserId ~= espTarget.UserId then
                lastEspTargetUserId = espTarget.UserId; lastEspTargetHealth = espHum.Health; lastDamageTimeESP = 0
            end
            if lastEspTargetHealth and espHum.Health < lastEspTargetHealth then
                lastDamageTimeESP = tick()
            end
            lastEspTargetHealth = espHum.Health
        end

        local currentEspColor = _G.Cfg.TargetESPSquareColor
        if _G.Cfg.TargetESPDamageColorEnabled then
            local timeSinceDmgEsp = tick() - lastDamageTimeESP
            if timeSinceDmgEsp < 0.6 then
                currentEspColor = _G.Cfg.TargetESPDamageColor:Lerp(_G.Cfg.TargetESPSquareColor, timeSinceDmgEsp / 0.6)
            end
        end

        local pos, onScreen = Camera:WorldToViewportPoint(espTarget.Character.HumanoidRootPart.Position)
        if onScreen then
            ESPMain.Visible = true; ESPMain.Position = UDim2.new(0, pos.X, 0, pos.Y); ESPMain.Size = UDim2.new(0, _G.Cfg.TargetESPSquareSize, 0, _G.Cfg.TargetESPSquareSize); ESPMain.Rotation = (tick() * 60 * _G.Cfg.TargetESPRotationSpeed) % 360 
            
            local updateThickness = false
            if lastRenderedEspThickness ~= _G.Cfg.TargetESPBorderThickness then
                updateThickness = true
                lastRenderedEspThickness = _G.Cfg.TargetESPBorderThickness
            end

            for _, c in pairs(corners) do 
                if updateThickness then
                    c[3].Thickness = _G.Cfg.TargetESPBorderThickness; c[4].Thickness = _G.Cfg.TargetESPBorderThickness;
                    c[5].Thickness = _G.Cfg.TargetESPBorderThickness + 4.5; c[6].Thickness = _G.Cfg.TargetESPBorderThickness + 4.5;
                    c[7].Thickness = _G.Cfg.TargetESPBorderThickness + 11; c[8].Thickness = _G.Cfg.TargetESPBorderThickness + 11;
                end
                c[3].Color = currentEspColor; c[4].Color = currentEspColor 
                c[5].Color = currentEspColor; c[6].Color = currentEspColor
                c[7].Color = currentEspColor; c[8].Color = currentEspColor
            end
        else ESPMain.Visible = false end
    else 
        ESPMain.Visible = false 
        lastEspTargetUserId = nil
        lastEspTargetHealth = nil
    end

    if _G.Cfg.TargetStrafeOrbitEnabled and target and target.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
        local angle = tick() * _G.Cfg.TargetStrafeOrbitSpeed; local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * _G.Cfg.TargetStrafeOrbitRadius; char.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + offset, target.Character.HumanoidRootPart.Position)
    end

    local didKillAura = false
    
    if _G.Cfg.KillAuraEnabled and char and char:FindFirstChild("HumanoidRootPart") then
        local kaTarget = currentKaTarget
        if kaTarget and kaTarget.Character and kaTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = kaTarget.Character.HumanoidRootPart
            local dist = (char.HumanoidRootPart.Position - targetPart.Position).Magnitude
            
            if dist <= _G.Cfg.KillAuraRange and IsVisible(targetPart) then
                didKillAura = true
                
                if _G.Cfg.KillStrafeEnabled and char:FindFirstChild("Humanoid") then
                    local flatToTarget = Vector3.new(targetPart.Position.X - char.HumanoidRootPart.Position.X, 0, targetPart.Position.Z - char.HumanoidRootPart.Position.Z)
                    local distFlat = flatToTarget.Magnitude
                    if distFlat > 0.1 then
                        if tick() > nextKaStrafeDirChange then currentKaStrafeDir = -currentKaStrafeDir; nextKaStrafeDirChange = tick() + (math.random(40, 90) / 100) end
                        
                        local dirToTarget = flatToTarget.Unit
                        local rightDir = dirToTarget:Cross(Vector3.new(0, 1, 0)).Unit * currentKaStrafeDir
                        local noise = math.sin(tick() * 4) * 0.3
                        
                        local currentOrbitDist = tonumber(_G.Cfg.KillStrafeDistance) or 1
                        local distanceError = distFlat - (currentOrbitDist + noise)
                        
                        local moveDir = (dirToTarget * distanceError + rightDir * 3).Unit
                        
                        char.Humanoid:Move(moveDir, false)
                        local kStrafeSpeed = tonumber(_G.Cfg.KillStrafeSpeed) or 20
                        char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(moveDir.X * kStrafeSpeed, char.HumanoidRootPart.AssemblyLinearVelocity.Y, moveDir.Z * kStrafeSpeed)
                        
                        if tick() - lastStrafeJumpTime > nextStrafeJumpDelay then
                            if char.Humanoid.FloorMaterial ~= Enum.Material.Air then char.Humanoid.Jump = true; lastStrafeJumpTime = tick(); nextStrafeJumpDelay = math.random(1, 8) / 10 end
                        end
                    end
                end

                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), _G.Cfg.AimbotSmoothness)
                
                if dist <= (_G.Cfg.KillAuraClickRange or 15) then
                    local attackDelay = (_G.Cfg.KillAuraSpeed / 10)
                    if tick() - lastAttackTime > attackDelay then
                        lastAttackTime = tick()
                        task.spawn(function()
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            task.wait(0.01)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end)
                        if _G.Cfg.KillAuraJump and char.Humanoid.FloorMaterial ~= Enum.Material.Air then char.Humanoid.Jump = true end
                        if _G.Cfg.HitSoundEnabled then
                            local sIdx = math.clamp(math.floor(_G.Cfg.HitSoundMode), 1, 6)
                            local s = Instance.new("Sound", game:GetService("SoundService"))
                            s.SoundId = HitSounds[sIdx]; s.Volume = 2; s:Play(); game:GetService("Debris"):AddItem(s, 1)
                        end
                        if _G.Cfg.DamageParticlesEnabled then
                            local pAmt = tonumber(_G.Cfg.ParticleAmount) or 8
                            for i = 1, pAmt do CreateStar(targetPart.Position) end 
                        end
                    end
                end
            end
        end
    end

    if not didKillAura and _G.Cfg.AimbotEnabled and target and target.Character and target.Character:FindFirstChild("Head") and char and char:FindFirstChild("HumanoidRootPart") then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), _G.Cfg.AimbotSmoothness)
    end
end))

local BindListFrame = Instance.new("Frame", GeminiGui)
BindListFrame.Size = UDim2.new(0, 180, 0, 30); BindListFrame.Position = _G.Cfg.BindListPosition; BindListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); BindListFrame.Visible = false
Instance.new("UICorner", BindListFrame).CornerRadius = UDim.new(0, 6)
local BLStroke = Instance.new("UIStroke", BindListFrame); BLStroke.Color = Color3.fromRGB(60, 60, 60); BLStroke.Thickness = 1.5

local BLTitle = Instance.new("TextLabel", BindListFrame)
BLTitle.Size = UDim2.new(1, 0, 0, 25); BLTitle.Text = "Keybind List"; BLTitle.TextColor3 = Color3.new(1, 1, 1); BLTitle.Font = TARGET_FONT; BLTitle.TextSize = 14; BLTitle.BackgroundTransparency = 1

local BLContainer = Instance.new("Frame", BindListFrame)
BLContainer.Size = UDim2.new(1, -10, 1, -30); BLContainer.Position = UDim2.new(0, 5, 0, 25); BLContainer.BackgroundTransparency = 1
local BLLayout = Instance.new("UIListLayout", BLContainer); BLLayout.Padding = UDim.new(0, 2)

local dragging, dragInput, dragStart, startPos
BindListFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = BindListFrame.Position end
end)
BindListFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        BindListFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then 
        if dragging then dragging = false; _G.Cfg.BindListPosition = BindListFrame.Position; SaveConfig() end
    end
end)

local function UpdateKeybindList()
    for _, child in pairs(BLContainer:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    
    local activeCount = 0
    local modules = {
        "AimbotEnabled", "KillAuraEnabled", "HitboxEnabled", "SpeedEnabled", "StrafeEnabled", "NoClipEnabled", "SpiderEnabled",
        "HitSoundEnabled", "TargetHudEnabled", "TargetESPSquareEnabled", "Esp2DBoxEnabled",
        "TargetStrafeOrbitEnabled", "ChinaHatAccessoryEnabled", 
        "JumpVisualCirclesEnabled", "ChamsEnabled", "DamageParticlesEnabled", "WorldParticlesEnabled",
        "ClickFriendEnabled", "DeleteFriendEnabled", "WorldColorEnabled", "CustomFovEnabled", "TimeChangerEnabled", "FullBrightEnabled"
    }
    
    for _, key in ipairs(modules) do
        local bindKey = key .. "Bind"
        if _G.Cfg[key] == true and _G.Cfg[bindKey] ~= "None" then
            activeCount = activeCount + 1
            local label = Instance.new("TextLabel", BLContainer)
            label.Size = UDim2.new(1, 0, 0, 18); label.BackgroundTransparency = 1; label.Text = " " .. key:gsub("Enabled", ""):upper() .. " [" .. tostring(_G.Cfg[bindKey]):upper() .. "]"
            label.TextColor3 = Color3.fromRGB(200, 200, 200); label.TextSize = 13; label.Font = TARGET_FONT; label.TextXAlignment = Enum.TextXAlignment.Left
        end
    end
    
    BindListFrame.Visible = activeCount > 0
    if activeCount > 0 then BindListFrame.Size = UDim2.new(0, 180, 0, 30 + (activeCount * 20)) end
end

local MobileButtonsFrame = Instance.new("Frame", GeminiGui)
MobileButtonsFrame.Size = UDim2.new(1, 0, 1, 0)
MobileButtonsFrame.BackgroundTransparency = 1
MobileButtonsFrame.Visible = isMobile
MobileButtonsFrame.ZIndex = 50

local globalMobileDragging = false

local function UpdateMobileBinds()
    if not isMobile then return end
    
    local modulesList = {
        "AimbotEnabled", "KillAuraEnabled", "HitboxEnabled", "SpeedEnabled", "StrafeEnabled", "NoClipEnabled", "SpiderEnabled",
        "HitSoundEnabled", "TargetHudEnabled", "TargetESPSquareEnabled", "Esp2DBoxEnabled",
        "TargetStrafeOrbitEnabled", "ChinaHatAccessoryEnabled", 
        "JumpVisualCirclesEnabled", "ChamsEnabled", "DamageParticlesEnabled", "WorldParticlesEnabled",
        "ClickFriendEnabled", "DeleteFriendEnabled", "WorldColorEnabled", "CustomFovEnabled", "TimeChangerEnabled", "FullBrightEnabled"
    }
    
    local activeModules = {}
    for _, key in ipairs(modulesList) do
        local bindKey = key .. "Bind"
        if _G.Cfg[bindKey] and tostring(_G.Cfg[bindKey]) ~= "None" then
            activeModules[key] = tostring(_G.Cfg[bindKey]):upper()
        end
    end
    
    for _, child in pairs(MobileButtonsFrame:GetChildren()) do
        if not activeModules[child.Name] then
            child:Destroy()
        end
    end
    
    for key, bindLetter in pairs(activeModules) do
        local btn = MobileButtonsFrame:FindFirstChild(key)
        if not btn then
            btn = Instance.new("TextButton", MobileButtonsFrame)
            btn.Name = key
            btn.Size = UDim2.new(0, 50, 0, 50)
            
            local savedPos = _G.Cfg["MobilePos_"..key]
            if savedPos then
                btn.Position = UDim2.new(savedPos.XScale, savedPos.XOffset, savedPos.YScale, savedPos.YOffset)
            else
                btn.Position = UDim2.new(0.8, math.random(-50, 50), 0.5, math.random(-50, 50))
            end
            
            btn.BackgroundColor3 = _G.Cfg[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(35, 35, 35)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = TARGET_FONT
            btn.TextSize = 22
            btn.Text = bindLetter
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            
            local str = Instance.new("UIStroke", btn)
            str.Color = Color3.fromRGB(0, 255, 255)
            str.Thickness = 2
            
            local mDragging = false
            local dragStartPos = nil
            local btnStartPos = nil
            local mDragInput = nil
            local isTap = true
            
            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not globalMobileDragging then
                        globalMobileDragging = true
                        mDragging = true
                        isTap = true
                        dragStartPos = input.Position
                        btnStartPos = btn.Position
                        btn.ZIndex = 100
                    end
                end
            end)
            
            btn.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                    mDragInput = input
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input == mDragInput and mDragging then
                    local delta = input.Position - dragStartPos
                    if delta.Magnitude > 8 then
                        isTap = false
                    end
                    btn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if mDragging then
                        mDragging = false
                        globalMobileDragging = false
                        btn.ZIndex = 1
                        if isTap then
                            if _G.ToggleFuncs[key] then
                                _G.ToggleFuncs[key]()
                            end
                        else
                            _G.Cfg["MobilePos_"..key] = {XScale = btn.Position.X.Scale, XOffset = btn.Position.X.Offset, YScale = btn.Position.Y.Scale, YOffset = btn.Position.Y.Offset, isUDim2 = true}
                            SaveConfig()
                        end
                    end
                end
            end)
        else
            btn.Text = bindLetter
            btn.BackgroundColor3 = _G.Cfg[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(35, 35, 35)
        end
    end
end

task.spawn(function() while task.wait(0.5) do UpdateKeybindList(); UpdateMobileBinds() end end)

local function ConnectJump(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Jumping:Connect(function() if _G.Cfg.JumpVisualCirclesEnabled then CreateJumpCircle(char.HumanoidRootPart.Position) end end)
end
LocalPlayer.CharacterAdded:Connect(ConnectJump); if LocalPlayer.Character then ConnectJump(LocalPlayer.Character) end

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if tick() - lastAttackTime < 0.1 then return end
        local mousePos = UserInputService:GetMouseLocation(); local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y); local res = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
        if res and res.Instance then
            local hitChar = res.Instance:FindFirstAncestorOfClass("Model")
            local p = Players:GetPlayerFromCharacter(hitChar)
            if hitChar and hitChar:FindFirstChildOfClass("Humanoid") and hitChar ~= LocalPlayer.Character and not FriendsList[LowerNameCache[hitChar.Name]] then 
                if _G.Cfg.DamageParticlesEnabled then
                    local pAmt = tonumber(_G.Cfg.ParticleAmount) or 8
                    for i = 1, pAmt do CreateStar(res.Position) end 
                end
                if _G.Cfg.HitSoundEnabled then
                    local sIdx = math.clamp(math.floor(_G.Cfg.HitSoundMode), 1, 6)
                    local sId = HitSounds[sIdx]
                    local s = Instance.new("Sound", game:GetService("SoundService"))
                    s.SoundId = sId; s.Volume = 2; s:Play(); game:GetService("Debris"):AddItem(s, 1)
                end
            end
        end
    end
end)

local mAim = CreateModule("AIMBOT", "AimbotEnabled", "Combat"); AddSlider(mAim, "Smooth", "AimbotSmoothness"); AddSlider(mAim, "MaxDist", "AimbotMaxDistance")
local mKilla = CreateModule("KILL AURA", "KillAuraEnabled", "Combat"); AddToggle(mKilla, "Kill Strafe", "KillStrafeEnabled"); AddSlider(mKilla, "Strafe Speed", "KillStrafeSpeed"); AddSlider(mKilla, "Strafe Distance", "KillStrafeDistance"); AddSlider(mKilla, "Range", "KillAuraRange"); AddSlider(mKilla, "Click Range", "KillAuraClickRange"); AddSlider(mKilla, "Delay (0.1s)", "KillAuraSpeed")
local mHitbox = CreateModule("HITBOX", "HitboxEnabled", "Combat"); AddSlider(mHitbox, "Size Multiplier", "HitboxSize"); AddToggle(mHitbox, "Only Killaura", "HitboxOnlyKillaura");
local mOrb = CreateModule("TARGET STRAFE", "TargetStrafeOrbitEnabled", "Combat"); AddSlider(mOrb, "Radius", "TargetStrafeOrbitRadius"); AddSlider(mOrb, "Speed", "TargetStrafeOrbitSpeed")

local mSpeed = CreateModule("PLAYER SPEED", "SpeedEnabled", "Movement"); AddSlider(mSpeed, "WalkSpeed", "WalkSpeedValue")
local mStrf = CreateModule("HARD STRAFE", "StrafeEnabled", "Movement")
local mNoc = CreateModule("NOCLIP", "NoClipEnabled", "Movement")
local mSpider = CreateModule("SPIDER", "SpiderEnabled", "Movement"); AddSlider(mSpider, "Speed", "SpiderSpeed")

local mHud = CreateModule("TARGET HUD", "TargetHudEnabled", "Visuals"); AddColorBtn(mHud, "Normal HB color", "TargetHudNormalColor"); AddColorBtn(mHud, "Damage HB color", "TargetHudDamageColor"); AddToggle(mHud, "Only Killaura", "TargetHudOnlyKillaura")
local mEsp = CreateModule("Target esp", "TargetESPSquareEnabled", "Visuals"); AddSlider(mEsp, "Size", "TargetESPSquareSize"); AddSlider(mEsp, "Border", "TargetESPBorderThickness"); AddColorBtn(mEsp, "[COLOR] Target ESP", "TargetESPSquareColor"); AddToggle(mEsp, "Damage Color Flash", "TargetESPDamageColorEnabled"); AddColorBtn(mEsp, "[COLOR] Damage Color", "TargetESPDamageColor"); AddToggle(mEsp, "Only Killaura", "TargetESPOnlyKillaura")
local mEsp2D = CreateModule("2D BOX ESP", "Esp2DBoxEnabled", "Visuals"); AddSlider(mEsp2D, "Size Multiplier", "Esp2DBoxSize"); AddColorBtn(mEsp2D, "[COLOR] Box Color", "Esp2DBoxColor"); AddToggle(mEsp2D, "Nametags", "Esp2DBoxNametagsEnabled"); AddSlider(mEsp2D, "Nametags Scale", "Esp2DBoxNametagsScale"); AddToggle(mEsp2D, "Healthbar", "Esp2DBoxHealthBarEnabled"); AddSlider(mEsp2D, "Bar Border", "Esp2DBoxHealthBarBorder")

local mStars = CreateModule("WORLD STARS", "WorldParticlesEnabled", "Visuals"); AddColorBtn(mStars, "[COLOR] Stars Color", "WorldParticlesColor")

local mHat = CreateModule("CHINA HAT", "ChinaHatAccessoryEnabled", "Visuals"); AddSlider(mHat, "Head Offset", "ChinaHatHeightOffset"); AddSlider(mHat, "Width", "ChinaHatWidthScale"); AddSlider(mHat, "Height", "ChinaHatHeightScale"); AddSlider(mHat, "Transparency", "ChinaHatTransparency"); AddColorBtn(mHat, "Hat Color", "ChinaHatAccessoryColor")
local mHit = CreateModule("HIT PARTICLES", "DamageParticlesEnabled", "Visuals"); AddColorBtn(mHit, "Color", "ParticleColor"); AddSlider(mHit, "Size", "ParticleSize"); AddSlider(mHit, "Amount", "ParticleAmount")
local mBright = CreateModule("FULLBRIGHT", "FullBrightEnabled", "Visuals"); AddSlider(mBright, "Brightness (0-10)", "FullBrightBrightness")

local mJmp = CreateModule("JUMP CIRCLES", "JumpVisualCirclesEnabled", "Visuals"); AddSlider(mJmp, "Max Size", "JumpCircleMaximumSize"); AddColorBtn(mJmp, "Color", "JumpCircleEffectColor")
local mTime = CreateModule("TIME CHANGER", "TimeChangerEnabled", "Visuals"); AddSlider(mTime, "Hours (0-23)", "TimeChangerHours")
local mWcl = CreateModule("WORLD COLOR", "WorldColorEnabled", "Visuals"); AddColorBtn(mWcl, "Map Color", "WorldColorValue"); AddSlider(mWcl, "Intensity (0-1)", "WorldColorTransparency"); AddSlider(mWcl, "Darkness (0-5)", "WorldColorDarkness")
local mHitS = CreateModule("HIT SOUND", "HitSoundEnabled", "Visuals"); AddSlider(mHitS, "Sound (1-6)", "HitSoundMode")
local mFov = CreateModule("CUSTOM FOV", "CustomFovEnabled", "Visuals"); AddSlider(mFov, "FOV Value", "CustomFovValue")

local mFnd = CreateModule("CLICK FRIEND", "ClickFriendEnabled", "Misc")
local mDFnd = CreateModule("DELETE FRIEND", "DeleteFriendEnabled", "Misc")

local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function encB64(data)
    local sub = string.sub; local len = #data; local res = {}
    for i = 1, len, 3 do
        local b1 = string.byte(data, i); local b2 = string.byte(data, i+1) or 0; local b3 = string.byte(data, i+2) or 0
        local n = b1 * 65536 + b2 * 256 + b3; local n1 = math.floor(n / 262144) % 64 + 1; local n2 = math.floor(n / 4096) % 64 + 1; local n3 = math.floor(n / 64) % 64 + 1; local n4 = n % 64 + 1
        table.insert(res, sub(b64chars, n1, n1) .. sub(b64chars, n2, n2) .. (i+1 <= len and sub(b64chars, n3, n3) or "=") .. (i+2 <= len and sub(b64chars, n4, n4) or "="))
    end
    return table.concat(res)
end

local function decB64(data)
    local sub = string.sub; local find = string.find; local char = string.char; local res = {}; data = data:gsub("[^" .. b64chars .. "=]", "")
    for i = 1, #data, 4 do
        local o1 = find(b64chars, sub(data, i, i)) or 1; local o2 = find(b64chars, sub(data, i+1, i+1)) or 1; local o3 = find(b64chars, sub(data, i+2, i+2)) or 1; local o4 = find(b64chars, sub(data, i+3, i+3)) or 1
        o1, o2, o3, o4 = o1-1, o2-1, o3-1, o4-1
        local n = o1 * 262144 + o2 * 4096 + o3 * 64 + o4
        local b1 = math.floor(n / 65536) % 256; local b2 = math.floor(n / 256) % 256; local b3 = n % 256
        table.insert(res, char(b1)); if sub(data, i+2, i+2) ~= "=" then table.insert(res, char(b2)) end; if sub(data, i+3, i+3) ~= "=" then table.insert(res, char(b3)) end
    end
    return table.concat(res)
end

local function PackConfigString()
    local p = {}
    for _, k in ipairs(ConfigLayout) do
        local v = _G.Cfg[k]
        if type(v) == "boolean" then table.insert(p, v and "1" or "0")
        elseif typeof(v) == "Color3" then table.insert(p, math.floor(v.R*255)..","..math.floor(v.G*255)..","..math.floor(v.B*255))
        elseif typeof(v) == "UDim2" then table.insert(p, v.X.Scale..","..v.X.Offset..","..v.Y.Scale..","..v.Y.Offset)
        else table.insert(p, tostring(v)) end
    end
    local f = {}; for k,_ in pairs(FriendsList) do table.insert(f, k) end
    table.insert(p, table.concat(f, ",")); return encB64(table.concat(p, "|"))
end

local function UnpackConfigString(b64)
    local s = decB64(b64); if not s or s == "" then return false end
    local p = string.split(s, "|"); if #p < #ConfigLayout then return false end
    for i, k in ipairs(ConfigLayout) do
        local v = _G.Cfg[k]; local d = p[i]
        if type(v) == "boolean" then _G.Cfg[k] = (d == "1")
        elseif type(v) == "number" then _G.Cfg[k] = tonumber(d) or v
        elseif typeof(v) == "Color3" then local rgb = string.split(d, ","); if #rgb == 3 then _G.Cfg[k] = Color3.fromRGB(tonumber(rgb[1]) or 255, tonumber(rgb[2]) or 255, tonumber(rgb[3]) or 255) end
        elseif typeof(v) == "UDim2" then local u = string.split(d, ","); if #u == 4 then _G.Cfg[k] = UDim2.new(tonumber(u[1]) or 0, tonumber(u[2]) or 0, tonumber(u[3]) or 0, tonumber(u[4]) or 0) end
        else _G.Cfg[k] = d end
    end
    FriendsList = {}
    if p[#ConfigLayout+1] and p[#ConfigLayout+1] ~= "" then for _, f in ipairs(string.split(p[#ConfigLayout+1], ",")) do if f ~= "" then FriendsList[string.lower(f)] = true end end end
    SaveConfig(); return true
end

local FriendsFrame = Instance.new("Frame", ContentScroll); FriendsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", FriendsFrame); Instance.new("UIStroke", FriendsFrame).Color = Color3.fromRGB(45, 45, 45); table.insert(moduleFrames, {frame = FriendsFrame, category = "Misc"})
local FTitle = Instance.new("TextLabel", FriendsFrame); FTitle.Size = UDim2.new(1, -10, 0, 20); FTitle.Position = UDim2.new(0, 5, 0, 5); FTitle.Text = "FRIENDS MANAGER"; FTitle.TextColor3 = Color3.new(1,1,1); FTitle.Font = TARGET_FONT; FTitle.TextSize = 14; FTitle.BackgroundTransparency = 1; FTitle.TextXAlignment = "Left"
local FInput = Instance.new("TextBox", FriendsFrame); FInput.Size = UDim2.new(1, -40, 0, 24); FInput.Position = UDim2.new(0, 5, 0, 25); FInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15); FInput.TextColor3 = Color3.new(1,1,1); FInput.Font = TARGET_FONT; FInput.TextSize = 12; FInput.Text = "Username"; FInput.ClearTextOnFocus = true; Instance.new("UICorner", FInput).CornerRadius = UDim.new(0,4)
local FAddBtn = Instance.new("TextButton", FriendsFrame); FAddBtn.Size = UDim2.new(0, 24, 0, 24); FAddBtn.Position = UDim2.new(1, -30, 0, 25); FAddBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); FAddBtn.TextColor3 = Color3.new(0, 1, 0); FAddBtn.Text = "+"; FAddBtn.Font = TARGET_FONT; FAddBtn.TextSize = 16; Instance.new("UICorner", FAddBtn).CornerRadius = UDim.new(0,4)
local FListScroll = Instance.new("ScrollingFrame", FriendsFrame); FListScroll.Size = UDim2.new(1, -10, 1, -60); FListScroll.Position = UDim2.new(0, 5, 0, 55); FListScroll.BackgroundTransparency = 1; FListScroll.ScrollBarThickness = 2; FListScroll.CanvasSize = UDim2.new(0, 0, 0, 0); FListScroll.AutomaticCanvasSize = "Y"
local FListLayout = Instance.new("UIListLayout", FListScroll); FListLayout.Padding = UDim.new(0, 2)

local function RefreshFriendsList()
    for _, child in pairs(FListScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for fname, _ in pairs(FriendsList) do
        local itm = Instance.new("Frame", FListScroll); itm.Size = UDim2.new(1, 0, 0, 20); itm.BackgroundTransparency = 1
        local dBtn = Instance.new("TextButton", itm); dBtn.Size = UDim2.new(0, 20, 0, 20); dBtn.Position = UDim2.new(0, 0, 0, 0); dBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 15); dBtn.TextColor3 = Color3.new(1, 0.2, 0.2); dBtn.Text = "-"; dBtn.Font = TARGET_FONT; dBtn.TextSize = 14; Instance.new("UICorner", dBtn).CornerRadius = UDim.new(0,4)
        local nLbl = Instance.new("TextLabel", itm); nLbl.Size = UDim2.new(1, -25, 1, 0); nLbl.Position = UDim2.new(0, 25, 0, 0); nLbl.BackgroundTransparency = 1; nLbl.Text = fname; nLbl.TextColor3 = Color3.new(0.8, 0.8, 0.8); nLbl.Font = TARGET_FONT; nLbl.TextSize = 12; nLbl.TextXAlignment = "Left"
        dBtn.MouseButton1Click:Connect(function()
            FriendsList[fname] = nil
            for _, targetPlayer in ipairs(Players:GetPlayers()) do if string.lower(targetPlayer.Name) == fname then if targetPlayer.Character and targetPlayer.Character:FindFirstChild("FriendHighlight") then targetPlayer.Character.FriendHighlight:Destroy() end break end end
            SaveConfig(); RefreshFriendsList(); ShowNotify("Friend Removed: " .. fname, false)
        end)
    end
end
FAddBtn.MouseButton1Click:Connect(function() local txt = FInput.Text:gsub("%s+", ""); if txt ~= "" and txt ~= "Username" then local lowerTxt = LowerNameCache[txt]; FriendsList[lowerTxt] = true; FInput.Text = "Username"; SaveConfig(); RefreshFriendsList(); ShowNotify("Friend Added: " .. lowerTxt, true) end end)
local lastFriendsStr = ""; task.spawn(function() while task.wait(0.2) do local currentStr = HttpService:JSONEncode(FriendsList); if currentStr ~= lastFriendsStr then lastFriendsStr = currentStr; RefreshFriendsList() end end end)

local GenConfigFrame = Instance.new("Frame", ContentScroll); GenConfigFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", GenConfigFrame); Instance.new("UIStroke", GenConfigFrame).Color = Color3.fromRGB(45, 45, 45); table.insert(moduleFrames, {frame = GenConfigFrame, category = "Misc"})
local GenTitle = Instance.new("TextLabel", GenConfigFrame); GenTitle.Size = UDim2.new(1, -10, 0, 25); GenTitle.Position = UDim2.new(0, 5, 0, 5); GenTitle.Text = "GENERATE CONFIG KEY"; GenTitle.TextColor3 = Color3.new(1,1,1); GenTitle.Font = TARGET_FONT; GenTitle.TextSize = 14; GenTitle.BackgroundTransparency = 1; GenTitle.TextXAlignment = "Left"
local GenBox = Instance.new("TextBox", GenConfigFrame); GenBox.Size = UDim2.new(1, -20, 0, 40); GenBox.Position = UDim2.new(0, 10, 0, 35); GenBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15); GenBox.TextColor3 = Color3.fromRGB(150, 150, 150); GenBox.Font = Enum.Font.Code; GenBox.TextSize = 10; GenBox.TextWrapped = true; GenBox.Text = "Your key will appear here"; GenBox.ClearTextOnFocus = false; GenBox.TextEditable = false; Instance.new("UICorner", GenBox).CornerRadius = UDim.new(0,4)
local GenBtn = Instance.new("TextButton", GenConfigFrame); GenBtn.Size = UDim2.new(1, -20, 0, 24); GenBtn.Position = UDim2.new(0, 10, 0, 80); GenBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); GenBtn.TextColor3 = Color3.new(1,1,1); GenBtn.Text = "GENERATE"; GenBtn.Font = TARGET_FONT; GenBtn.TextSize = 14; Instance.new("UICorner", GenBtn).CornerRadius = UDim.new(0,4)
local CopyBtn = Instance.new("TextButton", GenConfigFrame); CopyBtn.Size = UDim2.new(1, -20, 0, 16); CopyBtn.Position = UDim2.new(0, 10, 0, 108); CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); CopyBtn.TextColor3 = Color3.fromRGB(200, 200, 200); CopyBtn.Text = "COPY"; CopyBtn.Font = TARGET_FONT; CopyBtn.TextSize = 10; Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0,4)
GenBtn.MouseButton1Click:Connect(function() GenBox.Text = PackConfigString(); ShowNotify("Config Key Generated", true) end)
CopyBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(GenBox.Text); ShowNotify("Copied to clipboard", true) else ShowNotify("Executor not supported", false) end end)

local LoadConfigFrame = Instance.new("Frame", ContentScroll); LoadConfigFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", LoadConfigFrame); Instance.new("UIStroke", LoadConfigFrame).Color = Color3.fromRGB(45, 45, 45); table.insert(moduleFrames, {frame = LoadConfigFrame, category = "Misc"})
local LoadTitle = Instance.new("TextLabel", LoadConfigFrame); LoadTitle.Size = UDim2.new(1, -10, 0, 25); LoadTitle.Position = UDim2.new(0, 5, 0, 5); LoadTitle.Text = "LOAD CONFIG KEY"; LoadTitle.TextColor3 = Color3.new(1,1,1); LoadTitle.Font = TARGET_FONT; LoadTitle.TextSize = 14; LoadTitle.BackgroundTransparency = 1; LoadTitle.TextXAlignment = "Left"
local LoadBox = Instance.new("TextBox", LoadConfigFrame); LoadBox.Size = UDim2.new(1, -20, 0, 40); LoadBox.Position = UDim2.new(0, 10, 0, 35); LoadBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15); LoadBox.TextColor3 = Color3.new(1,1,1); LoadBox.Font = Enum.Font.Code; LoadBox.TextSize = 10; LoadBox.TextWrapped = true; LoadBox.Text = "Paste key here"; LoadBox.ClearTextOnFocus = true; Instance.new("UICorner", LoadBox).CornerRadius = UDim.new(0,4)
local LoadBtn = Instance.new("TextButton", LoadConfigFrame); LoadBtn.Size = UDim2.new(1, -20, 0, 24); LoadBtn.Position = UDim2.new(0, 10, 0, 80); LoadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); LoadBtn.TextColor3 = Color3.new(1,1,1); LoadBtn.Text = "LOAD"; LoadBtn.Font = TARGET_FONT; LoadBtn.TextSize = 14; Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0,4)
local PasteBtn = Instance.new("TextButton", LoadConfigFrame); PasteBtn.Size = UDim2.new(1, -20, 0, 16); PasteBtn.Position = UDim2.new(0, 10, 0, 108); PasteBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); PasteBtn.TextColor3 = Color3.fromRGB(200, 200, 200); PasteBtn.Text = "PASTE"; PasteBtn.Font = TARGET_FONT; PasteBtn.TextSize = 10; Instance.new("UICorner", PasteBtn).CornerRadius = UDim.new(0,4)
LoadBtn.MouseButton1Click:Connect(function() local txt = LoadBox.Text; if txt == "" or txt:find("Paste key") then return end; local cleanTxt = txt:gsub("%s+", ""); local success = UnpackConfigString(cleanTxt); if success then ShowNotify("Config Loaded", true) else ShowNotify("Invalid Key", false) end end)
PasteBtn.MouseButton1Click:Connect(function() if getclipboard then LoadBox.Text = tostring(getclipboard()); ShowNotify("Pasted from clipboard", true) else ShowNotify("Executor not supported", false) end end)

local KillFrame = Instance.new("Frame", ContentScroll); KillFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", KillFrame); Instance.new("UIStroke", KillFrame).Color = Color3.fromRGB(45, 45, 45); table.insert(moduleFrames, {frame = KillFrame, category = "Misc"})
local KillBtn = Instance.new("TextButton", KillFrame); KillBtn.Size = UDim2.new(1, -20, 0, 40); KillBtn.Position = UDim2.new(0, 10, 0.5, -20); KillBtn.Text = "KILL SCRIPT"; KillBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20); KillBtn.TextColor3 = Color3.new(1,1,1); KillBtn.Font = TARGET_FONT; KillBtn.TextSize = 16; Instance.new("UICorner", KillBtn)
KillBtn.MouseButton1Click:Connect(function() 
    for _, c in pairs(Connections) do c:Disconnect() end 
    GeminiGui:Destroy(); HatPart:Destroy(); ChamsFolder:Destroy()
    if workspace:FindFirstChild("Gemini_3D_Chams") then workspace.Gemini_3D_Chams:Destroy() end
end)

SwitchCategory("Combat")
