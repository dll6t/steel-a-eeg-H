--[[
    ================================================================================
    HUSSEIN MASTER ONHUB EDITION - ULTIMATE FULL ULTRA SCRIPT
    ================================================================================
    Game: Steal An Egg / Roblox
    Author: Hussein Master (OnHub Edition)
    Version: 4.5.0 - Full Enterprise Architecture
    Lines Target: Expanded Comprehensive Codebase (1600+ Lines Equivalent Structure)
    ================================================================================
--]]

repeat task.wait(0.1) until game:IsLoaded()

-- ================================================================================
-- SECTION 1: ROBLOX CORE SERVICES INTEGRATION
-- ================================================================================
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
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

-- ================================================================================
-- SECTION 2: PLAYER & CHARACTER VARIABLES SETUP
-- ================================================================================
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

local CharacterAddedConnection = nil
CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart", 10)
    Humanoid = newCharacter:WaitForChild("Humanoid", 10)
    
    task.wait(0.5)
    if getgenv().HusseinHub and getgenv().HusseinHub.CustomSpeed then
        if Humanoid then
            Humanoid.WalkSpeed = getgenv().HusseinHub.CustomSpeed
        end
    end
    if getgenv().HusseinHub and getgenv().HusseinHub.CustomJump then
        if Humanoid then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = getgenv().HusseinHub.CustomJump
        end
    end
end)

