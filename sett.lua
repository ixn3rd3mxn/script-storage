--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Project Vertigo | Miners Haven',
    Center = true, 
    AutoShow = true,
})

Library.KeybindFrame.Visible = false; -- todo: add a function for this

Library:OnUnload(function()
    Library.Unloaded = true
end)

--Locals
local FetchItemModule = require(game:GetService("ReplicatedStorage").FetchItem)
local TycoonBase = game.Players.LocalPlayer.PlayerTycoon.Value.Base
local MyTycoon = game:GetService("Players").LocalPlayer.PlayerTycoon.Value
local MoneyLibary = require(game:GetService("ReplicatedStorage").MoneyLib)
local PlayersList = {}
local player = game.Players.LocalPlayer
local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local collectedBoxes = {}
local oldRebirths = game:GetService("Players").LocalPlayer.Rebirths.Value


local Settings = {AutoLoopUpgrader=false,LayoutCopierSelected="1",LayoutPlayerSelected="",ItemTracker=false,WebhookLink="",LoopPulse=false,AutoPulse=false,LoopRemoteDrop=false,AutoLoadSetup=false,LoadAfter=5,ShouldReload=false,LayoutSelected=1,AutoRebirth=false,LoopUpgrader=false,SelectedUpgrader="nil",SelectedFurnace="nil"}

--Functions
function GetUpgraders()
    tbl = {}
    for i,v in pairs(MyTycoon:GetChildren()) do
        if v:FindFirstChild("Model") and v.Model:FindFirstChild("Upgrade") then
            table.insert(tbl,v)
        elseif v:FindFirstChild("Model") and v.Model:FindFirstChild("Upgrader") then
            table.insert(tbl,v)
        elseif v:FindFirstChild("Model") and v.Model:FindFirstChild("Cannon") then
            table.insert(tbl,v)
        end
    end
    return tbl
end
function GetPlayers()
    table.clear(PlayersList)
    for i,v in pairs(game.Players:GetChildren()) do
        table.insert(PlayersList,v.Name)
    end
end
GetPlayers()
game.Players.PlayerAdded:Connect(function()
    GetPlayers()
end)
game.Players.PlayerRemoving:Connect(function()
    GetPlayers()
end)
function GetDropped()
    local tbl = {}
    for i,v in pairs(game:GetService("Workspace").DroppedParts[MyTycoon.Name]:GetChildren()) do
        if not string.find(v.Name,"Coal") then 
            table.insert(tbl,v)        
        end
    end
    return tbl
end
function ShopItems()
    for i,v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v,"Miscs") then
            return v["All"]
        end
    end
end
function HasItem(Needed)
    if game:GetService("ReplicatedStorage").HasItem:InvokeServer(Needed) > 0 then
        return true
    end
    return false
end
function IsShopItem(Needed)
    for i,v in pairs(ShopItems()) do
        if tonumber(v.ItemId.Value) == tonumber(Needed) then
            return true
        end
    end
    return false
end
function GetMissingItems()
    local MissingTbl = {}
    for i,v in pairs(game:GetService("HttpService"):JSONDecode(game:GetService("Players")[Settings.LayoutPlayerSelected].Layouts["Layout"..Settings.LayoutCopierSelected].Value)) do
        local ItemName = FetchItemModule.Get(nil,v["ItemId"]).Name
        if HasItem(v["ItemId"]) == false and IsShopItem(v["ItemId"]) == true then
            table.insert(MissingTbl,ItemName.." [Shop]")
        elseif HasItem(v["ItemId"]) == false and IsShopItem(v["ItemId"]) == false then
            table.insert(MissingTbl,ItemName)
        end
    end
    local MissingString
    if #MissingTbl > 0 then
        MissingString = table.concat(MissingTbl, "\n")
    else
        MissingString = "No Missing Items!"
    end
    return MissingString
end

local Tabs = {Main = Window:AddTab('Main'),Layouts=Window:AddTab('Layouts'),['UI Settings'] = Window:AddTab('UI Settings'),}

local LayoutsTabbox = Tabs.Layouts:AddLeftTabbox()
local LayoutsTab = LayoutsTabbox:AddTab('Copier')
local LayoutsTabbox2 = Tabs.Layouts:AddRightTabbox()
local LayoutsTabInfo = LayoutsTabbox2:AddTab('Missing Items')

