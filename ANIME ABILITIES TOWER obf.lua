local Players = game:GetService("Players")
local player = Players.LocalPlayer
local currentPlaceId = game.PlaceId

-- ============================================
-- ОПРЕДЕЛЕНИЕ РЕЖИМА
-- ============================================
local gameMode = "unknown"
if currentPlaceId == 127124731990410 then
    gameMode = "pro"
elseif currentPlaceId == 138738806137319 then
    gameMode = "slap"
elseif currentPlaceId == 103661214879860 then
    gameMode = "noob"
end

-- ============================================
-- ФУНКЦИЯ УВЕДОМЛЕНИЯ
-- ============================================
local function showFullscreenNotification(message, duration)
    duration = duration or 3
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "FullscreenNotification"
    notificationGui.ResetOnSpawn = false
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    notificationGui.IgnoreGuiInset = true
    notificationGui.DisplayOrder = 999999
    notificationGui.Parent = player:WaitForChild("PlayerGui")
    
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.4
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 100
    overlay.Parent = notificationGui
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 100)
    textLabel.Position = UDim2.new(0, 0, 0.5, -50)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 28
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true
    textLabel.ZIndex = 101
    textLabel.Parent = notificationGui
    
    task.spawn(function()
        task.wait(duration)
        if notificationGui then notificationGui:Destroy() end
    end)
end

-- ============================================
-- ПОИСК БЕЙДЖЕЙ (для любого режима)
-- ============================================
local function findAllBadgeTouches()
    local touches = {}
    
    local activeObstacle = workspace:FindFirstChild("ActiveAnimeObstacle")
    if activeObstacle then
        for _, character in pairs(activeObstacle:GetChildren()) do
            local badge = character:FindFirstChild("BadgeAwarder")
            if badge then
                local touch = badge:FindFirstChild("TouchInterest")
                if touch then table.insert(touches, touch) end
            end
        end
    end
    
    local towerSections = workspace:FindFirstChild("TowerSections")
    if towerSections then
        for _, section in pairs(towerSections:GetChildren()) do
            for _, obj in pairs(section:GetDescendants()) do
                if obj.Name == "BadgeAwarder" then
                    local touch = obj:FindFirstChild("TouchInterest")
                    if touch then table.insert(touches, touch) end
                end
            end
        end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "BadgeAwarder" then
            local touch = obj:FindFirstChild("TouchInterest")
            if touch then table.insert(touches, touch) end
        end
    end
    
    return touches
end

-- ============================================
-- ПОИСК ФИНИША (только для Slap Tower)
-- ============================================
local function getFinishTouch()
    if gameMode ~= "slap" then return nil end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Finish" and obj:FindFirstChild("GiveWinScript") then
            local touch = obj:FindFirstChild("TouchInterest")
            if not touch then
                touch = obj:FindFirstChild("Parts") and obj.Parts:FindFirstChild("Finish") and obj.Parts.Finish:FindFirstChild("TouchInterest")
            end
            return touch
        end
    end
    return nil
end

-- ============================================
-- АКТИВАЦИЯ
-- ============================================
local function activateTouch(touch)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and touch then
        pcall(function() firetouchinterest(hrp, touch.Parent, 0) end)
    end
end

local function resetChar()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then pcall(function() hum.Health = 0 end) end
    end
end

-- ============================================
-- GUI (ПОЛНОЕ МЕНЮ)
-- ============================================
local gui, menuBtn, mainFrame, finishBtn, badgeBtn, statusLabel, delaySlider, delayLabel
local finishActive = false
local badgeActive = false
local delayValue = 1

local function copyToClipboard(text)
    pcall(function() game:GetService("ClipboardService"):Set(text) end)
end

