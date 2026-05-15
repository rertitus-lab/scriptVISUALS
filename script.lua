local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Connections = {}
local ChamsFolder = Instance.new("Folder", game.CoreGui)
ChamsFolder.Name = "Gemini_Chams_Storage"

local FriendsList = {}

-- // ПОЛНАЯ КОНФИГУРАЦИЯ
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
    KillAuraSpeed = 1, 
    KillAuraEnabledBind = "None",
    
    SpeedEnabled = false,
    WalkSpeedValue = 16,
    SpeedEnabledBind = "None",

    NoClipEnabled = false,
    NoClipEnabledBind = "None",

    HitSoundEnabled = false,
    HitSoundMode = 1, 
    HitSoundEnabledBind = "None",
    
    TargetESPSquareEnabled = false,
    TargetESPSquareSize = 110,
    TargetESPBorderThickness = 6.5,
    TargetESPSquareColor = Color3.new(1, 1, 1),
    TargetESPRotationSpeed = 2,
    TargetESPSquareEnabledBind = "None",
    
    TargetStrafeOrbitEnabled = false,
    TargetStrafeOrbitRadius = 5,
    TargetStrafeOrbitSpeed = 15,
    TargetStrafeOrbitEnabledBind = "None",
    
    ChinaHatAccessoryEnabled = false,
    ChinaHatAccessoryColor = Color3.fromRGB(255, 0, 0),
    ChinaHatHeightOffset = 0.8,
    ChinaHatWidthScale = 3,
    ChinaHatHeightScale = 2,
    ChinaHatTransparency = 0,
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
    
    DamageParticlesEnabled = false,
    ParticleColor = Color3.fromRGB(255, 255, 255),
    ParticleSize = 4,
    DamageParticlesEnabledBind = "None",

    ClickFriendEnabled = false,
    ClickFriendEnabledBind = "None",

    DeleteFriendEnabled = false,
    DeleteFriendEnabledBind = "None",
    
    AspectRatioValue = 80
}

local HitSounds = {
    [1] = "rbxassetid://140604838213617",
    [2] = "rbxassetid://130201387574815",
    [3] = "rbxassetid://135478009117226",
    [4] = "rbxassetid://96735711388006",
    [5] = "rbxassetid://126048302910782",
    [6] = "rbxassetid://7255642553"
}

local GeminiGui = Instance.new("ScreenGui", game.CoreGui)
GeminiGui.Name = "Gemini_V60_Final"
GeminiGui.IgnoreGuiInset = true

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

-- // FRIEND SYSTEM LOGIC
local function StartFriendProcess(isDelete)
    local BigLabel = Instance.new("TextLabel", GeminiGui)
    BigLabel.Size = UDim2.new(1, 0, 0, 100)
    BigLabel.Position = UDim2.new(0, 0, 0.2, 0)
    BigLabel.BackgroundTransparency = 1
    BigLabel.Text = isDelete and "нажмите три раза по игроку чтобы удалить из друзей" or "кликните по своему другу три раза в течении 5 секунд!"
    BigLabel.TextColor3 = isDelete and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    BigLabel.Font = Enum.Font.SourceSansBold
    BigLabel.TextSize = 40
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
                    if isDelete and not FriendsList[p.Name] then return end
                    ClickData[p.Name] = (ClickData[p.Name] or 0) + 1
                    if ClickData[p.Name] >= 3 then
                        if isDelete then
                            FriendsList[p.Name] = nil
                            if char:FindFirstChild("FriendHighlight") then char.FriendHighlight:Destroy() end
                            ShowNotify("Friend Removed: " .. p.DisplayName, false)
                            _G.Cfg.DeleteFriendEnabled = false
                        else
                            FriendsList[p.Name] = true
                            ShowNotify("Friend Added: " .. p.DisplayName, true)
                            _G.Cfg.ClickFriendEnabled = false
                        end
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
    end)
end

