--[[
    Premium UI Library - Black & White Rotating Background
    Features: Button, Toggle, Slider, Dropdown, Input, Keybind, Paragraph, Code, ColorPicker,
              TabSection, Section, Notification, Popup, Dialog, KeySystem
    With Minimize, Close, Light/Dark themes, and RBXAssetID support
]]

local PremiumUI = {}
PremiumUI.__index = PremiumUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Theme colors
local Themes = {
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Surface = Color3.fromRGB(255, 255, 255),
        Border = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(30, 30, 30),
        TextSecondary = Color3.fromRGB(100, 100, 100),
        Accent = Color3.fromRGB(0, 0, 0),
        AccentHover = Color3.fromRGB(50, 50, 50),
        Success = Color3.fromRGB(76, 175, 80),
        Danger = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 152, 0),
        Info = Color3.fromRGB(33, 150, 243),
        ToggleOn = Color3.fromRGB(0, 0, 0),
        ToggleOff = Color3.fromRGB(200, 200, 200),
        SliderBg = Color3.fromRGB(220, 220, 220),
        DropdownBg = Color3.fromRGB(250, 250, 250),
        InputBg = Color3.fromRGB(250, 250, 250),
        CodeBg = Color3.fromRGB(240, 240, 240),
    },
    Dark = {
        Background = Color3.fromRGB(18, 18, 18),
        Surface = Color3.fromRGB(30, 30, 30),
        Border = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(235, 235, 235),
        TextSecondary = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(255, 255, 255),
        AccentHover = Color3.fromRGB(200, 200, 200),
        Success = Color3.fromRGB(76, 175, 80),
        Danger = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 152, 0),
        Info = Color3.fromRGB(33, 150, 243),
        ToggleOn = Color3.fromRGB(255, 255, 255),
        ToggleOff = Color3.fromRGB(80, 80, 80),
        SliderBg = Color3.fromRGB(50, 50, 50),
        DropdownBg = Color3.fromRGB(40, 40, 40),
        InputBg = Color3.fromRGB(40, 40, 40),
        CodeBg = Color3.fromRGB(25, 25, 25),
    }
}

-- Animation settings
local TweenSettings = {
    Duration = 0.2,
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out
}

-- Utility functions
local function TweenObject(obj, properties)
    local tween = TweenService:Create(obj, TweenInfo.new(TweenSettings.Duration, TweenSettings.EasingStyle, TweenSettings.EasingDirection), properties)
    tween:Play()
    return tween
end

