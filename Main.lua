-- Premium UI Library
-- Features: rotating B&W background, light/dark mode, key system, all UI elements
-- Author: Custom Script

local PremiumUI = {}
PremiumUI.__index = PremiumUI

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Default Colors
local Themes = {
	Light = {
		Background = Color3.fromRGB(245, 245, 245),
		Surface = Color3.fromRGB(255, 255, 255),
		Primary = Color3.fromRGB(30, 144, 255),
		Text = Color3.fromRGB(0, 0, 0),
		Border = Color3.fromRGB(200, 200, 200),
		Accent = Color3.fromRGB(0, 0, 0),
		Slider = Color3.fromRGB(30, 144, 255),
		Dropdown = Color3.fromRGB(255, 255, 255),
		Input = Color3.fromRGB(255, 255, 255),
		Button = Color3.fromRGB(30, 144, 255),
		ButtonText = Color3.fromRGB(255, 255, 255),
		ToggleOn = Color3.fromRGB(30, 144, 255),
		ToggleOff = Color3.fromRGB(200, 200, 200),
		Keybind = Color3.fromRGB(255, 255, 255),
		Code = Color3.fromRGB(245, 245, 245),
		Section = Color3.fromRGB(250, 250, 250),
		TabInactive = Color3.fromRGB(230, 230, 230),
		TabActive = Color3.fromRGB(255, 255, 255),
	},
	Dark = {
		Background = Color3.fromRGB(20, 20, 20),
		Surface = Color3.fromRGB(30, 30, 30),
		Primary = Color3.fromRGB(0, 120, 215),
		Text = Color3.fromRGB(255, 255, 255),
		Border = Color3.fromRGB(50, 50, 50),
		Accent = Color3.fromRGB(255, 255, 255),
		Slider = Color3.fromRGB(0, 120, 215),
		Dropdown = Color3.fromRGB(40, 40, 40),
		Input = Color3.fromRGB(40, 40, 40),
		Button = Color3.fromRGB(0, 120, 215),
		ButtonText = Color3.fromRGB(255, 255, 255),
		ToggleOn = Color3.fromRGB(0, 120, 215),
		ToggleOff = Color3.fromRGB(80, 80, 80),
		Keybind = Color3.fromRGB(40, 40, 40),
		Code = Color3.fromRGB(25, 25, 25),
		Section = Color3.fromRGB(35, 35, 35),
		TabInactive = Color3.fromRGB(45, 45, 45),
		TabActive = Color3.fromRGB(55, 55, 55),
	}
}
local CurrentTheme = "Dark" -- default

-- Helper: Create gradient (for rotating background)
local function createRotatingBackground(parent)
	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.new(1, 1, 1)
	bg.BackgroundTransparency = 1
	bg.Parent = parent

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
	}
	gradient.Rotation = 0
	gradient.Parent = bg

	-- Animate rotation slowly
	local angle = 0
	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		angle = (angle + 30 * dt) % 360
		gradient.Rotation = angle
	end)
	bg.Destroying:Connect(function()
		if connection then connection:Disconnect() end
	end)

	return bg
end

-- Helper: Create draggable functionality for a frame
local function makeDraggable(frame, dragHandle)
	local dragging = false
	local dragStart, startPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	dragHandle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Helper: Apply theme to all elements (recursive)
local function applyThemeToElement(element, theme)
	if element:IsA("GuiObject") then
		local bgColor = element:GetAttribute("ThemeBackground")
		if bgColor then
			element.BackgroundColor3 = theme[bgColor] or element.BackgroundColor3
		end
		local textColor = element:GetAttribute("ThemeText")
		if textColor and element:IsA("TextLabel") or element:IsA("TextButton") then
			element.TextColor3 = theme[textColor] or element.TextColor3
		end
		local borderColor = element:GetAttribute("ThemeBorder")
		if borderColor then
			element.BorderColor3 = theme[borderColor] or element.BorderColor3
		end
	end
	for _, child in ipairs(element:GetChildren()) do
		applyThemeToElement(child, theme)
	end
