local Boreal = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui") or LocalPlayer.PlayerGui
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local ConfigFolder = "BorealConfigs"

local KeySystemData = {
    SavedKey = nil,
    IsAuthenticated = false
}

local WatermarkData = {
    Active = false,
    Frame = nil,
    UpdateConnection = nil
}

local ShineAnimation = {}
local shineConnections = {}

local function ClearAllShineAnimations()
    for _, c in ipairs(shineConnections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(shineConnections)
end

function ShineAnimation.Apply(theme, root)
    ClearAllShineAnimations()

    if not theme or not root or not getgenv().ShineEnabled or not theme.ShineEnabled or not theme.Shine then
        return
    end

    local ShineConfig = theme.Shine
    local Speed = ShineConfig.Speed or 0.5
    local RotationSpeed = ShineConfig.RotationSpeed or 25
    local ColorSequence = ShineConfig.ColorSequence
    
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("UIGradient") then
            local conn
            conn = RunService.RenderStepped:Connect(function(dt)
                local t = obj:GetAttribute("old_t") or 0
                t += dt * Speed
                obj:SetAttribute("old_t", t)
                obj.Rotation = (t * RotationSpeed) % 360
                obj.Color = ColorSequence
            end)
            table.insert(shineConnections, conn)
        end

        if obj:IsA("UIStroke") and theme.StrokeShine then
            local from = theme.StrokeDark or theme.AcrylicBorder
            local shine = theme.Accent
            local conn
            conn = RunService.RenderStepped:Connect(function(dt)
                local t = obj:GetAttribute("old_t") or 0
                t += dt * Speed
                obj.Thickness = 2
                obj:SetAttribute("old_t", t)
                obj.Color = from:Lerp(shine, (math.sin(t) + 1) / 2)
            end)
            table.insert(shineConnections, conn)
        end
    end
end

local function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.9
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button
        
        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = 0
        if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.Y * 1.5
        elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        end

        local Time = 0.5
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size/2, 0.5, -Size/2), "Out", "Quad", Time, false, nil)
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            wait(Time/10)
        end
        Circle:Destroy()
    end)
end

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        object.Position = pos
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdatePos(input)
        end
    end)
end

local function MakeDraggableMobileButton(button, object, screenGui)
    local Dragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    local ClickStartTime = 0
    local ClickStartPos = nil

    local function UpdatePos(input)
        local Delta = input.Position - DragStart
        local newX = StartPosition.X.Offset + Delta.X
        local newY = StartPosition.Y.Offset + Delta.Y
        
        local screenSize = screenGui.AbsoluteSize
        local buttonSize = object.AbsoluteSize
        
        local padding = 10
        newX = math.clamp(newX, padding, screenSize.X - buttonSize.X - padding)
        newY = math.clamp(newY, padding, screenSize.Y - buttonSize.Y - padding)
        
        object.Position = UDim2.new(0, newX, 0, newY)
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            ClickStartTime = tick()
            ClickStartPos = input.Position
            DragStart = input.Position
            StartPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    local dragTime = tick() - ClickStartTime
                    local dragDistance = (input.Position - ClickStartPos).Magnitude
                    
                    if dragTime < 0.2 and dragDistance < 5 then
                    end
                    Dragging = false
                end
            end)
        end
    end)

    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if not Dragging then
                local dragDistance = (input.Position - ClickStartPos).Magnitude
                if dragDistance > 5 then
                    Dragging = true
                end
            end
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            UpdatePos(input)
        end
    end)
    
    return function() return Dragging end
end

local function MakeResizable(resizeHandle, targetObject, minSize, maxSize, onResize)
    minSize = minSize or Vector2.new(300, 200)
    maxSize = maxSize or Vector2.new(1000, 800)
    
    local isResizing = false
    local resizeStartPos = nil
    local startSize = nil
    local startMousePos = nil
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            resizeStartPos = targetObject.Position
            startSize = targetObject.AbsoluteSize
            startMousePos = input.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isResizing = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startMousePos
            local newWidth = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
            local newHeight = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
            
            targetObject.Size = UDim2.new(0, newWidth, 0, newHeight)
            
            if onResize then
                onResize(Vector2.new(newWidth, newHeight))
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = false
        end
    end)
end

local ConfigSystem = {
    CurrentConfig = nil,
    Configs = {},
    ThemeColors = {
        ["Default"] = Color3.fromRGB(255, 0, 255),
        ["Blue"] = Color3.fromRGB(0, 120, 255),
        ["Red"] = Color3.fromRGB(255, 50, 50),
        ["Green"] = Color3.fromRGB(0, 200, 80),
        ["Orange"] = Color3.fromRGB(255, 120, 0),
        ["Purple"] = Color3.fromRGB(160, 0, 255),
        ["Cyan"] = Color3.fromRGB(0, 200, 255),
        ["Pink"] = Color3.fromRGB(255, 100, 200),
        ["Midnight"] = Color3.fromRGB(10, 30, 60),
        ["Ocean"] = Color3.fromRGB(0, 150, 200),
        ["Sunset"] = Color3.fromRGB(255, 100, 50),
        ["Gold"] = Color3.fromRGB(255, 200, 0),
        ["Emerald"] = Color3.fromRGB(0, 200, 150),
        ["Crimson"] = Color3.fromRGB(200, 0, 50),
        ["Lavender"] = Color3.fromRGB(180, 130, 255),
        ["Teal"] = Color3.fromRGB(0, 150, 150),
        ["Rose"] = Color3.fromRGB(255, 100, 150),
        ["Sky"] = Color3.fromRGB(100, 180, 255),
        ["Forest"] = Color3.fromRGB(0, 120, 80),
        ["Amber"] = Color3.fromRGB(255, 150, 0),
        ["Neon"] = Color3.fromRGB(0, 255, 200),
        ["Royal"] = Color3.fromRGB(100, 0, 200)
    },
    CurrentTheme = "Default",
    ThemeElements = {},
    ToggleElements = {},
    SliderElements = {},
    DropdownElements = {},
    TabElements = {},
    AllElements = {},
    DropdownOptionFrames = {}
}

function ConfigSystem:SetTheme(themeName)
    if self.ThemeColors[themeName] then
        self.CurrentTheme = themeName
        local newColor = self.ThemeColors[themeName]
        self:UpdateAllThemeElements(newColor)
        return true, newColor
    end
    return false, nil
end

function ConfigSystem:UpdateAllThemeElements(newColor)
    for _, toggle in pairs(self.ToggleElements) do
        if toggle and toggle:IsA("Frame") then
            local featureFrame = toggle:FindFirstChild("FeatureFrame")
            local toggleCircle = toggle:FindFirstChild("ToggleCircle")
            local frameStroke = featureFrame and featureFrame:FindFirstChild("UIStroke")
            local toggleTitle = toggle:FindFirstChild("ToggleTitle")
            
            if toggleCircle then
                local isOn = toggleCircle.Position == UDim2.new(0, 15, 0, 0)
                if isOn then
                    toggleCircle.BackgroundColor3 = newColor
                    if frameStroke then
                        frameStroke.Color = newColor
                    end
                    if featureFrame then
                        featureFrame.BackgroundColor3 = newColor
                    end
                    if toggleTitle then
                        toggleTitle.TextColor3 = newColor
                    end
                end
            end
        end
    end
    
    for _, slider in pairs(self.SliderElements) do
        if slider and slider:IsA("Frame") then
            local sliderFill = slider:FindFirstChild("SliderFill")
            if sliderFill then
                sliderFill.BackgroundColor3 = newColor
            end
        end
    end
    
    for _, dropdown in pairs(self.DropdownElements) do
        if dropdown and dropdown:IsA("Frame") then
            local dropdownList = dropdown:FindFirstChild("DropdownList")
            if dropdownList then
                local listScroll = dropdownList:FindFirstChild("ListScroll")
                if listScroll then
                    for _, option in listScroll:GetChildren() do
                        if option:IsA("Frame") and option.Name == "Option" then
                            local chooseFrame = option:FindFirstChild("ChooseFrame")
                            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
                            local optionText = option:FindFirstChild("OptionText")
                            
                            if chooseFrame then
                                chooseFrame.BackgroundColor3 = newColor
                            end
                            if chooseStroke then
                                chooseStroke.Color = newColor
                            end
                            if optionText and optionText.TextColor3 ~= Color3.fromRGB(230, 230, 230) then
                                optionText.TextColor3 = newColor
                            end
                        end
                    end
                end
            end
        end
    end
    
    for _, optionData in pairs(self.DropdownOptionFrames) do
        if optionData.Frame and optionData.Frame.Parent then
            local chooseFrame = optionData.Frame:FindFirstChild("ChooseFrame")
            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
            local optionText = optionData.Frame:FindFirstChild("OptionText")
            
            if optionData.IsSelected then
                if chooseFrame then
                    chooseFrame.BackgroundColor3 = newColor
                end
                if chooseStroke then
                    chooseStroke.Color = newColor
                end
                if optionText then
                    optionText.TextColor3 = newColor
                end
            end
        end
    end
    
    for _, tab in pairs(self.TabElements) do
        if tab and tab:IsA("Frame") then
            local chooseFrame = tab:FindFirstChild("ChooseFrame")
            local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
            
            if chooseFrame then
                chooseFrame.BackgroundColor3 = newColor
            end
            if chooseStroke then
                chooseStroke.Color = newColor
            end
        end
    end
    
    for _, element in pairs(self.ThemeElements) do
        if element and element:IsA("Frame") and element:FindFirstChild("ChooseFrame") then
            local chooseFrame = element.ChooseFrame
            if chooseFrame then
                chooseFrame.BackgroundColor3 = newColor
                local stroke = chooseFrame:FindFirstChild("UIStroke")
                if stroke then
                    stroke.Color = newColor
                end
            end
        elseif type(element) == "table" and element.Update then
            element.Update(newColor)
        end
    end
    
    return newColor
end

function ConfigSystem:EnsureFolder()
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
end

function ConfigSystem:SaveConfig(name, data)
    self:EnsureFolder()
    
    local configData = {
        Name = name,
        Theme = self.CurrentTheme,
        Data = data or {},
        SavedAt = os.time()
    }
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(configData)
    end)
    
    if success then
        writefile(ConfigFolder .. "/" .. name .. ".json", encoded)
        self.CurrentConfig = name
        
        return {
            Title = "Config",
            Description = "Saved",
            Content = "Config '" .. name .. "' saved successfully!",
            Color = self.ThemeColors[self.CurrentTheme],
            Delay = 3
        }
    else
        return {
            Title = "Config",
            Description = "Error",
            Content = "Failed to save config: " .. tostring(encoded),
            Color = Color3.fromRGB(255, 50, 50),
            Delay = 3
        }
    end
end

function ConfigSystem:LoadConfig(name)
    self:EnsureFolder()
    local filePath = ConfigFolder .. "/" .. name .. ".json"
    
    if isfile(filePath) then
        local success, content = pcall(function()
            return readfile(filePath)
        end)
        
        if success then
            local decodeSuccess, config = pcall(function()
                return HttpService:JSONDecode(content)
            end)
            
            if decodeSuccess and config then
                self.CurrentTheme = config.Theme or "Default"
                self.CurrentConfig = name
                
                return {
                    Title = "Config",
                    Description = "Loaded",
                    Content = "Config '" .. name .. "' loaded successfully!",
                    Color = self.ThemeColors[self.CurrentTheme],
                    Delay = 3
                }, config.Data
            end
        end
    end
    
    return {
        Title = "Config",
        Description = "Error",
        Content = "Config '" .. name .. "' not found or corrupted!",
        Color = Color3.fromRGB(255, 50, 50),
        Delay = 3
    }, nil
end

function ConfigSystem:DeleteConfig(name)
    self:EnsureFolder()
    local filePath = ConfigFolder .. "/" .. name .. ".json"
    
    if isfile(filePath) then
        local success = pcall(function()
            delfile(filePath)
        end)
        
        if success then
            if self.CurrentConfig == name then
                self.CurrentConfig = nil
            end
            
            return {
                Title = "Config",
                Description = "Deleted",
                Content = "Config '" .. name .. "' deleted successfully!",
                Color = self.ThemeColors[self.CurrentTheme],
                Delay = 3
            }
        end
    end
    
    return {
        Title = "Config",
        Description = "Error",
        Content = "Config '" .. name .. "' not found!",
        Color = Color3.fromRGB(255, 50, 50),
        Delay = 3
    }
end

function ConfigSystem:GetConfigList()
    self:EnsureFolder()
    local configs = {}
    
    local success, files = pcall(function()
        return listfiles(ConfigFolder)
    end)
    
    if success and files then
        for _, filePath in ipairs(files) do
            local fileName = filePath:match("([^/\\]+)%.json$")
            if fileName then
                table.insert(configs, fileName)
            end
        end
    end
    
    return configs
end

-- ==============================================
-- THEME MANAGER
-- ==============================================
local ThemeManager = {
    CurrentTheme = "Dark",
    Themes = {
        Dark = {
            Name = "Dark",
            Background = Color3.fromRGB(15, 15, 15),
            Text = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(0, 145, 255),
            Border = Color3.fromRGB(255, 255, 255),
            BorderTransparency = 0.75,
            TabBackground = Color3.fromRGB(24, 24, 27),
            TabText = Color3.fromRGB(255, 255, 255),
            SectionBackground = Color3.fromRGB(26, 26, 26),
            SectionHeader = Color3.fromRGB(42, 42, 42),
            SectionBorder = Color3.fromRGB(58, 58, 58),
            MultiSectionTab = Color3.fromRGB(32, 32, 32),
            MultiSectionTabHover = Color3.fromRGB(45, 45, 45),
            MultiSectionTabSelected = Color3.fromRGB(0, 145, 255),
        },
        Light = {
            Name = "Light",
            Background = Color3.fromRGB(240, 240, 240),
            Text = Color3.fromRGB(0, 0, 0),
            Accent = Color3.fromRGB(0, 145, 255),
            Border = Color3.fromRGB(0, 0, 0),
            BorderTransparency = 0.2,
            TabBackground = Color3.fromRGB(224, 224, 224),
            TabText = Color3.fromRGB(0, 0, 0),
            SectionBackground = Color3.fromRGB(255, 255, 255),
            SectionHeader = Color3.fromRGB(245, 245, 245),
            SectionBorder = Color3.fromRGB(204, 204, 204),
            MultiSectionTab = Color3.fromRGB(232, 232, 232),
            MultiSectionTabHover = Color3.fromRGB(208, 208, 208),
            MultiSectionTabSelected = Color3.fromRGB(0, 145, 255),
        }
    }
}