local function CreateRoundedFrame(parent, size, position, color, transparency, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = transparency or 0
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    corner.CornerRadius = UDim.new(0, cornerRadius or 8)
    
    return frame
end

local function CreateTextLabel(parent, text, size, position, color, transparency, font, textSize, textXAlign, textYAlign)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Text = text
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextTransparency = transparency or 0
    label.Font = font or Enum.Font.GothamMedium
    label.TextSize = textSize or 14
    label.TextXAlignment = textXAlign or Enum.TextXAlignment.Left
    label.TextYAlignment = textYAlign or Enum.TextYAlignment.Center
    label.RichText = true
    return label
end

local function CreateTextBox(parent, placeholder, size, position, color, bgColor, cornerRadius)
    local frame = CreateRoundedFrame(parent, size, position, bgColor, 0, cornerRadius or 6)
    local textBox = Instance.new("TextBox")
    textBox.Parent = frame
    textBox.Size = UDim2.new(1, -16, 1, -8)
    textBox.Position = UDim2.new(0, 8, 0, 4)
    textBox.BackgroundTransparency = 1
    textBox.TextColor3 = color
    textBox.PlaceholderText = placeholder
    textBox.PlaceholderColor3 = Themes.Dark.TextSecondary
    textBox.Font = Enum.Font.GothamMedium
    textBox.TextSize = 13
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClipsDescendants = true
    
    return frame, textBox
end

-- Main UI Class
function PremiumUI:CreateWindow(config)
    config = config or {}
    local self = setmetatable({}, PremiumUI)
    
    self.Title = config.Title or "Premium UI"
    self.Icon = config.Icon or "star"
    self.Author = config.Author or ""
    self.RBXAssetId = config.RBXAssetId or "rbxassetid://1234567890"
    self.CurrentTheme = config.DefaultTheme or "Dark"
    self.ThemeColors = Themes[self.CurrentTheme]
    self.WindowVisible = true
    self.Tabs = {}
    self.CurrentTab = nil
    self.Notifications = {}
    self.Popups = {}
    self.Dialogs = {}
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "PremiumUI"
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    
    -- Main Container (for minimize animation)
    self.MainContainer = Instance.new("Frame")
    self.MainContainer.Parent = self.ScreenGui
    self.MainContainer.Size = UDim2.new(0, 800, 0, 550)
    self.MainContainer.Position = UDim2.new(0.5, -400, 0.5, -275)
    self.MainContainer.BackgroundTransparency = 1
    self.MainContainer.BorderSizePixel = 0
    
    -- Background with rotating gradient
    self.RotatingBg = Instance.new("Frame")
    self.RotatingBg.Parent = self.MainContainer
    self.RotatingBg.Size = UDim2.new(1, 0, 1, 0)
    self.RotatingBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.RotatingBg.BackgroundTransparency = 0.15
    self.RotatingBg.BorderSizePixel = 0
    
    -- Create gradient texture for rotating effect
    local gradientFrame = Instance.new("Frame")
    gradientFrame.Parent = self.RotatingBg
    gradientFrame.Size = UDim2.new(2, 0, 2, 0)
    gradientFrame.Position = UDim2.new(-0.5, 0, -0.5, 0)
    gradientFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    gradientFrame.BackgroundTransparency = 0.7
    gradientFrame.BorderSizePixel = 0
    
    local gradient = Instance.new("UIGradient")
    gradient.Parent = gradientFrame
    gradient.Rotation = 0
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(200, 200, 200)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 100, 100)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(200, 200, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    
    -- Rotate animation
    local rotationAngle = 0
    RunService.RenderStepped:Connect(function(dt)
        rotationAngle = (rotationAngle + 15 * dt) % 360
        gradient.Rotation = rotationAngle
        gradientFrame.Position = UDim2.new(-0.5 + math.sin(math.rad(rotationAngle)) * 0.2, 0, -0.5 + math.cos(math.rad(rotationAngle)) * 0.2, 0)
    end)
    
    -- Border frame
    self.BorderFrame = CreateRoundedFrame(self.MainContainer, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 255, 255), 0.8, 12)
    self.BorderFrame.BackgroundTransparency = 0.9
    self.BorderFrame.ZIndex = 1
    
    local borderStroke = Instance.new("UIStroke")
    borderStroke.Parent = self.BorderFrame
    borderStroke.Color = Color3.fromRGB(255, 255, 255)
    borderStroke.Thickness = 1
    borderStroke.Transparency = 0.6
    
    -- Main Window Frame
    self.WindowFrame = CreateRoundedFrame(self.MainContainer, UDim2.new(1, -4, 1, -4), UDim2.new(0, 2, 0, 2), self.ThemeColors.Background, 0, 10)
    self.WindowFrame.ZIndex = 2
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Parent = self.WindowFrame
    self.TitleBar.Size = UDim2.new(1, 0, 0, 48)
    self.TitleBar.Position = UDim2.new(0, 0, 0, 0)
    self.TitleBar.BackgroundColor3 = self.ThemeColors.Surface
    self.TitleBar.BackgroundTransparency = 0
    self.TitleBar.BorderSizePixel = 0
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.Parent = self.TitleBar
    titleCorner.CornerRadius = UDim.new(0, 10)
    
    -- Icon and Title
    local titleIcon = CreateTextLabel(self.TitleBar, "★", UDim2.new(0, 32, 1, 0), UDim2.new(0, 12, 0, 0), self.ThemeColors.Accent, 0, Enum.Font.GothamBold, 20, Enum.TextXAlignment.Center)
    local titleLabel = CreateTextLabel(self.TitleBar, self.Title, UDim2.new(0, 200, 1, 0), UDim2.new(0, 52, 0, 0), self.ThemeColors.Text, 0, Enum.Font.GothamBold, 16)
    
    -- Author label
    if self.Author ~= "" then
        CreateTextLabel(self.TitleBar, self.Author, UDim2.new(0, 150, 1, 0), UDim2.new(0, 250, 0, 0), self.ThemeColors.TextSecondary, 0, Enum.Font.Gotham, 11)
    end
    
    -- Window Controls
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Parent = self.TitleBar
    controlsFrame.Size = UDim2.new(0, 120, 1, 0)
    controlsFrame.Position = UDim2.new(1, -128, 0, 0)
    controlsFrame.BackgroundTransparency = 1
    
    -- Light/Dark toggle
    self.ThemeToggle = CreateRoundedFrame(controlsFrame, UDim2.new(0, 32, 0, 32), UDim2.new(0, 0, 0, 8), self.ThemeColors.Surface, 0, 16)
    local themeIcon = CreateTextLabel(self.ThemeToggle, "☀️", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Text, 0, Enum.Font.Gotham, 16, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
    
    self.ThemeToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:ToggleTheme()
            themeIcon.Text = self.CurrentTheme == "Dark" and "🌙" or "☀️"
        end
    end)
    
    -- Minimize button
    self.MinimizeBtn = CreateRoundedFrame(controlsFrame, UDim2.new(0, 32, 0, 32), UDim2.new(0, 40, 0, 8), self.ThemeColors.Surface, 0, 16)
    local minIcon = CreateTextLabel(self.MinimizeBtn, "─", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Text, 0, Enum.Font.Gotham, 20, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
    
    self.MinimizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:Minimize()
        end
    end)
    
    -- Close button
    self.CloseBtn = CreateRoundedFrame(controlsFrame, UDim2.new(0, 32, 0, 32), UDim2.new(0, 80, 0, 8), Color3.fromRGB(255, 80, 80), 0, 16)
    local closeIcon = CreateTextLabel(self.CloseBtn, "✕", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 255, 255), 0, Enum.Font.Gotham, 16, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
    
    self.CloseBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:Close()
        end
    end)
    
    -- Dragging functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainContainer.Position
        end
    end)
    
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Tab Container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Parent = self.WindowFrame
    self.TabContainer.Size = UDim2.new(1, 0, 0, 40)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 48)
    self.TabContainer.BackgroundColor3 = self.ThemeColors.Surface
    self.TabContainer.BackgroundTransparency = 0.5
    self.TabContainer.BorderSizePixel = 0
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.Parent = self.TabContainer
    tabCorner.CornerRadius = UDim.new(0, 8)
    
    -- Content Container
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Parent = self.WindowFrame
    self.ContentContainer.Size = UDim2.new(1, -24, 1, -108)
    self.ContentContainer.Position = UDim2.new(0, 12, 0, 96)
    self.ContentContainer.BackgroundTransparency = 1
    self.ContentContainer.BorderSizePixel = 0
    
    -- Scrolling Frame
    self.ScrollingFrame = Instance.new("ScrollingFrame")
    self.ScrollingFrame.Parent = self.ContentContainer
    self.ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    self.ScrollingFrame.BackgroundTransparency = 1
    self.ScrollingFrame.BorderSizePixel = 0
    self.ScrollingFrame.ScrollBarThickness = 6
    self.ScrollingFrame.ScrollBarImageColor3 = self.ThemeColors.Accent
    self.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local scrollPadding = Instance.new("UIPadding")
    scrollPadding.Parent = self.ScrollingFrame
    scrollPadding.PaddingTop = UDim.new(0, 8)
    scrollPadding.PaddingBottom = UDim.new(0, 8)
    
    -- Canvas layout
    self.CanvasLayout = Instance.new("UIListLayout")
    self.CanvasLayout.Parent = self.ScrollingFrame
    self.CanvasLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.CanvasLayout.Padding = UDim.new(0, 12)
    
    self.CanvasLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.CanvasLayout.AbsoluteContentSize.Y)
    end)
    
    -- Initialize key system if enabled
    if config.KeySystem then
        self:ShowKeySystem(config.KeySystem)
    end
    
    return self