local Label = LayoutsTabInfo:AddLabel('No Layout Selected',true)
LayoutsTabInfo:AddButton("Get Missing Items!",function()
    Label:SetText("Getting Items, Please Wait!")
    if Settings.LayoutPlayerSelected == nil and Settings.LayoutCopierSelected == nil then return end
    Label:SetText(GetMissingItems())
end)

LayoutsTab:AddDropdown('LayoutPlayerSelected',{Values = PlayersList,Default = 2,Multi = false,Text = 'Player',})
LayoutsTab:AddDropdown('LayoutCopierSelected', {Values = {1,2,3},Default = 1,Multi = false,Text = 'Layout',})
LayoutsTab:AddButton('Build Layout', function()
    if Settings.LayoutPlayerSelected == nil and Settings.LayoutCopierSelected == nil then return end
    for i,v in pairs(game:GetService("HttpService"):JSONDecode(game:GetService("Players")[Settings.LayoutPlayerSelected].Layouts["Layout"..Settings.LayoutCopierSelected].Value)) do
        task.spawn(function()
            if HasItem(v["ItemId"]) == true then
                local TopLeft = TycoonBase.CFrame * CFrame.new(Vector3.new(TycoonBase.Size.X/2, 0, TycoonBase.Size.Z/2))
                local Position = TopLeft * Vector3.new(tonumber(v.Position[1]), tonumber(v.Position[2]), tonumber(v.Position[3]))
                local Rotation = Vector3.new(tonumber(v.Position[4]),tonumber(v.Position[5]),tonumber(v.Position[6]))
                local NewCf = CFrame.new(Position, Position + (Rotation * 5))
                game:GetService("ReplicatedStorage").PlaceItem:InvokeServer(FetchItemModule.Get(nil,v["ItemId"]).Name,NewCf,{TycoonBase})
                task.wait()
            elseif HasItem(v["ItemId"]) == false and IsShopItem(v["ItemId"]) == true and game:GetService("Players").LocalPlayer.PlayerGui.GUI.Money.Value >= game:GetService("ReplicatedStorage").Items[FetchItemModule.Get(nil,v["ItemId"]).Name].Cost.Value then
                game:GetService("ReplicatedStorage").BuyItem:InvokeServer(FetchItemModule.Get(nil,v["ItemId"]).Name,1)
                task.wait()
                local TopLeft = TycoonBase.CFrame * CFrame.new(Vector3.new(TycoonBase.Size.X/2, 0, TycoonBase.Size.Z/2))
                local Position = TopLeft * Vector3.new(tonumber(v.Position[1]), tonumber(v.Position[2]), tonumber(v.Position[3]))
                local Rotation = Vector3.new(tonumber(v.Position[4]),tonumber(v.Position[5]),tonumber(v.Position[6]))
                local NewCf = CFrame.new(Position, Position + (Rotation * 5))
                game:GetService("ReplicatedStorage").PlaceItem:InvokeServer(FetchItemModule.Get(nil,v["ItemId"]).Name,NewCf,{TycoonBase})
                task.wait()
            else
                if IsShopItem(v["ItemId"]) == true then
                    print("Cant Afford Item, "..FetchItemModule.Get(nil,v["ItemId"]).Name)
                else
                    print("Cant Find, "..FetchItemModule.Get(nil,v["ItemId"]).Name)
                end
            end
        end)
    end
end)

local OresTabbox = Tabs.Main:AddLeftTabbox()
local OresTab = OresTabbox:AddTab('Ores')
local RebirthTabbox = Tabs.Main:AddRightTabbox()
local RebirthTab = RebirthTabbox:AddTab('Rebirthing')
local MiscTabbox = Tabs.Main:AddLeftTabbox()
local MiscTab = MiscTabbox:AddTab('Misc')
local WebhookTabbox = Tabs.Main:AddRightTabbox()
local WebhookTab = WebhookTabbox:AddTab('Webhook')
local EventTabbox = Tabs.Main:AddRightTabbox()
local EventTab = EventTabbox:AddTab('Event')
local FpsTabbox = Tabs.Main:AddRightTabbox()
local FpsTab = FpsTabbox:AddTab('FPS')

FpsTab:AddToggle('RenderingToggle', {Text = 'Rendering',Default = true})