local Island = Instance.new("TextButton", GeminiGui)
Island.Size = UDim2.new(0, 350, 0, 35)
Island.Position = UDim2.new(0.5, -175, 0, 10)
Island.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Island.Text = ""
Island.AutoButtonColor = false
Instance.new("UICorner", Island).CornerRadius = UDim.new(0, 10)
local IslandStroke = Instance.new("UIStroke", Island)
IslandStroke.Color = Color3.fromRGB(50, 50, 50)
IslandStroke.Thickness = 1.5

local IslandTitle = Instance.new("TextLabel", Island)
IslandTitle.Size = UDim2.new(0.5, 0, 1, 0)
IslandTitle.Position = UDim2.new(0, 15, 0, 0)
IslandTitle.BackgroundTransparency = 1
IslandTitle.Text = "тгк: extazz_scripts"
IslandTitle.Font = Enum.Font.SourceSansBold
IslandTitle.TextSize = 16
IslandTitle.TextColor3 = Color3.new(1, 1, 1)
IslandTitle.TextXAlignment = "Left"

local StatsLabel = Instance.new("TextLabel", Island)
StatsLabel.Size = UDim2.new(0.5, 0, 1, 0)
StatsLabel.Position = UDim2.new(0.5, -10, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: 0 | PING: 0ms"
StatsLabel.Font = Enum.Font.SourceSans
StatsLabel.TextSize = 14
StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatsLabel.TextXAlignment = "Right"

local MainFrame = Instance.new("Frame", GeminiGui)
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.BackgroundTransparency = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(50, 50, 50)
MainStroke.Thickness = 2

local ContentScroll = Instance.new("ScrollingFrame", MainFrame)
ContentScroll.Size = UDim2.new(1, -20, 1, -20)
ContentScroll.Position = UDim2.new(0, 10, 0, 10)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 2
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = "Y"

local UIGrid = Instance.new("UIGridLayout", ContentScroll)
UIGrid.CellSize = UDim2.new(0, 305, 0, 130)
UIGrid.CellPadding = UDim2.new(0, 10, 0, 10)

local MenuOpen = false
local function ToggleMenu()
    MenuOpen = not MenuOpen
    if MenuOpen then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Position = UDim2.new(0.5, -325, 0.5, -225)}):Play()
    else
        local t = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1, Position = UDim2.new(0.5, -325, 0.5, -180)})
        t:Play()
        t.Completed:Connect(function() if not MenuOpen then MainFrame.Visible = false end end)
    end
end
Island.MouseButton1Click:Connect(ToggleMenu)

task.spawn(function()
    while task.wait(0.5) do
        local fps = math.floor(workspace:GetRealPhysicsFPS())
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        StatsLabel.Text = "FPS: "..fps.." | PING: "..ping.."ms"
        IslandTitle.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
end)

-- // COLOR PICKER
local CPFrame = Instance.new("Frame", GeminiGui)
CPFrame.Size = UDim2.new(0, 220, 0, 240)
CPFrame.Position = UDim2.new(0.5, -110, 0.5, -120)
CPFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
CPFrame.Visible = false
CPFrame.Active = true
CPFrame.ZIndex = 20
Instance.new("UIStroke", CPFrame).Color = Color3.fromRGB(50, 50, 50)

local SatValBox = Instance.new("Frame", CPFrame)
SatValBox.Size = UDim2.new(0, 200, 0, 150)
SatValBox.Position = UDim2.new(0, 10, 0, 10)
SatValBox.ZIndex = 21

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

local ApplyBtn = Instance.new("TextButton", CPFrame); ApplyBtn.Size = UDim2.new(0, 200, 0, 30); ApplyBtn.Position = UDim2.new(0, 10, 0, 200); ApplyBtn.Text = "APPLY"; ApplyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); ApplyBtn.TextColor3 = Color3.new(1,1,1); ApplyBtn.ZIndex = 25
ApplyBtn.MouseButton1Click:Connect(function() CPFrame.Visible = false end)

