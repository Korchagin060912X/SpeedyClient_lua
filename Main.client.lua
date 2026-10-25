local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local colors = {
	background = Color3.fromRGB(15, 17, 24),
	panel = Color3.fromRGB(22, 25, 34),
	panelLight = Color3.fromRGB(29, 33, 44),
	border = Color3.fromRGB(47, 52, 67),
	text = Color3.fromRGB(239, 241, 248),
	muted = Color3.fromRGB(144, 151, 170),
	accent = Color3.fromRGB(133, 105, 255),
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

local window = create("Frame", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(760, 470),
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
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local header = create("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 72),
	BackgroundTransparency = 1,
}, window)

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
	Text = "Главная",
	TextColor3 = colors.text,
	TextSize = 19,
	TextXAlignment = Enum.TextXAlignment.Left,
}, content)

local sectionDescription = create("TextLabel", {
	Name = "SectionDescription",
	Position = UDim2.new(0, 24, 0, 60),
	Size = UDim2.new(1, -48, 0, 60),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Выберите раздел справа.",
	TextColor3 = colors.muted,
	TextSize = 14,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}, content)

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
	Text = "РАЗДЕЛЫ",
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
	Text = "version 0.0.0",
	TextColor3 = colors.muted,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
}, window)

local sections = {
	{
		name = "Главная",
		description = "Выберите раздел справа.",
	},
	{
		name = "Player",
		description = "В этом разделе пока нет настроек.",
	},
	{
		name = "Visuals",
		description = "В этом разделе пока нет настроек.",
	},
	{
		name = "About",
		description = "Speedy Client\nИнтерфейс находится в разработке.",
	},
}

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
	sectionDescription.Text = section.description
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
