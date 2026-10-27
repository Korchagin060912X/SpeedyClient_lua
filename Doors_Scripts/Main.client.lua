local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
repeat task.wait() until game:IsLoaded()
if game:GetService("Players").LocalPlayer:GetAttribute("SpeedyClientLoaded") then
if getgenv().Library then
getgenv().Library:Notify("Speedy Client 『 Already Loaded 』",4)
else
print("Speedy Client 『 Already Loaded 』")
end
return end
game:GetService("Players").LocalPlayer:SetAttribute("SpeedyClientLoaded",true)
local LibraryName = 'Speedy Client'
repeat task.wait() until LocalPlayer.Character
if   getgenv().ScriptLibrary ~= "Linoria" then
getgenv().ScriptLibrary = getgenv().ScriptLibrary or "Linoria"
end
local repo = getgenv().ScriptLibrary == "Obsidian" and 'https://raw.githubusercontent.com/mstudio45/Obsidian/main/' or getgenv().ScriptLibrary == "Linoria" and 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
task.wait()
local ThemeManager, SaveManager
pcall(function() ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))() end)
pcall(function() SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))() end)
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheHunterSolo1/Scripts/main/ESPLibrary"))() 
local HttpService = game:GetService("HttpService")
if SaveManager then
local oldSave = SaveManager.Save
SaveManager.Save = function(self, name)
if Library.KeybindFrame then
local pos = Library.KeybindFrame.Position
local data = { pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset }
getgenv().SpeedyClient_KeybindPos = data
pcall(function()
if writefile and self.Folder then
writefile(self.Folder .. '/settings/' .. name .. '_keybindpos.json', HttpService:JSONEncode(data))
end
end)
end
return oldSave(self, name)
end
local oldLoad = SaveManager.Load
SaveManager.Load = function(self, name)
local result = oldLoad(self, name)
pcall(function()
if isfile and self.Folder and isfile(self.Folder .. '/settings/' .. name .. '_keybindpos.json') then
local data = HttpService:JSONDecode(readfile(self.Folder .. '/settings/' .. name .. '_keybindpos.json'))
if data and Library.KeybindFrame then
Library.KeybindFrame.Position = UDim2.new(data[1], data[2], data[3], data[4])
getgenv().SpeedyClient_KeybindPos = data
end
end
end)
return result
end
end
local Options = Library.Options
local Toggles = Library.Toggles
local Connections = {}
local Window = Library:CreateWindow({
Title = LibraryName,
Center = true,
ToggleKeybind = Enum.KeyCode.RightControl,
AutoShow = true,
NotifySide = "Right",
ShowCustomCursor = true,
})
if Library.KeybindFrame then
if getgenv().SpeedyClient_KeybindPos then
local p = getgenv().SpeedyClient_KeybindPos
Library.KeybindFrame.Position = UDim2.new(p[1], p[2], p[3], p[4])
end
table.insert(Connections, Library.KeybindFrame:GetPropertyChangedSignal("Position"):Connect(function()
local pos = Library.KeybindFrame.Position
getgenv().SpeedyClient_KeybindPos = { pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset }
end))
end
local Notifying = "Library"
local PlaySound = true
local function Notify(txt, duration)
Library:Notify(txt, duration)
if PlaySound then
local Sound = Instance.new("Sound", game:GetService("SoundService"))
Sound.SoundId = "rbxassetid://101511361468852"
Sound.PlaybackSpeed = 0.77
Sound.Volume = 2
Sound:Play()
game:GetService("Debris"):AddItem(Sound, 3)
end
end
function AddESP(part,txt,color)
ESPLibrary:AddESP({
Object = part, Text = txt, Color = color })
end
function AddEntityESP(part,txt,color)
if part:IsA("Model") then
while not part.PrimaryPart do
for _, v in pairs(part:GetChildren()) do
if v:IsA("BasePart") then
part.PrimaryPart = v
end
end
task.wait()
end
if part.PrimaryPart then
part.PrimaryPart.Transparency = 0.99
end
if not part:FindFirstChildOfClass("Humanoid") then
Instance.new("Humanoid",part)
end
end
if part.Name == "FigureRig" or part.Name == "FigureRagdoll" then
part:WaitForChild("Root").Size = Vector3.new(0.001, 0.001, 0.001)
end
ESPLibrary:AddESP({
Object = part, Text = txt, Color =  color, })
end
function GetLibraryCode()
local CodeLength = game.ReplicatedStorage.GameData.Floor.Value == "Fools" and 10 or 5
local Slot = table.create(CodeLength, "_")
local Paper
for _, plr in pairs(Players:GetPlayers()) do
local char = plr.Character
if char then
Paper = char:FindFirstChild("LibraryHintPaper") or char:FindFirstChild("LibraryHintPaperHard") or
plr.Backpack:FindFirstChild("LibraryHintPaper") or plr.Backpack:FindFirstChild("LibraryHintPaperHard")
if Paper then break end
end
end
if not Paper then return table.concat(Slot) end
local Hints = LocalPlayer.PlayerGui.PermUI.Hints:GetChildren()
for _, i in pairs(Paper.UI:GetChildren()) do
if i:IsA("ImageLabel") and i.Name ~= "Image" then
local Pos = tonumber(i.Name)
if Pos and Slot[Pos] then
for _, v in pairs(Hints) do
if v.Name == "Icon" and v.ImageRectOffset.X == i.ImageRectOffset.X then
local Label = v:FindFirstChild("TextLabel")
if Label then
Slot[Pos] = Label.Text
end
break
end
end
end
end
end
return table.concat(Slot)
end
if workspace:FindFirstChild("Lobby") then
local Tabs = {
Main = Window:AddTab('Game', "star"),
Settings = Window:AddTab('Settings',"settings"),
}
local Tp = Tabs.Main:AddLeftGroupbox("Teleport")
Tp:AddLabel('Main menu appears after teleport', true)
local function FastElevator(dest, settings)
local Event = game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder") and game:GetService("ReplicatedStorage").RemotesFolder:FindFirstChild("CreateElevator")
if Event then
Event:FireServer({
Mods = {},
Settings = settings or {},
Destination = dest,
FriendsOnly = false,
MaxPlayers = "1"
})
end
end
Tp:AddButton("Teleport to Hotel", function() FastElevator("Hotel") end)
Tp:AddButton("Teleport to Mines", function() FastElevator("Mines") end)
Tp:AddButton("Teleport to Rooms (PRICE)", function() FastElevator("Rooms") end)
Tp:AddButton("Teleport to Backdoors", function() FastElevator("Backdoor") end)
Tp:AddButton("Teleport to Outdoors (FREE)", function() FastElevator("Garden") end)
Tp:AddButton("Teleport to Retro Mode", function() FastElevator("Retro") end)
Tp:AddButton("Teleport to Super Hard Mode", function() FastElevator("SuperHardMode") end)
Tp:AddButton("Teleport to Endless", function() FastElevator("Endless") end)
Tp:AddButton("Teleport to Rush Mode", function() FastElevator("Fools26") end)
Tp:AddButton("Teleport to Battle Mode", function() FastElevator("Party") end)
Tp:AddButton("Teleport to Chaos", function() FastElevator("Curated", { youtube = "", twitch = "" }) end)
Tp:AddButton("Teleport to Daily Run", function() FastElevator("Daily") end)
Tp:AddButton("Teleport to Cringles Workshop", function() FastElevator("CringlesWorkshop") end)
Tp:AddButton("Teleport to Trick Or Treat", function() FastElevator("Halloween25") end)
Tp:AddButton("Teleport to Hotel-", function() FastElevator("BeforePlus") end)
local MenuGroup = Tabs.Settings:AddLeftGroupbox('UI Settings')
local UtilityBox = Tabs.Settings:AddRightGroupbox('Speedy Client Utilities')
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("ShowKeybinds", { Text = "Show Keybinds Overlay", Default = false }):OnChanged(function()
Library.KeybindFrame.Visible = Toggles.ShowKeybinds.Value
end)
MenuGroup:AddToggle("ShowCustomCursor", {
Text = "Custom Cursor",
Default = true,
Callback = function(Value)
Library.ShowCustomCursor = Value
end,
})
MenuGroup:AddDivider()
MenuGroup:AddToggle('PlayNotifySound',{
Text = "Play Notification Sound",
Default = true,
Callback = function(Value)
PlaySound = Value
end
})
MenuGroup:AddDropdown("NotificationSide", {
Values = { "Left", "Right" },
Default = "Right",
Text = "Notification Side",
Callback = function(Value)
Library:SetNotifySide(Value)
end,
})
MenuGroup:AddButton('Test Notification',function()
Notify("Hello World",2)
end)
MenuGroup:AddDropdown("Library", {
Values = { "Obsidian", "Linoria" },
Default = 2,
Text = "Library",
Callback = function(Value)
getgenv().ScriptLibrary = tostring(Value)
Notify('Please Unload Script and Execute Again to Take Effect',4)
end,
})
MenuGroup:AddDivider()
MenuGroup:AddDropdown("DPIDropdown", {
Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
Default = "100%",
Text = "DPI Scale",
Callback = function(Value)
Value = Value:gsub("%%", "")
local DPI = tonumber(Value)
Library:SetDPIScale(DPI)
end,
})
UtilityBox:AddButton({
Text = "Unload Speedy Client",
Func = function()
LocalPlayer:SetAttribute("SpeedyClientLoaded", nil)
if Library.KeybindFrame then
local pos = Library.KeybindFrame.Position
getgenv().SpeedyClient_KeybindPos = { pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset }
end
for _, con in pairs(Connections) do con:Disconnect() end
Library:Unload()
ESPLibrary:Unload()
end
})
if ThemeManager then
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("Speedy Client")
end
if SaveManager then
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
SaveManager:SetFolder("Speedy Client/DOORSLOBBY")
SaveManager:BuildConfigSection(Tabs['Settings'])
end
if ThemeManager then
ThemeManager:ApplyToTab(Tabs['Settings'])
end
Notify("Successfully Loaded for Game |  DOORS Lobby ",4)
else
local function GetDistanceToPlayer(Pos)
local DisA = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position or workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position or Vector3.new(0, 0, 0)
local Dis = (DisA - Pos).Magnitude
return Dis
end
local PathFolder = Instance.new("Folder",workspace)
PathFolder.Name = "PathFolder"
function PathTo(Pos)
local Character = LocalPlayer.Character
local Root = Character and Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character and Character:FindFirstChild("Humanoid")
if not Root or not Humanoid then return end
local p = PathfindingService:CreatePath({
AgentRadius = 2,
AgentHeight = 5,
AgentCanJump = true,
WaypointSpacing = 2,
AgentCanSprint = false,
AgentMaxSlope = 45,
AgentJumpHeight = 0
})
local AdjustedPos = Pos and Pos +Vector3.new(0, 0, 1)
p:ComputeAsync(Root.Position, AdjustedPos)
if  p.Status ~= Enum.PathStatus.Success then return end
for _, waypoint in ipairs(p:GetWaypoints()) do
if not Toggles.AutoRooms.Value or Library.Unloaded then break end
local Dist = (Root.Position - waypoint.Position).Magnitude
if Dist >= 2 then
Humanoid:MoveTo(waypoint.Position)
Humanoid.MoveToFinished:Wait()
end
end
end
InfCrucfixTable = {
RushMoving = 90,
AmbushMoving = 160,
A60 = 140,
A120 = 99,
GlitchRush = 150,
GlitchAmbush = 110,
}
local Firepp = fireproximityprompt
local Require = require
local ReplicateSignal = replicatesignal or (typeof(replicatesignal) == "function" and replicatesignal)
local FireTouch = firetouchinterest
local HookMeta = hookmetamethod
local IsNetworkOwner = isnetworkowner
Items = {
["Bandage"] = "Bandage",
["Flashlight"] = "Flash light",
["Battery"] = "Battery",
["BatteryPack"] = "Battery Pack",
["SkeletonKey"] = "Skeleton Key",
["Crucifix"] = "Crucifix",
["Straplight"] = "Strap Light",
["Lockpick"] = "Lockpick",
["Bulklight"] = "Bulk Light",
["Vitamins"] = "Vitamin",
["Shears"] = "Shears",
["LaserPointer"] = "Laser Pointer",
["Candle"] = "Candle",
["Smoothie"] = "Smoothie",
["StarJug"] = "Jug of Bottle",
["StardustPickup"] = "Stardust",
["ChestBoxLocked"] = "Locked Chest",
["ChestBox"] = "Chest",
["Chest_Vine"] = "Chest Vine",
["Toolbox_Locked"] = "Locked Toolbox",
["Toolshed_Small"] = "Toolshed",
["TimerLever"] = "Lever",
["HolyGrenade"] = "Holy Grenade",
["ShieldMini"] = "Mini Shield",
["ShieldBig"] = "Big Shield",
["CrucifixWall"] = "Crucifix",
["Glowsticks"] = "Glow Sticks",
["BandagePack"] = "Bandage Pack",
["AlarmClock"] = "Alarm Clock",
["MouseHole"] = "Louie Mouse",
["StarVial"] = "Star Vial",
["StarBottle"] = "Star Bottle",
["Compass"] = "Compass",
["Lantern"] = "Lantern",
["KeyIron"] = "Iron Key",
["GoldGun"] = "Golden Gun",
["Candy"] = "Candy",
["WaterPump"] = "Water Pump",
["VineGuillotine"] = "Vine Lever",
["Shakelight"] = "Shake Light",
["LibraryHintPaper"] = "Hint Paper",
["LotusPetalPickup"] = "Lotus Petal",
}
local Floor = ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Floor")
local LatestRoom = ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LatestRoom")
local MainGame = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI").Initiator:WaitForChild("Main_Game")
local RemoteListener = MainGame:WaitForChild("RemoteListener")
local RequiredMainGame
local ClientModules = ReplicatedStorage:FindFirstChild("ModulesClient") or ReplicatedStorage:FindFirstChild("ClientModules")
local RemotesFolder = ReplicatedStorage:FindFirstChild("EntityInfo") and ReplicatedStorage:FindFirstChild("EntityInfo")  or ReplicatedStorage:FindFirstChild("Bricks")  and ReplicatedStorage:FindFirstChild("Bricks") or ReplicatedStorage:FindFirstChild("RemotesFolder")
local MotorReplication = RemotesFolder:WaitForChild("MotorReplication")
local CollisionClone
local CamLock = RemotesFolder:WaitForChild("CamLock")
local AnchorArgs
local PL = RemotesFolder:WaitForChild("PL")
local ClutchHeartbeat = RemotesFolder:WaitForChild("ClutchHeartbeat")
local params = RaycastParams.new()
params.FilterDescendantsInstances = {LocalPlayer.Character}
local  SeekPath = Instance.new("Folder",workspace)
SeekPath.Name = "SeekPath"
function ShowSeekPath(v)
local Part = Instance.new("Part", SeekPath)
Part.Size = Vector3.new(1.5, 1.5, 1.5)
Part.Anchored = true
Part.Shape = "Ball"
Part.Position = v.Position
Part.CanCollide = false
Part.Color = Color3.new(0, 1, 0)
Debris:AddItem(Part, 60)
end
function FixBridge(v)
for _, i in pairs(v:GetChildren()) do
if i.Name == "PlayerBarrier" and i.Rotation.X == 180 then
local Barrier = i:Clone()
Barrier.CFrame = CFrame.new(i.Position.X, i.Position.Y, i.Position.Z)
Barrier.CFrame = Barrier.CFrame * CFrame.new(0, -7, 0)
Barrier.Size = Vector3.new(40, 0.1, 40)
Barrier.Transparency = 0.5
Barrier.Color = Color3.new(0.5, 0, 0.5)
Barrier.Material = "ForceField"
Barrier.Parent = v
Barrier.Name = "BridgeBarrier"
Barrier.Anchored = true
Barrier.CanCollide = true
end
end
end
if Require then
RequiredMainGame = require(MainGame)
end
local getcons = getconnections or get_signal_cons or get_relative_connections
if getcons then
for _, con in pairs(getcons(LocalPlayer.Idled)) do
if con.Disable then
con:Disable()
end
end
end
table.insert(Connections,LocalPlayer.CharacterAdded:Connect(function()
task.wait(1.5)
if LocalPlayer.Character then
MainGame = LocalPlayer.PlayerGui.MainUI.Initiator:WaitForChild("Main_Game")
RemoteListener = MainGame.RemoteListener
params.FilterDescendantsInstances = {LocalPlayer.Character}
if Toggles.NoScenes.Value then
local Cutscene = RemoteListener:FindFirstChild("Cutscenes") or RemoteListener:FindFirstChild("Cutscenes_")
Cutscene.Name = "Cutscenes_"
end
if Require then
RequiredMainGame = require(MainGame)
end
end
if Toggles.Jamming.Value then
if  ReplicatedStorage:FindFirstChild("LiveModifiers") and ReplicatedStorage:FindFirstChild("LiveModifiers"):FindFirstChild("Jammin") then
local Jam = LocalPlayer.PlayerGui.MainUI.Initiator:FindFirstChild("Main_Game").Health.Jam
Jam.Playing = false
local Jamming = game:GetService("SoundService").Main.Jamming
Jamming.Enabled =  false
end
end
if Toggles.Godmode.Value and RemotesFolder.Name ~= "RemotesFolder" then
LocalPlayer.Character.Collision.Position -= Vector3.new(0, 4, 0)
end
if Toggles.Dread.Value then
local Dread = LocalPlayer:FindFirstChild("Dread",true) or LocalPlayer:FindFirstChild("_Dread",true)
if Dread then
Dread.Name = "_Dread"
end
end
if Toggles.Halt.Value then
local Dread = ClientModules.EntityModules:FindFirstChild("Shade",true) or ClientModules.EntityModules:FindFirstChild("_Shade",true)
if Dread then
Dread.Name = "_Shade"
end
end
end))
local Tabs = {
Main = Window:AddTab('Player', "star"),
Bypass = Window:AddTab('Bypass', "ban"),
Visuals = Window:AddTab('Visuals',"eye"),
Floor = Window:AddTab('Floor', "sparkles"),
Settings = Window:AddTab('Settings',"settings"),
}
local PlayerBox = Tabs.Main:AddLeftGroupbox('Player')
local GameBox = Tabs.Main:AddLeftGroupbox('Game Management')
local HotelFloor = Tabs.Floor:AddLeftGroupbox('Hotel')
local MinesFloor = Tabs.Floor:AddRightGroupbox('Mines')
local FoolsFloor = Tabs.Floor:AddRightGroupbox('Fools')
local RoomsFloor = Tabs.Floor:AddLeftGroupbox('Rooms')
local RetroFloor = Tabs.Floor:AddLeftGroupbox('Retro')
local AutoBox = Tabs.Main:AddRightGroupbox('Auto')
local ReachBox = Tabs.Main:AddRightGroupbox('Reach')
local CameraBox = Tabs.Visuals:AddLeftGroupbox('Camera')
local LightingBox = Tabs.Visuals:AddLeftGroupbox('Lighting')
local ESPBox = Tabs.Visuals:AddRightGroupbox('ESP')
local ESPSettings = Tabs.Visuals:AddRightGroupbox('Settings')
local NotifyBox = Tabs.Visuals:AddRightGroupbox('Notifying')
local BypassEntityBox = Tabs.Bypass:AddLeftGroupbox('Bypass Entities')
local BypassBox = Tabs.Bypass:AddRightGroupbox('Bypass')
RetroFloor:AddToggle('AntiLava',{
Text = "Anti Lava",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "Lava" then
v.CanTouch = not Value
end
end
end
})
FoolsFloor:AddToggle('AntiBanana',{
Text = "Anti Banana",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace:GetChildren()) do
if v.Name == "BananaPeel" then
v.CanTouch = not Value
end
end
end
})
FoolsFloor:AddToggle('AntiJeff',{
Text = "Anti Jeff",
Default = false,
Callback = function(Value)
local v = workspace:FindFirstChild("JeffTheKiller")
if v.Name == "JeffTheKiller" then
repeat task.wait() until v.PrimaryPart and isnetworkowner(v.PrimaryPart)
for _, i in pairs(v:GetChildren()) do
if i:IsA("BasePart") then
i.CanTouch = Value and false or true
end
end
v.Humanoid.Health = Value and 0 or 100
end
end
})
GameBox:AddButton({
Text = "Revive",
DoubleClick = true,
Func = function()
RemotesFolder.Revive:FireServer()
end
})
GameBox:AddButton({
Text = "Play Again",
DoubleClick = true,
Func = function()
RemotesFolder.PlayAgain:FireServer()
end
})
local Pressed = false
GameBox:AddButton({
Text = "Reset",
DoubleClick = true,
Func = function()
Pressed = not Pressed
if not Pressed then
if RemotesFolder:FindFirstChild("Underwater") then
RemotesFolder.Underwater:FireServer(false)
end
return
end
if ReplicateSignal then
replicatesignal(LocalPlayer.Kill)
else
Notify("Double Click to stop", 5)
task.spawn(function()
while Pressed and LocalPlayer:GetAttribute("Alive") ~= false do
if RemotesFolder:FindFirstChild("Underwater") then
RemotesFolder.Underwater:FireServer(true)
end
task.wait()
end
if RemotesFolder:FindFirstChild("Underwater") then
RemotesFolder.Underwater:FireServer(false)
end
Pressed = false
end)
end
end
})
GameBox:AddButton({
Text = "Lobby",
DoubleClick = true,
Func = function()
RemotesFolder.Lobby:FireServer()
end
})
FoolsFloor:AddToggle('InfRevive',{
Text = "Infinite Revive",
Default = false
})
FoolsFloor:AddToggle('DeleteSeekFE',{
Text = "Delete Seek (FE)",
Default = false,
Callback = function(Value)
if Value then
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "TriggerEventCollision" then
Notify("Deleting Seek",3)
for _, i  in pairs(v:GetChildren()) do
if i.Name == "Collision" then
if FireTouch then
firetouchinterest(LocalPlayer.Character.HumanoidRootPart, i, 0)
end
end
end
task.wait(0.5)
if v:FindFirstChild("Collision") then
Notify("Failed to remove Seek", 3)
else
Notify("Deleted Seek Successfully", 3)
end
end
end
end
end
})
RetroFloor:AddToggle('AntiWall',{
Text = "Anti SeekWall",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "ScaryWall" then
for _, i in pairs(v:GetChildren()) do
if i:IsA("BasePart") then
i.CanTouch = not Value
end
end
end
end
end
})
RetroFloor:AddToggle('RealBridge',{
Text = "Show Real Bridge",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "Bridge" then
if v.CanCollide == false then
v.Transparency = Value and 1 or 0
end
end
end
end
})
local Figures = {}
MinesFloor:AddToggle('DeleteFigureFE',{
Text = "Delete Figure (FE)",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "FigureRig" or v.Name == "FigureRagdoll" then
table.insert(Figures,v)
end
end
end
})
MinesFloor:AddToggle('ShowPath',{
Text = "Show Seek Path",
Default = false,
Callback = function(Value)
if Value then
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "SeekGuidingLight" then
ShowSeekPath(v)
end
end
else
SeekPath:ClearAllChildren()
end
end
})
MinesFloor:AddToggle('FixBrokenBridge',{
Text = "Fix Broken Bridge",
Default = false,
Callback = function(Value)
if Value then
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "Bridge" then
FixBridge(v)
end
end
else
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "BridgeBarrier" then
v:Destroy()
end
end
end
end
})
local DuckBoards = {}
local Nodes = {}
if Require then
local Control = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls().GetMoveVector
end
MinesFloor:AddToggle('AutoMinecart',{
Text = "Auto Minecart",
Risky = true,
Default = false,
Callback = function(Value)
if Value then
for _, v in workspace.CurrentRooms:GetDescendants() do
if v.Name == "DuckBoard" then
table.insert(DuckBoards, v)
end
if string.find(v.Name, "MinecartNode") then
table.insert(Nodes, v)
end
end
else
require(LocalPlayer.PlayerScripts.PlayerModule):GetControls().GetMoveVector = Control
table.clear(Nodes)
table.clear(DuckBoards)
end
end
})
local Anchors = {}
MinesFloor:AddToggle('AutoAnchorSolver',{
Text = "Auto Anchor Solver",
Default = false,
Callback = function(Value)
if Value then
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "MinesAnchor" then
table.insert(Anchors,v)
end
end
end
end
})
MinesFloor:AddToggle('AntiSeekFlood',{
Text = "Anti Seek Flood",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "SeekFloodline" then
v.CanCollide = Value
end
end
end
})
RoomsFloor:AddToggle('AutoRooms',{
Text = "Auto A-1000",
Default = false,
Callback = function(Value)
if not Value then
PathFolder:ClearAllChildren()
if LocalPlayer.Character then
LocalPlayer.Character.Collision.Size = Vector3.new(5.5,3,3)
LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
PathActive = false
end
end
end
})
if (getrawmetatable or debug.getmetatable) and (setreadonly or make_writeable) and newcclosure then
local getmt = getrawmetatable or debug.getmetatable
local setro = setreadonly or (make_writeable and function(t, b) if b then make_writeable(t) else make_readonly(t) end end)
local mt = getmt(game)
local oldIndex = mt.__index
setro(mt, false)
mt.__index = newcclosure(function(t, k)
if not checkcaller() and k == "MoveDirection" and t:IsA("Humanoid") then
local char = LocalPlayer.Character
if char and Toggles.AutoRooms.Value and not char:GetAttribute("Hiding") then
return Vector3.new(0, 0, 1)
end
end
return oldIndex(t, k)
end)
setro(mt, true)
end
RoomsFloor:AddToggle('IgnoreA60',{
Text = "Ignore A-60",
})
ESPSettings:AddToggle('ShowDistance',{
Text = "Show ESP Distance",
Default = true,
Callback = function(Value)
ESPLibrary:SetShowDistance(Value)
end
})
ESPSettings:AddToggle('ShowTracers',{
Text = "Show ESP Tracers",
Default = false,
Callback = function(Value)
ESPLibrary:SetTracers(Value)
end
})
ESPSettings:AddToggle('ShowRainbow',{
Text = "Show ESP Rainbow",
Default = false,
Callback = function(Value)
ESPLibrary:SetRainbow(Value)
end
})
ESPSettings:AddDropdown("SetESPMode", {
Text = "Set ESP Mode",
Values = {"Highlight/Text", "Text", "Highlight"},
Default = 1,
Multi = false,
Callback = function(Value)
ESPLibrary:SetESPMode(Value)
end
})
ESPSettings:AddDropdown("SetFont", {
Text = "Set Font",
Values = {
"Legacy", "Arial", "ArialBold", "SourceSans", "SourceSansBold",
"SourceSansLight", "SourceSansItalic", "Bodoni", "Garamond",
"Cartoon", "Code", "Highway", "SciFi", "Arcade", "Fantasy",
"Antique", "Gotham", "GothamMedium", "GothamBold", "GothamBlack",
"AmaticSC", "Bangers", "Creepster", "DenkOne", "FredokaOne",
"IndieFlower", "LuckiestGuy", "Michroma", "Nunito", "Oswald",
"PatrickHand", "PermanentMarker", "Roboto", "RobotoCondensed",
"RobotoMono", "Sarpanch", "SpecialElite", "TitilliumWeb", "Ubuntu"
},
Default = "Legacy",
Multi = false,
Callback = function(Value)
ESPLibrary:SetFont(Value)
end
})
task.spawn(function()
task.wait(0.1)
ESPLibrary:SetTracers(false)
ESPLibrary:SetFont("Legacy")
end)
PlayerBox:AddSlider("MovementSpeed", {
Text = "Movement Speed",
Default = 15,
Min = 15,
Max = 21,
Rounding = 1,
Compact = false,
Callback = function(Value)
end,
Tooltip = "Walking Speed",
})
PlayerBox:AddToggle('EnableMovementSpeed',{
Text = "Enable Movement Speed",
Default = false,
Callback = function(Value)
if not Value then
LocalPlayer.Character.Humanoid.WalkSpeed = 15
end
end
})
PlayerBox:AddSlider("ClimbingSpeed", {
Text = "Climbing Speed",
Default = 15,
Min = 15,
Max = 30,
Rounding = 1,
Compact = false,
Callback = function(Value)
end,
Tooltip = "Climbing Speed",
})
PlayerBox:AddToggle('EnableClimbingSpeed',{
Text = "Enable Climbing Speed",
Default = false,
Callback = function(Value)
if not Value then
LocalPlayer.Character.Humanoid.WalkSpeed = 15
end
end
})
PlayerBox:AddDivider()
local OldAccel
PlayerBox:AddToggle('NoAcc',{
Text = "No Slipping",
Default = false,
Callback = function(Value)
if Value then
OldAccel = LocalPlayer.Character.HumanoidRootPart.CustomPhysicalProperties
else
if OldAccel then
LocalPlayer.Character.HumanoidRootPart.CustomPhysicalProperties = OldAccel
OldAccel = nil
end
end
end
})
PlayerBox:AddToggle('NoClip',{
Text = "No Clip",
Default = false,
Tooltip = "You Can Move Through Wall",
Callback = function(Value)
if not Value then
for _, v in pairs(LocalPlayer.Character:GetChildren()) do
if not v.Name == "CollisionClone" then
if v:IsA("BasePart") then
v.CanCollide  = true
end
end
end
end
end
}):AddKeyPicker("NoclipKeybind", {
Default = "N", 	SyncToggleState = true,
Mode ="Toggle" , 
Text = "No Clip", 	NoUI = false, 
Callback = function(Value)
end,
ChangedCallback = function(NewKey, NewModifiers)
end,
})
PlayerBox:AddToggle('Flight',{
Text = "Flight",
Default = false,
Callback = function(Value)
if not Value then
if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlightVelocity") then
LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlightVelocity"):Destroy()
end
end
end
}):AddKeyPicker("FlightKeybind", {
Default = "F", 	SyncToggleState = true,
Mode ="Toggle" , 
Text = "Flight", 	NoUI = false, 
Callback = function(Value)
end,
ChangedCallback = function(NewKey, NewModifiers)
end,
})
PlayerBox:AddSlider("FlightSpeed", {
Text = "Flight Speed",
Default = 15,
Min = 15,
Max = 21,
Rounding = 1,
Compact = false,
Callback = function(Value)
end,
Tooltip = "Flight Speed",
})
PlayerBox:AddToggle('EnableJump',{
Text = "Enable Jumping",
Default = false,
Tooltip = "You Can Move Jump",
Callback = function(Value)
if not Value then
LocalPlayer.Character:SetAttribute("CanJump",false)
end
end
})
PlayerBox:AddToggle('InstaInteract',{
Text = "Instant Interact",
Default = false,
Tooltip = "Interactions are Instantly",
Callback = function(Value)
if Value then
for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then
v:SetAttribute("Duration",v.HoldDuration)
v.HoldDuration = 0
end
end
else
for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then
v.HoldDuration = v:GetAttribute("Duration") or 0
end
end
end
end
})
PlayerBox:AddToggle('InfJump',{
Text = "Infinite Jump",
Default = false
})
if UserInputService.KeyboardEnabled then
local d = false
table.insert(Connections, UserInputService.JumpRequest:Connect(function()
if Toggles.InfJump.Value and not d and LocalPlayer.Character then
d = true
LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping, true)
task.wait(0.1)
d = false
end
end))
elseif UserInputService.TouchEnabled then
table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function()
task.wait(1)
if LocalPlayer.PlayerGui.MainUI.MainFrame.MobileButtons:FindFirstChild("JumpButton") then
table.insert(Connections, LocalPlayer.PlayerGui.MainUI.MainFrame.MobileButtons.JumpButton.MouseButton1Click:Connect(function()
if Toggles.InfJump.Value and LocalPlayer.Character then
LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping, true)
end
end))
end
end))
if LocalPlayer.PlayerGui.MainUI.MainFrame.MobileButtons:FindFirstChild("JumpButton") then
table.insert(Connections, LocalPlayer.PlayerGui.MainUI.MainFrame.MobileButtons.JumpButton.MouseButton1Click:Connect(function()
if Toggles.InfJump.Value and LocalPlayer.Character then
LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping, true)
end
end))
end
end
PlayerBox:AddToggle('Godmode',{
Text = "Godmode",
Default = false,
Tooltip = "Can Lagback you or not work",
Risky  = true,
Callback = function(Value)
if Value and RemotesFolder.Name ~= "RemotesFolder" then
LocalPlayer.Character.Collision.Position -= Vector3.new(0, 4, 0)
end
if Value and RemotesFolder.Name == "RemotesFolder" then
LocalPlayer.Character:PivotTo(LocalPlayer.Character.CollisionPart.CFrame * CFrame.new(0, -2,0))
end
if not Value and RemotesFolder.Name == "RemotesFolder" then
LocalPlayer.Character.Humanoid.HipHeight = 2.4
LocalPlayer.Character.Collision.Size = Vector3.new(5.5, 3, 3)
LocalPlayer.Character.LowerTorso.Root.C1 = CFrame.new(Vector3.new(0, 0, 0))
LocalPlayer.Character.Collision.CollisionCrouch.Size = Vector3.new(5.5, 3, 3)
LocalPlayer.Character:PivotTo(LocalPlayer.Character.CollisionPart.CFrame * CFrame.new(0, 2,0))
end
if not Value and RemotesFolder.Name ~= "RemotesFolder" then
LocalPlayer.Character.Collision.Position = LocalPlayer.Character.HumanoidRootPart.Position
end
end
}):AddKeyPicker("GodmodeKeybind", {
Default = "G", 	SyncToggleState = true,
Mode ="Toggle" , 
Text = "Godmode", 	NoUI = false, 
Callback = function(Value)
end,
ChangedCallback = function(NewKey, NewModifiers)
end,
})
local PromptIgnore = {
HidePrompt = true,
ClimbPrompt = true,
PropPrompt = true,
InteractPrompt = true,
RiftPrompt = true,
StarRiftPrompt = true,
NoHidingLilBro = true,
AnimatePrompt = true,
RevivePrompt = true,
}
Interactions = {}
AutoBox:AddToggle("AutoInteract",{
Text = "Auto Interact",
Default = false,
Tooltip = "Automatically Interacts with things when near",
Callback = function(Value)
if Value then
for _, v in ipairs(workspace.CurrentRooms:GetDescendants()) do
if v:IsA("ProximityPrompt") then
if not (PromptIgnore[v.Name] or  v.Parent.Name == "Padlock" or  v.Parent:GetAttribute("JeffShop")) or v.Parent.Name == "RetroWardrobe" or v.Parent.Name == "KeyObtainFake" then
table.insert(Interactions, v)
end
end
end
else
table.clear(Interactions)
end
end
}):AddKeyPicker("AutoInteractKeybind", {
Default = "R", 	SyncToggleState = true,
Mode = Library.IsMobile and "Toggle"  or "Hold", 
Text = "Auto Interact", 	NoUI = false, 
Callback = function(Value)
print("[cb] Keybind clicked!", Value)
end,
ChangedCallback = function(NewKey, NewModifiers)
end,
})
HidingPlaces = {
["Wardrobe"] = "Closet",
["Rooms_Locker"] = "Locker",
["Rooms_Locker_Fridge"] = "Fridge",
["Locker_Large"] = "Locker",
["Backdoor_Wardrobe"] = "Closet",
["Bed"] = "Bed",
["Double_Bed"]  = "Double Bed",
["Toolshed"] = "Closet",
["RetroWardrobe"] = "Closet",
["CircularVent"] = "Vent",
["Bed"] = "Bed",
["Double_Bed"] = "Double_Bed",
}
Closets = {}
AutoBox:AddSlider("AutoInteractDelay", {
Text = "Auto Interact Delay",
Default = 0.05,
Min = 0,
Max = 0.2,
Rounding = 2,
Compact = false,
Callback = function(Value)
end,
})
AutoBox:AddSlider("AutoInteractreach", {
Text = "Auto Interact Range",
Default = 12,
Min = 7,
Max = 12,
Rounding = 2,
Compact = false,
Callback = function(Value)
end,
})
AutoBox:AddDivider()
AutoBox:AddToggle('AutoLibraryCode',{
Text = "Auto Library Code",
Default = false,
})
AutoBox:AddToggle('BruteForceLibCode',{
Text = "Bruteforce Library Code",
Default = false,
})
AutoBox:AddToggle('AutoHeartbeat',{
Text = "Auto Heartbeat Minigame",
Default = false
})
local function Breaker(part)
local label = part:WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("Code")
local function run()
task.wait(0.05)
if not Toggles.AutoBreaker.Value then return end
local target = tonumber(label.Text)
if target then
for _, v in part:GetChildren() do
if v.Name == "BreakerSwitch" and v:GetAttribute("ID") == target then
local trans = part:WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("Code"):WaitForChild("Frame").BackgroundTransparency
local pc = v:FindFirstChild("PrismaticConstraint")
local light = v:FindFirstChild("Light")
local sound = v:FindFirstChild("Sound")
if trans == 0 then
if v:GetAttribute("Enabled") then return end
v:SetAttribute("Enabled", true)
if pc then pc.TargetPosition = -0.2 end
if light then
light.Material = Enum.Material.Neon
local spark = light:FindFirstChild("Spark", true)
if spark then spark:Emit(1) end
end
if sound then sound:Play() end
elseif trans == 1 then
if not v:GetAttribute("Enabled") then return end
v:SetAttribute("Enabled", false)
if pc then pc.TargetPosition = 0.2 end
if light then light.Material = Enum.Material.Glass end
if sound then sound:Play() end
end
break
end
end
end
end
label:GetPropertyChangedSignal("Text"):Connect(run)
run()
end
AutoBox:AddToggle('AutoBreaker',{
Text = "Auto Breaker Minigame",
Default = false,
Callback = function(Value)
if Value then
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "ElevatorBreaker" then
Breaker(v)
end
end
end
end
})
local OldFogEnd
LightingBox:AddToggle('NoFog',{
Text = "No Fog",
Default = false,
Tooltip = "No fog",
Callback = function(Value)
if not Value then
for _, v in pairs(Lighting:GetChildren()) do
if v:IsA("Atmosphere") then
v.Density = 0.94
end
end
end
if Value then
OldFogEnd = Lighting.FogEnd
else
if OldFogEnd then
Lighting.FogEnd = OldFogEnd
OldFogEnd = nil
end
end
end
})
LightingBox:AddToggle('FullBright',{
Text = "Fullbright",
Default = false,
Tooltip = "Make you see in darkness",
Callback = function(Value)
if not Value then
Lighting.Ambient = Color3.fromRGB(0, 0, 0)
Lighting.GlobalShadows = true
for _, v in pairs(workspace.CurrentRooms:GetChildren()) do
v:SetAttribute("Ambient", v:GetAttribute("OldAmbient"))
end
end
end
})