local function CreateModule(name, key)
    local ModFrame = Instance.new("Frame", ContentScroll)
    ModFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", ModFrame)
    local s = Instance.new("UIStroke", ModFrame); s.Color = Color3.fromRGB(45,45,45); s.Thickness = 1
    
    local Title = Instance.new("TextLabel", ModFrame)
    Title.Size = UDim2.new(1, -50, 0, 35); Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = name; Title.TextColor3 = Color3.new(1,1,1); Title.Font = "SourceSansBold"; Title.TextSize = 18; Title.TextXAlignment = "Left"; Title.BackgroundTransparency = 1
    
    local Toggle = Instance.new("TextButton", ModFrame)
    Toggle.Size = UDim2.new(0, 45, 0, 22); Toggle.Position = UDim2.new(1, -55, 0, 7)
    Toggle.BackgroundColor3 = _G.Cfg[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
    Toggle.Text = ""; Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1,0)
    
    local function RunToggle()
        _G.Cfg[key] = not _G.Cfg[key]
        
        if key == "SpeedEnabled" and not _G.Cfg[key] then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 16
            end
        end

        if key == "ClickFriendEnabled" and _G.Cfg[key] then
            StartFriendProcess(false)
        elseif key == "DeleteFriendEnabled" and _G.Cfg[key] then
            StartFriendProcess(true)
        end
    end
    Toggle.MouseButton1Click:Connect(RunToggle)
    
    task.spawn(function()
        while task.wait(0.1) do
            Toggle.BackgroundColor3 = _G.Cfg[key] and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
        end
    end)
    
    local Inner = Instance.new("Frame", ModFrame)
    Inner.Size = UDim2.new(1, -10, 1, -40); Inner.Position = UDim2.new(0, 5, 0, 35); Inner.BackgroundTransparency = 1
    local l = Instance.new("UIListLayout", Inner); l.Padding = UDim.new(0, 2)
    
    local bindKey = key .. "Bind"
    local bF = Instance.new("Frame", Inner); bF.Size = UDim2.new(1, 0, 0, 20); bF.BackgroundTransparency = 1
    local bL = Instance.new("TextLabel", bF); bL.Size = UDim2.new(0.6, 0, 1, 0); bL.Text = "  Bind Key"; bL.TextColor3 = Color3.new(0.7,0.7,0.7); bL.BackgroundTransparency = 1; bL.TextXAlignment = "Left"; bL.TextSize = 14
    local bI = Instance.new("TextBox", bF); bI.Size = UDim2.new(0, 60, 0.9, 0); bI.Position = UDim2.new(1, -65, 0, 0); bI.Text = tostring(_G.Cfg[bindKey]); bI.BackgroundColor3 = Color3.fromRGB(35,35,35); bI.TextColor3 = Color3.new(1,1,1); bI.TextSize = 12
    bI.FocusLost:Connect(function() local inputStr = bI.Text:gsub("%s+", ""); if inputStr == "" or inputStr:lower() == "none" then _G.Cfg[bindKey] = "None" else _G.Cfg[bindKey] = inputStr end; bI.Text = _G.Cfg[bindKey] end)
    
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and _G.Cfg[bindKey] ~= "None" and input.KeyCode.Name:lower() == _G.Cfg[bindKey]:lower() then RunToggle() end
    end))

    return Inner
end

local function AddSlider(parent, text, key)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 18); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.6, 0, 1, 0); l.Text = "  " .. text; l.TextColor3 = Color3.new(0.6,0.6,0.6); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"; l.TextSize = 13
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0, 45, 0.9, 0); i.Position = UDim2.new(1, -50, 0, 0); i.Text = tostring(_G.Cfg[key]); i.BackgroundColor3 = Color3.fromRGB(40,40,40); i.TextColor3 = Color3.new(1,1,1); i.TextSize = 11
    i.FocusLost:Connect(function() local v = tonumber(i.Text); if v then _G.Cfg[key] = v end end)
end

local function AddColorBtn(parent, text, key)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, 0, 0, 18); b.Text = "  [COLOR] " .. text; b.BackgroundColor3 = Color3.fromRGB(40, 40, 50); b.TextColor3 = Color3.new(1,1,1); b.TextXAlignment = "Left"; b.TextSize = 13
    b.MouseButton1Click:Connect(function() curKey = key; CPFrame.Visible = true end)
end

-- // CORE FUNCTIONS
local function GetTarget()
    local t, d = nil, _G.Cfg.AimbotMaxDistance
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and not FriendsList[v.Name] and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if dist < d then d = dist; t = v end
        end
    end
    return t
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

