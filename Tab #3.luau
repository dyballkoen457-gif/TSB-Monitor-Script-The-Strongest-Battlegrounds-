

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// GUI SETTINGS
local GUI_NAME = "SilverMonitor"

--// GUI PARENT
local GUIParent

pcall(function()
    GUIParent = gethui()
end)

if not GUIParent then
    GUIParent = CoreGui
end

--// REMOVE OLD GUI
pcall(function()
    local old = GUIParent:FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

pcall(function()
    local old = LocalPlayer.PlayerGui:FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
end)

--// SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GUIParent

--// HUD
local HUD = Instance.new("Frame")
HUD.Name = "HUD"
HUD.Size = UDim2.new(0, 180, 0, 125)
HUD.Position = UDim2.new(0, 12, 1, -12)
HUD.AnchorPoint = Vector2.new(0, 1)
HUD.BackgroundTransparency = 1
HUD.Parent = ScreenGui

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0, 2)
Layout.Parent = HUD

--// LABEL CREATOR
local function CreateLabel(name, text, order)
    local Label = Instance.new("TextLabel")
    Label.Name = name
    Label.Size = UDim2.new(1, 0, 0, 22)
    Label.BackgroundTransparency = 1
    Label.BorderSizePixel = 0
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextSize = 16
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextStrokeTransparency = 0.55
    Label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.LayoutOrder = order
    Label.Parent = HUD
    return Label
end

--// HUD LABELS
local FPSLabel = CreateLabel("FPS", "FPS  0", 1)
local PingLabel = CreateLabel("PING", "PING  0", 2)
local StreakLabel = CreateLabel("KS", "K/S 0", 3)
local MonthlyLabel = CreateLabel("MTH", "MTH 0", 4)
local TotalLabel = CreateLabel("TTL", "TTL 0", 5)

--// WARNING POPUP
local Warning = Instance.new("Frame")
Warning.Name = "StreakWarning"
Warning.Size = UDim2.new(0, 265, 0, 85)
Warning.Position = UDim2.new(1, 290, 1, -25)
Warning.AnchorPoint = Vector2.new(1, 1)
Warning.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Warning.BackgroundTransparency = 1
Warning.BorderSizePixel = 0
Warning.Visible = false
Warning.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 9)
Corner.Parent = Warning

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 170, 55)
Stroke.Thickness = 1.5
Stroke.Transparency = 1
Stroke.Parent = Warning

local WarningTitle = Instance.new("TextLabel")
WarningTitle.Name = "Title"
WarningTitle.Size = UDim2.new(1, -20, 0, 27)
WarningTitle.Position = UDim2.new(0, 12, 0, 8)
WarningTitle.BackgroundTransparency = 1
WarningTitle.Font = Enum.Font.GothamBold
WarningTitle.Text = "STREAK WARNING"
WarningTitle.TextSize = 15
WarningTitle.TextColor3 = Color3.fromRGB(255, 180, 70)
WarningTitle.TextXAlignment = Enum.TextXAlignment.Left
WarningTitle.TextTransparency = 1
WarningTitle.Parent = Warning

local WarningMessage = Instance.new("TextLabel")
WarningMessage.Name = "Message"
WarningMessage.Size = UDim2.new(1, -20, 0, 32)
WarningMessage.Position = UDim2.new(0, 12, 0, 38)
WarningMessage.BackgroundTransparency = 1
WarningMessage.Font = Enum.Font.GothamBold
WarningMessage.Text = "3 KILLS AWAY FROM 10"
WarningMessage.TextSize = 14
WarningMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
WarningMessage.TextXAlignment = Enum.TextXAlignment.Left
WarningMessage.TextTransparency = 1
WarningMessage.Parent = Warning

--// WARNING ANIMATION
local NotificationID = 0

