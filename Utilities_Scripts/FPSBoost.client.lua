local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local guiName = "SpeedyClientFPSBoostUI"
local toggleActionName = "SpeedyClientFPSBoostMenu"

ContextActionService:UnbindAction(toggleActionName)
local previousGui = playerGui:FindFirstChild(guiName)
if previousGui then
	previousGui:Destroy()
end

local colors = {
	background = Color3.fromRGB(9, 15, 27),
	panel = Color3.fromRGB(14, 23, 40),
	panelLight = Color3.fromRGB(21, 34, 57),
	border = Color3.fromRGB(37, 55, 82),
	text = Color3.fromRGB(235, 241, 250),
	muted = Color3.fromRGB(139, 157, 183),
	accent = Color3.fromRGB(48, 105, 190),
	green = Color3.fromRGB(86, 190, 139),
	toggleOff = Color3.fromRGB(82, 91, 107),
	toggleOn = Color3.fromRGB(235, 242, 250),
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
	Name = guiName,
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local window = create("Frame", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(620, 380),
	BackgroundColor3 = colors.background,
	BorderSizePixel = 0,
}, screenGui)
create("UICorner", { CornerRadius = UDim.new(0, 14) }, window)
local windowStroke = create("UIStroke", {
	Color = colors.border,
	Transparency = 0.15,
	Thickness = 1,
}, window)
create("UISizeConstraint", {
	MinSize = Vector2.new(340, 280),
	MaxSize = Vector2.new(760, 520),
}, window)

local windowScale = create("UIScale", { Scale = 1 }, window)
local camera = workspace.CurrentCamera
local function updateScale()
	camera = workspace.CurrentCamera
	if camera then
		local viewport = camera.ViewportSize
		windowScale.Scale = math.max(0.35, math.min(1, (viewport.X - 24) / 620, (viewport.Y - 24) / 380))
	end
end
updateScale()
local viewportConnection
local launcherDragConnection
local launcherEndConnection
if camera then
	viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
screenGui.Destroying:Connect(function()
	if viewportConnection then
		viewportConnection:Disconnect()
	end
end)

local header = create("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 72),
	BackgroundTransparency = 1,
}, window)

local logo = create("Frame", {
	Name = "Logo",
	Position = UDim2.new(0, 22, 0.5, -17),
	Size = UDim2.fromOffset(34, 34),
	BackgroundColor3 = colors.accent,
	BorderSizePixel = 0,
}, header)
create("UICorner", { CornerRadius = UDim.new(0, 9) }, logo)
create("TextLabel", {
	Name = "LogoText",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "SC",
	TextColor3 = colors.text,
	TextSize = 13,
}, logo)