EventTab:AddButton('Do Santa', function()
    task.spawn(function()
        if workspace:FindFirstChild("CreatedPresent") and (workspace:FindFirstChild("CreatedPresent"):GetPivot().p -humanoidRootPart:GetPivot().p).Magnitude > 10 then
            humanoidRootPart:PivotTo(workspace.CreatedPresent:GetPivot() + Vector3.new(0,2,0))
            task.wait(.2)
            fireproximityprompt(workspace.CreatedPresent.ProximityPrompt)
        end
        task.wait(.3)
        humanoidRootPart:PivotTo(workspace.Map.SantaModel.Santa.CamPos:GetPivot())
        game:GetService("Players").LocalPlayer.PlayerGui.GUI.GiftExchange.Visible = true
        task.wait(.35)
        firesignal(game:GetService("Players").LocalPlayer.PlayerGui.GUI.GiftExchange.ExchangeButton.MouseButton1Down)
        task.wait(.4)
        game:GetService("Players").LocalPlayer.PlayerGui.GUI.GiftExchange.Visible = false

        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.CFrame = TycoonBase:GetPivot()+Vector3.new(0,TycoonBase.Size.Y+2.5,0)
    end)
end)

OresTab:AddInput('SelectedUpgrader', {Default = 'Upgrader',Numeric = false,Finished = false,Text = 'Upgrader',Placeholder = 'Upgrader Name',})
OresTab:AddToggle('LoopUpgrader', {Text = 'Loop Upgrader',Default = false})
OresTab:AddToggle('AutoLoopUpgraders', {Text = 'Loop All Upgraders',Default = false})
OresTab:AddDivider()
OresTab:AddInput('SelectedFurnace', {Default = 'Furnace',Numeric = false,Finished = false,Text = 'Furnace',Placeholder = 'Furnace',})
OresTab:AddToggle('AutoSellOre', {Text = 'Auto Sell Ore',Default = false})
OresTab:AddButton('Sell Ores', function()
    for i,v in pairs(GetDropped()) do
        task.spawn(function()
            if MyTycoon:FindFirstChild(Settings.SelectedFurnace) then
                firetouchinterest(v,MyTycoon[Settings.SelectedFurnace].Model.Lava,0)
                task.wait()
                firetouchinterest(v,MyTycoon[Settings.SelectedFurnace].Model.Lava,1)
            end
        end)
    end
end)

RebirthTab:AddToggle('AutoRebirth', {Text = 'Auto Rebirth',Default = false})
RebirthTab:AddToggle('DelayRebirth', {Text = 'Delay Rebirth',Default = false})
RebirthTab:AddToggle('AutoLoadSetup', {Text = 'Load Layout',Default = false})
RebirthTab:AddDropdown('LayoutSelected', {Values = {1,2,3},Default = 1,Multi = false,Text = 'Layout',})
RebirthTab:AddToggle('ShouldReload', {Text = 'Reload Layout',Default = false})
RebirthTab:AddSlider('LoadAfter', {Text = 'Reload After (s)',Default = 5,Min = 1,Max = 60,Rounding = 0,Compact = false,})

MiscTab:AddToggle('LoopProximtyPrompt', {Text = 'Auto Excavator',Default = false})
MiscTab:AddToggle('LoopRemoteDrop', {Text = 'Auto Remote',Default = false})
MiscTab:AddToggle('LoopPulse', {Text = 'Auto Pulse',Default = false})
MiscTab:AddButton('Get Free Daily Crate', function()
    firesignal(game:GetService("Players").LocalPlayer.PlayerGui.GUI.SpookMcDookShop.RedeemFrame.MouseButton1Click)
end)
MiscTab:AddDivider()
MiscTab:AddToggle('ToggleCraftsMan', {Text = 'Craftman Gui',Default = false})
MiscTab:AddToggle('ToggleAutoBoxes', {Text = 'Auto Collect Boxes',Default = false})
MiscTab:AddButton('Goto Base!', function()
    humanoidRootPart.Velocity = Vector3.zero
    humanoidRootPart.CFrame = TycoonBase:GetPivot()+Vector3.new(0,TycoonBase.Size.Y+2.5,0)
end)

WebhookTab:AddInput('WebhookLink', {Default = 'Link',Numeric = false,Finished = false,Text = 'Link',Placeholder = 'Link',})
WebhookTab:AddToggle('ItemTracker', {Text = 'Item Tracker',Default = false})