local function SendNotification(streak)
    NotificationID += 1
    local ThisNotification = NotificationID

    local Messages = {
        [7] = "3 KILLS AWAY FROM STREAK",
        [8] = "2 KILLS AWAY FROM STREAK",
        [9] = "1 KILL AWAY FROM STREAK"
    }

    WarningMessage.Text = Messages[streak]

    Warning.Visible = true
    Warning.Position = UDim2.new(1, 290, 1, -25)
    Warning.BackgroundTransparency = 1
    WarningTitle.TextTransparency = 0
    WarningMessage.TextTransparency = 0
    Stroke.Transparency = 0.15

    TweenService:Create(
        Warning,
        TweenInfo.new(
            0.35,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        {
            Position = UDim2.new(1, -20, 1, -25),
            BackgroundTransparency = 0.12
        }
    ):Play()

    task.delay(3, function()
        if ThisNotification ~= NotificationID then
            return
        end

        local Fade = TweenInfo.new(0.4)

        TweenService:Create(Warning, Fade, {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 290, 1, -25)
        }):Play()

        TweenService:Create(WarningTitle, Fade, {
            TextTransparency = 1
        }):Play()

        TweenService:Create(WarningMessage, Fade, {
            TextTransparency = 1
        }):Play()

        TweenService:Create(Stroke, Fade, {
            Transparency = 1
        }):Play()

        task.wait(0.45)

        if ThisNotification == NotificationID then
            Warning.Visible = false
        end
    end)
end

--// STAT READER
local function GetStat(attributeName, leaderstatName)
    local value = LocalPlayer:GetAttribute(attributeName)

    if typeof(value) == "number" then
        return value
    end

    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")

    if leaderstats then
        local stat = leaderstats:FindFirstChild(leaderstatName)

        if stat and (
            stat:IsA("IntValue") or
            stat:IsA("NumberValue")
        ) then
            return stat.Value
        end
    end

    return 0
end

--// CURRENT STREAK
local function GetCurrentStreak()
    local Live = workspace:FindFirstChild("Live")

    if not Live then
        return 0
    end

    local Character = Live:FindFirstChild(LocalPlayer.Name)

    if not Character then
        return 0
    end

    local Streak = Character:GetAttribute("CurrentStreak")

    if typeof(Streak) == "number" then
        return Streak
    end

    return 0
end

--// PING
local function GetPing()
    local Ping = 0

    pcall(function()
        Ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)

    if typeof(Ping) ~= "number" or Ping <= 0 then
        Ping = LocalPlayer:GetAttribute("Ping") or 0
    end

    return math.round(Ping)
end

--// FPS COUNTER
local Frames = 0
local LastFPSUpdate = os.clock()
local CurrentFPS = 0

RunService.RenderStepped:Connect(function()
    Frames += 1

    local Now = os.clock()
    local Elapsed = Now - LastFPSUpdate

    if Elapsed >= 0.1 then
        CurrentFPS = math.round(Frames / Elapsed)
        Frames = 0
        LastFPSUpdate = Now
    end
end)

--// MILESTONE TRACKING
local Milestones = {
    [7] = false,
    [8] = false,
    [9] = false
}

local PreviousStreak = 0

--// MAIN UPDATE LOOP
task.spawn(function()
    while ScreenGui.Parent do
        -- FPS
        FPSLabel.Text = "FPS  " .. CurrentFPS

        -- PING
        PingLabel.Text = "PING  " .. GetPing() .. "ms"

        -- CURRENT STREAK
        local CurrentStreak = GetCurrentStreak()
        StreakLabel.Text = "K/S " .. CurrentStreak

        -- MONTHLY KILLS
        local MonthlyKills = GetStat("Kills", "Kills")
        MonthlyLabel.Text = "MTH " .. MonthlyKills

        -- TOTAL KILLS
        local TotalKills = GetStat("TotalKillsFrb", "Total Kills")
        TotalLabel.Text = "TTL " .. TotalKills

        -- RESET MILESTONES AFTER STREAK ENDS
        if CurrentStreak <= 0 then
            Milestones[7] = false
            Milestones[8] = false
            Milestones[9] = false
        end

        -- CHECK MILESTONES
        for _, Milestone in ipairs({7, 8, 9}) do
            if PreviousStreak < Milestone
                and CurrentStreak >= Milestone
                and not Milestones[Milestone] then

                Milestones[Milestone] = true
                SendNotification(Milestone)
            end
        end

        PreviousStreak = CurrentStreak

        task.wait(0.1)
    end
end)

print("[Silver Monitor Loaded]")