end

-- Notification System
local notificationQueue = {}
local activeNotification = nil

local function showNotification(title, content, duration)
	-- Implementation: create a frame that fades in/out
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(0, 300, 0, 80)
	notification.Position = UDim2.new(1, -310, 0, 10)
	notification.BackgroundColor3 = Themes[CurrentTheme].Surface
	notification.BorderColor3 = Themes[CurrentTheme].Border
	notification.BackgroundTransparency = 0
	notification.BorderSizePixel = 1
	notification.ClipsDescendants = true
	notification.Parent = screenGui
	notification:SetAttribute("ThemeBackground", "Surface")
	notification:SetAttribute("ThemeBorder", "Border")

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 30)
	titleLabel.Position = UDim2.new(0, 10, 0, 5)
	titleLabel.Text = title
	titleLabel.TextColor3 = Themes[CurrentTheme].Text
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.Parent = notification
	titleLabel:SetAttribute("ThemeText", "Text")

	local contentLabel = Instance.new("TextLabel")
	contentLabel.Size = UDim2.new(1, -20, 0, 40)
	contentLabel.Position = UDim2.new(0, 10, 0, 35)
	contentLabel.Text = content
	contentLabel.TextColor3 = Themes[CurrentTheme].Text
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextWrapped = true
	contentLabel.BackgroundTransparency = 1
	contentLabel.Font = Enum.Font.Gotham
	contentLabel.TextSize = 14
	contentLabel.Parent = notification
	contentLabel:SetAttribute("ThemeText", "Text")

	-- Tween in
	notification.Position = UDim2.new(1, -10, 0, 10)
	local tweenIn = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -310, 0, 10)})
	tweenIn:Play()

	task.wait(duration or 3)

	local tweenOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -10, 0, 10)})
	tweenOut:Play()
	tweenOut.Completed:Wait()
	notification:Destroy()
end

PremiumUI.Notify = function(title, content, duration)
	task.spawn(showNotification, title, content, duration)
end

-- Dialog System
local function createDialog(title, content, buttons)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.Parent = screenGui

	local dialog = Instance.new("Frame")
	dialog.Size = UDim2.new(0, 400, 0, 200)
	dialog.Position = UDim2.new(0.5, -200, 0.5, -100)
	dialog.BackgroundColor3 = Themes[CurrentTheme].Surface
	dialog.BorderColor3 = Themes[CurrentTheme].Border
	dialog.BorderSizePixel = 1
	dialog.ClipsDescendants = true
	dialog.Parent = overlay
	dialog:SetAttribute("ThemeBackground", "Surface")
	dialog:SetAttribute("ThemeBorder", "Border")

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.Text = title
	titleLabel.TextColor3 = Themes[CurrentTheme].Text
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.Parent = dialog
	titleLabel:SetAttribute("ThemeText", "Text")

	local contentLabel = Instance.new("TextLabel")
	contentLabel.Size = UDim2.new(1, -20, 0, 100)
	contentLabel.Position = UDim2.new(0, 10, 0, 50)
	contentLabel.Text = content
	contentLabel.TextColor3 = Themes[CurrentTheme].Text
	contentLabel.TextWrapped = true
	contentLabel.BackgroundTransparency = 1
	contentLabel.Font = Enum.Font.Gotham
	contentLabel.TextSize = 14
	contentLabel.Parent = dialog
	contentLabel:SetAttribute("ThemeText", "Text")

	local buttonContainer = Instance.new("Frame")
	buttonContainer.Size = UDim2.new(1, 0, 0, 40)
	buttonContainer.Position = UDim2.new(0, 0, 1, -40)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = dialog

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 10)
	layout.Parent = buttonContainer

	for _, btn in ipairs(buttons) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 80, 0, 30)
		button.Text = btn.text
		button.BackgroundColor3 = Themes[CurrentTheme].Button
		button.TextColor3 = Themes[CurrentTheme].ButtonText
		button.Font = Enum.Font.Gotham
		button.TextSize = 14
		button.Parent = buttonContainer
		button:SetAttribute("ThemeBackground", "Button")
		button:SetAttribute("ThemeText", "ButtonText")
		button.MouseButton1Click:Connect(function()
			if btn.callback then btn.callback() end
			overlay:Destroy()
		end)
	end

	return overlay
