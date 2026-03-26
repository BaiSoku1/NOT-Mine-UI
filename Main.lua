--[[ 
    PREMIUM MODERN SILVER UI (V11)
    - Style: Compact & Refined
    - Features: Button, Toggle, Slider, Input, Dropdown
    - Themes: Dark, Light, Gold, Silver, Plant, Rose, Purple, Violet, Crimson, Blue, Pink, Orange
    - Draggable Open/Close Button
    - Author below Title
]]

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Library = {}
local Themes = {}

-- Theme Definitions
Themes.Colors = {
    Dark = {
        Background = Color3.fromRGB(8, 8, 8),
        Secondary = Color3.fromRGB(18, 18, 18),
        Sidebar = Color3.fromRGB(12, 12, 12),
        Accent = Color3.fromRGB(220, 220, 220),
        Text = Color3.fromRGB(230, 230, 230),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Button = Color3.fromRGB(18, 18, 18),
        Border = Color3.fromRGB(255, 255, 255)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 240),
        Secondary = Color3.fromRGB(250, 250, 250),
        Sidebar = Color3.fromRGB(235, 235, 235),
        Accent = Color3.fromRGB(80, 80, 80),
        Text = Color3.fromRGB(30, 30, 30),
        TextSecondary = Color3.fromRGB(80, 80, 80),
        Button = Color3.fromRGB(245, 245, 245),
        Border = Color3.fromRGB(100, 100, 100)
    },
    Gold = {
        Background = Color3.fromRGB(20, 15, 8),
        Secondary = Color3.fromRGB(35, 25, 12),
        Sidebar = Color3.fromRGB(25, 18, 10),
        Accent = Color3.fromRGB(255, 215, 0),
        Text = Color3.fromRGB(255, 235, 150),
        TextSecondary = Color3.fromRGB(200, 170, 80),
        Button = Color3.fromRGB(35, 25, 12),
        Border = Color3.fromRGB(255, 215, 0)
    },
    Silver = {
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 45),
        Sidebar = Color3.fromRGB(30, 30, 40),
        Accent = Color3.fromRGB(192, 192, 192),
        Text = Color3.fromRGB(220, 220, 240),
        TextSecondary = Color3.fromRGB(160, 160, 180),
        Button = Color3.fromRGB(35, 35, 45),
        Border = Color3.fromRGB(192, 192, 192)
    },
    Plant = {
        Background = Color3.fromRGB(10, 25, 10),
        Secondary = Color3.fromRGB(20, 40, 20),
        Sidebar = Color3.fromRGB(15, 30, 15),
        Accent = Color3.fromRGB(80, 200, 80),
        Text = Color3.fromRGB(180, 230, 180),
        TextSecondary = Color3.fromRGB(120, 170, 120),
        Button = Color3.fromRGB(20, 40, 20),
        Border = Color3.fromRGB(80, 200, 80)
    },
    Rose = {
        Background = Color3.fromRGB(30, 15, 20),
        Secondary = Color3.fromRGB(45, 25, 35),
        Sidebar = Color3.fromRGB(35, 18, 25),
        Accent = Color3.fromRGB(255, 100, 150),
        Text = Color3.fromRGB(255, 200, 210),
        TextSecondary = Color3.fromRGB(200, 130, 150),
        Button = Color3.fromRGB(45, 25, 35),
        Border = Color3.fromRGB(255, 100, 150)
    },
    Purple = {
        Background = Color3.fromRGB(20, 10, 30),
        Secondary = Color3.fromRGB(35, 20, 45),
        Sidebar = Color3.fromRGB(25, 12, 35),
        Accent = Color3.fromRGB(160, 100, 220),
        Text = Color3.fromRGB(210, 180, 240),
        TextSecondary = Color3.fromRGB(150, 120, 190),
        Button = Color3.fromRGB(35, 20, 45),
        Border = Color3.fromRGB(160, 100, 220)
    },
    Violet = {
        Background = Color3.fromRGB(20, 8, 35),
        Secondary = Color3.fromRGB(35, 15, 55),
        Sidebar = Color3.fromRGB(25, 10, 40),
        Accent = Color3.fromRGB(180, 80, 240),
        Text = Color3.fromRGB(220, 170, 255),
        TextSecondary = Color3.fromRGB(160, 110, 210),
        Button = Color3.fromRGB(35, 15, 55),
        Border = Color3.fromRGB(180, 80, 240)
    },
    Crimson = {
        Background = Color3.fromRGB(30, 8, 8),
        Secondary = Color3.fromRGB(50, 15, 15),
        Sidebar = Color3.fromRGB(40, 10, 10),
        Accent = Color3.fromRGB(220, 60, 60),
        Text = Color3.fromRGB(255, 180, 180),
        TextSecondary = Color3.fromRGB(200, 120, 120),
        Button = Color3.fromRGB(50, 15, 15),
        Border = Color3.fromRGB(220, 60, 60)
    },
    Blue = {
        Background = Color3.fromRGB(8, 15, 30),
        Secondary = Color3.fromRGB(15, 25, 45),
        Sidebar = Color3.fromRGB(10, 18, 35),
        Accent = Color3.fromRGB(80, 150, 255),
        Text = Color3.fromRGB(180, 210, 255),
        TextSecondary = Color3.fromRGB(120, 150, 200),
        Button = Color3.fromRGB(15, 25, 45),
        Border = Color3.fromRGB(80, 150, 255)
    },
    Pink = {
        Background = Color3.fromRGB(35, 12, 25),
        Secondary = Color3.fromRGB(55, 20, 40),
        Sidebar = Color3.fromRGB(40, 14, 28),
        Accent = Color3.fromRGB(255, 100, 200),
        Text = Color3.fromRGB(255, 180, 220),
        TextSecondary = Color3.fromRGB(200, 120, 170),
        Button = Color3.fromRGB(55, 20, 40),
        Border = Color3.fromRGB(255, 100, 200)
    },
    Orange = {
        Background = Color3.fromRGB(30, 18, 8),
        Secondary = Color3.fromRGB(50, 30, 12),
        Sidebar = Color3.fromRGB(35, 20, 10),
        Accent = Color3.fromRGB(255, 140, 50),
        Text = Color3.fromRGB(255, 210, 150),
        TextSecondary = Color3.fromRGB(200, 150, 90),
        Button = Color3.fromRGB(50, 30, 12),
        Border = Color3.fromRGB(255, 140, 50)
    }
}

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    for _,c in pairs(children or {}) do c.Parent = obj end
    return obj