end

function PremiumUI:ShowKeySystem(keyConfig)
    self.WindowVisible = false
    self.MainContainer.Visible = false
    
    local dialogFrame = CreateRoundedFrame(self.ScreenGui, UDim2.new(0, 400, 0, 250), UDim2.new(0.5, -200, 0.5, -125), self.ThemeColors.Surface, 0, 16)
    dialogFrame.ZIndex = 100
    dialogFrame.BackgroundTransparency = 0
    
    local borderStroke = Instance.new("UIStroke")
    borderStroke.Parent = dialogFrame
    borderStroke.Color = self.ThemeColors.Accent
    borderStroke.Thickness = 1
    
    CreateTextLabel(dialogFrame, "🔑 Key System", UDim2.new(1, -24, 0, 40), UDim2.new(0, 12, 0, 12), self.ThemeColors.Text, 0, Enum.Font.GothamBold, 18)
    CreateTextLabel(dialogFrame, keyConfig.Note or "Enter your key to continue", UDim2.new(1, -24, 0, 30), UDim2.new(0, 12, 0, 55), self.ThemeColors.TextSecondary, 0, Enum.Font.Gotham, 12)
    
    local inputFrame, keyInput = CreateTextBox(dialogFrame, "Enter key...", UDim2.new(1, -24, 0, 40), UDim2.new(0, 12, 0, 95), self.ThemeColors.Text, self.ThemeColors.InputBg, 8)
    inputFrame.BackgroundTransparency = 0
    
    local submitBtn = CreateRoundedFrame(dialogFrame, UDim2.new(1, -24, 0, 40), UDim2.new(0, 12, 0, 150), self.ThemeColors.Accent, 0, 8)
    local submitText = CreateTextLabel(submitBtn, "Submit", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Background, 0, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
    
    local getKeyBtn = CreateRoundedFrame(dialogFrame, UDim2.new(1, -24, 0, 40), UDim2.new(0, 12, 0, 198), self.ThemeColors.Surface, 0, 8)
    getKeyBtn.BackgroundColor3 = self.ThemeColors.Surface
    local getKeyText = CreateTextLabel(getKeyBtn, "Get Key", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Text, 0, Enum.Font.Gotham, 14, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
    
    local errorLabel = CreateTextLabel(dialogFrame, "", UDim2.new(1, -24, 0, 20), UDim2.new(0, 12, 0, 205), Color3.fromRGB(255, 80, 80), 0, Enum.Font.Gotham, 11)
    
    local function validateKey(key)
        for _, validKey in ipairs(keyConfig.Key) do
            if key == validKey then
                return true
            end
        end
        return false
    end
    
    submitBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if validateKey(keyInput.Text) then
                dialogFrame:Destroy()
                self.WindowVisible = true
                self.MainContainer.Visible = true
            else
                errorLabel.Text = "Invalid key! Please try again."
                TweenObject(errorLabel, {TextTransparency = 0})
                task.wait(2)
                TweenObject(errorLabel, {TextTransparency = 1})
            end
        end
    end)
    
    getKeyBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if keyConfig.GetKey then
                keyConfig.GetKey()
            end
        end
    end)
