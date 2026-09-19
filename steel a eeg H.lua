--[[
    ==================================================
    Steal An Egg - Hussein Master OnHub Edition
    Full Script - Integrated & Fixed
    ==================================================
--]]

repeat task.wait() until game:IsLoaded()

-- 1. استدعاء خدمات روبلوكس الأساسية (Roblox Core Services)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

-- 2. إعداد بيانات ومتغيرات اللاعب المحلي (Local Player Setup)
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- إعادة ربط المتغيرات عند الموت وإعادة الترسيب (Respawn Handler)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
    
    task.wait(0.5)
    if getgenv().HusseinHub and getgenv().HusseinHub.CustomSpeed then
        Humanoid.WalkSpeed = getgenv().HusseinHub.CustomSpeed
    end
end)

-- 3. حماية الحساب من الطرد التلقائي (Anti-AFK Security System)
pcall(function()
    for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
        if conn.Disable then
            conn:Disable()
        elseif conn.Disconnect then
            conn:Disconnect()
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- 4. تنظيف الواجهات القديمة لمنع التداخل (GUI Cleanup)
pcall(function()
    if CoreGui:FindFirstChild("HusseinOnHubMaster") then
        CoreGui.HusseinOnHubMaster:Destroy()
    end
    if CoreGui:FindFirstChild("HusseinNotificationGui") then
        CoreGui.HusseinNotificationGui:Destroy()
    end
end)

-- 5. جدول الإعدادات الشامل (Global State Management)
getgenv().HusseinHub = {
    IsFarming = false,
    SelectedTarget = nil,
    SelectedEggName = "None",
    TargetDistance = 6000,
    FastMode = true,
    SkipPlayerNear = false,
    MinRarity = "ANY",
    FlyHeight = 35,
    AutoReturn = true,
    BaseCFrame = nil,
    CustomSpeed = 16,
    CustomJump = 50,
    SavedEggsData = {},
    Connections = {},
    Stats = {
        TotalStolen = 0,
        StartTime = os.time(),
        EarnedEstimate = 0
    }
}

local Hub = getgenv().HusseinHub

-- 6. نظام الإشعارات الداخلي (Custom Notification Engine)
function Hub:Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "OnHub Notice",
            Text = text or "",
            Duration = duration or 3,
            Icon = "rbxassetid://6031075931"
        })
    end)
end

-- 7. دالة كشف واستخراج موقع قاعدة/مزرعة اللاعب (Base Locator Engine)
function Hub:GetPlayerBaseLocation()
    if Hub.BaseCFrame then
        return Hub.BaseCFrame
    end
    
    for _, plot in pairs(Workspace:GetDescendants()) do
        if (plot.Name:lower():find("plot") or plot.Name:lower():find("base") or plot.Name:lower():find("claim") or plot.Name:find("مزرعة")) then
            local ownerVal = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player") or plot:FindFirstChild("PlayerName")
            if ownerVal and (tostring(ownerVal.Value) == LocalPlayer.Name or tostring(ownerVal.Value) == LocalPlayer.DisplayName) then
                if plot:IsA("BasePart") then
                    Hub.BaseCFrame = plot.CFrame
                    return plot.CFrame
                elseif plot:IsA("Model") then
                    local primary = plot.PrimaryPart or plot:FindFirstChildWhichIsA("BasePart")
                    if primary then
                        Hub.BaseCFrame = primary.CFrame
                        return primary.CFrame
                    end
                end
            end
        end
    end
    
    for _, spawnPoint in pairs(Workspace:GetDescendants()) do
        if spawnPoint:IsA("SpawnLocation") then
            local dist = (HumanoidRootPart.Position - spawnPoint.Position).Magnitude
            if dist < 50 then
                Hub.BaseCFrame = spawnPoint.CFrame
                return spawnPoint.CFrame
            end
        end
    end
    
    if HumanoidRootPart then
        Hub.BaseCFrame = HumanoidRootPart.CFrame
        return HumanoidRootPart.CFrame
    end
    
    return CFrame.new(0, 10, 0)
end

-- 8. نظام تتبع الوقت المنقضي (Farm Time Calculator)
function Hub:GetFormattedTime()
    local elapsed = os.time() - Hub.Stats.StartTime
    local hours = math.floor(elapsed / 3600)
    local mins = math.floor((elapsed % 3600) / 60)
    local secs = elapsed % 60
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

