local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean up existing instance if already running
if playerGui:FindFirstChild("WheelClickerGui") then
    playerGui.WheelClickerGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WheelClickerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local wheelButton = Instance.new("TextButton")
wheelButton.Name = "MouseWheelBtn"
wheelButton.Size = UDim2.new(0, 65, 0, 65)
wheelButton.Position = UDim2.new(0.5, 10, 0.4, 0)
wheelButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
wheelButton.BackgroundTransparency = 0.2
wheelButton.Text = "WHEEL"
wheelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
wheelButton.Font = Enum.Font.GothamBold
wheelButton.TextSize = 12
wheelButton.Active = true
wheelButton.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = wheelButton

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 170, 0)
stroke.Parent = wheelButton

-- Draggable Logic (Prevents clicking when dragging)
local dragging, dragStart, startPos = false, nil, nil
local hasMoved = false

wheelButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        hasMoved = false
        dragStart = input.Position
        startPos = wheelButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then 
                dragging = false 
            end
        end)
    end
end)

wheelButton.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then
            hasMoved = true -- Mark that the user is dragging, not clicking
        end
        wheelButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Click Action with Debounce (Prevents glitching / spam locking)
local isCooldown = false

wheelButton.MouseButton1Click:Connect(function()
    -- If the user was dragging the button, don't trigger a click
    if hasMoved then return end
    
    -- Prevent spam-glitching
    if isCooldown then return end
    isCooldown = true

    -- Perform middle mouse click safely
    pcall(function()
        local mouse = player:GetMouse()
        local vim = game:GetService("VirtualInputManager")
        -- Button index 2 represents the middle mouse click / wheel button
        vim:SendMouseButtonEvent(mouse.X, mouse.Y, 2, true, game, 0)
        task.wait(0.02)
        vim:SendMouseButtonEvent(mouse.X, mouse.Y, 2, false, game, 0)
    end)

    -- Small cool-down delay (0.15 seconds) before it can be pressed again
    task.wait(0.15)
    isCooldown = false
end)
