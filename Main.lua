--[[ 
    PREMIUM MODERN SILVER UI (V12) - WITH OPTIONAL KEY SYSTEM & ANIMATED TITLE
    - Style: Compact & Refined
    - Features: URL Loader, Animated Title (letter by letter), Optional Key System, Get Key Button, Transparency
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

-- Function to create animated title with individual letters
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
    
    -- Animate letters appearing one by one
    for i, letterLabel in ipairs(letterLabels) do
        letterLabel.TextTransparency = 1
        task.wait(0.05)
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
    
    -- Key window
    local KeyWindow = Create("Frame", {
        Size = UDim2.fromOffset(420, 380),
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
    
    -- Create animated title for key window
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
    
    -- Animate key window title
    for i, letterLabel in ipairs(letterLabels) do
        letterLabel.TextTransparency = 1
        task.wait(0.05)
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
    
    -- Submit button
    local SubmitBtn = Create("TextButton", {
        Size = UDim2.new(0.4, 0, 0, 40),
        Position = UDim2.new(0.05, 0, 0, 165),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Text = "VERIFY KEY",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Parent = KeyWindow
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
    ApplyPremiumBorder(SubmitBtn, 1.5)
    
    -- Get Key button
    local GetKeyBtn = Create("TextButton", {
        Size = UDim2.new(0.4, 0, 0, 40),
        Position = UDim2.new(0.55, 0, 0, 165),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Text = "GET KEY",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Parent = KeyWindow
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
    ApplyPremiumBorder(GetKeyBtn, 1.5)
    
    -- Status text
    local StatusText = Create("TextLabel", {
        Text = "Waiting for key...",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 220),
        Size = UDim2.new(1, 0, 0, 30),
        Parent = KeyWindow
    })
    
    -- Get key URL function
    local function OpenGetKeyURL()
        if config.GetKeyURL then
            local Animation = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vraigos/Fluent-Modded/refs/heads/master/src/Components/AnimateGui.lua"))()
            if Animation and Animation.AnimateGui then
                Animation.AnimateGui(config.GetKeyURL)
            else
                Library:Notify("Key Link", "Link copied to clipboard!", 3)
                setclipboard(config.GetKeyURL)
            end
        else
            Library:Notify("Error", "No key link provided!", 3)
        end
    end
    
    -- Verify function
    local function VerifyKey(key)
        StatusText.Text = "Verifying key..."
        StatusText.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        local verified = false
        
        for _, api in ipairs(config.API or {}) do
            if api.Type == "platoboost" and api.ServiceId and api.Secret then
                local success, response = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet("https://api.platoboost.com/v1/verify/" .. api.ServiceId .. "/" .. key .. "?secret=" .. api.Secret))
                end)
                if success and response and response.valid then
                    verified = true
                end
            elseif api.Type == "pandadevelopment" and api.ServiceId then
                local success, response = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet("https://api.pandadevelopment.net/verify/" .. api.ServiceId .. "/" .. key))
                end)
                if success and response and response.success then
                    verified = true
                end
            elseif api.Type == "luarmor" and api.ScriptId then
                local success, response = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet("https://api.luarmor.net/v3/scripts/" .. api.ScriptId .. "/verify?key=" .. key))
                end)
                if success and response and response.valid then
                    verified = true
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
    
    GetKeyBtn.MouseButton1Click:Connect(function()
        OpenGetKeyURL()
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
        Size = UDim2.fromOffset(420, 380)
    }):Play()
end