end

PremiumUI.Dialog = function(options)
	return createDialog(options.Title, options.Content, options.Buttons)
end

-- Key System
local function showKeySystem(keys, note, getKeyCallback, onSuccess)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.Parent = screenGui

	local dialog = Instance.new("Frame")
	dialog.Size = UDim2.new(0, 350, 0, 180)
	dialog.Position = UDim2.new(0.5, -175, 0.5, -90)
	dialog.BackgroundColor3 = Themes[CurrentTheme].Surface
	dialog.BorderColor3 = Themes[CurrentTheme].Border
	dialog.BorderSizePixel = 1
	dialog.ClipsDescendants = true
	dialog.Parent = overlay
	dialog:SetAttribute("ThemeBackground", "Surface")
	dialog:SetAttribute("ThemeBorder", "Border")

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.Text = "Key System"
	titleLabel.TextColor3 = Themes[CurrentTheme].Text
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.Parent = dialog
	titleLabel:SetAttribute("ThemeText", "Text")

	local noteLabel = Instance.new("TextLabel")
	noteLabel.Size = UDim2.new(1, -20, 0, 30)
	noteLabel.Position = UDim2.new(0, 10, 0, 45)
	noteLabel.Text = note
	noteLabel.TextColor3 = Themes[CurrentTheme].Text
	noteLabel.TextWrapped = true
	noteLabel.BackgroundTransparency = 1
	noteLabel.Font = Enum.Font.Gotham
	noteLabel.TextSize = 12
	noteLabel.Parent = dialog
	noteLabel:SetAttribute("ThemeText", "Text")

	local inputBox = Instance.new("TextBox")
	inputBox.Size = UDim2.new(1, -20, 0, 30)
	inputBox.Position = UDim2.new(0, 10, 0, 80)
	inputBox.PlaceholderText = "Enter key"
	inputBox.BackgroundColor3 = Themes[CurrentTheme].Input
	inputBox.TextColor3 = Themes[CurrentTheme].Text
	inputBox.Font = Enum.Font.Gotham
	inputBox.TextSize = 14
	inputBox.Parent = dialog
	inputBox:SetAttribute("ThemeBackground", "Input")
	inputBox:SetAttribute("ThemeText", "Text")

	local buttonContainer = Instance.new("Frame")
	buttonContainer.Size = UDim2.new(1, 0, 0, 40)
	buttonContainer.Position = UDim2.new(0, 0, 1, -40)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = dialog

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 10)
	layout.Parent = buttonContainer

	local submitBtn = Instance.new("TextButton")
	submitBtn.Size = UDim2.new(0, 80, 0, 30)
	submitBtn.Text = "Submit"
	submitBtn.BackgroundColor3 = Themes[CurrentTheme].Button
	submitBtn.TextColor3 = Themes[CurrentTheme].ButtonText
	submitBtn.Font = Enum.Font.Gotham
	submitBtn.TextSize = 14
	submitBtn.Parent = buttonContainer
	submitBtn:SetAttribute("ThemeBackground", "Button")
	submitBtn:SetAttribute("ThemeText", "ButtonText")

	local getKeyBtn = Instance.new("TextButton")
	getKeyBtn.Size = UDim2.new(0, 80, 0, 30)
	getKeyBtn.Text = "Get Key"
	getKeyBtn.BackgroundColor3 = Themes[CurrentTheme].Button
	getKeyBtn.TextColor3 = Themes[CurrentTheme].ButtonText
	getKeyBtn.Font = Enum.Font.Gotham
	getKeyBtn.TextSize = 14
	getKeyBtn.Parent = buttonContainer
	getKeyBtn:SetAttribute("ThemeBackground", "Button")
	getKeyBtn:SetAttribute("ThemeText", "ButtonText")

	local function validateKey(key)
		for _, valid in ipairs(keys) do
			if key == valid then
				return true
			end
		end
		return false
	end

	submitBtn.MouseButton1Click:Connect(function()
		if validateKey(inputBox.Text) then
			overlay:Destroy()
			if onSuccess then onSuccess() end
		else
			PremiumUI.Notify("Error", "Invalid key!", 2)
		end
	end)

	getKeyBtn.MouseButton1Click:Connect(function()
		if getKeyCallback then getKeyCallback() end
	end)

	return overlay