end

function PremiumUI:ToggleTheme()
    self.CurrentTheme = self.CurrentTheme == "Dark" and "Light" or "Dark"
    self.ThemeColors = Themes[self.CurrentTheme]
    
    -- Update all UI elements colors
    self.WindowFrame.BackgroundColor3 = self.ThemeColors.Background
    self.TitleBar.BackgroundColor3 = self.ThemeColors.Surface
    self.TabContainer.BackgroundColor3 = self.ThemeColors.Surface
    
    for _, tab in ipairs(self.Tabs) do
        if tab.Button then
            tab.Button.BackgroundColor3 = self.ThemeColors.Surface
            tab.Button.TextColor3 = self.ThemeColors.Text
        end
    end
    
    if self.CurrentTab then
        self.CurrentTab:Show()
    end
end

function PremiumUI:Minimize()
    local targetSize = self.WindowVisible and UDim2.new(0, 800, 0, 48) or UDim2.new(0, 800, 0, 550)
    self.WindowVisible = not self.WindowVisible
    
    TweenObject(self.MainContainer, {Size = targetSize})
    TweenObject(self.ContentContainer, {BackgroundTransparency = self.WindowVisible and 1 or 0})
    TweenObject(self.TabContainer, {BackgroundTransparency = self.WindowVisible and 0.5 or 1})
end

function PremiumUI:Close()
    self.ScreenGui:Destroy()
end