table.insert(Connections, RunService.Stepped:Connect(function()
    if _G.Cfg.NoClipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    elseif not _G.Cfg.NoClipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and not part.CanCollide then
                if part.Name ~= "HumanoidRootPart" then 
                    part.CanCollide = true
                end
            end
        end
    end
end))

local function CreateStar(position)
    local bgui = Instance.new("BillboardGui", GeminiGui)
    bgui.Size = UDim2.new(_G.Cfg.ParticleSize*0.5,0,_G.Cfg.ParticleSize*0.5,0); bgui.AlwaysOnTop = true
    local p = Instance.new("Part", workspace); p.Size = Vector3.new(0.1,0.1,0.1); p.Transparency = 1; p.CanCollide = false; p.Anchored = true; p.Position = position
    bgui.Adornee = p
    local f = Instance.new("Frame", bgui); f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = _G.Cfg.ParticleColor
    Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
    local tI = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(p, tI, {Position = p.Position + Vector3.new(math.random(-5,5), math.random(4,8), math.random(-5,5))}):Play()
    TweenService:Create(f, tI, {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0)}):Play()
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

local TargetHUD = Instance.new("Frame", GeminiGui); TargetHUD.Size = UDim2.new(0, 200, 0, 70); TargetHUD.Position = UDim2.new(0.5, 50, 0.5, 50); TargetHUD.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TargetHUD.Visible = false; TargetHUD.Active = true; TargetHUD.Draggable = true 
Instance.new("UIStroke", TargetHUD).Color = Color3.fromRGB(60, 60, 60)
local TargetIcon = Instance.new("ImageLabel", TargetHUD); TargetIcon.Size = UDim2.new(0, 50, 0, 50); TargetIcon.Position = UDim2.new(0, 10, 0, 10)
local TargetName = Instance.new("TextLabel", TargetHUD); TargetName.Size = UDim2.new(1, -75, 0, 20); TargetName.Position = UDim2.new(0, 65, 0, 10); TargetName.BackgroundTransparency = 1; TargetName.TextColor3 = Color3.new(1, 1, 1); TargetName.Text = "No Target"; TargetName.Font = "SourceSansBold"; TargetName.TextSize = 16
local HealthBack = Instance.new("Frame", TargetHUD); HealthBack.Size = UDim2.new(1, -75, 0, 15); HealthBack.Position = UDim2.new(0, 65, 0, 35); HealthBack.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
local HealthBar = Instance.new("Frame", HealthBack); HealthBar.Size = UDim2.new(1, 0, 1, 0); HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100); HealthBar.BorderSizePixel = 0
local HealthText = Instance.new("TextLabel", HealthBack); HealthText.Size = UDim2.new(1, 0, 1, 0); HealthText.BackgroundTransparency = 1; HealthText.TextColor3 = Color3.new(1, 1, 1); HealthText.TextSize = 12; HealthText.Font = "SourceSansBold"

local ESPMain = Instance.new("Frame", GeminiGui); ESPMain.BackgroundTransparency = 1; ESPMain.AnchorPoint = Vector2.new(0.5, 0.5); ESPMain.Visible = false
local function CreateCorner(name, pos)
    local corner = Instance.new("Frame", ESPMain); corner.Size = UDim2.new(0.3, 0, 0.3, 0); corner.Position = pos; corner.BackgroundTransparency = 1
    local hL = Instance.new("Frame", corner); hL.BorderSizePixel = 0; hL.ZIndex = 5; hL.Size = UDim2.new(1, 0, 0, 0); hL.Position = (name:find("B")) and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 0, 0)
    local vL = Instance.new("Frame", corner); vL.BorderSizePixel = 0; vL.ZIndex = 5; vL.Size = UDim2.new(0, 0, 1, 0); vL.Position = (name:find("R")) and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
    local hS = Instance.new("UIStroke", hL); hS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local vS = Instance.new("UIStroke", vL); vS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return {hL, vL, hS, vS}
