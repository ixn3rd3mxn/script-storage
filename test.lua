task.wait(5)

repeat wait() until game:IsLoaded()

local slotnumber = 1 -- YOUR SLOT HERE

local ReplicatedStorage = game:GetService("ReplicatedStorage")
wait(1)
local QuickLoad = ReplicatedStorage.QuickLoad 
QuickLoad:InvokeServer(
    slotnumber
)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoadPlayerData = ReplicatedStorage.LoadPlayerData 
LoadPlayerData:InvokeServer(
    slotnumber
)
local Workspace = game:GetService("Workspace")
local Easter = Workspace.Easter
local easterthing = Easter:FindFirstChild("EASTER ISLAND EGG SPAWNS")
local mapthing = Workspace.Map:FindFirstChild("EGG_SPAWNS")

if easterthing then
    for i, v in ipairs(easterthing:GetChildren()) do
        if #v:GetChildren() > 0 then
            for _, child in ipairs(v:GetChildren()) do
                print(child.Name)
                child:FindFirstChild("ProximityPrompt")
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = child.CFrame
                task.wait(.5)
                fireproximityprompt(child.ProximityPrompt)
                wait(.5)
            end
        end
    end
end

if mapthing then
    for i, v in ipairs(mapthing:GetChildren()) do
        if #v:GetChildren() > 0 then
            for _, child in ipairs(v:GetChildren()) do
                print(child.Name)
                child:FindFirstChild("ProximityPrompt")
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = child.CFrame
                task.wait(.5)
                fireproximityprompt(child.ProximityPrompt)
                wait(.5)
            end
        end
    end
end
wait(1)
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end
function TPReturner()
    local Site;
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0;
    for i,v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _,Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
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
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

function Teleport()
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

-- ░ Auto Box Collector with Return to Base
local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local myTycoon = game.Players.LocalPlayer:WaitForChild("PlayerTycoon").Value
local tycoonBase = myTycoon:WaitForChild("Base")
local collectedBoxes = {}
local BOX_NAMES = {"Shadow", "Research", "Goldpot", "Golden", "Crystal", "Diamond", "Present", "Lucky", "Egg", "Executive", "Flaming", "Giant"}

local function teleportToBase()
    if humanoidRootPart and tycoonBase then
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart:PivotTo(tycoonBase:GetPivot() + Vector3.new(0, tycoonBase.Size.Y + 2.5, 0))
    end
end

local function collectBox(box)
    humanoidRootPart.Velocity = Vector3.zero
    humanoidRootPart:PivotTo(box:GetPivot() * CFrame.new(0, -1, 0))
    task.wait(0.1)
    firetouchinterest(humanoidRootPart, box, 0)
    firetouchinterest(humanoidRootPart, box, 1)
    collectedBoxes[box] = true
    task.wait(0.1)
end

-- Collect all boxes before teleporting
local function collectAllBoxesAndTeleport()
    for i = 1, 10 do -- Try multiple times just in case more boxes spawn in
        local foundBox = false
        for _, box in ipairs(workspace:WaitForChild("Boxes"):GetChildren()) do
            if table.find(BOX_NAMES, box.Name) and not collectedBoxes[box] then
                if box:IsA("BasePart") and box:FindFirstChild("TouchInterest") then
                    foundBox = true
                    collectBox(box)
                end
            end
        end
        if not foundBox then
            break
        end
        task.wait(0.3)
    end

    teleportToBase()
    task.wait(1) -- Give it a second to settle
end

collectAllBoxesAndTeleport()


Teleport()
