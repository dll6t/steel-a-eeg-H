--[[
====================================================================
  Steel Panel Custom V4 - Custom Egg/Pet Stealer GUI
  Design & Logic based on Hussein's Mockup (Image 22302)
====================================================================
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

pcall(function()
    if CoreGui:FindFirstChild("HusseinEggStealer") then
        CoreGui.HusseinEggStealer:Destroy()
    end
end)

-- 1. إنشاء واجهة المستخدم (UI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HusseinEggStealer"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

-- الزر المصغر (Open Menu +)
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenMenuButton"
openBtn.Size = UDim2.new(0, 150, 0, 40)
openBtn.Position = UDim2.new(0.8, 0, 0.05, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
openBtn.TextColor3 = Color3.fromRGB(255, 220, 0)
openBtn.Text = "Open menu +"
openBtn.TextSize, openBtn.Font = 18, Enum.Font.SourceSansBold
openBtn.Parent = screenGui

local cornerOpen = Instance.new("UICorner")
cornerOpen.CornerRadius = UDim.new(0, 8)
cornerOpen.Parent = openBtn

-- النافذة الرئيسية (اللوحة)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 360, 0, 280)
mainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(0, 10)
cornerMain.Parent = mainFrame

-- إغلاق/فتح القائمة
openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- 2. عناصر التصميم الخاصة برسمتك (الصورة 22302)

-- أ) مربع صورة الحيوان/البيضة (Top Left)
local petImage = Instance.new("ImageLabel")
petImage.Size = UDim2.new(0, 80, 0, 80)
petImage.Position = UDim2.new(0.04, 0, 0.05, 0)
petImage.BackgroundColor3 = Color3.fromRGB(70, 70, 50)
petImage.Image = "rbxassetid://6031075929" -- صورة افتراضية
petImage.Parent = mainFrame

local cornerImg = Instance.new("UICorner")
cornerImg.CornerRadius = UDim.new(0, 8)
cornerImg.Parent = petImage

-- ب) مربع اسم الحيوان (Top Center)
local petNameLabel = Instance.new("TextLabel")
petNameLabel.Size = UDim2.new(0, 180, 0, 80)
petNameLabel.Position = UDim2.new(0.3, 0, 0.05, 0)
petNameLabel.BackgroundColor3 = Color3.fromRGB(85, 85, 45)
petNameLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
petNameLabel.Text = "اسم الحيوان"
petNameLabel.TextSize, petNameLabel.Font = 18, Enum.Font.SourceSansBold
petNameLabel.Parent = mainFrame

local cornerName = Instance.new("UICorner")
cornerName.CornerRadius = UDim.new(0, 8)
cornerName.Parent = petNameLabel

-- ج) أيقونة الإشارة/الحفظ (Top Right Icon)
local bookmarkIcon = Instance.new("TextLabel")
bookmarkIcon.Size = UDim2.new(0, 35, 0, 45)
bookmarkIcon.Position = UDim2.new(0.84, 0, 0.05, 0)
bookmarkIcon.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
bookmarkIcon.Text = "🔖"
bookmarkIcon.TextSize = 22
bookmarkIcon.Parent = mainFrame

local cornerBookmark = Instance.new("UICorner")
cornerBookmark.CornerRadius = UDim.new(0, 6)
cornerBookmark.Parent = bookmarkIcon

-- د) قائمة الحيوانات المتاحة في السيرفر (Bottom Left ScrollingFrame)
local scrollList = Instance.new("ScrollingFrame")
scrollList.Size = UDim2.new(0, 220, 0, 140)
scrollList.Position = UDim2.new(0.04, 0, 0.4, 0)
scrollList.BackgroundColor3 = Color3.fromRGB(75, 75, 40)
scrollList.CanvasSize = UDim2.new(0, 0, 2, 0)
scrollList.ScrollBarThickness = 6
scrollList.Parent = mainFrame