end
local corners = {CreateCorner("TL", UDim2.new(0,0,0,0)), CreateCorner("TR", UDim2.new(0.7,0,0,0)), CreateCorner("BL", UDim2.new(0,0,0.7,0)), CreateCorner("BR", UDim2.new(0.7,0,0.7,0))}

-- // RENDER LOOP
local lastAttackTime = 0
table.insert(Connections, RunService.RenderStepped:Connect(function()
    local target = GetTarget()
    local char = LocalPlayer.Character
    Camera.FieldOfView = _G.Cfg.AspectRatioValue
    
    if _G.Cfg.SpeedEnabled and char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = _G.Cfg.WalkSpeedValue
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character; local highlight = ChamsFolder:FindFirstChild(player.Name)
            if FriendsList[player.Name] then
                if highlight then highlight:Destroy() end
                local friendHighlight = char and char:FindFirstChild("FriendHighlight")
                if not friendHighlight and char then
                    friendHighlight = Instance.new("Highlight", char)
                    friendHighlight.Name = "FriendHighlight"
                    friendHighlight.FillColor = Color3.fromRGB(0, 255, 0)
                    friendHighlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                    friendHighlight.FillTransparency = 0.8
                    friendHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
                end
            elseif _G.Cfg.ChamsEnabled and char then
                if char:FindFirstChild("FriendHighlight") then char.FriendHighlight:Destroy() end
                if not highlight then highlight = Instance.new("Highlight", ChamsFolder); highlight.Name = player.Name end
                highlight.Adornee = char; highlight.FillColor = _G.Cfg.ChamsColor; highlight.OutlineColor = _G.Cfg.ChamsOutlineColor; highlight.FillTransparency = _G.Cfg.ChamsFillTransparency; highlight.OutlineTransparency = _G.Cfg.ChamsOutlineTransparency; highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            else 
                if highlight then highlight:Destroy() end
                if char and char:FindFirstChild("FriendHighlight") then char.FriendHighlight:Destroy() end
            end
        end
    end
    
    if _G.Cfg.ChinaHatAccessoryEnabled and char and char:FindFirstChild("Head") then
        HatPart.Transparency = _G.Cfg.ChinaHatTransparency; HatPart.Color = _G.Cfg.ChinaHatAccessoryColor; HatMesh.Scale = Vector3.new(_G.Cfg.ChinaHatWidthScale, _G.Cfg.ChinaHatHeightScale, _G.Cfg.ChinaHatWidthScale); HatPart.CFrame = char.Head.CFrame * CFrame.new(0, _G.Cfg.ChinaHatHeightOffset, 0)
    else HatPart.Transparency = 1 end

    if _G.Cfg.TargetHudEnabled and target and target.Character:FindFirstChild("Humanoid") then
        TargetHUD.Visible = true; local hum = target.Character.Humanoid; TargetName.Text = target.DisplayName; TargetIcon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. target.UserId .. "&w=150&h=150"; HealthBar.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0); HealthText.Text = math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
    else TargetHUD.Visible = false end

    if _G.Cfg.TargetESPSquareEnabled and target and target.Character:FindFirstChild("HumanoidRootPart") then
        local pos, onScreen = Camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
        if onScreen then
            ESPMain.Visible = true; ESPMain.Position = UDim2.new(0, pos.X, 0, pos.Y); ESPMain.Size = UDim2.new(0, _G.Cfg.TargetESPSquareSize, 0, _G.Cfg.TargetESPSquareSize); ESPMain.Rotation = (tick() * 100 * _G.Cfg.TargetESPRotationSpeed) % 360
            for _, c in pairs(corners) do c[3].Thickness = _G.Cfg.TargetESPBorderThickness; c[4].Thickness = _G.Cfg.TargetESPBorderThickness; c[3].Color = _G.Cfg.TargetESPSquareColor; c[4].Color = _G.Cfg.TargetESPSquareColor end
        else ESPMain.Visible = false end
    else ESPMain.Visible = false end

    if _G.Cfg.TargetStrafeOrbitEnabled and target and target.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
        local angle = tick() * _G.Cfg.TargetStrafeOrbitSpeed; local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * _G.Cfg.TargetStrafeOrbitRadius; char.HumanoidRootPart.CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + offset, target.Character.HumanoidRootPart.Position)
    end

    if target and target.Character and char and char:FindFirstChild("HumanoidRootPart") then
        local targetPart = target.Character:FindFirstChild("HumanoidRootPart")
        local dist = (char.HumanoidRootPart.Position - targetPart.Position).Magnitude
        if _G.Cfg.KillAuraEnabled and dist <= _G.Cfg.KillAuraRange and IsVisible(targetPart) then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), _G.Cfg.AimbotSmoothness)
            local attackDelay = (_G.Cfg.KillAuraSpeed / 10)
            if tick() - lastAttackTime > attackDelay then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1); task.wait(0.01); VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1); lastAttackTime = tick()
                if _G.Cfg.KillAuraJump and char.Humanoid.FloorMaterial ~= Enum.Material.Air then char.Humanoid.Jump = true end
            end
        elseif _G.Cfg.AimbotEnabled and target.Character:FindFirstChild("Head") then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), _G.Cfg.AimbotSmoothness)
        end
    end