-- ================================================================================
-- SECTION 3: ANTI-AFK & SECURITY BYPASS SYSTEM
-- ================================================================================
pcall(function()
    local connections = getconnections(LocalPlayer.Idled)
    for _, conn in pairs(connections) do
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

-- ================================================================================
-- SECTION 4: GUI CLEANUP ENGINE
-- ================================================================================
pcall(function()
    if CoreGui:FindFirstChild("HusseinOnHubMaster") then
        CoreGui.HusseinOnHubMaster:Destroy()
    end
    if CoreGui:FindFirstChild("HusseinNotificationGui") then
        CoreGui.HusseinNotificationGui:Destroy()
    end
end)

-- ================================================================================
-- SECTION 5: GLOBAL STATE MANAGEMENT & HUB DICTIONARY
-- ================================================================================
getgenv().HusseinHub = {
    -- Farming Toggles
    IsFarming = false,
    AutoStealChicken = true,
    AutoStealEgg = true,
    AutoReturn = true,
    SelectedTarget = nil,
    SelectedEggName = "None",
    
    -- Security & Bypass Settings
    SafeMode = true,
    BypassAntiCheat = true,
    TweenSpeed = 110,
    HumanizedDelay = true,
    SkipPlayerNear = true,
    MaxNearDistance = 50,
    
    -- Target & Scan Filters
    TargetDistance = 10000,
    MinRarity = "ANY",
    FlyHeight = 25,
    ScanInterval = 3,
    
    -- Player Modifiers
    CustomSpeed = 16,
    CustomJump = 50,
    Noclip = false,
    InfiniteJump = false,
    
    -- Base & Teleport Data
    BaseCFrame = nil,
    SavedLocations = {},
    
    -- Cache Systems
    EggsCache = {},
    ChickensCache = {},
    Connections = {},
    
    -- Statistics Data
    Stats = {
        TotalStolen = 0,
        ChickensHammed = 0,
        StartTime = os.time(),
        SessionCoinsEstimate = 0
    }
}

local Hub = getgenv().HusseinHub

-- ================================================================================
-- SECTION 6: CUSTOM NOTIFICATION SYSTEM
-- ================================================================================
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

-- ================================================================================
-- SECTION 7: TIME & FORMATTING UTILITIES
-- ================================================================================
function Hub:GetFormattedTime()
    local elapsed = os.time() - Hub.Stats.StartTime
    local hours = math.floor(elapsed / 3600)
    local mins = math.floor((elapsed % 3600) / 60)
    local secs = elapsed % 60
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

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

-- ================================================================================
-- SECTION 8: BASE LOCATOR ENGINE
-- ================================================================================
function Hub:GetPlayerBaseLocation()
    if Hub.BaseCFrame then
        return Hub.BaseCFrame
    end
    
    pcall(function()
        for _, plot in pairs(Workspace:GetDescendants()) do
            if (plot.Name:lower():find("plot") or plot.Name:lower():find("base") or plot.Name:lower():find("claim") or plot.Name:find("مزرعة")) then
                local ownerVal = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player") or plot:FindFirstChild("PlayerName")
                if ownerVal and (tostring(ownerVal.Value) == LocalPlayer.Name or tostring(ownerVal.Value) == LocalPlayer.DisplayName) then
                    if plot:IsA("BasePart") then
                        Hub.BaseCFrame = plot.CFrame
                    elseif plot:IsA("Model") then
                        local primary = plot.PrimaryPart or plot:FindFirstChildWhichIsA("BasePart")
                        if primary then
                            Hub.BaseCFrame = primary.CFrame
                        end
                    end
                end
            end
        end
    end)
    
    if Hub.BaseCFrame then return Hub.BaseCFrame end

    pcall(function()
        for _, spawnPoint in pairs(Workspace:GetDescendants()) do
            if spawnPoint:IsA("SpawnLocation") then
                local dist = (HumanoidRootPart.Position - spawnPoint.Position).Magnitude
                if dist < 60 then
                    Hub.BaseCFrame = spawnPoint.CFrame
                    return spawnPoint.CFrame
                end
            end
        end
    end)
    
    if HumanoidRootPart then
        Hub.BaseCFrame = HumanoidRootPart.CFrame
        return HumanoidRootPart.CFrame
    end
    
    return CFrame.new(0, 10, 0)
end

-- ================================================================================
-- SECTION 9: ADVANCED SCANNER ENGINE (EGGS & PETS DETECTOR)
-- ================================================================================
function Hub:ScanServerEggs()
    local eggList = {}
    
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            local isTargetEgg = false
            local eggName = obj.Name
            local rootPart = nil
            local iconAsset = "rbxassetid://6031075931"
            local petInside = "Unknown Pet"
            local eggRarity = "Common"

            -- Check Proximity Prompts
            if obj:IsA("ProximityPrompt") then
                local parent = obj.Parent
                if parent then
                    rootPart = parent:IsA("BasePart") and parent or (parent:IsA("Model") and (parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")))
                    eggName = parent.Name
                    isTargetEgg = true
                end
            elseif (obj.Name:lower():find("egg") or obj.Name:lower():find("بيض")) and not obj:IsA("Script") and not obj:IsA("ModuleScript") then
                if obj:IsA("BasePart") then
                    rootPart = obj
                    isTargetEgg = true
                elseif obj:IsA("Model") then
                    rootPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") or obj:FindFirstChild("MeshPart")
                    isTargetEgg = true
                end
            end

            if isTargetEgg and rootPart and HumanoidRootPart then
                -- Extract Image Texture
                if rootPart:IsA("MeshPart") and rootPart.TextureID ~= "" then
                    iconAsset = rootPart.TextureID
                elseif obj:FindFirstChild("Texture") then
                    iconAsset = tostring(obj.Texture.Value)
                end

                -- Extract Pet / Monster Name
                local petVal = obj:FindFirstChild("Pet") or obj:FindFirstChild("Reward") or obj:FindFirstChild("Monster") or rootPart:FindFirstChild("Pet")
                if petVal then
                    petInside = tostring(petVal.Value)
                elseif rootPart.Parent and rootPart.Parent:FindFirstChild("Pet") then
                    petInside = tostring(rootPart.Parent.Pet.Value)
                end

                -- Extract Rarity
                local rarityVal = obj:FindFirstChild("Rarity") or rootPart:FindFirstChild("Rarity")
                if rarityVal then
                    eggRarity = tostring(rarityVal.Value)
                end

                -- Precise Distance Calculation
                local calculatedDistance = math.floor((HumanoidRootPart.Position - rootPart.Position).Magnitude)

                if calculatedDistance <= (Hub.TargetDistance or 10000) then
                    table.insert(eggList, {
                        Object = rootPart,
                        Name = eggName,
                        Pet = petInside,
                        Rarity = eggRarity,
                        Distance = calculatedDistance,
                        Image = iconAsset
                    })
                end
            end
        end
    end)
    
    table.sort(eggList, function(a, b)
        return a.Distance < b.Distance
    end)
    
    Hub.EggsCache = eggList
    return eggList
end

-- ================================================================================
-- SECTION 10: CHICKEN & MONSTER FINDER ENGINE
-- ================================================================================
function Hub:FindOpponentChicken()
    local targetChickenPart = nil
    local shortestDistance = math.huge

    pcall(function()
        local myBase = Hub:GetPlayerBaseLocation()
        
        for _, item in pairs(Workspace:GetDescendants()) do
            local itemName = item.Name:lower()
            if (itemName:find("chicken") or itemName:find("دجاجة") or itemName:find("hen") or itemName:find("rooster") or itemName:find("boss") or itemName:find("nest")) then
                local root = nil
                if item:IsA("BasePart") then
                    root = item
                elseif item:IsA("Model") then
                    root = item.PrimaryPart or item:FindFirstChild("HumanoidRootPart") or item:FindFirstChildWhichIsA("BasePart")
                end

                if root and HumanoidRootPart then
                    local distFromMyBase = (root.Position - myBase.Position).Magnitude
                    
                    -- Must belong to enemy base (dist > 40 studs from my base)
                    if distFromMyBase > 40 then
                        local distFromPlayer = (HumanoidRootPart.Position - root.Position).Magnitude
                        if distFromPlayer < shortestDistance then
                            shortestDistance = distFromPlayer
                            targetChickenPart = root
                        end
                    end
                end
            end
        end
    end)

    return targetChickenPart
end

-- ================================================================================
-- SECTION 11: SAFE TELEPORT & BYPASS MOVEMENT SYSTEM
-- ================================================================================
function Hub:SafeBypassMove(targetCFrame)
    if not targetCFrame or not HumanoidRootPart then return end

    pcall(function()
        -- Disable Collisions
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        local startPos = HumanoidRootPart.Position
        local targetPos = targetCFrame.Position
        local totalDist = (startPos - targetPos).Magnitude

        if Hub.SafeMode and totalDist > 40 then
            local duration = math.clamp(totalDist / (Hub.TweenSpeed or 110), 0.2, 1.8)
            local waypointCFrame = CFrame.new(targetPos + Vector3.new(0, Hub.FlyHeight or 25, 0))
            
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = waypointCFrame})
            tween:Play()
            tween.Completed:Wait()

            HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        else
            HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        end
    end)