for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if HidingPlaces[v.Name] then
table.insert(Closets, v)
end
end
ESPHooks = {}
task.spawn(function()
local DoorColor         = Color3.fromRGB(120, 255, 120)
local ItemsColor        = Color3.fromRGB(0, 50, 180)
local HidingPlaceColor  = Color3.fromRGB(255, 255, 255)
local LeverColor        = Color3.fromRGB(150, 150, 150)
local BookColor         = Color3.fromRGB(0, 50, 180)
local BreakerColor      = Color3.fromRGB(0, 50, 180)
local GoldColor         = Color3.fromRGB(255, 255, 0)
local LadderColor       = Color3.fromRGB(0, 191, 255)
local FuseColor         = Color3.fromRGB(255, 170, 0)
local EntityColor       = Color3.new(1, 0, 0)
local DoorActiveESP = {}
local DoorRoomCache = {}
local DoorStringCache = {}
local function RemoveDoorESP(part)
if part and DoorActiveESP[part] then
DoorActiveESP[part] = nil
ESPLibrary:RemoveESP(part)
end
end
local function AddDoorESP(part, txt, color, roomNum)
if not part then return end
local data = DoorActiveESP[part]
if data and data.text == txt then return end
if data then ESPLibrary:RemoveESP(part) end
DoorActiveESP[part] = { text = txt, room = roomNum }
if roomNum then
local bucket = DoorRoomCache[roomNum]
if not bucket then bucket = {} DoorRoomCache[roomNum] = bucket end
table.insert(bucket, part)
end
AddESP(part, txt, color)
end
local function CleanOldDoorRooms(currentRoomNum)
currentRoomNum = tonumber(currentRoomNum) or 0
for roomNum, parts in pairs(DoorRoomCache) do
if roomNum < currentRoomNum or roomNum > (currentRoomNum + 1) then
for i = 1, #parts do RemoveDoorESP(parts[i]) end
DoorRoomCache[roomNum] = nil
end
end
end
local function ClearAllDoorESP()
for part in pairs(DoorActiveESP) do
ESPLibrary:RemoveESP(part)
end
table.clear(DoorActiveESP)
table.clear(DoorRoomCache)
table.clear(DoorStringCache)
end
local function ProcessRoomDoors(roomFolder, roomNum)
if not roomFolder then return end
local doorModel = roomFolder:FindFirstChild("Door")
if doorModel then
local doorPart = doorModel:FindFirstChild("Door")
if doorPart then
local roomID = doorModel:GetAttribute("RoomID") or doorPart:GetAttribute("RoomID") or tostring(roomNum)
local cached = DoorStringCache[roomID]
if not cached then
cached = "Door " .. tostring(roomID)
DoorStringCache[roomID] = cached
end
AddDoorESP(doorPart, cached, DoorColor, roomNum)
local boards = doorPart:FindFirstChild("CrossBoards")
if boards then AddDoorESP(boards, "", DoorColor, roomNum) end
end
end
for _, v in ipairs(roomFolder:GetDescendants()) do
if v.Name == "KeyObtain" then
AddDoorESP(v, "Key", DoorColor, roomNum)
elseif v.Name == "ElectrialKeyObtain" then
AddDoorESP(v, "Electrical Key", DoorColor, roomNum)
end
end
end
local function UpdateDoorESP()
if not (Toggles.Door and Toggles.Door.Value) then return end
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
CleanOldDoorRooms(currentRoomNum)
local rooms = workspace:FindFirstChild("CurrentRooms")
if not rooms then return end
ProcessRoomDoors(rooms:FindFirstChild(tostring(currentRoomNum)), currentRoomNum)
ProcessRoomDoors(rooms:FindFirstChild(tostring(currentRoomNum + 1)), currentRoomNum + 1)
end
local ObjectiveActiveESP = {}
local ObjectiveRoomCache = {}
local ObjectiveStringCache = {}
local function RemoveObjectiveESP(part)
if part and ObjectiveActiveESP[part] then
ObjectiveActiveESP[part] = nil
ESPLibrary:RemoveESP(part)
end
end
local function AddObjectiveESP(part, txt, color, roomNum)
if not part then return end
local data = ObjectiveActiveESP[part]
if data and data.text == txt then return end
if data then ESPLibrary:RemoveESP(part) end
ObjectiveActiveESP[part] = { text = txt, room = roomNum }
if roomNum then
local bucket = ObjectiveRoomCache[roomNum]
if not bucket then bucket = {} ObjectiveRoomCache[roomNum] = bucket end
table.insert(bucket, part)
end
AddESP(part, txt, color)
end
local function CleanOldObjectiveRooms(currentRoomNum)
currentRoomNum = tonumber(currentRoomNum) or 0
for roomNum, parts in pairs(ObjectiveRoomCache) do
if roomNum < currentRoomNum or roomNum > (currentRoomNum + 1) then
for i = 1, #parts do RemoveObjectiveESP(parts[i]) end
ObjectiveRoomCache[roomNum] = nil
end
end
end
local function ClearAllObjectiveESP()
for part in pairs(ObjectiveActiveESP) do
ESPLibrary:RemoveESP(part)
end
table.clear(ObjectiveActiveESP)
table.clear(ObjectiveRoomCache)
table.clear(ObjectiveStringCache)
end
local function ProcessRoomObjectives(roomFolder, roomNum)
if not roomFolder then return end
for _, v in ipairs(roomFolder:GetDescendants()) do
local itemName = Items[v.Name]
if itemName then
local cached = ObjectiveStringCache[itemName]
if not cached then
cached = itemName
ObjectiveStringCache[itemName] = cached
end
AddObjectiveESP(v, cached, ItemsColor, roomNum)
elseif v.Name == "MinesAnchor" then
local sign = v:FindFirstChild("Sign")
local label = sign and sign:FindFirstChild("TextLabel")
local text = label and label.Text or ""
local key = "Anchor " .. text
local cached = ObjectiveStringCache[key]
if not cached then
cached = key
ObjectiveStringCache[key] = cached
end
AddObjectiveESP(v, cached, ItemsColor, roomNum)
end
end
end
local function UpdateObjectiveESP()
if not (Toggles.Objective and Toggles.Objective.Value) then return end
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
CleanOldObjectiveRooms(currentRoomNum)
local rooms = workspace:FindFirstChild("CurrentRooms")
if not rooms then return end
ProcessRoomObjectives(rooms:FindFirstChild(tostring(currentRoomNum)), currentRoomNum)
ProcessRoomObjectives(rooms:FindFirstChild(tostring(currentRoomNum + 1)), currentRoomNum + 1)
end
local HidingPlaceActiveESP = {}
local HidingPlaceRoomCache = {}
local HidingPlaceStringCache = {}
local function RemoveHidingPlaceESP(part)
if part and HidingPlaceActiveESP[part] then
HidingPlaceActiveESP[part] = nil
ESPLibrary:RemoveESP(part)
end
end
local function AddHidingPlaceESP(part, txt, color, roomNum)
if not part then return end
local data = HidingPlaceActiveESP[part]
if data and data.text == txt then return end
if data then ESPLibrary:RemoveESP(part) end
HidingPlaceActiveESP[part] = { text = txt, room = roomNum }
if roomNum then
local bucket = HidingPlaceRoomCache[roomNum]
if not bucket then bucket = {} HidingPlaceRoomCache[roomNum] = bucket end
table.insert(bucket, part)
end
AddESP(part, txt, color)
end
local function CleanOldHidingPlaceRooms(currentRoomNum)
currentRoomNum = tonumber(currentRoomNum) or 0
for roomNum, parts in pairs(HidingPlaceRoomCache) do
if roomNum < currentRoomNum or roomNum > (currentRoomNum + 1) then
for i = 1, #parts do RemoveHidingPlaceESP(parts[i]) end
HidingPlaceRoomCache[roomNum] = nil
end
end
end
local function ClearAllHidingPlaceESP()
for part in pairs(HidingPlaceActiveESP) do
ESPLibrary:RemoveESP(part)
end
table.clear(HidingPlaceActiveESP)
table.clear(HidingPlaceRoomCache)
table.clear(HidingPlaceStringCache)
end
local function ProcessRoomHidingPlaces(roomFolder, roomNum)
if not roomFolder then return end
for _, v in ipairs(roomFolder:GetDescendants()) do
local name = HidingPlaces[v.Name]
if name then
local cached = HidingPlaceStringCache[name]
if not cached then
cached = name
HidingPlaceStringCache[name] = cached
end
AddHidingPlaceESP(v, cached, HidingPlaceColor, roomNum)
end
end
end
local function UpdateHidingPlaceESP()
if not (Toggles.HidingPlace and Toggles.HidingPlace.Value) then return end
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
CleanOldHidingPlaceRooms(currentRoomNum)
local rooms = workspace:FindFirstChild("CurrentRooms")
if not rooms then return end
ProcessRoomHidingPlaces(rooms:FindFirstChild(tostring(currentRoomNum)), currentRoomNum)
ProcessRoomHidingPlaces(rooms:FindFirstChild(tostring(currentRoomNum + 1)), currentRoomNum + 1)
end
local GateLeverActiveESP = {}
local GateLeverRoomCache = {}
local GateLeverStringCache = {}
local function RemoveGateLeverESP(part)
if part and GateLeverActiveESP[part] then
GateLeverActiveESP[part] = nil
ESPLibrary:RemoveESP(part)
end
end
local function AddGateLeverESP(part, txt, color, roomNum)
if not part then return end
local data = GateLeverActiveESP[part]
if data and data.text == txt then return end
if data then ESPLibrary:RemoveESP(part) end
GateLeverActiveESP[part] = { text = txt, room = roomNum }
if roomNum then
local bucket = GateLeverRoomCache[roomNum]
if not bucket then bucket = {} GateLeverRoomCache[roomNum] = bucket end
table.insert(bucket, part)
end
AddESP(part, txt, color)
end
local function CleanOldGateLeverRooms(currentRoomNum)
currentRoomNum = tonumber(currentRoomNum) or 0
for roomNum, parts in pairs(GateLeverRoomCache) do
if roomNum < currentRoomNum or roomNum > (currentRoomNum + 1) then
for i = 1, #parts do RemoveGateLeverESP(parts[i]) end
GateLeverRoomCache[roomNum] = nil
end
end
end
local function ClearAllGateLeverESP()
for part in pairs(GateLeverActiveESP) do
ESPLibrary:RemoveESP(part)
end
table.clear(GateLeverActiveESP)
table.clear(GateLeverRoomCache)
table.clear(GateLeverStringCache)
end
local function ProcessRoomGateLevers(roomFolder, roomNum)
if not roomFolder then return end
local cached = GateLeverStringCache["Lever"]
if not cached then
cached = "Gate Lever"
GateLeverStringCache["Lever"] = cached
end
for _, v in ipairs(roomFolder:GetDescendants()) do
if v.Name == "LeverForGate" then
AddGateLeverESP(v, cached, LeverColor, roomNum)
end
end
end
local function UpdateGateLeverESP()
if not (Toggles.GateLever and Toggles.GateLever.Value) then return end
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
CleanOldGateLeverRooms(currentRoomNum)
local rooms = workspace:FindFirstChild("CurrentRooms")
if not rooms then return end
ProcessRoomGateLevers(rooms:FindFirstChild(tostring(currentRoomNum)), currentRoomNum)
ProcessRoomGateLevers(rooms:FindFirstChild(tostring(currentRoomNum + 1)), currentRoomNum + 1)
end
local BookActiveESP = {}
local BookRoomCache = {}
local BookStringCache = {}
local function RemoveBookESP(part)
if part and BookActiveESP[part] then
BookActiveESP[part] = nil
ESPLibrary:RemoveESP(part)
end
end
local function AddBookESP(part, txt, color, roomNum)
if not part then return end
local data = BookActiveESP[part]
if data and data.text == txt then return end
if data then ESPLibrary:RemoveESP(part) end
BookActiveESP[part] = { text = txt, room = roomNum }
if roomNum then
local bucket = BookRoomCache[roomNum]
if not bucket then bucket = {} BookRoomCache[roomNum] = bucket end
table.insert(bucket, part)
end
AddESP(part, txt, color)
end
local function CleanOldBookRooms(currentRoomNum)
currentRoomNum = tonumber(currentRoomNum) or 0
for roomNum, parts in pairs(BookRoomCache) do
if roomNum < currentRoomNum or roomNum > (currentRoomNum + 1) then
for i = 1, #parts do RemoveBookESP(parts[i]) end
BookRoomCache[roomNum] = nil
end
end
end
local function ClearAllBookESP()
for part in pairs(BookActiveESP) do
ESPLibrary:RemoveESP(part)
end
table.clear(BookActiveESP)
table.clear(BookRoomCache)
table.clear(BookStringCache)
end
local function ProcessRoomBooks(roomFolder, roomNum)
if not roomFolder then return end
if (tonumber(roomNum) or 0) ~= 50 then return end
local cached = BookStringCache["Book"]
if not cached then
cached = "Library Book"
BookStringCache["Book"] = cached
end
for _, v in ipairs(roomFolder:GetDescendants()) do
if v.Name == "LiveHintBook" then
AddBookESP(v, cached, BookColor, roomNum)
end
end
end
local function UpdateBookESP()
if not (Toggles.Books and Toggles.Books.Value) then return end
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
CleanOldBookRooms(currentRoomNum)
local rooms = workspace:FindFirstChild("CurrentRooms")
if not rooms then return end
ProcessRoomBooks(rooms:FindFirstChild(tostring(currentRoomNum)), currentRoomNum)
ProcessRoomBooks(rooms:FindFirstChild(tostring(currentRoomNum + 1)), currentRoomNum + 1)
end
local BreakerActiveESP = {}
local BreakerRoomCache = {}
local BreakerStringCache = {}
local function RemoveBreakerESP(part)
if part and BreakerActiveESP[part] then
BreakerActiveESP[part] = nil
ESPLibrary:RemoveESP(part)
end
end
local function AddBreakerESP(part, txt, color, roomNum)
if not part then return end
local data = BreakerActiveESP[part]
if data and data.text == txt then return end
if data then ESPLibrary:RemoveESP(part) end
BreakerActiveESP[part] = { text = txt, room = roomNum }
if roomNum then
local bucket = BreakerRoomCache[roomNum]
if not bucket then bucket = {} BreakerRoomCache[roomNum] = bucket end
table.insert(bucket, part)
end
AddESP(part, txt, color)
end
local function CleanOldBreakerRooms(currentRoomNum)
currentRoomNum = tonumber(currentRoomNum) or 0
for roomNum, parts in pairs(BreakerRoomCache) do
if roomNum < currentRoomNum or roomNum > (currentRoomNum + 1) then
for i = 1, #parts do RemoveBreakerESP(parts[i]) end
BreakerRoomCache[roomNum] = nil
end
end
end
local function ClearAllBreakerESP()
for part in pairs(BreakerActiveESP) do
ESPLibrary:RemoveESP(part)
end
table.clear(BreakerActiveESP)
table.clear(BreakerRoomCache)
table.clear(BreakerStringCache)
end
local function ProcessRoomBreakers(roomFolder, roomNum)
if not roomFolder then return end
if (tonumber(roomNum) or 0) ~= 100 then return end
local cached = BreakerStringCache["Breaker"]
if not cached then
cached = "Breaker"
BreakerStringCache["Breaker"] = cached
end
for _, v in ipairs(roomFolder:GetDescendants()) do
if v.Name == "LiveBreakerPolePickup" then
AddBreakerESP(v, cached, BreakerColor, roomNum)
end
end
end
local function UpdateBreakerESP()
if not (Toggles.Breakers and Toggles.Breakers.Value) then return end
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
CleanOldBreakerRooms(currentRoomNum)
local rooms = workspace:FindFirstChild("CurrentRooms")
if not rooms then return end
ProcessRoomBreakers(rooms:FindFirstChild(tostring(currentRoomNum)), currentRoomNum)
ProcessRoomBreakers(rooms:FindFirstChild(tostring(currentRoomNum + 1)), currentRoomNum + 1)
end
local GoldActiveESP = {}
local GoldRoomCache = {}
local GoldStringCache = {}
local function RemoveGoldESP(part)
if part and GoldActiveESP[part] then
GoldActiveESP[part] = nil
ESPLibrary:RemoveESP(part)
end
end
local function AddGoldESP(part, txt, color, roomNum)
if not part then return end
local data = GoldActiveESP[part]
if data and data.text == txt then return end
if data then ESPLibrary:RemoveESP(part) end
GoldActiveESP[part] = { text = txt, room = roomNum }
if roomNum then
local bucket = GoldRoomCache[roomNum]
if not bucket then bucket = {} GoldRoomCache[roomNum] = bucket end
table.insert(bucket, part)
end
AddESP(part, txt, color)
end
local function CleanOldGoldRooms(currentRoomNum)
currentRoomNum = tonumber(currentRoomNum) or 0
for roomNum, parts in pairs(GoldRoomCache) do
if roomNum < currentRoomNum or roomNum > (currentRoomNum + 1) then
for i = 1, #parts do RemoveGoldESP(parts[i]) end
GoldRoomCache[roomNum] = nil
end
end
end
local function ClearAllGoldESP()
for part in pairs(GoldActiveESP) do
ESPLibrary:RemoveESP(part)
end
table.clear(GoldActiveESP)
table.clear(GoldRoomCache)
table.clear(GoldStringCache)
end
local function ProcessRoomGold(roomFolder, roomNum)
if not roomFolder then return end
for _, v in ipairs(roomFolder:GetDescendants()) do
if v.Name == "GoldPile" then
local value = tonumber(v:GetAttribute("GoldValue")) or 0
local cached = GoldStringCache[value]
if not cached then
cached = "Gold " .. tostring(value)
GoldStringCache[value] = cached
end
AddGoldESP(v, cached, GoldColor, roomNum)
end
end
end
local function UpdateGoldESP()
if not (Toggles.Gold and Toggles.Gold.Value) then return end
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
CleanOldGoldRooms(currentRoomNum)
local rooms = workspace:FindFirstChild("CurrentRooms")
if not rooms then return end
ProcessRoomGold(rooms:FindFirstChild(tostring(currentRoomNum)), currentRoomNum)
ProcessRoomGold(rooms:FindFirstChild(tostring(currentRoomNum + 1)), currentRoomNum + 1)
end
local LadderActiveESP = {}
local LadderRoomCache = {}
local LadderStringCache = {}
local function RemoveLadderESP(part)
if part and LadderActiveESP[part] then
LadderActiveESP[part] = nil
ESPLibrary:RemoveESP(part)
end
end
local function AddLadderESP(part, txt, color, roomNum)
if not part then return end
local data = LadderActiveESP[part]
if data and data.text == txt then return end
if data then ESPLibrary:RemoveESP(part) end
LadderActiveESP[part] = { text = txt, room = roomNum }
if roomNum then
local bucket = LadderRoomCache[roomNum]
if not bucket then bucket = {} LadderRoomCache[roomNum] = bucket end
table.insert(bucket, part)
end
AddESP(part, txt, color)
end
local function CleanOldLadderRooms(currentRoomNum)
currentRoomNum = tonumber(currentRoomNum) or 0
for roomNum, parts in pairs(LadderRoomCache) do
if roomNum < currentRoomNum or roomNum > (currentRoomNum + 1) then
for i = 1, #parts do RemoveLadderESP(parts[i]) end
LadderRoomCache[roomNum] = nil
end
end
end
local function ClearAllLadderESP()
for part in pairs(LadderActiveESP) do
ESPLibrary:RemoveESP(part)
end
table.clear(LadderActiveESP)
table.clear(LadderRoomCache)
table.clear(LadderStringCache)
end
local function ProcessRoomLadders(roomFolder, roomNum)
if not roomFolder then return end
local cached = LadderStringCache["Ladder"]
if not cached then
cached = "Ladder"
LadderStringCache["Ladder"] = cached
end
for _, v in ipairs(roomFolder:GetDescendants()) do
if v.Name == "Ladder" then
AddLadderESP(v, cached, LadderColor, roomNum)
end
end
end
local function UpdateLadderESP()
if not (Toggles.Ladder and Toggles.Ladder.Value) then return end
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
CleanOldLadderRooms(currentRoomNum)
local rooms = workspace:FindFirstChild("CurrentRooms")
if not rooms then return end
ProcessRoomLadders(rooms:FindFirstChild(tostring(currentRoomNum)), currentRoomNum)
ProcessRoomLadders(rooms:FindFirstChild(tostring(currentRoomNum + 1)), currentRoomNum + 1)
end
local FuseActiveESP = {}
local FuseRoomCache = {}
local FuseStringCache = {}
local function RemoveFuseESP(part)
if part and FuseActiveESP[part] then
FuseActiveESP[part] = nil
ESPLibrary:RemoveESP(part)
end
end
local function AddFuseESP(part, txt, color, roomNum)
if not part then return end
local data = FuseActiveESP[part]
if data and data.text == txt then return end
if data then ESPLibrary:RemoveESP(part) end
FuseActiveESP[part] = { text = txt, room = roomNum }
if roomNum then
local bucket = FuseRoomCache[roomNum]
if not bucket then bucket = {} FuseRoomCache[roomNum] = bucket end
table.insert(bucket, part)
end
AddESP(part, txt, color)
end
local function CleanOldFuseRooms(currentRoomNum)
currentRoomNum = tonumber(currentRoomNum) or 0
for roomNum, parts in pairs(FuseRoomCache) do
if roomNum < currentRoomNum or roomNum > (currentRoomNum + 1) then
for i = 1, #parts do RemoveFuseESP(parts[i]) end
FuseRoomCache[roomNum] = nil
end
end
end
local function ClearAllFuseESP()
for part in pairs(FuseActiveESP) do
ESPLibrary:RemoveESP(part)
end
table.clear(FuseActiveESP)
table.clear(FuseRoomCache)
table.clear(FuseStringCache)
end
local function ProcessRoomFuses(roomFolder, roomNum)
if not roomFolder then return end
for _, v in ipairs(roomFolder:GetDescendants()) do
local n = v.Name
if n == "FuseObtain" then
AddFuseESP(v, "Fuse", FuseColor, roomNum)
elseif n == "MinesGenerator" then
AddFuseESP(v, "Generator", FuseColor, roomNum)
elseif n == "MinesGateButton" then
AddFuseESP(v, "Gate Button", FuseColor, roomNum)
end
end
end
local function UpdateFuseESP()
if not (Toggles.Fuse and Toggles.Fuse.Value) then return end
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
CleanOldFuseRooms(currentRoomNum)
local rooms = workspace:FindFirstChild("CurrentRooms")
if not rooms then return end
ProcessRoomFuses(rooms:FindFirstChild(tostring(currentRoomNum)), currentRoomNum)
ProcessRoomFuses(rooms:FindFirstChild(tostring(currentRoomNum + 1)), currentRoomNum + 1)
end
local EntityNear = {
["Snare"] = "Snare",
["MandrakeLive"] = "Man Drake",
["Mandrake"] = "Man Drake",
["JeffTheKiller"] = "Jeff",
["Eyes"] = "Eyes",
["Lookman"] = "Eyes",
["BackdoorLookman"] = "Lookman",
}
local EntityCurrent = {
["FigureRig"] = "Figure",
["FigureRagdoll"] = "Figure",
["Groundskeeper"] = "Ground Keeper",
["LiveEntityBramble"] = "Bramble",
}
local EntityGlobal = {
["RushMoving"] = "Rush",
["AmbushMoving"] = "Ambush",
["A60"] = "A-60",
["A120"] = "A-120",
["GlitchRush"] = "Glitch Rush",
["GlitchAmbush"] = "Glitch Ambush",
["BackdoorRush"] = "Blitz",
}
local EntityRoom150 = {
["GrumbleRig"] = "Grumble",
}
local EntityAll = {}
for k, v in pairs(EntityNear) do EntityAll[k] = v end
for k, v in pairs(EntityCurrent) do EntityAll[k] = v end
for k, v in pairs(EntityGlobal) do EntityAll[k] = v end
for k, v in pairs(EntityRoom150) do EntityAll[k] = v end
EntityAll["DoorFake"] = "Dupe"
EntityAll["GiggleCeiling"] = "Giggle"
local EntityActiveESP = {}
local EntityRoomCache = {}
local EntityStringCache = {}
local function PrepareEntity(part)
if not part then return false end
if part:IsA("Model") then
if not part.PrimaryPart then
local base = part:FindFirstChildWhichIsA("BasePart")
if not base then return false end
part.PrimaryPart = base
end
pcall(function() part.PrimaryPart.Transparency = 0.99 end)
if not part:FindFirstChildOfClass("Humanoid") then
Instance.new("Humanoid", part)
end
end
if part.Name == "FigureRig" or part.Name == "FigureRagdoll" then
local root = part:FindFirstChild("Root")
if root then root.Size = Vector3.new(0.001, 0.001, 0.001) end
end
return true
end
local function RemoveEntityESP(part)
if part and EntityActiveESP[part] then
EntityActiveESP[part] = nil
ESPLibrary:RemoveESP(part)
end
end
local function AddEntityESP(part, txt, color, roomNum)
if not part then return end
local data = EntityActiveESP[part]
if data and data.text == txt then return end
if data then ESPLibrary:RemoveESP(part) end
if not PrepareEntity(part) then return end
local cached = EntityStringCache[txt]
if not cached then
cached = txt
EntityStringCache[txt] = cached
end
EntityActiveESP[part] = { text = cached, room = roomNum }
if roomNum then
local bucket = EntityRoomCache[roomNum]
if not bucket then bucket = {} EntityRoomCache[roomNum] = bucket end
table.insert(bucket, part)
end
AddESP(part, cached, color)
end
local function CleanOldEntityRooms(currentRoomNum)
currentRoomNum = tonumber(currentRoomNum) or 0
for roomNum, parts in pairs(EntityRoomCache) do
if roomNum < currentRoomNum or roomNum > (currentRoomNum + 1) then
for i = 1, #parts do RemoveEntityESP(parts[i]) end
EntityRoomCache[roomNum] = nil
end
end
end
local function ClearAllEntityESP()
for part in pairs(EntityActiveESP) do
ESPLibrary:RemoveESP(part)
end
table.clear(EntityActiveESP)
table.clear(EntityRoomCache)
table.clear(EntityStringCache)
end
local function ProcessRoomEntities(roomFolder, roomNum)
if not roomFolder then return end
roomNum = tonumber(roomNum) or 0
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
local isCurrent = (roomNum == currentRoomNum)
for _, v in ipairs(roomFolder:GetDescendants()) do
local n = v.Name
local label = EntityNear[n]
if label then
if n ~= "Snare" or v:FindFirstChild("Hitbox") then
AddEntityESP(v, label, EntityColor, roomNum)
end
elseif n == "DoorFake" then
if v.Parent and v.Parent.Name == "SideroomDupe" then
local fake = v:FindFirstChild("Door")
if fake then AddEntityESP(fake, "Dupe", EntityColor, roomNum) end
end
elseif n == "GiggleCeiling" then
if v:FindFirstChild("Hitbox") then
AddEntityESP(v, "Giggle", EntityColor, roomNum)
end
elseif isCurrent then
label = EntityCurrent[n]
if label then
AddEntityESP(v, label, EntityColor, roomNum)
elseif EntityRoom150[n] and currentRoomNum == 150 then
AddEntityESP(v, EntityRoom150[n], EntityColor, roomNum)
end
end
end
end
local function UpdateEntityESP()
if not (Toggles.Entity and Toggles.Entity.Value) then return end
local currentRoomNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
for part in pairs(EntityActiveESP) do
if not part.Parent then RemoveEntityESP(part) end
end
CleanOldEntityRooms(currentRoomNum)
local rooms = workspace:FindFirstChild("CurrentRooms")
if rooms then
ProcessRoomEntities(rooms:FindFirstChild(tostring(currentRoomNum)), currentRoomNum)
ProcessRoomEntities(rooms:FindFirstChild(tostring(currentRoomNum + 1)), currentRoomNum + 1)
end
for _, v in ipairs(workspace:GetChildren()) do
local n = v.Name
local label = EntityGlobal[n]
if label then
AddEntityESP(v, label, EntityColor, nil)
else
label = EntityNear[n]
if label then
AddEntityESP(v, label, EntityColor, currentRoomNum)
end
end
end
end
local NotifiedEntities = {}
local NotifyNames = {
["RushMoving"] = "Rush",
["AmbushMoving"] = "Ambush",
["A60"] = "A-60",
["A120"] = "A-120",
["GlitchRush"] = "Glitch Rush",
["GlitchAmbush"] = "Glitch Ambush",
["Eyes"] = "Eyes",
["Lookman"] = "Eyes",
["BackdoorRush"] = "Blitz",
["BackdoorLookman"] = "Lookman",
["JeffTheKiller"] = "Jeff",
}
local NotifyOptionKey = {
["RushMoving"] = "Rush",
["AmbushMoving"] = "Ambush",
["A60"] = "A-60",
["A120"] = "A-120",
["GlitchRush"] = "GlitchRush",
["GlitchAmbush"] = "GlitchAmbush",
["Eyes"] = "Eyes",
["Lookman"] = "Eyes",
["BackdoorRush"] = "Blitz",
["BackdoorLookman"] = "Lookman",
["JeffTheKiller"] = "Jeff",
}
local function CheckAndNotifyEntity(entity)
if not entity then return end
if NotifiedEntities[entity] then return end
if not (Toggles.NotifySpawn and Toggles.NotifySpawn.Value) then return end
local key = NotifyOptionKey[entity.Name]
if not key then return end
local selected = Options.Notify and Options.Notify.Value
if type(selected) ~= "table" or not selected[key] then return end
NotifiedEntities[entity] = true
local con
con = entity.AncestryChanged:Connect(function(_, parent)
if not parent then
NotifiedEntities[entity] = nil
if con then con:Disconnect() con = nil end
end
end)
table.insert(Connections, con)
Notify(NotifyNames[entity.Name] .. " has Spawned", 5)
end
local function ScanNotifyEntities()
if not (Toggles.NotifySpawn and Toggles.NotifySpawn.Value) then return end
for _, v in ipairs(workspace:GetChildren()) do
if NotifyOptionKey[v.Name] then
CheckAndNotifyEntity(v)
end
end
end
local function UpdateAllESP()
UpdateDoorESP()
UpdateObjectiveESP()
UpdateHidingPlaceESP()
UpdateGateLeverESP()
UpdateBookESP()
UpdateBreakerESP()
UpdateGoldESP()
UpdateLadderESP()
UpdateFuseESP()
UpdateEntityESP()
end
local function ClearAllESP()
ClearAllDoorESP()
ClearAllObjectiveESP()
ClearAllHidingPlaceESP()
ClearAllGateLeverESP()
ClearAllBookESP()
ClearAllBreakerESP()
ClearAllGoldESP()
ClearAllLadderESP()
ClearAllFuseESP()
ClearAllEntityESP()
table.clear(NotifiedEntities)
end
ESPHooks.UpdateAll = UpdateAllESP
ESPHooks.ClearAll = ClearAllESP
ESPHooks.ScanNotify = ScanNotifyEntities
ESPHooks.CheckNotify = CheckAndNotifyEntity
ESPBox:AddToggle('Door', {
Text = "Door",
Default = false,
Callback = function(Value)
if Value then task.defer(UpdateDoorESP) else ClearAllDoorESP() end
end
}):AddColorPicker("ColorPicker2", {
Default = DoorColor,
Title = "Door ESP Color",
Callback = function(Value)
DoorColor = Value
if Toggles.Door and Toggles.Door.Value then
ClearAllDoorESP()
task.defer(UpdateDoorESP)
end
end,
})
ESPBox:AddToggle('Objective', {
Text = "Objective",
Default = false,
Callback = function(Value)
if Value then task.defer(UpdateObjectiveESP) else ClearAllObjectiveESP() end
end
}):AddColorPicker("ColorPicker3", {
Default = ItemsColor,
Title = "Objective ESP Color",
Callback = function(Value)
ItemsColor = Value
if Toggles.Objective and Toggles.Objective.Value then
ClearAllObjectiveESP()
task.defer(UpdateObjectiveESP)
end
end,
})
ESPBox:AddToggle('HidingPlace', {
Text = "Hiding Place",
Default = false,
Callback = function(Value)
if Value then task.defer(UpdateHidingPlaceESP) else ClearAllHidingPlaceESP() end
end
}):AddColorPicker("ColorPicker3", {
Default = HidingPlaceColor,
Title = "Hiding Place ESP Color",
Callback = function(Value)
HidingPlaceColor = Value
if Toggles.HidingPlace and Toggles.HidingPlace.Value then
ClearAllHidingPlaceESP()
task.defer(UpdateHidingPlaceESP)
end
end,
})
ESPBox:AddToggle('GateLever', {
Text = "Gate Lever",
Default = false,
Callback = function(Value)
if Value then task.defer(UpdateGateLeverESP) else ClearAllGateLeverESP() end
end
}):AddColorPicker("ColorPicker3", {
Default = LeverColor,
Title = "Gate Lever ESP Color",
Callback = function(Value)
LeverColor = Value
if Toggles.GateLever and Toggles.GateLever.Value then
ClearAllGateLeverESP()
task.defer(UpdateGateLeverESP)
end
end,
})
ESPBox:AddToggle('Books', {
Text = "Library Book",
Default = false,
Callback = function(Value)
if Value then task.defer(UpdateBookESP) else ClearAllBookESP() end
end
}):AddColorPicker("ColorPicker3", {
Default = BookColor,
Title = "Library ESP Color",
Callback = function(Value)
BookColor = Value
if Toggles.Books and Toggles.Books.Value then
ClearAllBookESP()
task.defer(UpdateBookESP)
end
end,
})
ESPBox:AddToggle('Breakers', {
Text = "Breaker",
Default = false,
Callback = function(Value)
if Value then task.defer(UpdateBreakerESP) else ClearAllBreakerESP() end
end
}):AddColorPicker("ColorPicker3", {
Default = BreakerColor,
Title = "Breaker ESP Color",
Callback = function(Value)
BreakerColor = Value
if Toggles.Breakers and Toggles.Breakers.Value then
ClearAllBreakerESP()
task.defer(UpdateBreakerESP)
end
end,
})
ESPBox:AddToggle('Gold', {
Text = "Gold",
Default = false,
Callback = function(Value)
if Value then task.defer(UpdateGoldESP) else ClearAllGoldESP() end
end
}):AddColorPicker("ColorPicker3", {
Default = GoldColor,
Title = "Gold ESP Color",
Callback = function(Value)
GoldColor = Value
if Toggles.Gold and Toggles.Gold.Value then
ClearAllGoldESP()
task.defer(UpdateGoldESP)
end
end,
})
ESPBox:AddToggle('Entity', {
Text = "Entity",
Default = false,
Callback = function(Value)
if Value then task.defer(UpdateEntityESP) else ClearAllEntityESP() end
end
}):AddColorPicker("ColorPicker3", {
Default = EntityColor,
Title = "Entity ESP Color",
Callback = function(Value)
EntityColor = Value
if Toggles.Entity and Toggles.Entity.Value then
ClearAllEntityESP()
task.defer(UpdateEntityESP)
end
end,
})
ESPBox:AddToggle('Ladder', {
Text = "Ladder",
Default = false,
Callback = function(Value)
if Value then task.defer(UpdateLadderESP) else ClearAllLadderESP() end
end
}):AddColorPicker("ColorPickerLadder", {
Default = LadderColor,
Title = "Ladder ESP Color",
Callback = function(Value)
LadderColor = Value
if Toggles.Ladder and Toggles.Ladder.Value then
ClearAllLadderESP()
task.defer(UpdateLadderESP)
end
end,
})
ESPBox:AddToggle('Fuse', {
Text = "Fuse",
Default = false,
Callback = function(Value)
if Value then task.defer(UpdateFuseESP) else ClearAllFuseESP() end
end
}):AddColorPicker("ColorPickerFuse", {
Default = FuseColor,
Title = "Fuse ESP Color",
Callback = function(Value)
FuseColor = Value
if Toggles.Fuse and Toggles.Fuse.Value then
ClearAllFuseESP()
task.defer(UpdateFuseESP)
end
end,
})
local ESPWatch = {
["Door"] = UpdateDoorESP,
["KeyObtain"] = UpdateDoorESP,
["ElectrialKeyObtain"] = UpdateDoorESP,
["MinesAnchor"] = UpdateObjectiveESP,
["LeverForGate"] = UpdateGateLeverESP,
["LiveHintBook"] = UpdateBookESP,
["LiveBreakerPolePickup"] = UpdateBreakerESP,
["GoldPile"] = UpdateGoldESP,
["Ladder"] = UpdateLadderESP,
["FuseObtain"] = UpdateFuseESP,
["MinesGenerator"] = UpdateFuseESP,
["MinesGateButton"] = UpdateFuseESP,
}
table.insert(Connections, LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
task.defer(UpdateAllESP)
task.defer(ScanNotifyEntities)
end))
table.insert(Connections, workspace.DescendantAdded:Connect(function(v)
local n = v.Name
local fn = ESPWatch[n]
if fn then task.defer(fn) end
if Items[n] then task.defer(UpdateObjectiveESP) end
if HidingPlaces[n] then task.defer(UpdateHidingPlaceESP) end
if EntityAll[n] then
task.defer(UpdateEntityESP)
if NotifyOptionKey[n] then CheckAndNotifyEntity(v) end
end
end))
table.insert(Connections, workspace.ChildAdded:Connect(function(v)
local n = v.Name
if EntityAll[n] then
task.defer(UpdateEntityESP)
if NotifyOptionKey[n] then CheckAndNotifyEntity(v) end
end
end))
table.insert(Connections, workspace.ChildRemoved:Connect(function(v)
if EntityAll[v.Name] then
RemoveEntityESP(v)
end
end))
end)
CameraBox:AddSlider("FOV", {
Text = "FOV",
Default = 70,
Min = 70,
Max = 120,
Rounding = 1,
Compact = false,
Callback = function(Value)
end,
Tooltip = "Field of View",
})
CameraBox:AddDivider()
CameraBox:AddToggle('ThirdPerson',{
Text = "Third Person",
Default = false
}):AddKeyPicker("ThirdpersonKeybind", {
Default = "T", 	SyncToggleState = true,
Mode = "Toggle", 
Text = "Third Person", 	NoUI = false, 
Callback = function(Value)
end,
ChangedCallback = function(NewKey, NewModifiers)
end,
})
CameraBox:AddSlider("X", {
Text = "X",
Default = 2,
Min = -10,
Max = 10,
Rounding = 1,
Compact = false,
Callback = function(Value)
end,
Tooltip = "X",
})
CameraBox:AddSlider("Y", {
Text = "Y",
Default = 0,
Min = -10,
Max = 10,
Rounding = 1,
Compact = false,
Callback = function(Value)
end,
Tooltip = "Y",
})
CameraBox:AddSlider("Z", {
Text = "Z",
Default = 4,
Min = -10,
Max = 10,
Rounding = 1,
Compact = false,
Callback = function(Value)
end,
Tooltip = "Z",
})
CameraBox:AddToggle('NoCamShake',{
Text = "No Camera Shake",
Disabled = not require and true or false,
})
local OldMinZoom = LocalPlayer.CameraMinZoomDistance
local OldMaxZoom  = LocalPlayer.CameraMaxZoomDistance
CameraBox:AddToggle('Freecam',{
Text = "Freecam",
Default = false,
Callback = function(Value)
if not Value then
local fcPart = workspace:FindFirstChild("FreecamPart")
if fcPart then
fcPart:Destroy()
local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if root then root.Anchored = false end
LocalPlayer.CameraMinZoomDistance = LocalPlayer:GetAttribute("fc_om") or 0.5
LocalPlayer.CameraMaxZoomDistance = LocalPlayer:GetAttribute("fc_ox") or 128
end
end
end
}):AddKeyPicker("FreecamKeybind", {
Default = "B", 	SyncToggleState = true,
Mode ="Toggle" , 
Text = "Freecam", 	NoUI = false, 
Callback = function(Value)
end,
ChangedCallback = function(NewKey, NewModifiers)
end,
})
CameraBox:AddToggle('NoScenes',{
Text = "No Cutscenes",
Default = false,
Callback = function(Value)
local Cutscene = RemoteListener:FindFirstChild("Cutscenes") or RemoteListener:FindFirstChild("Cutscenes_")
if Value then
Cutscene.Name = "Cutscenes_"
else
Cutscene.Name = "Cutscenes"
end
end
})
NotifyBox:AddDropdown("Notify", {
Values = { "Rush","Ambush","GlitchRush","GlitchAmbush","A-60","A-120","Eyes","Blitz","Lookman","Jeff"},
Default = 1, 	Multi = true, 
Text = "Choose to Notify",
Callback = function(Value)
end,
})
NotifyBox:AddToggle('NotifySpawn',{
Text = "Notify Entity",
Default = false,
Tooltip = "Notify Entity In Spawn",
Callback = function(Value)
if Value and ESPHooks and ESPHooks.ScanNotify then
task.defer(ESPHooks.ScanNotify)
end
end
})
local FakeScreech = Instance.new("RemoteEvent",RemotesFolder)
FakeScreech.Name = "Screech_"
local FakeA90 = Instance.new("RemoteEvent",RemotesFolder)
FakeA90.Name = "A90_"
local gotToggled = false
local gotToggled2 = false
BypassEntityBox:AddToggle('Screech',{
Text = "Anti Screech Damage",
Default = false,
Callback = function(Value)
if Value then
gotToggled = true
RemotesFolder.Screech.Name = "Screech_"
FakeScreech.Name = "Screech"
else
if gotToggled then
RemotesFolder["Screech_"].Name = "Screech"
FakeScreech.Name = "Screech_"
end
end
end
})
BypassEntityBox:AddToggle('A90',{
Text = "Anti A90 Damage",
Default = false,
Callback = function(Value)
if Value then
gotToggled2 = true
RemotesFolder.A90.Name = "A90_"
FakeA90.Name = "A90"
else
if gotToggled2 then
RemotesFolder["A90_"].Name = "A90"
FakeA90.Name = "A90_"
end
end
end
})
BypassEntityBox:AddToggle('Dread',{
Text = "Anti Dread",
Default = false,
Callback = function(Value)
if Value then
local Dread = LocalPlayer:FindFirstChild("Dread",true) or LocalPlayer:FindFirstChild("_Dread",true)
if Dread then
Dread.Name = "_Dread"
end
else
local Dread = LocalPlayer:FindFirstChild("Dread",true) or LocalPlayer:FindFirstChild("_Dread",true)
if Dread then
Dread.Name = "Dread"
end
end
end
})
BypassEntityBox:AddToggle('Halt',{
Text = "Anti Halt",
Default = false,
Callback = function(Value)
if Value then
local Dread = ClientModules.EntityModules:FindFirstChild("Shade",true) or ClientModules.EntityModules:FindFirstChild("_Shade",true)
if Dread then
Dread.Name = "_Shade"
end
else
local Dread = ClientModules.EntityModules:FindFirstChild("Shade",true) or ClientModules.EntityModules:FindFirstChild("_Shade",true)
if Dread then
Dread.Name = "Shade"
end
end
end
})
BypassEntityBox:AddToggle('Jamming',{
Text = "Anti Jammimg",
Default = false,
Callback = function(Value)
if  ReplicatedStorage:FindFirstChild("LiveModifiers") and ReplicatedStorage:FindFirstChild("LiveModifiers"):FindFirstChild("Jammin") then
local Jam = LocalPlayer.PlayerGui.MainUI.Initiator:FindFirstChild("Main_Game").Health.Jam
Jam.Playing = not Value
local Jamming = game:GetService("SoundService").Main.Jamming
Jamming.Enabled =  not Value
end
end
})
local Surge = Instance.new("RemoteEvent",ReplicatedStorage)
Surge.Name = "SurgeRemote"
BypassEntityBox:AddToggle('BypassSurgeDamage',{
Text = "Anti Surge Damage",
Default = false,
Callback = function(Value)
if Value then
if RemotesFolder:FindFirstChild("SurgeRemote") then
RemotesFolder.SurgeRemote.Parent = ReplicatedStorage
Surge.Parent = RemotesFolder
end
else
if RemotesFolder:FindFirstChild("SurgeRemote") then
ReplicatedStorage.SurgeRemote.Parent = RemotesFolder
Surge.Parent = ReplicatedStorage
end
end
end
})
BypassEntityBox:AddToggle('Snare',{
Text = "Anti Snare",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if   v.Name == "Snare" then
local wait = 0
repeat task.wait(0.01) wait = wait  + 0.01 until wait > 2 or v:FindFirstChild("Hitbox")
if v:FindFirstChild("Hitbox") then
v.Hitbox.CanTouch = not Value
end
end
end
end
})
BypassEntityBox:AddToggle('Giggle',{
Text = "Anti Giggle",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if   v.Name == "GiggleCeiling" then
local wait = 0
repeat task.wait(0.01) wait = wait  + 0.01 until wait > 2 or v:FindFirstChild("Hitbox")
if v:FindFirstChild("Hitbox") then
v.Hitbox.CanTouch = not Value
end
end
end
end
})
BypassEntityBox:AddToggle('Dupe',{
Text = "Anti Dupe",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "DoorFake"  and v.Parent.Name == "SideroomDupe" then
v:WaitForChild("Hidden",9e9).CanTouch = not Value
end
end
end
})
BypassBox:AddToggle('BypassSpeed',{
Text = "Speed Bypass",
Default = false,
Callback  = function(Value)
Options.MovementSpeed:SetMax(Value and 75 or 21)
Options.FlightSpeed:SetMax(Value and 75 or 21)
end
})
BypassBox:AddDivider()
BypassBox:AddDropdown("AntiCheatManiMethod", {
Values = { "Velocity", "Anticheat" },
Default = 1,
Text = "Manipulation Method",
Callback = function(Value)
end,
})
BypassBox:AddToggle('AntiCheatMani',{
Text = "Manipulation",
Default = false,
Callback = function(Value)
if not Value then
if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("VelocityMani") then
LocalPlayer.Character.HumanoidRootPart:FindFirstChild("VelocityMani"):Destroy()
end
if  Toggles.NoClip.Value then
Toggles.NoClip:SetValue(false)
end
end
end
}):AddKeyPicker("AntiCheatMan", {
Default = "V", 	SyncToggleState = true,
Mode = Library.IsMobile and "Toggle" or "Hold",  
Text = " Manipulation", 	NoUI = false, 
Callback = function(Value)
print("[cb] Keybind clicked!", Value)
end,
ChangedCallback = function(NewKey, NewModifiers)
end,
})
task.spawn(function()
while task.wait() do
if Library.Unloaded then break end
if Toggles.BypassSpeed.Value then
if CollisionClone then
CollisionClone.Massless = true
end
RemotesFolder.Crouch:FireServer(true, true)
end
end
end)
table.insert(Connections,workspace.ChildAdded:Connect(function(v)
if Toggles.AntiBanana.Value then
if v.Name == "BananaPeel" then
v.CanTouch = false
end
end
if Toggles.AntiJeff.Value then
if v.Name == "JeffTheKiller" then
repeat task.wait() until v.PrimaryPart and isnetworkowner(v.PrimaryPart)
for _, i in pairs(v:GetChildren()) do
if i:IsA("BasePart") then
i.CanTouch = false
end
end
v.Humanoid.Health = 0
end
end
end))
BypassEntityBox:AddToggle('EyesDamage',{
Text = "Anti Eyes Damage",
Default = false
})
BypassEntityBox:AddToggle('LookmanDamage',{
Text = "Anti Lookman Damage",
Default = false
})
BypassEntityBox:AddToggle('GloomEggDamage',{
Text = "Anti Gloom Egg",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "GloomEgg" then
for _, i in pairs(v:GetChildren()) do
if i:IsA("BasePart")  then
i.CanTouch = not Value
end
end
end
end
end
})
HotelFloor:AddToggle('NotifyLibraryCode',{
Text = "Notify Library Code",
Default = false,
})
HotelFloor:AddToggle('SeekObf',{
Text = "Anti Seek Obstacles",
Default = false,
Callback = function(Value)
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if v.Name == "Seek_Arm" or v.Name == "ChandelierObstruction" then
for _, i in pairs(v:GetChildren()) do
if i:IsA("BasePart") then
i.CanTouch = not Value
end
end
end
end
end
})
BypassEntityBox:AddToggle('FigureHearing',{
Text = "Anti Figure Hearing",
Default = false,
Callback = function(Value)
if not Value then
RemotesFolder.Crouch:FireServer(false)
else
RemotesFolder.Crouch:FireServer(true)
end
end
})
BypassEntityBox:AddToggle('AntiLag',{
Text = "Anti Lag ",
Default = false,
Callback = function(Value)
if Value then
for _, v in workspace.CurrentRooms:GetDescendants() do
if v:IsA("BasePart") then
v:SetAttribute("Mat", v.Material)
v.Material = "Plastic"
end
end
else
for _, v in workspace.CurrentRooms:GetDescendants() do
if v:IsA("BasePart") then
if v:GetAttribute("Mat") then
v.Material = v:GetAttribute("Mat") or "Plastic"
end
end
end
end
end
})
ReachBox:AddToggle('PromptReach',{
Text = "Prompt Reach",
Default = false,
Callback = function(Value)
if Value then
for _, v in pairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then
v:SetAttribute("Range", v.MaxActivationDistance)
v.MaxActivationDistance = v.MaxActivationDistance * 2
end
end
else
for _, v in pairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then
v.MaxActivationDistance = v:GetAttribute("Range") or v.MaxActivationDistance
end
end
end
end
})
ReachBox:AddToggle('PromptClip',{
Text = "Prompt Clip",
Default = false,
Callback = function(Value)
if Value then
for _, v in pairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then
v:SetAttribute("Clip", v.RequiresLineOfSight)
v.RequiresLineOfSight = false
end
end
else
for _, v in pairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then
v.RequiresLineOfSight = v:GetAttribute("Clip") or true
end
end
end
end
})
ReachBox:AddToggle('DoorReach',{
Text = "Door Reach",
Default = false
})
PlayerColor = Color3.fromRGB(150, 150, 150)
ESPBox:AddToggle('Player', {
Text = "Player",
Default = false,
Callback = function(Value)
for _, v in pairs(Players:GetPlayers()) do
if v ~= LocalPlayer and v.Character then
ESPLibrary:RemoveESP(v.Character)
if Value then
local hum = v.Character:FindFirstChildOfClass("Humanoid")
if hum and hum.Health > 0 then
AddESP(v.Character, v.Name .. " [" .. math.floor((hum.Health / hum.MaxHealth) * 100) .. "%]", PlayerColor)
end
end
end
end
end
}):AddColorPicker("ColorPicker99", {
Default = PlayerColor,
Title = "Player ESP Color",
Callback = function(Value)
PlayerColor = Value
Toggles.Player:SetValue(false)
Toggles.Player:SetValue(true)
end,
})
BypassBox:AddDivider()
BypassBox:AddLabel("Infinite Crucfix Only Works on A-60, A-120, Rush, Ambush. Have a chance to fail",true)
BypassBox:AddToggle('InfCrucifix',{
Text = "Infinite Crucifix ",
Risky = true,
})
BypassBox:AddDivider()
local Stored = {}
local Names = {
Lock = true,
ChestBoxLocked = true,
Cellar = true,
Chest_Vine = true,
CuttableVines = true,
SkullLock = true,
Toolbox_Locked = true,
Lock1 = true,
Lock2 = true,
}
local function IsInfItemTarget(prompt)
if not prompt or not prompt:IsA("ProximityPrompt") then return false end
if prompt.Name == "FusesPrompt" then return true end
local parent = prompt.Parent
if not parent then return false end
local parentName = parent.Name
local grandParentName = parent.Parent and parent.Parent.Name
if Names[parentName] or (grandParentName and Names[grandParentName]) then return true end
if grandParentName == "Locker_Small_Locked" then return true end
return false
end
local function RestorePrompt(Prompt)
if not Prompt then return end
if Prompt.Parent then
local ExistingPrompt = Prompt.Parent:FindFirstChild("InfPrompt")
if ExistingPrompt then
ExistingPrompt:Destroy()
end
end
Prompt:SetAttribute("InfItems", nil)
Prompt:SetAttribute("Tool", nil)
Prompt:SetAttribute("InfTime", nil)
Prompt.Enabled = true
Prompt.ClickablePrompt = true
end
local function InfPrompt(Prompt)
local Char = LocalPlayer.Character
if not Char then return end
local RootPart = Char:FindFirstChild("HumanoidRootPart")
if not RootPart then return end
local Tool = Char:FindFirstChild("Lockpick") or Char:FindFirstChild("SkeletonKey") or Char:FindFirstChild("Shears")
local Name = Tool and Tool.Name
local TargetPart = Prompt.Parent and (Prompt.Parent:IsA("BasePart") and Prompt.Parent or Prompt.Parent:FindFirstChildWhichIsA("BasePart"))
local Dist = TargetPart and GetDistanceToPlayer(TargetPart.Position) or 999
if Tool and Dist <= (Prompt.MaxActivationDistance + 5) then
if Prompt:GetAttribute("InfItems") and Prompt:GetAttribute("Tool") ~= Name then
RestorePrompt(Prompt)
end
if Prompt:GetAttribute("InfItems") then
local startTime = Prompt:GetAttribute("InfTime") or 0
if (tick() - startTime > 8) or (Dist > Prompt.MaxActivationDistance + 7) then
RestorePrompt(Prompt)
end
return
end
if not Prompt:GetAttribute("InfItems") then
Prompt.Enabled = false
Prompt:SetAttribute("InfItems", true)
Prompt:SetAttribute("Tool", Name)
Prompt:SetAttribute("InfTime", tick())
Prompt.ClickablePrompt = false
local Clone = Prompt:Clone()
Clone.Name = "InfPrompt"
Clone.MaxActivationDistance = Prompt.MaxActivationDistance
Clone.Parent = Prompt.Parent
Clone.Enabled = true
Clone.ClickablePrompt = true
local Con, ConEnded
local function Cleanup()
if Con then Con:Disconnect() end
if ConEnded then ConEnded:Disconnect() end
RestorePrompt(Prompt)
end
ConEnded = Clone.PromptButtonHoldEnded:Connect(function()
task.delay(0.15, function()
if Clone and Clone.Parent then
Cleanup()
end
end)
end)
Con = Clone.Triggered:Connect(function()
if ConEnded then ConEnded:Disconnect() end
if Con then Con:Disconnect() end
if Clone and Clone.Parent then Clone:Destroy() end
if Char:FindFirstChild(Name) then
task.spawn(function()
local Drop = nil
local StartTime = tick()
repeat
RemotesFolder.DropItem:FireServer(Tool)
task.wait(0.01)
local ClosestDist = 15
if workspace:FindFirstChild("Drops") then
for _, v in ipairs(workspace.Drops:GetChildren()) do
if v.Name == Name then
local d = GetDistanceToPlayer(v:GetPivot().Position)
if d < ClosestDist then
ClosestDist = d
Drop = v
end
end
end
end
until Drop or not Char:FindFirstChild(Name) or (tick() - StartTime) > 2.5
local firePromptFunc = Firepp or fireproximityprompt
if Name == "Shears" then
if firePromptFunc then firePromptFunc(Prompt) end
if Drop then
local DropPrompt = Drop:FindFirstChildWhichIsA("ProximityPrompt", true)
if DropPrompt and firePromptFunc then firePromptFunc(DropPrompt) end
end
else
if Drop then
local DropPrompt = Drop:FindFirstChildWhichIsA("ProximityPrompt", true)
if DropPrompt and firePromptFunc then firePromptFunc(DropPrompt) end
end
if firePromptFunc then firePromptFunc(Prompt) end
end
RestorePrompt(Prompt)
end)
else
RestorePrompt(Prompt)
end
end)
end
else
if Prompt:GetAttribute("InfItems") then
RestorePrompt(Prompt)
end
end
end
BypassBox:AddToggle('InfItems',{
Text = "Infinite Items",
BypassBox:AddLabel("If Infinite Items doesn't work with Auto-Interact (R), it will work with the default game bind (E). Just keep tapping it",true),
Callback = function(Value)
if Value then
for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
if IsInfItemTarget(v) then
table.insert(Stored, v)
end
end
else
for _, Prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
if Prompt:IsA("ProximityPrompt") and Prompt:GetAttribute("InfItems") then
RestorePrompt(Prompt)
end
end
table.clear(Stored)
end
end
})
local InfParams = RaycastParams.new()
InfParams.FilterType = Enum.RaycastFilterType.Exclude
local AutoInteract = 0
local AutoLibrary = 0
local AutoAnchorSolver  = 0
local NotifyCode = 0
local InfItemsDelay = 0
local PlayerESP = 0
local DoorReach = 0
table.insert(Connections,RunService.RenderStepped:Connect(function(dt)
AutoInteract += dt
NotifyCode += dt
AutoAnchorSolver += dt
InfItemsDelay += dt
PlayerESP += dt
AutoLibrary += dt
DoorReach += dt
if not LocalPlayer:GetAttribute("Alive") then
if Toggles.InfRevive.Value then
RemotesFolder.Revive:FireServer()
end
if CollisionClone then
CollisionClone = nil
end
return
end
if Camera ~= workspace.CurrentCamera then
Camera = workspace.CurrentCamera
end
if not LocalPlayer.Character:GetAttribute("Climbing") and Toggles.EnableMovementSpeed.Value then
if LocalPlayer.Character.Humanoid.WalkSpeed ~= Options.MovementSpeed.Value then
LocalPlayer.Character.Humanoid.WalkSpeed = Options.MovementSpeed.Value
end
elseif LocalPlayer.Character:GetAttribute("Climbing") and Toggles.EnableClimbingSpeed.Value then
if LocalPlayer.Character.Humanoid.WalkSpeed ~= Options.ClimbingSpeed.Value then
LocalPlayer.Character.Humanoid.WalkSpeed = Options.ClimbingSpeed.Value
end
end
if Toggles.ThirdPerson.Value then
Camera.CFrame = Camera.CFrame * CFrame.new(Options.X.Value, Options.Y.Value, Options.Z.Value)
end
for _, v in pairs(LocalPlayer.Character:GetChildren()) do
if v:IsA("BasePart") and (v.Name == "Head" or v.Name == "FakeHead") then
v.Transparency = Toggles.ThirdPerson.Value and 0 or 1
v.LocalTransparencyModifier = Toggles.ThirdPerson.Value and 0 or 1
end
if v:IsA("Accessory") then
local handle = v:FindFirstChild("Handle")
if handle then
handle.Transparency = Toggles.ThirdPerson.Value and 0 or 1
handle.LocalTransparencyModifier = Toggles.ThirdPerson.Value and 0 or 1
end
end
end
Camera.FieldOfView = Options.FOV.Value
if Toggles.Freecam.Value then
local char = LocalPlayer.Character
local hum = char and char:FindFirstChild("Humanoid")
local root = char and char:FindFirstChild("HumanoidRootPart")
if root and not root.Anchored then root.Anchored = true end
if not workspace:FindFirstChild("FreecamPart") then
local part = Instance.new("Part")
part.Name = "FreecamPart"
part.Size = Vector3.new(0.01, 0.01, 0.01)
part.Transparency = 1
part.CanCollide = false
part.Anchored = true
part.CFrame = Camera.CFrame
part.Parent = workspace
LocalPlayer:SetAttribute("fc_om", LocalPlayer.CameraMinZoomDistance)
LocalPlayer:SetAttribute("fc_ox", LocalPlayer.CameraMaxZoomDistance)
LocalPlayer.CameraMinZoomDistance = 0
LocalPlayer.CameraMaxZoomDistance = 0
local rx, ry, rz = Camera.CFrame:ToOrientation()
LocalPlayer:SetAttribute("fc_p", math.deg(rx))
LocalPlayer:SetAttribute("fc_y", math.deg(ry))
end
local fcPart = workspace:FindFirstChild("FreecamPart")
local curCam = Camera
if fcPart and curCam then
local delta = UserInputService:GetMouseDelta()
local sensitivity = UserInputService.KeyboardEnabled and 0.3 or 0.6
local pitch = (LocalPlayer:GetAttribute("fc_p") or 0) - (delta.Y * sensitivity)
local yaw = (LocalPlayer:GetAttribute("fc_y") or 0) - (delta.X * sensitivity)
pitch = math.clamp(pitch, -80, 80)
LocalPlayer:SetAttribute("fc_p", pitch)
LocalPlayer:SetAttribute("fc_y", yaw)
fcPart.CFrame = CFrame.new(fcPart.Position) * CFrame.fromOrientation(math.rad(pitch), math.rad(yaw), 0)
curCam.CFrame = fcPart.CFrame
curCam.Focus = curCam.CFrame * CFrame.new(0, 0, -10)
if hum and hum.MoveDirection.Magnitude > 0 then
local speed = 75
local moveVec = hum.MoveDirection
local localMove = curCam.CFrame:VectorToObjectSpace(moveVec)
local finalMove = (curCam.CFrame.RightVector * localMove.X) + (curCam.CFrame.LookVector * -localMove.Z)
fcPart.Position = fcPart.Position + (finalMove * speed * dt)
end
end
end
if Toggles.DeleteFigureFE.Value and Figures then
for _, v in pairs(Figures) do
local Root = v:FindFirstChild("Root")
if not IsNetworkOwner then
Notify("Sorry your executor wont support Delete Figure Because isnetworkowner", 5)
Toggles.DeleteFigureFE:SetValue(false)
end
if Root and isnetworkowner(Root) then
if Root:FindFirstChild("BodyForce") then
Root.BodyForce.Force = Vector3.new(0, -50000, 0)
else
Root:PivotTo(CFrame.new(0, -50000, 0))
end
for _, part in pairs(v:GetDescendants()) do
if part:IsA("BasePart") and part.CanCollide then
part.CanCollide = false
part.Anchored = false
end
end
if Root.Position.Y < -1000 and not v:GetAttribute("Deleted") then
Notify("Deleted Figure Successfully", 4)
v:SetAttribute("Deleted", true)
end
end
end
end
if Toggles.AutoAnchorSolver.Value and LatestRoom.Value == 50 and AutoAnchorSolver > 0.5  then
AutoAnchorSolver = 0
local Hint = LocalPlayer.PlayerGui.MainUI:FindFirstChild("AnchorHintFrame")
if Anchors and Hint and Hint.Visible then
local ID = Hint.AnchorCode.Text
for _, v in pairs(Anchors) do
if v:FindFirstChild("Sign") and v.Sign.TextLabel.Text == ID then
local Code = Hint.Code.Text
local Note = v:FindFirstChild("Note")
local NoteText = Note and Note.SurfaceGui.TextLabel.Text or ""
local Mod = tonumber(string.match(NoteText, "%d+")) or 0
local Final = ""
for i = 1, #Code do
local Digit = tonumber(string.sub(Code, i, i)) or 0
local Res = string.find(NoteText, "+") and (Digit + Mod) % 10 or (Digit - Mod) % 10
Final = Final .. tostring(Res < 0 and Res + 10 or Res)
end
local Dis = (LocalPlayer.Character.HumanoidRootPart.Position - v:GetPivot().Position).Magnitude
if Dis < 20 then
local AnchorRemote = v:FindFirstChildOfClass("RemoteFunction")
if AnchorRemote then
AnchorRemote:InvokeServer(tostring(Code))
end
Notify("Anchor " .. Final, 1)
end
end
end
end
end
if Toggles.AutoMinecart.Value and Camera:FindFirstChild("MinecartRig") then
if LatestRoom.Value < 49 then
if not LocalPlayer:GetAttribute("NotifyMinecart") then
Notify("[Auto Minecart] DONT MOVE", 5)
LocalPlayer:SetAttribute("NotifyMinecart", true)
end
local Root = LocalPlayer.Character.HumanoidRootPart
local ClosestDuckDist = math.huge
for _, v in pairs(DuckBoards) do
local Dist = GetDistanceToPlayer(v:GetPivot().Position)
if Dist < ClosestDuckDist then
ClosestDuckDist = Dist
end
end
if RequiredMainGame.crouching ~= (ClosestDuckDist < 30) then
RequiredMainGame.crouching = (ClosestDuckDist < 30)
end
local CurrentNode = nil
local MinDist = math.huge
for _, Node in pairs(Nodes) do
if Node:GetAttribute("ForceConnect") then
local Dist = (Root.Position - Node.Position).Magnitude
if Dist < MinDist then
MinDist = Dist
CurrentNode = Node
end
end
end
if CurrentNode then
local CurrentNum = tonumber(string.match(CurrentNode.Name, "%d+"))
if CurrentNum then
local Node1
for _, Node in pairs(Nodes) do
if Node.Name == "MinecartNode" .. tostring(CurrentNum + 3) then
Node1 = Node
break
end
end
if Node1 then
local DistToNode = GetDistanceToPlayer(CurrentNode.Position)
if DistToNode > 30 then
require(LocalPlayer.PlayerScripts.PlayerModule):GetControls().GetMoveVector = function()
return Vector3.new(0, 0, -1)
end
else
local DirectionToNode = (CurrentNode.Position - Node1.Position).Unit
local Dot = DirectionToNode:Dot(CurrentNode.CFrame.RightVector)
require(LocalPlayer.PlayerScripts.PlayerModule):GetControls().GetMoveVector = function()
if Dot > 0.15 then
return Vector3.new(1, 0, 0)
elseif Dot < -0.15 then
return Vector3.new(1, 0, 0)
end
return Vector3.new(0, 0, -1)
end
end
end
end
end
elseif LatestRoom.Value >= 50 then
if LocalPlayer:GetAttribute("NotifyMinecart") then
Notify("[Auto Minecart] YOU CAN MOVE", 5)
LocalPlayer:SetAttribute("NotifyMinecart", false)
end
Toggles.AutoMinecart:SetValue(false)
require(LocalPlayer.PlayerScripts.PlayerModule):GetControls().GetMoveVector = Control
end
end
if Toggles.InfItems.Value and InfItemsDelay > 0.15 then
InfItemsDelay = 0
for _, Prompt in pairs(Stored) do
InfPrompt(Prompt)
end
end
if Toggles.NotifyLibraryCode.Value and NotifyCode >  5 then
NotifyCode = 0
local Code = GetLibraryCode()
if Code and LatestRoom.Value == 50 then
Notify("Code " .. Code)
end
end
if Toggles.Flight.Value then
if not LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlightVelocity") then
local Velocity = Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
Velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
Velocity.Velocity = Vector3.zero
Velocity.Name = "FlightVelocity"
Velocity.P = math.huge
end
if OldAccel then
LocalPlayer.Character.HumanoidRootPart.CustomPhysicalProperties = OldAccel
end
local moveDir = LocalPlayer.Character.Humanoid.MoveDirection
local flatLook = Camera.CFrame.LookVector * Vector3.new(1, 0, 1)
if flatLook.Magnitude < 0.001 then
flatLook = Camera.CFrame.UpVector * Vector3.new(1, 0, 1) * math.sign(-Camera.CFrame.LookVector.Y)
end
local flatCam = CFrame.lookAt(Vector3.zero, flatLook)
local localInput = flatCam:VectorToObjectSpace(moveDir)
LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlightVelocity").Velocity = Camera.CFrame:VectorToWorldSpace(localInput) * Options.FlightSpeed.Value
end
if Toggles.Godmode.Value then
if RemotesFolder.Name == "RemotesFolder" then
if not Toggles.FigureHearing.Value then
Notify("Enabled Figure Hearing Automaticlly cause Godmode needs it", 3)
Toggles.FigureHearing:SetValue(true)
end
if LocalPlayer.Character.LowerTorso.Root.C1 ~= CFrame.new(0, -2.3, 0) then
LocalPlayer.Character.LowerTorso.Root.C1 = CFrame.new(0, -2.3, 0)
end
if LocalPlayer.Character.Humanoid.HipHeight ~= 0.22 then
LocalPlayer.Character.Humanoid.HipHeight = 0.22
end
if LocalPlayer.Character.Collision.Size ~= Vector3.new(1, 1, 4) then
LocalPlayer.Character.Collision.Size = Vector3.new(1, 1, 4)
end
if LocalPlayer.Character.Collision.CollisionCrouch.Size ~= Vector3.new(1, 1, 4) then
LocalPlayer.Character.Collision.CollisionCrouch.Size = Vector3.new(1, 1, 4)
end
end
if (Floor.Value == "Fools" or RemotesFolder.Name == "Bricks") and not Toggles.NoClip.Value then
Toggles.NoClip:SetValue(true)
end
end
if not LocalPlayer.Character:FindFirstChild("CollisionClone") then
if LocalPlayer.Character:FindFirstChild("CollisionPart") then
CollisionClone = LocalPlayer.Character.CollisionPart:Clone()
CollisionClone.Parent = LocalPlayer.Character
CollisionClone.Name = "CollisionClone"
CollisionClone.RootPriority = 127
CollisionClone.Anchored = false
CollisionClone.CanCollide = false
if CollisionClone:FindFirstChild("CollisionCrouch") then
CollisionClone:FindFirstChild("CollisionCrouch"):Destroy()
end
end
end
if Toggles.NoScenes.Value and LatestRoom.Value == 100 then
Toggles.NoScenes:SetValue(false)
end
if not HookMeta then
if Toggles.FigureHearing.Value then
if RemotesFolder:FindFirstChild("Crouch") then
RemotesFolder.Crouch:FireServer(true)
end
end
end
if Toggles.InfCrucifix.Value and not Toggles.Godmode.Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
local Origin = LocalPlayer.Character.HumanoidRootPart.Position
local Tool = LocalPlayer.Character:FindFirstChild("Crucifix")
if Tool then
for _, Entity in pairs(workspace:GetChildren()) do
local MaxRange = InfCrucfixTable[Entity.Name]
if MaxRange and Entity.PrimaryPart then
local Target = Entity.PrimaryPart.Position
local Dist = (Origin - Target).Magnitude
if Dist < (MaxRange + 40) then
InfParams.FilterDescendantsInstances = {LocalPlayer.Character, Entity}
local Hit = workspace:Raycast(Origin, Target - Origin, InfParams)
if not Hit then
task.spawn(function()
RemotesFolder.DropItem:FireServer(Tool)
local FireFunc = Firepp or fireproximityprompt
local StartTime = tick()
repeat
task.wait(0.01)
local Drops = workspace:FindFirstChild("Drops")
local Drop = Drops and Drops:FindFirstChild("Crucifix")
local Prompt = Drop and Drop:FindFirstChildOfClass("ProximityPrompt")
if Prompt and FireFunc then
FireFunc(Prompt)
end
until LocalPlayer.Character:FindFirstChild("Crucifix") or (tick() - StartTime) > 1.2
end)
break
end
end
end
end
end
end
if Toggles.AutoLibraryCode.Value then
if LatestRoom.Value == 50 then
local Code = GetLibraryCode()
if Code then
if Toggles.BruteForceLibCode.Value and string.find(Code, "_") then
local Bruted = ""
for i = 1, #Code do
local char = string.sub(Code, i, i)
Bruted ..= (char == "_" and math.random(0, 9) or char)
end
Code = Bruted
end
PL:FireServer(Code)
end
end
end
if Toggles.DoorReach.Value and DoorReach > 0.2 then
DoorReach = 0
local Rooms = workspace:FindFirstChild("CurrentRooms")
local Room = Rooms and Rooms:FindFirstChild(tostring(tonumber(LatestRoom.Value) or 0))
local Door = Room and Room:FindFirstChild("Door")
if Door and Door:FindFirstChild("Door") and Door.Parent and Door.Parent.Name ~= "101" and GetDistanceToPlayer(Door.Door.Position) < 30 then
Door.ClientOpen:FireServer()
end
end
if Toggles.NoAcc.Value then
if not Toggles.Flight.Value then
if LocalPlayer.Character.HumanoidRootPart.CustomPhysicalProperties ~= PhysicalProperties.new(100, 0.1, 0.1, 0.1, 0.1) then
LocalPlayer.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(100, 0.1, 0.1, 0.1, 0.1)
end
end
end
if Toggles.EnableJump.Value then
if not LocalPlayer.Character:GetAttribute("CanJump") then
LocalPlayer.Character:SetAttribute("CanJump",true)
end
end
if Toggles.AutoInteract and Toggles.AutoInteract.Value then
AutoInteract = AutoInteract + (dt or 0.016)
local interactDelay = Options.AutoInteractDelay and Options.AutoInteractDelay.Value or 0.05
if AutoInteract > interactDelay then
AutoInteract = 0
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
local hrpPos = LocalPlayer.Character.HumanoidRootPart.Position
local reachDist = Options.AutoInteractreach and Options.AutoInteractreach.Value or 12
local fireppFunc = Firepp or fireproximityprompt
for i = #Interactions, 1, -1 do
local prompt = Interactions[i]
if not prompt or not prompt.Parent then
table.remove(Interactions, i)
continue
end
if (prompt.Parent.Name == "GoldPile" and Floor and Floor.Value == "Fools") or prompt.Parent.Name == "KeyObtainFake" then
continue
end
if prompt.Parent.Parent and prompt.Parent.Parent.Parent and prompt.Parent.Parent.Parent.Name == "ItemSpawns" then
continue
end
if prompt:GetAttribute("InfItems") and prompt.Name ~= "InfPrompt" then
continue
end
if prompt.Parent.Name == "Mandrake" then
continue
end
if prompt:GetAttribute("Interactions") and prompt:GetAttribute("Interactions") > 0 then
table.remove(Interactions, i)
continue
end
if prompt.Parent:IsA("BasePart") or prompt.Parent:IsA("Model") then
local TargetPart = prompt.Parent:IsA("BasePart") and prompt.Parent or (prompt.Parent.PrimaryPart or prompt.Parent:FindFirstChildWhichIsA("BasePart"))
if TargetPart then
if (hrpPos - TargetPart.Position).Magnitude <= reachDist then
if not prompt.Enabled then
prompt.Enabled = true
end
if fireppFunc then
fireppFunc(prompt)
else
prompt:InputHoldBegin()
prompt:InputHoldEnd(prompt.HoldDuration or 0)
end
end
end
end
end
end
end
end
if Toggles.NoFog.Value then
if Lighting.FogEnd < 100000 then
Lighting.FogEnd = 100000
end
for _, v in pairs(Lighting:GetChildren()) do
if v:IsA("Atmosphere") and v.Density > 0 then
v.Density = 0
end
end
end
if Toggles.NoCamShake.Value then
if RequiredMainGame then
RequiredMainGame.csgo = CFrame.new(0,0,0)
end
end
if Toggles.Player.Value and PlayerESP > 1 then
PlayerESP = 0
for _, v in pairs(Players:GetPlayers()) do
if v ~= LocalPlayer and v.Character then
local hum = v.Character:FindFirstChildOfClass("Humanoid")
if hum then
if hum.Health > 0 then
AddESP(v.Character, v.Name .. " [" .. math.floor((hum.Health / hum.MaxHealth) * 100) .. "%]", PlayerColor)
else
ESPLibrary:RemoveESP(v.Character)
end
end
end
end
end
if Toggles.EyesDamage.Value then
if (workspace:FindFirstChild("Eyes") or workspace:FindFirstChild("Lookman")) and not LocalPlayer.Character:GetAttribute("Hiding") then
if RemotesFolder.Name ~= "RemotesFolder" then
MotorReplication:FireServer(0, -650, 0, false)
else
MotorReplication:FireServer(-650)
end
end
end
if Toggles.LookmanDamage.Value then
if workspace:FindFirstChild("BackdoorLookman") then
if not LocalPlayer.Character:GetAttribute("Hiding") then
MotorReplication:FireServer(-650)
end
end
end
if Toggles.FullBright.Value then
if Lighting.Ambient ~= Color3.new(1, 1, 1) then
Lighting.Ambient = Color3.new(1, 1, 1)
end
local FBRooms = workspace:FindFirstChild("CurrentRooms")
local FBNum = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
local FBRoom = FBRooms and FBRooms:FindFirstChild(tostring(FBNum))
if FBRoom then
if not FBRoom:GetAttribute("OldAmbient") then
FBRoom:SetAttribute("OldAmbient", FBRoom:GetAttribute("Ambient"))
end
if FBRoom:GetAttribute("Ambient") ~= Color3.new(1, 1, 1) then
FBRoom:SetAttribute("Ambient", Color3.new(1, 1, 1))
end
end
if (tonumber(LatestRoom.Value) or 0) < 100 then
local FBNext = FBRooms and FBRooms:FindFirstChild(tostring(FBNum + 1))
if FBNext then
if not FBNext:GetAttribute("OldAmbient") then
FBNext:SetAttribute("OldAmbient", FBNext:GetAttribute("Ambient"))
end
if FBNext:GetAttribute("Ambient") ~= Color3.new(1, 1, 1) then
FBNext:SetAttribute("Ambient", Color3.new(1, 1, 1))
end
end
end
end
if Toggles.AntiCheatMani.Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
if Options.AntiCheatManiMethod.Value == "Velocity" then
if not Toggles.NoClip.Value then
Toggles.NoClip:SetValue(true)
end
local BodyVelocity = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("VelocityMani") or Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
local LookingVector = LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * 2
BodyVelocity.Velocity = Vector3.new(LookingVector.X, LookingVector.Y, LookingVector.Z)
BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
BodyVelocity.Name = "VelocityMani"
else
local currentPivot = LocalPlayer.Character:GetPivot()
LocalPlayer.Character:PivotTo(currentPivot  * CFrame.new(0, 0, 10000))
end
end
if Options.AutoInteractKeybind:GetState() and not Toggles.AutoInteract.Value then
Toggles.AutoInteract:SetValue(true)
end
if not Options.AutoInteractKeybind:GetState() and  Toggles.AutoInteract.Value then
Toggles.AutoInteract:SetValue(false)
end
if Options.NoclipKeybind:GetState() and not Toggles.NoClip.Value then
Toggles.NoClip:SetValue(true)
end
if not Options.NoclipKeybind:GetState() and  Toggles.NoClip.Value then
Toggles.NoClip:SetValue(false)
end
if Options.ThirdpersonKeybind:GetState() and not Toggles.ThirdPerson.Value then
Toggles.ThirdPerson:SetValue(true)
end
if not Options.ThirdpersonKeybind:GetState() and  Toggles.ThirdPerson.Value then
Toggles.ThirdPerson:SetValue(false)
end
if Options.AntiCheatMan:GetState() and not Toggles.AntiCheatMani.Value then
Toggles.AntiCheatMani:SetValue(true)
end
if not Options.AntiCheatMan:GetState() and  Toggles.AntiCheatMani.Value then
Toggles.AntiCheatMani:SetValue(false)
end
if Toggles.NoClip.Value then
for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
if v:IsA("BasePart") and v.Name ~= "CollisionClone" and v.CanCollide then
v.CanCollide = false
end
end
if LocalPlayer.Character:FindFirstChild("Collision") then
LocalPlayer.Character.Collision.CanCollide = false
if LocalPlayer.Character.Collision:FindFirstChild("CollisionCrouch") then
LocalPlayer.Character.Collision.CollisionCrouch.CanCollide = false
end
end
end
if not Toggles.NoClip.Value then
for _, v in pairs(LocalPlayer.Character:GetChildren()) do
if v.Name ~= "CollisionClone" and v.Name ~= "Collision" then
if v:IsA("BasePart") and not v.CanCollide then
v.CanCollide = true
end
end
end
if LocalPlayer.Character:FindFirstChild("Collision") then
LocalPlayer.Character.Collision.CanCollide = (LocalPlayer.Character.Collision.CollisionGroup == "PlayerCrouching" and false or LocalPlayer.Character.Collision.CollisionGroup ~= "PlayerCrouching" and true)
if LocalPlayer.Character.Collision:FindFirstChild("CollisionCrouch") then
LocalPlayer.Character.Collision.CollisionCrouch.CanCollide = LocalPlayer.Character.Collision.CanCollide
end
end
end
end))
table.insert(Connections, RunService.RenderStepped:Connect(function()
if Toggles.AutoRooms.Value then
if IsMoving then return end
if Toggles.IgnoreA60.Value and not Toggles.Godmode.Value then
Toggles.Godmode:SetValue(true)
Notify("Godmode Enabled Automatically For Ignore A-60", 5)
end
LocalPlayer.Character.Collision.Size = Vector3.new(1, 1, 3)
local DangerousEntity = workspace:FindFirstChild("A120") or workspace:FindFirstChild("GlitchRush") or workspace:FindFirstChild("GlitchAmbush")
local A60 = workspace:FindFirstChild("A60")
local ShouldHide = false
if DangerousEntity and DangerousEntity.PrimaryPart and DangerousEntity.PrimaryPart.Position.Y > -4 then
ShouldHide = true
elseif A60 and A60.PrimaryPart and A60.PrimaryPart.Position.Y > -4 then
if not Toggles.IgnoreA60.Value then
ShouldHide = true
end
end
if ShouldHide then
local Closet = GetNearestHidingSpot()
if Closet then
Closet.Base.CanCollide = false
PathTo(Closet.Base.Position)
if not LocalPlayer.Character.CollisionPart.Anchored then
fireproximityprompt(Closet.HidePrompt)
end
end
else
LocalPlayer.Character:SetAttribute("Hiding", false)
local CurrentRoom = workspace.CurrentRooms:FindFirstChild(tostring(LatestRoom.Value))
if CurrentRoom then
local TargetDoor = CurrentRoom:FindFirstChild("Door")
if TargetDoor and TargetDoor:FindFirstChild("Door") then
PathTo(TargetDoor.Door.Position)
end
end
end
end
end))
if HookMeta then
local Old
Old = hookmetamethod(game, "__namecall", function(Self, ...)
if Library.Unloaded then
return Old(Self, ...)
end
local Method = getnamecallmethod()
if Method == "FireServer" or Method == "InvokeServer" then
if Toggles.AutoHeartbeat.Value and Self.Name == "ClutchHeartbeat" then
return Old(Self, true)
end
if Method == "FireServer" and Toggles.FigureHearing.Value and Self.Name == "Crouch" then
return Old(Self, true,true)
end
end
return Old(Self, ...)
end)
end
table.insert(Connections,workspace.DescendantAdded:Connect(function(v)
local timeout = 0
repeat task.wait(0.03) timeout += 0.03 until v.Parent or timeout > 0.5
if v.Parent then
if v.Parent:FindFirstChildOfClass("Humanoid") then return end
if (v.Name == "Candle" and v.Parent.Name == "Candle" or v.Parent.Parent and v.Parent.Parent.Name == "Candle") then return end
if  HidingPlaces[v.Name] then
table.insert(Closets, v)
end
if Toggles.AntiLag.Value then
if v:IsA("BasePart") then
v:SetAttribute("Mat", v.Material)
v.Material = "Plastic"
end
end
if Toggles.InfItems.Value then
if IsInfItemTarget(v) then
table.insert(Stored, v)
end
end
if Toggles.DeleteSeekFE.Value then
if v.Name == "TriggerEventCollision" then
Notify("Deleting Seek", 3)
local Part = v:FindFirstChild("Collision") or v.ChildAdded:Wait()
if Part then
Notify("DONT OPEN NEXT DOOR", 1)
task.wait(0.1)
for _, Item in pairs(v:GetChildren()) do
if Item.Name == "Collision" then
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
if FireTouch then
firetouchinterest(LocalPlayer.Character.HumanoidRootPart, Item, 0)
task.wait()
firetouchinterest(LocalPlayer.Character.HumanoidRootPart, Item, 1)
end
end
end
end
task.wait(0.5)
local Success = true
for _, Item in pairs(v:GetChildren()) do
if Item.Name == "Collision" then
Success = false
break
end
end
if Success then
Notify("Deleted Seek Successfully Open Next Door", 3)
else
Notify("Failed To Delete Seek Open Next Door", 3)
end
end
end
end
if Toggles.SeekObf.Value then
if v.Name == "Seek_Arm" or v.Name == "ChandelierObstruction" then
for _, i in pairs(v:GetChildren()) do
if i:IsA("BasePart") then
i.CanTouch = false
end
end
end
end
if Toggles.AutoMinecart.Value then
if v.Name == "DuckBoard" then
table.insert(DuckBoards, v)
end
if string.find(v.Name, "MinecartNode") then
table.insert(Nodes, v)
end
end
if Toggles.AntiSeekFlood.Value then
if v.Name == "SeekFloodline" then
v.CanCollide = true
end
end
if Toggles.ShowPath.Value then
if v.Name == "SeekGuidingLight" then
ShowSeekPath(v)
end
end
if Toggles.DeleteFigureFE.Value then
if v.Name == "FigureRig" or v.Name == "FigureRagdoll" then
table.insert(Figures,v)
end
end
if Toggles.PromptClip.Value then
if v:IsA("ProximityPrompt") then
v:SetAttribute("Clip", v.RequiresLineOfSight)
v.RequiresLineOfSight = false
end
end
if Toggles.AutoBreaker.Value then
if v.Name == "ElevatorBreaker" then
Breaker(v)
end
end
if Toggles.PromptReach.Value then
if v:IsA("ProximityPrompt") then
v:SetAttribute("Range", v.MaxActivationDistance)
v.MaxActivationDistance = v.MaxActivationDistance * 2
end
end
if Toggles.Snare.Value then
if  v.Name == "Snare" then
local wait = 0
repeat task.wait(0.01) wait = wait  + 0.01 until wait > 1 or v:FindFirstChild("Hitbox")
if v:FindFirstChild("Hitbox") then
v.Hitbox.CanTouch = false
end
end
end
if Toggles.AntiLava.Value then
if v.Name == "Lava" then
v.CanTouch = false
end
end
if Toggles.AntiWall.Value then
if v.Name == "ScaryWall" then
for _, i in pairs(v:GetChildren()) do
if i:IsA("BasePart") then
i.CanTouch = false
end
end
end
end
if Toggles.RealBridge.Value then
if v.Name == "Bridge" then
if v.CanCollide == false then
v.Transparency = 1
end
end
end
if Toggles.Dupe.Value then
if v.Name == "DoorFake"  and v.Parent.Name == "SideroomDupe" then
v:WaitForChild("Hidden",9e9).CanTouch = false
end
end
if Toggles.FixBrokenBridge.Value then
if v.Name == "Bridge" then
FixBridge(v)
end
end
if Toggles.AutoAnchorSolver.Value then
if v.Name == "MinesAnchor" then
table.insert(Anchors,v)
end
end
if Toggles.GloomEggDamage.Value then
if v.Name == "GloomEgg" then
repeat task.wait() until v:FindFirstChildWhichIsA("BasePart")
for _, i in pairs(v:GetChildren()) do
if i:IsA("BasePart")  then
i.CanTouch = false
end
end
end
end
if v:IsA("ProximityPrompt") then
if not (PromptIgnore[v.Name] or  v.Parent.Name == "Padlock" or  v.Parent:GetAttribute("JeffShop"))  or v.Parent.Parent.Name == "RetroWardrobe" then
table.insert(Interactions, v)
end
end
if Toggles.Giggle.Value then
if   v.Name == "GiggleCeiling" then
repeat task.wait() until v:FindFirstChild("Hitbox")
v.Hitbox.CanTouch = false
end
end
if v:IsA("ProximityPrompt") then
if Toggles.InstaInteract.Value then
v:SetAttribute("Duration",v.HoldDuration)
v.HoldDuration = 0
end
end
end
end))
table.insert(Connections,workspace.DescendantRemoving:Connect(function(v)
if Toggles.AutoInteract.Value then
for i, g in pairs(Interactions) do
if g ==  v then
table.remove(Interactions, i)
break
end
end
end
for i, g in pairs(Closets) do
if v == g then
table.remove(Closets, i)
end
end
for i, k in pairs(Stored) do
if v == k then
table.remove(Stored, i)
end
end
end))
task.spawn(function()
local MenuGroup = Tabs.Settings:AddLeftGroupbox('UI Settings')
local UtilityBox = Tabs.Settings:AddRightGroupbox('Speedy Client Utilities')
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle("ShowKeybinds", { Text = "Show Keybinds Overlay", Default = false }):OnChanged(function()
Library.KeybindFrame.Visible = Toggles.ShowKeybinds.Value
end)
MenuGroup:AddToggle("ShowCustomCursor", {
Text = "Custom Cursor",
Default = true,
Callback = function(Value)
Library.ShowCustomCursor = Value
end,
})
MenuGroup:AddDivider()
MenuGroup:AddToggle('PlayNotifySound',{
Text = "Play Notification Sound",
Default = true,
Callback = function(Value)
PlaySound = Value
end
})
MenuGroup:AddDropdown("NotificationSide", {
Values = { "Left", "Right" },
Default = "Right",
Text = "Notification Side",
Callback = function(Value)
Library:SetNotifySide(Value)
end,
})
MenuGroup:AddButton('Test Notification',function()
Notify("Hello World",2)
end)
MenuGroup:AddDropdown("Library", {
Values = { "Obsidian", "Linoria" },
Default = getgenv().ScriptLibrary,
Text = "Library",
Callback = function(Value)
getgenv().ScriptLibrary = tostring(Value)
Notify('Please Unload Script and Execute Again to Take Effect',4)
end,
})
MenuGroup:AddDropdown("RenderESPSpeed", {
Values = { "10", "30", "60", "90", "120","144", "240"},
Default = Library.IsMobile and 2 or 6,
Text = "ESP Rendering Speed",
Callback = function(Value)
ESPLibrary:SetRenderingSpeed(Value)
end,
})
MenuGroup:AddDivider()
MenuGroup:AddDropdown("DPIDropdown", {
Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
Default = "100%",
Text = "DPI Scale",
Callback = function(Value)
Value = Value:gsub("%%", "")
local DPI = tonumber(Value)
Library:SetDPIScale(DPI)
end,
})
UtilityBox:AddButton({
Text = "Unload Speedy Client",
Func = function()
LocalPlayer:SetAttribute("SpeedyClientLoaded", nil)
for _, con in pairs(Connections) do con:Disconnect() end
if ESPHooks and ESPHooks.ClearAll then
ESPHooks.ClearAll()
end
local Dread = LocalPlayer:FindFirstChild("Dread",true) or LocalPlayer:FindFirstChild("_Dread",true)
if Dread then
Dread.Name = "Dread"
end
local Dread = ClientModules.EntityModules:FindFirstChild("Shade",true) or ClientModules.EntityModules:FindFirstChild("_Shade",true)
if Dread then
Dread.Name = "Shade"
end
FakeA90:Destroy()
FakeScreech:Destroy()
if ReplicatedStorage:FindFirstChild("Screech") then
ReplicatedStorage:FindFirstChild("Screech").Parent = RemotesFolder
end
local getcons = getconnections or get_signal_cons or get_relative_connections
if getcons then
for _, con in pairs(getcons(LocalPlayer.Idled)) do
if con.Enable then
con:Enable()
end
end
end
local fcPart = workspace:FindFirstChild("FreecamPart")
if fcPart then
fcPart:Destroy()
local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if root then root.Anchored = false end
LocalPlayer.CameraMinZoomDistance = LocalPlayer:GetAttribute("fc_om") or 0.5
LocalPlayer.CameraMaxZoomDistance = LocalPlayer:GetAttribute("fc_ox") or 128
end
if ReplicatedStorage:FindFirstChild("A90") then
ReplicatedStorage:FindFirstChild("A90").Parent = RemotesFolder
end
for _, v in pairs(workspace:GetDescendants()) do
if v:IsA("BasePart") then
v.CanTouch = true
end
if v.Name == "BridgeBarrier" then
v:Destroy()
end
end
if LocalPlayer.Character then
LocalPlayer.Character.Humanoid.WalkSpeed = 16
LocalPlayer.Character:SetAttribute("CanJump",false)
for _, v in pairs(LocalPlayer.Character:GetChildren()) do
if not (v.Name == "CollisionClone") and v:IsA("BasePart") then
v.CanCollide  = true
end
end
if OldAccel then
LocalPlayer.Character.HumanoidRootPart.CustomPhysicalProperties = OldAccel
OldAccel = nil
end
end
for _, v in ipairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then
v.HoldDuration = v:GetAttribute("Duration") or
v.HoldDuration
end
end
if OldFogEnd then
Lighting.FogEnd = OldFogEnd
OldFogEnd = nil
end
for _, v in pairs(Lighting:GetChildren()) do
if v:IsA("Atmosphere") then
v.Density = 0.94
end
end
if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("VelocityMani") then
LocalPlayer.Character.HumanoidRootPart:FindFirstChild("VelocityMani"):Destroy()
end
Lighting.Ambient = Color3.fromRGB(0, 0, 0)
Lighting.GlobalShadows = true
for _, v in pairs(workspace.CurrentRooms:GetChildren()) do
v:SetAttribute("Ambient", v:GetAttribute("OldAmbient") and v:GetAttribute("OldAmbient") or Color3.new(0, 0, 0))
end
FakeScreech:Destroy()
FakeA90:Destroy()
task.wait()
if RemotesFolder:FindFirstChild("A90_") then
RemotesFolder:FindFirstChild("A90_").Name = "A90"
end
if RemotesFolder:FindFirstChild("Screech_") then
local Cutscene = RemoteListener:FindFirstChild("Cutscenes") or RemoteListener:FindFirstChild("Cutscenes_")
Cutscene.Name = "Cutscenes"
RemotesFolder:FindFirstChild("Screech_").Name = "Screech"
end
for _, v in pairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then
v.MaxActivationDistance = v:GetAttribute("Range") or v.MaxActivationDistance
end
if v.Name == "SeekFloodline" then
v.CanCollide = false
end
end
for _, Prompt in pairs(workspace.CurrentRooms:GetDescendants()) do
if Prompt:IsA("ProximityPrompt") and Prompt:GetAttribute("InfItems") then
RestorePrompt(Prompt)
end
end
for _, v in workspace.CurrentRooms:GetDescendants() do
if v:IsA("BasePart") then
if v:GetAttribute("Mat") then
v.Material = v:GetAttribute("Mat") or "Plastic"
end
end
end
if CollisionClone then
CollisionClone:Destroy()
CollisionClone = nil
end
for _, v in pairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then
v.RequiresLineOfSight = v:GetAttribute("Clip") or true
end
end
if PathFolder then
PathFolder:Destroy()
end
if LocalPlayer.Character then
LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
LocalPlayer.Character.LowerTorso.Root.C1 = CFrame.new(Vector3.new(0, 0, 0))
end
if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlightVelocity") then
LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlightVelocity"):Destroy()
end
if RemotesFolder:FindFirstChild("Crouch") then
RemotesFolder.Crouch:FireServer(false)
end
if LocalPlayer.Character then
LocalPlayer.Character.Collision.Position = LocalPlayer.Character.HumanoidRootPart.Position
LocalPlayer.Character.Humanoid.HipHeight =2.4
if RemotesFolder.Name ~= "RemotesFolder" then
LocalPlayer.Character.Collision.Position = LocalPlayer.Character.HumanoidRootPart.Position
end
end
if GodmodeFolder then Folder:Destroy()
end
if LocalPlayer.Character then
for _, v in pairs(LocalPlayer.Character:GetChildren()) do
if v.Name ~= "CollisionClone"  and v.Name ~= "Collision" and v.Name ~= "HumanoidRootPart" and v.Name ~= "CollisionPart" then
if v:IsA("BasePart") then
v.Transparency = 0
end
end
end
end
if  ReplicatedStorage:FindFirstChild("LiveModifiers") and ReplicatedStorage:FindFirstChild("LiveModifiers"):FindFirstChild("Jammin") then
local Jam = LocalPlayer.PlayerGui.MainUI.Initiator:FindFirstChild("Main_Game").Health.Jam
Jam.Playing = true
local Jamming = game:GetService("SoundService").Main.Jamming
Jamming.Enabled =  true
end
if Library.KeybindFrame then
local pos = Library.KeybindFrame.Position
getgenv().SpeedyClient_KeybindPos = { pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset }
end
Library:Unload()
ESPLibrary:Unload()
ShouldStop = true
end
})
end)
if ThemeManager then
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("Speedy Client")
end
if SaveManager then
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
SaveManager:SetFolder("Speedy Client/DOORSLOBBY")
SaveManager:BuildConfigSection(Tabs['Settings'])
end
if ThemeManager then
ThemeManager:ApplyToTab(Tabs['Settings'])
end
Notify("Successfully Loaded for Game |  DOORS ",4)
end