end

-- UI Elements (Button, Toggle, etc.)
local function createButton(parent, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, 0)
	btn.Text = text
	btn.BackgroundColor3 = Themes[CurrentTheme].Button
	btn.TextColor3 = Themes[CurrentTheme].ButtonText
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = parent
	btn:SetAttribute("ThemeBackground", "Button")
	btn:SetAttribute("ThemeText", "ButtonText")
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function createToggle(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 30)
	frame.Position = UDim2.new(0, 10, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -50, 1, 0)
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Themes[CurrentTheme].Text
	label.Parent = frame
	label:SetAttribute("ThemeText", "Text")

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 40, 0, 20)
	toggle.Position = UDim2.new(1, -45, 0.5, -10)
	toggle.BackgroundColor3 = default and Themes[CurrentTheme].ToggleOn or Themes[CurrentTheme].ToggleOff
	toggle.Text = ""
	toggle.Parent = frame
	toggle:SetAttribute("ThemeBackground", default and "ToggleOn" or "ToggleOff")

	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.BackgroundColor3 = state and Themes[CurrentTheme].ToggleOn or Themes[CurrentTheme].ToggleOff
		toggle:SetAttribute("ThemeBackground", state and "ToggleOn" or "ToggleOff")
		callback(state)
	end)
	return frame, function() return state end
end

local function createSlider(parent, text, min, max, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 50)
	frame.Position = UDim2.new(0, 10, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Themes[CurrentTheme].Text
	label.Parent = frame
	label:SetAttribute("ThemeText", "Text")

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 40, 0, 20)
	valueLabel.Position = UDim2.new(1, -45, 0, 0)
	valueLabel.Text = tostring(default)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.BackgroundTransparency = 1
	valueLabel.Font = Enum.Font.Gotham
	valueLabel.TextSize = 14
	valueLabel.TextColor3 = Themes[CurrentTheme].Text
	valueLabel.Parent = frame
	valueLabel:SetAttribute("ThemeText", "Text")

	local slider = Instance.new("Frame")
	slider.Size = UDim2.new(1, 0, 0, 4)
	slider.Position = UDim2.new(0, 0, 0, 25)
	slider.BackgroundColor3 = Themes[CurrentTheme].Border
	slider.BorderSizePixel = 0
	slider.Parent = frame
	slider:SetAttribute("ThemeBackground", "Border")

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Themes[CurrentTheme].Slider
	fill.BorderSizePixel = 0
	fill.Parent = slider
	fill:SetAttribute("ThemeBackground", "Slider")

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new((default - min) / (max - min), -6, 0, -4)
	knob.BackgroundColor3 = Themes[CurrentTheme].Slider
	knob.Text = ""
	knob.Parent = slider
	knob:SetAttribute("ThemeBackground", "Slider")

	local function updateSlider(value)
		local t = (value - min) / (max - min)
		fill.Size = UDim2.new(t, 0, 1, 0)
		knob.Position = UDim2.new(t, -6, 0, -4)
		valueLabel.Text = tostring(math.floor(value))
		callback(value)
	end

	local dragging = false
	knob.MouseButton1Down:Connect(function()
		dragging = true
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mouseX = input.Position.X
			local sliderAbsPos = slider.AbsolutePosition.X
			local sliderWidth = slider.AbsoluteSize.X
			local newT = math.clamp((mouseX - sliderAbsPos) / sliderWidth, 0, 1)
			local newVal = min + newT * (max - min)
			updateSlider(newVal)
		end
	end)

	updateSlider(default)
	return frame