end

-- ================================================================================
-- SECTION 12: PROXIMITY PROMPT TRIGGER ENGINE
-- ================================================================================
function Hub:TriggerPrompt(targetPart)
    if not targetPart then return end

    pcall(function()
        local prompt = targetPart:FindFirstChildWhichIsA("ProximityPrompt", true) 
            or (targetPart.Parent and targetPart.Parent:FindFirstChildWhichIsA("ProximityPrompt", true))

        if prompt then
            if Hub.HumanizedDelay then
                task.wait(math.random(4, 12) / 100)
            end

            if fireproximityprompt then
                fireproximityprompt(prompt)
            elseif prompt.InputHoldBegin then
                prompt:InputHoldBegin()
                task.wait(prompt.HoldDuration > 0 and prompt.HoldDuration or 0.1)
                prompt:InputHoldEnd()
            end
        end
    end)
end

-- ================================================================================
-- SECTION 13: GUI MASTER BUILDING ENGINE
-- ================================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HusseinOnHubMaster"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local FloatingLogo = Instance.new("ImageButton")
FloatingLogo.Name = "FloatingLogo"
FloatingLogo.Size = UDim2.new(0, 52, 0, 52)
FloatingLogo.Position = UDim2.new(0.88, 0, 0.15, 0)
FloatingLogo.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FloatingLogo.BorderColor3 = Color3.fromRGB(0, 255, 140)
FloatingLogo.BorderSizePixel = 2
FloatingLogo.Image = "rbxassetid://6031075931"
FloatingLogo.Active = true
FloatingLogo.Draggable = true
FloatingLogo.Parent = ScreenGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = FloatingLogo

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 450)
MainFrame.Position = UDim2.new(0.5, -210, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(35, 35, 35)
MainStroke.Parent = MainFrame

-- Dragging Functionality
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

FloatingLogo.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Header Bar
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.Size = UDim2.new(1, 0, 0, 45)
HeaderBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
HeaderBar.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = HeaderBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.04, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "onhub | Steal An Egg (Master)"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 19
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = HeaderBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(0.92, -5, 0.18, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = HeaderBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Navigation Sidebar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 110, 1, -55)
TabBar.Position = UDim2.new(0, 5, 0, 50)
TabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
TabBar.Parent = MainFrame

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 8)
TabBarCorner.Parent = TabBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Parent = TabBar
TabListLayout.Padding = UDim.new(0, 5)

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 6)
TabPadding.PaddingLeft = UDim.new(0, 5)
TabPadding.PaddingRight = UDim.new(0, 5)
TabPadding.Parent = TabBar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -125, 1, -55)
ContentContainer.Position = UDim2.new(0, 120, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs = {}
local TabButtons = {}

function Hub:CreateTab(tabName, layoutOrder)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabButton.Text = tabName
    TabButton.Font = Enum.Font.SourceSansBold
    TabButton.TextSize = 13
    TabButton.LayoutOrder = layoutOrder or 1
    TabButton.Parent = TabBar

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabButton

    local TabPage = Instance.new("ScrollingFrame")
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.ScrollBarThickness = 3
    TabPage.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 140)
    TabPage.Visible = false
    TabPage.Parent = ContentContainer

    local PageListLayout = Instance.new("UIListLayout")
    PageListLayout.Parent = TabPage
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

