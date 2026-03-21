--[[ 
    PREMIUM MODERN SILVER UI (V11) - WITH KEY SYSTEM & ANIMATED TITLE
    - Style: Compact & Refined
    - Features: URL Loader, Animated Title (letter by letter), Key System
    - Usage: loadstring(game:HttpGet("YOUR_URL_HERE"))()
]]

local Library = {}

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do obj[k] = v end
    for _,c in pairs(children or {}) do c.Parent = obj end
    return obj
end

local function ApplyPremiumBorder(parent, thickness)
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    
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
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local TweenService = game:GetService("TweenService")
    
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

-- Function to create animated title with individual letters (1 second delay between letters)
local function CreateAnimatedTitle(parent, titleText, position, size, textSize)
    local TweenService = game:GetService("TweenService")
    textSize = textSize or 14
    
    local titleContainer = Create("Frame", {
        Size = size,
        Position = position,
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    -- Split title into individual characters
    local letters = {}
    for i = 1, #titleText do
        local char = string.sub(titleText, i, i)
        table.insert(letters, char)
    end
    
    -- Create letter labels
    local letterLabels = {}
    local totalWidth = 0
    
    for i, letter in ipairs(letters) do
        local letterLabel = Create("TextLabel", {
            Text = letter,
            Font = Enum.Font.GothamBold,
            TextSize = textSize,
            TextColor3 = Color3.fromRGB(230, 230, 230),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, letter == " " and (textSize/2) or textSize + 4, 1, 0),
            Position = UDim2.new(0, totalWidth, 0, 0),
            Parent = titleContainer
        })
        
        if letter == " " then
            totalWidth = totalWidth + (textSize/2)
        else
            totalWidth = totalWidth + (textSize + 4)
        end
        
        table.insert(letterLabels, letterLabel)
    end
    
    -- Animate letters appearing one by one with 1 second delay
    for i, letterLabel in ipairs(letterLabels) do
        letterLabel.TextTransparency = 1
        task.wait(1) -- Changed from 0.05 to 1 second delay
        TweenService:Create(letterLabel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
    end
    
    return titleContainer, letterLabels
end

-- Key System Functions
local function ShowKeySystem(config, callback)
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    
    local screenGui = Create("ScreenGui", {
        Name = "KeySystemUI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")
    })
    
    -- Background blur
    local Background = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        Parent = screenGui
    })
    
    -- Key window with red/black theme
    local KeyWindow = Create("Frame", {
        Size = UDim2.fromOffset(420, 420),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(8, 8, 8),
        Parent = screenGui
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 12)})})
    ApplyPremiumBorder(KeyWindow, 2.5)
    
    -- Animated Title
    local titleText = config.Title or "KEY SYSTEM"
    local titleContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Parent = KeyWindow
    })
    
    -- Create animated title for key window with 1 second delay
    local letters = {}
    for i = 1, #titleText do
        table.insert(letters, string.sub(titleText, i, i))
    end
    
    local totalWidth = 0
    local letterLabels = {}
    for i, letter in ipairs(letters) do
        local letterLabel = Create("TextLabel", {
            Text = letter,
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextColor3 = Color3.fromRGB(230, 230, 230),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, letter == " " and 10 or 24, 0, 40),
            Position = UDim2.new(0.5, -((#letters * 24)/2) + totalWidth, 0, 10),
            Parent = titleContainer
        })
        
        if letter == " " then
            totalWidth = totalWidth + 10
        else
            totalWidth = totalWidth + 24
        end
        table.insert(letterLabels, letterLabel)
    end
    
    -- Animate key window title with 1 second delay
    for i, letterLabel in ipairs(letterLabels) do
        letterLabel.TextTransparency = 1
        task.wait(1) -- Changed from 0.05 to 1 second delay
        TweenService:Create(letterLabel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
    end
    
    -- Note text
    if config.Note then
        Create("TextLabel", {
            Text = config.Note,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 55),
            Size = UDim2.new(1, -40, 0, 30),
            TextWrapped = true,
            Parent = KeyWindow
        })
    end
    
    -- Key input box
    local KeyBox = Create("Frame", {
        Size = UDim2.new(0.85, 0, 0, 45),
        Position = UDim2.new(0.5, -170, 0, 100),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Parent = KeyWindow
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 8)})})
    
    local KeyInput = Create("TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        PlaceholderText = "Enter your key...",
        Text = "",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
        ClearTextOnFocus = false,
        Parent = KeyBox
    })
    
    -- Get Key button (NEW)
    local GetKeyBtn = Create("TextButton", {
        Size = UDim2.new(0.85, 0, 0, 40),
        Position = UDim2.new(0.5, -170, 0, 155),
        BackgroundColor3 = Color3.fromRGB(139, 0, 0), -- Dark red
        Text = "GET KEY",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = KeyWindow
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
    ApplyPremiumBorder(GetKeyBtn, 1.5)
    
    -- Submit button with red theme
    local SubmitBtn = Create("TextButton", {
        Size = UDim2.new(0.85, 0, 0, 40),
        Position = UDim2.new(0.5, -170, 0, 205),
        BackgroundColor3 = Color3.fromRGB(180, 0, 0), -- Bright red
        Text = "VERIFY KEY",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Parent = KeyWindow
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
    ApplyPremiumBorder(SubmitBtn, 1.5)
    
    -- Status text
    local StatusText = Create("TextLabel", {
        Text = "Waiting for key...",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 260),
        Size = UDim2.new(1, 0, 0, 30),
        Parent = KeyWindow
    })
    
    -- Get Key button functionality
    GetKeyBtn.MouseButton1Click:Connect(function()
        -- Add your key acquisition link here
        local keyLink = config.KeyLink or "https://example.com/getkey"
        setclipboard(keyLink)
        StatusText.Text = "✓ Key link copied to clipboard!"
        StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.wait(2)
        StatusText.Text = "Waiting for key..."
        StatusText.TextColor3 = Color3.fromRGB(150, 150, 150)
    end)
    
    -- Verify function
    local function VerifyKey(key)
        StatusText.Text = "Verifying key..."
        StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        -- Check through APIs
        local verified = false
        local apiResults = {}
        
        for _, api in ipairs(config.API or {}) do
            if api.Type == "platoboost" and api.ServiceId and api.Secret then
                -- PlatoBoost verification simulation
                local success, response = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet("https://api.platoboost.com/v1/verify/" .. api.ServiceId .. "/" .. key .. "?secret=" .. api.Secret))
                end)
                if success and response and response.valid then
                    verified = true
                    apiResults.platoboost = true
                end
            elseif api.Type == "pandadevelopment" and api.ServiceId then
                -- PandaDevelopment verification simulation
                local success, response = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet("https://api.pandadevelopment.net/verify/" .. api.ServiceId .. "/" .. key))
                end)
                if success and response and response.success then
                    verified = true
                    apiResults.pandadevelopment = true
                end
            elseif api.Type == "luarmor" and api.ScriptId then
                -- LuaArmor verification simulation
                local success, response = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet("https://api.luarmor.net/v3/scripts/" .. api.ScriptId .. "/verify?key=" .. key))
                end)
                if success and response and response.valid then
                    verified = true
                    apiResults.luarmor = true
                end
            end
        end
        
        if verified then
            StatusText.Text = "✓ Key verified successfully!"
            StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
            task.wait(1)
            screenGui:Destroy()
            if callback then callback(true) end
        else
            StatusText.Text = "✗ Invalid key! Please try again."
            StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    SubmitBtn.MouseButton1Click:Connect(function()
        if KeyInput.Text ~= "" then
            VerifyKey(KeyInput.Text)
        else
            StatusText.Text = "Please enter a key!"
            StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    -- Enter key support
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
            if KeyInput.Text ~= "" then
                VerifyKey(KeyInput.Text)
            end
        end
    end)
    
    -- Close button
    local CloseBtn = Create("ImageButton", {
        Size = UDim2.fromOffset(25, 25),
        Position = UDim2.new(1, -35, 0, 10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://74666642456643",
        ImageColor3 = Color3.fromRGB(200, 200, 200),
        Parent = KeyWindow
    })
    CloseBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if callback then callback(false) end
    end)
    
    -- Animate window popup
    KeyWindow.Size = UDim2.fromOffset(0, 0)
    TweenService:Create(KeyWindow, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(420, 420)
    }):Play()
