getgenv().OpenBox = false
getgenv().TeleportBoxes = false
getgenv().SelectedBox = "Regular"
local boxes = {"Regular", "Unreal", "Easter"}

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local boxesFolder = game.Workspace:WaitForChild("Boxes")
local teleportInterval = 0.1

-- ░ New Box Collection System (Separated and Protected)
local function executeNewBoxCollection()
    spawn(function()
        pcall(function()
            -- Wait for game to load
            repeat task.wait() until game:IsLoaded()
            task.wait(2) -- Extra safety wait
            
            local slotnumber = 1
            
            -- Load player data safely
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            if ReplicatedStorage then
                task.wait(1)
                
                local QuickLoad = ReplicatedStorage:FindFirstChild("QuickLoad")
                if QuickLoad then
                    pcall(function()
                        QuickLoad:InvokeServer(slotnumber)
                    end)
                end
                
                local LoadPlayerData = ReplicatedStorage:FindFirstChild("LoadPlayerData")
                if LoadPlayerData then
                    pcall(function()
                        LoadPlayerData:InvokeServer(slotnumber)
                    end)
                end
            end
            
            task.wait(1)
            
            -- Collect Easter eggs
            local Workspace = game:GetService("Workspace")
            if Workspace then
                local Easter = Workspace:FindFirstChild("Easter")
                if Easter then
                    local easterthing = Easter:FindFirstChild("EASTER ISLAND EGG SPAWNS")
                    if easterthing then
                        for i, v in ipairs(easterthing:GetChildren()) do
                            if #v:GetChildren() > 0 then
                                for _, child in ipairs(v:GetChildren()) do
                                    pcall(function()
                                        local proximityPrompt = child:FindFirstChild("ProximityPrompt")
                                        if proximityPrompt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                            player.Character.HumanoidRootPart.CFrame = child.CFrame
                                            task.wait(0.5)
                                            fireproximityprompt(proximityPrompt)
                                            task.wait(0.5)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
                
                -- Collect Map eggs
                local Map = Workspace:FindFirstChild("Map")
                if Map then
                    local mapthing = Map:FindFirstChild("EGG_SPAWNS")
                    if mapthing then
                        for i, v in ipairs(mapthing:GetChildren()) do
                            if #v:GetChildren() > 0 then
                                for _, child in ipairs(v:GetChildren()) do
                                    pcall(function()
                                        local proximityPrompt = child:FindFirstChild("ProximityPrompt")
                                        if proximityPrompt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                            player.Character.HumanoidRootPart.CFrame = child.CFrame
                                            task.wait(0.5)
                                            fireproximityprompt(proximityPrompt)
                                            task.wait(0.5)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
            
            -- Collect boxes
            local BOX_NAMES = {"Shadow", "Research", "Goldpot", "Golden", "Crystal", "Diamond", "Present", "Lucky", "Egg", "Executive", "Flaming", "Giant"}
            local collectedBoxes = {}
            
            for i = 1, 10 do
                local foundBox = false
                local boxesWorkspace = workspace:FindFirstChild("Boxes")
                
                if boxesWorkspace then
                    for _, box in ipairs(boxesWorkspace:GetChildren()) do
                        if table.find(BOX_NAMES, box.Name) and not collectedBoxes[box] then
                            if box:IsA("BasePart") and box:FindFirstChild("TouchInterest") then
                                pcall(function()
                                    local character = player.Character
                                    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                                    
                                    if humanoidRootPart then
                                        foundBox = true
                                        humanoidRootPart.Velocity = Vector3.zero
                                        humanoidRootPart:PivotTo(box:GetPivot() * CFrame.new(0, -1, 0))
                                        task.wait(0.1)
                                        firetouchinterest(humanoidRootPart, box, 0)
                                        firetouchinterest(humanoidRootPart, box, 1)
                                        collectedBoxes[box] = true
                                        task.wait(0.1)
                                    end
                                end)
                            end
                        end
                    end
                end
                
                if not foundBox then
                    break
                end
                task.wait(0.3)
            end
            
            -- Teleport to base
            pcall(function()
                local character = player.Character
                if character then
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    local playerTycoon = player:FindFirstChild("PlayerTycoon")
                    
                    if humanoidRootPart and playerTycoon and playerTycoon.Value then
                        local tycoonBase = playerTycoon.Value:FindFirstChild("Base")
                        if tycoonBase then
                            humanoidRootPart.Velocity = Vector3.zero
                            humanoidRootPart:PivotTo(tycoonBase:GetPivot() + Vector3.new(0, tycoonBase.Size.Y + 2.5, 0))
                        end
                    end
                end
            end)
            
            task.wait(2)
            
            -- Server hop
            pcall(function()
                local PlaceID = game.PlaceId
                local AllIDs = {}
                local foundAnything = ""
                local actualHour = os.date("!*t").hour
                
                local File = pcall(function()
                    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
                end)
                
                if not File then
                    table.insert(AllIDs, actualHour)
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                end
                
                local function TPReturner()
                    local Site
                    pcall(function()
                        if foundAnything == "" then
                            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
                        else
                            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
                        end
                    end)
                    
                    if not Site then return false end
                    
                    local ID = ""
                    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
                        foundAnything = Site.nextPageCursor
                    end
                    
                    local num = 0
                    for i, v in pairs(Site.data) do
                        local Possible = true
                        ID = tostring(v.id)
                        if tonumber(v.maxPlayers) > tonumber(v.playing) then
                            for _, Existing in pairs(AllIDs) do
                                if num ~= 0 then
                                    if ID == tostring(Existing) then
                                        Possible = false
                                    end
                                else
                                    if tonumber(actualHour) ~= tonumber(Existing) then
                                        pcall(function()
                                            delfile("NotSameServers.json")
                                            AllIDs = {}
                                            table.insert(AllIDs, actualHour)
                                        end)
                                    end
                                end
                                num = num + 1
                            end
                            
                            if Possible == true then
                                table.insert(AllIDs, ID)
                                pcall(function()
                                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                                    task.wait(1)
                                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, player)
                                end)
                                return true
                            end
                        end
                    end
                    return false
                end
                
                -- Try to teleport with timeout
                local attempts = 0
                while attempts < 50 do
                    attempts = attempts + 1
                    if TPReturner() then
                        break
                    end
                    if foundAnything ~= "" then
                        if TPReturner() then
                            break
                        end
                    end
                    task.wait(2)
                end
            end)
        end)
    end)
end

local function createGui()
    local existingGui = playerGui:FindFirstChild("AutoOpenGui")
    if existingGui then
        existingGui:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoOpenGui"
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.BackgroundTransparency = 0.2

    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 12)

    local gradient = Instance.new("UIGradient", mainFrame)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 70, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
    }

    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Text = "CUSTOM TOOL"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextScaled = true
    titleLabel.TextStrokeTransparency = 0.5

    local dropdownLabel = Instance.new("TextLabel", mainFrame)
    dropdownLabel.Size = UDim2.new(1, 0, 0, 30)
    dropdownLabel.Position = UDim2.new(0, 0, 0, 50)
    dropdownLabel.Text = "Select a Box:"
    dropdownLabel.TextColor3 = Color3.new(1, 1, 1)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.TextScaled = true

    local dropdownButton = Instance.new("TextButton", mainFrame)
    dropdownButton.Size = UDim2.new(1, 0, 0, 40)
    dropdownButton.Position = UDim2.new(0, 0, 0, 90)
    dropdownButton.Text = getgenv().SelectedBox
    dropdownButton.TextColor3 = Color3.new(1, 1, 1)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    dropdownButton.BorderSizePixel = 0

    local toggleOpenButton = Instance.new("TextButton", mainFrame)
    toggleOpenButton.Size = UDim2.new(1, 0, 0, 40)
    toggleOpenButton.Position = UDim2.new(0, 0, 0, 140)
    toggleOpenButton.Text = "Enable Auto Open"
    toggleOpenButton.TextColor3 = Color3.new(1, 1, 1)
    toggleOpenButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleOpenButton.BorderSizePixel = 0

    local toggleTeleportButton = Instance.new("TextButton", mainFrame)
    toggleTeleportButton.Size = UDim2.new(1, 0, 0, 40)
    toggleTeleportButton.Position = UDim2.new(0, 0, 0, 190)
    toggleTeleportButton.Text = "Enable TP to Boxes Old version"
    toggleTeleportButton.TextColor3 = Color3.new(1, 1, 1)
    toggleTeleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleTeleportButton.BorderSizePixel = 0

    -- ░ New Button: TP to Boxes New Version
    local newBoxCollectionButton = Instance.new("TextButton", mainFrame)
    newBoxCollectionButton.Size = UDim2.new(1, 0, 0, 40)
    newBoxCollectionButton.Position = UDim2.new(0, 0, 0, 240)
    newBoxCollectionButton.Text = "TP to Boxes New Version"
    newBoxCollectionButton.TextColor3 = Color3.new(1, 1, 1)
    newBoxCollectionButton.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
    newBoxCollectionButton.BorderSizePixel = 0

    local function animateButton(button)
        button.MouseEnter:Connect(function()
            local currentColor = button.BackgroundColor3
            button.BackgroundColor3 = Color3.new(
                math.min(currentColor.R + 0.08, 1),
                math.min(currentColor.G + 0.08, 1),
                math.min(currentColor.B + 0.08, 1)
            )
        end)
        button.MouseLeave:Connect(function()
            if button == newBoxCollectionButton then
                button.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
            else
                button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end
        end)
        button.MouseButton1Down:Connect(function()
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end)
        button.MouseButton1Up:Connect(function()
            if button == newBoxCollectionButton then
                button.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
            else
                button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end
        end)
    end

    local function toggleAutoOpen()
        getgenv().OpenBox = not getgenv().OpenBox
        toggleOpenButton.Text = getgenv().OpenBox and "Disable Auto Open" or "Enable Auto Open"

        if getgenv().OpenBox then
            spawn(function()
                while getgenv().OpenBox do
                    game.ReplicatedStorage.MysteryBox:InvokeServer(getgenv().SelectedBox)
                    task.wait(1)
                end
            end)
        end
    end

    local function toggleTeleport()
        getgenv().TeleportBoxes = not getgenv().TeleportBoxes
        toggleTeleportButton.Text = getgenv().TeleportBoxes and "Disable TP to Boxes Old version" or "Enable TP to Boxes Old version"
    end

    local function selectBox()
        local boxIndex = table.find(boxes, getgenv().SelectedBox)
        boxIndex = boxIndex == #boxes and 1 or boxIndex + 1
        getgenv().SelectedBox = boxes[boxIndex]
        dropdownButton.Text = getgenv().SelectedBox
    end

    -- ░ New Function: Execute New Box Collection (One-time click)
    local function onNewBoxCollectionClick()
        -- Prevent multiple clicks
        if newBoxCollectionButton.Text == "Running..." then
            return
        end
        
        -- Visual feedback
        newBoxCollectionButton.Text = "Running..."
        newBoxCollectionButton.BackgroundColor3 = Color3.fromRGB(150, 100, 100)
        
        executeNewBoxCollection()
        
        -- Reset button after delay
        spawn(function()
            task.wait(3)
            if newBoxCollectionButton and newBoxCollectionButton.Parent then
                newBoxCollectionButton.Text = "TP to Boxes New Version"
                newBoxCollectionButton.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
            end
        end)
    end

    toggleOpenButton.MouseButton1Click:Connect(toggleAutoOpen)
    toggleTeleportButton.MouseButton1Click:Connect(toggleTeleport)
    dropdownButton.MouseButton1Click:Connect(selectBox)
    newBoxCollectionButton.MouseButton1Click:Connect(onNewBoxCollectionClick)

    animateButton(dropdownButton)
    animateButton(toggleOpenButton)
    animateButton(toggleTeleportButton)
    animateButton(newBoxCollectionButton)
end

player.CharacterAdded:Connect(function()
    createGui()
end)

createGui()

-- ░ Old teleport function (for backward compatibility)
local function teleportToObject(object)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = object.CFrame
    end
end

local function monitorFolder()
    while true do
        if getgenv().TeleportBoxes then
            local children = boxesFolder:GetChildren()
            if #children > 0 then
                local target = children[1]
                teleportToObject(target)
            end
        end
        wait(teleportInterval)
    end
end

spawn(monitorFolder)