--Toggles
Toggles.RenderingToggle:OnChanged(function()
    game:GetService("RunService"):Set3dRenderingEnabled(Toggles.RenderingToggle.Value)
end)
Toggles.AutoSellOre:OnChanged(function()
    task.spawn(function()
        while Toggles.AutoSellOre.Value do task.wait()
            for i,v in pairs(GetDropped()) do
                task.spawn(function()
                    if MyTycoon:FindFirstChild(Settings.SelectedFurnace) then
                        firetouchinterest(v,MyTycoon[Settings.SelectedFurnace].Model.Lava,0)
                        task.wait()
                        firetouchinterest(v,MyTycoon[Settings.SelectedFurnace].Model.Lava,1)
                    end
                end)
            end
        end
    end)
end)
Toggles.ToggleAutoBoxes:OnChanged(function()
    task.spawn(function()
        while Toggles.ToggleAutoBoxes.Value do task.wait(.2)
            if humanoidRootPart then
                for i, v in pairs(game:GetService("Workspace").Boxes:GetChildren()) do
                    local boxNames = {"Shadow", "Research", "Goldpot", "Golden", "Crystal", "Diamond", "Present","Lucky"}
                    if table.find(boxNames,v.Name) and not collectedBoxes[v] and v:FindFirstChild("TouchInterest") then
                        humanoidRootPart.Velocity = Vector3.zero
                        humanoidRootPart:PivotTo(v:GetPivot()*CFrame.new(0,-1,0))
                        firetouchinterest(humanoidRootPart,v,0)
                        if v:FindFirstChild("TouchInterest") then
                            firetouchinterest(humanoidRootPart,v,1)
                        end
                        if v.Transparency ~= 0.2 then
                            collectedBoxes[v] = nil
                        else
                            collectedBoxes[v] = true
                        end
                        task.wait(.2)
                        humanoidRootPart.Velocity = Vector3.zero
                        humanoidRootPart:PivotTo(v:GetPivot()*CFrame.new(0,-30,0))
                    end
                end
                humanoidRootPart.Velocity = Vector3.zero
                humanoidRootPart:PivotTo(TycoonBase:GetPivot()+Vector3.new(0,TycoonBase.Size.Y+2.5,0))
            end 
        end
    end)
end)