end))

-- // KEYBIND LIST SYSTEM
local BindListFrame = Instance.new("Frame", GeminiGui)
BindListFrame.Size = UDim2.new(0, 180, 0, 30)
BindListFrame.Position = UDim2.new(0, 20, 0.5, 0)
BindListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BindListFrame.Visible = false
Instance.new("UICorner", BindListFrame).CornerRadius = UDim.new(0, 5)
local BLStroke = Instance.new("UIStroke", BindListFrame)
BLStroke.Color = Color3.fromRGB(60, 60, 60)
BLStroke.Thickness = 1.5

local BLTitle = Instance.new("TextLabel", BindListFrame)
BLTitle.Size = UDim2.new(1, 0, 0, 25)
BLTitle.Text = "Keybind List"
BLTitle.TextColor3 = Color3.new(1, 1, 1)
BLTitle.Font = Enum.Font.SourceSansBold
BLTitle.TextSize = 14
BLTitle.BackgroundTransparency = 1

local BLContainer = Instance.new("Frame", BindListFrame)
BLContainer.Size = UDim2.new(1, -10, 1, -30)
BLContainer.Position = UDim2.new(0, 5, 0, 25)
BLContainer.BackgroundTransparency = 1
local BLLayout = Instance.new("UIListLayout", BLContainer)
BLLayout.Padding = UDim.new(0, 2)

