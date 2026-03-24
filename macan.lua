-- ============================================
-- CONTAINER RNG - compact UI, full logic (PlayerGui, Menu, title drag, Discord)
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local unpackArgs = table.unpack

local AUTHOR_DISCORD_LINK = "http://discordapp.com/users/715915325421518958"

-- GUI (main)
local gui = Instance.new("ScreenGui")
gui.Name = "ContainerRNG"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Top-layer GUI for Discord toast (above other scripts' ScreenGuis)
local toastGui = Instance.new("ScreenGui")
toastGui.Name = "ContainerRNG_Toast"
toastGui.ResetOnSpawn = false
toastGui.IgnoreGuiInset = true
toastGui.DisplayOrder = 2147483647
toastGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
toastGui.Parent = localPlayer.PlayerGui

-- Compact panel (same palette as before: dark blue-gray frame, Gotham buttons)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 300, 0, 520)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
mainFrame.BackgroundTransparency = 0.08
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
mainFrame.Visible = false

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Title (drag handle)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎲 CONTAINER RNG"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
title.Active = true

-- Layout: each row = [feature button] then [delay box below, indented right]
-- Row step: 30px btn + 5px gap + 22px slider = 57px per feature block
local fastEButton = Instance.new("TextButton")
fastEButton.Size = UDim2.new(0.85, 0, 0, 30)
fastEButton.Position = UDim2.new(0.075, 0, 0, 38)
fastEButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
fastEButton.Text = "⚡ FAST E 🔴 OFF"
fastEButton.TextColor3 = Color3.fromRGB(255, 255, 255)
fastEButton.TextScaled = true
fastEButton.Font = Enum.Font.GothamBold
fastEButton.Parent = mainFrame
Instance.new("UICorner", fastEButton).CornerRadius = UDim.new(0, 8)

local fastESlider = Instance.new("TextBox")
fastESlider.Size = UDim2.new(0.62, 0, 0, 22)
fastESlider.Position = UDim2.new(0.2, 0, 0, 73)
fastESlider.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
fastESlider.Text = "10"
fastESlider.TextColor3 = Color3.fromRGB(255, 255, 255)
fastESlider.PlaceholderText = "sec"
fastESlider.Font = Enum.Font.Gotham
fastESlider.TextScaled = true
fastESlider.Parent = mainFrame
Instance.new("UICorner", fastESlider).CornerRadius = UDim.new(0, 6)

local containerButton = Instance.new("TextButton")
containerButton.Size = UDim2.new(0.85, 0, 0, 30)
containerButton.Position = UDim2.new(0.075, 0, 0, 95)
containerButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
containerButton.Text = "📦 CONTAINER 🔴 OFF"
containerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
containerButton.TextScaled = true
containerButton.Font = Enum.Font.GothamBold
containerButton.Parent = mainFrame
Instance.new("UICorner", containerButton).CornerRadius = UDim.new(0, 8)

local containerSlider = Instance.new("TextBox")
containerSlider.Size = UDim2.new(0.62, 0, 0, 22)
containerSlider.Position = UDim2.new(0.2, 0, 0, 130)
containerSlider.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
containerSlider.Text = "1"
containerSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
containerSlider.PlaceholderText = "sec"
containerSlider.Font = Enum.Font.Gotham
containerSlider.TextScaled = true
containerSlider.Parent = mainFrame
Instance.new("UICorner", containerSlider).CornerRadius = UDim.new(0, 6)

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0.85, 0, 0, 30)
openButton.Position = UDim2.new(0.075, 0, 0, 152)
openButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
openButton.Text = "🔓 AUTO OPEN 🔴 OFF"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextScaled = true
openButton.Font = Enum.Font.GothamBold
openButton.Parent = mainFrame
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 8)

local openSlider = Instance.new("TextBox")
openSlider.Size = UDim2.new(0.62, 0, 0, 22)
openSlider.Position = UDim2.new(0.2, 0, 0, 187)
openSlider.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
openSlider.Text = "0.1"
openSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
openSlider.PlaceholderText = "sec"
openSlider.Font = Enum.Font.Gotham
openSlider.TextScaled = true
openSlider.Parent = mainFrame
Instance.new("UICorner", openSlider).CornerRadius = UDim.new(0, 6)