function ThemeManager:GetProperty(property, defaultValue)
    local theme = self.Themes[self.CurrentTheme]
    return theme and theme[property] ~= nil and theme[property] or defaultValue
end

function ThemeManager:SetTheme(themeName)
    if self.Themes[themeName] then
        self.CurrentTheme = themeName
        return true
    end
    return false
end

-- ==============================================
-- FULL SCREEN MANAGER
-- ==============================================
local FullScreenManager = {
    IsFullscreen = false,
    OriginalSize = nil,
    OriginalPosition = nil,
    Window = nil
}

function FullScreenManager:Initialize(window)
    self.Window = window
    self.OriginalSize = window.UI.Main.Size
    self.OriginalPosition = window.UI.Main.Position
    self:CreateFullscreenButton()
end

function FullScreenManager:CreateFullscreenButton()
    if not self.Window then return end
    
    if self.Window.TopBarButtons and self.Window.TopBarButtons.Fullscreen then
        return
    end
    
    local button = Instance.new("ImageButton")
    button.Name = "FullscreenButton"
    button.Size = UDim2.new(0, 24, 0, 24)
    button.BackgroundTransparency = 1
    button.Image = "rbxassetid://127426072704909"
    button.Parent = self.Window.UI.RightButtons
    
    button.MouseButton1Click:Connect(function()
        self:ToggleFullscreen()
    end)
    
    self.Window.TopBarButtons = self.Window.TopBarButtons or {}
    self.Window.TopBarButtons.Fullscreen = button
end

function FullScreenManager:ToggleFullscreen()
    if not self.Window then return end
    
    self.IsFullscreen = not self.IsFullscreen
    
    if self.IsFullscreen then
        self.OriginalSize = self.Window.UI.Main.Size
        self.OriginalPosition = self.Window.UI.Main.Position
        
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local fullSize = UDim2.new(0, viewportSize.X, 0, viewportSize.Y)
        local fullPosition = UDim2.new(0.5, 0, 0.5, 0)
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local sizeTween = TweenService:Create(self.Window.UI.Main, tweenInfo, {Size = fullSize})
        local posTween = TweenService:Create(self.Window.UI.Main, tweenInfo, {Position = fullPosition})
        
        sizeTween:Play()
        posTween:Play()
        
        local button = self.Window.TopBarButtons.Fullscreen
        if button then
            button.Image = "rbxassetid://10384619023"
        end
    else
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        local sizeTween = TweenService:Create(self.Window.UI.Main, tweenInfo, {Size = self.OriginalSize})
        local posTween = TweenService:Create(self.Window.UI.Main, tweenInfo, {Position = self.OriginalPosition})
        
        sizeTween:Play()
        posTween:Play()
        
        local button = self.Window.TopBarButtons.Fullscreen
        if button then
            button.Image = "rbxassetid://127426072704909"
        end
    end
end

-- ==============================================
-- MULTI SECTION MODULE
-- ==============================================
local MultiSectionModule = {
    Sections = {},
    CurrentSection = nil
}