end

function Library:CreateWindow(config)
    local UIS = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    
    local titleText = config.Title or "PREMIUM UI"
    local windowCreated = false
    local screenGui = nil
    local MainFrame = nil
    local OpenButton = nil
    local titleContainer = nil
    local letterLabels = nil
    
    -- Check if key system is enabled
    if config.KeySystem and config.KeySystem.API then
        ShowKeySystem(config.KeySystem, function(verified)
            if verified then
                CreateMainUI()
            else
                Library:Notify("Access Denied", "Key verification failed!", 3)
            end
        end)
    else
        CreateMainUI()
    end
    
    function CreateMainUI()
        if windowCreated then return end
        windowCreated = true
        
        screenGui = Create("ScreenGui", {
            Name = "PremiumSilverUI",
            ResetOnSpawn = false,
            Parent = (game:GetService("CoreGui") or Player:WaitForChild("PlayerGui"))
        })
    
        OpenButton = Create("ImageButton", {
            Size = UDim2.fromOffset(40, 40),
            Position = UDim2.new(0, 15, 0.5, -20),
            BackgroundColor3 = Color3.fromRGB(10, 10, 10),
            Image = "rbxassetid://74666642456643",
            Parent = screenGui
        }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
        ApplyPremiumBorder(OpenButton, 2)
    
        MainFrame = Create("Frame", {
            Name = "MainFrame",
            Size = UDim2.fromOffset(420, 280),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(8, 8, 8),
            Visible = true,
            Parent = screenGui
        }, {Create("UICorner", {CornerRadius = UDim.new(0, 10)})})
        ApplyPremiumBorder(MainFrame, 2.8)
    
        -- Draggable
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
            if MainFrame.Visible then 
                MainFrame:TweenSize(UDim2.fromOffset(420, 280), "Out", "Back", 0.4, true)
                -- Re-animate title when window opens with 1 second delay
                if titleContainer and letterLabels then
                    for _, letterLabel in ipairs(letterLabels) do
                        letterLabel.TextTransparency = 1
                    end
                    for i, letterLabel in ipairs(letterLabels) do
                        task.wait(1) -- Changed from 0.05 to 1 second delay
                        TweenService:Create(letterLabel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                            TextTransparency = 0
                        }):Play()
                    end
                end
            end
        end)
    
        local TopBar = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundTransparency = 1,
            Parent = MainFrame
        })
        
        -- Create animated title with letter-by-letter display (1 second delay)
        titleContainer, letterLabels = CreateAnimatedTitle(TopBar, titleText, UDim2.fromOffset(12, 0), UDim2.new(1, -60, 1, 0), 14)
        
        -- Add author text if provided
        if config.Author then
            Create("TextLabel", {
                Text = config.Author,
                Font = Enum.Font.Gotham,
                TextSize = 8,
                TextColor3 = Color3.fromRGB(150, 150, 150),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -100, 0, 25),
                Size = UDim2.new(0, 100, 0, 10),
                Parent = TopBar
            })
        end
        
        local CloseBtn = Create("ImageButton", {
            Size = UDim2.fromOffset(20, 20),
            Position = UDim2.new(1, -30, 0, 8),
            BackgroundTransparency = 1,
            Image = "rbxassetid://74666642456643",
            ImageColor3 = Color3.fromRGB(200, 200, 200),
            Parent = TopBar
        })
        CloseBtn.MouseButton1Click:Connect(function() 
            MainFrame:TweenSize(UDim2.fromOffset(0, 0), "In", "Back", 0.3, true, function() 
                MainFrame.Visible = false 
            end) 
        end)
    
        -- Sidebar with Padding
        local Sidebar = Create("Frame", {
            Size = UDim2.new(0, 110, 1, -55),
            Position = UDim2.fromOffset(10, 45),
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = MainFrame
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Create("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = "Center"}),
            Create("UIPadding", {PaddingTop = UDim.new(0, 8)})
        })
        ApplyPremiumBorder(Sidebar, 1.2)
    
        -- Container with Padding
        local Container = Create("Frame", {
            Size = UDim2.new(1, -140, 1, -55),
            Position = UDim2.fromOffset(130, 45),
            BackgroundTransparency = 1,
            Parent = MainFrame
        })
    
        local Window = {}
        local firstTab = true
    
        function Window:CreateTab(name)
            local TabBtn = Create("TextButton", {
                Size = UDim2.new(0.85, 0, 0, 30),
                BackgroundColor3 = firstTab and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(20, 20, 20),
                Text = name,
                TextColor3 = firstTab and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(200, 200, 200),
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                Parent = Sidebar
            }, {Create("UICorner", {CornerRadius = UDim.new(0, 5)})})
            
            local Page = Create("ScrollingFrame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Visible = firstTab,
                ScrollBarThickness = 0,
                Parent = Container
            }, {
                Create("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = "Center"}),
                Create("UIPadding", {PaddingTop = UDim.new(0, 2)})
            })
    
            TabBtn.MouseButton1Click:Connect(function()
                for _, v in pairs(Sidebar:GetChildren()) do 
                    if v:IsA("TextButton") then 
                        TweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 20, 20), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play() 
                    end 
                end
                for _, v in pairs(Container:GetChildren()) do 
                    v.Visible = false 
                end
                TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(220, 220, 220), TextColor3 = Color3.fromRGB(20, 20, 20)}):Play()
                Page.Visible = true
            end)
    
            firstTab = false
            local Tab = {}
    
            function Tab:CreateButton(text, callback)
                local Btn = Create("TextButton", {
                    Size = UDim2.new(0.96, 0, 0, 35),
                    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                    Text = text,
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    Parent = Page
                }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
                ApplyPremiumBorder(Btn, 1)
                Btn.MouseButton1Click:Connect(function() 
                    if callback then callback() end 
                    Btn:TweenSize(UDim2.new(0.9, 0, 0, 32), "Out", "Quad", 0.1, true, function() 
                        Btn:TweenSize(UDim2.new(0.96, 0, 0, 35), "Out", "Quad", 0.1, true) 
                    end) 
                end)
            end
    
            function Tab:CreateToggle(text, callback)
                local TglFrame = Create("Frame", {
                    Size = UDim2.new(0.96, 0, 0, 35),
                    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                    Parent = Page
                }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
                ApplyPremiumBorder(TglFrame, 1)
                
                Create("TextLabel", {
                    Text = text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(10, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Parent = TglFrame
                })
                
                local TglBtn = Create("TextButton", {
                    Size = UDim2.fromOffset(36, 18),
                    Position = UDim2.new(1, -46, 0.5, -9),
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Text = "",
                    Parent = TglFrame
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                local Circle = Create("Frame", {
                    Size = UDim2.fromOffset(14, 14),
                    Position = UDim2.fromOffset(2, 2),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = TglBtn
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                local toggled = false
                TglBtn.MouseButton1Click:Connect(function() 
                    toggled = not toggled
                    local targetPos = toggled and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
                    local targetColor = toggled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(35, 35, 35)
                    TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos}):Play()
                    TweenService:Create(TglBtn, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
                    if callback then callback(toggled) end 
                end)
            end
    
            function Tab:CreateSlider(text, min, max, default, callback)
                local SliderFrame = Create("Frame", {
                    Size = UDim2.new(0.96, 0, 0, 55),
                    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                    Parent = Page
                }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
                ApplyPremiumBorder(SliderFrame, 1)
                
                Create("TextLabel", {
                    Text = text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 11,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(10, 5),
                    Size = UDim2.new(1, -20, 0, 15),
                    Parent = SliderFrame
                })
                
                local ValueLabel = Create("TextLabel", {
                    Text = tostring(default),
                    Font = Enum.Font.GothamBold,
                    TextSize = 10,
                    TextColor3 = Color3.fromRGB(220, 220, 220),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 5),
                    Size = UDim2.new(0, 35, 0, 15),
                    Parent = SliderFrame
                })
                
                local SliderBar = Create("Frame", {
                    Size = UDim2.new(0.9, 0, 0, 4),
                    Position = UDim2.new(0.05, 0, 0.7, 0),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Parent = SliderFrame
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                local Fill = Create("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(200, 200, 200),
                    Parent = SliderBar
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                local value = default
                local dragging = false
                
                local function update(input)
                    local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    value = math.floor(min + (max - min) * pos)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    if callback then callback(value) end
                end
                
                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        update(input)
                    end
                end)
                
                UIS.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        update(input)
                    end
                end)
                
                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
            end
    
            return Tab
        end
    
        return Window
    end
end

return Library
