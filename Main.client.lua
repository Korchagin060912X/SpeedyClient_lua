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

local sizeConstraint = create("UISizeConstraint", {
	MinSize = Vector2.new(340, 300),
	MaxSize = Vector2.new(900, 600),
}, window)

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
	window.Visible = true
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
	window.Visible = false
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
			local actionButton = create("TextButton", {
				Name = "ActionButton",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 5),
				Size = UDim2.fromOffset(122, 34),
				BackgroundColor3 = colors.panelLight,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Font = Enum.Font.GothamMedium,
				Text = card.action == "antiAfk"
					and (antiAfkEnabled and "ON" or "OFF")
					or card.buttonText,
				TextColor3 = colors.text,
				TextSize = 12,
			}, cardFrame)
			create("UICorner", { CornerRadius = UDim.new(0, 7) }, actionButton)

			if card.action == "keybind" then
				menuKeybindButton = actionButton
				actionButton.Activated:Connect(function()
					waitingForMenuKey = true
					actionButton.Text = "Press a key..."
				end)
			elseif card.action == "antiAfk" then
				actionButton.Activated:Connect(function()
					setAntiAfkEnabled(not antiAfkEnabled)
					actionButton.Text = antiAfkEnabled and "ON" or "OFF"
				end)
			elseif card.action == "unload" then
				actionButton.Activated:Connect(function()
					setAntiAfkEnabled(false)
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
	Position = UDim2.new(1, -22, 0, 92),
	Size = UDim2.new(0, 142, 1, -140),
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
	Position = UDim2.new(0, 0, 0, 34),
	Size = UDim2.new(1, 0, 1, -34),
	BackgroundTransparency = 1,
}, sidebar)
create("UIListLayout", {
	Padding = UDim.new(0, 8),
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
				buttonText = "OFF",
				action = "antiAfk",
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
		local shouldOpen = not window.Visible
		window.Visible = shouldOpen
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
		Size = UDim2.new(1, 0, 0, 40),
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
