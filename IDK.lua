local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local C = {
    Background = Color3.fromRGB(8, 10, 20),
    Surface = Color3.fromRGB(14, 17, 32),
    SurfaceLight = Color3.fromRGB(22, 27, 50),
    Accent1 = Color3.fromRGB(120, 80, 255),
    Accent2 = Color3.fromRGB(80, 50, 200),
    Accent3 = Color3.fromRGB(0, 200, 255),
    TextPrimary = Color3.fromRGB(230, 235, 255),
    TextSecondary = Color3.fromRGB(160, 165, 200),
    TextMuted = Color3.fromRGB(90, 95, 130),
    Success = Color3.fromRGB(0, 220, 90),
    Warning = Color3.fromRGB(255, 190, 0),
    Danger = Color3.fromRGB(255, 60, 80),
}

local function New(cls, props, kids)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do o[k] = v end
    for _, c in ipairs(kids or {}) do c.Parent = o end
    return o
end

local function Drag(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local Library = {}
Library.Colors = C

local _nc = 0
function Library:Notify(title, msg, dur)
    dur = dur or 3
    _nc = _nc + 1
    local gui = New("ScreenGui", {
        Name = "DSN_".._nc,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    local card = New("Frame", {
        Size = UDim2.new(0, 285, 0, 68),
        Position = UDim2.new(1, 10, 1, -85),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = C.Surface,
        ZIndex = 200,
        Parent = gui
    }, {
        New("UICorner", {CornerRadius = UDim.new(0, 12)}),
        New("UIStroke", {Color = C.Accent1, Thickness = 1.5}),
        New("Frame", {Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = C.Accent1, ZIndex = 201}, {New("UICorner", {CornerRadius = UDim.new(0, 12)})}),
        New("TextLabel", {Text = "[ "..tostring(title).." ]", Size = UDim2.new(1, -14, 0, 22), Position = UDim2.new(0, 12, 0, 7), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.Accent1, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 201}),
        New("TextLabel", {Text = tostring(msg), Size = UDim2.new(1, -14, 0, 28), Position = UDim2.new(0, 12, 0, 30), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 201})
    })
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -295, 1, -85)}):Play()
    task.delay(dur, function()
        local t = TweenService:Create(card, TweenInfo.new(0.25), {Position = UDim2.new(1, 10, 1, -85)})
        t:Play()
        t.Completed:Connect(function() gui:Destroy() end)
    end)
end