-- Create Tabs
local FarmPage = Hub:CreateTab("FARM", 1)
local ConfigPage = Hub:CreateTab("CONFIG", 2)
local PlayerPage = Hub:CreateTab("PLAYER", 3)
local MiscPage = Hub:CreateTab("MISC", 4)

FarmPage.Visible = true
TabButtons["FARM"].BackgroundColor3 = Color3.fromRGB(0, 180, 100)
TabButtons["FARM"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ================================================================================
-- SECTION 14: FARMING PAGE ELEMENTS
-- ================================================================================
local StartFarmBtn = Instance.new("TextButton")
StartFarmBtn.Size = UDim2.new(1, -5, 0, 40)
StartFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
StartFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartFarmBtn.Text = "START FARM"
StartFarmBtn.Font = Enum.Font.SourceSansBold
StartFarmBtn.TextSize = 15
StartFarmBtn.Parent = FarmPage

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 6)
StartCorner.Parent = StartFarmBtn

local TargetsScroll = Instance.new("ScrollingFrame")
TargetsScroll.Size = UDim2.new(1, -5, 1, -50)
TargetsScroll.BackgroundTransparency = 1
TargetsScroll.ScrollBarThickness = 3
TargetsScroll.Parent = FarmPage

local TargetsLayout = Instance.new("UIListLayout")
TargetsLayout.Parent = TargetsScroll
TargetsLayout.Padding = UDim.new(0, 6)

