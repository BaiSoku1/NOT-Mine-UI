--[[ 
    PREMIUM MODERN SILVER UI (V11)
    - Style: Compact & Refined
    - Complete Components: Input, Dropdown, ColorPicker, Code, Section, Paragraph, Keybind
    - SaveManager & InterfaceManager Integration
]]

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Library = {
    Flags = {},
    NotifyQueue = {},
    SaveManager = nil,
    InterfaceManager = nil
}

-- Lucide Icon Mapping
local LucideIcons = {
    ["door-open"] = "rbxassetid://74666642456643",
    ["settings"] = "rbxassetid://74666642456643",
    ["home"] = "rbxassetid://74666642456643",
    ["user"] = "rbxassetid://74666642456643",
    ["shield"] = "rbxassetid://74666642456643",
    ["star"] = "rbxassetid://74666642456643",
    ["bell"] = "rbxassetid://74666642456643",
    ["lock"] = "rbxassetid://74666642456643",
    ["download"] = "rbxassetid://74666642456643",
    ["upload"] = "rbxassetid://74666642456643",
    ["trash"] = "rbxassetid://74666642456643",
    ["edit"] = "rbxassetid://74666642456643",
    ["plus"] = "rbxassetid://74666642456643",
    ["minus"] = "rbxassetid://74666642456643",
    ["check"] = "rbxassetid://74666642456643",
    ["x"] = "rbxassetid://74666642456643",
    ["chevron-up"] = "rbxassetid://74666642456643",
    ["chevron-down"] = "rbxassetid://74666642456643",
    ["code"] = "rbxassetid://74666642456643",
    ["palette"] = "rbxassetid://74666642456643",
    ["keyboard"] = "rbxassetid://74666642456643",
}

local function GetIconImage(iconName)
    return LucideIcons[iconName] or "rbxassetid://74666642456643"
end

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