local cornerScroll = Instance.new("UICorner")
cornerScroll.CornerRadius = UDim.new(0, 8)
cornerScroll.Parent = scrollList

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollList
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)

-- هـ) زر البدء (Start Button - Middle Right)
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0, 80, 0, 140)
startBtn.Position = UDim2.new(0.7, 0, 0.4, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(85, 85, 45)
startBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
startBtn.Text = "زر\nالبدء"
startBtn.TextSize, startBtn.Font = 18, Enum.Font.SourceSansBold
startBtn.Parent = mainFrame

local cornerStart = Instance.new("UICorner")
cornerStart.CornerRadius = UDim.new(0, 8)
cornerStart.Parent = startBtn

-- ====================================================================
-- 3. البرمجة والربط بالسيرفر (Server Scan & Steal Logic)
-- ====================================================================

local selectedEggObject = nil

-- وظيفة فحص وتحديث قائمة البيض في السيرفر
local function refreshEggList()
    for _, child in pairs(scrollList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local count = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (string.find(obj.Name:lower(), "egg") or string.find(obj.Name:lower(), "boss") or string.find(obj.Name:lower(), "pet")) then
            if obj.Transparency < 1 and obj.Size.Y > 0.3 then
                count = count + 1
                local itemBtn = Instance.new("TextButton")
                itemBtn.Size = UDim2.new(1, -8, 0, 30)
                itemBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 25)
                itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                itemBtn.Text = obj.Name
                itemBtn.TextSize = 13
                itemBtn.Font = Enum.Font.SourceSans
                itemBtn.Parent = scrollList

                itemBtn.MouseButton1Click:Connect(function()
                    selectedEggObject = obj
                    petNameLabel.Text = obj.Name
                    -- استبدال الصورة تلقائياً إن وجدت أو وضع الصورة التفاعلية
                    if obj:FindFirstChildOfClass("Decal") then
                        petImage.Image = obj:FindFirstChildOfClass("Decal").Texture
                    end
                end)
            end
        end
    end
end

-- تشغيل فحص السيرفر عند فتح السكربت
refreshEggList()

-- تنفيذ السرقة الفورية عند ضغط زر "البدء"
startBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if not humanoidRootPart then return end
        
        local target = selectedEggObject
        -- إذا لم يحدد المستخدم بيضة معينة، يتم اختيار أول بيضة من السيرفر
        if not target then
            refreshEggList()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(obj.Name:lower(), "egg") then
                    target = obj
                    break
                end
            end
        end

        if target then
            local oldPos = humanoidRootPart.CFrame
            -- النقل المباشر لموقع الحيوان/البيضة
            humanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 2, 0)
            
            -- تفعيل أي ProximityPrompt إن وجد
            local prompt = target:FindFirstChildOfClass("ProximityPrompt") or target.Parent:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end

            task.wait(0.2)
            -- العودة التلقائية
            humanoidRootPart.CFrame = oldPos
            petNameLabel.Text = "تمت السرقة! ✅"
        else
            petNameLabel.Text = "لم يتم العثور"
        end
    end)
end)
    end
end)

-- 1. بناء واجهة المستخدم الرئيسية (UI Framework)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SteelPanelUltimate"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- الزر المصغر (Open Menu Button)
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 160, 0, 48)
openButton.Position = UDim2.new(0.81, 0, 0.04, 0)
openButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
openButton.TextColor3 = Color3.fromRGB(0, 255, 127)
openButton.Text = "⚡ Steel Pro"
openButton.TextSize, openButton.Font = 18, Enum.Font.SourceSansBold
openButton.Parent = screenGui

local cornerOpen = Instance.new("UICorner")
cornerOpen.CornerRadius = UDim.new(0, 10)
cornerOpen.Parent = openButton

local strokeOpen = Instance.new("UIStroke")
strokeOpen.Color = Color3.fromRGB(0, 255, 127)
strokeOpen.Thickness = 1.5
strokeOpen.Parent = openButton