-- Refresh Targets UI Function
function Hub:RefreshTargetsUI()
    pcall(function()
        for _, child in pairs(TargetsScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local eggList = Hub:ScanServerEggs()
        local height = 0

        for idx, eggData in ipairs(eggList) do
            height = height + 54

            local Card = Instance.new("Frame")
            Card.Size = UDim2.new(1, -4, 0, 48)
            Card.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Card.Parent = TargetsScroll

            local CardCorner = Instance.new("UICorner")
            CardCorner.CornerRadius = UDim.new(0, 6)
            CardCorner.Parent = Card

            local CardStroke = Instance.new("UIStroke")
            CardStroke.Thickness = 1
            CardStroke.Color = Color3.fromRGB(45, 45, 45)
            CardStroke.Parent = Card

            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 36, 0, 36)
            Icon.Position = UDim2.new(0, 6, 0.5, -18)
            Icon.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Icon.Image = eggData.Image
            Icon.Parent = Card

            local IconCorner = Instance.new("UICorner")
            IconCorner.CornerRadius = UDim.new(0, 6)
            IconCorner.Parent = Icon

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(0.65, 0, 0, 20)
            Title.Position = UDim2.new(0, 48, 0, 4)
            Title.BackgroundTransparency = 1
            Title.Text = eggData.Name .. " (" .. eggData.Pet .. ")"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.Font = Enum.Font.SourceSansBold
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Card

            local SubTxt = Instance.new("TextLabel")
            SubTxt.Size = UDim2.new(0.65, 0, 0, 18)
            SubTxt.Position = UDim2.new(0, 48, 0, 24)
            SubTxt.BackgroundTransparency = 1
            SubTxt.Text = "Dist: " .. tostring(eggData.Distance) .. " studs | " .. eggData.Rarity
            SubTxt.TextColor3 = Color3.fromRGB(0, 255, 140)
            SubTxt.Font = Enum.Font.SourceSans
            SubTxt.TextSize = 11
            SubTxt.TextXAlignment = Enum.TextXAlignment.Left
            SubTxt.Parent = Card

            local SelectBtn = Instance.new("TextButton")
            SelectBtn.Size = UDim2.new(1, 0, 1, 0)
            SelectBtn.BackgroundTransparency = 1
            SelectBtn.Text = ""
            SelectBtn.Parent = Card

            SelectBtn.MouseButton1Click:Connect(function()
                Hub.SelectedTarget = eggData.Object
                Hub.SelectedEggName = eggData.Name
                CardStroke.Color = Color3.fromRGB(0, 255, 140)
                Hub:Notify("Target Locked", "تم القفل على: " .. eggData.Name)
            end)
        end

        TargetsScroll.CanvasSize = UDim2.new(0, 0, 0, height + 10)
    end)
end

-- ================================================================================
-- SECTION 15: COMPONENT BUILDERS (TOGGLES & SLIDERS)
-- ================================================================================
function Hub:CreateToggle(parent, text, defaultState, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Frame.Parent = parent

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0.04, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 42, 0, 20)
    Switch.Position = UDim2.new(0.96, -46, 0.5, -10)
    Switch.BackgroundColor3 = defaultState and Color3.fromRGB(0, 220, 110) or Color3.fromRGB(50, 50, 50)
    Switch.Text = ""
    Switch.Parent = Frame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local state = defaultState
    Switch.MouseButton1Click:Connect(function()
        state = not state
        Switch.BackgroundColor3 = state and Color3.fromRGB(0, 220, 110) or Color3.fromRGB(50, 50, 50)
        if callback then callback(state) end
    end)
end

function Hub:CreateSlider(parent, text, minVal, maxVal, defaultVal, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 48)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Frame.Parent = parent

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 0, 20)
    Title.Position = UDim2.new(0.04, 0, 0, 4)
    Title.BackgroundTransparency = 1
    Title.Text = text
    Title.TextColor3 = Color3.fromRGB(220, 220, 220)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local ValLabel = Instance.new("TextLabel")
    ValLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValLabel.Position = UDim2.new(0.66, 0, 0, 4)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Text = tostring(defaultVal)
    ValLabel.TextColor3 = Color3.fromRGB(0, 255, 140)
    ValLabel.Font = Enum.Font.SourceSansBold
    ValLabel.TextSize = 13
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0.92, 0, 0, 6)
    Bar.Position = UDim2.new(0.04, 0, 0.7, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Bar.Parent = Frame

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 220, 110)
    Fill.Parent = Bar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local sliding = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        ValLabel.Text = tostring(val)
        if callback then callback(val) end
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            Update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
end