local function showCopyableLink(message, link)
    if not gui then return end
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 280, 0, 120)
    notification.Position = UDim2.new(0.5, -140, 0, 0)
    notification.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    notification.BorderSizePixel = 0
    notification.ZIndex = 40
    notification.Parent = gui

    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -20, 0, 30)
    notifTitle.Position = UDim2.new(0, 10, 0, 10)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = message
    notifTitle.TextColor3 = Color3.new(1, 1, 1)
    notifTitle.TextSize = 16
    notifTitle.Font = Enum.Font.SourceSansBold
    notifTitle.ZIndex = 41
    notifTitle.Parent = notification

    local linkBox = Instance.new("TextBox")
    linkBox.Size = UDim2.new(1, -20, 0, 40)
    linkBox.Position = UDim2.new(0, 10, 0, 45)
    linkBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    linkBox.Text = link
    linkBox.TextColor3 = Color3.new(0, 0, 0)
    linkBox.TextSize = 12
    linkBox.Font = Enum.Font.SourceSans
    linkBox.TextXAlignment = Enum.TextXAlignment.Center
    linkBox.TextYAlignment = Enum.TextYAlignment.Center
    linkBox.ClearTextOnFocus = false
    linkBox.TextEditable = false
    linkBox.ZIndex = 41
    linkBox.Parent = notification

    local instructionText = Instance.new("TextLabel")
    instructionText.Size = UDim2.new(1, -20, 0, 20)
    instructionText.Position = UDim2.new(0, 10, 0, 90)
    instructionText.BackgroundTransparency = 1
    instructionText.Text = "Click to select, Ctrl+C to copy"
    instructionText.TextColor3 = Color3.fromRGB(220, 220, 220)
    instructionText.TextSize = 12
    instructionText.Font = Enum.Font.SourceSans
    instructionText.ZIndex = 41
    instructionText.Parent = notification

    task.spawn(function()
        task.wait(6)
        if notification.Parent then notification:Destroy() end
    end)
end