-- 9. دالة التحقق من أمان التنقل والمسافة (Safety & Distance Checks)
function Hub:IsPositionSafe(targetCFrame)
    if not targetCFrame then return false end
    
    local distance = (HumanoidRootPart.Position - targetCFrame.Position).Magnitude
    if distance > Hub.TargetDistance then
        return false
    end
    
    if Hub.SkipPlayerNear then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= LocalPlayer and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerDist = (targetCFrame.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                if playerDist < 60 then
                    return false
                end
            end
        end
    end
    
    return true
end

-- 10. دالة تحويل القيم المادية لتنسيق مقروء (Currency Formatter)
function Hub:FormatMoney(number)
    local num = tonumber(number) or 0
    if num >= 1e12 then
        return string.format("%.2fT", num / 1e12)
    elseif num >= 1e9 then
        return string.format("%.2fB", num / 1e9)
    elseif num >= 1e6 then
        return string.format("%.2fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.2fK", num / 1e3)
    else
        return tostring(math.floor(num))
    end
end

-- 11. تهيئة تأخير التيلبورت التكيّفي (Adaptive Teleport Delay)
function Hub:GetAdaptiveDelay()
    return Hub.FastMode and 0.12 or 0.35
end

-- 12. دالة مسح وفحص البيض المتاح في السيرفر (Server Eggs Scanner Engine)
function Hub:ScanServerEggs()
    local eggList = {}
    
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if (obj.Name:lower():find("egg") or obj.Name:lower():find("بيض") or obj:FindFirstChild("ProximityPrompt")) then
                local rootPart = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
                
                if rootPart and HumanoidRootPart then
                    local dist = math.floor((HumanoidRootPart.Position - rootPart.Position).Magnitude)
                    
                    if dist <= (Hub.TargetDistance or 6000) then
                        local rarity = obj:FindFirstChild("Rarity") and obj.Rarity.Value or "Common"
                        local income = obj:FindFirstChild("Income") and obj.Income.Value or 100
                        
                        table.insert(eggList, {
                            Object = rootPart,
                            Name = obj.Name,
                            Distance = dist,
                            Rarity = rarity,
                            Income = Hub:FormatMoney(income),
                            Image = "rbxassetid://6031075931"
                        })
                    end
                end
            end
        end
    end)
    
    table.sort(eggList, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return eggList
end

-- ==================================================
-- بناء عناصر واجهة المستخدم (GUI Creation)
-- ==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HusseinOnHubMaster"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local LogoButton = Instance.new("ImageButton")
LogoButton.Name = "FloatingLogo"
LogoButton.Size = UDim2.new(0, 50, 0, 50)
LogoButton.Position = UDim2.new(0.88, 0, 0.15, 0)
LogoButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogoButton.BorderColor3 = Color3.fromRGB(0, 255, 120)
LogoButton.BorderSizePixel = 2
LogoButton.Image = "rbxassetid://6031075931"
LogoButton.Active = true
LogoButton.Draggable = true
LogoButton.Parent = ScreenGui

local UICornerLogo = Instance.new("UICorner")
UICornerLogo.CornerRadius = UDim.new(1, 0)
UICornerLogo.Parent = LogoButton

local UIGradientLogo = Instance.new("UIGradient")
UIGradientLogo.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
})
UIGradientLogo.Parent = LogoButton

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 390, 0, 420)
MainFrame.Position = UDim2.new(0.5, -195, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 12)
UICornerMain.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(35, 35, 35)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- نظام سحب النافذة (Dragging)
local dragging, dragInput, dragStart, startPos

local function UpdateDrag(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = newPos}):Play()
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        UpdateDrag(input)
    end
end)

LogoButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        MainFrame.Size = UDim2.new(0, 390, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 390, 0, 420)}):Play()
    end
end)

-- Header Bar
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 45)
HeaderBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
HeaderBar.BorderSizePixel = 0
HeaderBar.Parent = MainFrame

local UICornerHeader = Instance.new("UICorner")
UICornerHeader.CornerRadius = UDim.new(0, 12)
UICornerHeader.Parent = HeaderBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.04, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "onhub"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 22
TitleLabel.Parent = HeaderBar

local SubTitleLabel = Instance.new("TextLabel")
SubTitleLabel.Name = "SubTitleLabel"
SubTitleLabel.Size = UDim2.new(0.4, 0, 1, 0)
SubTitleLabel.Position = UDim2.new(0.24, 0, 0, 0)
SubTitleLabel.BackgroundTransparency = 1
SubTitleLabel.Text = "| Steal An Egg"
SubTitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubTitleLabel.Font = Enum.Font.SourceSans
SubTitleLabel.TextSize = 14
SubTitleLabel.Parent = HeaderBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(0.9, -5, 0.16, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 14
CloseButton.Parent = HeaderBar

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 8)
UICornerClose.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 390, 0, 0)}):Play()
    task.wait(0.2)
    MainFrame.Visible = false