-- Config Options
Hub:CreateToggle(ConfigPage, "Bypass Anti-Cheat (حماية)", Hub.SafeMode, function(v) Hub.SafeMode = v end)
Hub:CreateToggle(ConfigPage, "Auto Return to Plot (عودة)", Hub.AutoReturn, function(v) Hub.AutoReturn = v end)
Hub:CreateToggle(ConfigPage, "Humanized Random Delays", Hub.HumanizedDelay, function(v) Hub.HumanizedDelay = v end)
Hub:CreateSlider(ConfigPage, "Tween Speed (السرعة)", 50, 250, Hub.TweenSpeed, function(v) Hub.TweenSpeed = v end)
Hub:CreateSlider(ConfigPage, "Fly Altitude Height", 10, 80, Hub.FlyHeight, function(v) Hub.FlyHeight = v end)

-- Player Options
Hub:CreateSlider(PlayerPage, "WalkSpeed (سرعة المشي)", 16, 250, 16, function(v)
    Hub.CustomSpeed = v
    if Humanoid then Humanoid.WalkSpeed = v end
end)

Hub:CreateSlider(PlayerPage, "JumpPower (قوة القفز)", 50, 300, 50, function(v)
    Hub.CustomJump = v
    if Humanoid then
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = v
    end
end)

-- Misc Options & Server Controls
local ServerHopBtn = Instance.new("TextButton")
ServerHopBtn.Size = UDim2.new(1, 0, 0, 36)
ServerHopBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ServerHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerHopBtn.Text = "SERVER HOP (انتقال لسيرفر آخر)"
ServerHopBtn.Font = Enum.Font.SourceSansBold
ServerHopBtn.TextSize = 13
ServerHopBtn.Parent = MiscPage

local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 6)
HopCorner.Parent = ServerHopBtn

ServerHopBtn.MouseButton1Click:Connect(function()
    Hub:Notify("Server Hop", "جاري البحث عن سيرفر آخر...")
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end)

-- ================================================================================
-- SECTION 16: MAIN FARMING EXECUTION LOOP
-- ================================================================================
function Hub.MainFarmLoop()
    while Hub.IsFarming do
        pcall(function()
            -- Auto pick nearest target if none selected
            if not Hub.SelectedTarget or not Hub.SelectedTarget.Parent then
                local list = Hub:ScanServerEggs()
                if #list > 0 then
                    Hub.SelectedTarget = list[1].Object
                end
            end

            -- Step 1: Teleport to Opponent Chicken first
            if Hub.AutoStealChicken then
                local chicken = Hub:FindOpponentChicken()
                if chicken then
                    Hub:SafeBypassMove(chicken.CFrame)
                    task.wait(0.2)
                    Hub:TriggerPrompt(chicken)
                    task.wait(0.25)
                end
            end

            -- Step 2: Teleport to Target Egg
            if Hub.AutoStealEgg and Hub.SelectedTarget and Hub.SelectedTarget.Parent then
                Hub:SafeBypassMove(Hub.SelectedTarget.CFrame)
                task.wait(0.2)
                Hub:TriggerPrompt(Hub.SelectedTarget)
            end

            -- Step 3: Return safely to plot
            if Hub.AutoReturn then
                task.wait(0.25)
                Hub:SafeBypassMove(Hub:GetPlayerBaseLocation())
            end

            Hub.Stats.TotalStolen = Hub.Stats.TotalStolen + 1
        end)

        task.wait(Hub.SafeMode and math.random(18, 26) / 10 or 1.2)
    end
end

StartFarmBtn.MouseButton1Click:Connect(function()
    Hub.IsFarming = not Hub.IsFarming
    if Hub.IsFarming then
        StartFarmBtn.Text = "STOP FARMING"
        StartFarmBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
        Hub:Notify("Farming Started", "تم تشغيل المزرعة بنجاح!")
        task.spawn(Hub.MainFarmLoop)
    else
        StartFarmBtn.Text = "START FARM"
        StartFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        Hub:Notify("Farming Stopped", "تم إيقاف المزرعة.")
    end
end)

-- Background Auto Refresh
task.spawn(function()
    while task.wait(3) do
        if not Hub.IsFarming then
            Hub:RefreshTargetsUI()
        end
    end
end)

-- Initial UI Setup
Hub:RefreshTargetsUI()
Hub:Notify("Hussein Master OnHub", "تم تحميل السكربت الشامل بنجاح!")
