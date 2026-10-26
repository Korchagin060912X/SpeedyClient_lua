print("SpeedyClient diagnostic v2: inventory path checks active")

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local colors = {
	background = Color3.fromRGB(9, 15, 27),
	panel = Color3.fromRGB(14, 23, 40),
	panelLight = Color3.fromRGB(21, 34, 57),
	border = Color3.fromRGB(37, 55, 82),
	text = Color3.fromRGB(235, 241, 250),
	muted = Color3.fromRGB(139, 157, 183),
	accent = Color3.fromRGB(48, 105, 190),
}

local function create(className, properties, parent)
	local instance = Instance.new(className)
	for property, value in pairs(properties) do
		instance[property] = value
	end
	instance.Parent = parent
	return instance
end

local screenGui = create("ScreenGui", {
	Name = "SpeedyClientUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)
local inputChangedConnection
local inputEndedConnection
local inputBeganConnection
local viewportConnection
local menuKeyCode = Enum.KeyCode.M
local waitingForMenuKey = false
local menuKeybindButton
local antiAfkEnabled = false
local antiAfkGeneration = 0
local activeAntiAfkHumanoid
local menuIsOpen = true
local autoFarmEnabled = false
local autoFarmGeneration = 0
local activeFarmTween
local activeFarmHumanoid
local activeFarmAutoRotate
local activeFarmPlatformStand
local farmCollisionStates
local autoFarmToggleButton
local autoFarmTravelSpeed = 55
local activeFarmMap

local window = create("Frame", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(620, 380),
	BackgroundColor3 = colors.background,
	BorderSizePixel = 0,
}, screenGui)
create("UICorner", { CornerRadius = UDim.new(0, 14) }, window)
create("UIStroke", {
	Color = colors.border,
	Transparency = 0.15,
	Thickness = 1,
}, window)
local windowStroke = window:FindFirstChildOfClass("UIStroke")

local sizeConstraint = create("UISizeConstraint", {
	MinSize = Vector2.new(340, 300),
	MaxSize = Vector2.new(900, 600),
}, window)
local closedWindowSize = UDim2.fromOffset(580, 356)
local menuTransitionInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local toggleTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local menuTransitionGeneration = 0
local savedMenuTransparency = {}

local scale = create("UIScale", { Scale = 1 }, window)
local camera = workspace.CurrentCamera
local function updateScale()
	if camera then
		local viewport = camera.ViewportSize
		scale.Scale = math.min(1, viewport.X / 800, viewport.Y / 520)
	end
end
updateScale()
if camera then
	viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local function getTransparencyProperties(instance)
	local properties = {}
	if instance:IsA("GuiObject") then
		table.insert(properties, "BackgroundTransparency")
	end
	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		table.insert(properties, "TextTransparency")
	end
	if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		table.insert(properties, "ImageTransparency")
	end
	if instance:IsA("UIStroke") then
		table.insert(properties, "Transparency")
	end
	return properties
end

local function animateMenu(visible)
	menuTransitionGeneration += 1
	local generation = menuTransitionGeneration
	menuIsOpen = visible
	window.Visible = true

	local targetSize = visible and UDim2.fromOffset(620, 380) or closedWindowSize
	TweenService:Create(window, menuTransitionInfo, { Size = targetSize }):Play()

	local instances = { window }
	for _, instance in ipairs(window:GetDescendants()) do
		table.insert(instances, instance)
	end
	for _, instance in ipairs(instances) do
		for _, property in ipairs(getTransparencyProperties(instance)) do
			local savedProperties = savedMenuTransparency[instance]
			if not savedProperties then
				savedProperties = {}
				savedMenuTransparency[instance] = savedProperties
			end

			if savedProperties[property] == nil then
				savedProperties[property] = instance[property]
			end

			local targetTransparency = visible and savedProperties[property] or 1
			if visible then
				instance[property] = 1
			end
			TweenService:Create(instance, menuTransitionInfo, {
				[property] = targetTransparency,
			}):Play()
		end
	end

	if visible then
		if windowStroke then
			TweenService:Create(windowStroke, menuTransitionInfo, { Transparency = 0.15 }):Play()
		end
	else
		if windowStroke then
			TweenService:Create(windowStroke, menuTransitionInfo, { Transparency = 1 }):Play()
		end
		task.delay(menuTransitionInfo.Time, function()
			if menuTransitionGeneration == generation then
				window.Visible = false
			end
		end)
	end
end

local launcher = create("TextButton", {
	Name = "Launcher",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(42, 42),
	BackgroundColor3 = colors.panel,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	Text = "SC",
	TextColor3 = colors.text,
	TextSize = 14,
	Visible = false,
}, screenGui)
create("UICorner", { CornerRadius = UDim.new(0, 10) }, launcher)
create("UIStroke", {
	Color = colors.border,
	Transparency = 0.1,
	Thickness = 1,
}, launcher)
launcher.MouseEnter:Connect(function()
	TweenService:Create(launcher, TweenInfo.new(0.12), {
		BackgroundColor3 = colors.accent,
	}):Play()
end)
launcher.MouseLeave:Connect(function()
	TweenService:Create(launcher, TweenInfo.new(0.12), {
		BackgroundColor3 = colors.panel,
	}):Play()
end)
local launcherDragging = false
local launcherMoved = false
local launcherDragStart
local launcherStart
launcher.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		launcherDragging = true
		launcherMoved = false
		launcherDragStart = input.Position
		launcherStart = launcher.Position
	end
end)
launcher.Activated:Connect(function()
	if launcherMoved then
		launcherMoved = false
		return
	end
	animateMenu(true)
	launcher.Visible = false
end)