function PremiumUI:CreateTab(name, icon)
    local tab = {}
    tab.Name = name
    tab.Icon = icon or "circle"
    tab.Parent = self
    tab.Elements = {}
    tab.Container = Instance.new("Frame")
    tab.Container.Parent = self.ScrollingFrame
    tab.Container.Size = UDim2.new(1, 0, 0, 0)
    tab.Container.BackgroundTransparency = 1
    tab.Container.LayoutOrder = #self.Tabs + 1
    tab.Container.Visible = false
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = tab.Container
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 12)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.Container.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    -- Tab button
    local tabBtn = CreateRoundedFrame(self.TabContainer, UDim2.new(0, 100, 1, -8), UDim2.new(0, 8 + (#self.Tabs * 108), 0, 4), self.ThemeColors.Surface, 0, 8)
    local btnText = CreateTextLabel(tabBtn, icon .. " " .. name, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Text, 0, Enum.Font.GothamMedium, 13, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
    
    tabBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, t in ipairs(self.Tabs) do
                t.Container.Visible = false
                t.Button.BackgroundTransparency = 0.5
                t.Button.TextColor3 = self.ThemeColors.TextSecondary
            end
            tab.Container.Visible = true
            tabBtn.BackgroundTransparency = 0
            btnText.TextColor3 = self.ThemeColors.Accent
            self.CurrentTab = tab
        end
    end)
    
    tab.Button = tabBtn
    tab.ButtonText = btnText
    table.insert(self.Tabs, tab)
    
    -- Show first tab
    if #self.Tabs == 1 then
        tab.Container.Visible = true
        tabBtn.BackgroundTransparency = 0
        btnText.TextColor3 = self.ThemeColors.Accent
        self.CurrentTab = tab
    end
    
    function tab:Show()
        tab.Container.Visible = true
        tabBtn.BackgroundTransparency = 0
        btnText.TextColor3 = self.ThemeColors.Accent
    end
    
    function tab:AddSection(title)
        local section = {}
        local sectionFrame = CreateRoundedFrame(tab.Container, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self.ThemeColors.Surface, 0.3, 10)
        sectionFrame.LayoutOrder = #tab.Elements + 1
        
        local sectionTitle = CreateTextLabel(sectionFrame, title, UDim2.new(1, -24, 0, 24), UDim2.new(0, 12, 0, 8), self.ThemeColors.Text, 0, Enum.Font.GothamBold, 14)
        
        section.Content = Instance.new("Frame")
        section.Content.Parent = sectionFrame
        section.Content.Size = UDim2.new(1, 0, 0, 0)
        section.Content.Position = UDim2.new(0, 0, 0, 40)
        section.Content.BackgroundTransparency = 1
        
        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.Parent = section.Content
        sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sectionLayout.Padding = UDim.new(0, 8)
        
        sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sectionFrame.Size = UDim2.new(1, 0, 0, 40 + sectionLayout.AbsoluteContentSize.Y)
            section.Content.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y)
        end)
        
        function section:AddElement(elementType, elementConfig)
            return tab:AddElement(elementType, elementConfig, section.Content)
        end
        
        table.insert(tab.Elements, section)
        return section
    end
    
    function tab:AddElement(elementType, config, parent)
        parent = parent or tab.Container
        local element = {}
        
        if elementType == "button" then
            local btnFrame = CreateRoundedFrame(parent, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), self.ThemeColors.Surface, 0.2, 8)
            btnFrame.LayoutOrder = #tab.Elements + 1
            local btnText = CreateTextLabel(btnFrame, config.Text, UDim2.new(1, -80, 1, 0), UDim2.new(0, 12, 0, 0), self.ThemeColors.Text, 0, Enum.Font.GothamMedium, 14)
            local btnClick = CreateRoundedFrame(btnFrame, UDim2.new(0, 60, 0, 30), UDim2.new(1, -72, 0.5, -15), self.ThemeColors.Accent, 0, 6)
            local clickText = CreateTextLabel(btnClick, config.ButtonText or "Click", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Background, 0, Enum.Font.GothamMedium, 12, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
            
            btnClick.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    TweenObject(btnClick, {BackgroundTransparency = 0.3})
                    task.wait(0.1)
                    TweenObject(btnClick, {BackgroundTransparency = 0})
                    if config.Callback then config.Callback() end
                end
            end)
            
        elseif elementType == "toggle" then
            local toggleFrame = CreateRoundedFrame(parent, UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 0), self.ThemeColors.Surface, 0.2, 8)
            toggleFrame.LayoutOrder = #tab.Elements + 1
            local toggleText = CreateTextLabel(toggleFrame, config.Text, UDim2.new(1, -70, 1, 0), UDim2.new(0, 12, 0, 0), self.ThemeColors.Text, 0, Enum.Font.GothamMedium, 14)
            local toggleBtn = CreateRoundedFrame(toggleFrame, UDim2.new(0, 50, 0, 26), UDim2.new(1, -62, 0.5, -13), config.Default and self.ThemeColors.ToggleOn or self.ThemeColors.ToggleOff, 0, 13)
            local toggleCircle = CreateRoundedFrame(toggleBtn, UDim2.new(0, 22, 0, 22), UDim2.new(config.Default and 0.52 or 0.02, 0, 0.5, -11), Color3.fromRGB(255, 255, 255), 0, 11)
            
            local toggled = config.Default or false
            
            local function updateToggle()
                local newColor = toggled and self.ThemeColors.ToggleOn or self.ThemeColors.ToggleOff
                local newPos = toggled and 0.52 or 0.02
                TweenObject(toggleBtn, {BackgroundColor3 = newColor})
                TweenObject(toggleCircle, {Position = UDim2.new(newPos, 0, 0.5, -11)})
                if config.Callback then config.Callback(toggled) end
            end
            
            toggleBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggled = not toggled
                    updateToggle()
                end
            end)
            
            updateToggle()
            
        elseif elementType == "slider" then
            local sliderFrame = CreateRoundedFrame(parent, UDim2.new(1, 0, 0, 70), UDim2.new(0, 0, 0, 0), self.ThemeColors.Surface, 0.2, 8)
            sliderFrame.LayoutOrder = #tab.Elements + 1
            local sliderText = CreateTextLabel(sliderFrame, config.Text, UDim2.new(1, -100, 0, 24), UDim2.new(0, 12, 0, 8), self.ThemeColors.Text, 0, Enum.Font.GothamMedium, 14)
            local valueLabel = CreateTextLabel(sliderFrame, tostring(config.Default or config.Min), UDim2.new(0, 80, 0, 24), UDim2.new(1, -92, 0, 8), self.ThemeColors.TextSecondary, 0, Enum.Font.Gotham, 12, Enum.TextXAlignment.Right)
            
            local sliderBg = CreateRoundedFrame(sliderFrame, UDim2.new(1, -24, 0, 4), UDim2.new(0, 12, 0, 44), self.ThemeColors.SliderBg, 0, 2)
            local sliderFill = CreateRoundedFrame(sliderBg, UDim2.new((config.Default or config.Min - config.Min) / (config.Max - config.Min), 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Accent, 0, 2)
            local sliderKnob = CreateRoundedFrame(sliderBg, UDim2.new(0, 12, 0, 12), UDim2.new((config.Default or config.Min - config.Min) / (config.Max - config.Min), -6, 0.5, -6), self.ThemeColors.Accent, 0, 6)
            
            local value = config.Default or config.Min
            
            local function updateSlider(input)
                local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                value = config.Min + (config.Max - config.Min) * relativeX
                value = math.floor(value * (1 / (config.Interval or 1)) + 0.5) / (1 / (config.Interval or 1))
                value = math.clamp(value, config.Min, config.Max)
                sliderFill.Size = UDim2.new((value - config.Min) / (config.Max - config.Min), 0, 1, 0)
                sliderKnob.Position = UDim2.new((value - config.Min) / (config.Max - config.Min), -6, 0.5, -6)
                valueLabel.Text = tostring(value)
                if config.Callback then config.Callback(value) end
            end
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateSlider(input)
                    local connection
                    connection = UserInputService.InputChanged:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseMovement then
                            updateSlider(input2)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input2)
                        if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                            connection:Disconnect()
                        end
                    end)
                end
            end)
            
        elseif elementType == "dropdown" then
            local dropdownFrame = CreateRoundedFrame(parent, UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 0), self.ThemeColors.Surface, 0.2, 8)
            dropdownFrame.LayoutOrder = #tab.Elements + 1
            local dropdownText = CreateTextLabel(dropdownFrame, config.Text, UDim2.new(1, -100, 1, 0), UDim2.new(0, 12, 0, 0), self.ThemeColors.Text, 0, Enum.Font.GothamMedium, 14)
            local dropdownBtn = CreateRoundedFrame(dropdownFrame, UDim2.new(0, 120, 0, 32), UDim2.new(1, -132, 0.5, -16), self.ThemeColors.DropdownBg, 0, 6)
            local selectedText = CreateTextLabel(dropdownBtn, config.Default or "Select", UDim2.new(1, -20, 1, 0), UDim2.new(0, 8, 0, 0), self.ThemeColors.Text, 0, Enum.Font.Gotham, 12)
            local arrow = CreateTextLabel(dropdownBtn, "▼", UDim2.new(0, 20, 1, 0), UDim2.new(1, -28, 0, 0), self.ThemeColors.TextSecondary, 0, Enum.Font.Gotham, 10, Enum.TextXAlignment.Center)
            
            local dropdownList = nil
            local expanded = false
            
            dropdownBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if expanded then
                        dropdownList:Destroy()
                        expanded = false
                    else
                        dropdownList = CreateRoundedFrame(dropdownFrame, UDim2.new(0, 200, 0, 120), UDim2.new(1, -212, 0, 45), self.ThemeColors.DropdownBg, 0, 6)
                        dropdownList.ZIndex = 10
                        local listLayout = Instance.new("UIListLayout")
                        listLayout.Parent = dropdownList
                        listLayout.Padding = UDim.new(0, 2)
                        
                        for _, option in ipairs(config.Options) do
                            local optBtn = CreateRoundedFrame(dropdownList, UDim2.new(1, -8, 0, 30), UDim2.new(0, 4, 0, 0), self.ThemeColors.Surface, 0.5, 4)
                            local optText = CreateTextLabel(optBtn, option, UDim2.new(1, 0, 1, 0), UDim2.new(0, 8, 0, 0), self.ThemeColors.Text, 0, Enum.Font.Gotham, 12)
                            optBtn.InputBegan:Connect(function(input2)
                                if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                                    selectedText.Text = option
                                    if config.Callback then config.Callback(option) end
                                    dropdownList:Destroy()
                                    expanded = false
                                end
                            end)
                        end
                        expanded = true
                    end
                end
            end)
            
        elseif elementType == "input" then
            local inputFrame, inputBox = CreateTextBox(parent, config.Placeholder or "Enter text...", UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 0), self.ThemeColors.Text, self.ThemeColors.InputBg, 8)
            inputFrame.LayoutOrder = #tab.Elements + 1
            inputFrame.BackgroundTransparency = 0.2
            local inputLabel = CreateTextLabel(inputFrame, config.Text, UDim2.new(1, -120, 0, 20), UDim2.new(0, 12, 0, 4), self.ThemeColors.Text, 0, Enum.Font.GothamMedium, 12)
            inputBox.Position = UDim2.new(0, 12, 0, 24)
            inputBox.Size = UDim2.new(1, -24, 0, 18)
            
            inputBox.FocusLost:Connect(function(enterPressed)
                if config.Callback then config.Callback(inputBox.Text) end
            end)
            
        elseif elementType == "keybind" then
            local keybindFrame = CreateRoundedFrame(parent, UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 0), self.ThemeColors.Surface, 0.2, 8)
            keybindFrame.LayoutOrder = #tab.Elements + 1
            local keybindText = CreateTextLabel(keybindFrame, config.Text, UDim2.new(1, -120, 1, 0), UDim2.new(0, 12, 0, 0), self.ThemeColors.Text, 0, Enum.Font.GothamMedium, 14)
            local keybindBtn = CreateRoundedFrame(keybindFrame, UDim2.new(0, 100, 0, 32), UDim2.new(1, -112, 0.5, -16), self.ThemeColors.InputBg, 0, 6)
            local keyLabel = CreateTextLabel(keybindBtn, config.Default and tostring(config.Default) or "None", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Text, 0, Enum.Font.Gotham, 12, Enum.TextXAlignment.Center)
            
            local currentKey = config.Default
            local listening = false
            
            keybindBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if listening then
                        listening = false
                        keyLabel.Text = currentKey and tostring(currentKey) or "None"
                    else
                        listening = true
                        keyLabel.Text = "Press any key..."
                        local connection
                        connection = UserInputService.InputBegan:Connect(function(input2)
                            if listening and input2.UserInputType ~= Enum.UserInputType.MouseButton1 then
                                currentKey = input2.KeyCode
                                keyLabel.Text = tostring(currentKey)
                                listening = false
                                if config.Callback then config.Callback(currentKey) end
                                connection:Disconnect()
                            end
                        end)
                    end
                end
            end)
            
        elseif elementType == "paragraph" then
            local paraFrame = CreateRoundedFrame(parent, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Surface, 0.2, 8)
            paraFrame.LayoutOrder = #tab.Elements + 1
            local paraText = CreateTextLabel(paraFrame, config.Text, UDim2.new(1, -24, 0, 0), UDim2.new(0, 12, 0, 12), self.ThemeColors.Text, 0, Enum.Font.Gotham, 13)
            paraText.TextWrapped = true
            paraText.TextYAlignment = Enum.TextYAlignment.Top
            paraText.Size = UDim2.new(1, -24, 0, 0)
            
            task.wait()
            paraText.Size = UDim2.new(1, -24, 0, paraText.TextBounds.Y)
            paraFrame.Size = UDim2.new(1, 0, 0, paraText.TextBounds.Y + 24)
            
        elseif elementType == "code" then
            local codeFrame = CreateRoundedFrame(parent, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.CodeBg, 0.2, 8)
            codeFrame.LayoutOrder = #tab.Elements + 1
            local codeText = CreateTextLabel(codeFrame, config.Code, UDim2.new(1, -24, 0, 0), UDim2.new(0, 12, 0, 12), self.ThemeColors.Text, 0, Enum.Font.Code, 12)
            codeText.TextWrapped = true
            codeText.TextYAlignment = Enum.TextYAlignment.Top
            codeText.Size = UDim2.new(1, -24, 0, 0)
            
            task.wait()
            codeText.Size = UDim2.new(1, -24, 0, codeText.TextBounds.Y)
            codeFrame.Size = UDim2.new(1, 0, 0, codeText.TextBounds.Y + 24)
            
        elseif elementType == "colorpicker" then
            local colorFrame = CreateRoundedFrame(parent, UDim2.new(1, 0, 0, 45), UDim2.new(0, 0, 0, 0), self.ThemeColors.Surface, 0.2, 8)
            colorFrame.LayoutOrder = #tab.Elements + 1
            local colorText = CreateTextLabel(colorFrame, config.Text, UDim2.new(1, -70, 1, 0), UDim2.new(0, 12, 0, 0), self.ThemeColors.Text, 0, Enum.Font.GothamMedium, 14)
            local colorPreview = CreateRoundedFrame(colorFrame, UDim2.new(0, 32, 0, 32), UDim2.new(1, -44, 0.5, -16), config.Default or Color3.fromRGB(255, 255, 255), 0, 16)
            
            colorPreview.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- Simple color picker dialog
                    local pickerFrame = CreateRoundedFrame(self.ScreenGui, UDim2.new(0, 300, 0, 350), UDim2.new(0.5, -150, 0.5, -175), self.ThemeColors.Surface, 0, 12)
                    pickerFrame.ZIndex = 100
                    
                    local hueSlider = CreateRoundedFrame(pickerFrame, UDim2.new(1, -40, 0, 20), UDim2.new(0, 20, 0, 280), Color3.fromRGB(255, 0, 0), 0, 10)
                    local satSlider = CreateRoundedFrame(pickerFrame, UDim2.new(1, -40, 0, 20), UDim2.new(0, 20, 0, 310), Color3.fromRGB(255, 255, 255), 0, 10)
                    local brightSlider = CreateRoundedFrame(pickerFrame, UDim2.new(1, -40, 0, 20), UDim2.new(0, 20, 0, 340), Color3.fromRGB(255, 255, 255), 0, 10)
                    
                    local confirmBtn = CreateRoundedFrame(pickerFrame, UDim2.new(0, 80, 0, 32), UDim2.new(0.5, -40, 1, -42), self.ThemeColors.Accent, 0, 6)
                    local confirmText = CreateTextLabel(confirmBtn, "Confirm", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Background, 0, Enum.Font.GothamBold, 12, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
                    
                    local currentColor = config.Default or Color3.fromRGB(255, 255, 255)
                    local hue = 0
                    local sat = 1
                    local val = 1
                    
                    confirmBtn.InputBegan:Connect(function(btnInput)
                        if btnInput.UserInputType == Enum.UserInputType.MouseButton1 then
                            colorPreview.BackgroundColor3 = currentColor
                            if config.Callback then config.Callback(currentColor) end
                            pickerFrame:Destroy()
                        end
                    end)
                    
                    pickerFrame:Destroy()
                end
            end)
        end
        
        table.insert(tab.Elements, element)
        return element
    end
    
    -- Add helper methods for common elements
    function tab:AddButton(text, callback)
        return self:AddElement("button", {Text = text, Callback = callback})
    end
    
    function tab:AddToggle(text, default, callback)
        return self:AddElement("toggle", {Text = text, Default = default, Callback = callback})
    end
    
    function tab:AddSlider(text, min, max, default, interval, callback)
        return self:AddElement("slider", {Text = text, Min = min, Max = max, Default = default, Interval = interval, Callback = callback})
    end
    
    function tab:AddDropdown(text, options, default, callback)
        return self:AddElement("dropdown", {Text = text, Options = options, Default = default, Callback = callback})
    end
    
    function tab:AddInput(text, placeholder, callback)
        return self:AddElement("input", {Text = text, Placeholder = placeholder, Callback = callback})
    end
    
    function tab:AddKeybind(text, default, callback)
        return self:AddElement("keybind", {Text = text, Default = default, Callback = callback})
    end
    
    function tab:AddParagraph(text)
        return self:AddElement("paragraph", {Text = text})
    end
    
    function tab:AddCode(code)
        return self:AddElement("code", {Code = code})
    end
    
    function tab:AddColorPicker(text, default, callback)
        return self:AddElement("colorpicker", {Text = text, Default = default, Callback = callback})
    end
    
    return tab