Toggles.ItemTracker:OnChanged(function()
    Settings.ItemTracker = Toggles.ItemTracker.Value
end)
Toggles.ToggleCraftsMan:OnChanged(function()
    game:GetService("Players").LocalPlayer.PlayerGui.GUI.Craftsman.Visible = Toggles.ToggleCraftsMan.Value
end)
Toggles.LoopPulse:OnChanged(function()
    Settings.LoopPulse = Toggles.LoopPulse.Value
    task.spawn(function()
        while Settings.LoopPulse == true do task.wait()
            if Settings.LoopPulse == true then
                game:GetService("ReplicatedStorage").Pulse:FireServer()
            end
        end
    end)
end)
Toggles.LoopRemoteDrop:OnChanged(function()
    Settings.LoopRemoteDrop = Toggles.LoopRemoteDrop.Value
    task.spawn(function()
        while Settings.LoopRemoteDrop == true do task.wait()
            if Settings.LoopRemoteDrop == true then
                game:GetService("ReplicatedStorage").RemoteDrop:FireServer()
            end
        end
    end)
end)
Toggles.AutoLoopUpgraders:OnChanged(function()
    Settings.AutoLoopUpgraders = Toggles.AutoLoopUpgraders.Value
    task.spawn(function()
        while Settings.AutoLoopUpgraders do task.wait()
            if Settings.AutoLoopUpgraders then
                for i,v2 in pairs(GetDropped()) do
                    task.spawn(function()
                        for i2,v in pairs(GetUpgraders()) do
                            if v:FindFirstChild("Model") and v.Model:FindFirstChild("Upgrade") and v.Name ~= "Ore Illuminator" then
                                firetouchinterest(v2,v.Model.Upgrade,0)
                                task.wait()
                                firetouchinterest(v2,v.Model.Upgrade,1)
                            elseif v:FindFirstChild("Model") and v.Model:FindFirstChild("Upgrader") then
                                firetouchinterest(v2,v.Model.Upgrader,0)
                                task.wait()
                                firetouchinterest(v2,v.Model.Upgrader,1)
                            elseif v:FindFirstChild("Model") and v.Model:FindFirstChild("Cannon") then
                                firetouchinterest(v2,v.Model.Cannon,0)
                                task.wait()
                                firetouchinterest(v2,v.Model.Cannon,1)
                            elseif v:FindFirstChild("Model") and v.Model:FindFirstChild("Copy") then
                                firetouchinterest(v2,v.Copy,0)
                                task.wait()
                                firetouchinterest(v2,v,1)
                            end
                        end
                    end)
                end
            end
        end
    end)
end)
Toggles.LoopUpgrader:OnChanged(function()
    Settings.LoopUpgrader = Toggles.LoopUpgrader.Value
    task.spawn(function()
        while Settings.LoopUpgrader do task.wait()
            if Settings.LoopUpgrader then
                for i,v in pairs(GetDropped()) do
                    task.spawn(function()
                        if MyTycoon:FindFirstChild(Settings.SelectedUpgrader) and MyTycoon[Settings.SelectedUpgrader].Model:FindFirstChild("Upgrade") then
                            firetouchinterest(v,MyTycoon[Settings.SelectedUpgrader].Model.Upgrade,0)
                            task.wait()
                            firetouchinterest(v,MyTycoon[Settings.SelectedUpgrader].Model.Upgrade,1)
                        elseif MyTycoon:FindFirstChild(Settings.SelectedUpgrader) and MyTycoon[Settings.SelectedUpgrader].Model:FindFirstChild("Upgrader") then
                            firetouchinterest(v,MyTycoon[Settings.SelectedUpgrader].Model.Upgrader,0)
                            task.wait()
                            firetouchinterest(v,MyTycoon[Settings.SelectedUpgrader].Model.Upgrader,1)
                        elseif MyTycoon:FindFirstChild(Settings.SelectedUpgrader) and MyTycoon[Settings.SelectedUpgrader].Model:FindFirstChild("Cannon") then
                            firetouchinterest(v,MyTycoon[Settings.SelectedUpgrader].Model.Cannon,0)
                            task.wait()
                            firetouchinterest(v,MyTycoon[Settings.SelectedUpgrader].Model.Cannon,1)
                        elseif MyTycoon:FindFirstChild(Settings.SelectedUpgrader) and MyTycoon[Settings.SelectedUpgrader].Model:FindFirstChild("Copy") then
                            firetouchinterest(v,MyTycoon[Settings.SelectedUpgrader].Model.Copy,0)
                            task.wait()
                            firetouchinterest(v,MyTycoon[Settings.SelectedUpgrader].Model.Copy,1)
                        end
                    end)
                end
            end
        end
    end)
end)
Toggles.LoopProximtyPrompt:OnChanged(function()
    Settings.LoopProximtyPrompt = Toggles.LoopProximtyPrompt.Value
    task.spawn(function()
        while Settings.LoopProximtyPrompt do task.wait()
            if Settings.LoopProximtyPrompt then
                for i,v in pairs(MyTycoon:GetChildren()) do
                    if string.find(v.Name,"Excavator") then
                       fireproximityprompt(v.Model.Internal.ProximityPrompt)
                    end
                end
            end
        end
    end)
end)
Toggles.AutoRebirth:OnChanged(function()
    Settings.AutoRebirth = Toggles.AutoRebirth.Value
    task.spawn(function()
        while Settings.AutoRebirth do task.wait()
            if game:GetService("Players").LocalPlayer.PlayerGui.GUI.Money.Value >= MoneyLibary.RebornPrice(game:GetService("Players").LocalPlayer) and Settings.AutoRebirth  == true then
                if Toggles.ToggleAutoBoxes.Value == true and (game:GetService("Players").LocalPlayer.PlayerTycoon.Value:GetPivot().p - humanoidRootPart:GetPivot().p).Magnitude <= 150 then
                    repeat task.wait()
                        humanoidRootPart:PivotTo(game:GetService("Players").LocalPlayer.PlayerTycoon.Value:GetPivot())
                    until (game:GetService("Players").LocalPlayer.PlayerTycoon.Value:GetPivot().p - humanoidRootPart:GetPivot().p).Magnitude <= 150
                end
                if Settings.DelayRebirth == true then
                    task.delay(2,function()
                        game:GetService("ReplicatedStorage").Rebirth:InvokeServer(26)
                    end)
                else
                    game:GetService("ReplicatedStorage").Rebirth:InvokeServer(26)
                end
                if Settings.AutoLoadSetup == true then
                    game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load","Layout"..Settings.LayoutSelected)
                    if Settings.ShouldReload == true then
                        task.wait(Settings.LoadAfter)
                        game:GetService("ReplicatedStorage").Layouts:InvokeServer("Load","Layout"..Settings.LayoutSelected)
                    end
                end
            end
        end
    end)
end)
Toggles.AutoLoadSetup:OnChanged(function()
    Settings.AutoLoadSetup = Toggles.AutoLoadSetup.Value
end)
Toggles.ShouldReload:OnChanged(function()
    Settings.ShouldReload = Toggles.ShouldReload.Value
end)


