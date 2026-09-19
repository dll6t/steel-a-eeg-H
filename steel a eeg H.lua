--[[
  Steel Panel V5 - Final Clean Working Build
  Developer: Hussein
--]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

pcall(function()
    if CoreGui:FindFirstChild("HusseinEggGui") then
        CoreGui.HusseinEggGui:Destroy()
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HusseinEggGui"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenMenuButton"
openBtn.Size = UDim2.new(0, 140, 0, 40)
openBtn.Position = UDim2.new(0.8, 0, 0.05, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
openBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
openBtn.Text = "Open menu +"
openBtn.TextSize = 16
openBtn.Font = Enum.Font.SourceSansBold
openBtn.Parent = screenGui

local cornerOpen = Instance.new("UICorner")
cornerOpen.CornerRadius = UDim.new(0, 8)
cornerOpen.Parent = openBtn

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 340, 0, 260)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(0, 10)
cornerMain.Parent = mainFrame

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0, 200, 0, 60)
nameLabel.Position = UDim2.new(0.05, 0, 0.08, 0)
nameLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 40)
nameLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
nameLabel.Text = "حدد البيضة من القائمة"
nameLabel.TextSize = 16
nameLabel.Font = Enum.Font.SourceSansBold
nameLabel.Parent = mainFrame

local cornerName = Instance.new("UICorner")
cornerName.CornerRadius = UDim.new(0, 8)
cornerName.Parent = nameLabel

local scrollList = Instance.new("ScrollingFrame")
scrollList.Size = UDim2.new(0, 200, 0, 150)
scrollList.Position = UDim2.new(0.05, 0, 0.35, 0)
scrollList.BackgroundColor3 = Color3.fromRGB(65, 65, 35)
scrollList.CanvasSize = UDim2.new(0, 0, 3, 0)
scrollList.ScrollBarThickness = 6
scrollList.Parent = mainFrame

local cornerScroll = Instance.new("UICorner")
cornerScroll.CornerRadius = UDim.new(0, 8)
cornerScroll.Parent = scrollList

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollList
listLayout.Padding = UDim.new(0, 4)

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0, 90, 0, 120)
startBtn.Position = UDim2.new(0.68, 0, 0.35, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 40)
startBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
startBtn.Text = "زر\nالبدء"
startBtn.TextSize = 20
startBtn.Font = Enum.Font.SourceSansBold
startBtn.Parent = mainFrame

local cornerStart = Instance.new("UICorner")
cornerStart.CornerRadius = UDim.new(0, 8)
cornerStart.Parent = startBtn

local targetEggPart = nil

local function scanEggs()
    pcall(function()
        for _, item in pairs(scrollList:GetChildren()) do
            if item:IsA("TextButton") then
                item:Destroy()
            end
        end

        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and (string.find(v.Name:lower(), "egg") or string.find(v.Name:lower(), "boss") or string.find(v.Name:lower(), "chicken")) then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -6, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(45, 45, 20)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Text = v.Name
                btn.TextSize = 13
                btn.Font = Enum.Font.SourceSans
                btn.Parent = scrollList

                btn.MouseButton1Click:Connect(function()
                    targetEggPart = v
                    nameLabel.Text = v.Name
                end)
            end
        end
    end)
end

task.spawn(scanEggs)

startBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if not humanoidRootPart then return end
        
        if targetEggPart and targetEggPart.Parent then
            local safePos = humanoidRootPart.CFrame
            humanoidRootPart.CFrame = targetEggPart.CFrame + Vector3.new(0, 2, 0)
            
            task.wait(0.2)
            humanoidRootPart.CFrame = safePos
            nameLabel.Text = "تمت السرقة! ✅"
        else
            scanEggs()
            nameLabel.Text = "اختر بيضة من القائمة"
        end
    end)
end)