end)

-- Side Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 100, 1, -55)
TabBar.Position = UDim2.new(0, 5, 0, 50)
TabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local UICornerTabBar = Instance.new("UICorner")
UICornerTabBar.CornerRadius = UDim.new(0, 8)
UICornerTabBar.Parent = TabBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 8)
TabPadding.PaddingLeft = UDim.new(0, 5)
TabPadding.PaddingRight = UDim.new(0, 5)
TabPadding.Parent = TabBar

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -115, 1, -55)
ContentContainer.Position = UDim2.new(0, 110, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs = {}
local TabButtons = {}

function Hub:CreateTab(tabName, layoutOrder)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "Btn"
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabButton.Text = tabName
    TabButton.Font = Enum.Font.SourceSansBold
    TabButton.TextSize = 13
    TabButton.LayoutOrder = layoutOrder or 1
    TabButton.Parent = TabBar

    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 6)
    UICornerBtn.Parent = TabButton

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Name = tabName .. "Page"
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.ScrollBarThickness = 4
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 140)
    TabPage.Visible = false
    TabPage.Parent = ContentContainer

    local PageListLayout = Instance.new("UIListLayout")
    PageListLayout.Parent = TabPage
    PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageListLayout.Padding = UDim.new(0, 8)

    TabButton.MouseButton1Click:Connect(function()
        for _, page in pairs(ContentContainer:GetChildren()) do
            if page:IsA("ScrollingFrame") then page.Visible = false end
        end
        for _, btn in pairs(TabBar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    Tabs[tabName] = TabPage
    TabButtons[tabName] = TabButton
    return TabPage
end

local FarmPage = Hub:CreateTab("FARM", 1)
local ConfigPage = Hub:CreateTab("CONFIG", 2)
local MiscPage = Hub:CreateTab("MISC", 3)

FarmPage.Visible = true
TabButtons["FARM"].BackgroundColor3 = Color3.fromRGB(0, 180, 100)
TabButtons["FARM"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- تجهيز زر الفارم وقائمة الأهداف داخل تبويب FARM
local StartFarmBtn = Instance.new("TextButton")
StartFarmBtn.Name = "StartFarmBtn"
StartFarmBtn.Size = UDim2.new(1, -5, 0, 40)
StartFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
StartFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartFarmBtn.Text = "START FARM"
StartFarmBtn.Font = Enum.Font.SourceSansBold
StartFarmBtn.TextSize = 15
StartFarmBtn.Parent = FarmPage

local UICornerStart = Instance.new("UICorner")
UICornerStart.CornerRadius = UDim.new(0, 6)
UICornerStart.Parent = StartFarmBtn

local TargetsScroll = Instance.new("ScrollingFrame")
TargetsScroll.Name = "TargetsScroll"
TargetsScroll.Size = UDim2.new(1, -5, 1, -50)
TargetsScroll.BackgroundTransparency = 1
TargetsScroll.ScrollBarThickness = 3
TargetsScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 140)
TargetsScroll.Parent = FarmPage

local TargetsLayout = Instance.new("UIListLayout")
TargetsLayout.Parent = TargetsScroll
TargetsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TargetsLayout.Padding = UDim.new(0, 6)

-- 13. دالة تحديث قائمة البيض بالواجهة
function Hub:RefreshTargetsUI()
    pcall(function()
        for _, child in pairs(TargetsScroll:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        local eggList = Hub:ScanServerEggs()
        local contentHeight = 0
        
        for index, eggData in ipairs(eggList) do
            contentHeight = contentHeight + 56
            
            local CardFrame = Instance.new("Frame")
            CardFrame.Name = "EggCard_" .. tostring(index)
            CardFrame.Size = UDim2.new(1, -4, 0, 50)
            CardFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            CardFrame.BorderSizePixel = 0
            CardFrame.Parent = TargetsScroll
            
            local UICornerCard = Instance.new("UICorner")
            UICornerCard.CornerRadius = UDim.new(0, 6)
            UICornerCard.Parent = CardFrame
            
            local CardStroke = Instance.new("UIStroke")
            CardStroke.Thickness = 1
            CardStroke.Color = Color3.fromRGB(45, 45, 45)
            CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            CardStroke.Parent = CardFrame
            
            local ImageLabel = Instance.new("ImageLabel")
            ImageLabel.Name = "EggIcon"
            ImageLabel.Size = UDim2.new(0, 38, 0, 38)
            ImageLabel.Position = UDim2.new(0, 6, 0.5, -19)
            ImageLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            ImageLabel.Image = eggData.Image or "rbxassetid://6031075931"
            ImageLabel.Parent = CardFrame
            
            local UICornerImg = Instance.new("UICorner")
            UICornerImg.CornerRadius = UDim.new(0, 6)
            UICornerImg.Parent = ImageLabel
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Name = "EggName"
            NameLabel.Size = UDim2.new(0.5, 0, 0, 20)
            NameLabel.Position = UDim2.new(0, 50, 0, 5)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = eggData.Name
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Font = Enum.Font.SourceSansBold
            NameLabel.TextSize = 13
            NameLabel.Parent = CardFrame
            
            local SubDetailLabel = Instance.new("TextLabel")
            SubDetailLabel.Name = "SubDetail"
            SubDetailLabel.Size = UDim2.new(0.5, 0, 0, 18)
            SubDetailLabel.Position = UDim2.new(0, 50, 0, 25)
            SubDetailLabel.BackgroundTransparency = 1
            SubDetailLabel.Text = "[" .. eggData.Rarity .. "] • " .. tostring(eggData.Distance) .. " studs"
            SubDetailLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
            SubDetailLabel.TextXAlignment = Enum.TextXAlignment.Left
            SubDetailLabel.Font = Enum.Font.SourceSans
            SubDetailLabel.TextSize = 11
            SubDetailLabel.Parent = CardFrame
            
            local IncomeLabel = Instance.new("TextLabel")
            IncomeLabel.Name = "IncomeLabel"
            IncomeLabel.Size = UDim2.new(0.38, 0, 0, 20)
            IncomeLabel.Position = UDim2.new(0.6, 0, 0, 5)
            IncomeLabel.BackgroundTransparency = 1
            IncomeLabel.Text = "$" .. eggData.Income .. "/s"
            IncomeLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
            IncomeLabel.TextXAlignment = Enum.TextXAlignment.Right
            IncomeLabel.Font = Enum.Font.SourceSansBold
            IncomeLabel.TextSize = 13
            IncomeLabel.Parent = CardFrame
            
            local ClickLabel = Instance.new("TextLabel")
            ClickLabel.Name = "ClickLabel"
            ClickLabel.Size = UDim2.new(0.38, 0, 0, 18)
            ClickLabel.Position = UDim2.new(0.6, 0, 0, 25)
            ClickLabel.BackgroundTransparency = 1
            ClickLabel.Text = "click to lock"
            ClickLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
            ClickLabel.TextXAlignment = Enum.TextXAlignment.Right
            ClickLabel.Font = Enum.Font.SourceSansItalic
            ClickLabel.TextSize = 10
            ClickLabel.Parent = CardFrame
            
            local SelectBtn = Instance.new("TextButton")
            SelectBtn.Name = "SelectBtn"
            SelectBtn.Size = UDim2.new(1, 0, 1, 0)
            SelectBtn.BackgroundTransparency = 1
            SelectBtn.Text = ""
            SelectBtn.Parent = CardFrame
            
            SelectBtn.MouseButton1Click:Connect(function()
                Hub.SelectedTarget = eggData.Object
                Hub.SelectedEggName = eggData.Name
                CardStroke.Color = Color3.fromRGB(0, 255, 140)
                ClickLabel.Text = "LOCKED 🔒"
                ClickLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
                Hub:Notify("Target Locked", "تم تحديد الهدف: " .. eggData.Name, 2)
            end)
        end
        
        TargetsScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 10)
    end)
end

-- ==================================================
-- محرك ووظائف السرقة (Steal Mechanics)
-- ==================================================

function Hub:FindOpponentChicken()
    local chickenObj = nil
    local minDistance = math.huge

    pcall(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            local nameLower = v.Name:lower()
            if (nameLower:find("chicken") or nameLower:find("دجاجة") or nameLower:find("boss")) then
                if v:IsA("BasePart") then
                    local dist = (HumanoidRootPart.Position - v.Position).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        chickenObj = v
                    end
                elseif v:IsA("Model") then
                    local hrp = v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    if hrp then
                        local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            chickenObj = hrp
                        end
                    end
                end
            end
        end
    end)

    return chickenObj
end

function Hub:TriggerPrompt(targetPart)
    if not targetPart then return false end

    pcall(function()
        local prompt = targetPart:FindFirstChildWhichIsA("ProximityPrompt") 
            or targetPart.Parent:FindFirstChildWhichIsA("ProximityPrompt")

        if prompt then
            if fireproximityprompt then
                fireproximityprompt(prompt)
            elseif prompt.InputHoldBegin then
                prompt:InputHoldBegin()
                task.wait(prompt.HoldDuration or 0.1)
                prompt:InputHoldEnd()
            end
        end
    end)
    return true
end

function Hub:SafeTeleport(targetCFrame)
    if not targetCFrame or not HumanoidRootPart then return end

    pcall(function()
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        local targetPos = targetCFrame.Position
        HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, Hub.FlyHeight or 30, 0))
        task.wait(Hub:GetAdaptiveDelay())
        HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
    end)