local collectButton = Instance.new("TextButton")
collectButton.Size = UDim2.new(0.85, 0, 0, 30)
collectButton.Position = UDim2.new(0.075, 0, 0, 209)
collectButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
collectButton.Text = "🎁 AUTO COLLECT 🔴 OFF"
collectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
collectButton.TextScaled = true
collectButton.Font = Enum.Font.GothamBold
collectButton.Parent = mainFrame
Instance.new("UICorner", collectButton).CornerRadius = UDim.new(0, 8)

local collectSlider = Instance.new("TextBox")
collectSlider.Size = UDim2.new(0.62, 0, 0, 22)
collectSlider.Position = UDim2.new(0.2, 0, 0, 244)
collectSlider.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
collectSlider.Text = "0.05"
collectSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
collectSlider.PlaceholderText = "sec"
collectSlider.Font = Enum.Font.Gotham
collectSlider.TextScaled = true
collectSlider.Parent = mainFrame
Instance.new("UICorner", collectSlider).CornerRadius = UDim.new(0, 6)

local autoBuyButton = Instance.new("TextButton")
autoBuyButton.Size = UDim2.new(0.85, 0, 0, 30)
autoBuyButton.Position = UDim2.new(0.075, 0, 0, 266)
autoBuyButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
autoBuyButton.Text = "🎲 AUTO BUY 🔴 OFF"
autoBuyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBuyButton.TextScaled = true
autoBuyButton.Font = Enum.Font.GothamBold
autoBuyButton.Parent = mainFrame
Instance.new("UICorner", autoBuyButton).CornerRadius = UDim.new(0, 8)

local autoBuySlider = Instance.new("TextBox")
autoBuySlider.Size = UDim2.new(0.62, 0, 0, 22)
autoBuySlider.Position = UDim2.new(0.2, 0, 0, 301)
autoBuySlider.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
autoBuySlider.Text = "5"
autoBuySlider.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBuySlider.PlaceholderText = "sec"
autoBuySlider.Font = Enum.Font.Gotham
autoBuySlider.TextScaled = true
autoBuySlider.Parent = mainFrame
Instance.new("UICorner", autoBuySlider).CornerRadius = UDim.new(0, 6)

local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(0.85, 0, 0, 28)
resetButton.Position = UDim2.new(0.075, 0, 0, 334)
resetButton.BackgroundColor3 = Color3.fromRGB(80, 70, 50)
resetButton.Text = "🔄 RESET CACHE"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.TextScaled = true
resetButton.Font = Enum.Font.Gotham
resetButton.Parent = mainFrame
Instance.new("UICorner", resetButton).CornerRadius = UDim.new(0, 8)

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(0.85, 0, 0, 34)
infoText.Position = UDim2.new(0.075, 0, 0, 372)
infoText.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
infoText.BackgroundTransparency = 0.5
infoText.Text = "📊 Opened: 0 | Collected: 0"
infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
infoText.TextScaled = true
infoText.Font = Enum.Font.Gotham
infoText.Parent = mainFrame
Instance.new("UICorner", infoText).CornerRadius = UDim.new(0, 8)

local authorLabel = Instance.new("TextButton")
authorLabel.Position = UDim2.new(0.075, 0, 0, 416)
authorLabel.Size = UDim2.new(0.85, 0, 0, 30)
authorLabel.BackgroundTransparency = 0.8
authorLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
authorLabel.Text = "Made by: onexale/whyalucy\nClick to copy Discord"
authorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
authorLabel.TextSize = 11
authorLabel.Font = Enum.Font.SourceSans
authorLabel.TextXAlignment = Enum.TextXAlignment.Center
authorLabel.TextYAlignment = Enum.TextYAlignment.Center
authorLabel.BorderSizePixel = 0
authorLabel.Parent = mainFrame
Instance.new("UICorner", authorLabel).CornerRadius = UDim.new(0, 5)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0.85, 0, 0, 30)
closeButton.Position = UDim2.new(0.075, 0, 0, 454)
closeButton.BackgroundColor3 = Color3.fromRGB(80, 50, 55)
closeButton.Text = "❌ CLOSE"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.Gotham
closeButton.Parent = mainFrame
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 8)

