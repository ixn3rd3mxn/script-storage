local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tbao143/Library-ui/refs/heads/main/Redzhubui"))()
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = redzlib:MakeWindow({
    Title = "Anti AFK Script",
    SubTitle = "By Phi",
    SaveFolder = "AntiAfkConfig"
})

Window:AddMinimizeButton({
    Button = {
        Image = "rbxassetid://71014873973869",
        BackgroundTransparency = 0
    },
    Corner = {
        CornerRadius = UDim.new(0, 8)
    }
})

local AntiAfkTab = Window:MakeTab({"Anti AFK", "activity"})

local afkEnabled = false
local afkInterval = 60
local moveEnabled = false
local clickEnabled = false
local jumpEnabled = false
local movementDirection = "Front then Back"
local afkConnection

local movementStuds = 1
local movementDelay = 0.1

AntiAfkTab:AddSection({"Anti AFK Settings"})

AntiAfkTab:AddToggle({
    Name = "Enable Anti AFK",
    Description = "Prevents kick for inactivity using the three methods provided",
    Default = false,
    Callback = function(Value)
        afkEnabled = Value

        if Value then
            if afkConnection then afkConnection:Disconnect() end
            afkConnection = RunService.RenderStepped:Connect(function()
                if tick() % afkInterval < 0.1 then
                    if clickEnabled then
                        VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                        task.wait(0.1)
                        VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    end

                    if moveEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local root = LocalPlayer.Character.HumanoidRootPart
                        if movementDirection == "Front then Back" then
                            root.CFrame = root.CFrame * CFrame.new(0, 0, -movementStuds)
                            task.wait(movementDelay)
                            root.CFrame = root.CFrame * CFrame.new(0, 0, movementStuds)
                        elseif movementDirection == "Back then Front" then
                            root.CFrame = root.CFrame * CFrame.new(0, 0, movementStuds)
                            task.wait(movementDelay)
                            root.CFrame = root.CFrame * CFrame.new(0, 0, -movementStuds)
                        elseif movementDirection == "Left then Right" then
                            root.CFrame = root.CFrame * CFrame.new(-movementStuds, 0, 0)
                            task.wait(movementDelay)
                            root.CFrame = root.CFrame * CFrame.new(movementStuds, 0, 0)
                        elseif movementDirection == "Right then Left" then
                            root.CFrame = root.CFrame * CFrame.new(movementStuds, 0, 0)
                            task.wait(movementDelay)
                            root.CFrame = root.CFrame * CFrame.new(-movementStuds, 0, 0)
                        end
                    end

                    if jumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        else
            if afkConnection then
                afkConnection:Disconnect()
                afkConnection = nil
            end
        end
    end
})

AntiAfkTab:AddSlider({
    Name = "Anti AFK Interval (sec)",
    Min = 5,
    Max = 1800,
    Increase = 5,
    Default = 60,
    Callback = function(Value)
        afkInterval = Value
    end
})

AntiAfkTab:AddSection({"Anti AFK Methods (can select multiple options at once)"})

AntiAfkTab:AddToggle({
    Name = "Enable Movement",
    Description = "Moves the character slightly for every slider's seconds",
    Default = false,
    Callback = function(Value)
        moveEnabled = Value
    end
})

AntiAfkTab:AddToggle({
    Name = "Enable Simulated Click",
    Description = "Simulates clicking for every slider's seconds",
    Default = false,
    Callback = function(Value)
        clickEnabled = Value
    end
})

AntiAfkTab:AddToggle({
    Name = "Enable Jumping",
    Description = "Makes the character jump for every slider's seconds",
    Default = false,
    Callback = function(Value)
        jumpEnabled = Value
    end
})

AntiAfkTab:AddDropdown({
    Name = "Movement Direction",
    Description = "Select the direction the player moves (for the movement toggle)",
    Options = {
        "Front then Back",
        "Back then Front",
        "Left then Right",
        "Right then Left"
    },
    Default = "Front then Back",
    Callback = function(Value)
        movementDirection = Value
    end
})