-- النافذة الرئيسية (Main Panel Frame)
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 290, 0, 360)
mainWindow.Position = UDim2.new(0.68, 0, 0.12, 0)
mainWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainWindow.BorderSizePixel = 0
mainWindow.Visible = false
mainWindow.Parent = screenGui

local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(0, 12)
cornerMain.Parent = mainWindow

local strokeMain = Instance.new("UIStroke")
strokeMain.Color = Color3.fromRGB(60, 60, 60)
strokeMain.Thickness = 1
strokeMain.Parent = mainWindow

-- شريط العنوان العلوي
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainWindow

local cornerTitle = Instance.new("UICorner")
cornerTitle.CornerRadius = UDim.new(0, 12)
cornerTitle.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "Steel Panel - النسخة الخارقة"
titleLabel.TextSize, titleLabel.Font = 15, Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- زر الإغلاق "X"
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 32, 0, 32)
closeButton.Position = UDim2.new(1, -38, 0, 6)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.TextSize, closeButton.Font = 15, Enum.Font.SourceSansBold
closeButton.Parent = titleBar

local cornerClose = Instance.new("UICorner")
cornerClose.CornerRadius = UDim.new(0, 8)
cornerClose.Parent = closeButton

-- 2. أزرار التحكم والوظائف داخل اللوحة
-- زر السرعة الخيالية (Speed Hack)
local speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(0, 250, 0, 45)
speedButton.Position = UDim2.new(0.5, -125, 0, 60)
speedButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.Text = "🚀 تفعيل السرعة الخيالية (130)"
speedButton.TextSize, speedButton.Font = 14, Enum.Font.SourceSansBold
speedButton.Parent = mainWindow

local cornerSpeed = Instance.new("UICorner")
cornerSpeed.CornerRadius = UDim.new(0, 8)
cornerSpeed.Parent = speedButton

-- زر السرقة المفردة الفورية
local stealButton = Instance.new("TextButton")
stealButton.Size = UDim2.new(0, 250, 0, 45)
stealButton.Position = UDim2.new(0.5, -125, 0, 115)
stealButton.BackgroundColor3 = Color3.fromRGB(0, 130, 60)
stealButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stealButton.Text = "🎯 سرقة البيضة فوراً والهروب"
stealButton.TextSize, stealButton.Font = 14, Enum.Font.SourceSansBold
stealButton.Parent = mainWindow

local cornerSteal = Instance.new("UICorner")
cornerSteal.CornerRadius = UDim.new(0, 8)
cornerSteal.Parent = stealButton

-- زر التشغيل التلقائي المستمر (Auto Farm)
local autoButton = Instance.new("TextButton")
autoButton.Size = UDim2.new(0, 250, 0, 45)
autoButton.Position = UDim2.new(0.5, -125, 0, 170)
autoButton.BackgroundColor3 = Color3.fromRGB(160, 95, 0)
autoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoButton.Text = "🔄 تشغيل الزراعة التلقائية (Auto)"
autoButton.TextSize, autoButton.Font = 14, Enum.Font.SourceSansBold
autoButton.Parent = mainWindow

local cornerAuto = Instance.new("UICorner")
cornerAuto.CornerRadius = UDim.new(0, 8)
cornerAuto.Parent = autoButton

-- زر حماية إضافي (Anti-Void / Safe Return)
local safeButton = Instance.new("TextButton")
safeButton.Size = UDim2.new(0, 250, 0, 45)
safeButton.Position = UDim2.new(0.5, -125, 0, 225)
safeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 90)
safeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
safeButton.Text = "🛡️ حفظ نقطة الأمان الحالية"
safeButton.TextSize, safeButton.Font = 14, Enum.Font.SourceSansBold
safeButton.Parent = mainWindow

local cornerSafe = Instance.new("UICorner")
cornerSafe.CornerRadius = UDim.new(0, 8)
cornerSafe.Parent = safeButton