end

function PremiumUI:Notify(title, message, duration)
    local notification = CreateRoundedFrame(self.ScreenGui, UDim2.new(0, 300, 0, 70), UDim2.new(1, -320, 0, 10), self.ThemeColors.Surface, 0, 8)
    notification.ZIndex = 200
    
    local titleLabel = CreateTextLabel(notification, title, UDim2.new(1, -16, 0, 24), UDim2.new(0, 8, 0, 4), self.ThemeColors.Text, 0, Enum.Font.GothamBold, 14)
    local messageLabel = CreateTextLabel(notification, message, UDim2.new(1, -16, 0, 32), UDim2.new(0, 8, 0, 28), self.ThemeColors.TextSecondary, 0, Enum.Font.Gotham, 12)
    messageLabel.TextWrapped = true
    
    local closeBtn = CreateRoundedFrame(notification, UDim2.new(0, 20, 0, 20), UDim2.new(1, -28, 0, 8), self.ThemeColors.Danger, 0, 10)
    local closeText = CreateTextLabel(closeBtn, "✕", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 255, 255), 0, Enum.Font.Gotham, 10, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
    
    local startPos = notification.Position
    notification.Position = UDim2.new(1, -320, 0, 10)
    TweenObject(notification, {Position = startPos})
    
    closeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenObject(notification, {Position = UDim2.new(1, -320, 0, 10)})
            task.wait(0.2)
            notification:Destroy()
        end
    end)
    
    if duration then
        task.wait(duration)
        if notification and notification.Parent then
            TweenObject(notification, {Position = UDim2.new(1, -320, 0, 10)})
            task.wait(0.2)
            notification:Destroy()
        end
    end
    
    table.insert(self.Notifications, notification)