end

function Hub.ExecuteFarmLoop()
    while Hub.IsFarming do
        pcall(function()
            if not Hub.SelectedTarget or not Hub.SelectedTarget.Parent then
                local eggList = Hub:ScanServerEggs()
                if #eggList > 0 then
                    Hub.SelectedTarget = eggList[1].Object
                    Hub.SelectedEggName = eggList[1].Name
                else
                    Hub:Notify("Warning", "لم يتم العثور على بيض متاح حالياً!", 2)
                    task.wait(2)
                    return
                end
            end

            local opponentChicken = Hub:FindOpponentChicken()
            if opponentChicken then
                Hub:SafeTeleport(opponentChicken.CFrame)
                task.wait(0.15)
                Hub:TriggerPrompt(opponentChicken)
            end

            task.wait(0.35)

            if Hub.SelectedTarget and Hub.SelectedTarget.Parent then
                HumanoidRootPart.CFrame = Hub.SelectedTarget.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.15)
                Hub:TriggerPrompt(Hub.SelectedTarget)
            end

            if Hub.AutoReturn then
                task.wait(0.25)
                local myBaseCFrame = Hub:GetPlayerBaseLocation()
                HumanoidRootPart.CFrame = myBaseCFrame + Vector3.new(0, 4, 0)
            end

            Hub.Stats.TotalStolen = Hub.Stats.TotalStolen + 1
        end)

        task.wait(Hub.FastMode and 1.2 or 2.2)
    end