-- Floating Menu button
local menuBtn = Instance.new("TextButton")
menuBtn.Position = UDim2.new(0, 10, 0, 10)
menuBtn.Size = UDim2.new(0, 80, 0, 35)
menuBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
menuBtn.TextColor3 = Color3.new(1, 1, 1)
menuBtn.Text = "Menu"
menuBtn.Font = Enum.Font.SourceSansBold
menuBtn.TextSize = 16
menuBtn.BorderSizePixel = 0
menuBtn.Parent = gui
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0, 8)

-- ============================================
-- State
-- ============================================
local loops = {
    fastE = false,
    container = false,
    autoOpen = false,
    autoCollect = false,
    autoBuy = false,
}

local delays = {
    fastE = 10,
    container = 1,
    autoOpen = 0.1,
    autoCollect = 0.05,
    autoBuy = 5,
}

local SESSION_ID = "751225821"
local openedCounter = 0
local collectedCounter = 0
local lastPrintTime = 0

-- Full unload: stop loops + disconnect globals + destroy all GUI
local scriptRunning = true
local connDescendants = nil
local connUISDragMain = nil
local connUISDragMenu = nil

local function unloadScript()
    scriptRunning = false
    loops.fastE = false
    loops.container = false
    loops.autoOpen = false
    loops.autoCollect = false
    loops.autoBuy = false

    if connDescendants then
        connDescendants:Disconnect()
        connDescendants = nil
    end
    if connUISDragMain then
        connUISDragMain:Disconnect()
        connUISDragMain = nil
    end
    if connUISDragMenu then
        connUISDragMenu:Disconnect()
        connUISDragMenu = nil
    end

    pcall(function()
        if toastGui and toastGui.Parent then
            toastGui:Destroy()
        end
    end)
    pcall(function()
        if gui and gui.Parent then
            gui:Destroy()
        end
    end)
    pcall(function()
        script:Destroy()
    end)

    print("[CONTAINER RNG] Fully unloaded")
end

-- Blacklists (from deepseekdaun)
local permanentBlacklist = {
    "USE DEX TO FIND OUT WHICH PLANT ID TO ADD TO THE BLACKLIST: workspace.Gameplay.Plots['SESSION_ID'].PlotLogic.ItemCache",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
}

local dynamicBlacklist = {}

local function isBlacklisted(itemId)
    for _, id in ipairs(permanentBlacklist) do
        if itemId == id then
            return true
        end
    end
    for _, id in ipairs(dynamicBlacklist) do
        if itemId == id then
            return true
        end
    end
    return false
end

local function resetDynamicBlacklist()
    dynamicBlacklist = {}
    print("[CACHE] Dynamic pickup blacklist cleared")
    resetButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
    task.delay(0.2, function()
        resetButton.BackgroundColor3 = Color3.fromRGB(80, 70, 50)
    end)
end

-- Remote (cached after first resolve)
local reliableRemote = nil
local function getReliableRemote()
    if reliableRemote then
        return reliableRemote
    end
    local ok, r = pcall(function()
        return ReplicatedStorage:WaitForChild("Modules", 15)
            :WaitForChild("Shared", 15)
            :WaitForChild("Warp", 15)
            :WaitForChild("Index", 15)
            :WaitForChild("Event", 15)
            :WaitForChild("Reliable", 15)
    end)
    if ok and r then
        reliableRemote = r
    end
    return reliableRemote
end