function Library:CreateWindow(config)
    local UIS = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    
    local titleText = config.Title or "PREMIUM UI"
    local isTransparent = config.Transparent or false
    local windowCreated = false
    local screenGui = nil
    local MainFrame = nil
    local OpenButton = nil
    local titleContainer = nil
    local letterLabels = nil
    local Sidebar = nil
    local Container = nil
    local Tabs = {}
    
    -- Background color based on transparency setting
    local bgColor = isTransparent and Color3.fromRGB(8, 8, 8) or Color3.fromRGB(8, 8, 8)
    local sideBgColor = isTransparent and Color3.fromRGB(12, 12, 12) or Color3.fromRGB(12, 12, 12)
    local bgTransparency = isTransparent and 0.15 or 0
    local sideTransparency = isTransparent and 0.1 or 0
    
    -- Check if key system is enabled (only if config.KeySystem exists and has API)
    if config.KeySystem and config.KeySystem.API and #config.KeySystem.API > 0 then
        ShowKeySystem(config.KeySystem, function(verified)
            if verified then
                CreateMainUI()
            else
                Library:Notify("Access Denied", "Key verification failed!", 3)
            end
        end)
    else
        -- No key system, langsung buat UI
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
            Size = UDim2.fromOffset(420, 380),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = bgColor,
            BackgroundTransparency = bgTransparency,
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
                MainFrame:TweenSize(UDim2.fromOffset(420, 380), "Out", "Back", 0.4, true)
                -- Re-animate title when window opens
                if titleContainer and letterLabels then
                    for _, letterLabel in ipairs(letterLabels) do
                        letterLabel.TextTransparency = 1
                    end
                    for i, letterLabel in ipairs(letterLabels) do
                        task.wait(0.05)
                        TweenService:Create(letterLabel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                            TextTransparency = 0
                        }):Play()
                    end
                end
            end
        end)
    
        local TopBar = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundTransparency = 1,
            Parent = MainFrame
        })
        
        -- Create animated title with letter-by-letter display
        titleContainer, letterLabels = CreateAnimatedTitle(TopBar, titleText, UDim2.fromOffset(12, 10), UDim2.new(1, -60, 1, 0), 16)
        
        -- Add author text if provided
        if config.Author then
            Create("TextLabel", {
                Text = config.Author,
                Font = Enum.Font.Gotham,
                TextSize = 9,
                TextColor3 = Color3.fromRGB(150, 150, 150),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -100, 0, 30),
                Size = UDim2.new(0, 100, 0, 12),
                Parent = TopBar
            })
        end
        
        local CloseBtn = Create("ImageButton", {
            Size = UDim2.fromOffset(24, 24),
            Position = UDim2.new(1, -35, 0, 10),
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
        
        -- Line separator
        Create("Frame", {
            Size = UDim2.new(1, -20, 0, 1),
            Position = UDim2.new(0, 10, 0, 44),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            Parent = MainFrame
        })
    
        -- Sidebar with Padding
        Sidebar = Create("Frame", {
            Size = UDim2.new(0, 120, 1, -55),
            Position = UDim2.fromOffset(10, 55),
            BackgroundColor3 = sideBgColor,
            BackgroundTransparency = sideTransparency,
            Parent = MainFrame
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Create("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})
        })
        ApplyPremiumBorder(Sidebar, 1.2)
    
        -- Container with Padding
        Container = Create("Frame", {
            Size = UDim2.new(1, -145, 1, -65),
            Position = UDim2.fromOffset(135, 55),
            BackgroundTransparency = 1,
            Parent = MainFrame
        })
        
        -- UIListLayout for sidebar buttons
        local SidebarLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Sidebar
        })
    
        local Window = {}
        local firstTab = true
        local currentPage = nil
    
        function Window:CreateTab(name)
            local TabBtn = Create("TextButton", {
                Size = UDim2.new(0.9, 0, 0, 35),
                BackgroundColor3 = firstTab and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(25, 25, 25),
                Text = name,
                TextColor3 = firstTab and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(200, 200, 200),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                BackgroundTransparency = 0,
                Parent = Sidebar
            }, {Create("UICorner", {CornerRadius = UDim.new(0, 6)})})
            
            local Page = Create("ScrollingFrame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Visible = firstTab,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Parent = Container
            }, {
                Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center}),
                Create("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10)})
            })
            
            if firstTab then
                currentPage = Page
            end
            
            TabBtn.MouseButton1Click:Connect(function()
                -- Update all sidebar buttons
                for _, v in pairs(Sidebar:GetChildren()) do 
                    if v:IsA("TextButton") then 
                        TweenService:Create(v, TweenInfo.new(0.2), {
                            BackgroundColor3 = Color3.fromRGB(25, 25, 25), 
                            TextColor3 = Color3.fromRGB(200, 200, 200)
                        }):Play() 
                    end 
                end
                -- Hide all pages
                for _, v in pairs(Container:GetChildren()) do 
                    if v:IsA("ScrollingFrame") then
                        v.Visible = false 
                    end
                end
                -- Show current page
                Page.Visible = true
                currentPage = Page
                -- Update button style
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(220, 220, 220), 
                    TextColor3 = Color3.fromRGB(20, 20, 20)
                }):Play()
            end)
    
            firstTab = false
            local Tab = {}
            
            -- Function to update canvas size
            local function UpdateCanvasSize()
                local layout = Page:FindFirstChildOfClass("UIListLayout")
                if layout then
                    task.wait(0.05)
                    local totalHeight = 0
                    for _, child in pairs(Page:GetChildren()) do
                        if child:IsA("TextButton") or child:IsA("Frame") then
                            totalHeight = totalHeight + child.AbsoluteSize.Y + 10
                        end
                    end
                    Page.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
                end
            end
    
            function Tab:CreateButton(text, callback)
                local Btn = Create("TextButton", {
                    Size = UDim2.new(0.95, 0, 0, 40),
                    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                    Text = text,
                    TextColor3 = Color3.fromRGB(230, 230, 230),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    Parent = Page
                }, {Create("UICorner", {CornerRadius = UDim.new(0, 8)})})
                ApplyPremiumBorder(Btn, 1)
                Btn.MouseButton1Click:Connect(function() 
                    if callback then callback() end 
                    Btn:TweenSize(UDim2.new(0.93, 0, 0, 38), "Out", "Quad", 0.1, true, function() 
                        Btn:TweenSize(UDim2.new(0.95, 0, 0, 40), "Out", "Quad", 0.1, true) 
                    end) 
                end)
                UpdateCanvasSize()
            end
    
            function Tab:CreateToggle(text, callback)
                local TglFrame = Create("Frame", {
                    Size = UDim2.new(0.95, 0, 0, 45),
                    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                    Parent = Page
                }, {Create("UICorner", {CornerRadius = UDim.new(0, 8)})})
                ApplyPremiumBorder(TglFrame, 1)
                
                Create("TextLabel", {
                    Text = text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(1, -70, 1, 0),
                    Parent = TglFrame
                })
                
                local TglBtn = Create("TextButton", {
                    Size = UDim2.fromOffset(44, 22),
                    Position = UDim2.new(1, -56, 0.5, -11),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Text = "",
                    Parent = TglFrame
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                local Circle = Create("Frame", {
                    Size = UDim2.fromOffset(18, 18),
                    Position = UDim2.fromOffset(2, 2),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = TglBtn
                }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                
                local toggled = false
                TglBtn.MouseButton1Click:Connect(function() 
                    toggled = not toggled
                    local targetPos = toggled and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2)
                    local targetColor = toggled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(40, 40, 40)
                    TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos}):Play()
                    TweenService:Create(TglBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                    if callback then callback(toggled) end 
                end)
                UpdateCanvasSize()
            end
    
            function Tab:CreateSlider(text, min, max, default, callback)
                local SliderFrame = Create("Frame", {
                    Size = UDim2.new(0.95, 0, 0, 70),
                    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                    Parent = Page
                }, {Create("UICorner", {CornerRadius = UDim.new(0, 8)})})
                ApplyPremiumBorder(SliderFrame, 1)
                
                Create("TextLabel", {
                    Text = text,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextXAlignment = "Left",
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(12, 8),
                    Size = UDim2.new(1, -20, 0, 20),
                    Parent = SliderFrame
                })
                
                local ValueLabel = Create("TextLabel", {
                    Text = tostring(default),
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(220, 220, 220),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 8),
                    Size = UDim2.new(0, 45, 0, 20),
                    Parent = SliderFrame
                })
                
                local SliderBar = Create("Frame", {
                    Size = UDim2.new(0.9, 0, 0, 4),
                    Position = UDim2.new(0.05, 0, 0.7, 0),
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
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
                UpdateCanvasSize()
            end
    
            return Tab
        end
    
        return Window
    end
end

return Library