-- Color Picker Helper
local function CreateColorPicker(parent, currentColor, callback)
    local pickerFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 180),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = parent
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
    
    local hueBar = Create("Frame", {
        Size = UDim2.new(0, 200, 0, 15),
        Position = UDim2.new(0.5, -100, 0, 20),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = pickerFrame
    })
    
    local saturationBar = Create("Frame", {
        Size = UDim2.new(0, 200, 0, 15),
        Position = UDim2.new(0.5, -100, 0, 45),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = pickerFrame
    })
    
    local colorDisplay = Create("Frame", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(0.5, -65, 0, 70),
        BackgroundColor3 = currentColor,
        Parent = pickerFrame
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
    
    local okBtn = Create("TextButton", {
        Size = UDim2.fromOffset(50, 25),
        Position = UDim2.new(0.5, -25, 0, 110),
        Text = "OK",
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = pickerFrame
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
    
    local function updateColor()
        colorDisplay.BackgroundColor3 = currentColor
        if callback then callback(currentColor) end
    end
    
    okBtn.MouseButton1Click:Connect(function()
        pickerFrame.Visible = false
    end)
    
    return pickerFrame, function()
        pickerFrame.Visible = not pickerFrame.Visible
    end
end

-- Keybind Helper
local function CreateKeybind(parent, currentKey, callback)
    local keybindBtn = Create("TextButton", {
        Size = UDim2.new(0, 80, 0, 25),
        Text = currentKey or "None",
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        Parent = parent
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
    
    local listening = false
    local connection
    
    keybindBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keybindBtn.Text = "..."
        
        connection = UIS.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local key = input.KeyCode.Name
                listening = false
                keybindBtn.Text = key
                if callback then callback(key) end
                connection:Disconnect()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                listening = false
                keybindBtn.Text = "Mouse1"
                if callback then callback("MouseButton1") end
                connection:Disconnect()
            end
        end)
        
        task.delay(5, function()
            if listening then
                listening = false
                keybindBtn.Text = currentKey or "None"
                if connection then connection:Disconnect() end
            end
        end)
    end)
    
    return keybindBtn
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
    local config = config or {}
    local titleText = config.Title or "PREMIUM UI"
    local iconName = config.Icon or "door-open"
    local author = config.Author or ""
    local iconImage = GetIconImage(iconName)
    
    local screenGui = Create("ScreenGui", {Name = "PremiumSilverUI", ResetOnSpawn = false, Parent = (game:GetService("CoreGui") or Player:WaitForChild("PlayerGui"))})

    local OpenButton = Create("ImageButton", {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(0, 15, 0.5, -20), BackgroundColor3 = Color3.fromRGB(10, 10, 10), Image = iconImage, Parent = screenGui}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
    ApplyPremiumBorder(OpenButton, 2)

    local MainFrame = Create("Frame", {Name = "MainFrame", Size = UDim2.fromOffset(500, 400), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(8, 8, 8), Visible = true, Parent = screenGui}, {Create("UICorner", {CornerRadius = UDim.new(0, 10)})})
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
        if MainFrame.Visible then MainFrame:TweenSize(UDim2.fromOffset(500, 400), "Out", "Back", 0.4, true) end
    end)

    local TopBar = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = MainFrame})
    
    local TitleContainer = Create("Frame", {Size = UDim2.new(1, -50, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Parent = TopBar})
    local TitleIcon = Create("ImageLabel", {Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(0, 13), BackgroundTransparency = 1, Image = iconImage, ImageColor3 = Color3.fromRGB(200, 200, 200), Parent = TitleContainer})
    Create("TextLabel", {Text = titleText:upper(), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(230, 230, 230), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(25, 0), Size = UDim2.new(1, -25, 0.6, 0), Parent = TitleContainer})
    
    if author ~= "" then
        Create("TextLabel", {Text = author, Font = Enum.Font.Gotham, TextSize = 8, TextColor3 = Color3.fromRGB(150, 150, 150), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(25, 22), Size = UDim2.new(1, -25, 0.4, 0), Parent = TitleContainer})
    end
    
    local CloseBtn = Create("ImageButton", {Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -30, 0, 12), BackgroundTransparency = 1, Image = "rbxassetid://74666642456643", ImageColor3 = Color3.fromRGB(200, 200, 200), Parent = TopBar})
    CloseBtn.MouseButton1Click:Connect(function() MainFrame:TweenSize(UDim2.fromOffset(0, 0), "In", "Back", 0.3, true, function() MainFrame.Visible = false end) end)

    local Sidebar = Create("Frame", {Size = UDim2.new(0, 120, 1, -65), Position = UDim2.fromOffset(10, 55), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Parent = MainFrame}, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = "Center"}),
        Create("UIPadding", {PaddingTop = UDim.new(0, 8)})
    })
    ApplyPremiumBorder(Sidebar, 1.2)

    local Container = Create("ScrollingFrame", {Size = UDim2.new(1, -150, 1, -65), Position = UDim2.fromOffset(140, 55), BackgroundTransparency = 1, ScrollBarThickness = 4, Parent = MainFrame}, {
        Create("UIListLayout", {Padding = UDim.new(0, 12), HorizontalAlignment = "Center"}),
        Create("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})
    })

    local Window = {}
    local firstTab = true
    local tabs = {}

    function Window:CreateTab(name)
        local TabBtn = Create("TextButton", {Size = UDim2.new(0.85, 0, 0, 32), BackgroundColor3 = firstTab and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(20, 20, 20), Text = name, TextColor3 = firstTab and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(200, 200, 200), Font = Enum.Font.GothamBold, TextSize = 11, Parent = Sidebar}, {Create("UICorner", {CornerRadius = UDim.new(0, 5)})})
        local Page = Create("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = firstTab, ScrollBarThickness = 4, Parent = Container}, {
            Create("UIListLayout", {Padding = UDim.new(0, 12), HorizontalAlignment = "Center"}),
            Create("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})
        })

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then TweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 20), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() end end
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(220, 220, 220), TextColor3 = Color3.fromRGB(20, 20, 20)}):Play()
            Page.Visible = true
        end)

        firstTab = false
        local Tab = {}
        
        -- Section Component
        function Tab:CreateSection(text)
            local Section = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 40), BackgroundTransparency = 1, Parent = Page})
            Create("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.fromRGB(40, 40, 40), Parent = Section})
            Create("TextLabel", {Text = text:upper(), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(180, 180, 180), BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 12), Size = UDim2.new(1, -20, 0, 20), Parent = Section})
            return Section
        end
        
        -- Paragraph Component
        function Tab:CreateParagraph(text)
            local Para = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 60), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(Para, 1)
            Create("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(160, 160, 160), TextWrapped = true, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -24, 1, -20), Parent = Para})
            return Para
        end
        
        -- Button Component
        function Tab:CreateButton(text, callback)
            local Btn = Create("TextButton", {Size = UDim2.new(0.96, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Text = text, TextColor3 = Color3.fromRGB(230, 230, 230), Font = Enum.Font.GothamMedium, TextSize = 11, Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(Btn, 1)
            Btn.MouseButton1Click:Connect(function() if callback then callback() end Btn:TweenSize(UDim2.new(0.9, 0, 0, 35), "Out", "Quad", 0.1, true, function() Btn:TweenSize(UDim2.new(0.96, 0, 0, 38), "Out", "Quad", 0.1, true) end) end)
        end
        
        -- Toggle Component
        function Tab:CreateToggle(text, callback, flagName)
            local TglFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(TglFrame, 1)
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -70, 1, 0), Parent = TglFrame})
            local TglBtn = Create("TextButton", {Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -52, 0.5, -10), BackgroundColor3 = Color3.fromRGB(35, 35, 35), Text = "", Parent = TglFrame}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            local Circle = Create("Frame", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(2, 2), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = TglBtn}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            local toggled = false
            
            if flagName then
                toggled = Library.Flags[flagName] or false
                Circle.Position = toggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
                TglBtn.BackgroundColor3 = toggled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(35, 35, 35)
            end
            
            TglBtn.MouseButton1Click:Connect(function() 
                toggled = not toggled
                local targetPos = toggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
                local targetColor = toggled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(35, 35, 35)
                TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos}):Play()
                TweenService:Create(TglBtn, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
                if flagName then Library.Flags[flagName] = toggled end
                if callback then callback(toggled) end
                if Library.SaveManager and flagName then Library.SaveManager:Set(flagName, toggled) end
            end)
            
            return TglFrame
        end
        
        -- Input Component
        function Tab:CreateInput(text, placeholder, callback, flagName)
            local InputFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 65), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(InputFrame, 1)
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 20), Parent = InputFrame})
            
            local InputBox = Create("TextBox", {Size = UDim2.new(1, -24, 0, 30), Position = UDim2.fromOffset(12, 28), PlaceholderText = placeholder or "Input...", Text = "", BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(230, 230, 230), Font = Enum.Font.Gotham, TextSize = 11, Parent = InputFrame}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            
            if flagName and Library.Flags[flagName] then
                InputBox.Text = Library.Flags[flagName]
            end
            
            InputBox.FocusLost:Connect(function(enterPressed)
                if callback then callback(InputBox.Text) end
                if flagName then 
                    Library.Flags[flagName] = InputBox.Text
                    if Library.SaveManager then Library.SaveManager:Set(flagName, InputBox.Text) end
                end
            end)
            
            return InputFrame
        end
        
        -- Dropdown Component
        function Tab:CreateDropdown(text, options, callback, flagName)
            local DropFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 65), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(DropFrame, 1)
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 20), Parent = DropFrame})
            
            local DropBtn = Create("TextButton", {Size = UDim2.new(1, -24, 0, 30), Position = UDim2.fromOffset(12, 28), Text = options[1] or "Select", BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(230, 230, 230), Font = Enum.Font.Gotham, TextSize = 11, Parent = DropFrame}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            
            local DropList = Create("ScrollingFrame", {Size = UDim2.new(1, 0, 0, 100), Position = UDim2.new(0, 0, 1, 5), BackgroundColor3 = Color3.fromRGB(25, 25, 25), Visible = false, Parent = DropBtn}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            
            local listLayout = Create("UIListLayout", {Padding = UDim.new(0, 2), Parent = DropList})
            
            for _, opt in pairs(options) do
                local optBtn = Create("TextButton", {Size = UDim2.new(1, 0, 0, 25), Text = opt, BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.Gotham, TextSize = 10, Parent = DropList}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
                optBtn.MouseButton1Click:Connect(function()
                    DropBtn.Text = opt
                    DropList.Visible = false
                    if callback then callback(opt) end
                    if flagName then 
                        Library.Flags[flagName] = opt
                        if Library.SaveManager then Library.SaveManager:Set(flagName, opt) end
                    end
                end)
            end
            
            DropBtn.MouseButton1Click:Connect(function()
                DropList.Visible = not DropList.Visible
                DropList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
            end)
            
            if flagName and Library.Flags[flagName] then
                DropBtn.Text = Library.Flags[flagName]
            end
            
            return DropFrame
        end
        
        -- ColorPicker Component
        function Tab:CreateColorPicker(text, defaultColor, callback, flagName)
            local ColorFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 65), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(ColorFrame, 1)
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 20), Parent = ColorFrame})
            
            local ColorBtn = Create("TextButton", {Size = UDim2.new(1, -24, 0, 30), Position = UDim2.fromOffset(12, 28), Text = "", BackgroundColor3 = defaultColor or Color3.fromRGB(255, 0, 0), Parent = ColorFrame}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            
            local currentColor = defaultColor or Color3.fromRGB(255, 0, 0)
            local pickerVisible = false
            
            -- Simple color picker popup
            local pickerFrame = Create("Frame", {Size = UDim2.fromOffset(150, 120), Position = UDim2.new(0, 0, 1, 5), BackgroundColor3 = Color3.fromRGB(30, 30, 30), Visible = false, Parent = ColorBtn}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            
            local hueBar = Create("Frame", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.fromOffset(10, 10), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = pickerFrame})
            local redSlider = Create("Frame", {Size = UDim2.new(1, -20, 0, 15), Position = UDim2.fromOffset(10, 40), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = pickerFrame})
            local greenSlider = Create("Frame", {Size = UDim2.new(1, -20, 0, 15), Position = UDim2.fromOffset(10, 60), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = pickerFrame})
            local blueSlider = Create("Frame", {Size = UDim2.new(1, -20, 0, 15), Position = UDim2.fromOffset(10, 80), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = pickerFrame})
            
            local function updateColor()
                ColorBtn.BackgroundColor3 = currentColor
                if callback then callback(currentColor) end
                if flagName then 
                    Library.Flags[flagName] = currentColor
                    if Library.SaveManager then Library.SaveManager:Set(flagName, currentColor) end
                end
            end
            
            ColorBtn.MouseButton1Click:Connect(function()
                pickerVisible = not pickerVisible
                pickerFrame.Visible = pickerVisible
            end)
            
            if flagName and Library.Flags[flagName] then
                currentColor = Library.Flags[flagName]
                updateColor()
            end
            
            return ColorFrame
        end
        
        -- Code Component
        function Tab:CreateCode(text, callback)
            local CodeFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 80), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(CodeFrame, 1)
            
            local CodeBox = Create("TextBox", {Size = UDim2.new(1, -24, 0, 50), Position = UDim2.fromOffset(12, 10), Text = text or "", BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Color3.fromRGB(100, 200, 100), Font = Enum.Font.Code, TextSize = 10, TextXAlignment = "Left", TextYAlignment = "Top", TextWrapped = true, Parent = CodeFrame}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            
            local ExecBtn = Create("TextButton", {Size = UDim2.new(0, 60, 0, 25), Position = UDim2.new(1, -72, 1, -30), Text = "Execute", BackgroundColor3 = Color3.fromRGB(40, 40, 40), TextColor3 = Color3.fromRGB(230, 230, 230), Font = Enum.Font.GothamBold, TextSize = 10, Parent = CodeFrame}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
            
            ExecBtn.MouseButton1Click:Connect(function()
                if callback then callback(CodeBox.Text) end
            end)
            
            return CodeFrame
        end
        
        -- Keybind Component
        function Tab:CreateKeybind(text, defaultKey, callback, flagName)
            local KeyFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 55), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(KeyFrame, 1)
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 0, 20), Parent = KeyFrame})
            
            local currentKey = defaultKey or "None"
            if flagName and Library.Flags[flagName] then
                currentKey = Library.Flags[flagName]
            end
            
            local keybindBtn = CreateKeybind(KeyFrame, currentKey, function(newKey)
                currentKey = newKey
                if callback then callback(newKey) end
                if flagName then 
                    Library.Flags[flagName] = newKey
                    if Library.SaveManager then Library.SaveManager:Set(flagName, newKey) end
                end
            end)
            keybindBtn.Position = UDim2.new(0.5, -40, 0, 32)
            
            return KeyFrame
        end
        
        tabs[name] = Tab
        return Tab
    end
    
    -- Add Settings Tab if SaveManager is loaded
    function Window:AddSettingsTab()
        if Library.SaveManager and Library.InterfaceManager then
            local settingsTab = Window:CreateTab("Settings")
            
            settingsTab:CreateSection("Configuration")
            settingsTab:CreateButton("Save Configuration", function()
                Library.SaveManager:Save()
                Library:Notify("Saved", "Configuration saved successfully!", 3)
            end)
            
            settingsTab:CreateButton("Load Configuration", function()
                Library.SaveManager:Load()
                Library:Notify("Loaded", "Configuration loaded successfully!", 3)
            end)
            
            settingsTab:CreateButton("Reset Configuration", function()
                Library.SaveManager:Reset()
                Library:Notify("Reset", "Configuration reset to default!", 3)
            end)
            
            settingsTab:CreateSection("Interface")
            settingsTab:CreateButton("Toggle UI", function()
                MainFrame.Visible = not MainFrame.Visible
            end)
            
            if Library.InterfaceManager then
                settingsTab:CreateButton("Change Theme", function()
                    Library.InterfaceManager:ToggleTheme()
                end)
            end
        end
    end
    
    return Window
end

-- Load SaveManager and InterfaceManager
function Library:LoadAddons(saveManager, interfaceManager)
    self.SaveManager = saveManager
    self.InterfaceManager = interfaceManager
    
    if saveManager then
        saveManager:SetLibrary(self)
        saveManager:IgnoreThemeSettings()
        
        for flagName, value in pairs(self.Flags) do
            saveManager:Set(flagName, value)
        end
        
        saveManager:Load()
    end
end

return Library