end

function PremiumUI:Popup(title, content, buttons)
    local popupFrame = CreateRoundedFrame(self.ScreenGui, UDim2.new(0, 400, 0, 200), UDim2.new(0.5, -200, 0.5, -100), self.ThemeColors.Surface, 0, 12)
    popupFrame.ZIndex = 150
    popupFrame.BackgroundTransparency = 0
    
    local titleLabel = CreateTextLabel(popupFrame, title, UDim2.new(1, -24, 0, 40), UDim2.new(0, 12, 0, 12), self.ThemeColors.Text, 0, Enum.Font.GothamBold, 16)
    local contentLabel = CreateTextLabel(popupFrame, content, UDim2.new(1, -24, 0, 60), UDim2.new(0, 12, 0, 52), self.ThemeColors.TextSecondary, 0, Enum.Font.Gotham, 12)
    contentLabel.TextWrapped = true
    
    local btnContainer = Instance.new("Frame")
    btnContainer.Parent = popupFrame
    btnContainer.Size = UDim2.new(1, -24, 0, 40)
    btnContainer.Position = UDim2.new(0, 12, 1, -52)
    btnContainer.BackgroundTransparency = 1
    
    local btnLayout = Instance.new("UIListLayout")
    btnLayout.Parent = btnContainer
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    btnLayout.Padding = UDim.new(0, 8)
    
    for _, btn in ipairs(buttons) do
        local btnFrame = CreateRoundedFrame(btnContainer, UDim2.new(0, 80, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Accent, 0, 6)
        local btnText = CreateTextLabel(btnFrame, btn.Text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Background, 0, Enum.Font.GothamMedium, 12, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
        
        btnFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if btn.Callback then btn.Callback() end
                popupFrame:Destroy()
            end
        end)
    end
    
    table.insert(self.Popups, popupFrame)
end

function PremiumUI:Dialog(config)
    local dialogFrame = CreateRoundedFrame(self.ScreenGui, UDim2.new(0, 450, 0, 300), UDim2.new(0.5, -225, 0.5, -150), self.ThemeColors.Surface, 0, 12)
    dialogFrame.ZIndex = 150
    
    local titleLabel = CreateTextLabel(dialogFrame, config.Title, UDim2.new(1, -24, 0, 40), UDim2.new(0, 12, 0, 12), self.ThemeColors.Text, 0, Enum.Font.GothamBold, 18)
    local contentLabel = CreateTextLabel(dialogFrame, config.Content, UDim2.new(1, -24, 0, 120), UDim2.new(0, 12, 0, 52), self.ThemeColors.TextSecondary, 0, Enum.Font.Gotham, 12)
    contentLabel.TextWrapped = true
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    local closeBtn = CreateRoundedFrame(dialogFrame, UDim2.new(0, 100, 0, 36), UDim2.new(0.5, -50, 1, -48), self.ThemeColors.Accent, 0, 8)
    local closeText = CreateTextLabel(closeBtn, "Close", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), self.ThemeColors.Background, 0, Enum.Font.GothamBold, 14, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
    
    closeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if config.Callback then config.Callback() end
            dialogFrame:Destroy()
        end
    end)
    
    table.insert(self.Dialogs, dialogFrame)
end

function PremiumUI:TabSection(name)
    local section = self.CurrentTab:AddSection(name)
    return section
end

-- Return the UI constructor
return PremiumUI