function Library:Window(cfg)
    cfg = cfg or {}
    local TITLE = cfg.Title or "DeadShot Hub"
    local SUB = cfg.SubTitle or "Premium Edition"
    local VER = cfg.Version or "v18"
    local W, H = 680, 480
    local NAV_H = 54
    local TOP_H = 72

    local gui = New("ScreenGui", {
        Name = "DeadShotHub_UI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })

    local loadGui = New("ScreenGui", {
        Name = "DSHub_Load",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    local bg = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = C.Background,
        ZIndex = 500,
        Parent = loadGui
    })
    New("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, C.Background),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 8, 35))
        },
        Rotation = 135,
        Parent = bg
    })
    New("TextLabel", {
        Text = TITLE,
        Size = UDim2.new(0, 400, 0, 40),
        Position = UDim2.new(0.5, -200, 0.42, -20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 30,
        TextColor3 = C.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 502,
        Parent = bg
    })
    New("TextLabel", {
        Text = SUB.."  |  "..VER,
        Size = UDim2.new(0, 400, 0, 22),
        Position = UDim2.new(0.5, -200, 0.42, 26),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = C.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 502,
        Parent = bg
    })
    local barBg = New("Frame", {
        Size = UDim2.new(0, 320, 0, 5),
        Position = UDim2.new(0.5, -160, 0.42, 60),
        BackgroundColor3 = C.SurfaceLight,
        ZIndex = 502,
        Parent = bg
    }, {New("UICorner", {CornerRadius = UDim.new(0, 3)})})
    local barFill = New("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.Accent1,
        ZIndex = 503,
        Parent = barBg
    }, {
        New("UICorner", {CornerRadius = UDim.new(0, 3)}),
        New("UIGradient", {Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, C.Accent1),
            ColorSequenceKeypoint.new(1, C.Accent3)
        }})
    })
    TweenService:Create(barFill, TweenInfo.new(2.8, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.delay(3.2, function()
        local t = TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        t:Play()
        t.Completed:Connect(function() loadGui:Destroy() end)
    end)

    local panel = New("Frame", {
        Name = "MainPanel",
        Size = UDim2.new(0, W, 0, H),
        Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = C.Background,
        BackgroundTransparency = 0.05,
        ClipsDescendants = true,
        Visible = false,
        Parent = gui
    }, {
        New("UICorner", {CornerRadius = UDim.new(0, 20)}),
        New("UIStroke", {Color = C.Accent1, Thickness = 2, Transparency = 0.2})
    })
    Drag(panel, panel)

    for _ = 1, 12 do
        local orb = New("Frame", {
            Size = UDim2.new(0, math.random(20, 55), 0, math.random(20, 55)),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundColor3 = C.Accent1,
            BackgroundTransparency = 0.95,
            ZIndex = 0,
            Parent = panel
        }, {New("UICorner", {CornerRadius = UDim.new(1, 0)})})
        TweenService:Create(orb, TweenInfo.new(math.random(8, 15), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.new(math.random(), 0, math.random(), 0)}):Play()
    end

    local topBar = New("Frame", {
        Size = UDim2.new(1, 0, 0, TOP_H),
        BackgroundTransparency = 1,
        Parent = panel
    })

    local closeBtn = New("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -34, 0, 8),
        BackgroundColor3 = C.Danger,
        BackgroundTransparency = 0.4,
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false,
        Parent = panel
    }, {New("UICorner", {CornerRadius = UDim.new(0, 8)})})
    closeBtn.MouseButton1Click:Connect(function() panel.Visible = false end)

    local profileCard = New("Frame", {
        Size = UDim2.new(0, 210, 0, TOP_H-10),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundColor3 = C.Surface,
        Parent = topBar
    }, {
        New("UICorner", {CornerRadius = UDim.new(0, 12)}),
        New("UIStroke", {Color = C.Accent2, Thickness = 1.5}),
        New("ImageLabel", {
            Size = UDim2.new(0, 48, 0, 48),
            Position = UDim2.new(0, 8, 0.5, -24),
            BackgroundTransparency = 1,
            Image = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            end) and Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) or ""
        }, {New("UICorner", {CornerRadius = UDim.new(1, 0)})}),
        New("TextLabel", {
            Text = LocalPlayer.Name,
            Size = UDim2.new(1, -64, 0, 22),
            Position = UDim2.new(0, 64, 0, 10),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = C.TextPrimary,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        New("TextLabel", {
            Name = "Ping",
            Text = "? ms",
            Size = UDim2.new(1, -64, 0, 18),
            Position = UDim2.new(0, 64, 0, 34),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = C.Accent3,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    })

    local statCards = {}
    local statDefs = {
        {lbl = "FPS", icon = "⚡", color = C.Success, x = 228},
        {lbl = "PING", icon = "📡", color = C.Warning, x = 346},
        {lbl = "PLAYERS", icon = "👥", color = C.Accent3, x = 464},
    }
    for _, d in ipairs(statDefs) do
        local card = New("Frame", {
            Size = UDim2.new(0, 108, 0, TOP_H-10),
            Position = UDim2.new(0, d.x, 0, 5),
            BackgroundColor3 = C.Surface,
            Parent = topBar
        }, {
            New("UICorner", {CornerRadius = UDim.new(0, 12)}),
            New("UIStroke", {Color = d.color, Thickness = 1.5}),
            New("TextLabel", {Text = d.icon, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 5), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = d.color, TextXAlignment = Enum.TextXAlignment.Center}),
            New("TextLabel", {Text = d.lbl, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = C.TextMuted, TextXAlignment = Enum.TextXAlignment.Center}),
            New("TextLabel", {Name = "Value", Text = "–", Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 44), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = d.color, TextXAlignment = Enum.TextXAlignment.Center})
        })
        statCards[d.lbl] = card
    end

    New("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 0, TOP_H+1),
        BackgroundColor3 = C.Accent1,
        BackgroundTransparency = 0.7,
        Parent = panel
    })

    local navBar = New("Frame", {
        Size = UDim2.new(1, -20, 0, NAV_H),
        Position = UDim2.new(0, 10, 0, TOP_H+4),
        BackgroundTransparency = 1,
        Parent = panel
    }, {
        New("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
    })

    local pageContainer = New("Frame", {
        Size = UDim2.new(1, -20, 1, -(TOP_H+NAV_H+18)),
        Position = UDim2.new(0, 10, 0, TOP_H+NAV_H+10),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = panel
    })

    local toggleGui = New("ScreenGui", {
        Name = "DSHub_ToggleBtn",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    local toggleBtn = New("TextButton", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 8, 0.5, -22),
        BackgroundColor3 = C.Surface,
        Text = "⊛",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = C.Accent1,
        AutoButtonColor = false,
        Visible = false,
        Parent = toggleGui
    }, {
        New("UICorner", {CornerRadius = UDim.new(0, 14)}),
        New("UIStroke", {Color = C.Accent1, Thickness = 2})
    })
    TweenService:Create(toggleBtn, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextColor3 = C.Accent3}):Play()
    Drag(toggleBtn, toggleBtn)
    task.delay(3.4, function() toggleBtn.Visible = true end)
    toggleBtn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)

    local _fps, _timer = 0, 0
    RunService.Heartbeat:Connect(function(dt)
        _fps = _fps + 1
        _timer = _timer + dt
        if _timer < 1 then return end
        local fps = _fps
        _fps = 0
        _timer = 0
        local ms = 0
        pcall(function()
            ms = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        pcall(function() statCards["FPS"].Value.Text = tostring(fps) end)
        pcall(function() statCards["PING"].Value.Text = tostring(ms) end)
        pcall(function() statCards["PLAYERS"].Value.Text = tostring(#Players:GetPlayers()) end)
        pcall(function() profileCard.Ping.Text = tostring(ms).."ms" end)
    end)

    local _tabs = {}
    local _pages = {}
    local _current = nil

    local function switchPage(name)
        if _current == name then return end
        if _current and _pages[_current] then
            local old = _pages[_current]
            TweenService:Create(old, TweenInfo.new(0.15), {Position = UDim2.new(-1, 0, 0, 0)}):Play()
            task.delay(0.18, function()
                old.Visible = false
                old.Position = UDim2.new(0, 0, 0, 0)
            end)
        end
        local new = _pages[name]
        new.Visible = true
        new.Position = UDim2.new(1, 0, 0, 0)
        TweenService:Create(new, TweenInfo.new(0.18), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        _current = name
    end

    local Win = {}

    function Win:Tab(name, icon)
        local isFirst = #_tabs == 0
        local navBtn = New("TextButton", {
            Name = name,
            Text = (icon and icon ~= "" and icon.."\n" or "")..name,
            Size = UDim2.new(0, 78, 0, NAV_H-6),
            BackgroundColor3 = isFirst and C.Accent1 or C.Surface,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = isFirst and C.TextPrimary or C.TextSecondary,
            AutoButtonColor = false,
            Parent = navBar
        }, {
            New("UICorner", {CornerRadius = UDim.new(0, 12)}),
            New("UIStroke", {Name = "Glow", Color = C.Accent1, Transparency = isFirst and 0.3 or 1})
        })

        local page = New("ScrollingFrame", {
            Name = name.."Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = C.Accent1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = isFirst,
            Parent = pageContainer
        })
        local layout = New("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page
        })
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 6),
            Parent = page
        })
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)

        _pages[name] = page
        table.insert(_tabs, navBtn)
        if isFirst then _current = name end

        navBtn.MouseEnter:Connect(function()
            if _current ~= name then
                TweenService:Create(navBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.SurfaceLight}):Play()
            end
        end)
        navBtn.MouseLeave:Connect(function()
            if _current ~= name then
                TweenService:Create(navBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.Surface}):Play()
            end
        end)
        navBtn.MouseButton1Click:Connect(function()
            for _, b in ipairs(_tabs) do
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = C.Surface, TextColor3 = C.TextSecondary}):Play()
                local g = b:FindFirstChild("Glow")
                if g then TweenService:Create(g, TweenInfo.new(0.2), {Transparency = 1}):Play() end
            end
            TweenService:Create(navBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.Accent1, TextColor3 = C.TextPrimary}):Play()
            local g = navBtn:FindFirstChild("Glow")
            if g then TweenService:Create(g, TweenInfo.new(0.2), {Transparency = 0.3}):Play() end
            switchPage(name)
        end)

        local Tab = {Page = page}

        function Tab:Toggle(label, default, callback)
            default = default or false
            local cont = New("Frame", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = C.Surface,
                Parent = page
            }, {
                New("UICorner", {CornerRadius = UDim.new(0, 10)}),
                New("UIStroke", {Color = C.Accent2, Transparency = 0.5})
            })
            New("TextLabel", {
                Text = label,
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextColor3 = C.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = cont
            })
            local track = New("Frame", {
                Size = UDim2.new(0, 60, 0, 30),
                Position = UDim2.new(1, -70, 0.5, -15),
                BackgroundColor3 = default and C.Accent1 or C.SurfaceLight,
                Parent = cont
            }, {New("UICorner", {CornerRadius = UDim.new(0, 15)})})
            local knob = New("Frame", {
                Size = UDim2.new(0, 26, 0, 26),
                Position = UDim2.new(default and 1 or 0, default and -28 or 2, 0.5, -13),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Parent = track
            }, {
                New("UICorner", {CornerRadius = UDim.new(0, 13)}),
                New("UIStroke", {Color = C.Accent1, Thickness = 1})
            })
            local state = default
            local clickBtn = New("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = cont
            })
            clickBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = state and C.Accent1 or C.SurfaceLight}):Play()
                TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = UDim2.new(state and 1 or 0, state and -28 or 2, 0.5, -13)}):Play()
                if callback then pcall(callback, state) end
            end)
            return cont
        end

        function Tab:Slider(label, minV, maxV, default, suffix, callback)
            suffix = suffix or ""
            local cont = New("Frame", {
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = C.Surface,
                Parent = page
            }, {
                New("UICorner", {CornerRadius = UDim.new(0, 10)}),
                New("UIStroke", {Color = C.Accent2, Transparency = 0.5})
            })
            New("TextLabel", {
                Text = label,
                Size = UDim2.new(1, -80, 0, 20),
                Position = UDim2.new(0, 15, 0, 8),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextColor3 = C.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = cont
            })
            local valLbl = New("TextLabel", {
                Text = tostring(default)..suffix,
                Size = UDim2.new(0, 70, 0, 20),
                Position = UDim2.new(1, -80, 0, 8),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = C.Accent1,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = cont
            })
            local trackBg = New("Frame", {
                Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 0, 38),
                BackgroundColor3 = C.SurfaceLight,
                Parent = cont
            }, {New("UICorner", {CornerRadius = UDim.new(0, 3)})})
            local fill = New("Frame", {
                Size = UDim2.new((default - minV) / (maxV - minV), 0, 1, 0),
                BackgroundColor3 = C.Accent1,
                Parent = trackBg
            }, {
                New("UICorner", {CornerRadius = UDim.new(0, 3)}),
                New("UIGradient", {Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, C.Accent1),
                    ColorSequenceKeypoint.new(1, C.Accent3)
                }})
            })
            local sliding = false
            local function update(x)
                local abs = trackBg.AbsoluteSize.X
                if abs <= 0 then return end
                local rel = math.clamp((x - trackBg.AbsolutePosition.X) / abs, 0, 1)
                local val = math.floor(minV + (maxV - minV) * rel)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                valLbl.Text = tostring(val)..suffix
                if callback then pcall(callback, val) end
            end
            trackBg.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    update(i.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if not sliding then return end
                if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then update(i.Position.X) end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)
            return cont
        end

        function Tab:Button(label, ico, callback)
            local btn = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = C.Surface,
                Text = "",
                AutoButtonColor = false,
                Parent = page
            }, {
                New("UICorner", {CornerRadius = UDim.new(0, 10)}),
                New("UIStroke", {Color = C.Accent2, Transparency = 0.5})
            })
            if ico and ico ~= "" then
                New("TextLabel", {
                    Text = ico,
                    Size = UDim2.new(0, 40, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    TextSize = 20,
                    TextColor3 = C.Accent1,
                    Parent = btn
                })
            end
            New("TextLabel", {
                Text = label,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, (ico and ico ~= "") and 42 or 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextColor3 = C.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = btn
            })
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.SurfaceLight}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.Surface}):Play()
            end)
            btn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
            return btn
        end

        function Tab:Label(text)
            return New("TextLabel", {
                Text = text,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = C.TextMuted,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = page
            })
        end

        function Tab:Divider()
            return New("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = C.Accent1,
                BackgroundTransparency = 0.7,
                Parent = page
            })
        end

        function Tab:Section(text)
            local f = New("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = C.SurfaceLight,
                Parent = page
            }, {
                New("UICorner", {CornerRadius = UDim.new(0, 8)}),
                New("UIStroke", {Color = C.Accent1, Transparency = 0.6})
            })
            New("TextLabel", {
                Text = "  "..text,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = C.Accent1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = f
            })
            return f
        end

        return Tab
    end

    return Win
end

return Library