end

-- Additional elements: Dropdown, Input, Keybind, Paragraph, Code, ColorPicker, etc.
-- (For brevity, we'll implement the core ones, but you can extend similarly)
-- For a complete library, you'd implement all, but here we'll include placeholders or simple implementations.

local function createDropdown(parent, options, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 30)
	frame.Position = UDim2.new(0, 10, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 1, 0)
	button.Text = default or options[1]
	button.BackgroundColor3 = Themes[CurrentTheme].Dropdown
	button.TextColor3 = Themes[CurrentTheme].Text
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = frame
	button:SetAttribute("ThemeBackground", "Dropdown")
	button:SetAttribute("ThemeText", "Text")

	local list = Instance.new("Frame")
	list.Size = UDim2.new(1, 0, 0, 0)
	list.Position = UDim2.new(0, 0, 1, 0)
	list.BackgroundColor3 = Themes[CurrentTheme].Dropdown
	list.BorderSizePixel = 0
	list.Visible = false
	list.Parent = frame
	list:SetAttribute("ThemeBackground", "Dropdown")

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = list

	for _, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 30)
		optBtn.Text = opt
		optBtn.BackgroundColor3 = Themes[CurrentTheme].Dropdown
		optBtn.TextColor3 = Themes[CurrentTheme].Text
		optBtn.Font = Enum.Font.Gotham
		optBtn.TextSize = 14
		optBtn.Parent = list
		optBtn:SetAttribute("ThemeBackground", "Dropdown")
		optBtn:SetAttribute("ThemeText", "Text")
		optBtn.MouseButton1Click:Connect(function()
			button.Text = opt
			list.Visible = false
			callback(opt)
		end)
	end

	button.MouseButton1Click:Connect(function()
		list.Visible = not list.Visible
		if list.Visible then
			local height = #options * 32
			list.Size = UDim2.new(1, 0, 0, height)
		end
	end)

	return frame
end

-- Input, Keybind, etc. similar patterns. We'll include minimal but functional.
local function createInput(parent, placeholder, default, callback)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -20, 0, 30)
	box.Position = UDim2.new(0, 10, 0, 0)
	box.PlaceholderText = placeholder
	box.Text = default or ""
	box.BackgroundColor3 = Themes[CurrentTheme].Input
	box.TextColor3 = Themes[CurrentTheme].Text
	box.Font = Enum.Font.Gotham
	box.TextSize = 14
	box.Parent = parent
	box:SetAttribute("ThemeBackground", "Input")
	box:SetAttribute("ThemeText", "Text")
	box:GetPropertyChangedSignal("Text"):Connect(function()
		callback(box.Text)
	end)
	return box
end

local function createKeybind(parent, text, defaultKey, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 30)
	frame.Position = UDim2.new(0, 10, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Themes[CurrentTheme].Text
	label.Parent = frame
	label:SetAttribute("ThemeText", "Text")

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.3, 0, 1, 0)
	button.Position = UDim2.new(0.7, 0, 0, 0)
	button.Text = defaultKey and defaultKey.Name or "None"
	button.BackgroundColor3 = Themes[CurrentTheme].Keybind
	button.TextColor3 = Themes[CurrentTheme].Text
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = frame
	button:SetAttribute("ThemeBackground", "Keybind")
	button:SetAttribute("ThemeText", "Text")

	local waiting = false
	button.MouseButton1Click:Connect(function()
		waiting = true
		button.Text = "..."
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if waiting and not gameProcessed then
			waiting = false
			button.Text = input.KeyCode.Name
			callback(input.KeyCode)
		end
	end)

	return frame