local function ensureGui()
    if gui and gui.Parent then return end

    gui = Instance.new("ScreenGui")
    gui.Name = "AnimeAbilitiesTower"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = player:WaitForChild("PlayerGui")

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 260, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -130, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.ZIndex = 20
    mainFrame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 36)
    title.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    title.BorderSizePixel = 0
    title.Text = "Anime Abilities Tower"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.ZIndex = 21
    title.Parent = mainFrame

    finishBtn = Instance.new("TextButton")
    finishBtn.Size = UDim2.new(1, -20, 0, 40)
    finishBtn.Position = UDim2.new(0, 10, 0, 50)
    finishBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    finishBtn.TextColor3 = Color3.new(1, 1, 1)
    finishBtn.TextSize = 16
    finishBtn.Font = Enum.Font.SourceSansBold
    finishBtn.Text = "🔴 FINISH LOOP (OFF)"
    finishBtn.ZIndex = 21
    finishBtn.Parent = mainFrame

    badgeBtn = Instance.new("TextButton")
    badgeBtn.Size = UDim2.new(1, -20, 0, 40)
    badgeBtn.Position = UDim2.new(0, 10, 0, 100)
    badgeBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    badgeBtn.TextColor3 = Color3.new(1, 1, 1)
    badgeBtn.TextSize = 16
    badgeBtn.Font = Enum.Font.SourceSansBold
    badgeBtn.Text = "🔴 BADGE LOOP (OFF)"
    badgeBtn.ZIndex = 21
    badgeBtn.Parent = mainFrame

    delayLabel = Instance.new("TextLabel")
    delayLabel.Size = UDim2.new(1, -20, 0, 20)
    delayLabel.Position = UDim2.new(0, 10, 0, 155)
    delayLabel.BackgroundTransparency = 1
    delayLabel.Text = "Delay: 0.3s"
    delayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    delayLabel.TextSize = 12
    delayLabel.Font = Enum.Font.SourceSans
    delayLabel.TextXAlignment = Enum.TextXAlignment.Left
    delayLabel.ZIndex = 21
    delayLabel.Parent = mainFrame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 20)
    sliderFrame.Position = UDim2.new(0, 10, 0, 175)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ZIndex = 21
    sliderFrame.Parent = mainFrame

    delaySlider = Instance.new("TextButton")
    delaySlider.Size = UDim2.new(0, 20, 1, 0)
    delaySlider.Position = UDim2.new(0, 0, 0, 0)
    delaySlider.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    delaySlider.BorderSizePixel = 0
    delaySlider.Text = ""
    delaySlider.ZIndex = 22
    delaySlider.Parent = sliderFrame

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 200)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Ready"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 12
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.TextWrapped = true
    statusLabel.ZIndex = 21
    statusLabel.Parent = mainFrame

    local authorLabel = Instance.new("TextButton")
    authorLabel.Size = UDim2.new(1, -20, 0, 40)
    authorLabel.Position = UDim2.new(0, 10, 0, 240)
    authorLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    authorLabel.Text = "Made by: onexale/whyalucy\nClick to copy Socials link"
    authorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    authorLabel.TextSize = 12
    authorLabel.Font = Enum.Font.SourceSans
    authorLabel.TextWrapped = true
    authorLabel.ZIndex = 21
    authorLabel.Parent = mainFrame

    local function updateDelaySlider()
        local scale = delayValue / 5
        delaySlider.Position = UDim2.new(scale, -10, 0, 0)
        delayLabel.Text = "Delay: " .. string.format("%.1f", delayValue) .. "s"
    end
    sliderFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateDelaySlider)

    local function updateVisual()
        if finishActive then
            finishBtn.Text = "🟢 FINISH LOOP (ON)"
            finishBtn.BackgroundColor3 = Color3.fromRGB(80, 170, 80)
        else
            finishBtn.Text = "🔴 FINISH LOOP (OFF)"
            finishBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        end
        
        if badgeActive then
            badgeBtn.Text = "🟢 BADGE LOOP (ON)"
            badgeBtn.BackgroundColor3 = Color3.fromRGB(80, 170, 80)
        else
            badgeBtn.Text = "🔴 BADGE LOOP (OFF)"
            badgeBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        end
        
        statusLabel.Text = (finishActive or badgeActive) and "Status: Looping..." or "Status: Ready"
    end

    menuBtn = Instance.new("TextButton")
    menuBtn.Size = UDim2.new(0, 80, 0, 32)
    menuBtn.Position = UDim2.new(0, 12, 0, 80)
    menuBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    menuBtn.Text = "Menu"
    menuBtn.TextColor3 = Color3.new(1, 1, 1)
    menuBtn.Font = Enum.Font.SourceSansBold
    menuBtn.TextSize = 16
    menuBtn.BorderSizePixel = 0
    menuBtn.ZIndex = 30
    menuBtn.Parent = gui

    local UserInputService = game:GetService("UserInputService")
    local dragToggle, dragStart, startPos

    local function connectDrag(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragToggle = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)
        frame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragToggle = false
            end
        end)
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragToggle then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)
    end

    connectDrag(mainFrame)
    connectDrag(menuBtn)

    menuBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    finishBtn.MouseButton1Click:Connect(function()
        if gameMode ~= "slap" then
            showFullscreenNotification("FINISH LOOP works only in Slap Tower!", 2)
            return
        end
        finishActive = not finishActive
        updateVisual()
    end)

    badgeBtn.MouseButton1Click:Connect(function()
        badgeActive = not badgeActive
        updateVisual()
    end)

    local sliderDragging = false
    local function updateSlider(input)
        local mouseX = input.Position.X
        local frameX = sliderFrame.AbsolutePosition.X
        local frameW = sliderFrame.AbsoluteSize.X
        if frameW > 0 then
            local rel = math.max(0, math.min(mouseX - frameX, frameW))
            delayValue = (rel / frameW) * 5
            updateDelaySlider()
        end
    end

    delaySlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliderDragging = true
            updateSlider(input)
        end
    end)
    delaySlider.InputEnded:Connect(function() sliderDragging = false end)
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliderDragging = true
            updateSlider(input)
        end
    end)
    sliderFrame.InputEnded:Connect(function() sliderDragging = false end)
    sliderFrame.InputChanged:Connect(function(input)
        if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    authorLabel.MouseButton1Click:Connect(function()
        local link = "https://whyalucy.github.io/RXSCRIPTS.html"
        copyToClipboard(link)
        showCopyableLink("Socials Link:", link)
    end)

    authorLabel.MouseEnter:Connect(function()
        authorLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        authorLabel.TextColor3 = Color3.new(1, 1, 1)
    end)

    authorLabel.MouseLeave:Connect(function()
        authorLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        authorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)

    updateVisual()
    updateDelaySlider()
end

ensureGui()

-- ============================================
-- ЦИКЛЫ
-- ============================================
task.spawn(function()
    while true do
        if finishActive and gameMode == "slap" then
            local touch = getFinishTouch()
            if touch then
                activateTouch(touch)
                task.wait(0.5)
                resetChar()
            end
        end
        task.wait(delayValue)
    end
end)

task.spawn(function()
    while true do
        if badgeActive then
            local touches = findAllBadgeTouches()
            for _, touch in pairs(touches) do
                activateTouch(touch)
            end
        end
        task.wait(delayValue)
    end
end)