end

StartFarmBtn.MouseButton1Click:Connect(function()
    Hub.IsFarming = not Hub.IsFarming
    
    if Hub.IsFarming then
        StartFarmBtn.Text = "STOP FARM"
        StartFarmBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
        Hub:Notify("Auto Farm", "تم تفعيل السرقة التلقائية!", 2)
        task.spawn(Hub.ExecuteFarmLoop)
    else
        StartFarmBtn.Text = "START FARM"
        StartFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        Hub:Notify("Auto Farm", "تم إيقاف السرقة التلقائية.", 2)
    end
end)

-- ==================================================
-- مكونات واجهة الإعدادات والخيارات (CONFIG & MISC Elements)
-- ==================================================

function Hub:CreateToggle(parent, text, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = text .. "Frame"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent

    local UICornerToggle = Instance.new("UICorner")
    UICornerToggle.CornerRadius = UDim.new(0, 6)
    UICornerToggle.Parent = ToggleFrame

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0.04, 0, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.SourceSansBold
    ToggleLabel.TextSize = 13
    ToggleLabel.Parent = ToggleFrame

    local SwitchBtn = Instance.new("TextButton")
    SwitchBtn.Name = "Switch"
    SwitchBtn.Size = UDim2.new(0, 44, 0, 22)
    SwitchBtn.Position = UDim2.new(0.96, -48, 0.5, -11)
    SwitchBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 220, 110) or Color3.fromRGB(50, 50, 50)
    SwitchBtn.Text = ""
    SwitchBtn.Parent = ToggleFrame

    local UICornerSwitch = Instance.new("UICorner")
    UICornerSwitch.CornerRadius = UDim.new(1, 0)
    UICornerSwitch.Parent = SwitchBtn

    local CircleDot = Instance.new("Frame")
    CircleDot.Name = "Dot"
    CircleDot.Size = UDim2.new(0, 18, 0, 18)
    CircleDot.Position = defaultState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    CircleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CircleDot.BorderSizePixel = 0
    CircleDot.Parent = SwitchBtn

    local UICornerDot = Instance.new("UICorner")
    UICornerDot.CornerRadius = UDim.new(1, 0)
    UICornerDot.Parent = CircleDot

    local state = defaultState
    SwitchBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(SwitchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 220, 110)}):Play()
            TweenService:Create(CircleDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
        else
            TweenService:Create(SwitchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            TweenService:Create(CircleDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
        if callback then callback(state) end
    end)

    return ToggleFrame
end

function Hub:CreateSlider(parent, text, minVal, maxVal, defaultVal, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = text .. "SliderFrame"
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent

    local UICornerSlider = Instance.new("UICorner")
    UICornerSlider.CornerRadius = UDim.new(0, 6)
    UICornerSlider.Parent = SliderFrame

    local SliderTitle = Instance.new("TextLabel")
    SliderTitle.Size = UDim2.new(0.6, 0, 0, 22)
    SliderTitle.Position = UDim2.new(0.04, 0, 0, 4)
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Text = text
    SliderTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.Font = Enum.Font.SourceSansBold
    SliderTitle.TextSize = 13
    SliderTitle.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 22)
    ValueLabel.Position = UDim2.new(0.66, 0, 0, 4)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(defaultVal)
    ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 13
    ValueLabel.Parent = SliderFrame

    local BarBack = Instance.new("Frame")
    BarBack.Size = UDim2.new(0.92, 0, 0, 8)
    BarBack.Position = UDim2.new(0.04, 0, 0.7, -2)
    BarBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BarBack.BorderSizePixel = 0
    BarBack.Parent = SliderFrame

    local UICornerBarBack = Instance.new("UICorner")
    UICornerBarBack.CornerRadius = UDim.new(1, 0)
    UICornerBarBack.Parent = BarBack

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(0, 220, 110)
    BarFill.BorderSizePixel = 0
    BarFill.Parent = BarBack

    local UICornerBarFill = Instance.new("UICorner")
    UICornerBarFill.CornerRadius = UDim.new(1, 0)
    UICornerBarFill.Parent = BarFill

    local isSliding = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - BarBack.AbsolutePosition.X) / BarBack.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * pos)
        BarFill.Size = UDim2.new(pos, 0, 1, 0)
        ValueLabel.Text = tostring(val)
        if callback then callback(val) end
    end

    BarBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
