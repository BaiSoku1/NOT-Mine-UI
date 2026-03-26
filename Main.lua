--[[ 
    PREMIUM MODERN SILVER UI (V11)
    - Style: Compact & Refined
    - Features: Button, Toggle, Slider with Input
    - Icons: BX Close & ID Open (74666642456643)
]]

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Library = {}

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    for _,c in pairs(children or {}) do c.Parent = obj end
    return obj
end

local function ApplyPremiumBorder(parent, thickness)
    local stroke = Create("UIStroke", {
        Thickness = thickness or 2.2,
        Color = Color3.fromRGB(255, 255, 255),
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    }, {
        Create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 220)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 30)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 220))
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
    
    local screenGui = Create("ScreenGui", {Name = folder, ResetOnSpawn = false, Parent = (game:GetService("CoreGui") or Player:WaitForChild("PlayerGui"))})

    local OpenButton = Create("ImageButton", {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, 15, 0.5, -20), BackgroundColor3 = Color3.fromRGB(10, 10, 10), Image = "rbxassetid://74666642456643", Parent = screenGui}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
    ApplyPremiumBorder(OpenButton, 2)

    local MainFrame = Create("Frame", {Name = "MainFrame", Size = UDim2.fromOffset(420, 280), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(8, 8, 8), Visible = true, Parent = screenGui}, {Create("UICorner", {CornerRadius = UDim.new(0, 10)})})
    ApplyPremiumBorder(MainFrame, 2.8)

    -- Draggable
    do
        local dragging, dragStart, startPos
        MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
        UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
        UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    end

    OpenButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then MainFrame:TweenSize(UDim2.fromOffset(420, 280), "Out", "Back", 0.4, true) end
    end)

    local TopBar = Create("Frame", {Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1, Parent = MainFrame})
    
    local titleWithAuthor = titleText:upper()
    if author ~= "" then
        titleWithAuthor = titleText:upper() .. " | " .. author
    end
    
    Create("TextLabel", {Text = titleWithAuthor, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(230, 230, 230), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -60, 1, 0), Parent = TopBar})
    
    local CloseBtn = Create("ImageButton", {Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -30, 0, 8), BackgroundTransparency = 1, Image = "rbxassetid://74666642456643", ImageColor3 = Color3.fromRGB(200, 200, 200), Parent = TopBar})
    CloseBtn.MouseButton1Click:Connect(function() MainFrame:TweenSize(UDim2.fromOffset(0, 0), "In", "Back", 0.3, true, function() MainFrame.Visible = false end) end)

    -- Sidebar
    local Sidebar = Create("Frame", {Size = UDim2.new(0, 110, 1, -55), Position = UDim2.fromOffset(10, 45), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Parent = MainFrame}, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = "Center"}),
        Create("UIPadding", {PaddingTop = UDim.new(0, 8)})
    })
    ApplyPremiumBorder(Sidebar, 1.2)

    -- Container
    local Container = Create("Frame", {Size = UDim2.new(1, -140, 1, -55), Position = UDim2.fromOffset(130, 45), BackgroundTransparency = 1, Parent = MainFrame})

    local Window = {}
    local firstTab = true

    function Window:Tab(tabConfig)
        tabConfig = tabConfig or {}
        local name = tabConfig.Title or "Tab"
        
        local TabBtn = Create("TextButton", {Size = UDim2.new(0.85, 0, 0, 30), BackgroundColor3 = firstTab and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(20, 20, 20), Text = name, TextColor3 = firstTab and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(200, 200, 200), Font = Enum.Font.GothamBold, TextSize = 11, Parent = Sidebar}, {Create("UICorner", {CornerRadius = UDim.new(0, 5)})})
        local Page = Create("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = firstTab, ScrollBarThickness = 0, Parent = Container}, {Create("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = "Center"}), Create("UIPadding", {PaddingTop = UDim.new(0, 2)})})

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 20), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end end
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(220, 220, 220), TextColor3 = Color3.fromRGB(20, 20, 20)}):Play()
            Page.Visible = true
        end)

        firstTab = false
        
        local Tab = {}

        function Tab:Button(config)
            config = config or {}
            local text = config.Text or "Button"
            local callback = config.Callback or function() end
            
            local Btn = Create("TextButton", {Size = UDim2.new(0.96, 0, 0, 35), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Text = text, TextColor3 = Color3.fromRGB(230, 230, 230), Font = Enum.Font.GothamMedium, TextSize = 11, Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(Btn, 1)
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
            
            local TglFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 35), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(TglFrame, 1)
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -60, 1, 0), Parent = TglFrame})
            local TglBtn = Create("TextButton", {Size = UDim2.fromOffset(36, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = default and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(35, 35, 35), Text = "", Parent = TglFrame}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            local Circle = Create("Frame", {Size = UDim2.fromOffset(14, 14), Position = default and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = TglBtn}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            local toggled = default or false
            
            TglBtn.MouseButton1Click:Connect(function() 
                toggled = not toggled
                local targetPos = toggled and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
                local targetColor = toggled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(35, 35, 35)
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
            
            -- Slider Container
            local SliderFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 70), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(SliderFrame, 1)
            
            -- Title
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -80, 0, 15), Parent = SliderFrame})
            
            -- Value Input Box
            local InputBox = Create("TextBox", {
                Size = UDim2.fromOffset(45, 25),
                Position = UDim2.new(1, -55, 0, 5),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                Text = tostring(default),
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = "Center",
                PlaceholderText = "",
                ClearTextOnFocus = false,
                Parent = SliderFrame
            }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            
            -- Slider Bar
            local SliderBar = Create("Frame", {
                Size = UDim2.new(0.9, 0, 0, 4),
                Position = UDim2.fromOffset(10, 45),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Parent = SliderFrame
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            
            local FillBar = Create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                Parent = SliderBar
            }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            
            -- Value Display (angka di kanan slider)
            local ValueDisplay = Create("TextLabel", {
                Text = tostring(default),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Color3.fromRGB(220, 220, 220),
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
            
            -- Slider Drag
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
            
            -- Input Box Focus
            InputBox.FocusLost:Connect(function(enterPressed)
                updateValueFromInput(InputBox.Text)
            end)
            
            -- Click on Slider Bar langsung
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    updateValueFromSlider(input)
                end
            end)
        end

        return Tab
    end

    return Window
end

return Library