end

local function ApplyPremiumBorder(parent, thickness, themeColor)
    local borderColor = themeColor or Color3.fromRGB(255, 255, 255)
    local stroke = Create("UIStroke", {
        Thickness = thickness or 2.2,
        Color = borderColor,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    }, {
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, borderColor),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 30)),
                ColorSequenceKeypoint.new(1, borderColor)
            }),
            Rotation = 0
        })
    })

    task.spawn(function()
        local g = stroke:FindFirstChildOfClass("UIGradient")
        while stroke and stroke.Parent do
            g.Rotation = g.Rotation + 1.5
            RunService.RenderStepped:Wait()
        end
    end)
    return stroke
end

function Library:Notify(title, content, duration)
    local duration = duration or 5
    local NotifGui = Player:WaitForChild("PlayerGui"):FindFirstChild("ModernNotifs") or Create("ScreenGui", {Name = "ModernNotifs", Parent = (game:GetService("CoreGui") or Player:WaitForChild("PlayerGui"))})
    local Holder = NotifGui:FindFirstChild("Holder") or Create("Frame", {Name = "Holder", Size = UDim2.new(0, 220, 1, -20), Position = UDim2.new(1, -230, 0, 10), BackgroundTransparency = 1, Parent = NotifGui}, {Create("UIListLayout", {VerticalAlignment = "Bottom", Padding = UDim.new(0, 8), HorizontalAlignment = "Right"})})

    local Notif = Create("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Color3.fromRGB(10, 10, 10), Parent = Holder}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
    ApplyPremiumBorder(Notif, 2)

    Create("TextLabel", {Text = title:upper(), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -40, 0, 15), Parent = Notif})
    Create("TextLabel", {Text = content, Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = Color3.fromRGB(180, 180, 180), TextXAlignment = "Left", TextYAlignment = "Top", TextWrapped = true, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 25), Size = UDim2.new(1, -20, 0, 30), Parent = Notif})

    Notif.Position = UDim2.new(1.5, 0, 0, 0)
    TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(duration, function()
        local t = TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, 0), BackgroundTransparency = 1})
        t:Play() t.Completed:Connect(function() Notif:Destroy() end)
    end)
