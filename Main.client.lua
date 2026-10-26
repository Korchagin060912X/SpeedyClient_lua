local Players = game:GetService("Players")
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
local autoFarmEnabled = { Coin = false, Candy = false }
local autoFarmSpeed = 40
local autoFarmRunning = false
local activeFarmTween
local activeFarmHumanoid
local activeFarmWalkSpeed
local farmCollisionStates
local sliderDragUpdate
local autoFarmToggleButtons = {}

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
		if sliderDragUpdate then
			sliderDragUpdate(input.Position.X)
		end
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
		sliderDragUpdate = nil
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
	local normal = workspace:FindFirstChild("Normal")
	if not normal then
		return nil
	end

	local mapFolder = normal:FindFirstChild("Map")
	local activeMap = mapFolder and mapFolder:FindFirstChild("Map")
	local container = activeMap and activeMap:FindFirstChild("CoinContainer")
	if container then
		return container
	end

	container = mapFolder and mapFolder:FindFirstChild("CoinContainer", true)
	if container then
		return container
	end

	return normal:FindFirstChild("CoinContainer", true)
end

local function getInventoryCount(itemType)
	local data = player:FindFirstChild("Data")
	local coinCount = data and data:FindFirstChild("Coin")
	if coinCount and (coinCount:IsA("IntValue") or coinCount:IsA("NumberValue")) then
		return coinCount.Value
	end

	return nil
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

local function restoreFarmWalkSpeed()
	if activeFarmHumanoid and activeFarmHumanoid.Parent and activeFarmWalkSpeed then
		activeFarmHumanoid.WalkSpeed = activeFarmWalkSpeed
	end
	activeFarmHumanoid = nil
	activeFarmWalkSpeed = nil
end

local function stopFarmMovement()
	if activeFarmTween then
		activeFarmTween:Cancel()
	end
	if activeFarmHumanoid and activeFarmHumanoid.Parent then
		local rootPart = activeFarmHumanoid.Parent:FindFirstChild("HumanoidRootPart")
		if rootPart and rootPart:IsA("BasePart") then
			activeFarmHumanoid:MoveTo(rootPart.Position)
		end
	end
	restoreFarmWalkSpeed()
	restoreFarmCollisions()
end

local function setFarmCharacterCollision(character, enabled)
	if not enabled then
		restoreFarmCollisions()
		farmCollisionStates = {}
		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("BasePart") then
				farmCollisionStates[descendant] = descendant.CanCollide
				descendant.CanCollide = false
			end
		end
	else
		restoreFarmCollisions()
	end
end

local function findNearestFarmTarget(itemType, rootPart, container)
	local nearestTarget
	local nearestPart
	local nearestDistance = math.huge

	for _, target in ipairs(container:GetDescendants()) do
		if target.Name == itemType and target:IsDescendantOf(container) then
			local targetPart = getFarmTargetPart(target)
			if targetPart and targetPart:IsDescendantOf(container) then
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