end

local function createParagraph(parent, text)
	local para = Instance.new("TextLabel")
	para.Size = UDim2.new(1, -20, 0, 0)
	para.Position = UDim2.new(0, 10, 0, 0)
	para.Text = text
	para.TextWrapped = true
	para.TextXAlignment = Enum.TextXAlignment.Left
	para.BackgroundTransparency = 1
	para.Font = Enum.Font.Gotham
	para.TextSize = 12
	para.TextColor3 = Themes[CurrentTheme].Text
	para.Parent = parent
	para:SetAttribute("ThemeText", "Text")
	para.Size = UDim2.new(1, -20, 0, para.TextBounds.Y + 10)
	return para
end

local function createCode(parent, code)
	local codeBox = Instance.new("TextBox")
	codeBox.Size = UDim2.new(1, -20, 0, 80)
	codeBox.Position = UDim2.new(0, 10, 0, 0)
	codeBox.Text = code
	codeBox.TextWrapped = true
	codeBox.ClearTextOnFocus = false
	codeBox.BackgroundColor3 = Themes[CurrentTheme].Code
	codeBox.TextColor3 = Themes[CurrentTheme].Text
	codeBox.Font = Enum.Font.Code
	codeBox.TextSize = 12
	codeBox.Parent = parent
	codeBox:SetAttribute("ThemeBackground", "Code")
	codeBox:SetAttribute("ThemeText", "Text")
	return codeBox
end

local function createColorPicker(parent, defaultColor, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 30)
	frame.Position = UDim2.new(0, 10, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Text = "Color Picker"
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.TextColor3 = Themes[CurrentTheme].Text
	label.Parent = frame
	label:SetAttribute("ThemeText", "Text")

	local colorBtn = Instance.new("TextButton")
	colorBtn.Size = UDim2.new(0, 30, 0, 20)
	colorBtn.Position = UDim2.new(1, -35, 0.5, -10)
	colorBtn.BackgroundColor3 = defaultColor
	colorBtn.Text = ""
	colorBtn.Parent = frame
	colorBtn:SetAttribute("ThemeBackground", "Surface")

	colorBtn.MouseButton1Click:Connect(function()
		-- Simplified color picker using a ColorPicker popup (not implemented fully here)
		PremiumUI.Notify("Color Picker", "Open color picker (custom implementation)", 2)
	end)
	return frame
end

-- Tab and Section management
local function createTabSection(parent, title, elements)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, 0, 0, 0)
	section.BackgroundColor3 = Themes[CurrentTheme].Section
	section.BorderSizePixel = 0
	section.Parent = parent
	section:SetAttribute("ThemeBackground", "Section")

	local titleBar = Instance.new("TextLabel")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.Text = title
	titleBar.TextXAlignment = Enum.TextXAlignment.Left
	titleBar.BackgroundColor3 = Themes[CurrentTheme].Surface
	titleBar.TextColor3 = Themes[CurrentTheme].Text
	titleBar.Font = Enum.Font.GothamBold
	titleBar.TextSize = 16
	titleBar.Parent = section
	titleBar:SetAttribute("ThemeBackground", "Surface")
	titleBar:SetAttribute("ThemeText", "Text")

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 0)
	container.Position = UDim2.new(0, 0, 0, 30)
	container.BackgroundTransparency = 1
	container.Parent = section

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 5)
	layout.Parent = container

	local totalHeight = 0
	for _, elementFunc in ipairs(elements) do
		local elem = elementFunc(container)
		totalHeight = totalHeight + elem.AbsoluteSize.Y + 5
	end

	-- Update section size after layout
	container.Size = UDim2.new(1, 0, 0, totalHeight)
	section.Size = UDim2.new(1, 0, 0, totalHeight + 30)

	return section