game.ReplicatedStorage.ItemObtained.OnClientEvent:Connect(function(Item,Amt)
    if Item and Amt and Settings.ItemTracker == true then
        
        local Tier = game.ReplicatedStorage.Tiers:FindFirstChild(tostring(Item.Tier.Value))
        local ImageId = Item.ThumbnailId.Value
        if Tier.TierName.Value == "Slipstream" then return end
        if string.find(ImageId,"rbxasset") then
           ImageId = string.split(tostring(Item.ThumbnailId.Value),"//")[2] 
        end
        local ImageData = game:GetService("HttpService"):JSONDecode(request({Url="https://thumbnails.roblox.com/v1/assets?assetIds="..tonumber(ImageId).."&returnPolicy=PlaceHolder&size=512x512&format=Png&isCircular=false"}).Body)
        local ImageLink = ImageData.data[1]["imageUrl"]
        local TierColor = Color3.new((Tier.TierColor.Value.r*0.7) + 0.2, (Tier.TierColor.Value.g*0.7) + 0.2, (Tier.TierColor.Value.b*0.7) + 0.2)
        local Data = {["embeds"]= {{
            ["title"] = "**New Item**",
            ["fields"] = {
                {
                    ["name"] = ":page_facing_up: **Item**",
                    ["value"] =  tostring("```\n"..Item.Name.."```"),
                    ["inline"] = true
                },
                {
                    ["name"] = (":arrow_up: **Tier**"),
                    ["value"] =  tostring("```\n"..Tier.TierName.Value.."```"),
                    ["inline"] = true
                },
                {
                    ["name"] = (":chart_with_upwards_trend:  **Total Quantity**"),
                    ["value"] =  tostring("```\n"..require(game:GetService("Players").LocalPlayer.PlayerGui.GUI.Inventory.Inventory).localInventory[Item.ItemId.Value].Quantity.."```"),
                    ["inline"] = true
                },
                {
                    ["name"] = (":recycle: **Rebirth Data**"),
                    ["value"] =  tostring("```\nRebirth: "..tostring(game:GetService("Players").LocalPlayer.Rebirths.Value).." | Rebirths With PV: "..tostring(game:GetService("Players").LocalPlayer.Rebirths.Value-oldRebirths).."```"),
                    ["inline"] = false
                },
                {
                    ["name"] = (":link: **Item Info | Wiki**"),
                    ["value"] =  tostring("https://minershaven.fandom.com/wiki/"..Item.Name:gsub(" ", "_")),
                    ["inline"] = false
                },
            },

        ["color"] = tonumber("0x"..tostring(string.split((string.format("#%02X%02X%02X", TierColor.R * 0xFF,TierColor.G * 0xFF, TierColor.B * 0xFF)),"#")[2])),
        ["footer"] = {["text"] = "Project Vertigo | "..os.date()},
        ["thumbnail"] = {["url"]=tostring(ImageLink)}
        }}
    }
    
        request({Url = Settings.WebhookLink.."?wait=true", Body =  game:GetService("HttpService"):JSONEncode(Data), Method = "POST", Headers = {["content-type"] = "application/json"}})
    end
end)


--Options
Options.WebhookLink:OnChanged(function()
    Settings.WebhookLink = Options.WebhookLink.Value
end)
Options.SelectedUpgrader:OnChanged(function()
    Settings.SelectedUpgrader = Options.SelectedUpgrader.Value
end)
Options.SelectedFurnace:OnChanged(function()
    Settings.SelectedFurnace = Options.SelectedFurnace.Value
end)
Options.LayoutSelected:OnChanged(function()
    Settings.LayoutSelected = Options.LayoutSelected.Value
end)
Options.LoadAfter:OnChanged(function()
    Settings.LoadAfter = Options.LoadAfter.Value
end)
Options.LayoutCopierSelected:OnChanged(function()
    Settings.LayoutCopierSelected = Options.LayoutCopierSelected.Value
end)
Options.LayoutPlayerSelected:OnChanged(function()
    Settings.LayoutPlayerSelected = Options.LayoutPlayerSelected.Value
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() 
    Library:Unload() 
    for i,v in pairs(Toggles) do
        v:SetValue(false)
    end
    game:GetService("RunService"):Set3dRenderingEnabled(true)
end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' }) 
Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings() 
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 
ThemeManager:SetFolder('ProjectVertigo')
SaveManager:SetFolder('ProjectVertigo/MinersHaven')
SaveManager:BuildConfigSection(Tabs['UI Settings']) 
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
