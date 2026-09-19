--[[
    ==================================================
    Steal An Egg - Auto Best Egg Stealer V9
    Developer: Hussein
    Platform: Android Executor Compatible
    Features: Auto Find Best Egg, Auto Chicken Hit, Instant Teleport
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

-- تنظيف الواجهات السابقة
pcall(function()
    if CoreGui:FindFirstChild("HusseinAutoEggGui") then
        CoreGui.HusseinAutoEggGui:Destroy()
    end
end)

local SavedBaseCFrame = nil
local IsAutoStealActive = false
local BestEggPart = nil

-- إنشاء الواجهة الرسمية المبسطة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HusseinAutoEggGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 260)
MainFrame.Position = UDim2.new(0.5, -160, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Text = "Steal An Egg - Auto Best V9"
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local InfoBox = Instance.new("Frame")
InfoBox.Size = UDim2.new(0.9, 0, 0, 80)
InfoBox.Position = UDim2.new(0.05, 0, 0.2, 0)
InfoBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InfoBox.Parent = MainFrame

local UICornerBox = Instance.new("UICorner")
UICornerBox.CornerRadius = UDim.new(0, 8)
UICornerBox.Parent = InfoBox

local EggNameLabel = Instance.new("TextLabel")
EggNameLabel.Size = UDim2.new(1, -10, 0, 35)
EggNameLabel.Position = UDim2.new(0.02, 0, 0.05, 0)
EggNameLabel.BackgroundTransparency = 1
EggNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
EggNameLabel.Text = "أقوى بيضة: جاري البحث..."
EggNameLabel.Font = Enum.Font.SourceSansBold
EggNameLabel.TextSize = 14
EggNameLabel.Parent = InfoBox

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 30)
StatusLabel.Position = UDim2.new(0.02, 0, 0.5, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.Text = "الحالة: احفظ القاعدة ثم شغل التلقائي"
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 12
StatusLabel.Parent = InfoBox

local SaveBaseBtn = Instance.new("TextButton")
SaveBaseBtn.Size = UDim2.new(0.9, 0, 0, 35)
SaveBaseBtn.Position = UDim2.new(0.05, 0, 0.56, 0)
SaveBaseBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 180)
SaveBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBaseBtn.Text = "📌 حفظ موقع القاعدة الحالية"
SaveBaseBtn.Font = Enum.Font.SourceSansBold
SaveBaseBtn.TextSize = 13
SaveBaseBtn.Parent = MainFrame

local UICornerSave = Instance.new("UICorner")
UICornerSave.CornerRadius = UDim.new(0, 6)
UICornerSave.Parent = SaveBaseBtn

local AutoStartBtn = Instance.new("TextButton")
AutoStartBtn.Size = UDim2.new(0.9, 0, 0, 40)
AutoStartBtn.Position = UDim2.new(0.05, 0, 0.74, 0)
AutoStartBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
AutoStartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoStartBtn.Text = "⚡ تفعيل السرقة التلقائية لـ (أقوى بيضة)"
AutoStartBtn.Font = Enum.Font.SourceSansBold
AutoStartBtn.TextSize = 13
AutoStartBtn.Parent = MainFrame

local UICornerStart = Instance.new("UICorner")
UICornerStart.CornerRadius = UDim.new(0, 6)
UICornerStart.Parent = AutoStartBtn

-- ==================================================
-- المنطق البرمجي الذكي للتعرف والسرقة التلقائية
-- ==================================================

-- 1. البحث عن أقوى بيضة بالخريطة تلقائياً
local function FindBestEggInServer()
    local highestValue = -1
    local bestObj = nil
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Parent and v.Parent:IsA("BasePart") then
            local part = v.Parent
            local val = part:FindFirstChild("Income") or part:FindFirstChild("Value") or part:FindFirstChild("Price")
            
            if val and tonumber(val.Value) then
                if val.Value > highestValue then
                    highestValue = val.Value
                    bestObj = part
                end
            elseif not bestObj then
                bestObj = part -- اختيار أول بيضة متاحة كاحتياط
            end
        end
    end
    
    if bestObj then
        BestEggPart = bestObj
        EggNameLabel.Text = "أقوى بيضة: " .. bestObj.Name
    else
        EggNameLabel.Text = "أقوى بيضة: لم يتم العثور على بيض!"
    end
end

task.spawn(function()
    while task.wait(3) do
        if not IsAutoStealActive then
            FindBestEggInServer()
        end
    end
end)

-- 2. حفظ موقع القاعدة
SaveBaseBtn.MouseButton1Click:Connect(function()
    if HumanoidRootPart then
        SavedBaseCFrame = HumanoidRootPart.CFrame
        StatusLabel.Text = "تم حفظ القاعدة بنجاح! ✅"
    end
end)

-- 3. البحث عن موقع الدجاجة/البوس
local function FindChickenPart()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("chicken") or v.Name:lower():find("boss") or v.Name:find("دجاجة") then
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                return v.HumanoidRootPart
            elseif v:IsA("BasePart") then
                return v
            end
        end
    end
    return nil
end

-- 4. تنشيط السرقة التلقائية عند التفعيل
local healthConn
AutoStartBtn.MouseButton1Click:Connect(function()
    IsAutoStealActive = not IsAutoStealActive
    
    if IsAutoStealActive then
        if not SavedBaseCFrame then
            StatusLabel.Text = "⚠️ يرجى حفظ القاعدة أولاً!"
            IsAutoStealActive = false
            return
        end
        
        AutoStartBtn.Text = "⏹️ إيقاف النظام التلقائي"
        AutoStartBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        StatusLabel.Text = "جاري الذهاب للدجاجة لتلقي الضربة..."
        
        -- أ) الذهاب للدجاجة تلقائياً
        local chicken = FindChickenPart()
        if chicken then
            HumanoidRootPart.CFrame = chicken.CFrame + Vector3.new(0, 2, 3)
        end

        -- ب) المراقبة فور ضرب الدجاجة والتعرض للضرر
        healthConn = Humanoid.HealthChanged:Connect(function(hp)
            if hp < Humanoid.MaxHealth and IsAutoStealActive then
                StatusLabel.Text = "تمت الضربة! جاري السرقة والتيلبورت..."
                
                -- التيلبورت فوراً لأقوى بيضة
                if BestEggPart then
                    HumanoidRootPart.CFrame = BestEggPart.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.15)
                    
                    local prompt = BestEggPart:FindFirstChildWhichIsA("ProximityPrompt") or BestEggPart.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        fireproximityprompt(prompt)
                    end
                end
                
                -- العودة فوراً للقاعدة بأمان
                task.wait(0.2)
                HumanoidRootPart.CFrame = SavedBaseCFrame
                StatusLabel.Text = "تمت العملية بنجاح والعودة للقاعدة! 🏆"
            end
        end)
    else
        AutoStartBtn.Text = "⚡ تفعيل السرقة التلقائية لـ (أقوى بيضة)"
        AutoStartBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        StatusLabel.Text = "تم إيقاف النظام."
        if healthConn then healthConn:Disconnect() end
    end
end)