-- شاشة عرض الحالة (Status Monitor)
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 35)
statusLabel.Position = UDim2.new(0, 0, 1, -38)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
statusLabel.Text = "الحالة: جاهز للتشغيل بأمان تام ✨"
statusLabel.TextSize, statusLabel.Font = 12, Enum.Font.SourceSansItalic
statusLabel.Parent = mainWindow

-- ====================================================================
-- 3. منطق البرمجة المتقدم ووظائف الحماية والتحكم
-- ====================================================================

-- فتح وإغلاق الواجهة بسلاسة
openButton.MouseButton1Click:Connect(function()
    openButton.Visible = false
    mainWindow.Visible = true
end)

closeButton.MouseButton1Click:Connect(function()
    mainWindow.Visible = false
    openButton.Visible = true
end)

-- نقطة الأمان الافتراضية
local customSafeCFrame = nil

safeButton.MouseButton1Click:Connect(function()
    pcall(function()
        if humanoidRootPart then
            customSafeCFrame = humanoidRootPart.CFrame
            statusLabel.Text = "الحالة: تم حفظ نقطة الأمان بنجاح! 📌"
            safeButton.BackgroundColor3 = Color3.fromRGB(20, 110, 20)
        end
    end)
end)

-- تفعيل السرعة الخيالية
speedButton.MouseButton1Click:Connect(function()
    pcall(function()
        if humanoid then
            humanoid.WalkSpeed = 130
            speedButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            statusLabel.Text = "الحالة: تم تفعيل السرعة القصوى!"
        end
    end)
end)

-- وظيفة السرقة الذكية الآمنة (Advanced Steal Logic)
local function executeSteal()
    pcall(function()
        if not humanoidRootPart or not character then return end
        
        -- اعتماد نقطة الأمان المخزنة أو أخذ المكان الحالي كاحتياط
        local safePos = customSafeCFrame or humanoidRootPart.CFrame
        
        -- البحث المتقدم عن البيضة في الخريطة
        local targetEgg = nil
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (string.find(obj.Name:lower(), "egg") or string.find(obj.Name:lower(), "chicken")) then
                -- التحقق من أن الجزء نشط وقابل للوصول
                if obj.Transparency < 1 then
                    targetEgg = obj
                    break
                end
            end
        end
        
        if targetEgg then
            statusLabel.Text = "الحالة: جاري سحب البيضة فوراً..."
            -- الانتقال لموقع البيضة بدقة مع تجنب الاصطدام الفوري
            humanoidRootPart.CFrame = targetEgg.CFrame + Vector3.new(0, 2.5, 0)
            
            -- مهلة زمنية دقيقة جداً لتسجيل أمر السرقة من قبل السيرفر
            task.wait(0.12)
            
            -- العودة الفورية الفائقة لمكان الأمان لتفادي ضربات البوس
            humanoidRootPart.CFrame = safePos
            statusLabel.Text = "الحالة: تمت السرقة والعودة بأمان تام! 🏆"
        else
            statusLabel.Text = "الحالة: لم يتم العثور على بيضة نشطة حالياً."
        end
    end)
end

stealButton.MouseButton1Click:Connect(executeSteal)

-- نظام الزراعة والتكرار التلقائي (Auto-Farm Loop)
local autoFarmActive = false
autoButton.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    if autoFarmActive then
        autoButton.Text = "⏹️ إيقاف الزراعة التلقائية"
        autoButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        statusLabel.Text = "الحالة: نظام التلقائي يعمل في الخلفية..."
        
        task.spawn(function()
            while autoFarmActive do
                executeSteal()
                task.wait(2.2) -- فاصل زمني آمن لضمان عدم حظر الحساب أو التسبب بلاغ
            end
        end)
    else
        autoButton.Text = "🔄 تشغيل الزراعة التلقائية (Auto)"
        autoButton.BackgroundColor3 = Color3.fromRGB(160, 95, 0)
        statusLabel.Text = "الحالة: تم إيقاف الزراعة التلقائية."
    end
end)
