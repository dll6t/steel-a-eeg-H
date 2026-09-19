--[[
    ==================================================
    Steal An Egg - Advanced Master Hub V8
    Developer: Hussein
    Platform: Mobile / Android Executor Compatible
    Features: Auto Anti-Hit Teleport, Full Pet Stats Display
    ==================================================
--]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    Humanoid = newChar:WaitForChild("Humanoid")
end)

-- تنظيف أي واجهة سابقة
pcall(function()
    if CoreGui:FindFirstChild("HusseinMasterEggGui") then
        CoreGui.HusseinMasterEggGui:Destroy()
    end
end)

-- متغيّرات النظام
local TargetEggPart = nil
local SavedBaseCFrame = nil
local IsAntiHitActive = false

-- إنشاء الواجهة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HusseinMasterEggGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- زر فتح القائمة
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 130, 0, 40)
ToggleBtn.Position = UDim2.new(0.8, 0, 0.05, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleBtn.Text = "قائمة السكربت ☰"
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Parent = ScreenGui

local UICornerToggle = Instance.new("UICorner")
UICornerToggle.CornerRadius = UDim.new(0, 8)
UICornerToggle.Parent = ToggleBtn

-- الإطار الرئيسي للواجهة
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 420)
MainFrame.Position = UDim2.new(0.5, -180, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 12)
UICornerMain.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- عنوان الواجهة
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Text = "Hussein Egg Stealer - V8 Master"
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

-- بطاقة عرض معلومات الحيوان/البيضة
local CardFrame = Instance.new("Frame")
CardFrame.Size = UDim2.new(0.9, 0, 0, 130)
CardFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
CardFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CardFrame.Parent = MainFrame

local UICornerCard = Instance.new("UICorner")
UICornerCard.CornerRadius = UDim.new(0, 8)
UICornerCard.Parent = CardFrame

-- صورة الوحش / الحيوان
local PetImage = Instance.new("ImageLabel")
PetImage.Size = UDim2.new(0, 80, 0, 80)
PetImage.Position = UDim2.new(0.04, 0, 0.15, 0)
PetImage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PetImage.Image = "rbxassetid://0"
PetImage.Parent = CardFrame

local UICornerImg = Instance.new("UICorner")
UICornerImg.CornerRadius = UDim.new(0, 8)
UICornerImg.Parent = PetImage

-- نصوص المعلومات (الاسم، الرتبة، السعر/ثانية، المسافة)
local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(0.65, 0, 0, 22)
NameLabel.Position = UDim2.new(0.32, 0, 0.08, 0)
NameLabel.BackgroundTransparency = 1
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.Text = "اسم الوحش: --"
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Font = Enum.Font.SourceSansBold
NameLabel.TextSize = 13
NameLabel.Parent = CardFrame

local RarityLabel = Instance.new("TextLabel")
RarityLabel.Size = UDim2.new(0.65, 0, 0, 22)
RarityLabel.Position = UDim2.new(0.32, 0, 0.28, 0)
RarityLabel.BackgroundTransparency = 1
RarityLabel.TextColor3 = Color3.fromRGB(255, 170, 0) -- لون الرتبة
RarityLabel.Text = "النوع: (Eternal / Secret / Divine)"
RarityLabel.TextXAlignment = Enum.TextXAlignment.Left
RarityLabel.Font = Enum.Font.SourceSans
RarityLabel.TextSize = 12
RarityLabel.Parent = CardFrame

local IncomeLabel = Instance.new("TextLabel")
IncomeLabel.Size = UDim2.new(0.65, 0, 0, 22)
IncomeLabel.Position = UDim2.new(0.32, 0, 0.48, 0)
IncomeLabel.BackgroundTransparency = 1
IncomeLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
IncomeLabel.Text = "السعر/ثانية: -- $/s"
IncomeLabel.TextXAlignment = Enum.TextXAlignment.Left
IncomeLabel.Font = Enum.Font.SourceSansBold
IncomeLabel.TextSize = 12
IncomeLabel.Parent = CardFrame

local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Size = UDim2.new(0.65, 0, 0, 22)
DistanceLabel.Position = UDim2.new(0.32, 0, 0.68, 0)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.TextColor3 = Color3.fromRGB(170, 220, 255)
DistanceLabel.Text = "المسافة: -- متراً"
DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
DistanceLabel.Font = Enum.Font.SourceSans
DistanceLabel.TextSize = 12
DistanceLabel.Parent = CardFrame

-- قائمة اختيار البيض
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(0.9, 0, 0, 140)
ScrollList.Position = UDim2.new(0.05, 0, 0.43, 0)
ScrollList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ScrollList.CanvasSize = UDim2.new(0, 0, 5, 0)
ScrollList.ScrollBarThickness = 5
ScrollList.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = ScrollList
UIList.Padding = UDim.new(0, 3)

-- أزرار التحكم
local SaveBaseBtn = Instance.new("TextButton")
SaveBaseBtn.Size = UDim2.new(0.43, 0, 0, 35)
SaveBaseBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
SaveBaseBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
SaveBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBaseBtn.Text = "حفظ القاعدة 📌"
SaveBaseBtn.Font = Enum.Font.SourceSansBold
SaveBaseBtn.TextSize = 13
SaveBaseBtn.Parent = MainFrame

local UICornerBase = Instance.new("UICorner")
UICornerBase.CornerRadius = UDim.new(0, 6)
UICornerBase.Parent = SaveBaseBtn

local ToggleAntiHitBtn = Instance.new("TextButton")
ToggleAntiHitBtn.Size = UDim2.new(0.44, 0, 0, 35)
ToggleAntiHitBtn.Position = UDim2.new(0.51, 0, 0.78, 0)
ToggleAntiHitBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ToggleAntiHitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleAntiHitBtn.Text = "نظام الهروب: معطل ❌"
ToggleAntiHitBtn.Font = Enum.Font.SourceSansBold
ToggleAntiHitBtn.TextSize = 12
ToggleAntiHitBtn.Parent = MainFrame

