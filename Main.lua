--[[ 
    PREMIUM MODERN SILVER UI (V11)
    - Style: Compact & Refined
    - Fixes: Adjusted Padding for Tabs, Smaller UI Size
    - Icons: BX Close & ID Open (74666642456643)
    - NEW: URL-based window creation with Lucide icons
]]

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local Library = {}

-- Lucide Icon Mapping (Common Icons)
local LucideIcons = {
    ["door-open"] = "rbxassetid://74666642456643", -- Use your existing icon as placeholder
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
    ["chevron-left"] = "rbxassetid://74666642456643",
    ["chevron-right"] = "rbxassetid://74666642456643",
    ["arrow-up"] = "rbxassetid://74666642456643",
    ["arrow-down"] = "rbxassetid://74666642456643",
    ["arrow-left"] = "rbxassetid://74666642456643",
    ["arrow-right"] = "rbxassetid://74666642456643",
    ["copy"] = "rbxassetid://74666642456643",
    ["clipboard"] = "rbxassetid://74666642456643",
    ["link"] = "rbxassetid://74666642456643",
    ["external-link"] = "rbxassetid://74666642456643",
    ["info"] = "rbxassetid://74666642456643",
    ["alert-circle"] = "rbxassetid://74666642456643",
    ["alert-triangle"] = "rbxassetid://74666642456643",
    ["check-circle"] = "rbxassetid://74666642456643",
    ["x-circle"] = "rbxassetid://74666642456643",
    ["help-circle"] = "rbxassetid://74666642456643",
    ["mail"] = "rbxassetid://74666642456643",
    ["phone"] = "rbxassetid://74666642456643",
    ["map-pin"] = "rbxassetid://74666642456643",
    ["calendar"] = "rbxassetid://74666642456643",
    ["clock"] = "rbxassetid://74666642456643",
    ["eye"] = "rbxassetid://74666642456643",
    ["eye-off"] = "rbxassetid://74666642456643",
    ["volume-2"] = "rbxassetid://74666642456643",
    ["volume-x"] = "rbxassetid://74666642456643",
    ["music"] = "rbxassetid://74666642456643",
    ["play"] = "rbxassetid://74666642456643",
    ["pause"] = "rbxassetid://74666642456643",
    ["skip-forward"] = "rbxassetid://74666642456643",
    ["skip-back"] = "rbxassetid://74666642456643",
    ["refresh-cw"] = "rbxassetid://74666642456643",
    ["loader"] = "rbxassetid://74666642456643",
    ["wifi"] = "rbxassetid://74666642456643",
    ["battery"] = "rbxassetid://74666642456643",
    ["cpu"] = "rbxassetid://74666642456643",
    ["hard-drive"] = "rbxassetid://74666642456643",
    ["database"] = "rbxassetid://74666642456643",
    ["cloud"] = "rbxassetid://74666642456643",
    ["folder"] = "rbxassetid://74666642456643",
    ["file"] = "rbxassetid://74666642456643",
    ["image"] = "rbxassetid://74666642456643",
    ["video"] = "rbxassetid://74666642456643",
    ["mic"] = "rbxassetid://74666642456643",
    ["headphones"] = "rbxassetid://74666642456643",
    ["monitor"] = "rbxassetid://74666642456643",
    ["smartphone"] = "rbxassetid://74666642456643",
    ["tablet"] = "rbxassetid://74666642456643",
    ["watch"] = "rbxassetid://74666642456643",
    ["globe"] = "rbxassetid://74666642456643",
    ["compass"] = "rbxassetid://74666642456643",
    ["navigation"] = "rbxassetid://74666642456643",
    ["anchor"] = "rbxassetid://74666642456643",
    ["flag"] = "rbxassetid://74666642456643",
    ["award"] = "rbxassetid://74666642456643",
    ["trophy"] = "rbxassetid://74666642456643",
    ["medal"] = "rbxassetid://74666642456643",
    ["gift"] = "rbxassetid://74666642456643",
    ["heart"] = "rbxassetid://74666642456643",
    ["thumbs-up"] = "rbxassetid://74666642456643",
    ["thumbs-down"] = "rbxassetid://74666642456643",
    ["smile"] = "rbxassetid://74666642456643",
    ["frown"] = "rbxassetid://74666642456643",
    ["meh"] = "rbxassetid://74666642456643",
}

