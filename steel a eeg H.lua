--[[
  Steel Panel V6 - Custom Game-Matched UI
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
    if CoreGui:FindFirstChild("HusseinCustomGui") then
        CoreGui.HusseinCustomGui:Destroy()
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HusseinCustomGui"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenMenuButton"
openBtn.Size = UDim2.new(0, 150, 0, 45)
openBtn.Position = UDim2.new(0.82, 0, 0.05, 0)
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
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0.68, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(0, 12)
cornerMain.Parent = mainFrame

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "X"
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame

local cornerClose = Instance.new("UICorner")
cornerClose.CornerRadius = UDim.new(0, 6)
cornerClose.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

local petImage = Instance.new("ImageLabel")
petImage.Size = UDim2.new(0, 120, 0, 120)
petImage.Position = UDim2.new(0.5, -60, 0.05, 0)
petImage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
petImage.Image = "rbxassetid://0"
petImage.Parent = mainFrame

local cornerPet = Instance.new("UICorner")
cornerPet.CornerRadius = UDim.new(0, 12)
cornerPet.Parent = petImage

local petName = Instance.new("TextLabel")
petName.Size = UDim2.new(1, -20, 0, 40)
petName.Position = UDim2.new(0.1, 0, 0.4, 0)
petName.BackgroundTransparency = 1
petName.TextColor3 = Color3.fromRGB(255, 255, 255)
petName.Text = "اسم البيضة"
petName.TextSize = 20
petName.Font = Enum.Font.SourceSansBold
petName.Parent = mainFrame

local petIncome = Instance.new("TextLabel")
petIncome.Size = UDim2.new(1, -20, 0, 40)
petIncome.Position = UDim2.new(0.1, 0, 0.5, 0)
petIncome.BackgroundTransparency = 1
petIncome.TextColor3 = Color3.fromRGB(100, 255, 100)
petIncome.Text = "الدخل: $0/s"
petIncome.TextSize = 18
petIncome.Font = Enum.Font.SourceSansBold
petIncome.Parent = mainFrame

local scrollList = Instance.new("ScrollingFrame")
scrollList.Size = UDim2.new(1, -40, 0, 120)
scrollList.Position = UDim2.new(0.05, 0, 0.65, 0)
scrollList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollList.CanvasSize = UDim2.new(0, 0, 4, 0)
scrollList.ScrollBarThickness = 6
scrollList.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollList
listLayout.Padding = UDim.new(0, 4)

local targetEggPart = nil

local function scanEggs()
    pcall(function()
        for _, item in pairs(scrollList:GetChildren()) do
            if item:IsA("TextButton") then
                item:Destroy()
            end
        end

        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local parentPart = v.Parent
                if parentPart and parentPart:IsA("BasePart") then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -6, 0, 30)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Text = parentPart.Name
                    btn.TextSize = 13
                    btn.Font = Enum.Font.SourceSans
                    btn.Parent = scrollList

                    btn.MouseButton1Click:Connect(function()
                        targetEggPart = parentPart
                        petName.Text = parentPart.Name
                        petIncome.Text = "تم التحديد: " .. parentPart.Name
                    end)
                end
            end
        end
    end)
end

task.spawn(scanEggs)

local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(1, -40, 0, 40)
stealBtn.Position = UDim2.new(0.05, 0, 0.58, 0)
stealBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
stealBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stealBtn.Text = "سرقة البيضة"
stealBtn.TextSize = 18
stealBtn.Font = Enum.Font.SourceSansBold
stealBtn.Parent = mainFrame

local cornerSteal = Instance.new("UICorner")
cornerSteal.CornerRadius = UDim.new(0, 8)
cornerSteal.Parent = stealBtn

stealBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if not humanoidRootPart or not targetEggPart then return end
        
        local safePos = humanoidRootPart.CFrame
        humanoidRootPart.CFrame = targetEggPart.CFrame + Vector3.new(0, 2, 0)
        
        local prompt = targetEggPart:FindFirstChildWhichIsA("ProximityPrompt") or targetEggPart.Parent:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            fireproximityprompt(prompt)
        end
        
        task.wait(0.2)
        humanoidRootPart.CFrame = safePos
    end)
end)