end

-- Window creation
local function createWindow(options)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PremiumUI_Window"
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 600, 0, 400)
	main.Position = UDim2.new(0.5, -300, 0.5, -200)
	main.BackgroundColor3 = Themes[CurrentTheme].Background
	main.BorderColor3 = Themes[CurrentTheme].Border
	main.BorderSizePixel = 1
	main.ClipsDescendants = true
	main.Parent = screenGui
	main:SetAttribute("ThemeBackground", "Background")
	main:SetAttribute("ThemeBorder", "Border")

	-- Rotating background
	createRotatingBackground(main)

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.BackgroundColor3 = Themes[CurrentTheme].Surface
	titleBar.BorderSizePixel = 0
	titleBar.Parent = main
	titleBar:SetAttribute("ThemeBackground", "Surface")

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -100, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.Text = options.Title or "Window"
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
	titleLabel.TextColor3 = Themes[CurrentTheme].Text
	titleLabel.Parent = titleBar
	titleLabel:SetAttribute("ThemeText", "Text")

	-- Buttons
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Size = UDim2.new(0, 25, 1, 0)
	minimizeBtn.Position = UDim2.new(1, -80, 0, 0)
	minimizeBtn.Text = "_"
	minimizeBtn.BackgroundColor3 = Themes[CurrentTheme].Surface
	minimizeBtn.TextColor3 = Themes[CurrentTheme].Text
	minimizeBtn.Font = Enum.Font.Gotham
	minimizeBtn.TextSize = 18
	minimizeBtn.Parent = titleBar
	minimizeBtn:SetAttribute("ThemeBackground", "Surface")
	minimizeBtn:SetAttribute("ThemeText", "Text")

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 25, 1, 0)
	closeBtn.Position = UDim2.new(1, -50, 0, 0)
	closeBtn.Text = "X"
	closeBtn.BackgroundColor3 = Themes[CurrentTheme].Surface
	closeBtn.TextColor3 = Themes[CurrentTheme].Text
	closeBtn.Font = Enum.Font.Gotham
	closeBtn.TextSize = 18
	closeBtn.Parent = titleBar
	closeBtn:SetAttribute("ThemeBackground", "Surface")
	closeBtn:SetAttribute("ThemeText", "Text")

	local lightDarkBtn = Instance.new("TextButton")
	lightDarkBtn.Size = UDim2.new(0, 25, 1, 0)
	lightDarkBtn.Position = UDim2.new(1, -110, 0, 0)
	lightDarkBtn.Text = "🌙"
	lightDarkBtn.BackgroundColor3 = Themes[CurrentTheme].Surface
	lightDarkBtn.TextColor3 = Themes[CurrentTheme].Text
	lightDarkBtn.Font = Enum.Font.Gotham
	lightDarkBtn.TextSize = 18
	lightDarkBtn.Parent = titleBar
	lightDarkBtn:SetAttribute("ThemeBackground", "Surface")
	lightDarkBtn:SetAttribute("ThemeText", "Text")

	-- Draggable
	makeDraggable(main, titleBar)

	local tabsContainer = Instance.new("Frame")
	tabsContainer.Size = UDim2.new(1, 0, 0, 30)
	tabsContainer.Position = UDim2.new(0, 0, 0, 30)
	tabsContainer.BackgroundTransparency = 1
	tabsContainer.Parent = main

	local tabButtons = {}
	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, 0, 1, -60)
	contentFrame.Position = UDim2.new(0, 0, 0, 60)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = main

	local function switchTab(tabName)
		for _, btn in ipairs(tabButtons) do
			btn.BackgroundColor3 = btn.Text == tabName and Themes[CurrentTheme].TabActive or Themes[CurrentTheme].TabInactive
		end
		for _, child in ipairs(contentFrame:GetChildren()) do
			child.Visible = child.Name == tabName
		end
	end

	local function addTab(name, icon)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 100, 1, 0)
		btn.Text = name
		btn.BackgroundColor3 = Themes[CurrentTheme].TabInactive
		btn.TextColor3 = Themes[CurrentTheme].Text
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 14
		btn.Parent = tabsContainer
		btn:SetAttribute("ThemeBackground", "TabInactive")
		btn:SetAttribute("ThemeText", "Text")
		btn.MouseButton1Click:Connect(function()
			switchTab(name)
		end)
		table.insert(tabButtons, btn)

		local tabContent = Instance.new("ScrollingFrame")
		tabContent.Name = name
		tabContent.Size = UDim2.new(1, 0, 1, 0)
		tabContent.BackgroundTransparency = 1
		tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabContent.ScrollBarThickness = 6
		tabContent.Parent = contentFrame
		tabContent.Visible = false

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 10)
		layout.Parent = tabContent
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			tabContent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
		end)

		return {
			CreateSection = function(sectionTitle, elements)
				local section = createTabSection(tabContent, sectionTitle, elements)
				return section
			end
		}
	end

	-- Minimize/Close
	local minimized = false
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		main.Size = minimized and UDim2.new(0, 600, 0, 30) or UDim2.new(0, 600, 0, 400)
		contentFrame.Visible = not minimized
	end)

	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	-- Light/Dark Mode
	lightDarkBtn.MouseButton1Click:Connect(function()
		CurrentTheme = CurrentTheme == "Light" and "Dark" or "Light"
		lightDarkBtn.Text = CurrentTheme == "Light" and "☀️" or "🌙"
		applyThemeToElement(main, Themes[CurrentTheme])
	end)

	return {
		CreateTab = addTab,
		Destroy = function() screenGui:Destroy() end
	}