end

function Hub:CreateDropdown(parent, text, options, defaultOption, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = text .. "DropdownFrame"
    DropdownFrame.Size = UDim2.new(1, 0, 0, 42)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Parent = parent

    local UICornerDrop = Instance.new("UICorner")
    UICornerDrop.CornerRadius = UDim.new(0, 6)
    UICornerDrop.Parent = DropdownFrame

    local DropTitle = Instance.new("TextLabel")
    DropTitle.Size = UDim2.new(0.5, 0, 0, 42)
    DropTitle.Position = UDim2.new(0.04, 0, 0, 0)
    DropTitle.BackgroundTransparency = 1
    DropTitle.Text = text
    DropTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    DropTitle.TextXAlignment = Enum.TextXAlignment.Left
    DropTitle.Font = Enum.Font.SourceSansBold
    DropTitle.TextSize = 13
    DropTitle.Parent = DropdownFrame

    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Size = UDim2.new(0.4, 0, 0, 42)
    SelectedLabel.Position = UDim2.new(0.55, -25, 0, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Text = defaultOption or "ANY"
    SelectedLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    SelectedLabel.Font = Enum.Font.SourceSansBold
    SelectedLabel.TextSize = 13
    SelectedLabel.Parent = DropdownFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 25, 0, 25)
    ToggleBtn.Position = UDim2.new(0.96, -25, 0.5, -12)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Text = "▼"
    ToggleBtn.Font = Enum.Font.SourceSansBold
    ToggleBtn.TextSize = 10
    ToggleBtn.Parent = DropdownFrame

    local UICornerArrow = Instance.new("UICorner")
    UICornerArrow.CornerRadius = UDim.new(0, 4)
    UICornerArrow.Parent = ToggleBtn

    local OptionListFrame = Instance.new("Frame")
    OptionListFrame.Size = UDim2.new(1, -10, 0, #options * 28)
    OptionListFrame.Position = UDim2.new(0, 5, 0, 45)
    OptionListFrame.BackgroundTransparency = 1
    OptionListFrame.Parent = DropdownFrame

    local OptionListLayout = Instance.new("UIListLayout")
    OptionListLayout.Parent = OptionListFrame
    OptionListLayout.Padding = UDim.new(0, 2)

    local isOpen = false
    local function ToggleDropdown()
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(DropdownFrame, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 45 + (#options * 30))}):Play()
            ToggleBtn.Text = "▲"
        else
            TweenService:Create(DropdownFrame, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 42)}):Play()
            ToggleBtn.Text = "▼"
        end
    end

    ToggleBtn.MouseButton1Click:Connect(ToggleDropdown)

    for _, optName in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 26)
        OptBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        OptBtn.Text = optName
        OptBtn.Font = Enum.Font.SourceSans
        OptBtn.TextSize = 12
        OptBtn.Parent = OptionListFrame

        local UICornerOpt = Instance.new("UICorner")
        UICornerOpt.CornerRadius = UDim.new(0, 4)
        UICornerOpt.Parent = OptBtn

        OptBtn.MouseButton1Click:Connect(function()
            SelectedLabel.Text = optName
            ToggleDropdown()
            if callback then callback(optName) end
        end)
    end
end

-- إضافة خيارات صفحة CONFIG
Hub:CreateToggle(ConfigPage, "Fast Mode (السرعة الفائقة)", Hub.FastMode, function(val)
    Hub.FastMode = val
end)

Hub:CreateToggle(ConfigPage, "Skip if player within 60 studs", Hub.SkipPlayerNear, function(val)
    Hub.SkipPlayerNear = val
end)

Hub:CreateToggle(ConfigPage, "Auto Return to Plot", Hub.AutoReturn, function(val)
    Hub.AutoReturn = val
end)

Hub:CreateSlider(ConfigPage, "Max Target Distance", 500, 10000, Hub.TargetDistance, function(val)
    Hub.TargetDistance = val
end)

Hub:CreateSlider(ConfigPage, "High Fly Height", 10, 80, Hub.FlyHeight, function(val)
    Hub.FlyHeight = val
end)

local rarityList = {"ANY", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Secret", "Eternal"}
Hub:CreateDropdown(ConfigPage, "MINIMUM RARITY", rarityList, Hub.MinRarity, function(selected)
    Hub.MinRarity = selected
    Hub:Notify("Filter Updated", "تم تحديد الحد الأدنى للندرة: " .. selected, 2)
end)

-- إضافة خيارات صفحة MISC
Hub:CreateSlider(MiscPage, "Player WalkSpeed", 16, 250, 16, function(val)
    Hub.CustomSpeed = val
    if Humanoid then Humanoid.WalkSpeed = val end
end)

Hub:CreateSlider(MiscPage, "Player JumpPower", 50, 300, 50, function(val)
    Hub.CustomJump = val
    if Humanoid then
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = val
    end
end)

-- Stats Display
local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsDisplayFrame"
StatsFrame.Size = UDim2.new(1, 0, 0, 100)
StatsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent = MiscPage

local UICornerStats = Instance.new("UICorner")
UICornerStats.CornerRadius = UDim.new(0, 8)
UICornerStats.Parent = StatsFrame

local StatsTitle = Instance.new("TextLabel")
StatsTitle.Size = UDim2.new(1, -10, 0, 22)
StatsTitle.Position = UDim2.new(0, 8, 0, 4)
StatsTitle.BackgroundTransparency = 1
StatsTitle.Text = "LIVE FARMING STATS"
StatsTitle.TextColor3 = Color3.fromRGB(0, 255, 140)
StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
StatsTitle.Font = Enum.Font.SourceSansBold
StatsTitle.TextSize = 12
StatsTitle.Parent = StatsFrame

local StolenText = Instance.new("TextLabel")
StolenText.Size = UDim2.new(1, -16, 0, 20)
StolenText.Position = UDim2.new(0, 8, 0, 30)
StolenText.BackgroundTransparency = 1
StolenText.Text = "Total Eggs Stolen: 0"
StolenText.TextColor3 = Color3.fromRGB(220, 220, 220)
StolenText.TextXAlignment = Enum.TextXAlignment.Left
StolenText.Font = Enum.Font.SourceSans
StolenText.TextSize = 13
StolenText.Parent = StatsFrame

local TimeText = Instance.new("TextLabel")
TimeText.Size = UDim2.new(1, -16, 0, 20)
TimeText.Position = UDim2.new(0, 8, 0, 52)
TimeText.BackgroundTransparency = 1
TimeText.Text = "Elapsed Time: 00:00:00"
TimeText.TextColor3 = Color3.fromRGB(220, 220, 220)
TimeText.TextXAlignment = Enum.TextXAlignment.Left
TimeText.Font = Enum.Font.SourceSans
TimeText.TextSize = 13
TimeText.Parent = StatsFrame

task.spawn(function()
    while task.wait(1) do
        if StatsFrame and StatsFrame.Parent then
            StolenText.Text = "Total Eggs Stolen: " .. tostring(Hub.Stats.TotalStolen)
            TimeText.Text = "Elapsed Time: " .. Hub:GetFormattedTime()
        end
    end
end)

-- Server Hop, Rejoin & Fly Mods
function Hub:ServerHop()
    Hub:Notify("Server Hop", "جاري البحث عن سيرفر آخر...", 3)
    pcall(function()
        local servers = {}
        local req = request or http_request or (syn and syn.request) or (http and http.request)
        if req then
            local response = req({
                Url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100",
                Method = "GET"
            })
            if response and response.Body then
                local body = HttpService:JSONDecode(response.Body)
                if body and body.data then
                    for _, v in pairs(body.data) do
                        if v.playing < v.maxPlayers and v.id ~= game.JobId then
                            table.insert(servers, v.id)
                        end
                    end
                end
            end
        end

        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end

function Hub:RejoinServer()
    Hub:Notify("Rejoin", "جاري إعادة الاتصال بالسيرفر...", 2)
    pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end

Hub.IsFlying = false
function Hub:ToggleFly(state)
    Hub.IsFlying = state
    pcall(function()
        local bodyVel = HumanoidRootPart:FindFirstChild("OnHubFlyVelocity")
        local bodyGyro = HumanoidRootPart:FindFirstChild("OnHubFlyGyro")

        if state then
            if not bodyVel then
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.Name = "OnHubFlyVelocity"
                bodyVel.MaxForce = Vector3.new(4e5, 4e5, 4e5)
                bodyVel.Velocity = Vector3.new(0, 0.1, 0)
                bodyVel.Parent = HumanoidRootPart
            end

            if not bodyGyro then
                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.Name = "OnHubFlyGyro"
                bodyGyro.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
                bodyGyro.CFrame = HumanoidRootPart.CFrame
                bodyGyro.Parent = HumanoidRootPart
            end

            task.spawn(function()
                while Hub.IsFlying and HumanoidRootPart do
                    local camCFrame = Workspace.CurrentCamera.CFrame
                    local moveDir = Vector3.new()

                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                    bodyVel.Velocity = moveDir * 60
                    bodyGyro.CFrame = camCFrame
                    task.wait()
                end
                if bodyVel then bodyVel:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
            end)
        else
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end
    end)
end

Hub:CreateToggle(MiscPage, "Fly / Float Mod (طيران احتياطي)", false, function(state)
    Hub:ToggleFly(state)
end)

local HopBtn = Instance.new("TextButton")
HopBtn.Name = "ServerHopButton"
HopBtn.Size = UDim2.new(1, 0, 0, 38)
HopBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HopBtn.Text = "SERVER HOP (الانتقال لسيرفر آخر) 🌐"
HopBtn.Font = Enum.Font.SourceSansBold
HopBtn.TextSize = 13
HopBtn.Parent = MiscPage

local UICornerHop = Instance.new("UICorner")
UICornerHop.CornerRadius = UDim.new(0, 6)
UICornerHop.Parent = HopBtn

HopBtn.MouseButton1Click:Connect(function()
    Hub:ServerHop()
end)

local RejoinBtn = Instance.new("TextButton")
RejoinBtn.Name = "RejoinButton"
RejoinBtn.Size = UDim2.new(1, 0, 0, 38)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.Text = "REJOIN SERVER (إعادة الدخول) 🔄"
RejoinBtn.Font = Enum.Font.SourceSansBold
RejoinBtn.TextSize = 13
RejoinBtn.Parent = MiscPage

local UICornerRejoin = Instance.new("UICorner")
UICornerRejoin.CornerRadius = UDim.new(0, 6)
UICornerRejoin.Parent = RejoinBtn

RejoinBtn.MouseButton1Click:Connect(function()
    Hub:RejoinServer()
end)

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Name = "UnloadButton"
UnloadBtn.Size = UDim2.new(1, 0, 0, 38)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.Text = "DESTROY SCRIPT (إغلاق السكربت بالكامل) ❌"
UnloadBtn.Font = Enum.Font.SourceSansBold
UnloadBtn.TextSize = 13
UnloadBtn.Parent = MiscPage

local UICornerUnload = Instance.new("UICorner")
UICornerUnload.CornerRadius = UDim.new(0, 6)
UICornerUnload.Parent = UnloadBtn

UnloadBtn.MouseButton1Click:Connect(function()
    Hub.IsFarming = false
    Hub:ToggleFly(false)
    if CoreGui:FindFirstChild("HusseinOnHubMaster") then
        CoreGui.HusseinOnHubMaster:Destroy()
    end
    Hub:Notify("OnHub Unloaded", "تم إغلاق السكربت بنجاح.", 2)
end)

-- ==================================================
-- التشغيل الأولي والتكرار
-- ==================================================

-- تحديث الواجهة عند التشغيل
Hub:RefreshTargetsUI()

-- تحديث القائمة تلقائياً كل 5 ثوانٍ
task.spawn(function()
    while task.wait(5) do
        if not Hub.IsFarming then
            Hub:RefreshTargetsUI()
        end
    end
end)

Hub:Notify("Hussein Master OnHub", "تم تحميل السكربت بنجاح وبشكل كامل!", 3)
print("==================================================")
print("Hussein OnHub Edition - Full Script Loaded Successfully!")
print("==================================================")