local function GetIconImage(iconName)
    return LucideIcons[iconName] or "rbxassetid://74666642456643" -- Default icon if not found
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

    local MainFrame = Create("Frame", {Name = "MainFrame", Size = UDim2.fromOffset(420, 320), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(8, 8, 8), Visible = true, Parent = screenGui}, {Create("UICorner", {CornerRadius = UDim.new(0, 10)})})
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
        if MainFrame.Visible then MainFrame:TweenSize(UDim2.fromOffset(420, 320), "Out", "Back", 0.4, true) end
    end)

    local TopBar = Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Parent = MainFrame})
    
    -- Title with Icon
    local TitleContainer = Create("Frame", {Size = UDim2.new(1, -50, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Parent = TopBar})
    
    -- Icon in title (small)
    local TitleIcon = Create("ImageLabel", {Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(0, 13), BackgroundTransparency = 1, Image = iconImage, ImageColor3 = Color3.fromRGB(200, 200, 200), Parent = TitleContainer})
    
    Create("TextLabel", {Text = titleText:upper(), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(230, 230, 230), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(25, 0), Size = UDim2.new(1, -25, 0.6, 0), Parent = TitleContainer})
    
    -- Author text if provided
    if author ~= "" then
        Create("TextLabel", {Text = author, Font = Enum.Font.Gotham, TextSize = 8, TextColor3 = Color3.fromRGB(150, 150, 150), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(25, 22), Size = UDim2.new(1, -25, 0.4, 0), Parent = TitleContainer})
    end
    
    local CloseBtn = Create("ImageButton", {Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -30, 0, 12), BackgroundTransparency = 1, Image = "rbxassetid://74666642456643", ImageColor3 = Color3.fromRGB(200, 200, 200), Parent = TopBar})
    CloseBtn.MouseButton1Click:Connect(function() MainFrame:TweenSize(UDim2.fromOffset(0, 0), "In", "Back", 0.3, true, function() MainFrame.Visible = false end) end)

    -- Sidebar with Padding
    local Sidebar = Create("Frame", {Size = UDim2.new(0, 110, 1, -65), Position = UDim2.fromOffset(10, 55), BackgroundColor3 = Color3.fromRGB(12, 12, 12), Parent = MainFrame}, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = "Center"}),
        Create("UIPadding", {PaddingTop = UDim.new(0, 8)})
    })
    ApplyPremiumBorder(Sidebar, 1.2)

    -- Container with Padding
    local Container = Create("Frame", {Size = UDim2.new(1, -140, 1, -65), Position = UDim2.fromOffset(130, 55), BackgroundTransparency = 1, Parent = MainFrame})

    local Window = {}
    local firstTab = true

    function Window:CreateTab(name)
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

        function Tab:CreateButton(text, callback)
            local Btn = Create("TextButton", {Size = UDim2.new(0.96, 0, 0, 35), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Text = text, TextColor3 = Color3.fromRGB(230, 230, 230), Font = Enum.Font.GothamMedium, TextSize = 11, Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(Btn, 1)
            Btn.MouseButton1Click:Connect(function() if callback then callback() end Btn:TweenSize(UDim2.new(0.9, 0, 0, 32), "Out", "Quad", 0.1, true, function() Btn:TweenSize(UDim2.new(0.96, 0, 0, 35), "Out", "Quad", 0.1, true) end) end)
        end

        function Tab:CreateToggle(text, callback)
            local TglFrame = Create("Frame", {Size = UDim2.new(0.96, 0, 0, 35), BackgroundColor3 = Color3.fromRGB(18, 18, 18), Parent = Page}, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            ApplyPremiumBorder(TglFrame, 1)
            Create("TextLabel", {Text = text, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(200, 200, 200), TextXAlignment = "Left", BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -60, 1, 0), Parent = TglFrame})
            local TglBtn = Create("TextButton", {Size = UDim2.fromOffset(36, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = Color3.fromRGB(35, 35, 35), Text = "", Parent = TglFrame}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            local Circle = Create("Frame", {Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(2, 2), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = TglBtn}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
            local toggled = false
            TglBtn.MouseButton1Click:Connect(function() toggled = not toggled; local targetPos = toggled and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2); local targetColor = toggled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(35, 35, 35); TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos}):Play(); TweenService:Create(TglBtn, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play(); if callback then callback(toggled) end end)
        end

        return Tab
    end

    return Window
end

-- Export the library
return Library