local header = create("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 72),
	BackgroundTransparency = 1,
}, window)

local closeButton = create("TextButton", {
	Name = "CloseButton",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -20, 0.5, 0),
	Size = UDim2.fromOffset(32, 32),
	BackgroundColor3 = colors.panel,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamMedium,
	Text = "X",
	TextColor3 = colors.muted,
	TextSize = 14,
}, header)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, closeButton)
closeButton.MouseEnter:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.12), {
		BackgroundColor3 = colors.panelLight,
		TextColor3 = colors.text,
	}):Play()
end)
closeButton.MouseLeave:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.12), {
		BackgroundColor3 = colors.panel,
		TextColor3 = colors.muted,
	}):Play()
end)
closeButton.Activated:Connect(function()
	animateMenu(false)
	launcher.Visible = true
end)

create("TextLabel", {
	Name = "Title",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(1, -220, 0, 32),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Speedy Client",
	TextColor3 = colors.text,
	TextSize = 22,
	TextXAlignment = Enum.TextXAlignment.Center,
}, header)

local dragging = false
local dragStart
local windowStart

local function beginDrag(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	dragging = true
	dragStart = input.Position
	windowStart = window.Position
end

local function addDragHandle(handle)
	handle.Active = true
	handle.InputBegan:Connect(beginDrag)
end

addDragHandle(header)
for _, edge in ipairs({
	{ Position = UDim2.new(0, 0, 0, 72), Size = UDim2.new(0, 8, 1, -80) },
	{ Position = UDim2.new(1, -8, 0, 72), Size = UDim2.new(0, 8, 1, -80) },
	{ Position = UDim2.new(0, 8, 1, -8), Size = UDim2.new(1, -16, 0, 8) },
}) do
	local handle = create("Frame", {
		Name = "DragHandle",
		Position = edge.Position,
		Size = edge.Size,
		BackgroundTransparency = 1,
		ZIndex = 5,
	}, window)
	addDragHandle(handle)
end

inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		if launcherDragging and launcherDragStart and launcherStart then
			local delta = input.Position - launcherDragStart
			if delta.Magnitude > 4 then
				launcherMoved = true
			end
			launcher.Position = UDim2.new(
				launcherStart.X.Scale,
				launcherStart.X.Offset + delta.X,
				launcherStart.Y.Scale,
				launcherStart.Y.Offset + delta.Y
			)
		elseif dragging and dragStart and windowStart then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(
				windowStart.X.Scale,
				windowStart.X.Offset + delta.X,
				windowStart.Y.Scale,
				windowStart.Y.Offset + delta.Y
			)
		end
	end
end)

inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		launcherDragging = false
		launcherDragStart = nil
		launcherStart = nil
		dragging = false
		dragStart = nil
		windowStart = nil
	end
end)

create("Frame", {
	Name = "HeaderDivider",
	Position = UDim2.new(0, 22, 1, -1),
	Size = UDim2.new(1, -44, 0, 1),
	BackgroundColor3 = colors.border,
	BorderSizePixel = 0,
}, header)

local content = create("Frame", {
	Name = "Content",
	Position = UDim2.new(0, 22, 0, 92),
	Size = UDim2.new(1, -190, 1, -140),
	BackgroundColor3 = colors.panel,
	BorderSizePixel = 0,
}, window)
create("UICorner", { CornerRadius = UDim.new(0, 11) }, content)
create("UIStroke", {
	Color = colors.border,
	Transparency = 0.35,
	Thickness = 1,
}, content)

local sectionTitle = create("TextLabel", {
	Name = "SectionTitle",
	Position = UDim2.new(0, 24, 0, 22),
	Size = UDim2.new(1, -48, 0, 30),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamSemibold,
	Text = "Home",
	TextColor3 = colors.text,
	TextSize = 19,
	TextXAlignment = Enum.TextXAlignment.Left,
}, content)

local cardList = create("ScrollingFrame", {
	Name = "InformationCards",
	Position = UDim2.new(0, 16, 0, 60),
	Size = UDim2.new(1, -32, 1, -76),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = colors.accent,
}, content)
local cardLayout = create("UIListLayout", {
	Padding = UDim.new(0, 9),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, cardList)

local function setAntiAfkEnabled(enabled)
	antiAfkEnabled = enabled
	antiAfkGeneration += 1

	if not enabled then
		if activeAntiAfkHumanoid and activeAntiAfkHumanoid.Parent then
			local rootPart = activeAntiAfkHumanoid.Parent:FindFirstChild("HumanoidRootPart")
			if rootPart and rootPart:IsA("BasePart") then
				activeAntiAfkHumanoid:MoveTo(rootPart.Position)
			end
		end
		activeAntiAfkHumanoid = nil
		return
	end

	local generation = antiAfkGeneration
	task.spawn(function()
		while antiAfkEnabled and antiAfkGeneration == generation do
			task.wait(600)
			if not antiAfkEnabled or antiAfkGeneration ~= generation then
				break
			end

			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and rootPart and rootPart:IsA("BasePart") then
				humanoid.Jump = true
				task.wait(0.25)
				if not antiAfkEnabled or antiAfkGeneration ~= generation then
					break
				end

				activeAntiAfkHumanoid = humanoid
				humanoid:MoveTo(rootPart.Position - rootPart.CFrame.RightVector * 2)
			end
		end
	end)
end

local function getFarmContainer()
	for _, map in ipairs(CollectionService:GetTagged("CurrentMap")) do
		if map:IsA("Model") and map.Name ~= "Lobby" and map:IsDescendantOf(workspace) then
			local container = map:FindFirstChild("CoinContainer", true)
			return container or map, map
		end
	end

	local normal = workspace:FindFirstChild("Normal")
	if normal then
		local mapFolder = normal:FindFirstChild("Map")
		local activeMap = mapFolder and mapFolder:FindFirstChild("Map")
		local container = activeMap and activeMap:FindFirstChild("CoinContainer")
		if container then
			return container, activeMap
		end

		container = mapFolder and mapFolder:FindFirstChild("CoinContainer", true)
		if container then
			return container, container:FindFirstAncestorOfClass("Model")
		end

		container = normal:FindFirstChild("CoinContainer", true)
		if container then
			return container, container:FindFirstAncestorOfClass("Model")
		end
	end

	local container = workspace:FindFirstChild("CoinContainer", true)
	if container then
		return container, container:FindFirstAncestorOfClass("Model")
	end

	for _, coin in ipairs(CollectionService:GetTagged("ServerCoinPart")) do
		if coin:IsDescendantOf(workspace) then
			return workspace, nil
		end
	end
	for _, visual in ipairs(CollectionService:GetTagged("CoinVisual")) do
		if visual:IsDescendantOf(workspace) then
			return workspace, nil
		end
	end
	if workspace:FindFirstChild("Coin", true) then
		return workspace, nil
	end

	return nil, nil
end

local function getInventoryCount()
	local data = player:FindFirstChild("Data")
	local coinCount = data and data:FindFirstChild("Coin")
	if coinCount and coinCount:IsA("ValueBase") and typeof(coinCount.Value) == "number" then
		return coinCount.Value, nil, false
	end

	local playerGui = player:FindFirstChild("PlayerGui")
	local bag = playerGui
	for _, name in ipairs({ "MainGUI", "Game", "CoinBags", "Container", "Coin" }) do
		bag = bag and bag:FindFirstChild(name)
	end
	local label = bag and bag:FindFirstChild("CurrencyFrame")
	label = label and label:FindFirstChild("Icon")
	label = label and label:FindFirstChild("Coins")
	local full = bag and bag:FindFirstChild("Full")
	local bagFull = bag ~= nil and bag.Visible and full ~= nil and full.Visible

	if label and label:IsA("TextLabel") then
		local value = tonumber((label.Text:gsub(",", "")))
		if value and value >= 0 then
			return value, nil, bagFull
		end
	end

	local reason = not data and "Player.Data was not found"
		or (data and not coinCount and "Player.Data.Coin was not found")
		or "Coin inventory value and PlayerGui coin bag were not found"
	return nil, reason, bagFull
end

local function getFarmTargetPart(target)
	if target:IsA("BasePart") then
		return target
	end
	if target:IsA("Model") then
		return target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
	end
	return target:FindFirstChildWhichIsA("BasePart", true)
end

local function restoreFarmCollisions()
	if not farmCollisionStates then
		return
	end
	for part, canCollide in pairs(farmCollisionStates) do
		if part.Parent then
			part.CanCollide = canCollide
		end
	end
	farmCollisionStates = nil
end

local function stopFarmMovement()
	if activeFarmTween then
		activeFarmTween:Cancel()
		activeFarmTween = nil
	end
	if activeFarmHumanoid and activeFarmHumanoid.Parent then
		activeFarmHumanoid.AutoRotate = activeFarmAutoRotate
		activeFarmHumanoid.PlatformStand = activeFarmPlatformStand
		if activeFarmHumanoid.Health > 0 and not activeFarmPlatformStand then
			activeFarmHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
	activeFarmHumanoid = nil
	activeFarmAutoRotate = nil
	activeFarmPlatformStand = nil
	restoreFarmCollisions()
end

local function prepareFarmMovement(character, humanoid)
	if activeFarmHumanoid ~= humanoid then
		stopFarmMovement()
		activeFarmHumanoid = humanoid
		activeFarmAutoRotate = humanoid.AutoRotate
		activeFarmPlatformStand = humanoid.PlatformStand
	end

	farmCollisionStates = farmCollisionStates or {}
	for _, descendant in ipairs(character:GetDescendants()) do
		if descendant:IsA("BasePart") then
			if farmCollisionStates[descendant] == nil then
				farmCollisionStates[descendant] = descendant.CanCollide
			end
			descendant.CanCollide = false
		end
	end
	humanoid.AutoRotate = false
	humanoid.PlatformStand = true
end

local function isValidFarmTarget(target, targetPart, container)
	if not target or not targetPart or not target:IsDescendantOf(container)
		or not targetPart:IsDescendantOf(container) then
		return false
	end

	local coinId = target:GetAttribute("CoinID")
	local taggedCoin = CollectionService:HasTag(target, "ServerCoinPart")
	local visual = target:FindFirstChild("CoinVisual", true)
	local taggedVisual = CollectionService:HasTag(target, "CoinVisual")
		or (visual and CollectionService:HasTag(visual, "CoinVisual"))
	if coinId ~= nil and coinId ~= "Coin" then
		return false
	end
	if coinId ~= "Coin" and not taggedCoin and not taggedVisual and not visual and target.Name ~= "Coin" then
		return false
	end
	if target:GetAttribute("Collected") or target:GetAttribute("RoundEnd") or target:GetAttribute("Delete")
		or targetPart:GetAttribute("Collected") or targetPart:GetAttribute("RoundEnd")
		or targetPart:GetAttribute("Delete") then
		return false
	end

	if visual and visual:IsA("BasePart") then
		local transparency = 1 - (1 - visual.Transparency) * (1 - visual.LocalTransparencyModifier)
		if transparency >= 0.99 or visual:GetAttribute("Collected")
			or visual:GetAttribute("RoundEnd") or visual:GetAttribute("Delete") then
			return false
		end
	end
	return true
end

local function findNearestFarmTarget(rootPart, container, cooldowns)
	local nearestTarget
	local nearestPart
	local nearestDistance = math.huge
	local now = os.clock()
	local candidates = {}
	local seen = {}
	local function addCandidate(candidate)
		if candidate and not seen[candidate] then
			seen[candidate] = true
			candidates[#candidates + 1] = candidate
		end
	end

	for _, target in ipairs(CollectionService:GetTagged("ServerCoinPart")) do
		addCandidate(target)
	end
	for _, visual in ipairs(CollectionService:GetTagged("CoinVisual")) do
		addCandidate(visual.Parent)
	end
	for _, target in ipairs(container:GetDescendants()) do
		if target:GetAttribute("CoinID") == "Coin" or target.Name == "Coin" then
			addCandidate(target)
		end
	end

	for _, target in ipairs(candidates) do
		if (cooldowns[target] or 0) <= now then
			local targetPart = getFarmTargetPart(target)
			if isValidFarmTarget(target, targetPart, container) then
				local distance = (targetPart.Position - rootPart.Position).Magnitude
				if distance < nearestDistance then
					nearestTarget = target
					nearestPart = targetPart
					nearestDistance = distance
				end
			end
		end
	end

	return nearestTarget, nearestPart
end

local function moveFarmCharacter(rootPart, destination)
	local distance = (destination - rootPart.Position).Magnitude
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
	if distance <= 0.35 then
		return Enum.PlaybackState.Completed
	end

	local tween = TweenService:Create(
		rootPart,
		TweenInfo.new(math.max(distance / autoFarmTravelSpeed, 0.05), Enum.EasingStyle.Linear),
		{ CFrame = CFrame.new(destination) * rootPart.CFrame.Rotation }
	)
	activeFarmTween = tween
	tween:Play()
	local playbackState = tween.Completed:Wait()
	if activeFarmTween == tween then
		activeFarmTween = nil
	end
	return playbackState
end

local function setAutoFarmEnabled(enabled)
	autoFarmEnabled = enabled
	autoFarmGeneration += 1
	local generation = autoFarmGeneration
	local toggle = autoFarmToggleButton
	if toggle then
		local knob = toggle:FindFirstChild("ToggleKnob")
		TweenService:Create(toggle, toggleTransitionInfo, {
			BackgroundColor3 = enabled and colors.accent or colors.panelLight,
		}):Play()
		if knob then
			TweenService:Create(knob, toggleTransitionInfo, {
				Position = enabled and UDim2.new(1, -23, 0.5, 0)
					or UDim2.new(0, 3, 0.5, 0),
				BackgroundColor3 = enabled and colors.background or colors.text,
			}):Play()
		end
	end

	if not enabled then
		stopFarmMovement()
		return
	end

	task.spawn(function()
		local warnedAboutCount = false
		local warnedAboutContainer = false
		local currentTarget
		local cooldowns = {}
		while autoFarmEnabled and autoFarmGeneration == generation do
			local character = player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local container, map = getFarmContainer()

			if container then
				warnedAboutContainer = false
			elseif not warnedAboutContainer then
				warn("Coin AutoFarm paused: no active map or coin targets were found.")
				warnedAboutContainer = true
			end

			if map ~= activeFarmMap then
				stopFarmMovement()
				activeFarmMap = map
				currentTarget = nil
				table.clear(cooldowns)
			end

			local count, countError, bagFull = getInventoryCount()
			if count == nil then
				if not warnedAboutCount then
					warn(("Coin AutoFarm cannot read the bag count (%s); continuing without the bag-cap check.")
						:format(countError))
					warnedAboutCount = true
				end
			else
				warnedAboutCount = false
			end

			if not rootPart or not rootPart:IsA("BasePart")
				or not humanoid or humanoid.Health <= 0 or not container then
				stopFarmMovement()
				task.wait(0.25)
				continue
			end

			local roundTimer = workspace:FindFirstChild("RoundTimerPart")
			local remaining = roundTimer and roundTimer:GetAttribute("Time")
			if roundTimer and (type(remaining) ~= "number" or remaining <= 0 or remaining ~= remaining) then
				currentTarget = nil
				stopFarmMovement()
				task.wait(0.25)
				continue
			end

			if bagFull or (count and count >= 50) then
				currentTarget = nil
				stopFarmMovement()
				task.wait(0.5)
				continue
			end

			local selectedPart = currentTarget and getFarmTargetPart(currentTarget)
			if not isValidFarmTarget(currentTarget, selectedPart, container)
				or (cooldowns[currentTarget] or 0) > os.clock() then
				currentTarget, selectedPart = findNearestFarmTarget(rootPart, container, cooldowns)
			end

			if currentTarget and selectedPart then
				prepareFarmMovement(character, humanoid)
				local startingCount = count
				local destination = selectedPart.Position
					+ Vector3.new(0, (rootPart.Size.Y + selectedPart.Size.Y) / 2 - 0.05, 0)
				local targetRemovedConnection = currentTarget.AncestryChanged:Connect(function()
					if not currentTarget:IsDescendantOf(container) and activeFarmTween then
						activeFarmTween:Cancel()
					end
				end)
				local partRemovedConnection = selectedPart.AncestryChanged:Connect(function()
					if not selectedPart:IsDescendantOf(container) and activeFarmTween then
						activeFarmTween:Cancel()
					end
				end)
				local playbackState = moveFarmCharacter(rootPart, destination)
				targetRemovedConnection:Disconnect()
				partRemovedConnection:Disconnect()

				if autoFarmEnabled and autoFarmGeneration == generation
					and playbackState == Enum.PlaybackState.Completed
					and rootPart.Parent == character and humanoid.Health > 0
					and isValidFarmTarget(currentTarget, selectedPart, container) then
					task.wait(0.6)
					local updatedCount, _, updatedBagFull = getInventoryCount()
					if not isValidFarmTarget(currentTarget, selectedPart, container)
						or (updatedCount and startingCount and updatedCount > startingCount) then
						cooldowns[currentTarget] = nil
						currentTarget = nil
					elseif isValidFarmTarget(currentTarget, selectedPart, container) then
						cooldowns[currentTarget] = os.clock() + (updatedBagFull and 0.5 or 8)
						currentTarget = nil
					end
				end
			else
				currentTarget = nil
				stopFarmMovement()
				task.wait(0.25)
			end
		end

		if autoFarmGeneration == generation then
			stopFarmMovement()
		end
	end)
end

local function renderCards(cards)
	for _, child in ipairs(cardList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for index, card in ipairs(cards) do
		local cardFrame = create("Frame", {
			Name = "InfoCard" .. index,
			LayoutOrder = index,
			Size = UDim2.new(1, -8, 0, card.height or 72),
			BackgroundColor3 = Color3.fromRGB(17, 43, 63),
			BorderSizePixel = 0,
		}, cardList)
		create("UICorner", { CornerRadius = UDim.new(0, 9) }, cardFrame)
		create("UIStroke", {
			Color = Color3.fromRGB(31, 76, 103),
			Transparency = 0.2,
			Thickness = 1,
		}, cardFrame)
		create("TextLabel", {
			Name = "CardTitle",
			Position = UDim2.new(0, 13, 0, 9),
			Size = UDim2.new(1, -26, 0, 18),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Text = card.title,
			TextColor3 = colors.text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, cardFrame)
		create("TextLabel", {
			Name = "CardBody",
			Position = UDim2.new(0, 13, 0, 31),
			Size = UDim2.new(1, card.action and -150 or -26, 1, -38),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = card.body,
			TextColor3 = colors.muted,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, cardFrame)

		if card.action then
			local isAntiAfkToggle = card.action == "antiAfkToggle"
			local isAutoFarmToggle = card.action == "autoFarmToggle"
			local isToggle = isAntiAfkToggle or isAutoFarmToggle
			local isEnabled = isAntiAfkToggle and antiAfkEnabled
				or (isAutoFarmToggle and autoFarmEnabled or false)
			local actionButton = create("TextButton", {
				Name = "ActionButton",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 5),
				Size = isToggle and UDim2.fromOffset(48, 26) or UDim2.fromOffset(122, 34),
				BackgroundColor3 = isToggle and (isEnabled and colors.accent or colors.panelLight)
					or colors.panelLight,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = Enum.Font.GothamMedium,
				Text = isToggle and "" or card.buttonText,
				TextColor3 = colors.text,
				TextSize = 12,
			}, cardFrame)
			create("UICorner", {
				CornerRadius = UDim.new(0, isToggle and 13 or 7),
			}, actionButton)

			if card.action == "keybind" then
				menuKeybindButton = actionButton
				actionButton.Activated:Connect(function()
					waitingForMenuKey = true
					actionButton.Text = "Press a key..."
				end)
			elseif isToggle then
				local toggleKnob = create("Frame", {
					Name = "ToggleKnob",
					AnchorPoint = Vector2.new(0, 0.5),
					Position = isEnabled and UDim2.new(1, -23, 0.5, 0)
						or UDim2.new(0, 3, 0.5, 0),
					Size = UDim2.fromOffset(20, 20),
					BackgroundColor3 = isEnabled and colors.background or colors.text,
					BorderSizePixel = 0,
				}, actionButton)
				create("UICorner", { CornerRadius = UDim.new(1, 0) }, toggleKnob)
				if isAutoFarmToggle then
					autoFarmToggleButton = actionButton
				end
				actionButton.Activated:Connect(function()
					if isAntiAfkToggle then
						setAntiAfkEnabled(not antiAfkEnabled)
						local enabled = antiAfkEnabled
						TweenService:Create(actionButton, toggleTransitionInfo, {
							BackgroundColor3 = enabled and colors.accent or colors.panelLight,
						}):Play()
						TweenService:Create(toggleKnob, toggleTransitionInfo, {
							Position = enabled and UDim2.new(1, -23, 0.5, 0)
								or UDim2.new(0, 3, 0.5, 0),
							BackgroundColor3 = enabled and colors.background or colors.text,
						}):Play()
					else
						setAutoFarmEnabled(not autoFarmEnabled)
					end
				end)
			elseif card.action == "unload" then
				actionButton.Activated:Connect(function()
					setAntiAfkEnabled(false)
					setAutoFarmEnabled(false)
					if inputChangedConnection then
						inputChangedConnection:Disconnect()
					end
					if inputEndedConnection then
						inputEndedConnection:Disconnect()
					end
					if inputBeganConnection then
						inputBeganConnection:Disconnect()
					end
					if viewportConnection then
						viewportConnection:Disconnect()
					end
					screenGui:Destroy()
				end)
			end
		end
	end
	cardList.CanvasPosition = Vector2.zero
end

local sidebar = create("Frame", {
	Name = "Sections",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -22, 0, 84),
	Size = UDim2.new(0, 142, 1, -116),
	BackgroundTransparency = 1,
}, window)

create("TextLabel", {
	Name = "SectionsCaption",
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "SECTIONS",
	TextColor3 = colors.muted,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)

local buttonList = create("Frame", {
	Name = "ButtonList",
	Position = UDim2.new(0, 0, 0, 30),
	Size = UDim2.new(1, 0, 1, -30),
	BackgroundTransparency = 1,
}, sidebar)
create("UIListLayout", {
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, buttonList)

local versionLabel = create("TextLabel", {
	Name = "Version",
	Position = UDim2.new(0, 22, 1, -35),
	Size = UDim2.new(0, 140, 0, 18),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Version 0.1.0",
	TextColor3 = colors.muted,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
}, window)

local sections = {
	{
		name = "Home",
		cards = {
			{
				title = "About Project",
				body = "Simple MM2 script with a lot of functions for Farm, PvP, Playing and more!",
				height = 72,
			},
			{
				title = "Changelog",
				body = "Version - 0.1.0",
				height = 64,
			},
		},
	},
	{
		name = "Player",
		cards = {
			{
				title = "Player",
				body = "There are no settings in this section yet.",
				height = 64,
			},
		},
	},
	{
		name = "AutoFarm",
		cards = {
			{
				title = "Coin AutoFarm",
				body = "Automatically collect map coins. Pauses when the bag is full.",
				action = "autoFarmToggle",
				height = 82,
			},
		},
	},
	{
		name = "Visuals",
		cards = {
			{
				title = "Visuals",
				body = "There are no settings in this section yet.",
				height = 64,
			},
		},
	},
	{
		name = "Settings",
		cards = {
			{
				title = "Anti AFK",
				body = "Every 10 minutes, jump and move 2 studs to the left.",
				action = "antiAfkToggle",
				height = 82,
			},
			{
				title = "Menu Keybind",
				body = "Change the keyboard key used to show or hide the menu.",
				buttonText = menuKeyCode.Name,
				action = "keybind",
				height = 82,
			},
			{
				title = "Unload Client",
				body = "Remove the menu and the SC button.",
				buttonText = "Unload",
				action = "unload",
				height = 82,
			},
		},
	},
	{
		name = "About",
		cards = {
			{
				title = "About Project",
				body = "Simple MM2 script with a lot of functions for Farm, PvP, Playing and more!",
				height = 72,
			},
			{
				title = "Author",
				body = "Author of script: SpeedyFarm or KorchaginX",
				height = 64,
			},
			{
				title = "Socials",
				body = "Telegram channel:\nGithub: github.com/Korchagin060912X/SpeedyClient_lua",
				height = 76,
			},
		},
	},
}

inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if waitingForMenuKey then
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if input.KeyCode == Enum.KeyCode.Escape then
			waitingForMenuKey = false
			if menuKeybindButton then
				menuKeybindButton.Text = menuKeyCode.Name
			end
			return
		end
		if input.KeyCode == Enum.KeyCode.Unknown then
			return
		end
		if not input.KeyCode.Name:match("^[A-Z]$") then
			return
		end

		menuKeyCode = input.KeyCode
		waitingForMenuKey = false
		if menuKeybindButton then
			menuKeybindButton.Text = menuKeyCode.Name
		end
		return
	end

	if gameProcessed or UserInputService:GetFocusedTextBox() then
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == menuKeyCode then
		local shouldOpen = not menuIsOpen
		animateMenu(shouldOpen)
		launcher.Visible = not shouldOpen
	end
end)

local buttons = {}
local activeSection

local function selectSection(section, button)
	if activeSection then
		TweenService:Create(activeSection, TweenInfo.new(0.15), {
			BackgroundColor3 = colors.panel,
			TextColor3 = colors.muted,
		}):Play()
	end

	activeSection = button
	TweenService:Create(button, TweenInfo.new(0.15), {
		BackgroundColor3 = colors.accent,
		TextColor3 = colors.text,
	}):Play()

	sectionTitle.Text = section.name
	renderCards(section.cards)
end

for index, section in ipairs(sections) do
	local button = create("TextButton", {
		Name = section.name .. "Button",
		LayoutOrder = index,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = colors.panel,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = section.name,
		TextColor3 = colors.muted,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, buttonList)
	create("UICorner", { CornerRadius = UDim.new(0, 8) }, button)
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 13),
	}, button)

	button.MouseEnter:Connect(function()
		if button ~= activeSection then
			TweenService:Create(button, TweenInfo.new(0.12), {
				BackgroundColor3 = colors.panelLight,
			}):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		if button ~= activeSection then
			TweenService:Create(button, TweenInfo.new(0.12), {
				BackgroundColor3 = colors.panel,
			}):Play()
		end
	end)
	button.Activated:Connect(function()
		selectSection(section, button)
	end)

	table.insert(buttons, button)
end

selectSection(sections[1], buttons[1])