end

function Library:CreateWindow(config)
    config = config or {}
    local titleText = config.Title or "PREMIUM UI"
    local author = config.Author or ""
    local folder = config.Folder or "PremiumUI"
    local currentTheme = config.Theme or "Silver"
    
    local screenGui = Create("ScreenGui", {Name = folder, ResetOnSpawn = false, Parent = (game:GetService("CoreGui") or Player:WaitForChild("PlayerGui"))})

    -- Open Button (Draggable)
    local OpenButton = Create("ImageButton", {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, 15, 0.5, -20), BackgroundColor3 = Themes.Colors[currentTheme].Secondary, Image = "rbxassetid://74666642456643", Parent = screenGui}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
    ApplyPremiumBorder(OpenButton, 2, Themes.Colors[currentTheme].Accent)

    local MainFrame = Create("Frame", {Name = "MainFrame", Size = UDim2.fromOffset(420, 380), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Themes.Colors[currentTheme].Background, Visible = true, Parent = screenGui}, {Create("UICorner", {CornerRadius = UDim.new(0, 10)})})
    ApplyPremiumBorder(MainFrame, 2.8, Themes.Colors[currentTheme].Accent)
    
    -- Make Open Button Draggable
    do
        local dragging, dragStart, startPos
        OpenButton.InputBegan:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                dragging = true
                dragStart = input.Position
                startPos = OpenButton.Position
            end 
        end)
        UIS.InputChanged:Connect(function(input) 
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
                local delta = input.Position - dragStart
                OpenButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end 
        end)
        UIS.InputEnded:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                dragging = false 
            end 
        end)
    end

    -- Make MainFrame Draggable
    do
        local dragging, dragStart, startPos
        MainFrame.InputBegan:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end 
        end)
        UIS.InputChanged:Connect(function(input) 
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end 
        end)
        UIS.InputEnded:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                dragging = false 
            end 
        end)
    end

    OpenButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then MainFrame:TweenSize(UDim2.fromOffset(420, 380), "Out", "Back", 0.4, true) end
    end)

    -- Top Bar with Title
    local TopBar = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = MainFrame})
    
    -- Title
    Create("TextLabel", {Text = titleText:upper(), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Themes.Colors[currentTheme].Text, TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -60, 0, 18), Parent = TopBar})
    
    -- Author (below title)
    if author ~= "" then
        Create("TextLabel", {Text = author, Font = Enum.Font.GothamMedium, TextSize = 9, TextColor3 = Themes.Colors[currentTheme].TextSecondary, TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 26), Size = UDim2.new(1, -60, 0, 14), Parent = TopBar})
    end
    
    -- Close Button
    local CloseBtn = Create("ImageButton", {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -34, 0, 10), BackgroundTransparency = 1, Image = "rbxassetid://74666642456643", ImageColor3 = Themes.Colors[currentTheme].TextSecondary, Parent = TopBar})
    
    -- Make Close Button Draggable
    do
        local dragging, dragStart, startPos
        CloseBtn.InputBegan:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end 
        end)
        UIS.InputChanged:Connect(function(input) 
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end 
        end)
        UIS.InputEnded:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                dragging = false 
            end 
        end)
    end
    
    local isDraggingClose = false
    CloseBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingClose = false
            task.delay(0.1, function()
                if not isDraggingClose then
                    MainFrame:TweenSize(UDim2.fromOffset(0, 0), "In", "Back", 0.3, true, function() 
                        MainFrame.Visible = false 
                    end)
                end
            end)
        end
    end)
    
    CloseBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            isDraggingClose = true
        end
    end)

    -- Sidebar
    local Sidebar = Create("Frame", {Size = UDim2.new(0, 110, 1, -55), Position = UDim2.fromOffset(10, 55), BackgroundColor3 = Themes.Colors[currentTheme].Sidebar, Parent = MainFrame}, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = "Center"}),
        Create("UIPadding", {PaddingTop = UDim.new(0, 8)})
    })
    ApplyPremiumBorder(Sidebar, 1.2, Themes.Colors[currentTheme].Accent)

    -- Container
    local Container = Create("Frame", {Size = UDim2.new(1, -140, 1, -55), Position = UDim2.fromOffset(130, 55), BackgroundTransparency = 1, Parent = MainFrame})

    local Window = {}
    local firstTab = true
    local tabs = {}
    local currentPage = nil
    
    -- Theme changer function
    local function ApplyTheme(themeName)
        local theme = Themes.Colors[themeName]
        if not theme then return end
        
        -- Update MainFrame
        MainFrame.BackgroundColor3 = theme.Background
        for _, stroke in ipairs(MainFrame:GetChildren()) do
            if stroke:IsA("UIStroke") then
                stroke.Color = theme.Accent
                local gradient = stroke:FindFirstChildOfClass("UIGradient")
                if gradient then
                    gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, theme.Accent),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 30)),
                        ColorSequenceKeypoint.new(1, theme.Accent)
                    })
                end
            end
        end
        
        -- Update TopBar text
        for _, child in ipairs(TopBar:GetChildren()) do
            if child:IsA("TextLabel") then
                if child.Text == titleText:upper() then
                    child.TextColor3 = theme.Text
                elseif child.Text == author then
                    child.TextColor3 = theme.TextSecondary
                end
            end
        end
        
        -- Update Close button color
        CloseBtn.ImageColor3 = theme.TextSecondary
        
        -- Update Sidebar
        Sidebar.BackgroundColor3 = theme.Sidebar
        for _, stroke in ipairs(Sidebar:GetChildren()) do
            if stroke:IsA("UIStroke") then
                stroke.Color = theme.Accent
            end
        end
        
        -- Update Open button
        OpenButton.BackgroundColor3 = theme.Secondary
        for _, stroke in ipairs(OpenButton:GetChildren()) do
            if stroke:IsA("UIStroke") then
                stroke.Color = theme.Accent
            end
        end
        
        -- Update all tab buttons
        for _, tabBtn in ipairs(tabs) do
            tabBtn.BackgroundColor3 = theme.Button
            tabBtn.TextColor3 = theme.TextSecondary
        end
        
        -- Update current page elements
        if currentPage then
            for _, child in ipairs(currentPage:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = theme.Button
                    child.TextColor3 = theme.Text
                    for _, stroke in ipairs(child:GetChildren()) do
                        if stroke:IsA("UIStroke") then
                            stroke.Color = theme.Accent
                        end
                    end
                elseif child:IsA("Frame") then
                    child.BackgroundColor3 = theme.Secondary
                    for _, frameChild in ipairs(child:GetChildren()) do
                        if frameChild:IsA("TextLabel") then
                            frameChild.TextColor3 = theme.Text
                        elseif frameChild:IsA("TextButton") then
                            frameChild.BackgroundColor3 = theme.Button
                            frameChild.TextColor3 = theme.Text
                        elseif frameChild:IsA("TextBox") then
                            frameChild.BackgroundColor3 = theme.Button
                            frameChild.TextColor3 = theme.Text
                        end
                    end
                    for _, stroke in ipairs(child:GetChildren()) do
                        if stroke:IsA("UIStroke") then
                            stroke.Color = theme.Accent
                        end
                    end
                end
            end
        end
    end

    function Window:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local name = tabConfig.Title or "Tab"
        
        local TabBtn = Create("TextButton", {Size = UDim2.new(0.85, 0, 0, 30), BackgroundColor3 = firstTab and Themes.Colors[currentTheme].Accent or Themes.Colors[currentTheme].Button, Text = name, TextColor3 = firstTab and Themes.Colors[currentTheme].Background or Themes.Colors[currentTheme].TextSecondary, Font = Enum.Font.GothamBold, TextSize = 11, Parent = Sidebar}, {Create("UICorner", {CornerRadius = UDim.new(0, 5)})})
        local Page = Create("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = firstTab, ScrollBarThickness = 4, ScrollBarImageColor3 = Themes.Colors[currentTheme].TextSecondary, Parent = Container}, {Create("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = "Center"}), Create("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 8)})})
        
        table.insert(tabs, TabBtn)
        
        if firstTab then
            currentPage = Page
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Sidebar:GetChildren()) do 
                if v:IsA("TextButton") then 
                    TweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = Themes.Colors[currentTheme].Button, TextColor3 = Themes.Colors[currentTheme].TextSecondary}):Play() 
                end 
            end
            for _, v in pairs(Container:GetChildren()) do 
                v.Visible = false 
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Themes.Colors[currentTheme].Accent, TextColor3 = Themes.Colors[currentTheme].Background}):Play()
            Page.Visible = true
            currentPage = Page
        end)

        firstTab = false
        
        local Tab = {}

        function Tab:Button(config)
            config = config or {}
            local text = config.Text or "Button"
            local callback = config.Callback or function() end
            
            local Btn = Create("TextButton", {Size = UDim2.new(0.96, 0, 0, 35), BackgroundColor3 = Themes.Colors[currentTheme].Button, Text = text, TextColor3 = Themes.Colors[currentTheme].Text, Font = Enum.Font.GothamMedium, TextSize = 11, Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(Btn, 1, Themes.Colors[currentTheme].Accent)
            Btn.MouseButton1Click:Connect(function() 
                if callback then callback() end 
                Btn:TweenSize(UDim2.new(0.9, 0, 0, 32), "Out", "Quad", 0.1, true, function() 
                    Btn:TweenSize(UDim2.new(0.96, 0, 0, 35), "Out", "Quad", 0.1, true) 
                end) 
            end)
        end

        function Tab:Toggle(config)
            config = config or {}
            local text = config.Text or "Toggle"
            local callback = config.Callback or function() end
            local default = config.Default or false
            
            local TglFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 35), BackgroundColor3 = Themes.Colors[currentTheme].Button, Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(TglFrame, 1, Themes.Colors[currentTheme].Accent)
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Themes.Colors[currentTheme].TextSecondary, TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -60, 1, 0), Parent = TglFrame})
            local TglBtn = Create("TextButton", {Size = UDim2.fromOffset(36, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = default and Themes.Colors[currentTheme].Accent or Color3.fromRGB(35, 35, 35), Text = "", Parent = TglFrame}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            local Circle = Create("Frame", {Size = UDim2.fromOffset(14, 14), Position = default and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = TglBtn}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            local toggled = default or false
            
            TglBtn.MouseButton1Click:Connect(function() 
                toggled = not toggled
                local targetPos = toggled and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
                local targetColor = toggled and Themes.Colors[currentTheme].Accent or Color3.fromRGB(35, 35, 35)
                TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos}):Play()
                TweenService:Create(TglBtn, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
                if callback then callback(toggled) end 
            end)
        end

        function Tab:Slider(config)
            config = config or {}
            local text = config.Text or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or 50
            local callback = config.Callback or function() end
            
            local SliderFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 70), BackgroundColor3 = Themes.Colors[currentTheme].Button, Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(SliderFrame, 1, Themes.Colors[currentTheme].Accent)
            
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Themes.Colors[currentTheme].TextSecondary, TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -80, 0, 15), Parent = SliderFrame})
            
            local InputBox = Create("TextBox", {
                Size = UDim2.fromOffset(45, 25),
                Position = UDim2.new(1, -55, 0, 5),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Text = tostring(default),
                TextColor3 = Themes.Colors[currentTheme].Text,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = "Center",
                ClearTextOnFocus = false,
                Parent = SliderFrame
            }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            
            local SliderBar = Create("Frame", {
                Size = UDim2.new(0.9, 0, 0, 4),
                Position = UDim2.fromOffset(10, 45),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Parent = SliderFrame
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            
            local FillBar = Create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Themes.Colors[currentTheme].Accent,
                Parent = SliderBar
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            
            local ValueDisplay = Create("TextLabel", {
                Text = tostring(default),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Themes.Colors[currentTheme].Text,
                TextXAlignment = "Right",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -10, 0, 32),
                Size = UDim2.fromOffset(40, 15),
                Parent = SliderFrame
            })
            
            local dragging = false
            local value = default
            
            local function updateValueFromInput(newValue)
                local num = tonumber(newValue)
                if num then
                    value = math.clamp(num, min, max)
                    value = math.floor(value)
                    local percent = (value - min) / (max - min)
                    FillBar.Size = UDim2.new(percent, 0, 1, 0)
                    InputBox.Text = tostring(value)
                    ValueDisplay.Text = tostring(value)
                    callback(value)
                else
                    InputBox.Text = tostring(value)
                end
            end
            
            local function updateValueFromSlider(input)
                local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                value = min + (max - min) * relativeX
                value = math.floor(value)
                FillBar.Size = UDim2.new(relativeX, 0, 1, 0)
                InputBox.Text = tostring(value)
                ValueDisplay.Text = tostring(value)
                callback(value)
            end
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateValueFromSlider(input)
                end
            end)
            
            UIS.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateValueFromSlider(input)
                end
            end)
            
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            InputBox.FocusLost:Connect(function(enterPressed)
                updateValueFromInput(InputBox.Text)
            end)
        end

        function Tab:Input(config)
            config = config or {}
            local text = config.Text or "Input"
            local placeholder = config.Placeholder or "Type here..."
            local default = config.Default or ""
            local callback = config.Callback or function() end
            
            local InputFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 70), BackgroundColor3 = Themes.Colors[currentTheme].Button, Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(InputFrame, 1, Themes.Colors[currentTheme].Accent)
            
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Themes.Colors[currentTheme].TextSecondary, TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -20, 0, 15), Parent = InputFrame})
            
            local InputBox = Create("TextBox", {
                Size = UDim2.new(0.9, 0, 0, 32),
                Position = UDim2.fromOffset(10, 30),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Text = default,
                PlaceholderText = placeholder,
                TextColor3 = Themes.Colors[currentTheme].Text,
                PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextXAlignment = "Left",
                ClearTextOnFocus = false,
                Parent = InputFrame
            }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            
            Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = InputBox})
            
            local currentValue = default
            
            InputBox.FocusLost:Connect(function(enterPressed)
                currentValue = InputBox.Text
                callback(currentValue)
            end)
            
            return {
                GetValue = function() return currentValue end,
                SetValue = function(newValue)
                    currentValue = tostring(newValue)
                    InputBox.Text = currentValue
                    callback(currentValue)
                end
            }
        end

        function Tab:Dropdown(config)
            config = config or {}
            local text = config.Text or "Dropdown"
            local options = config.Options or {}
            local default = config.Default or (options[1] or "")
            local callback = config.Callback or function() end
            
            local isOpen = false
            local selected = default
            
            local DropdownFrame = Create("Frame", {
                Size = UDim2.new(0.96, 0, 0, 45),
                BackgroundColor3 = Themes.Colors[currentTheme].Button,
                Parent = Page,
                ClipsDescendants = false
            }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(DropdownFrame, 1, Themes.Colors[currentTheme].Accent)
            
            local ClickArea = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = DropdownFrame
            })
            
            Create("TextLabel", {
                Text = text,
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextColor3 = Themes.Colors[currentTheme].TextSecondary,
                TextXAlignment = "Left",
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.new(0.6, 0, 1, 0),
                Parent = DropdownFrame
            })
            
            local SelectedLabel = Create("TextLabel", {
                Text = selected,
                Font = Enum.Font.GothamMedium,
                TextSize = 11,
                TextColor3 = Themes.Colors[currentTheme].Text,
                TextXAlignment = "Right",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.7, 0, 0, 0),
                Size = UDim2.new(0.25, -30, 1, 0),
                Parent = DropdownFrame
            })
            
            local Arrow = Create("TextLabel", {
                Text = "▼",
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextColor3 = Themes.Colors[currentTheme].TextSecondary,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0, 0),
                Size = UDim2.fromOffset(20, 45),
                Parent = DropdownFrame
            })
            
            local DropdownList = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Themes.Colors[currentTheme].Sidebar,
                Visible = false,
                ClipsDescendants = true,
                ZIndex = 10,
                Parent = DropdownFrame
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Create("UIListLayout", {Padding = UDim.new(0, 2), HorizontalAlignment = "Center"}),
                Create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)})
            })
            ApplyPremiumBorder(DropdownList, 1, Themes.Colors[currentTheme].Accent)
            
            local optionButtons = {}
            local function rebuildOptions()
                for _, btn in pairs(optionButtons) do btn:Destroy() end
                optionButtons = {}
                
                for i, option in ipairs(options) do
                    local OptionBtn = Create("TextButton", {
                        Size = UDim2.new(0.95, 0, 0, 30),
                        BackgroundColor3 = Themes.Colors[currentTheme].Button,
                        Text = option,
                        TextColor3 = Themes.Colors[currentTheme].TextSecondary,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 11,
                        ZIndex = 11,
                        Parent = DropdownList
                    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
                    
                    OptionBtn.MouseButton1Click:Connect(function()
                        selected = option
                        SelectedLabel.Text = selected
                        callback(selected)
                        isOpen = false
                        Arrow.Text = "▼"
                        TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.96, 0, 0, 45)}):Play()
                        task.delay(0.2, function()
                            if not isOpen then DropdownList.Visible = false end
                        end)
                    end)
                    
                    OptionBtn.MouseEnter:Connect(function()
                        TweenService:Create(OptionBtn, TweenInfo.new(0.2), {BackgroundColor3 = Themes.Colors[currentTheme].Accent, TextColor3 = Themes.Colors[currentTheme].Background}):Play()
                    end)
                    
                    OptionBtn.MouseLeave:Connect(function()
                        TweenService:Create(OptionBtn, TweenInfo.new(0.2), {BackgroundColor3 = Themes.Colors[currentTheme].Button, TextColor3 = Themes.Colors[currentTheme].TextSecondary}):Play()
                    end)
                    
                    table.insert(optionButtons, OptionBtn)
                end
            end
            
            rebuildOptions()
            
            ClickArea.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local listHeight = math.clamp(#options * 34 + 8, 0, 200)
                    DropdownList.Visible = true
                    Arrow.Text = "▲"
                    TweenService:Create(DropdownList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, listHeight)}):Play()
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.96, 0, 0, 45 + listHeight)}):Play()
                else
                    Arrow.Text = "▼"
                    TweenService:Create(DropdownList, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.96, 0, 0, 45)}):Play()
                    task.delay(0.2, function()
                        if not isOpen then DropdownList.Visible = false end
                    end)
                end
            end)
            
            return {
                SetValue = function(newValue)
                    for _, option in ipairs(options) do
                        if option == newValue then
                            selected = newValue
                            SelectedLabel.Text = selected
                            callback(selected)
                            break
                        end
                    end
                end,
                GetValue = function() return selected end,
                AddOption = function(newOption)
                    table.insert(options, newOption)
                    rebuildOptions()
                end
            }
        end
        
        function Tab:ThemeDropdown()
            local themeOptions = {"Dark", "Light", "Gold", "Silver", "Plant", "Rose", "Purple", "Violet", "Crimson", "Blue", "Pink", "Orange"}
            return Tab:Dropdown({
                Text = "Theme",
                Options = themeOptions,
                Default = currentTheme,
                Callback = function(value)
                    currentTheme = value
                    ApplyTheme(value)
                    Library:Notify("Theme", "Changed to " .. value, 2)
                end
            })
        end

        return Tab
    end

    return Window
end

return Library