local UICornerHit = Instance.new("UICorner")
UICornerHit.CornerRadius = UDim.new(0, 6)
UICornerHit.Parent = ToggleAntiHitBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.05, 0, 0.88, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "الحالة: حدد بيضة وسجل موقع القاعدة"
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame

-- ==================================================
-- الوظائف والمنطق البرمجي المعدل بالكامل
-- ==================================================

-- 1. فحص وقراءة بيانات الحيوانات والبيض من الماب
local function UpdateSelectedEggData(eggPart)
    TargetEggPart = eggPart
    if not eggPart then return end

    -- أ) اسم الوحش
    NameLabel.Text = "اسم الوحش: " .. eggPart.Name

    -- ب) استخراج الرتبة والدخل والصورة إن وجدت بداخل المجسم أو البيانات المربوطة
    local rarity = eggPart:FindFirstChild("Rarity") or eggPart:FindFirstChild("Type")
    local income = eggPart:FindFirstChild("Income") or eggPart:FindFirstChild("Price") or eggPart:FindFirstChild("Value")
    local img = eggPart:FindFirstChild("Texture") or eggPart:FindFirstChild("Icon") or eggPart:FindFirstChild("ImageId")

    RarityLabel.Text = "النوع: " .. (rarity and rarity.Value or "Secret / Divine")
    IncomeLabel.Text = "السعر/ثانية: " .. (income and tostring(income.Value) or "150K") .. " $/s"
    
    if img and img:IsA("Decal") then
        PetImage.Image = img.Texture
    elseif img and img:IsA("StringValue") then
        PetImage.Image = img.Value
    else
        PetImage.Image = "rbxassetid://6031075931" -- صورة افتراضية مرتبة
    end

    -- ج) حساب المسافة الحالية
    if HumanoidRootPart then
        local dist = math.floor((HumanoidRootPart.Position - eggPart.Position).Magnitude)
        DistanceLabel.Text = "المسافة: " .. tostring(dist) .. " متراً"
    end
end

-- 2. المسح الدائم للخريطة لتعبئة القائمة
local function ScanMapPrompts()
    pcall(function()
        for _, child in pairs(ScrollList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local parentPart = v.Parent
                if parentPart and parentPart:IsA("BasePart") then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -6, 0, 28)
                    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = parentPart.Name
                    btn.TextSize = 11
                    btn.Font = Enum.Font.SourceSans
                    btn.Parent = ScrollList

                    btn.MouseButton1Click:Connect(function()
                        UpdateSelectedEggData(parentPart)
                        StatusLabel.Text = "تم اختيار: " .. parentPart.Name
                    end)
                end
            end
        end
    end)
end

task.spawn(ScanMapPrompts)

-- 3. حفظ القاعدة
SaveBaseBtn.MouseButton1Click:Connect(function()
    if HumanoidRootPart then
        SavedBaseCFrame = HumanoidRootPart.CFrame
        StatusLabel.Text = "تم حفظ موقع القاعدة بنجاح! 📌"
    end
end)

-- 4. تنفيذ التيلبورت للسرقة والعودة الحقيقية
local function PerformEggSteal()
    if not TargetEggPart or not TargetEggPart.Parent then
        StatusLabel.Text = "اختر بيضة من القائمة أولاً!"
        return
    end

    StatusLabel.Text = "تم التفاعل مع الدجاجة! جاري التيلبورت للسرقة..."
    
    -- التيلبورت للبيضة
    HumanoidRootPart.CFrame = TargetEggPart.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.2)

    -- الضغط على ProximityPrompt
    local prompt = TargetEggPart:FindFirstChildWhichIsA("ProximityPrompt") or TargetEggPart.Parent:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    end

    task.wait(0.3)

    -- العودة للقاعدة المحفوظة لتجنب الموت
    if SavedBaseCFrame then
        HumanoidRootPart.CFrame = SavedBaseCFrame
        StatusLabel.Text = "تمت السرقة والعودة للقاعدة بنجاح! 🏆"
    else
        StatusLabel.Text = "تنبيه: لم تحفظ موقع القاعدة!"
    end
end

-- 5. تفعيل نظام مراقبة ضربة الدجاجة (Anti-Hit Teleport)
local healthConnection
ToggleAntiHitBtn.MouseButton1Click:Connect(function()
    IsAntiHitActive = not IsAntiHitActive
    if IsAntiHitActive then
        ToggleAntiHitBtn.Text = "نظام الهروب: شغال ✅"
        ToggleAntiHitBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        StatusLabel.Text = "الآن اذهب والدجاجة تضربك..."

        -- المراقبة عند انخفاض الدم (ضربة الدجاجة)
        healthConnection = Humanoid.HealthChanged:Connect(function(currentHealth)
            if currentHealth < Humanoid.MaxHealth and IsAntiHitActive then
                PerformEggSteal()
            end
        end)
    else
        ToggleAntiHitBtn.Text = "نظام الهروب: معطل ❌"
        ToggleAntiHitBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        StatusLabel.Text = "تم إيقاف نظام الهروب."
        if healthConnection then
            healthConnection:Disconnect()
        end
    end
end)

-- تحديث المسافة تلقائياً كل ثانية
task.spawn(function()
    while task.wait(1) do
        if TargetEggPart and HumanoidRootPart then
            local dist = math.floor((HumanoidRootPart.Position - TargetEggPart.Position).Magnitude)
            DistanceLabel.Text = "المسافة: " .. tostring(dist) .. " متراً"
        end
    end
end)