-- ============================================
-- Game logic
-- ============================================
local function applyFastE()
    for _, prompt in ipairs(game:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = 0
        end
    end
end

connDescendants = game.DescendantAdded:Connect(function(obj)
    if not scriptRunning then
        return
    end
    if loops.fastE and obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end)

local function spawnContainer()
    local remote = getReliableRemote()
    if not remote then
        return
    end
    local args = {
        buffer.fromstring("H"),
        buffer.fromstring("\254\001\000\006\fEggContainer"),
    }
    pcall(function()
        remote:FireServer(unpackArgs(args))
    end)
end

local function findAndOpenContainers()
    local player = Players.LocalPlayer
    local character = player and player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return 0
    end

    local plots = workspace:FindFirstChild("Gameplay") and workspace.Gameplay:FindFirstChild("Plots")
    if not plots then
        return 0
    end
    local playerPlot = plots:FindFirstChild(SESSION_ID)
    if not playerPlot then
        return 0
    end
    local plotLogic = playerPlot:FindFirstChild("PlotLogic")
    if not plotLogic then
        return 0
    end
    local containerHolder = plotLogic:FindFirstChild("ContainerHolder")
    if not containerHolder then
        return 0
    end

    local openedNow = 0
    for _, container in pairs(containerHolder:GetChildren()) do
        if container:IsA("Folder") or container:IsA("Model") then
            local doorHolder = container:FindFirstChild("DoorProximityHolder")
                or (container:FindFirstChild("ContainerLogic") and container.ContainerLogic:FindFirstChild("DoorProximityHolder"))
            if doorHolder then
                for _, obj in pairs(doorHolder:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        pcall(function()
                            fireproximityprompt(obj)
                            openedNow = openedNow + 1
                            openedCounter = openedCounter + 1
                        end)
                    end
                end
            end
        end
    end
    if openedNow == 0 then
        for _, obj in pairs(containerHolder:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                pcall(function()
                    fireproximityprompt(obj)
                    openedNow = openedNow + 1
                    openedCounter = openedCounter + 1
                end)
            end
        end
    end
    return openedNow
end

local function collectItems()
    local player = Players.LocalPlayer
    local character = player and player.Character
    if not character then
        return 0
    end

    local plots = workspace:FindFirstChild("Gameplay") and workspace.Gameplay:FindFirstChild("Plots")
    if not plots then
        return 0
    end
    local playerPlot = plots:FindFirstChild(SESSION_ID)
    if not playerPlot then
        return 0
    end
    local plotLogic = playerPlot:FindFirstChild("PlotLogic")
    if not plotLogic then
        return 0
    end
    local itemCache = plotLogic:FindFirstChild("ItemCache")
    if not itemCache then
        return 0
    end

    local collectedNow = 0

    for _, item in pairs(itemCache:GetChildren()) do
        local itemName = item.Name
        if not (itemName and string.sub(itemName, 1, 5) == "ITEM_") then
            continue
        end
        if isBlacklisted(itemName) then
            continue
        end
        if item:FindFirstChild("FlowerUI") then
            continue
        end

        local primaryPart = item:FindFirstChild("PrimaryPart")
        if primaryPart and primaryPart:FindFirstChild("FlowerUI") then
            continue
        end

        if primaryPart then
            local promptAttachment = primaryPart:FindFirstChild("PickupPromptAttachment")
            if promptAttachment then
                local prompt = promptAttachment:FindFirstChild("ProximityPrompt")
                if prompt and prompt:IsA("ProximityPrompt") then
                    pcall(function()
                        fireproximityprompt(prompt)
                        collectedNow = collectedNow + 1
                        collectedCounter = collectedCounter + 1
                        table.insert(dynamicBlacklist, itemName)
                    end)
                end
            end
        end
    end

    -- Extra pickup points (skip plants)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "BestItemPivotPoint" then
            local isPlantItem = false
            local parent = obj.Parent
            while parent do
                if parent:FindFirstChild("FlowerUI") then
                    isPlantItem = true
                    break
                end
                parent = parent.Parent
            end
            if not isPlantItem then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    pcall(function()
                        fireproximityprompt(prompt)
                        collectedNow = collectedNow + 1
                        collectedCounter = collectedCounter + 1
                    end)
                end
            end
        end
    end

    return collectedNow
end

-- Auto buy (same remote as deepseekdaun)
local function buyDice(diceName)
    local remote = getReliableRemote()
    if not remote then
        warn("[AUTO BUY] Remote not found (game still loading?)")
        return
    end
    local fullName = diceName
    if diceName == "DarkMatterDice" then
        fullName = "\014DarkMatterDice"
    elseif diceName == "QuantumDice" then
        fullName = "\vQuantumDice"
    elseif diceName == "PlasmaDice" then
        fullName = "\nPlasmaDice"
    end
    local args = {
        buffer.fromstring(":"),
        buffer.fromstring("\254\001\000\006" .. fullName),
    }
    pcall(function()
        remote:FireServer(unpackArgs(args))
        print("[AUTO BUY] Dice:", diceName)
    end)
end

local function buyPotion(potionName)
    local remote = getReliableRemote()
    if not remote then
        return
    end
    local fullName = potionName
    if potionName == "MutationLuckPotion2" then
        fullName = "\023MutationLuckPotion2"
    elseif potionName == "MutationLuckPotion1" then
        fullName = "\023MutationLuckPotion1"
    end
    local args = {
        buffer.fromstring("&"),
        buffer.fromstring("\254\001\000\006" .. fullName),
    }
    pcall(function()
        remote:FireServer(unpackArgs(args))
        print("[AUTO BUY] Potion:", potionName)
    end)
end

local function autoBuyAll()
    buyDice("DarkMatterDice")
    buyDice("QuantumDice")
    buyDice("PlasmaDice")
    buyPotion("MutationLuckPotion2")
    buyPotion("MutationLuckPotion1")
end

-- ============================================
-- Clipboard + Discord toast
-- ============================================
local function copyToClipboard(text)
    pcall(function()
        if type(setclipboard) == "function" then
            setclipboard(text)
        end
    end)
    pcall(function()
        game:GetService("ClipboardService"):Set(text)
    end)
end

local function showCopyableLink(message, link)
    if not scriptRunning or not toastGui or not toastGui.Parent then
        return
    end
    for _, child in ipairs(toastGui:GetChildren()) do
        child:Destroy()
    end

    local notification = Instance.new("Frame")
    notification.Name = "DiscordToast"
    notification.Parent = toastGui
    notification.Position = UDim2.new(0.5, -180, 0, -120)
    notification.Size = UDim2.new(0, 360, 0, 108)
    notification.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    notification.BorderSizePixel = 0
    notification.ZIndex = 100000
    local nc = Instance.new("UICorner", notification)
    nc.CornerRadius = UDim.new(0, 10)
    local nt = Instance.new("TextLabel", notification)
    nt.Size = UDim2.new(1, 0, 0, 30)
    nt.BackgroundTransparency = 1
    nt.Text = message
    nt.TextColor3 = Color3.new(1, 1, 1)
    nt.TextSize = 16
    nt.Font = Enum.Font.SourceSansBold
    nt.ZIndex = 100001
    local lb = Instance.new("TextBox", notification)
    lb.Size = UDim2.new(1, -20, 0, 36)
    lb.Position = UDim2.new(0, 10, 0, 36)
    lb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    lb.Text = link
    lb.TextColor3 = Color3.new(0, 0, 0)
    lb.TextSize = 11
    lb.ClearTextOnFocus = false
    lb.TextEditable = false
    lb.ZIndex = 100001
    Instance.new("UICorner", lb).CornerRadius = UDim.new(0, 5)
    local hint = Instance.new("TextLabel", notification)
    hint.Size = UDim2.new(1, 0, 0, 22)
    hint.Position = UDim2.new(0, 0, 0, 78)
    hint.BackgroundTransparency = 1
    hint.Text = "Tap the link above to select and copy"
    hint.TextColor3 = Color3.fromRGB(200, 200, 200)
    hint.TextSize = 11
    hint.Font = Enum.Font.SourceSans
    hint.ZIndex = 100001
    notification:TweenPosition(UDim2.new(0.5, -180, 0, 20), "Out", "Quad", 0.5)
    task.delay(8, function()
        if not scriptRunning or not notification.Parent then
            return
        end
        notification:TweenPosition(UDim2.new(0.5, -180, 0, -120), "Out", "Quad", 0.5)
        task.wait(0.5)
        if notification.Parent then
            notification:Destroy()
        end
    end)
end

-- ============================================
-- Loops
-- ============================================
task.spawn(function()
    while scriptRunning do
        if loops.fastE then
            applyFastE()
        end
        task.wait(delays.fastE)
    end
end)

task.spawn(function()
    while scriptRunning do
        if loops.container then
            pcall(spawnContainer)
        end
        task.wait(delays.container)
    end
end)

task.spawn(function()
    while scriptRunning do
        if loops.autoOpen then
            pcall(findAndOpenContainers)
        end
        task.wait(delays.autoOpen)
    end
end)

task.spawn(function()
    while scriptRunning do
        if loops.autoCollect then
            pcall(collectItems)
        end
        if scriptRunning and infoText.Parent then
            infoText.Text = "📊 Opened: " .. openedCounter .. " | Collected: " .. collectedCounter
        end
        if scriptRunning and loops.autoCollect and tick() - lastPrintTime > 10 then
            print("[COLLECT] Total collected:", collectedCounter)
            lastPrintTime = tick()
        end
        task.wait(delays.autoCollect)
    end
end)

task.spawn(function()
    while scriptRunning do
        if loops.autoBuy then
            pcall(autoBuyAll)
        end
        task.wait(delays.autoBuy)
    end
end)

-- ============================================
-- Buttons
-- ============================================
fastEButton.MouseButton1Click:Connect(function()
    loops.fastE = not loops.fastE
    if loops.fastE then
        fastEButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
        fastEButton.Text = "⚡ FAST E 🟢 ON"
        applyFastE()
    else
        fastEButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        fastEButton.Text = "⚡ FAST E 🔴 OFF"
    end
end)

fastESlider.FocusLost:Connect(function()
    local val = tonumber(fastESlider.Text)
    if val and val > 0 then
        delays.fastE = val
        print("[FAST E] Delay:", val, "sec")
    else
        fastESlider.Text = tostring(delays.fastE)
    end
end)

containerButton.MouseButton1Click:Connect(function()
    loops.container = not loops.container
    if loops.container then
        containerButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
        containerButton.Text = "📦 CONTAINER 🟢 ON"
    else
        containerButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        containerButton.Text = "📦 CONTAINER 🔴 OFF"
    end
end)

containerSlider.FocusLost:Connect(function()
    local val = tonumber(containerSlider.Text)
    if val and val > 0 then
        delays.container = val
        print("[CONTAINER] Delay:", val, "sec")
    else
        containerSlider.Text = tostring(delays.container)
    end
end)

openButton.MouseButton1Click:Connect(function()
    loops.autoOpen = not loops.autoOpen
    if loops.autoOpen then
        openButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
        openButton.Text = "🔓 AUTO OPEN 🟢 ON"
        print("[AUTO OPEN] Enabled")
    else
        openButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        openButton.Text = "🔓 AUTO OPEN 🔴 OFF"
        print("[AUTO OPEN] Disabled")
    end
end)

openSlider.FocusLost:Connect(function()
    local val = tonumber(openSlider.Text)
    if val and val > 0 then
        delays.autoOpen = val
        print("[AUTO OPEN] Delay:", val, "sec")
    else
        openSlider.Text = tostring(delays.autoOpen)
    end
end)

collectButton.MouseButton1Click:Connect(function()
    loops.autoCollect = not loops.autoCollect
    if loops.autoCollect then
        collectButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
        collectButton.Text = "🎁 AUTO COLLECT 🟢 ON"
        print("[COLLECT] Enabled")
    else
        collectButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        collectButton.Text = "🎁 AUTO COLLECT 🔴 OFF"
        print("[COLLECT] Disabled")
    end
end)

collectSlider.FocusLost:Connect(function()
    local val = tonumber(collectSlider.Text)
    if val and val > 0 then
        delays.autoCollect = val
        print("[COLLECT] Delay:", val, "sec")
    else
        collectSlider.Text = tostring(delays.autoCollect)
    end
end)

autoBuyButton.MouseButton1Click:Connect(function()
    loops.autoBuy = not loops.autoBuy
    if loops.autoBuy then
        autoBuyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
        autoBuyButton.Text = "🎲 AUTO BUY 🟢 ON"
        print("[AUTO BUY] Enabled | interval", delays.autoBuy, "sec")
    else
        autoBuyButton.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
        autoBuyButton.Text = "🎲 AUTO BUY 🔴 OFF"
        print("[AUTO BUY] Disabled")
    end
end)

autoBuySlider.FocusLost:Connect(function()
    local val = tonumber(autoBuySlider.Text)
    if val and val > 0 then
        delays.autoBuy = val
        print("[AUTO BUY] Delay:", val, "sec")
    else
        autoBuySlider.Text = tostring(delays.autoBuy)
    end
end)

resetButton.MouseButton1Click:Connect(resetDynamicBlacklist)

authorLabel.MouseButton1Click:Connect(function()
    copyToClipboard(AUTHOR_DISCORD_LINK)
    showCopyableLink("Discord:", AUTHOR_DISCORD_LINK)
end)

authorLabel.MouseEnter:Connect(function()
    authorLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    authorLabel.TextColor3 = Color3.new(1, 1, 1)
end)

authorLabel.MouseLeave:Connect(function()
    authorLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    authorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

closeButton.MouseButton1Click:Connect(function()
    print("[CONTAINER RNG] Closed | Opened:", openedCounter, "| Collected:", collectedCounter)
    unloadScript()
end)

-- ============================================
-- Drag: title bar only
-- ============================================
local dragToggle = false
local dragInput, dragStart, startPos

title.InputBegan:Connect(function(input)
    if not scriptRunning or not mainFrame.Parent then
        return
    end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = false
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

connUISDragMain = UserInputService.InputChanged:Connect(function(input)
    if not scriptRunning or not mainFrame.Parent then
        return
    end
    if input == dragInput and dragToggle then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Drag: Menu button
local menuDragToggle = false
local menuDragInput, menuDragStart, menuStartPos

menuBtn.InputBegan:Connect(function(input)
    if not scriptRunning or not menuBtn.Parent then
        return
    end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        menuDragToggle = true
        menuDragStart = input.Position
        menuStartPos = menuBtn.Position
        menuBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 200)
    end
end)

menuBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        menuDragToggle = false
        menuBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    end
end)

menuBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        menuDragInput = input
    end
end)

connUISDragMenu = UserInputService.InputChanged:Connect(function(input)
    if not scriptRunning or not menuBtn.Parent or not gui.Parent then
        return
    end
    if input == menuDragInput and menuDragToggle then
        local delta = input.Position - menuDragStart
        local newX = menuStartPos.X.Offset + delta.X
        local newY = menuStartPos.Y.Offset + delta.Y
        local screenSize = gui.AbsoluteSize
        newX = math.max(0, math.min(newX, screenSize.X - menuBtn.AbsoluteSize.X))
        newY = math.max(0, math.min(newY, screenSize.Y - menuBtn.AbsoluteSize.Y))
        menuBtn.Position = UDim2.new(0, newX, 0, newY)
    end
end)

menuBtn.MouseButton1Click:Connect(function()
    if not scriptRunning or not mainFrame.Parent then
        return
    end
    mainFrame.Visible = not mainFrame.Visible
    print("Menu:", mainFrame.Visible and "OPEN" or "CLOSED")
end)

print("========================================")
print("🎲 CONTAINER RNG - ready (compact)")
print("Menu toggles panel | drag by TITLE")
print("AUTO BUY: dice + potions via Reliable remote")
print("========================================")