local dragging, dragInput, dragStart, startPos
BindListFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = BindListFrame.Position
    end
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local function UpdateKeybindList()
    for _, child in pairs(BLContainer:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    
    local activeCount = 0
    local modules = {
        "AimbotEnabled", "KillAuraEnabled", "SpeedEnabled", "NoClipEnabled", 
        "HitSoundEnabled", "TargetHudEnabled", "TargetESPSquareEnabled", 
        "TargetStrafeOrbitEnabled", "ChinaHatAccessoryEnabled", 
        "JumpVisualCirclesEnabled", "ChamsEnabled", "DamageParticlesEnabled",
        "ClickFriendEnabled", "DeleteFriendEnabled"
    }
    
    for _, key in pairs(modules) do
        local bindKey = key .. "Bind"
        if _G.Cfg[key] == true and _G.Cfg[bindKey] ~= "None" then
            activeCount = activeCount + 1
            local label = Instance.new("TextLabel", BLContainer)
            label.Size = UDim2.new(1, 0, 0, 18)
            label.BackgroundTransparency = 1
            label.Text = " " .. key:gsub("Enabled", ""):upper() .. " [" .. tostring(_G.Cfg[bindKey]):upper() .. "]"
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 13
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
        end
    end
    
    BindListFrame.Visible = activeCount > 0
    if activeCount > 0 then
        BindListFrame.Size = UDim2.new(0, 180, 0, 30 + (activeCount * 20))
    end
end

task.spawn(function()
    while task.wait(0.5) do
        UpdateKeybindList()
    end
end)

-- // JUMP DETECTION
local function ConnectJump(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Jumping:Connect(function() if _G.Cfg.JumpVisualCirclesEnabled then CreateJumpCircle(char.HumanoidRootPart.Position) end end)
end
LocalPlayer.CharacterAdded:Connect(ConnectJump); if LocalPlayer.Character then ConnectJump(LocalPlayer.Character) end

-- // CLICK ACTIONS
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation(); local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y); local res = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
        if res and res.Instance then
            local char = res.Instance:FindFirstAncestorOfClass("Model")
            local p = Players:GetPlayerFromCharacter(char)
            if char and char:FindFirstChildOfClass("Humanoid") and char ~= LocalPlayer.Character and not FriendsList[char.Name] then 
                if _G.Cfg.DamageParticlesEnabled then
                    for i = 1, 8 do CreateStar(res.Position) end 
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

-- // ИНИЦИАЛИЗАЦИЯ МЕНЮ
local mAim = CreateModule("AIMBOT", "AimbotEnabled"); AddSlider(mAim, "Smooth", "AimbotSmoothness"); AddSlider(mAim, "MaxDist", "AimbotMaxDistance")
local mKilla = CreateModule("KILL AURA", "KillAuraEnabled"); AddSlider(mKilla, "Range", "KillAuraRange"); AddSlider(mKilla, "Delay (0.1s)", "KillAuraSpeed")
local mSpeed = CreateModule("PLAYER SPEED", "SpeedEnabled"); AddSlider(mSpeed, "WalkSpeed", "WalkSpeedValue")
local mNoc = CreateModule("NOCLIP", "NoClipEnabled")
local mHitS = CreateModule("HIT SOUND", "HitSoundEnabled"); AddSlider(mHitS, "Sound (1-6)", "HitSoundMode")
local mHud = CreateModule("TARGET HUD", "TargetHudEnabled")
local mEsp = CreateModule("Target esp", "TargetESPSquareEnabled"); AddSlider(mEsp, "Size", "TargetESPSquareSize"); AddSlider(mEsp, "Border", "TargetESPBorderThickness"); AddColorBtn(mEsp, "Color", "TargetESPSquareColor")
local mOrb = CreateModule("TARGET STRAFE", "TargetStrafeOrbitEnabled"); AddSlider(mOrb, "Radius", "TargetStrafeOrbitRadius"); AddSlider(mOrb, "Speed", "TargetStrafeOrbitSpeed")
local mHat = CreateModule("CHINA HAT", "ChinaHatAccessoryEnabled"); AddSlider(mHat, "Head Offset", "ChinaHatHeightOffset"); AddSlider(mHat, "Width", "ChinaHatWidthScale"); AddSlider(mHat, "Height", "ChinaHatHeightScale"); AddSlider(mHat, "Transparency", "ChinaHatTransparency"); AddColorBtn(mHat, "Hat Color", "ChinaHatAccessoryColor")
local mJmp = CreateModule("JUMP CIRCLES", "JumpVisualCirclesEnabled"); AddSlider(mJmp, "Max Size", "JumpCircleMaximumSize"); AddColorBtn(mJmp, "Color", "JumpCircleEffectColor")
local mCha = CreateModule("CHAMS (Wallhack)", "ChamsEnabled"); AddColorBtn(mCha, "Fill", "ChamsColor"); AddColorBtn(mCha, "Outline", "ChamsOutlineColor")
local mHit = CreateModule("HIT PARTICLES", "DamageParticlesEnabled"); AddColorBtn(mHit, "Color", "ParticleColor")
local mFnd = CreateModule("CLICK FRIEND", "ClickFriendEnabled")
local mDFnd = CreateModule("DELETE FRIEND", "DeleteFriendEnabled")

local KillBtn = Instance.new("TextButton", ContentScroll); KillBtn.Size = UDim2.new(0, 305, 0, 35); KillBtn.Text = "KILL SCRIPT"; KillBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20); KillBtn.TextColor3 = Color3.new(1,1,1); KillBtn.Font = "SourceSansBold"
Instance.new("UICorner", KillBtn)
KillBtn.MouseButton1Click:Connect(function() for _, c in pairs(Connections) do c:Disconnect() end GeminiGui:Destroy(); HatPart:Destroy(); ChamsFolder:Destroy() end)