create("TextLabel", {
	Name = "Title",
	Position = UDim2.new(0, 68, 0, 0),
	Size = UDim2.new(1, -140, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamBold,
	Text = "Speedy Client",
	TextColor3 = colors.text,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Left,
}, header)

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

create("Frame", {
	Name = "HeaderDivider",
	Position = UDim2.new(0, 22, 1, -1),
	Size = UDim2.new(1, -44, 0, 1),
	BackgroundColor3 = colors.border,
	BorderSizePixel = 0,
}, header)

local sidebar = create("Frame", {
	Name = "Sidebar",
	Position = UDim2.new(0, 18, 0, 88),
	Size = UDim2.new(0, 150, 1, -106),
	BackgroundColor3 = colors.panel,
	BorderSizePixel = 0,
}, window)
create("UICorner", { CornerRadius = UDim.new(0, 11) }, sidebar)
create("UIStroke", {
	Color = colors.border,
	Transparency = 0.35,
	Thickness = 1,
}, sidebar)

create("TextLabel", {
	Name = "SectionLabel",
	Position = UDim2.new(0, 16, 0, 17),
	Size = UDim2.new(1, -32, 0, 18),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamSemibold,
	Text = "MENU",
	TextColor3 = colors.muted,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)

local function createSidebarTab(name, yPosition, isSelected)
	local button = create("TextButton", {
		Name = name .. "Tab",
		Position = UDim2.new(0, 10, 0, yPosition),
		Size = UDim2.new(1, -20, 0, 36),
		BackgroundColor3 = isSelected and colors.accent or colors.panel,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = "  " .. name,
		TextColor3 = isSelected and colors.text or colors.muted,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, sidebar)
	create("UICorner", { CornerRadius = UDim.new(0, 8) }, button)
	return button
end

local fpsBoostTab = createSidebarTab("FPS Boost", 45, true)
local settingsTab = createSidebarTab("Settings", 87, false)

create("TextLabel", {
	Name = "VersionLabel",
	Position = UDim2.new(0, 16, 0, 138),
	Size = UDim2.new(1, -32, 0, 18),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Version: 1.03.00",
	TextColor3 = colors.muted,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
}, sidebar)

local content = create("Frame", {
	Name = "Content",
	Position = UDim2.new(0, 182, 0, 88),
	Size = UDim2.new(1, -200, 1, -106),
	BackgroundColor3 = colors.panel,
	BorderSizePixel = 0,
}, window)
create("UICorner", { CornerRadius = UDim.new(0, 11) }, content)
create("UIStroke", {
	Color = colors.border,
	Transparency = 0.35,
	Thickness = 1,
}, content)

local pageTitle = create("TextLabel", {
	Name = "PageTitle",
	Position = UDim2.new(0, 24, 0, 20),
	Size = UDim2.new(1, -48, 0, 28),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamSemibold,
	Text = "FPS Boost",
	TextColor3 = colors.text,
	TextSize = 19,
	TextXAlignment = Enum.TextXAlignment.Left,
}, content)

local statusCard = create("Frame", {
	Name = "StatusCard",
	Position = UDim2.new(0, 20, 0, 58),
	Size = UDim2.new(1, -40, 0, 42),
	BackgroundColor3 = colors.panelLight,
	BorderSizePixel = 0,
}, content)
create("UICorner", { CornerRadius = UDim.new(0, 10) }, statusCard)
create("UIStroke", {
	Color = colors.border,
	Transparency = 0.45,
	Thickness = 1,
}, statusCard)

local sectionHeading = create("TextLabel", {
	Name = "FeatureHeading",
	Position = UDim2.new(0, 14, 0, 0),
	Size = UDim2.new(1, -28, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Performance options",
	TextColor3 = colors.muted,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
}, statusCard)

local featureList = create("ScrollingFrame", {
	Name = "FeatureList",
	Position = UDim2.new(0, 12, 0, 108),
	Size = UDim2.new(1, -24, 1, -148),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = colors.accent,
}, content)
create("UIListLayout", {
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, featureList)

local settingsList = create("ScrollingFrame", {
	Name = "SettingsList",
	Position = UDim2.new(0, 12, 0, 108),
	Size = UDim2.new(1, -24, 1, -148),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = colors.accent,
	Visible = false,
}, content)
create("UIListLayout", {
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, settingsList)

local function createSettingsRow(order, title, value, height)
	local row = create("Frame", {
		Name = title:gsub("%W", "") .. "Info",
		LayoutOrder = order,
		Size = UDim2.new(1, -2, 0, height or 48),
		BackgroundColor3 = colors.panelLight,
		BorderSizePixel = 0,
	}, settingsList)
	create("UICorner", { CornerRadius = UDim.new(0, 9) }, row)
	create("UIStroke", {
		Color = colors.border,
		Transparency = 0.55,
		Thickness = 1,
	}, row)
	create("TextLabel", {
		Name = "Title",
		Position = UDim2.new(0, 12, 0, 5),
		Size = UDim2.new(1, -24, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = colors.text,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	if value ~= nil then
		create("TextLabel", {
			Name = "Value",
			Position = UDim2.new(0, 12, 0, 22),
			Size = UDim2.new(1, -24, 0, (height or 48) - 25),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = value,
			TextColor3 = colors.muted,
			TextSize = 10,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, row)
	end
	return row
end

createSettingsRow(1, "About", nil, 32)
createSettingsRow(2, "Made by:", "SpeedyFarm & KorchaginX")
createSettingsRow(3, "Menu by:", "SpeedyFarm")
createSettingsRow(4, "Github:", "https://github.com/Korchagin060912X/SpeedyClient_lua", 54)
createSettingsRow(5, "Telegram:", "")

local unloadRow = create("Frame", {
	Name = "UnloadScriptRow",
	LayoutOrder = 6,
	Size = UDim2.new(1, -2, 0, 64),
	BackgroundColor3 = colors.panelLight,
	BorderSizePixel = 0,
}, settingsList)
create("UICorner", { CornerRadius = UDim.new(0, 9) }, unloadRow)
create("UIStroke", {
	Color = colors.border,
	Transparency = 0.55,
	Thickness = 1,
}, unloadRow)
create("TextLabel", {
	Name = "UnloadDescription",
	Position = UDim2.new(0, 12, 0, 0),
	Size = UDim2.new(1, -108, 1, 0),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Unload script and restore changed settings.",
	TextColor3 = colors.muted,
	TextSize = 10,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
}, unloadRow)
local unloadButton = create("TextButton", {
	Name = "UnloadButton",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -10, 0.5, 0),
	Size = UDim2.fromOffset(82, 32),
	BackgroundColor3 = Color3.fromRGB(105, 47, 57),
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamSemibold,
	Text = "Unload script",
	TextColor3 = colors.text,
	TextSize = 11,
}, unloadRow)
create("UICorner", { CornerRadius = UDim.new(0, 8) }, unloadButton)

local statusLabel = create("TextLabel", {
	Name = "Status",
	Position = UDim2.new(0, 14, 1, -30),
	Size = UDim2.new(1, -28, 0, 18),
	BackgroundTransparency = 1,
	Font = Enum.Font.Gotham,
	Text = "Ready",
	TextColor3 = colors.muted,
	TextSize = 10,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left,
}, content)

local function setStatus(message, isError)
	statusLabel.Text = message
	statusLabel.TextColor3 = isError and Color3.fromRGB(255, 145, 145) or colors.muted
end

local fpsViewerFrameCount = 0
local fpsViewerElapsed = 0
local fpsViewerConnection
local fpsViewerDragConnection
local fpsViewerEndConnection
local lowGraphicsOriginalQuality
local lowPolyOriginals = {}
local lowPolyConnection
local fpsUnlockOriginalCap
local threeDRenderingDisabled = false
local threeDUsesEngineSwitch = false
local threeDOriginals = {}
local threeDConnection

local fpsViewer = create("TextLabel", {
	Name = "FPSViewer",
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.new(0, 18, 0, 60),
	Size = UDim2.fromOffset(150, 34),
	BackgroundColor3 = Color3.fromRGB(8, 12, 20),
	BorderSizePixel = 0,
	Font = Enum.Font.GothamSemibold,
	Text = "SC | FPS: --",
	TextColor3 = Color3.fromRGB(110, 155, 198),
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Center,
	Visible = false,
	ZIndex = 10,
	Active = true,
}, screenGui)
create("UICorner", { CornerRadius = UDim.new(0, 9) }, fpsViewer)
create("UIStroke", {
	Color = colors.border,
	Transparency = 0.25,
	Thickness = 1,
}, fpsViewer)

local fpsViewerDragging = false
local fpsViewerDragStart
local fpsViewerStartPosition
fpsViewer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		fpsViewerDragging = true
		fpsViewerDragStart = input.Position
		fpsViewerStartPosition = fpsViewer.Position
	end
end)
fpsViewerDragConnection = UserInputService.InputChanged:Connect(function(input)
	if not fpsViewerDragging or not fpsViewerDragStart or not fpsViewerStartPosition then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - fpsViewerDragStart
	fpsViewer.Position = UDim2.new(
		fpsViewerStartPosition.X.Scale,
		fpsViewerStartPosition.X.Offset + delta.X,
		fpsViewerStartPosition.Y.Scale,
		fpsViewerStartPosition.Y.Offset + delta.Y
	)
end)
fpsViewerEndConnection = UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		fpsViewerDragging = false
		fpsViewerDragStart = nil
		fpsViewerStartPosition = nil
	end
end)

local function setFPSViewerEnabled(enabled)
	fpsViewer.Visible = enabled
	if fpsViewerConnection then
		fpsViewerConnection:Disconnect()
		fpsViewerConnection = nil
	end
	fpsViewerFrameCount = 0
	fpsViewerElapsed = 0

	if enabled then
		fpsViewerConnection = RunService.RenderStepped:Connect(function(deltaTime)
			fpsViewerFrameCount += 1
			fpsViewerElapsed += deltaTime
			if fpsViewerElapsed >= 0.5 then
				local fps = math.floor(fpsViewerFrameCount / fpsViewerElapsed + 0.5)
				fpsViewer.Text = ("SC | FPS: %d"):format(fps)
				fpsViewerFrameCount = 0
				fpsViewerElapsed = 0
			end
		end)
	end
	return true, enabled and "FPS Viewer enabled" or "FPS Viewer disabled"
end

local function setFPSUnlockerEnabled(enabled)
	local environment = _G
	if type(getgenv) == "function" then
		local success, result = pcall(getgenv)
		if success and type(result) == "table" then
			environment = result
		end
	end

	local setFPSCap = environment.setfpscap
	local getFPSCap = environment.getfpscap
	if type(setFPSCap) ~= "function" then
		return false, "FPS Unlocker unavailable: client does not expose setfpscap"
	end

	if enabled then
		if type(getFPSCap) == "function" then
			local success, cap = pcall(getFPSCap)
			if not success or type(cap) ~= "number" then
				return false, "FPS Unlocker unavailable: could not read current FPS cap"
			end
			fpsUnlockOriginalCap = cap
		else
			fpsUnlockOriginalCap = 60
		end

		local success, errorMessage = pcall(setFPSCap, 999)
		if not success then
			fpsUnlockOriginalCap = nil
			return false, ("FPS Unlocker failed: %s"):format(tostring(errorMessage))
		end
		return true, "FPS cap raised; actual FPS depends on device and display"
	end

	if fpsUnlockOriginalCap == nil then
		return true, "FPS Unlocker disabled"
	end
	local success, errorMessage = pcall(setFPSCap, fpsUnlockOriginalCap)
	if not success then
		return false, ("Could not restore the previous FPS cap: %s"):format(tostring(errorMessage))
	end
	fpsUnlockOriginalCap = nil
	return true, "Previous FPS cap restored"
end

local function setLowGraphicsEnabled(enabled)
	local settingsSuccess, gameSettings = pcall(function()
		return UserSettings().GameSettings
	end)
	if not settingsSuccess then
		return false, ("Low Graphics unavailable: %s"):format(tostring(gameSettings))
	end
	if enabled then
		local readSuccess, originalQuality = pcall(function()
			return gameSettings.SavedQualityLevel
		end)
		if not readSuccess then
			return false, ("Low Graphics unavailable: %s"):format(tostring(originalQuality))
		end
		lowGraphicsOriginalQuality = originalQuality
		local success, errorMessage = pcall(function()
			gameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
		end)
		if not success then
			lowGraphicsOriginalQuality = nil
			return false, ("Low Graphics unavailable: %s"):format(tostring(errorMessage))
		end
		return true, "Roblox graphics quality set to minimum"
	end

	if lowGraphicsOriginalQuality == nil then
		return true, "Low Graphics disabled"
	end
	local originalQuality = lowGraphicsOriginalQuality
	local success, errorMessage = pcall(function()
		gameSettings.SavedQualityLevel = originalQuality
	end)
	if not success then
		return false, ("Could not restore graphics quality: %s"):format(tostring(errorMessage))
	end
	lowGraphicsOriginalQuality = nil
	return true, "Previous graphics quality restored"
end

local function applyLowPoly(instance)
	if instance:IsA("BasePart") and lowPolyOriginals[instance] == nil then
		local original = {
			kind = "Material",
			material = instance.Material,
			materialVariant = instance.MaterialVariant,
		}
		if instance:IsA("MeshPart") then
			local textureSuccess, textureId = pcall(function()
				return instance.TextureID
			end)
			if textureSuccess then
				local clearSuccess = pcall(function()
					instance.TextureID = ""
				end)
				if clearSuccess then
					original.textureId = textureId
				end
			end
		end
		lowPolyOriginals[instance] = original
		instance.Material = Enum.Material.Plastic
		instance.MaterialVariant = ""
	elseif instance:IsA("SurfaceAppearance") and lowPolyOriginals[instance] == nil then
		local original = { kind = "Appearance" }
		for _, property in ipairs({ "ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap" }) do
			original[property] = instance[property]
			instance[property] = ""
		end
		lowPolyOriginals[instance] = original
	elseif (instance:IsA("Decal") or instance:IsA("Texture"))
		and lowPolyOriginals[instance] == nil then
		lowPolyOriginals[instance] = {
			kind = "Transparency",
			transparency = instance.Transparency,
		}
		instance.Transparency = 1
	end
end

local function restoreLowPoly()
	if lowPolyConnection then
		lowPolyConnection:Disconnect()
		lowPolyConnection = nil
	end
	for instance, original in pairs(lowPolyOriginals) do
		if instance.Parent then
			if original.kind == "Material" then
				instance.Material = original.material
				instance.MaterialVariant = original.materialVariant
				if original.textureId ~= nil then
					instance.TextureID = original.textureId
				end
			elseif original.kind == "Appearance" then
				for _, property in ipairs({ "ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap" }) do
					instance[property] = original[property]
				end
			else
				instance.Transparency = original.transparency
			end
		end
		lowPolyOriginals[instance] = nil
	end
end

local function setLowPolyEnabled(enabled)
	if enabled then
		table.clear(lowPolyOriginals)
		for _, instance in ipairs(workspace:GetDescendants()) do
			applyLowPoly(instance)
		end
		lowPolyConnection = workspace.DescendantAdded:Connect(applyLowPoly)
		return true, "World materials simplified locally"
	end

	restoreLowPoly()
	return true, "Original world materials restored"
end

local function set3DRenderingEnabled(enabled)
	if enabled and not threeDRenderingDisabled then
		local success = pcall(function()
			RunService:Set3dRenderingEnabled(false)
		end)
		if success then
			threeDUsesEngineSwitch = true
			threeDRenderingDisabled = true
			return true, "3D rendering disabled; the world may appear blank"
		end

		local function hide3DInstance(instance)
			if instance:IsA("BasePart") and threeDOriginals[instance] == nil then
				threeDOriginals[instance] = {
					kind = "Transparency",
					value = instance.LocalTransparencyModifier,
				}
				instance.LocalTransparencyModifier = 1
			elseif (instance:IsA("ParticleEmitter")
				or instance:IsA("Trail")
				or instance:IsA("Beam")
				or instance:IsA("Fire")
				or instance:IsA("Smoke")
				or instance:IsA("Sparkles")
				or instance:IsA("Highlight")
				or instance:IsA("PointLight")
				or instance:IsA("SpotLight")
				or instance:IsA("SurfaceLight"))
				and threeDOriginals[instance] == nil then
				threeDOriginals[instance] = {
					kind = "Enabled",
					value = instance.Enabled,
				}
				instance.Enabled = false
			end
		end

		for _, instance in ipairs(workspace:GetDescendants()) do
			hide3DInstance(instance)
		end
		threeDConnection = workspace.DescendantAdded:Connect(hide3DInstance)
		threeDRenderingDisabled = true
		return true, "3D objects hidden locally; interface remains available"
	end

	if not enabled and threeDRenderingDisabled then
		if threeDUsesEngineSwitch then
			local success, errorMessage = pcall(function()
				RunService:Set3dRenderingEnabled(true)
			end)
			if not success then
				return false, ("Could not restore 3D rendering: %s"):format(tostring(errorMessage))
			end
			threeDUsesEngineSwitch = false
			threeDRenderingDisabled = false
			return true, "3D rendering restored"
		end

		if threeDConnection then
			threeDConnection:Disconnect()
			threeDConnection = nil
		end
		for instance, original in pairs(threeDOriginals) do
			if instance.Parent then
				if original.kind == "Transparency" then
					instance.LocalTransparencyModifier = original.value
				else
					instance.Enabled = original.value
				end
			end
			threeDOriginals[instance] = nil
		end
		threeDRenderingDisabled = false
		return true, "3D objects restored"
	end

	return true, enabled and "3D rendering is already disabled" or "3D rendering is already enabled"
end

local function createFeatureToggle(order, title, description, callback)
	local row = create("Frame", {
		Name = title:gsub("%s+", "") .. "Row",
		LayoutOrder = order,
		Size = UDim2.new(1, -2, 0, 58),
		BackgroundColor3 = colors.panelLight,
		BorderSizePixel = 0,
	}, featureList)
	create("UICorner", { CornerRadius = UDim.new(0, 9) }, row)
	create("UIStroke", {
		Color = colors.border,
		Transparency = 0.55,
		Thickness = 1,
	}, row)

	create("TextLabel", {
		Name = "Title",
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -82, 0, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = colors.text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	create("TextLabel", {
		Name = "Description",
		Position = UDim2.new(0, 12, 0, 27),
		Size = UDim2.new(1, -82, 0, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = description,
		TextColor3 = colors.muted,
		TextSize = 10,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local switch = create("TextButton", {
		Name = "Toggle",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(42, 24),
		BackgroundColor3 = colors.toggleOff,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	}, row)
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, switch)
	local knob = create("Frame", {
		Name = "Knob",
		Position = UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
	}, switch)
	create("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

	local enabled = false
	switch.Activated:Connect(function()
		local requestedState = not enabled
		local success, message = callback(requestedState)
		if not success then
			setStatus(message, true)
			return
		end

		enabled = requestedState
		TweenService:Create(switch, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
			BackgroundColor3 = enabled and colors.toggleOn or colors.toggleOff,
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
			Position = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = enabled and colors.accent or Color3.fromRGB(255, 255, 255),
		}):Play()
		setStatus(message)
	end)
end

createFeatureToggle(1, "FPS Viewer", "Draggable live FPS counter", setFPSViewerEnabled)
createFeatureToggle(2, "FPS Unlocker", "Needs setfpscap; display refresh rate still depends on device", setFPSUnlockerEnabled)
createFeatureToggle(3, "Low Graphics", "Sets Roblox graphics quality to minimum", setLowGraphicsEnabled)
createFeatureToggle(4, "Low Poly", "Uses Plastic and removes local surface textures", setLowPolyEnabled)
createFeatureToggle(5, "Disable 3D Rendering", "Hides the 3D world; the screen may appear blank", set3DRenderingEnabled)

local selectedTab = fpsBoostTab
local function selectTab(tab, title, heading, showSettings)
	if selectedTab then
		TweenService:Create(selectedTab, TweenInfo.new(0.14), {
			BackgroundColor3 = colors.panel,
			TextColor3 = colors.muted,
		}):Play()
	end
	selectedTab = tab
	TweenService:Create(tab, TweenInfo.new(0.14), {
		BackgroundColor3 = colors.accent,
		TextColor3 = colors.text,
	}):Play()
	pageTitle.Text = title
	sectionHeading.Text = heading
	featureList.Visible = not showSettings
	settingsList.Visible = showSettings
end

fpsBoostTab.Activated:Connect(function()
	selectTab(fpsBoostTab, "FPS Boost", "Performance options", false)
end)
settingsTab.Activated:Connect(function()
	selectTab(settingsTab, "Settings", "About & actions", true)
end)
unloadButton.Activated:Connect(function()
	screenGui:Destroy()
end)

screenGui.Destroying:Connect(function()
	ContextActionService:UnbindAction(toggleActionName)
	if launcherDragConnection then
		launcherDragConnection:Disconnect()
		launcherDragConnection = nil
	end
	if launcherEndConnection then
		launcherEndConnection:Disconnect()
		launcherEndConnection = nil
	end
	if fpsViewerConnection then
		fpsViewerConnection:Disconnect()
		fpsViewerConnection = nil
	end
	if fpsViewerDragConnection then
		fpsViewerDragConnection:Disconnect()
		fpsViewerDragConnection = nil
	end
	if fpsViewerEndConnection then
		fpsViewerEndConnection:Disconnect()
		fpsViewerEndConnection = nil
	end
	if lowPolyConnection then
		restoreLowPoly()
	end
	if lowGraphicsOriginalQuality ~= nil then
		local success, message = setLowGraphicsEnabled(false)
		if not success then
			warn(message)
		end
	end
	if fpsUnlockOriginalCap ~= nil then
		local success, message = setFPSUnlockerEnabled(false)
		if not success then
			warn(message)
		end
	end
	if threeDRenderingDisabled then
		local success, message = set3DRenderingEnabled(false)
		if not success then
			warn(message)
		end
	end
end)

local launcher = create("TextButton", {
	Name = "Launcher",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 20, 0.5, 0),
	Size = UDim2.fromOffset(46, 46),
	BackgroundColor3 = colors.panel,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Font = Enum.Font.GothamBold,
	Text = "SC",
	TextColor3 = colors.text,
	TextSize = 14,
	Visible = false,
}, screenGui)
create("UICorner", { CornerRadius = UDim.new(0, 12) }, launcher)
create("UIStroke", {
	Color = colors.border,
	Transparency = 0.1,
	Thickness = 1,
}, launcher)

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

launcherDragConnection = UserInputService.InputChanged:Connect(function(input)
	if not launcherDragging or not launcherDragStart or not launcherStart then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - launcherDragStart
	if delta.Magnitude > 4 then
		launcherMoved = true
	end
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
	local xOffset = launcherStart.X.Offset + delta.X
	local yOffset = launcherStart.Y.Offset + delta.Y
	if viewport then
		xOffset = math.clamp(xOffset, 0, math.max(0, viewport.X - launcher.AbsoluteSize.X))
		local halfHeight = launcher.AbsoluteSize.Y / 2
		yOffset = math.clamp(yOffset, halfHeight, math.max(halfHeight, viewport.Y - halfHeight))
	end
	launcher.Position = UDim2.new(
		launcherStart.X.Scale,
		xOffset,
		launcherStart.Y.Scale,
		yOffset
	)
end)

launcherEndConnection = UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		launcherDragging = false
		launcherDragStart = nil
		launcherStart = nil
	end
end)

local menuIsOpen = true
local transitionGeneration = 0
local function setMenuOpen(isOpen)
	if menuIsOpen == isOpen then
		return
	end

	menuIsOpen = isOpen
	transitionGeneration += 1
	local generation = transitionGeneration
	launcher.Visible = not isOpen

	if isOpen then
		window.Visible = true
		windowScale.Scale = windowScale.Scale * 0.96
		windowStroke.Transparency = 0.35
	end

	local tween = TweenService:Create(
		windowScale,
		TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Scale = isOpen and 1 or windowScale.Scale * 0.96 }
	)
	tween:Play()
	TweenService:Create(windowStroke, TweenInfo.new(0.18), {
		Transparency = isOpen and 0.15 or 0.65,
	}):Play()

	if not isOpen then
		tween.Completed:Connect(function()
			if transitionGeneration == generation and not menuIsOpen then
				window.Visible = false
			end
		end)
	end
end

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
launcher.Activated:Connect(function()
	if launcherMoved then
		launcherMoved = false
		return
	end
	setMenuOpen(true)
end)
closeButton.Activated:Connect(function()
	setMenuOpen(false)
end)

ContextActionService:BindAction(toggleActionName, function(_, inputState)
	if inputState ~= Enum.UserInputState.Begin or UserInputService:GetFocusedTextBox() then
		return Enum.ContextActionResult.Pass
	end
	setMenuOpen(not menuIsOpen)
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.M)