end

PremiumUI.CreateWindow = createWindow
PremiumUI.Themes = Themes
PremiumUI.SetTheme = function(themeName)
	if Themes[themeName] then
		CurrentTheme = themeName
	end
end

-- Open/Close button using rbxassetid
local function createToggleButton(assetId, window)
	local btn = Instance.new("ImageButton")
	btn.Image = "rbxassetid://" .. assetId
	btn.Size = UDim2.new(0, 50, 0, 50)
	btn.Position = UDim2.new(0, 10, 0, 10)
	btn.BackgroundTransparency = 1
	btn.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local visible = true
	btn.MouseButton1Click:Connect(function()
		visible = not visible
		window:SetVisible(visible)
	end)

	return btn
end

-- Example usage (uncomment to test)
--[[
local Window = PremiumUI.CreateWindow({ Title = "Premium UI Demo" })
local mainTab = Window:CreateTab("Main", "home")
local section = mainTab:CreateSection("Controls", {
	function(parent) return createButton(parent, "Click Me", function() PremiumUI.Notify("Info", "Button clicked!", 2) end) end,
	function(parent) return createToggle(parent, "Toggle Option", true, function(state) print("Toggle state:", state) end) end,
	function(parent) return createSlider(parent, "Volume", 0, 100, 50, function(val) print("Volume:", val) end) end,
	function(parent) return createDropdown(parent, {"Option1", "Option2"}, "Option1", function(opt) print("Selected:", opt) end) end,
	function(parent) return createInput(parent, "Enter text", "default", function(txt) print("Input:", txt) end) end,
	function(parent) return createKeybind(parent, "Keybind", Enum.KeyCode.R, function(key) print("Key pressed:", key) end) end,
	function(parent) return createParagraph(parent, "This is a paragraph with some text.") end,
	function(parent) return createCode(parent, "print('Hello World')") end,
	function(parent) return createColorPicker(parent, Color3.new(1,0,0), function(col) print("Color:", col) end) end,
})
]]

-- Return the library
return PremiumUI