function MultiSectionModule:CreateSection(parent, config)
    config = config or {}
    
    local section = {
        Name = config.Name or "Section",
        Title = config.Title or config.Name or "Section",
        Description = config.Description or "",
        Icon = config.Icon,
        IsOpen = config.IsOpen == nil and true or config.IsOpen,
        Elements = {},
        UI = {},
        Locked = config.Locked or false
    }
    
    local frame = Instance.new("Frame")
    frame.Name = "Section_" .. section.Name
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = parent
    
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = ThemeManager:GetProperty("SectionHeader", Color3.fromRGB(42, 42, 42))
    header.BackgroundTransparency = 0
    header.Text = ""
    header.AutoButtonColor = false
    header.Parent = frame
    
    local headerLayout = Instance.new("UIListLayout")
    headerLayout.FillDirection = Enum.FillDirection.Horizontal
    headerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    headerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    headerLayout.Padding = UDim.new(0, 8)
    headerLayout.Parent = header
    
    local headerPadding = Instance.new("UIPadding")
    headerPadding.PaddingLeft = UDim.new(0, 12)
    headerPadding.PaddingRight = UDim.new(0, 12)
    headerPadding.Parent = header
    
    if section.Icon then
        local iconLabel = Instance.new("ImageLabel")
        iconLabel.Size = UDim2.new(0, 20, 0, 20)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Image = section.Icon
        iconLabel.Parent = header
        section.UI.Icon = iconLabel
    end
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = section.Title
    title.TextColor3 = ThemeManager:GetProperty("Text", Color3.new(1,1,1))
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 16
    title.Parent = header
    section.UI.Title = title
    
    local expandIcon = Instance.new("ImageLabel")
    expandIcon.Name = "ExpandIcon"
    expandIcon.Size = UDim2.new(0, 16, 0, 16)
    expandIcon.BackgroundTransparency = 1
    expandIcon.Image = section.IsOpen and "rbxassetid://10384619023" or "rbxassetid://127426072704909"
    expandIcon.Parent = header
    section.UI.ExpandIcon = expandIcon
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Visible = section.IsOpen
    content.Parent = frame
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 12)
    contentPadding.PaddingRight = UDim.new(0, 12)
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 8)
    contentPadding.Parent = content
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.Parent = content
    
    header.MouseButton1Click:Connect(function()
        if section.Locked then return end
        section.IsOpen = not section.IsOpen
        content.Visible = section.IsOpen
        expandIcon.Image = section.IsOpen and "rbxassetid://10384619023" or "rbxassetid://127426072704909"
    end)
    
    header.MouseEnter:Connect(function()
        if section.Locked then return end
        TweenService:Create(header, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
    end)
    
    header.MouseLeave:Connect(function()
        if section.Locked then return end
        TweenService:Create(header, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
    end)
    
    function section:AddElement(elementType, elementConfig)
        local element = self:CreateElement(elementType, elementConfig)
        if element then
            element.Parent = content
            table.insert(self.Elements, element)
        end
        return element
    end
    
    function section:CreateElement(elementType, config)
        return nil
    end
    
    function section:Lock()
        self.Locked = true
        header.BackgroundTransparency = 0.5
        header.Active = false
    end
    
    function section:Unlock()
        self.Locked = false
        header.BackgroundTransparency = 0
        header.Active = true
    end
    
    table.insert(self.Sections, section)
    return section
end

function MultiSectionModule:CreateMultiSection(parent, config)
    config = config or {}
    
    local multiSection = {
        Name = config.Name or "MultiSection",
        Title = config.Title or config.Name or "MultiSection",
        Description = config.Description or "",
        Tabs = {},
        CurrentTab = nil,
        UI = {}
    }
    
    local container = Instance.new("Frame")
    container.Name = "MultiSection_" .. multiSection.Name
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundColor3 = ThemeManager:GetProperty("SectionBackground", Color3.fromRGB(26, 26, 26))
    container.BackgroundTransparency = 0.05
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 8)
    containerCorner.Parent = container
    
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, 40)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = container
    
    local tabBarLayout = Instance.new("UIListLayout")
    tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    tabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabBarLayout.Padding = UDim.new(0, 2)
    tabBarLayout.Parent = tabBar
    
    local tabBarPadding = Instance.new("UIPadding")
    tabBarPadding.PaddingLeft = UDim.new(0, 8)
    tabBarPadding.PaddingRight = UDim.new(0, 8)
    tabBarPadding.Parent = tabBar
    
    local contentArea = Instance.new("Frame")
    contentArea.Name = "Content"
    contentArea.Size = UDim2.new(1, 0, 0, 0)
    contentArea.BackgroundTransparency = 1
    contentArea.AutomaticSize = Enum.AutomaticSize.Y
    contentArea.Parent = container
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 12)
    contentPadding.PaddingRight = UDim.new(0, 12)
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 8)
    contentPadding.Parent = contentArea
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.Parent = contentArea
    
    function multiSection:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        
        local tab = {
            Name = tabConfig.Name or ("Tab_" .. tostring(#self.Tabs + 1)),
            Title = tabConfig.Title or tabConfig.Name or ("Tab " .. tostring(#self.Tabs + 1)),
            Icon = tabConfig.Icon,
            Elements = {},
            UI = {}
        }
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. tab.Name
        tabButton.Size = UDim2.new(0, 0, 0, 30)
        tabButton.AutomaticSize = Enum.AutomaticSize.X
        tabButton.BackgroundColor3 = ThemeManager:GetProperty("MultiSectionTab", Color3.fromRGB(32, 32, 32))
        tabButton.BackgroundTransparency = 0
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabBar
        
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, 6)
        tabButtonCorner.Parent = tabButton
        
        local tabButtonLayout = Instance.new("UIListLayout")
        tabButtonLayout.FillDirection = Enum.FillDirection.Horizontal
        tabButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        tabButtonLayout.Padding = UDim.new(0, 4)
        tabButtonLayout.Parent = tabButton
        
        local tabButtonPadding = Instance.new("UIPadding")
        tabButtonPadding.PaddingLeft = UDim.new(0, 8)
        tabButtonPadding.PaddingRight = UDim.new(0, 8)
        tabButtonPadding.Parent = tabButton
        
        if tab.Icon then
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 16, 0, 16)
            icon.BackgroundTransparency = 1
            icon.Image = tab.Icon
            icon.Parent = tabButton
            tab.UI.Icon = icon
        end
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0, 0, 1, 0)
        title.AutomaticSize = Enum.AutomaticSize.X
        title.BackgroundTransparency = 1
        title.Text = tab.Title
        title.TextColor3 = ThemeManager:GetProperty("Text", Color3.new(1,1,1))
        title.Font = Enum.Font.Gotham
        title.TextSize = 14
        title.Parent = tabButton
        tab.UI.Title = title
        tab.UI.Button = tabButton
        
        local tabContent = Instance.new("Frame")
        tabContent.Name = "Content_" .. tab.Name
        tabContent.Size = UDim2.new(1, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.AutomaticSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        tabContent.Parent = contentArea
        
        local tabContentLayout = Instance.new("UIListLayout")
        tabContentLayout.FillDirection = Enum.FillDirection.Vertical
        tabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        tabContentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        tabContentLayout.Padding = UDim.new(0, 6)
        tabContentLayout.Parent = tabContent
        
        tab.UI.Content = tabContent
        
        tabButton.MouseButton1Click:Connect(function()
            multiSection:SelectTab(tab)
        end)
        
        tabButton.MouseEnter:Connect(function()
            if multiSection.CurrentTab == tab then return end
            TweenService:Create(tabButton, TweenInfo.new(0.1), 
                {BackgroundColor3 = ThemeManager:GetProperty("MultiSectionTabHover", Color3.fromRGB(45, 45, 45))}
            ):Play()
        end)
        
        tabButton.MouseLeave:Connect(function()
            if multiSection.CurrentTab == tab then return end
            TweenService:Create(tabButton, TweenInfo.new(0.1), 
                {BackgroundColor3 = ThemeManager:GetProperty("MultiSectionTab", Color3.fromRGB(32, 32, 32))}
            ):Play()
        end)
        
        function tab:AddElement(elementType, elementConfig)
            return nil
        end
        
        table.insert(self.Tabs, tab)
        return tab
    end
    
    function multiSection:SelectTab(tab)
        if self.CurrentTab == tab then return end
        
        if self.CurrentTab then
            TweenService:Create(self.CurrentTab.UI.Button, TweenInfo.new(0.15), 
                {BackgroundColor3 = ThemeManager:GetProperty("MultiSectionTab", Color3.fromRGB(32, 32, 32))}
            ):Play()
            self.CurrentTab.UI.Content.Visible = false
        end
        
        self.CurrentTab = tab
        TweenService:Create(tab.UI.Button, TweenInfo.new(0.15), 
            {BackgroundColor3 = ThemeManager:GetProperty("MultiSectionTabSelected", Color3.fromRGB(0, 145, 255))}
        ):Play()
        tab.UI.Content.Visible = true
    end
    
    if config.Tabs then
        for _, tabConfig in ipairs(config.Tabs) do
            multiSection:AddTab(tabConfig)
        end
    else
        multiSection:AddTab({Title = "Main"})
    end
    
    if #multiSection.Tabs > 0 then
        multiSection:SelectTab(multiSection.Tabs[1])
    end
    
    table.insert(self.Sections, multiSection)
    return multiSection
end

-- ==============================================
-- CREATE WINDOW FUNCTION (from original Kairo)
-- ==============================================
local createMainUI

function Boreal:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Boreal UI"
    local Theme = config.Theme or "Default"
    local Size = config.Size or UDim2.fromOffset(520, 420)
    local Center = config.Center ~= false
    local Draggable = config.Draggable ~= false
    local Resizable = config.Resize or false
    local Badges = config.Badges or {}
    local MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
    local MinimizeButton = config.MinimizeButton or false
    local MinimizeButtonImage = config.MinimizeButton_Image or "rbxassetid://16932740082"
    local ConfigData = config.Config or {}
    local KeySystemConfig = config.KeySystem or {}
    
    if ConfigSystem.ThemeColors[Theme] then
        ConfigSystem.CurrentTheme = Theme
    end
    
    local shouldShowMainUI = true
    
    if KeySystemConfig.Enabled then
        shouldShowMainUI = false
        
        local KeyTitle = KeySystemConfig.Title or "Boreal Authentication"
        local KeySubtitle = KeySystemConfig.Subtitle or "Enter your key to continue"
        local KeyNote = KeySystemConfig.Note or "Get the key from our website"
        local KeySaveKey = KeySystemConfig.SaveKey ~= false
        local KeyLink = KeySystemConfig.KeyLink or ""
        local Keys = KeySystemConfig.Keys or {}
        local KeyFileName = KeySystemConfig.FileName or "Boreal_Key"
        
        if KeySaveKey then
            local savedKeyPath = ConfigFolder .. "/" .. KeyFileName .. ".txt"
            if isfile(savedKeyPath) then
                local savedKey = readfile(savedKeyPath)
                for _, validKey in ipairs(Keys) do
                    if savedKey == validKey then
                        KeySystemData.IsAuthenticated = true
                        KeySystemData.SavedKey = savedKey
                        shouldShowMainUI = true
                        break
                    end
                end
            end
        end
        
        if not shouldShowMainUI then
            local KeyGui = Instance.new("ScreenGui")
            KeyGui.Name = "BorealKeySystem"
            KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            KeyGui.Parent = CoreGui
            
            local KeyShadowHolder = Instance.new("Frame")
            KeyShadowHolder.BackgroundTransparency = 1
            KeyShadowHolder.BorderSizePixel = 0
            KeyShadowHolder.Size = UDim2.fromOffset(400, 280)
            KeyShadowHolder.Position = UDim2.new(0.5, -200, 0.5, -140)
            KeyShadowHolder.ZIndex = 100
            KeyShadowHolder.Name = "KeyShadowHolder"
            KeyShadowHolder.Parent = KeyGui
            
            local KeyShadow = Instance.new("ImageLabel")
            KeyShadow.Image = "rbxassetid://6015897843"
            KeyShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
            KeyShadow.ImageTransparency = 0.5
            KeyShadow.ScaleType = Enum.ScaleType.Slice
            KeyShadow.SliceCenter = Rect.new(49, 49, 450, 450)
            KeyShadow.AnchorPoint = Vector2.new(0.5, 0.5)
            KeyShadow.BackgroundTransparency = 1
            KeyShadow.BorderSizePixel = 0
            KeyShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
            KeyShadow.Size = UDim2.new(1, 47, 1, 47)
            KeyShadow.ZIndex = 100
            KeyShadow.Name = "KeyShadow"
            KeyShadow.Parent = KeyShadowHolder
            
            local KeyMain = Instance.new("Frame")
            KeyMain.AnchorPoint = Vector2.new(0.5, 0.5)
            KeyMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            KeyMain.BackgroundTransparency = 0.1
            KeyMain.BorderSizePixel = 0
            KeyMain.Position = UDim2.new(0.5, 0, 0.5, 0)
            KeyMain.Size = UDim2.new(1, -47, 1, -47)
            KeyMain.Name = "KeyMain"
            KeyMain.ZIndex = 101
            KeyMain.Parent = KeyShadow
            
            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 8)
            KeyCorner.Parent = KeyMain
            
            local KeyStroke = Instance.new("UIStroke")
            KeyStroke.Color = Color3.fromRGB(50, 50, 50)
            KeyStroke.Thickness = 1.6
            KeyStroke.Parent = KeyMain
            
            local KeyTop = Instance.new("Frame")
            KeyTop.BackgroundTransparency = 0.999
            KeyTop.Size = UDim2.new(1, 0, 0, 45)
            KeyTop.Name = "KeyTop"
            KeyTop.ZIndex = 102
            KeyTop.Parent = KeyMain
            
            local KeyTitleLabel = Instance.new("TextLabel")
            KeyTitleLabel.Font = Enum.Font.GothamBold
            KeyTitleLabel.Text = KeyTitle
            KeyTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            KeyTitleLabel.TextSize = 16
            KeyTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeyTitleLabel.BackgroundTransparency = 0.999
            KeyTitleLabel.Position = UDim2.new(0, 15, 0, 12)
            KeyTitleLabel.Size = UDim2.new(1, -30, 0, 20)
            KeyTitleLabel.ZIndex = 103
            KeyTitleLabel.Parent = KeyTop
            
            local KeySubtitleLabel = Instance.new("TextLabel")
            KeySubtitleLabel.Font = Enum.Font.GothamBold
            KeySubtitleLabel.Text = KeySubtitle
            KeySubtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            KeySubtitleLabel.TextSize = 12
            KeySubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeySubtitleLabel.BackgroundTransparency = 0.999
            KeySubtitleLabel.Position = UDim2.new(0, 15, 0, 50)
            KeySubtitleLabel.Size = UDim2.new(1, -30, 0, 15)
            KeySubtitleLabel.ZIndex = 102
            KeySubtitleLabel.Parent = KeyMain
            
            local KeyInputFrame = Instance.new("Frame")
            KeyInputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            KeyInputFrame.BackgroundTransparency = 0.95
            KeyInputFrame.BorderSizePixel = 0
            KeyInputFrame.Position = UDim2.new(0, 15, 0, 75)
            KeyInputFrame.Size = UDim2.new(1, -30, 0, 40)
            KeyInputFrame.ZIndex = 102
            KeyInputFrame.Parent = KeyMain
            
            local KeyInputCorner = Instance.new("UICorner")
            KeyInputCorner.CornerRadius = UDim.new(0, 6)
            KeyInputCorner.Parent = KeyInputFrame
            
            local KeyInput = Instance.new("TextBox")
            KeyInput.Font = Enum.Font.GothamBold
            KeyInput.PlaceholderText = "Enter Key Here..."
            KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            KeyInput.Text = ""
            KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            KeyInput.TextSize = 13
            KeyInput.BackgroundTransparency = 0.999
            KeyInput.Position = UDim2.new(0, 10, 0, 0)
            KeyInput.Size = UDim2.new(1, -20, 1, 0)
            KeyInput.ZIndex = 103
            KeyInput.Parent = KeyInputFrame
            
            local KeyNoteLabel = Instance.new("TextLabel")
            KeyNoteLabel.Font = Enum.Font.GothamBold
            KeyNoteLabel.Text = KeyNote
            KeyNoteLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            KeyNoteLabel.TextSize = 11
            KeyNoteLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeyNoteLabel.BackgroundTransparency = 0.999
            KeyNoteLabel.Position = UDim2.new(0, 15, 0, 125)
            KeyNoteLabel.Size = UDim2.new(1, -30, 0, 15)
            KeyNoteLabel.ZIndex = 102
            KeyNoteLabel.Parent = KeyMain
            
            local ButtonsFrame = Instance.new("Frame")
            ButtonsFrame.BackgroundTransparency = 0.999
            ButtonsFrame.Position = UDim2.new(0, 15, 0, 155)
            ButtonsFrame.Size = UDim2.new(1, -30, 0, 40)
            ButtonsFrame.ZIndex = 102
            ButtonsFrame.Parent = KeyMain
            
            local SubmitBtn = Instance.new("TextButton")
            SubmitBtn.Font = Enum.Font.GothamBold
            SubmitBtn.Text = "SUBMIT KEY"
            SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            SubmitBtn.TextSize = 12
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            SubmitBtn.BackgroundTransparency = 0.3
            SubmitBtn.BorderSizePixel = 0
            SubmitBtn.Size = UDim2.new(0.48, 0, 1, 0)
            SubmitBtn.ZIndex = 103
            SubmitBtn.Parent = ButtonsFrame
            
            local SubmitCorner = Instance.new("UICorner")
            SubmitCorner.CornerRadius = UDim.new(0, 6)
            SubmitCorner.Parent = SubmitBtn
            
            local GetKeyBtn = Instance.new("TextButton")
            GetKeyBtn.Font = Enum.Font.GothamBold
            GetKeyBtn.Text = "GET KEY"
            GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            GetKeyBtn.TextSize = 12
            GetKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            GetKeyBtn.BackgroundTransparency = 0.3
            GetKeyBtn.BorderSizePixel = 0
            GetKeyBtn.Position = UDim2.new(0.52, 0, 0, 0)
            GetKeyBtn.Size = UDim2.new(0.48, 0, 1, 0)
            GetKeyBtn.ZIndex = 103
            GetKeyBtn.Parent = ButtonsFrame
            
            local GetKeyCorner = Instance.new("UICorner")
            GetKeyCorner.CornerRadius = UDim.new(0, 6)
            GetKeyCorner.Parent = GetKeyBtn
            
            local StatusLabel = Instance.new("TextLabel")
            StatusLabel.Font = Enum.Font.GothamBold
            StatusLabel.Text = ""
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            StatusLabel.TextSize = 11
            StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
            StatusLabel.BackgroundTransparency = 0.999
            StatusLabel.Position = UDim2.new(0, 15, 0, 205)
            StatusLabel.Size = UDim2.new(1, -30, 0, 20)
            StatusLabel.ZIndex = 102
            StatusLabel.Parent = KeyMain
            
            local KeyClose = Instance.new("TextButton")
            KeyClose.Font = Enum.Font.SourceSans
            KeyClose.Text = ""
            KeyClose.BackgroundTransparency = 0.999
            KeyClose.Position = UDim2.new(1, -35, 0, 10)
            KeyClose.Size = UDim2.new(0, 25, 0, 25)
            KeyClose.ZIndex = 103
            KeyClose.Parent = KeyTop
            
            local KeyCloseIcon = Instance.new("ImageLabel")
            KeyCloseIcon.Image = "rbxassetid://9886659671"
            KeyCloseIcon.BackgroundTransparency = 0.999
            KeyCloseIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
            KeyCloseIcon.Size = UDim2.new(0, 16, 0, 16)
            KeyCloseIcon.ZIndex = 104
            KeyCloseIcon.Parent = KeyClose

            local function ValidateKey()
                local enteredKey = KeyInput.Text
                local isValid = false
                
                for _, validKey in ipairs(Keys) do
                    if enteredKey == validKey then
                        isValid = true
                        break
                    end
                end
                
                if isValid then
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                    StatusLabel.Text = "Key Valid! Access Granted."
                    
                    if KeySaveKey then
                        local savedKeyPath = ConfigFolder .. "/" .. KeyFileName .. ".txt"
                        ConfigSystem:EnsureFolder()
                        writefile(savedKeyPath, enteredKey)
                    end
                    
                    KeySystemData.IsAuthenticated = true
                    KeySystemData.SavedKey = enteredKey
                    
                    task.wait(0.5)
                    
                    TweenService:Create(KeyShadowHolder, TweenInfo.new(0.3), {Size = UDim2.fromOffset(0, 0)}):Play()
                    task.wait(0.3)
                    KeyGui:Destroy()
                    
                    createMainUI(config)
                else
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    StatusLabel.Text = "Invalid Key! Please try again."
                    
                    TweenService:Create(KeyInputFrame, TweenInfo.new(0.1), {Position = UDim2.new(0, 10, 0, 75)}):Play()
                    task.wait(0.05)
                    TweenService:Create(KeyInputFrame, TweenInfo.new(0.1), {Position = UDim2.new(0, 20, 0, 75)}):Play()
                    task.wait(0.05)
                    TweenService:Create(KeyInputFrame, TweenInfo.new(0.1), {Position = UDim2.new(0, 15, 0, 75)}):Play()
                end
            end
            
            SubmitBtn.Activated:Connect(function()
                CircleClick(SubmitBtn, Mouse.X, Mouse.Y)
                ValidateKey()
            end)
            
            GetKeyBtn.Activated:Connect(function()
                CircleClick(GetKeyBtn, Mouse.X, Mouse.Y)
                if KeyLink and KeyLink ~= "" then
                    pcall(function()
                        setclipboard(KeyLink)
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                        StatusLabel.Text = "Link copied to clipboard!"
                    end)
                else
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                    StatusLabel.Text = "No key link provided!"
                end
            end)
            
            KeyClose.Activated:Connect(function()
                KeyGui:Destroy()
            end)
            
            KeyInput.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    ValidateKey()
                end
            end)
            
            KeyShadowHolder.Size = UDim2.fromOffset(0, 0)
            TweenService:Create(KeyShadowHolder, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(400, 280)}):Play()
            
            return nil
        end
    end
    
    if shouldShowMainUI then
        return createMainUI(config)
    end
    
    return nil
end