local function setAutoFarmEnabled(itemType, enabled)
	autoFarmEnabled[itemType] = enabled
	local toggle = autoFarmToggleButtons[itemType]
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
	end

	if not autoFarmEnabled.Coin and not autoFarmEnabled.Candy then
		stopFarmMovement()
		return
	end

	if autoFarmRunning then
		return
	end

	autoFarmRunning = true
	task.spawn(function()
		local warnedAboutCount = {}
		local warnedAboutContainer = false
		while autoFarmEnabled.Coin or autoFarmEnabled.Candy do
			local character = player.Character
			local rootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local container = getFarmContainer()
			local availableTypes = {}

			if container then
				warnedAboutContainer = false
			elseif not warnedAboutContainer then
				local normal = workspace:FindFirstChild("Normal")
				local mapFolder = normal and normal:FindFirstChild("Map")
				if not normal then
					warn("AutoFarm paused: workspace.Normal was not found.")
				elseif not mapFolder then
					warn("AutoFarm paused: workspace.Normal.Map was not found.")
				else
					warn("AutoFarm paused: no CoinContainer found inside workspace.Normal.Map.")
				end
				warnedAboutContainer = true
			end

			if rootPart and rootPart:IsA("BasePart") and humanoid and humanoid.Health > 0 and container then
				for _, itemType in ipairs({ "Coin", "Candy" }) do
					if autoFarmEnabled[itemType] then
						local count = getInventoryCount(itemType)
						if count == nil then
							if not warnedAboutCount[itemType] then
								warn(("AutoFarm paused: expected a numeric Player.Data.Coin value for %s inventory."):format(itemType))
								warnedAboutCount[itemType] = true
							end
						elseif count < 50 then
							table.insert(availableTypes, itemType)
						end
					end
				end
			end

			local selectedTarget
			local selectedPart
			local selectedDistance = math.huge
			for _, itemType in ipairs(availableTypes) do
				local target, targetPart = findNearestFarmTarget(itemType, rootPart, container)
				if targetPart then
					local distance = (targetPart.Position - rootPart.Position).Magnitude
					if distance < selectedDistance then
						selectedTarget = target
						selectedPart = targetPart
						selectedDistance = distance
					end
				end
			end

			if selectedTarget and selectedPart
				and selectedTarget:IsDescendantOf(container)
				and selectedPart:IsDescendantOf(container) then
				local touchPosition = selectedPart.Position
					+ Vector3.new(0, (rootPart.Size.Y + selectedPart.Size.Y) / 2 - 0.05, 0)
				local approachDirection = Vector3.new(
					rootPart.Position.X - selectedPart.Position.X,
					0,
					rootPart.Position.Z - selectedPart.Position.Z
				)
				if approachDirection.Magnitude < 0.01 then
					approachDirection = Vector3.new(1, 0, 0)
				else
					approachDirection = approachDirection.Unit
				end
				local tweenPosition = touchPosition + approachDirection * 2
				local tweenDistance = (tweenPosition - rootPart.Position).Magnitude

				setFarmCharacterCollision(character, false)
				local tween = TweenService:Create(
					rootPart,
					TweenInfo.new(math.max(tweenDistance / autoFarmSpeed, 0.05), Enum.EasingStyle.Linear),
					{ CFrame = CFrame.new(tweenPosition) * rootPart.CFrame.Rotation }
				)
				activeFarmTween = tween
				local targetRemovedConnection = selectedTarget.AncestryChanged:Connect(function()
					if not selectedTarget:IsDescendantOf(container) then
						tween:Cancel()
					end
				end)
				local partRemovedConnection = selectedPart.AncestryChanged:Connect(function()
					if not selectedPart:IsDescendantOf(container) then
						tween:Cancel()
					end
				end)
				tween:Play()
				local playbackState = tween.Completed:Wait()
				targetRemovedConnection:Disconnect()
				partRemovedConnection:Disconnect()
				if activeFarmTween == tween then
					activeFarmTween = nil
				end
				restoreFarmCollisions()

				if playbackState == Enum.PlaybackState.Completed
					and selectedTarget:IsDescendantOf(container)
					and selectedPart:IsDescendantOf(container)
					and rootPart.Parent == character
					and humanoid.Health > 0
					and (autoFarmEnabled.Coin or autoFarmEnabled.Candy) then
					activeFarmHumanoid = humanoid
					activeFarmWalkSpeed = humanoid.WalkSpeed
					humanoid.WalkSpeed = autoFarmSpeed
					humanoid:MoveTo(touchPosition)
					local reachedTarget = humanoid.MoveToFinished:Wait()
					restoreFarmWalkSpeed()
					if reachedTarget and (autoFarmEnabled.Coin or autoFarmEnabled.Candy) then
						task.wait(0.6)
					end
				end
			else
				task.wait(0.25)
			end
		end

		if activeFarmTween then
			activeFarmTween:Cancel()
			activeFarmTween = nil
		end
		stopFarmMovement()
		restoreFarmCollisions()
		autoFarmRunning = false
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

		if card.action == "autoFarmSpeed" then
			local valueLabel = create("TextLabel", {
				Name = "SpeedValue",
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -14, 0, 29),
				Size = UDim2.fromOffset(130, 16),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamMedium,
				Text = tostring(autoFarmSpeed) .. " /s",
				TextColor3 = colors.text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,
			}, cardFrame)
			local sliderTrack = create("TextButton", {
				Name = "SpeedSlider",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0, 59),
				Size = UDim2.fromOffset(130, 6),
				BackgroundColor3 = colors.border,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
			}, cardFrame)
			create("UICorner", { CornerRadius = UDim.new(1, 0) }, sliderTrack)
			local sliderFill = create("Frame", {
				Name = "SliderFill",
				Size = UDim2.new((autoFarmSpeed - 1) / 99, 0, 1, 0),
				BackgroundColor3 = colors.accent,
				BorderSizePixel = 0,
			}, sliderTrack)
			create("UICorner", { CornerRadius = UDim.new(1, 0) }, sliderFill)
			local sliderKnob = create("Frame", {
				Name = "SliderKnob",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new((autoFarmSpeed - 1) / 99, 0, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),
				BackgroundColor3 = colors.text,
				BorderSizePixel = 0,
			}, sliderTrack)
			create("UICorner", { CornerRadius = UDim.new(1, 0) }, sliderKnob)

			local function updateSlider(positionX)
				local width = sliderTrack.AbsoluteSize.X
				if width <= 0 then
					return
				end
				local progress = math.clamp(
					(positionX - sliderTrack.AbsolutePosition.X) / width,
					0,
					1
				)
				autoFarmSpeed = math.clamp(math.floor(1 + progress * 99 + 0.5), 1, 100)
				local normalizedSpeed = (autoFarmSpeed - 1) / 99
				valueLabel.Text = tostring(autoFarmSpeed) .. " /s"
				sliderFill.Size = UDim2.new(normalizedSpeed, 0, 1, 0)
				sliderKnob.Position = UDim2.new(normalizedSpeed, 0, 0.5, 0)
			end

			sliderTrack.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					sliderDragUpdate = updateSlider
					updateSlider(input.Position.X)
				end
			end)
		elseif card.action then
			local isAntiAfkToggle = card.action == "antiAfkToggle"
			local isAutoFarmToggle = card.action == "autoFarmToggle"
			local isToggle = isAntiAfkToggle or isAutoFarmToggle
			local isEnabled = isAntiAfkToggle and antiAfkEnabled
				or (isAutoFarmToggle and autoFarmEnabled[card.toggleKey] or false)
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
					autoFarmToggleButtons[card.toggleKey] = actionButton
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
						setAutoFarmEnabled(card.toggleKey, not autoFarmEnabled[card.toggleKey])
					end
				end)
			elseif card.action == "unload" then
				actionButton.Activated:Connect(function()
					setAntiAfkEnabled(false)
					setAutoFarmEnabled("Coin", false)
					setAutoFarmEnabled("Candy", false)
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
				body = "Automatically collect Coin objects from the map.",
				action = "autoFarmToggle",
				toggleKey = "Coin",
				height = 82,
			},
			{
				title = "Candy AutoFarm",
				body = "Automatically collect Candy objects from the map.",
				action = "autoFarmToggle",
				toggleKey = "Candy",
				height = 82,
			},
			{
				title = "AutoFarm Speed",
				body = "Movement speed (1-100 studs per second).",
				action = "autoFarmSpeed",
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