createMainUI = function(config)
    local Title = config.Title or "Boreal UI"
    local Theme = config.Theme or "Default"
    local Size = config.Size or UDim2.fromOffset(520, 420)
    local Center = config.Center ~= false
    local Draggable = config.Draggable ~= false
    local Resizable = config.Resize or false
    local Badges = config.Badges or {}
    local MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
    local MinimizeButton = config.MinimizeButton or false
    local MinimizeButtonImage = config.MinimizeButton_Image or "rbxassetid://16932740082"
    local ConfigData = config.Config or {}
    
    if ConfigSystem.ThemeColors[Theme] then
        ConfigSystem.CurrentTheme = Theme
    end
    
    ThemeManager:SetTheme(Theme == "Default" and "Dark" or Theme)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Name = "BorealUI"
    ScreenGui.Parent = CoreGui

    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.Size = Size
    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = ScreenGui
    
    if Center then
        DropShadowHolder.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    end

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    local Main = Instance.new("Frame")
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = ThemeManager:GetProperty("Background", Color3.fromRGB(15, 15, 15))
    Main.BackgroundTransparency = 0.1
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Main

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(50, 50, 50)
    UIStroke.Thickness = 1.6
    UIStroke.Parent = Main

    local Top = Instance.new("Frame")
    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.999
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.Parent = Main

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 0.999
    TitleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleLabel.BorderSizePixel = 0
    TitleLabel.Size = UDim2.new(1, -150, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Parent = Top

    local BadgeContainer = Instance.new("Frame")
    BadgeContainer.Name = "BadgeContainer"
    BadgeContainer.BackgroundTransparency = 1
    BadgeContainer.Size = UDim2.new(0, 0, 1, 0)
    BadgeContainer.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
    BadgeContainer.Parent = Top
    
    local BadgeLayout = Instance.new("UIListLayout")
    BadgeLayout.FillDirection = Enum.FillDirection.Horizontal
    BadgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    BadgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BadgeLayout.Padding = UDim.new(0, 6)
    BadgeLayout.Parent = BadgeContainer
    
    local function UpdateBadgePosition()
        BadgeContainer.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
    end
    
    TitleLabel:GetPropertyChangedSignal("TextBounds"):Connect(UpdateBadgePosition)
    
    for _, badgeText in ipairs(Badges) do
        local Badge = Instance.new("TextLabel")
        Badge.Name = "Badge"
        Badge.Font = Enum.Font.GothamBold
        Badge.Text = badgeText
        Badge.TextColor3 = Color3.fromRGB(255, 255, 255)
        Badge.TextSize = 10
        Badge.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        Badge.BackgroundTransparency = 0.3
        Badge.BorderSizePixel = 0
        Badge.Size = UDim2.new(0, TextService:GetTextSize(badgeText, 10, Enum.Font.GothamBold, Vector2.new(999, 999)).X + 10, 0, 18)
        
        local BadgeCorner = Instance.new("UICorner")
        BadgeCorner.CornerRadius = UDim.new(0, 4)
        BadgeCorner.Parent = Badge
        
        Badge.Parent = BadgeContainer
        
        table.insert(ConfigSystem.ThemeElements, {
            Update = function(color)
                Badge.BackgroundColor3 = color
            end
        })
    end

    local Close = Instance.new("TextButton")
    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Close.BackgroundTransparency = 0.999
    Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Image = "rbxassetid://9886659671"
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseIcon.BackgroundTransparency = 0.999
    CloseIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseIcon.BorderSizePixel = 0
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.Size = UDim2.new(1, -8, 1, -8)
    CloseIcon.Parent = Close

    local Min = Instance.new("TextButton")
    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.TextColor3 = Color3.fromRGB(0, 0, 0)
    Min.TextSize = 14
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Min.BackgroundTransparency = 0.999
    Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(1, -42, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top

    local MinIcon = Instance.new("ImageLabel")
    MinIcon.Image = "rbxassetid://9886659276"
    MinIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinIcon.BackgroundTransparency = 0.999
    MinIcon.ImageTransparency = 0.2
    MinIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MinIcon.BorderSizePixel = 0
    MinIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinIcon.Size = UDim2.new(1, -9, 1, -9)
    MinIcon.Parent = Min

    local RightButtons = Instance.new("Frame")
    RightButtons.Name = "RightButtons"
    RightButtons.Size = UDim2.new(0, 100, 1, 0)
    RightButtons.BackgroundTransparency = 1
    RightButtons.Position = UDim2.new(1, -100, 0, 0)
    RightButtons.Parent = Top
    
    local RightLayout = Instance.new("UIListLayout")
    RightLayout.FillDirection = Enum.FillDirection.Horizontal
    RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    RightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    RightLayout.Padding = UDim.new(0, 8)
    RightLayout.Parent = RightButtons

    local ResizeHandle = nil
    if Resizable then
        ResizeHandle = Instance.new("TextButton")
        ResizeHandle.Name = "ResizeHandle"
        ResizeHandle.Text = ""
        ResizeHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ResizeHandle.BackgroundTransparency = 0.5
        ResizeHandle.BorderSizePixel = 0
        ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
        ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
        ResizeHandle.AutoButtonColor = false
        ResizeHandle.Parent = Main
        
        local ResizeCorner = Instance.new("UICorner")
        ResizeCorner.CornerRadius = UDim.new(0, 3)
        ResizeCorner.Parent = ResizeHandle
        
        local ResizeIcon = Instance.new("ImageLabel")
        ResizeIcon.Name = "ResizeIcon"
        ResizeIcon.Image = "rbxassetid://16932740082"
        ResizeIcon.BackgroundTransparency = 1
        ResizeIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
        ResizeIcon.Position = UDim2.new(0.15, 0, 0.15, 0)
        ResizeIcon.Rotation = 90
        ResizeIcon.Parent = ResizeHandle
        
        MakeResizable(ResizeHandle, DropShadowHolder, Vector2.new(400, 300), Vector2.new(1200, 900), function(newSize)
            Main.Size = UDim2.new(1, -47, 1, -47)
        end)
    end

    local TabFrame = Instance.new("Frame")
    TabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabFrame.BackgroundTransparency = 0.999
    TabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabFrame.BorderSizePixel = 0
    TabFrame.Position = UDim2.new(0, 9, 0, 50)
    TabFrame.Size = UDim2.new(0, 120, 1, -59)
    TabFrame.Name = "TabFrame"
    TabFrame.Parent = Main

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 2)
    TabCorner.Parent = TabFrame

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    TabScroll.ScrollBarThickness = 0
    TabScroll.Active = true
    TabScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabScroll.BackgroundTransparency = 0.999
    TabScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabScroll.BorderSizePixel = 0
    TabScroll.Size = UDim2.new(1, 0, 1, -50)
    TabScroll.Name = "TabScroll"
    TabScroll.Parent = TabFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 3)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabScroll

    local ContentFrame = Instance.new("Frame")
    ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentFrame.BackgroundTransparency = 0.999
    ContentFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 138, 0, 50)
    ContentFrame.Size = UDim2.new(1, -147, 1, -59)
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = Main

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 2)
    ContentCorner.Parent = ContentFrame

    local ContentTitle = Instance.new("TextLabel")
    ContentTitle.Font = Enum.Font.GothamBold
    ContentTitle.Text = "Main"
    ContentTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ContentTitle.TextSize = 24
    ContentTitle.TextWrapped = true
    ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
    ContentTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentTitle.BackgroundTransparency = 0.999
    ContentTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentTitle.BorderSizePixel = 0
    ContentTitle.Size = UDim2.new(1, 0, 0, 30)
    ContentTitle.Position = UDim2.new(0, 10, 0, 0)
    ContentTitle.Name = "ContentTitle"
    ContentTitle.Parent = ContentFrame

    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    ContentScroll.ScrollBarThickness = 4
    ContentScroll.ScrollBarImageColor3 = ThemeManager:GetProperty("Accent", Color3.fromRGB(0, 145, 255))
    ContentScroll.Active = true
    ContentScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentScroll.BackgroundTransparency = 0.999
    ContentScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ClipsDescendants = true
    ContentScroll.Position = UDim2.new(0, 10, 0, 35)
    ContentScroll.Size = UDim2.new(1, -20, 1, -35)
    ContentScroll.Name = "ContentScroll"
    ContentScroll.Parent = ContentFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentScroll

    local TabContents = {}
    local CurrentTab = nil
    local TabCount = 0
    local AllElements = {}

    local function UpdateTabSize()
        local OffsetY = 0
        for _, child in TabScroll:GetChildren() do
            if child:IsA("Frame") then
                OffsetY = OffsetY + 3 + child.Size.Y.Offset
            end
        end
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end

    local function UpdateContentSize()
        if CurrentTab and TabContents[CurrentTab] then
            local OffsetY = 0
            for _, child in TabContents[CurrentTab]:GetChildren() do
                if child:IsA("Frame") then
                    OffsetY = OffsetY + 8 + child.Size.Y.Offset
                end
            end
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
        end
    end

    TabScroll.ChildAdded:Connect(UpdateTabSize)
    TabScroll.ChildRemoved:Connect(UpdateTabSize)

    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)
        DropShadowHolder.Visible = false
    end)

    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        DropShadowHolder.Visible = false
    end)

    local OldPos = DropShadowHolder.Position
    local OldSize = DropShadowHolder.Size
    
    if Draggable then
        MakeDraggable(Top, DropShadowHolder)
    end

    local MobileMinimizeButton = nil
    if MinimizeButton then
        MobileMinimizeButton = Instance.new("Frame")
        MobileMinimizeButton.Name = "MobileMinimizeButton"
        MobileMinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        MobileMinimizeButton.BackgroundTransparency = 0.2
        MobileMinimizeButton.BorderSizePixel = 0
        MobileMinimizeButton.Size = UDim2.new(0, 50, 0, 50)
        MobileMinimizeButton.Position = UDim2.new(0, 20, 0, 100)
        MobileMinimizeButton.ZIndex = 100
        MobileMinimizeButton.Parent = ScreenGui
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(1, 0)
        ButtonCorner.Parent = MobileMinimizeButton
        
        local ButtonStroke = Instance.new("UIStroke")
        ButtonStroke.Color = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        ButtonStroke.Thickness = 0
        ButtonStroke.Parent = MobileMinimizeButton
        
        local ButtonImage = Instance.new("ImageLabel")
        ButtonImage.Name = "ButtonImage"
        ButtonImage.Image = MinimizeButtonImage
        ButtonImage.BackgroundTransparency = 1
        ButtonImage.Size = UDim2.new(0.7, 0, 0.7, 0)
        ButtonImage.Position = UDim2.new(0.15, 0, 0.15, 0)
        ButtonImage.ZIndex = 101
        ButtonImage.Parent = MobileMinimizeButton
        
        local ClickDetector = Instance.new("TextButton")
        ClickDetector.Name = "ClickDetector"
        ClickDetector.Text = ""
        ClickDetector.BackgroundTransparency = 1
        ClickDetector.Size = UDim2.new(1, 0, 1, 0)
        ClickDetector.ZIndex = 102
        ClickDetector.Parent = MobileMinimizeButton
        
        local isDragging = MakeDraggableMobileButton(ClickDetector, MobileMinimizeButton, ScreenGui)
        
        local lastClick = 0
        ClickDetector.Activated:Connect(function()
            local now = tick()
            if now - lastClick < 0.3 then return end
            lastClick = now
            
            if not isDragging() then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
                
                TweenService:Create(MobileMinimizeButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 45, 0, 45)}):Play()
                task.wait(0.1)
                TweenService:Create(MobileMinimizeButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 50, 0, 50)}):Play()
            end
        end)
        
        table.insert(ConfigSystem.ThemeElements, {
            Update = function(color)
                ButtonStroke.Color = color
            end
        })
    end

    local function CreateParagraph(tabContainer, title, content)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        
        local Paragraph = Instance.new("Frame")
        Paragraph.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Paragraph.BackgroundTransparency = 0.935
        Paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Paragraph.BorderSizePixel = 0
        Paragraph.Size = UDim2.new(1, 0, 0, 46)
        Paragraph.Name = "Paragraph"
        Paragraph.Parent = tabContainer

        local ParagraphCorner = Instance.new("UICorner")
        ParagraphCorner.CornerRadius = UDim.new(0, 4)
        ParagraphCorner.Parent = Paragraph

        local ParagraphTitle = Instance.new("TextLabel")
        ParagraphTitle.Font = Enum.Font.GothamBold
        ParagraphTitle.Text = title
        ParagraphTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ParagraphTitle.TextSize = 13
        ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphTitle.TextYAlignment = Enum.TextYAlignment.Top
        ParagraphTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphTitle.BackgroundTransparency = 0.999
        ParagraphTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ParagraphTitle.BorderSizePixel = 0
        ParagraphTitle.Position = UDim2.new(0, 10, 0, 10)
        ParagraphTitle.Size = UDim2.new(1, -20, 0, 13)
        ParagraphTitle.Name = "ParagraphTitle"
        ParagraphTitle.Parent = Paragraph

        local ParagraphContent = Instance.new("TextLabel")
        ParagraphContent.Font = Enum.Font.GothamBold
        ParagraphContent.Text = content
        ParagraphContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphContent.TextSize = 12
        ParagraphContent.TextTransparency = 0.6
        ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
        ParagraphContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ParagraphContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ParagraphContent.BackgroundTransparency = 0.999
        ParagraphContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ParagraphContent.BorderSizePixel = 0
        ParagraphContent.Position = UDim2.new(0, 10, 0, 23)
        ParagraphContent.Name = "ParagraphContent"
        ParagraphContent.Parent = Paragraph

        local textSize = TextService:GetTextSize(content, 12, Enum.Font.GothamBold, Vector2.new(ContentScroll.AbsoluteSize.X - 40, math.huge))
        
        ParagraphContent.Size = UDim2.new(1, -20, 0, textSize.Y)
        ParagraphContent.TextWrapped = true
        Paragraph.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))
        
        task.wait(0.1)
        UpdateContentSize()
        
        return Paragraph
    end

    local function CreateButton(tabContainer, title, content, iconId, callback)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        
        local Button = Instance.new("Frame")
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 0.935
        Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 0, 46)
        Button.Name = "Button"
        Button.Parent = tabContainer

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = Button

        local ButtonTitle = Instance.new("TextLabel")
        ButtonTitle.Font = Enum.Font.GothamBold
        ButtonTitle.Text = title
        ButtonTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ButtonTitle.TextSize = 13
        ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
        ButtonTitle.TextYAlignment = Enum.TextYAlignment.Top
        ButtonTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ButtonTitle.BackgroundTransparency = 0.999
        ButtonTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonTitle.BorderSizePixel = 0
        ButtonTitle.Position = UDim2.new(0, 10, 0, 10)
        ButtonTitle.Size = UDim2.new(1, -100, 0, 13)
        ButtonTitle.Name = "ButtonTitle"
        ButtonTitle.Parent = Button

        local ButtonContent = Instance.new("TextLabel")
        ButtonContent.Font = Enum.Font.GothamBold
        ButtonContent.Text = content
        ButtonContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonContent.TextSize = 12
        ButtonContent.TextTransparency = 0.6
        ButtonContent.TextXAlignment = Enum.TextXAlignment.Left
        ButtonContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ButtonContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ButtonContent.BackgroundTransparency = 0.999
        ButtonContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonContent.BorderSizePixel = 0
        ButtonContent.Position = UDim2.new(0, 10, 0, 23)
        ButtonContent.Name = "ButtonContent"
        ButtonContent.Parent = Button
        
        local textSize = TextService:GetTextSize(content, 12, Enum.Font.GothamBold, Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge))
        
        ButtonContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        ButtonContent.TextWrapped = true
        Button.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local ButtonButton = Instance.new("TextButton")
        ButtonButton.Font = Enum.Font.SourceSans
        ButtonButton.Text = ""
        ButtonButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.TextSize = 14
        ButtonButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.BackgroundTransparency = 0.999
        ButtonButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ButtonButton.BorderSizePixel = 0
        ButtonButton.Size = UDim2.new(1, 0, 1, 0)
        ButtonButton.Name = "ButtonButton"
        ButtonButton.Parent = Button

        local FeatureFrame = Instance.new("Frame")
        FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        FeatureFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BackgroundTransparency = 0.999
        FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BorderSizePixel = 0
        FeatureFrame.Position = UDim2.new(1, -15, 0.5, 0)
        FeatureFrame.Size = UDim2.new(0, 25, 0, 25)
        FeatureFrame.Name = "FeatureFrame"
        FeatureFrame.Parent = Button

        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.Image = iconId or "rbxassetid://16932740082"
        FeatureImg.AnchorPoint = Vector2.new(0.5, 0.5)
        FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        FeatureImg.BackgroundTransparency = 0.999
        FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        FeatureImg.Size = UDim2.new(1, 0, 1, 0)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = FeatureFrame

        ButtonButton.Activated:Connect(function()
            CircleClick(ButtonButton, Mouse.X, Mouse.Y)
            if callback then
                callback()
            end
        end)
        
        task.wait(0.1)
        UpdateContentSize()

        return Button
    end

    local function CreateToggle(tabContainer, title, content, defaultValue, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        
        local Toggle = Instance.new("Frame")
        Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.BackgroundTransparency = 0.935
        Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Toggle.BorderSizePixel = 0
        Toggle.Size = UDim2.new(1, 0, 0, 46)
        Toggle.Name = "Toggle"
        Toggle.Parent = tabContainer

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 4)
        ToggleCorner.Parent = Toggle

        local ToggleTitle = Instance.new("TextLabel")
        ToggleTitle.Font = Enum.Font.GothamBold
        ToggleTitle.Text = title
        ToggleTitle.TextSize = 13
        ToggleTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
        ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
        ToggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleTitle.BackgroundTransparency = 0.999
        ToggleTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleTitle.BorderSizePixel = 0
        ToggleTitle.Position = UDim2.new(0, 10, 0, 10)
        ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
        ToggleTitle.Name = "ToggleTitle"
        ToggleTitle.Parent = Toggle

        local ToggleContent = Instance.new("TextLabel")
        ToggleContent.Font = Enum.Font.GothamBold
        ToggleContent.Text = content
        ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleContent.TextSize = 12
        ToggleContent.TextTransparency = 0.6
        ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
        ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
        ToggleContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleContent.BackgroundTransparency = 0.999
        ToggleContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleContent.BorderSizePixel = 0
        ToggleContent.Position = UDim2.new(0, 10, 0, 23)
        ToggleContent.Size = UDim2.new(1, -100, 0, 12)
        ToggleContent.Name = "ToggleContent"
        ToggleContent.Parent = Toggle
        
        local textSize = TextService:GetTextSize(content, 12, Enum.Font.GothamBold, Vector2.new(ContentScroll.AbsoluteSize.X - 120, math.huge))
        
        ToggleContent.Size = UDim2.new(1, -100, 0, textSize.Y)
        ToggleContent.TextWrapped = true
        Toggle.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.TextSize = 14
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.BackgroundTransparency = 0.999
        ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Size = UDim2.new(1, 0, 1, 0)
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = Toggle

        local FeatureFrame = Instance.new("Frame")
        FeatureFrame.AnchorPoint = Vector2.new(1, 0.5)
        FeatureFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        FeatureFrame.BackgroundTransparency = 0.2
        FeatureFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureFrame.BorderSizePixel = 0
        FeatureFrame.Position = UDim2.new(1, -30, 0.5, 0)
        FeatureFrame.Size = UDim2.new(0, 30, 0, 15)
        FeatureFrame.Name = "FeatureFrame"
        FeatureFrame.Parent = Toggle

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.Parent = FeatureFrame

        local FrameStroke = Instance.new("UIStroke")
        FrameStroke.Color = Color3.fromRGB(100, 100, 100)
        FrameStroke.Thickness = 1.5
        FrameStroke.Transparency = 0
        FrameStroke.Parent = FeatureFrame

        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        ToggleCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Position = defaultValue and UDim2.new(0, 15, 0, 0) or UDim2.new(0, 0, 0, 0)
        ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
        ToggleCircle.Name = "ToggleCircle"
        ToggleCircle.Parent = FeatureFrame

        local CircleCorner = Instance.new("UICorner")
        CircleCorner.CornerRadius = UDim.new(0, 15)
        CircleCorner.Parent = ToggleCircle
        
        table.insert(ConfigSystem.ToggleElements, Toggle)
        
        local state = defaultValue or false
        
        local function SetState(value)
            state = value
            local themeColor = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            if value then
                TweenService:Create(
                    ToggleTitle,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {TextColor3 = themeColor}
                ):Play()
                TweenService:Create(
                    ToggleCircle,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {Position = UDim2.new(0, 15, 0, 0), BackgroundColor3 = themeColor}
                ):Play()
                TweenService:Create(
                    FrameStroke,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {Color = themeColor}
                ):Play()
                TweenService:Create(
                    FeatureFrame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {BackgroundTransparency = 0.2} 
                ):Play()
            else
                TweenService:Create(
                    ToggleTitle,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {TextColor3 = Color3.fromRGB(230, 230, 230)}
                ):Play()
                TweenService:Create(
                    ToggleCircle,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.fromRGB(200, 200, 200)}
                ):Play()
                TweenService:Create(
                    FrameStroke,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {Color = Color3.fromRGB(100, 100, 100)}
                ):Play()
                TweenService:Create(
                    FeatureFrame,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {BackgroundTransparency = 0.2}
                ):Play()
            end
            if callback then
                callback(state)
            end
        end
        
        SetState(state)
        
        ToggleButton.Activated:Connect(function()
            CircleClick(ToggleButton, Mouse.X, Mouse.Y) 
            SetState(not state)
        end)
        
        task.wait(0.1)
        UpdateContentSize()

        local toggleFunc = {
            Value = state,
            Set = SetState,
            Type = "Toggle",
            Id = elementId
        }
        
        if elementId then
            AllElements[elementId] = toggleFunc
        end
        
        return toggleFunc
    end

    local function CreateInput(tabContainer, title, content, placeholder, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        
        local Input = Instance.new("Frame")
        Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Input.BackgroundTransparency = 0.935
        Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Input.BorderSizePixel = 0
        Input.Size = UDim2.new(1, 0, 0, 46)
        Input.Name = "Input"
        Input.Parent = tabContainer

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 4)
        InputCorner.Parent = Input

        local InputTitle = Instance.new("TextLabel")
        InputTitle.Font = Enum.Font.GothamBold
        InputTitle.Text = title
        InputTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        InputTitle.TextSize = 13
        InputTitle.TextXAlignment = Enum.TextXAlignment.Left
        InputTitle.TextYAlignment = Enum.TextYAlignment.Top
        InputTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputTitle.BackgroundTransparency = 0.999
        InputTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputTitle.BorderSizePixel = 0
        InputTitle.Position = UDim2.new(0, 10, 0, 10)
        InputTitle.Size = UDim2.new(1, -180, 0, 13)
        InputTitle.Name = "InputTitle"
        InputTitle.Parent = Input

        local InputContent = Instance.new("TextLabel")
        InputContent.Font = Enum.Font.GothamBold
        InputContent.Text = content
        InputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputContent.TextSize = 12
        InputContent.TextTransparency = 0.6
        InputContent.TextWrapped = true
        InputContent.TextXAlignment = Enum.TextXAlignment.Left
        InputContent.TextYAlignment = Enum.TextYAlignment.Bottom
        InputContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputContent.BackgroundTransparency = 0.999
        InputContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputContent.BorderSizePixel = 0
        InputContent.Position = UDim2.new(0, 10, 0, 23)
        InputContent.Size = UDim2.new(1, -180, 0, 12)
        InputContent.Name = "InputContent"
        InputContent.Parent = Input
        
        local textSize = TextService:GetTextSize(content, 12, Enum.Font.GothamBold, Vector2.new(ContentScroll.AbsoluteSize.X - 200, math.huge))
        
        InputContent.Size = UDim2.new(1, -180, 0, textSize.Y)
        InputContent.TextWrapped = true
        Input.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local InputFrame = Instance.new("Frame")
        InputFrame.AnchorPoint = Vector2.new(1, 0.5)
        InputFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputFrame.BackgroundTransparency = 0.95
        InputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputFrame.BorderSizePixel = 0
        InputFrame.ClipsDescendants = true
        InputFrame.Position = UDim2.new(1, -7, 0.5, 0)
        InputFrame.Size = UDim2.new(0, 148, 0, 30)
        InputFrame.Name = "InputFrame"
        InputFrame.Parent = Input

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = InputFrame

        local InputTextBox = Instance.new("TextBox")
        InputTextBox.CursorPosition = -1
        InputTextBox.Font = Enum.Font.GothamBold
        InputTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
        InputTextBox.PlaceholderText = placeholder or "Write your input there"
        InputTextBox.Text = ""
        InputTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.TextSize = 12
        InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
        InputTextBox.AnchorPoint = Vector2.new(0, 0.5)
        InputTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        InputTextBox.BackgroundTransparency = 0.999
        InputTextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
        InputTextBox.BorderSizePixel = 0
        InputTextBox.Position = UDim2.new(0, 5, 0.5, 0)
        InputTextBox.Size = UDim2.new(1, -10, 1, -8)
        InputTextBox.Name = "InputTextBox"
        InputTextBox.Parent = InputFrame
        
        local inputFunc = {
            Value = "",
            Type = "Input",
            Id = elementId
        }
        
        function inputFunc:Set(value)
            InputTextBox.Text = value
            inputFunc.Value = value
            if callback then
                callback(value)
            end
        end
        
        InputTextBox.FocusLost:Connect(function(enterPressed)
            inputFunc:Set(InputTextBox.Text)
        end)
        
        task.wait(0.1)
        UpdateContentSize()

        if elementId then
            AllElements[elementId] = inputFunc
        end
        
        return inputFunc
    end

    local function CreateDropdown(tabContainer, title, content, options, multi, defaultValue, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        
        local Dropdown = Instance.new("Frame")
        Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Dropdown.BackgroundTransparency = 0.935
        Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Dropdown.BorderSizePixel = 0
        Dropdown.Size = UDim2.new(1, 0, 0, 46)
        Dropdown.Name = "Dropdown"
        Dropdown.Parent = tabContainer

        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.CornerRadius = UDim.new(0, 4)
        DropdownCorner.Parent = Dropdown

        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Font = Enum.Font.SourceSans
        DropdownButton.Text = ""
        DropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.TextSize = 14
        DropdownButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.BackgroundTransparency = 0.999
        DropdownButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownButton.BorderSizePixel = 0
        DropdownButton.Size = UDim2.new(1, 0, 1, 0)
        DropdownButton.Name = "DropdownButton"
        DropdownButton.Parent = Dropdown

        local DropdownTitle = Instance.new("TextLabel")
        DropdownTitle.Font = Enum.Font.GothamBold
        DropdownTitle.Text = title
        DropdownTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        DropdownTitle.TextSize = 13
        DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
        DropdownTitle.TextYAlignment = Enum.TextYAlignment.Top
        DropdownTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DropdownTitle.BackgroundTransparency = 0.999
        DropdownTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownTitle.BorderSizePixel = 0
        DropdownTitle.Position = UDim2.new(0, 10, 0, 10)
        DropdownTitle.Size = UDim2.new(1, -180, 0, 13)
        DropdownTitle.Name = "DropdownTitle"
        DropdownTitle.Parent = Dropdown

        local DropdownContent = Instance.new("TextLabel")
        DropdownContent.Font = Enum.Font.GothamBold
        DropdownContent.Text = content
        DropdownContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownContent.TextSize = 12
        DropdownContent.TextTransparency = 0.6
        DropdownContent.TextWrapped = true
        DropdownContent.TextXAlignment = Enum.TextXAlignment.Left
        DropdownContent.TextYAlignment = Enum.TextYAlignment.Bottom
        DropdownContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DropdownContent.BackgroundTransparency = 0.999
        DropdownContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownContent.BorderSizePixel = 0
        DropdownContent.Position = UDim2.new(0, 10, 0, 23)
        DropdownContent.Size = UDim2.new(1, -180, 0, 12)
        DropdownContent.Name = "DropdownContent"
        DropdownContent.Parent = Dropdown
        
        local textSize = TextService:GetTextSize(content, 12, Enum.Font.GothamBold, Vector2.new(ContentScroll.AbsoluteSize.X - 200, math.huge))
        
        DropdownContent.Size = UDim2.new(1, -180, 0, textSize.Y)
        DropdownContent.TextWrapped = true
        Dropdown.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33))

        local SelectOptionsFrame = Instance.new("Frame")
        SelectOptionsFrame.AnchorPoint = Vector2.new(1, 0.5)
        SelectOptionsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SelectOptionsFrame.BackgroundTransparency = 0.95
        SelectOptionsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SelectOptionsFrame.BorderSizePixel = 0
        SelectOptionsFrame.Position = UDim2.new(1, -7, 0.5, 0)
        SelectOptionsFrame.Size = UDim2.new(0, 148, 0, 30)
        SelectOptionsFrame.Name = "SelectOptionsFrame"
        SelectOptionsFrame.Parent = Dropdown

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 4)
        FrameCorner.Parent = SelectOptionsFrame

        local OptionSelecting = Instance.new("TextLabel")
        OptionSelecting.Font = Enum.Font.GothamBold
        OptionSelecting.Text = "Select Option"
        OptionSelecting.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionSelecting.TextSize = 12
        OptionSelecting.TextTransparency = 0.6
        OptionSelecting.TextWrapped = true
        OptionSelecting.TextXAlignment = Enum.TextXAlignment.Left
        OptionSelecting.AnchorPoint = Vector2.new(0, 0.5)
        OptionSelecting.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptionSelecting.BackgroundTransparency = 0.999
        OptionSelecting.BorderColor3 = Color3.fromRGB(0, 0, 0)
        OptionSelecting.BorderSizePixel = 0
        OptionSelecting.Position = UDim2.new(0, 5, 0.5, 0)
        OptionSelecting.Size = UDim2.new(1, -30, 1, -8)
        OptionSelecting.Name = "OptionSelecting"
        OptionSelecting.Parent = SelectOptionsFrame

        local OptionImg = Instance.new("ImageLabel")
        OptionImg.Image = "rbxassetid://16851841101"
        OptionImg.ImageColor3 = Color3.fromRGB(230, 230, 230)
        OptionImg.AnchorPoint = Vector2.new(1, 0.5)
        OptionImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptionImg.BackgroundTransparency = 0.999
        OptionImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        OptionImg.BorderSizePixel = 0
        OptionImg.Position = UDim2.new(1, 0, 0.5, 0)
        OptionImg.Size = UDim2.new(0, 25, 0, 25)
        OptionImg.Name = "OptionImg"
        OptionImg.Parent = SelectOptionsFrame
        
        local DropdownList = Instance.new("Frame")
        DropdownList.AnchorPoint = Vector2.new(1, 0)
        DropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        DropdownList.BorderColor3 = Color3.fromRGB(0, 0, 0)
        DropdownList.BorderSizePixel = 0
        DropdownList.Position = UDim2.new(1, -12, 0, 35)
        DropdownList.Size = UDim2.new(0, 160, 0, 0)
        DropdownList.Name = "DropdownList"
        DropdownList.Visible = false
        DropdownList.ClipsDescendants = true
        DropdownList.ZIndex = 10
        DropdownList.Parent = ScreenGui

        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, 4)
        ListCorner.Parent = DropdownList

        local ListStroke = Instance.new("UIStroke")
        ListStroke.Color = Color3.fromRGB(255, 255, 255)
        ListStroke.Thickness = 2.5
        ListStroke.Transparency = 0.8
        ListStroke.Parent = DropdownList

        local ListScroll = Instance.new("ScrollingFrame")
        ListScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
        ListScroll.ScrollBarThickness = 0
        ListScroll.Active = true
        ListScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ListScroll.BackgroundTransparency = 0.999
        ListScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ListScroll.BorderSizePixel = 0
        ListScroll.Size = UDim2.new(1, -10, 1, -10)
        ListScroll.Position = UDim2.new(0, 5, 0, 5)
        ListScroll.Name = "ListScroll"
        ListScroll.ZIndex = 11
        ListScroll.Parent = DropdownList

        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Padding = UDim.new(0, 3)
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Parent = ListScroll
        
        table.insert(ConfigSystem.DropdownElements, Dropdown)
        
        local dropdownData = {
            Options = options or {},
            Value = multi and (defaultValue or {}) or defaultValue or nil,
            Multi = multi or false,
            Open = false,
            OptionFrames = {}
        }
        
        local function UpdateListSize()
            local totalHeight = 0
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") then
                    totalHeight = totalHeight + child.Size.Y.Offset + 3
                end
            end
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
            DropdownList.Size = UDim2.new(0, 160, 0, math.min(150, totalHeight + 10))
        end
        
        local function UpdateSelectedDisplay()
            if dropdownData.Multi then
                if #dropdownData.Value > 0 then
                    local displayText = ""
                    for i, v in ipairs(dropdownData.Value) do
                        if i > 3 then
                            displayText = displayText .. ", ..."
                            break
                        end
                        displayText = displayText .. (i > 1 and ", " or "") .. v
                    end
                    OptionSelecting.Text = displayText
                else
                    OptionSelecting.Text = "Select Option"
                end
            else
                OptionSelecting.Text = dropdownData.Value or "Select Option"
            end
        end
        
        local function ToggleDropdown()
            dropdownData.Open = not dropdownData.Open
            if dropdownData.Open then
                local dropdownAbsPos = Dropdown.AbsolutePosition
                local dropdownAbsSize = Dropdown.AbsoluteSize
                DropdownList.Position = UDim2.new(0, dropdownAbsPos.X + dropdownAbsSize.X - 172, 0, dropdownAbsPos.Y + dropdownAbsSize.Y + 5)
                
                DropdownList.Visible = true
                TweenService:Create(DropdownList, TweenInfo.new(0.3), {Size = UDim2.new(0, 160, 0, math.min(150, ListScroll.CanvasSize.Y.Offset + 10))}):Play()
                TweenService:Create(OptionImg, TweenInfo.new(0.3), {Rotation = 180}):Play()
            else
                TweenService:Create(DropdownList, TweenInfo.new(0.3), {Size = UDim2.new(0, 160, 0, 0)}):Play()
                TweenService:Create(OptionImg, TweenInfo.new(0.3), {Rotation = 0}):Play()
                task.wait(0.3)
                DropdownList.Visible = false
            end
        end
        
        local function CreateOption(optionName)
            local Option = Instance.new("Frame")
            Option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Option.BackgroundTransparency = 0.999
            Option.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Option.BorderSizePixel = 0
            Option.Size = UDim2.new(1, 0, 0, 30)
            Option.Name = "Option"
            Option.ZIndex = 12
            Option.Parent = ListScroll

            local OptionCorner = Instance.new("UICorner")
            OptionCorner.CornerRadius = UDim.new(0, 3)
            OptionCorner.Parent = Option

            local OptionButton = Instance.new("TextButton")
            OptionButton.Font = Enum.Font.GothamBold
            OptionButton.Text = ""
            OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            OptionButton.TextSize = 13
            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
            OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            OptionButton.BackgroundTransparency = 0.999
            OptionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            OptionButton.BorderSizePixel = 0
            OptionButton.Size = UDim2.new(1, 0, 1, 0)
            OptionButton.Name = "OptionButton"
            OptionButton.ZIndex = 13
            OptionButton.Parent = Option

            local OptionText = Instance.new("TextLabel")
            OptionText.Font = Enum.Font.GothamBold
            OptionText.Text = optionName
            OptionText.TextSize = 13
            OptionText.TextColor3 = Color3.fromRGB(230, 230, 230)
            OptionText.TextXAlignment = Enum.TextXAlignment.Left
            OptionText.TextYAlignment = Enum.TextYAlignment.Top
            OptionText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            OptionText.BackgroundTransparency = 0.999
            OptionText.BorderColor3 = Color3.fromRGB(0, 0, 0)
            OptionText.BorderSizePixel = 0
            OptionText.Position = UDim2.new(0, 8, 0, 8)
            OptionText.Size = UDim2.new(1, -16, 0, 13)
            OptionText.Name = "OptionText"
            OptionText.ZIndex = 14
            OptionText.Parent = Option

            local ChooseFrame = Instance.new("Frame")
            ChooseFrame.AnchorPoint = Vector2.new(0, 0.5)
            ChooseFrame.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ChooseFrame.BorderSizePixel = 0
            ChooseFrame.Position = UDim2.new(0, 2, 0.5, 0)
            ChooseFrame.Size = UDim2.new(0, 0, 0, 0)
            ChooseFrame.Name = "ChooseFrame"
            ChooseFrame.ZIndex = 15
            ChooseFrame.Parent = Option
            
            local ChooseStroke = Instance.new("UIStroke")
            ChooseStroke.Color = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
            ChooseStroke.Thickness = 1.6
            ChooseStroke.Transparency = 0.999
            ChooseStroke.ZIndex = 16
            ChooseStroke.Parent = ChooseFrame
            
            local ChooseCorner = Instance.new("UICorner")
            ChooseCorner.Parent = ChooseFrame
            
            local optionId = HttpService:GenerateGUID(false)
            ConfigSystem.DropdownOptionFrames[optionId] = {
                Frame = Option,
                IsSelected = false
            }
            
            local function UpdateOptionVisual()
                local isSelected = false
                if dropdownData.Multi then
                    isSelected = table.find(dropdownData.Value, optionName) ~= nil
                else
                    isSelected = dropdownData.Value == optionName
                end
                
                ConfigSystem.DropdownOptionFrames[optionId].IsSelected = isSelected
                
                if isSelected then
                    TweenService:Create(ChooseStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
                    TweenService:Create(ChooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 1, 0, 12)}):Play()
                    TweenService:Create(Option, TweenInfo.new(0.2), {BackgroundTransparency = 0.935}):Play()
                    TweenService:Create(OptionText, TweenInfo.new(0.2), {TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]}):Play()
                else
                    TweenService:Create(ChooseStroke, TweenInfo.new(0.2), {Transparency = 0.999}):Play()
                    TweenService:Create(ChooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                    TweenService:Create(Option, TweenInfo.new(0.2), {BackgroundTransparency = 0.999}):Play()
                    TweenService:Create(OptionText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(230, 230, 230)}):Play()
                end
            end
            
            OptionButton.Activated:Connect(function()
                CircleClick(OptionButton, Mouse.X, Mouse.Y)
                
                if dropdownData.Multi then
                    local index = table.find(dropdownData.Value, optionName)
                    if index then
                        table.remove(dropdownData.Value, index)
                    else
                        table.insert(dropdownData.Value, optionName)
                    end
                    UpdateOptionVisual()
                else
                    for _, child in ListScroll:GetChildren() do
                        if child:IsA("Frame") and child.Name == "Option" then
                            local childOptionText = child:FindFirstChild("OptionText")
                            if childOptionText and childOptionText.Text ~= optionName then
                                local childChooseFrame = child:FindFirstChild("ChooseFrame")
                                local childChooseStroke = childChooseFrame and childChooseFrame:FindFirstChild("UIStroke")
                                
                                if childChooseStroke then
                                    TweenService:Create(childChooseStroke, TweenInfo.new(0.2), {Transparency = 0.999}):Play()
                                end
                                if childChooseFrame then
                                    TweenService:Create(childChooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                                end
                                TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.999}):Play()
                                TweenService:Create(childOptionText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(230, 230, 230)}):Play()
                                
                                for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                                    if data.Frame == child then
                                        data.IsSelected = false
                                    end
                                end
                            end
                        end
                    end
                    
                    dropdownData.Value = optionName
                    UpdateOptionVisual()
                end
                
                UpdateSelectedDisplay()
                
                if callback then
                    callback(dropdownData.Value)
                end
                
                if not dropdownData.Multi then
                    ToggleDropdown()
                end
            end)
            
            UpdateOptionVisual()
            return Option
        end
        
        for _, option in ipairs(dropdownData.Options) do
            CreateOption(option)
        end
        
        UpdateListSize()
        UpdateSelectedDisplay()
        
        DropdownButton.Activated:Connect(function()
            CircleClick(DropdownButton, Mouse.X, Mouse.Y)
            ToggleDropdown()
        end)
        
        local dropdownConnection
        dropdownConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if dropdownData.Open and DropdownList.Visible then
                    local mousePos = input.Position
                    local dropdownPos = DropdownList.AbsolutePosition
                    local dropdownSize = DropdownList.AbsoluteSize
                    local selectFramePos = SelectOptionsFrame.AbsolutePosition
                    local selectFrameSize = SelectOptionsFrame.AbsoluteSize
                    
                    if not (mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
                           mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y) and
                       not (mousePos.X >= selectFramePos.X and mousePos.X <= selectFramePos.X + selectFrameSize.X and
                           mousePos.Y >= selectFramePos.Y and mousePos.Y <= selectFramePos.Y + selectFrameSize.Y) then
                        ToggleDropdown()
                    end
                end
            end
        end)
        
        Dropdown.Destroying:Connect(function()
            if dropdownConnection then
                dropdownConnection:Disconnect()
            end
            for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                if data.Frame and data.Frame:IsDescendantOf(DropdownList) then
                    ConfigSystem.DropdownOptionFrames[id] = nil
                end
            end
            DropdownList:Destroy()
        end)
        
        task.wait(0.1)
        UpdateContentSize()

        local dropdownFunc = {
            Value = dropdownData.Value,
            Options = dropdownData.Options,
            Type = "Dropdown",
            Id = elementId
        }
        
        function dropdownFunc:Set(value)
            if dropdownData.Multi then
                dropdownData.Value = value or {}
            else
                dropdownData.Value = value
            end
            UpdateSelectedDisplay()
            
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") and child.Name == "Option" then
                    local optionName = child.OptionText.Text
                    local isSelected = false
                    if dropdownData.Multi then
                        isSelected = table.find(dropdownData.Value, optionName) ~= nil
                    else
                        isSelected = dropdownData.Value == optionName
                    end
                    
                    local chooseFrame = child:FindFirstChild("ChooseFrame")
                    local chooseStroke = chooseFrame and chooseFrame:FindFirstChild("UIStroke")
                    local optionText = child:FindFirstChild("OptionText")
                    if chooseFrame and chooseStroke and optionText then
                        if isSelected then
                            TweenService:Create(chooseStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
                            TweenService:Create(chooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 1, 0, 12)}):Play()
                            TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.935}):Play()
                            TweenService:Create(optionText, TweenInfo.new(0.2), {TextColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]}):Play()
                        else
                            TweenService:Create(chooseStroke, TweenInfo.new(0.2), {Transparency = 0.999}):Play()
                            TweenService:Create(chooseFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                            TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 0.999}):Play()
                            TweenService:Create(optionText, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(230, 230, 230)}):Play()
                        end
                    end
                end
            end
        end
        
        function dropdownFunc:Refresh(newOptions, newValue)
            for _, child in ListScroll:GetChildren() do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end
            
            for id, data in pairs(ConfigSystem.DropdownOptionFrames) do
                if data.Frame and data.Frame:IsDescendantOf(ListScroll) then
                    ConfigSystem.DropdownOptionFrames[id] = nil
                end
            end
            
            dropdownData.Options = newOptions or {}
            dropdownData.Value = newValue or (dropdownData.Multi and {} or nil)
            
            for _, option in ipairs(dropdownData.Options) do
                CreateOption(option)
            end
            
            UpdateListSize()
            UpdateSelectedDisplay()
            dropdownFunc.Value = dropdownData.Value
            dropdownFunc.Options = dropdownData.Options
        end
        
        if elementId then
            AllElements[elementId] = dropdownFunc
        end
        
        return dropdownFunc
    end

    local function CreateSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId)
        if not tabContainer or not tabContainer:IsA("Frame") then return end
        
        local Slider = Instance.new("Frame")
        Slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Slider.BackgroundTransparency = 0.935
        Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Slider.BorderSizePixel = 0
        Slider.Size = UDim2.new(1, 0, 0, 46)
        Slider.Name = "Slider"
        Slider.Parent = tabContainer

        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 4)
        SliderCorner.Parent = Slider

        local SliderTitle = Instance.new("TextLabel")
        SliderTitle.Font = Enum.Font.GothamBold
        SliderTitle.Text = title
        SliderTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
        SliderTitle.TextSize = 13
        SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
        SliderTitle.TextYAlignment = Enum.TextYAlignment.Top
        SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderTitle.BackgroundTransparency = 0.999
        SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderTitle.BorderSizePixel = 0
        SliderTitle.Position = UDim2.new(0, 10, 0, 10)
        SliderTitle.Size = UDim2.new(1, -60, 0, 13)
        SliderTitle.Name = "SliderTitle"
        SliderTitle.Parent = Slider

        local SliderContent = Instance.new("TextLabel")
        SliderContent.Font = Enum.Font.GothamBold
        SliderContent.Text = content
        SliderContent.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderContent.TextSize = 12
        SliderContent.TextTransparency = 0.6
        SliderContent.TextXAlignment = Enum.TextXAlignment.Left
        SliderContent.TextYAlignment = Enum.TextYAlignment.Bottom
        SliderContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderContent.BackgroundTransparency = 0.999
        SliderContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderContent.BorderSizePixel = 0
        SliderContent.Position = UDim2.new(0, 10, 0, 23)
        SliderContent.Size = UDim2.new(1, -60, 0, 12)
        SliderContent.Name = "SliderContent"
        SliderContent.Parent = Slider
        
        local textSize = TextService:GetTextSize(content, 12, Enum.Font.GothamBold, Vector2.new(ContentScroll.AbsoluteSize.X - 80, math.huge))
        
        SliderContent.Size = UDim2.new(1, -60, 0, textSize.Y)
        SliderContent.TextWrapped = true
        
        local ValueDisplay = Instance.new("TextLabel")
        ValueDisplay.Font = Enum.Font.GothamBold
        ValueDisplay.Text = tostring(defaultValue or minValue)
        ValueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
        ValueDisplay.TextSize = 13
        ValueDisplay.TextXAlignment = Enum.TextXAlignment.Right
        ValueDisplay.AnchorPoint = Vector2.new(1, 0)
        ValueDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ValueDisplay.BackgroundTransparency = 0.999
        ValueDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ValueDisplay.BorderSizePixel = 0
        ValueDisplay.Position = UDim2.new(1, -10, 0, 10)
        ValueDisplay.Size = UDim2.new(0, 40, 0, 13)
        ValueDisplay.Name = "ValueDisplay"
        ValueDisplay.Parent = Slider

        Slider.Size = UDim2.new(1, 0, 0, math.max(46, textSize.Y + 33 + 25))
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.AnchorPoint = Vector2.new(0, 0)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SliderFrame.BackgroundTransparency = 0.5
        SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Position = UDim2.new(0, 10, 0, textSize.Y + 33)
        SliderFrame.Size = UDim2.new(1, -20, 0, 3)
        SliderFrame.Name = "SliderFrame"
        SliderFrame.Parent = Slider

        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 2)
        FrameCorner.Parent = SliderFrame

        local SliderFill = Instance.new("Frame")
        SliderFill.AnchorPoint = Vector2.new(0, 0.5)
        SliderFill.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        SliderFill.BorderColor3 = Color3.fromRGB(0, 0, 0)
        SliderFill.BorderSizePixel = 0
        SliderFill.Position = UDim2.new(0, 0, 0.5, 0)
        SliderFill.Size = UDim2.new(0.5, 0, 0, 3)
        SliderFill.Name = "SliderFill"
        SliderFill.Parent = SliderFrame

        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(0, 2)
        FillCorner.Parent = SliderFill
        
        table.insert(ConfigSystem.SliderElements, SliderFrame)
        
        local sliderData = {
            Min = minValue or 0,
            Max = maxValue or 100,
            Value = defaultValue or minValue or 0,
            Dragging = false,
            TouchInput = nil
        }
        
        local function Round(num, decimalPlaces)
            local mult = 10^(decimalPlaces or 0)
            return math.floor(num * mult + 0.5) / mult
        end
        
        local function SetValue(value, instant)
            value = math.clamp(value, sliderData.Min, sliderData.Max)
            sliderData.Value = Round(value, 0)
            
            ValueDisplay.Text = tostring(sliderData.Value)
            
            local percentage = (sliderData.Value - sliderData.Min) / (sliderData.Max - sliderData.Min)
            
            if instant then
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            else
                TweenService:Create(
                    SliderFill,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(percentage, 0, 1, 0)}
                ):Play()
            end
            
            if callback then
                callback(sliderData.Value)
            end
        end
        
        local startValue = defaultValue or minValue or 0
        SetValue(startValue, true)
        
        local function UpdateSliderFromInput(input)
            local inputPos
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                inputPos = input.Position
            elseif input.UserInputType == Enum.UserInputType.Touch then
                inputPos = input.Position
            else
                return
            end
            
            local sliderPos = SliderFrame.AbsolutePosition
            local sliderSize = SliderFrame.AbsoluteSize
            
            local percentage = math.clamp((inputPos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local value = sliderData.Min + (percentage * (sliderData.Max - sliderData.Min))
            
            SetValue(value)
        end
        
        SliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliderData.Dragging = true
                sliderData.TouchInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
                UpdateSliderFromInput(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if sliderData.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
               (input.UserInputType == Enum.UserInputType.Touch and sliderData.TouchInput and input == sliderData.TouchInput)) then
                UpdateSliderFromInput(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 and sliderData.Dragging) or
               (input.UserInputType == Enum.UserInputType.Touch and sliderData.TouchInput and input == sliderData.TouchInput) then
                sliderData.Dragging = false
                sliderData.TouchInput = nil
            end
        end)
        
        task.wait(0.1)
        UpdateContentSize()

        local sliderFunc = {
            Value = sliderData.Value,
            Type = "Slider",
            Id = elementId
        }
        
        function sliderFunc:Set(value)
            SetValue(value)
            sliderFunc.Value = sliderData.Value
        end
        
        if elementId then
            AllElements[elementId] = sliderFunc
        end
        
        return sliderFunc
    end

    local function CreateTabButton(tabName, iconId, isConfigTab)
        TabCount = TabCount + 1
        
        local Tab = Instance.new("Frame")
        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Tab.BackgroundTransparency = 0.999
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.BorderSizePixel = 0
        Tab.Size = UDim2.new(1, 0, 0, 30)
        Tab.LayoutOrder = isConfigTab and 999 or TabCount
        Tab.Name = "Tab"
        Tab.Parent = TabScroll

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = Tab

        local TabButton = Instance.new("TextButton")
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 0.999
        TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = Tab

        local TabNameLabel = Instance.new("TextLabel")
        TabNameLabel.Font = Enum.Font.GothamBold
        TabNameLabel.Text = tabName
        TabNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabNameLabel.TextSize = 13
        TabNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabNameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabNameLabel.BackgroundTransparency = 0.999
        TabNameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabNameLabel.BorderSizePixel = 0
        TabNameLabel.Size = UDim2.new(1, 0, 1, 0)
        TabNameLabel.Position = UDim2.new(0, 30, 0, 0)
        TabNameLabel.Name = "TabName"
        TabNameLabel.Parent = Tab

        local FeatureImg = Instance.new("ImageLabel")
        FeatureImg.Image = iconId or ""
        FeatureImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        FeatureImg.BackgroundTransparency = 0.999
        FeatureImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        FeatureImg.BorderSizePixel = 0
        FeatureImg.Position = UDim2.new(0, 9, 0, 7)
        FeatureImg.Size = UDim2.new(0, 16, 0, 16)
        FeatureImg.Name = "FeatureImg"
        FeatureImg.Parent = Tab

        local ChooseFrame = Instance.new("Frame")
        ChooseFrame.BackgroundColor3 = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        ChooseFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ChooseFrame.BorderSizePixel = 0
        ChooseFrame.Position = UDim2.new(0, 2, 0, 9)
        ChooseFrame.Size = UDim2.new(0, 1, 0, 12)
        ChooseFrame.Name = "ChooseFrame"
        ChooseFrame.Parent = Tab
        ChooseFrame.Visible = false

        local ChooseStroke = Instance.new("UIStroke")
        ChooseStroke.Color = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        ChooseStroke.Thickness = 1.6
        ChooseStroke.Parent = ChooseFrame

        local ChooseCorner = Instance.new("UICorner")
        ChooseCorner.Parent = ChooseFrame
        
        table.insert(ConfigSystem.TabElements, Tab)
        
        local TabContentContainer = Instance.new("Frame")
        TabContentContainer.BackgroundTransparency = 1
        TabContentContainer.Size = UDim2.new(1, 0, 0, 0)
        TabContentContainer.Visible = false
        TabContentContainer.LayoutOrder = isConfigTab and 999 or TabCount
        TabContentContainer.Name = tabName.."Content"
        TabContentContainer.Parent = ContentScroll
        
        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 8)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = TabContentContainer

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContentContainer.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
        end)
        
        TabContents[tabName] = TabContentContainer
        
        local function SwitchToTab()
            for name, container in pairs(TabContents) do
                container.Visible = false
            end
            
            for _, tabFrame in TabScroll:GetChildren() do
                if tabFrame:IsA("Frame") and tabFrame.Name == "Tab" then
                    local chooseFrame = tabFrame:FindFirstChild("ChooseFrame")
                    if chooseFrame then
                        chooseFrame.Visible = false
                    end
                    tabFrame.BackgroundTransparency = 0.999
                end
            end
            
            TabContentContainer.Visible = true
            ChooseFrame.Visible = true
            Tab.BackgroundTransparency = 0.92
            ContentTitle.Text = tabName
            CurrentTab = tabName
            UpdateContentSize()
        end

        TabButton.Activated:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            SwitchToTab()
        end)

        return TabContentContainer, SwitchToTab
    end

    local ConfigTabContainer, SwitchToConfigTab = CreateTabButton("Configs", "rbxassetid://16932740082", true)
    
    CreateParagraph(ConfigTabContainer, "Configuration Settings", "Manage your UI settings and themes here.")
    
    local themeNames = {}
    for themeName, _ in pairs(ConfigSystem.ThemeColors) do
        table.insert(themeNames, themeName)
    end
    
    local CurrentConfigName = ""
    
    local ThemeDropdown = CreateDropdown(ConfigTabContainer, "Theme", "Select UI theme color", themeNames, false, ConfigSystem.CurrentTheme, function(value)
        local success, themeColor = ConfigSystem:SetTheme(value)
        if success then
            MakeNotify({
                Title = "Theme",
                Description = "Changed",
                Content = "Theme changed to " .. value .. "!",
                Color = themeColor,
                Delay = 3
            })
        end
    end, "ThemeDropdown")
    
    local TransparencyToggle = CreateToggle(ConfigTabContainer, "UI Transparency", "Toggle UI background transparency", false, function(state)
        if state then
            TweenService:Create(Main, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(UIStroke, TweenInfo.new(0.3), {Transparency = 0.7}):Play()
        else
            TweenService:Create(Main, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
            TweenService:Create(UIStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
        end
    end, "TransparencyToggle")
    
    local ConfigNameInput = CreateInput(ConfigTabContainer, "Config Name", "Enter name for your config", "MyConfig", function(value)
        CurrentConfigName = value
    end, "ConfigNameInput")
    
    CreateButton(ConfigTabContainer, "Save Config", "Save current settings to config", "rbxassetid://16932740082", function()
        if CurrentConfigName and CurrentConfigName ~= "" then
            local configData = {}
            for id, element in pairs(AllElements) do
                if element.Type == "Toggle" then
                    configData[id] = element.Value
                elseif element.Type == "Slider" then
                    configData[id] = element.Value
                elseif element.Type == "Dropdown" then
                    configData[id] = element.Value
                elseif element.Type == "Input" then
                    configData[id] = element.Value
                end
            end
            
            local notifyData = ConfigSystem:SaveConfig(CurrentConfigName, configData)
            MakeNotify(notifyData)
            
            local configList = ConfigSystem:GetConfigList()
            LoadConfigDropdown:Refresh(configList)
            DeleteConfigDropdown:Refresh(configList)
        else
            MakeNotify({
                Title = "Config",
                Description = "Error",
                Content = "Please enter a config name first!",
                Color = Color3.fromRGB(255, 50, 50),
                Delay = 3
            })
        end
    end)
    
    local LoadConfigDropdown = CreateDropdown(ConfigTabContainer, "Load Config", "Select config to load", {}, false, nil, function(value)
        if value then
            local notifyData, configData = ConfigSystem:LoadConfig(value)
            MakeNotify(notifyData)
            
            if configData then
                for id, val in pairs(configData) do
                    if AllElements[id] then
                        AllElements[id]:Set(val)
                    end
                end
                ThemeDropdown:Set(ConfigSystem.CurrentTheme)
            end
        end
    end, "LoadConfigDropdown")
    
    local DeleteConfigDropdown = CreateDropdown(ConfigTabContainer, "Delete Config", "Select config to delete", {}, false, nil, function(value)
        if value then
            local notifyData = ConfigSystem:DeleteConfig(value)
            MakeNotify(notifyData)
            
            local configList = ConfigSystem:GetConfigList()
            LoadConfigDropdown:Refresh(configList)
            DeleteConfigDropdown:Refresh(configList)
        end
    end, "DeleteConfigDropdown")
    
    local initialConfigList = ConfigSystem:GetConfigList()
    LoadConfigDropdown:Refresh(initialConfigList)
    DeleteConfigDropdown:Refresh(initialConfigList)
    
    CreateParagraph(ConfigTabContainer, "Note", "Configs are saved to local files in the BorealConfigs folder.")

    local Window = {
        UI = {
            Main = DropShadowHolder,
            Topbar = Top,
            Content = ContentScroll,
            RightButtons = RightButtons
        },
        TopBarButtons = {}
    }

    function Window:CreateTab(tabName, iconId)
        return CreateTabButton(tabName, iconId, false)
    end

    function Window:AddParagraph(tabContainer, title, content)
        return CreateParagraph(tabContainer, title, content)
    end

    function Window:AddButton(tabContainer, title, content, iconId, callback)
        return CreateButton(tabContainer, title, content, iconId, callback)
    end

    function Window:AddToggle(tabContainer, title, content, defaultValue, callback, elementId)
        return CreateToggle(tabContainer, title, content, defaultValue, callback, elementId)
    end

    function Window:AddInput(tabContainer, title, content, placeholder, callback, elementId)
        return CreateInput(tabContainer, title, content, placeholder, callback, elementId)
    end

    function Window:AddDropdown(tabContainer, title, content, options, multi, defaultValue, callback, elementId)
        return CreateDropdown(tabContainer, title, content, options, multi, defaultValue, callback, elementId)
    end

    function Window:AddMultiDropdown(tabContainer, title, content, options, defaultValue, callback, elementId)
        return CreateDropdown(tabContainer, title, content, options, true, defaultValue, callback, elementId)
    end

    function Window:AddSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId)
        return CreateSlider(tabContainer, title, content, minValue, maxValue, defaultValue, callback, elementId)
    end

    function Window:AddSection(tabContainer, config)
        return MultiSectionModule:CreateSection(tabContainer, config)
    end

    function Window:AddMultiSection(tabContainer, config)
        return MultiSectionModule:CreateMultiSection(tabContainer, config)
    end

    function Window:Notify(notifyConfig)
        return MakeNotify(notifyConfig)
    end

    function Window:SetTheme(themeName)
        return ConfigSystem:SetTheme(themeName)
    end

    function Window:SetWatermark(watermarkConfig)
        watermarkConfig = watermarkConfig or {}
        local Title = watermarkConfig.Title or "Boreal UI"
        local Version = watermarkConfig.Version or ""
        local ShowFPS = watermarkConfig.ShowFPS ~= false
        local ShowPing = watermarkConfig.ShowPing ~= false
        local ShowTime = watermarkConfig.ShowTime ~= false
        local Position = watermarkConfig.Position or "Right"
        
        if WatermarkData.Frame then
            WatermarkData.Frame:Destroy()
            if WatermarkData.UpdateConnection then
                WatermarkData.UpdateConnection:Disconnect()
            end
        end
        
        local WatermarkGui = Instance.new("ScreenGui")
        WatermarkGui.Name = "BorealWatermark"
        WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        WatermarkGui.Parent = CoreGui
        
        local WatermarkFrame = Instance.new("Frame")
        WatermarkFrame.Name = "WatermarkFrame"
        WatermarkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        WatermarkFrame.BackgroundTransparency = 0.2
        WatermarkFrame.BorderSizePixel = 0
        WatermarkFrame.Size = UDim2.new(0, 0, 0, 25)
        WatermarkFrame.Position = Position == "Left" and UDim2.new(0, 10, 0, 10) or UDim2.new(1, -10, 0, 10)
        WatermarkFrame.AutomaticSize = Enum.AutomaticSize.X
        WatermarkFrame.Parent = WatermarkGui
        
        local WatermarkCorner = Instance.new("UICorner")
        WatermarkCorner.CornerRadius = UDim.new(0, 4)
        WatermarkCorner.Parent = WatermarkFrame
        
        local WatermarkStroke = Instance.new("UIStroke")
        WatermarkStroke.Color = ConfigSystem.ThemeColors[ConfigSystem.CurrentTheme]
        WatermarkStroke.Thickness = 1
        WatermarkStroke.Transparency = 0.5
        WatermarkStroke.Parent = WatermarkFrame
        
        local WatermarkText = Instance.new("TextLabel")
        WatermarkText.Name = "WatermarkText"
        WatermarkText.Font = Enum.Font.GothamBold
        WatermarkText.Text = Title .. (Version ~= "" and " | " .. Version or "")
        WatermarkText.TextColor3 = Color3.fromRGB(255, 255, 255)
        WatermarkText.TextSize = 11
        WatermarkText.TextXAlignment = Enum.TextXAlignment.Left
        WatermarkText.BackgroundTransparency = 1
        WatermarkText.Position = UDim2.new(0, 8, 0, 0)
        WatermarkText.Size = UDim2.new(0, 0, 1, 0)
        WatermarkText.AutomaticSize = Enum.AutomaticSize.X
        WatermarkText.Parent = WatermarkFrame
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingRight = UDim.new(0, 8)
        Padding.Parent = WatermarkFrame
        
        WatermarkData.Frame = WatermarkFrame
        WatermarkData.Active = true
        
        WatermarkData.UpdateConnection = RunService.RenderStepped:Connect(function()
            if not WatermarkData.Active or not WatermarkData.Frame then return end
            
            local text = Title
            if Version ~= "" then
                text = text .. " | " .. Version
            end
            
            if ShowFPS then
                local fps = math.floor(1 / RunService.RenderStepped:Wait())
                text = text .. " | FPS: " .. fps
            end
            
            if ShowPing then
                local ping = 0
                pcall(function()
                    ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                text = text .. " | Ping: " .. ping .. "ms"
            end
            
            if ShowTime then
                local time = os.date("%H:%M")
                text = text .. " | " .. time
            end
            
            WatermarkText.Text = text
            
            if Position == "Right" then
                local frameWidth = WatermarkFrame.AbsoluteSize.X
                WatermarkFrame.Position = UDim2.new(1, -frameWidth - 10, 0, 10)
            end
        end)
        
        table.insert(ConfigSystem.ThemeElements, {
            Update = function(color)
                if WatermarkStroke then
                    WatermarkStroke.Color = color
                end
            end
        })
        
        return WatermarkFrame
    end

    function Window:SaveConfig(name)
        local configData = {}
        for id, element in pairs(AllElements) do
            if element.Type == "Toggle" then
                configData[id] = element.Value
            elseif element.Type == "Slider" then
                configData[id] = element.Value
            elseif element.Type == "Dropdown" then
                configData[id] = element.Value
            elseif element.Type == "Input" then
                configData[id] = element.Value
            end
        end
        local notifyData = ConfigSystem:SaveConfig(name, configData)
        MakeNotify(notifyData)
    end

    function Window:LoadConfig(name)
        local notifyData, configData = ConfigSystem:LoadConfig(name)
        MakeNotify(notifyData)
        if configData then
            for id, val in pairs(configData) do
                if AllElements[id] then
                    AllElements[id]:Set(val)
                end
            end
        end
    end

    function Window:DeleteConfig(name)
        local notifyData = ConfigSystem:DeleteConfig(name)
        MakeNotify(notifyData)
    end

    function Window:GetConfigs()
        return ConfigSystem:GetConfigList()
    end

    function Window:Destroy()
        if WatermarkData.UpdateConnection then
            WatermarkData.UpdateConnection:Disconnect()
        end
        ScreenGui:Destroy()
    end

    -- Initialize FullScreen
    FullScreenManager:Initialize(Window)

    return Window
end

local function MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "Notification"
    NotifyConfig.Description = NotifyConfig.Description or "Description"
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = NotifyConfig.Color or Color3.fromRGB(255, 0, 255)
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5
    
    local NotifyFunction = {}
    
    spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui")
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.Parent = CoreGui
        end
        
        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame")
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            NotifyLayout.BackgroundTransparency = 0.999
            NotifyLayout.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyLayout.BorderSizePixel = 0
            NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
            NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.NotifyGui
            
            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                    TweenService:Create(
                        v,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                        {Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12)*Count))}
                    ):Play()
                    Count = Count + 1
                end
            end)
        end
        
        local NotifyPosHeigh = 0
        for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
            NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
        end
        
        local NotifyFrame = Instance.new("Frame")
        local NotifyFrameReal = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local DropShadowHolder = Instance.new("Frame")
        local DropShadow = Instance.new("ImageLabel")
        local Top = Instance.new("Frame")
        local TextLabel = Instance.new("TextLabel")
        local UIStroke = Instance.new("UIStroke")
        local UICorner1 = Instance.new("UICorner")
        local TextLabel1 = Instance.new("TextLabel")
        local UIStroke1 = Instance.new("UIStroke")
        local Close = Instance.new("TextButton")
        local ImageLabel = Instance.new("ImageLabel")
        local TextLabel2 = Instance.new("TextLabel")

        NotifyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrame.BorderSizePixel = 0
        NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))

        NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderSizePixel = 0
        NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.Parent = NotifyFrame

        UICorner.Parent = NotifyFrameReal
        UICorner.CornerRadius = UDim.new(0, 8)

        DropShadowHolder.BackgroundTransparency = 1
        DropShadowHolder.BorderSizePixel = 0
        DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
        DropShadowHolder.ZIndex = 0
        DropShadowHolder.Name = "DropShadowHolder"
        DropShadowHolder.Parent = NotifyFrameReal

        DropShadow.Image = "rbxassetid://6015897843"
        DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        DropShadow.ImageTransparency = 0.5
        DropShadow.ScaleType = Enum.ScaleType.Slice
        DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
        DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
        DropShadow.BackgroundTransparency = 1
        DropShadow.BorderSizePixel = 0
        DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        DropShadow.Size = UDim2.new(1, 47, 1, 47)
        DropShadow.ZIndex = 0
        DropShadow.Name = "DropShadow"
        DropShadow.Parent = DropShadowHolder

        Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Top.BackgroundTransparency = 0.999
        Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Top.BorderSizePixel = 0
        Top.Size = UDim2.new(1, 0, 0, 36)
        Top.Name = "Top"
        Top.Parent = NotifyFrameReal

        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.Text = NotifyConfig.Title
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 14
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 0.999
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.BorderSizePixel = 0
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Parent = Top
        TextLabel.Position = UDim2.new(0, 10, 0, 0)

        UIStroke.Color = Color3.fromRGB(255, 255, 255)
        UIStroke.Thickness = 0.3
        UIStroke.Parent = TextLabel

        UICorner1.Parent = Top
        UICorner1.CornerRadius = UDim.new(0, 5)

        TextLabel1.Font = Enum.Font.GothamBold
        TextLabel1.Text = NotifyConfig.Description
        TextLabel1.TextColor3 = NotifyConfig.Color
        TextLabel1.TextSize = 14
        TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel1.BackgroundTransparency = 0.999
        TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel1.BorderSizePixel = 0
        TextLabel1.Size = UDim2.new(1, 0, 1, 0)
        TextLabel1.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0)
        TextLabel1.Parent = Top

        UIStroke1.Color = NotifyConfig.Color
        UIStroke1.Thickness = 0.4
        UIStroke1.Parent = TextLabel1

        Close.Font = Enum.Font.SourceSans
        Close.Text = ""
        Close.TextColor3 = Color3.fromRGB(0, 0, 0)
        Close.TextSize = 14
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Close.BackgroundTransparency = 0.999
        Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Close.BorderSizePixel = 0
        Close.Position = UDim2.new(1, -5, 0.5, 0)
        Close.Size = UDim2.new(0, 25, 0, 25)
        Close.Name = "Close"
        Close.Parent = Top

        ImageLabel.Image = "rbxassetid://9886659671"
        ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageLabel.BackgroundTransparency = 0.999
        ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageLabel.BorderSizePixel = 0
        ImageLabel.Position = UDim2.new(0.49, 0, 0.5, 0)
        ImageLabel.Size = UDim2.new(1, -8, 1, -8)
        ImageLabel.Parent = Close

        TextLabel2.Font = Enum.Font.GothamBold
        TextLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel2.TextSize = 13
        TextLabel2.Text = NotifyConfig.Content
        TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
        TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel2.BackgroundTransparency = 0.999
        TextLabel2.TextColor3 = Color3.fromRGB(150, 150, 150)
        TextLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel2.BorderSizePixel = 0
        TextLabel2.Position = UDim2.new(0, 10, 0, 27)
        TextLabel2.Parent = NotifyFrameReal
        TextLabel2.Size = UDim2.new(1, -20, 0, 13)

        TextLabel2.Size = UDim2.new(1, -20, 0, 13 + (13 * (TextLabel2.TextBounds.X // TextLabel2.AbsoluteSize.X)))
        TextLabel2.TextWrapped = true

        if TextLabel2.AbsoluteSize.Y < 27 then
            NotifyFrame.Size = UDim2.new(1, 0, 0, 65)
        else
            NotifyFrame.Size = UDim2.new(1, 0, 0, TextLabel2.AbsoluteSize.Y + 40)
        end
        
        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then
                return false
            end
            waitbruh = true
            TweenService:Create(
                NotifyFrameReal,
                TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                {Position = UDim2.new(0, 400, 0, 0)}
            ):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end
        
        Close.Activated:Connect(function()
            NotifyFunction:Close()
        end)
        
        TweenService:Create(
            NotifyFrameReal,
            TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
            {Position = UDim2.new(0, 0, 0, 0)}
        ):Play()
        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)
    
    return NotifyFunction
end

return Boreal
