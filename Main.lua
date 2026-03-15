-- Perbaiki: Definisi fungsi yang hilang
local checkcaller = checkcaller or function() return true end

-- Perbaiki: hookmetamethod fallback
local hookmetamethod = hookmetamethod or function(self, idx, func)
    local old = debug and debug.getmetatable and debug.getmetatable(self) and debug.getmetatable(self)[idx]
    if debug and debug.setmetatable then
        local mt = debug.getmetatable(self) or {}
        mt[idx] = function(...)
            if checkcaller() then
                return func(...)
            else
                return old and old(...)
            end
        end
        debug.setmetatable(self, mt)
    end
    return old
end

-- Perbaiki: firesignal fallback
local firesignal = firesignal or function(signal, ...)
    if signal and signal:IsA("RBXScriptSignal") then
        local args = {...}
        task.spawn(function()
            signal:Fire(unpack(args))
        end)
    end
end

-- Perbaiki: setfpscap fallback
local setfpscap = setfpscap or function(fps)
    if type(fps) == "number" then
        setfpscap = fps
        local RunService = game:GetService("RunService")
        local Stepped = RunService.Stepped:Connect(function()
            task.wait()
        end)
    end
end

--// Library Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/Vraigos/Fluent-Modded/releases/download/Test/main.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vraigos/Fluent-Modded/refs/heads/master/Addons/InterfaceManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vraigos/Fluent-Modded/refs/heads/master/Addons/SaveManager.lua"))()

-- Periksa Fluent
if not getgenv().Fluent then
    getgenv().Fluent = Fluent
end

if not workspace:FindFirstChild("SecurityPart") then
    local SecurityPart = Instance.new("Part")
    SecurityPart.Name = "SecurityPart"
    SecurityPart.Size = Vector3.new(10, 1, 10)
    SecurityPart.Position = Vector3.new(5000, 5000, 5000)
    SecurityPart.Anchored = true
    SecurityPart.CanCollide = true
    SecurityPart.Transparency = 1
    SecurityPart.CanTouch = false
    SecurityPart.Parent = workspace
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- Levenshtein distance for key system
local function levenshtein(a, b)
    a, b = a:lower(), b:lower()
    local m, n = #a, #b
    if m == 0 then return n end
    if n == 0 then return m end

    local matrix = {}
    for i = 0, m do matrix[i] = {[0] = i} end
    for j = 0, n do matrix[0][j] = j end

    for i = 1, m do
        for j = 1, n do
            local cost = (a:sub(i,i) == b:sub(j,j)) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1,
                matrix[i][j-1] + 1,
                matrix[i-1][j-1] + cost
            )
        end
    end

    return matrix[m][n]
end

--// Window Fluent
local Window = Fluent:CreateWindow({
    Title = "Veroki Hub",
    SubTitle = "by Baisoku/Syfta",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local FloatingButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/BaiSoku1/Veroki/refs/heads/main/Evade/flot",true))() FloatingButton.init(Window)

-- Get executor info
local executor = identifyexecutor()
if type(executor) == "table" then
    for key, value in pairs(executor) do
        print(key .. ": " .. tostring(value))
    end
elseif type(executor) == "string" then
    print("Executor: " .. executor)
end

--// Tabs Fluent
local MainTab = Window:AddTab({
    Title = "Main",
    Icon = "home"
})

local AutoFarmsTab = Window:AddTab({
    Title = "Auto Farms",
    Icon = "coins"
})

local CombatTab = Window:AddTab({
    Title = "Combat",
    Icon = "sword"
})

local MiscTab = Window:AddTab({
    Title = "Misc",
    Icon = "star"
})

local VisualTab = Window:AddTab({
    Title = "Visual",
    Icon = "diamond"
})

local InfoTab = Window:AddTab({
    Title = "Info",
    Icon = "info"
})

local ConfigTab = Window:AddTab({
    Title = "Configuration",
    Icon = "save"
})

local ExtensionTab = Window:AddTab({
    Title = "Extension",
    Icon = "puzzle"
})

-- Inisialisasi featureStates
if not getgenv().featureStates then
    getgenv().featureStates = {}
end

-- Set default values
getgenv().featureStates.AntiNextbot = false
getgenv().featureStates.AntiNextbotTeleportType = "Distance"
getgenv().featureStates.AntiNextbotDistance = 50
getgenv().featureStates.DistanceTeleport = 20
getgenv().featureStates.AntiNextbotSpawn = false
getgenv().featureStates.AntiNextbotSpawnType = "Spawn"
getgenv().featureStates.AntiNextbotSpawnDistance = 40
getgenv().featureStates.AntiNextbotTeleportDistance = 20

if not getgenv().espObjects then
    getgenv().espObjects = {}
end

if not getgenv().espThreads then
    getgenv().espThreads = {}
end

if not getgenv().tracerLines then
    getgenv().tracerLines = {}
end

-- InfoTab
getgenv().DiscordInfo = getgenv().DiscordInfo or {
    ServerLink = "https://discord.gg/kzy6cAUVJ",
    ServerID = 1450681153680969874,
    NotificationShown = false
}

InfoTab:AddParagraph({
    Title = "Veroki Hub Discord! :]",
    Content = "Join our Discord server for updates, support, and community!"
})

InfoTab:AddButton({
    Title = "Copy Discord Link",
    Description = "Click to copy Discord invite link",
    Callback = function()
        setclipboard(getgenv().DiscordInfo.ServerLink)
        Fluent:Notify({
            Title = "Discord",
            Content = "Discord link copied to clipboard!",
            Duration = 3
        })
        getgenv().DiscordInfo.NotificationShown = true
    end
})

InfoTab:AddButton({
    Title = "Join Server",
    Description = "Teleport to Discord server",
    Callback = function()
        pcall(function() 
            game:GetService("TeleportService"):Teleport(getgenv().DiscordInfo.ServerID, LocalPlayer) 
        end)
    end
})

InfoTab:AddParagraph({
    Title = "Credits",
    Content = "Script created by SYFTA\nUI Library: Fluent Modded\nSpecial thanks to all testers and supporters!"
})

-- ESP IN MAINTAB
local function createESP(part, name, baseColor)
    if getgenv().espObjects[part] then return getgenv().espObjects[part] end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = name .. "ESP"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 180, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 500
    billboard.Parent = PlayerGui
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.25
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.Text = ""
    label.TextColor3 = baseColor or Color3.fromRGB(255, 255, 255)
    label.Parent = billboard
    
    getgenv().espObjects[part] = {billboard = billboard, label = label, type = name}
    return getgenv().espObjects[part]
end

local function removeESP(part)
    if getgenv().espObjects[part] then
        getgenv().espObjects[part].billboard:Destroy()
        getgenv().espObjects[part] = nil
    end
end

local function cleanupESP()
    for part, data in pairs(getgenv().espObjects) do
        if data and data.billboard then
            data.billboard:Destroy()
        end
    end
    getgenv().espObjects = {}
    
    for name, thread in pairs(getgenv().espThreads) do
        if thread then
            coroutine.close(thread)
            getgenv().espThreads[name] = nil
        end
    end
end

MainTab:AddToggle("ESPPlayer", {
    Title = "ESP Player",
    Description = "Show player ESP",
    Default = false,
    Callback = function(state)
        getgenv().featureStates.EspPlayer = state
        
        if getgenv().espThreads["player"] then
            coroutine.close(getgenv().espThreads["player"])
            getgenv().espThreads["player"] = nil
        end
        
        for part, data in pairs(getgenv().espObjects) do
            if data and data.type == "Player" then
                removeESP(part)
            end
        end
        
        if not state then return end
        
        getgenv().espThreads["player"] = coroutine.create(function()
            local function getDistance(pos)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                return hrp and (pos - hrp.Position).Magnitude or 0
            end
            
            while getgenv().featureStates.EspPlayer do
                local folder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
                if folder then
                    for _, char in ipairs(folder:GetChildren()) do
                        if not char:IsA("Model") then continue end
                        if char:GetAttribute("Team") == "Nextbot" then continue end
                        if char.Name == LocalPlayer.Name then continue end
                        
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        
                        local espData = getgenv().espObjects[hrp]
                        if not espData then
                            espData = createESP(hrp, "Player", Color3.fromRGB(100, 180, 255))
                        end
                        
                        if not espData or not espData.billboard or not espData.billboard.Parent then
                            getgenv().espObjects[hrp] = nil
                            continue
                        end
                        
                        local dist = getDistance(hrp.Position)
                        local downed = char:GetAttribute("Downed")
                        local downedTime = tonumber(char:GetAttribute("DownedTimeLeft")) or 0
                        
                        local displayText, color
                        if downed == true then
                            color = Color3.fromRGB(255, 60, 60)
                            displayText = string.format('%s (Downed %.0f)', char.Name, downedTime)
                        elseif downed == false then
                            color = Color3.fromRGB(100, 255, 100)
                            displayText = string.format('%s\n%.0f studs', char.Name, dist)
                        else
                            color = Color3.fromRGB(100, 180, 255)
                            displayText = string.format('%s\n%.0f studs', char.Name, dist)
                        end
                        
                        espData.label.Text = displayText
                        espData.label.TextColor3 = color
                    end
                end
                task.wait(0.3)
            end
        end)
        
        coroutine.resume(getgenv().espThreads["player"])
    end
})

MainTab:AddToggle("ESPTicket", {
    Title = "ESP Ticket",
    Description = "Show ticket ESP",
    Default = false,
    Callback = function(state)
        getgenv().featureStates.EspTicket = state
        
        if getgenv().espThreads["ticket"] then
            coroutine.close(getgenv().espThreads["ticket"])
            getgenv().espThreads["ticket"] = nil
        end
        
        for part, data in pairs(getgenv().espObjects) do
            if data and data.type == "Ticket" then
                removeESP(part)
            end
        end
        
        if not state then return end
        
        getgenv().espThreads["ticket"] = coroutine.create(function()
            local function getDistance(pos)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                return hrp and (pos - hrp.Position).Magnitude or 0
            end
            
            while getgenv().featureStates.EspTicket do
                local ticketFolder = workspace:FindFirstChild("Game") and 
                                   workspace.Game:FindFirstChild("Effects") and 
                                   workspace.Game.Effects:FindFirstChild("Tickets")
                
                if ticketFolder then
                    for _, ticketModel in ipairs(ticketFolder:GetChildren()) do
                        if not ticketModel:IsA("Model") then continue end
                        
                        local part = ticketModel:FindFirstChildWhichIsA("BasePart")
                        if not part then continue end
                        
                        local espData = getgenv().espObjects[part]
                        if not espData then
                            espData = createESP(part, "Ticket", Color3.fromRGB(255, 255, 100))
                        end
                        
                        if not espData or not espData.billboard or not espData.billboard.Parent then
                            getgenv().espObjects[part] = nil
                            continue
                        end
                        
                        local dist = getDistance(part.Position)
                        espData.label.Text = string.format("%s\n%.0f studs", ticketModel.Name, dist)
                    end
                end
                task.wait(0.3)
            end
        end)
        
        coroutine.resume(getgenv().espThreads["ticket"])
    end
})

MainTab:AddToggle("ESPNextbot", {
    Title = "ESP Nextbot",
    Description = "Show nextbot ESP",
    Default = false,
    Callback = function(state)
        getgenv().featureStates.EspNextbot = state
        
        if getgenv().espThreads["nextbot"] then
            coroutine.close(getgenv().espThreads["nextbot"])
            getgenv().espThreads["nextbot"] = nil
        end
        
        for part, data in pairs(getgenv().espObjects) do
            if data and data.type == "Nextbot" then
                removeESP(part)
            end
        end
        
        if not state then return end
        
        getgenv().espThreads["nextbot"] = coroutine.create(function()
            local function getDistance(pos)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                return hrp and (pos - hrp.Position).Magnitude or 0
            end
            
            while getgenv().featureStates.EspNextbot do
                local folder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
                if folder then
                    for _, npc in ipairs(folder:GetChildren()) do
                        if not npc:IsA("Model") then continue end
                        if npc:GetAttribute("Team") ~= "Nextbot" then continue end
                        
                        local part = npc:FindFirstChild("Root") or 
                                    npc:FindFirstChild("Head") or 
                                    npc:FindFirstChild("HumanoidRootPart") or
                                    npc:FindFirstChildWhichIsA("BasePart")
                        if not part then continue end
                        
                        local espData = getgenv().espObjects[part]
                        if not espData then
                            espData = createESP(part, "Nextbot", Color3.fromRGB(200, 100, 255))
                        end
                        
                        if not espData or not espData.billboard or not espData.billboard.Parent then
                            getgenv().espObjects[part] = nil
                            continue
                        end
                        
                        local dist = getDistance(part.Position)
                        local color = Color3.fromRGB(200, 100, 255)
                        if dist <= 60 then
                            local t = math.max(0, math.min(1, (dist - 12) / 48))
                            color = Color3.new(
                                1,
                                0.235 + 0.765 * t,
                                0.235
                            )
                        end
                        
                        espData.label.Text = string.format("%s\n%.0f studs", npc.Name, dist)
                        espData.label.TextColor3 = color
                    end
                end
                task.wait(0.3)
            end
        end)
        
        coroutine.resume(getgenv().espThreads["nextbot"])
    end
})

getgenv().tracerThread = nil

local function cleanupTracers()
    for _, line in pairs(getgenv().tracerLines) do
        if line then
            pcall(function() line:Remove() end)
        end
    end
    getgenv().tracerLines = {}
end

MainTab:AddToggle("TracerDowned", {
    Title = "Tracer Downed Players",
    Description = "Show tracers to downed players",
    Default = false,
    Callback = function(state)
        getgenv().featureStates.TracerDowned = state
        
        if getgenv().tracerThread then
            coroutine.close(getgenv().tracerThread)
            getgenv().tracerThread = nil
        end
        
        cleanupTracers()
        
        if not state then return end
        
        getgenv().tracerThread = coroutine.create(function()
            while getgenv().featureStates.TracerDowned do
                cleanupTracers()
                
                local folder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
                if folder and camera then
                    for _, char in ipairs(folder:GetChildren()) do
                        if not char:IsA("Model") then continue end
                        if char:GetAttribute("Team") == "Nextbot" then continue end
                        if char.Name == LocalPlayer.Name then continue end
                        if char:GetAttribute("Downed") ~= true then continue end
                        
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if not hrp then continue end
                        
                        local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local tracer = Drawing.new("Line")
                            tracer.Color = Color3.fromRGB(255, 60, 60)
                            tracer.Thickness = 1.5
                            tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            tracer.To = Vector2.new(pos.X, pos.Y)
                            tracer.Visible = true
                            table.insert(getgenv().tracerLines, tracer)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
        
        coroutine.resume(getgenv().tracerThread)
    end
})

local LupenESPModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ksjsowos/29401/refs/heads/main/Test%20Script/LupenESP.lua"))()
LupenESPModule:Init(Fluent, Options)

MainTab:AddToggle("LupenESPToggle", {
    Title = "ESP Lupen",
    Default = false,
    Callback = function(state)
        if state then
            LupenESPModule:Start()
        else
            LupenESPModule:Stop()
        end
    end
})


MainTab:AddSection("Fly", "apple")

local character = nil
local humanoid = nil
local rootPart = nil

local flying = false
local bodyVelocity = nil
local bodyGyro = nil
local flySpeed = 50
local flyConnection = nil

-- Untuk mobile controls (menggunakan kontrol default Roblox)
local mobileMoveDirection = Vector3.new(0, 0, 0)

local function updateCharacter()
    character = LocalPlayer.Character
    if character then
        humanoid = character:FindFirstChild("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
    else
        humanoid = nil
        rootPart = nil
    end
end

updateCharacter()
LocalPlayer.CharacterAdded:Connect(updateCharacter)
LocalPlayer.CharacterRemoving:Connect(function()
    character = nil
    humanoid = nil
    rootPart = nil
end)

local function startFlying()
    updateCharacter()
    if not character or not humanoid or not rootPart then return end
    
    flying = true
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart

    humanoid.PlatformStand = true
    flyConnection = RunService.Heartbeat:Connect(updateFly)
end

local function stopFlying()
    flying = false
    
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
end

local function updateFly()
    if not flying or not bodyVelocity or not bodyGyro or not humanoid or not rootPart then 
        return 
    end
    
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    local direction = Vector3.new(0, 0, 0)
    
    -- Dapatkan move direction dari humanoid (ini akan bekerja untuk PC dan Mobile)
    -- Mobile: joystick virtual akan mengisi MoveDirection secara otomatis
    -- PC: tombol WASD akan mengisi MoveDirection
    local moveDirection = humanoid.MoveDirection

    if moveDirection.Magnitude > 0 then
        -- Konversi move direction relatif terhadap kamera
        local forwardVector = cameraCFrame.LookVector
        local rightVector = cameraCFrame.RightVector
        
        -- Proyeksikan move direction ke arah kamera
        local forwardComponent = moveDirection:Dot(forwardVector) * forwardVector
        local rightComponent = moveDirection:Dot(rightVector) * rightVector
        
        -- Gabungkan komponen dan normalisasi
        direction = direction + (forwardComponent + rightComponent).Unit * moveDirection.Magnitude
    end

    -- Kontrol vertikal (space untuk naik, shift untuk turun)
    -- Ini juga akan bekerja di mobile jika ada tombol yang dipetakan
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        direction = direction + Vector3.new(0, 1, 0)
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction - Vector3.new(0, 1, 0)
    end

    -- Terapkan velocity
    bodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * flySpeed or Vector3.new(0, 0, 0)
    bodyGyro.CFrame = cameraCFrame
end

-- MainTab
MainTab:AddToggle("FlyToggle", {
    Title = "Fly",
    Description = "Enable fly mode (Use WASD/Joystik to move, Space=Up, Shift=Down)",
    Default = false,
    Callback = function(state)
        if state then
            startFlying()
        else
            stopFlying()
        end
    end
})

MainTab:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Adjust fly speed",
    Default = 70,
    Min = 1,
    Max = 9999,
    Rounding = 0,
    Callback = function(value)
        flySpeed = value
    end
})

-- Variabel global untuk AntiNextbot
local player = LocalPlayer
local nextbotSpawnConnection = nil
local cachedAttachment = nil
local lastAttachmentCheck = 0
local attachmentCheckCooldown = 5
local isSearchingForAttachment = false
local farmsSuppressedByAntiNextbot = false
local previousMoneyFarm, previousTicketFarm, previousAutoWin
local antiNextbotConnection = nil
local lastAvoidanceTime = 0
local avoidanceCooldown = 2

-- Koleksi nama nextbot
local nextBotNames = {}
if ReplicatedStorage:FindFirstChild("NPCs") then
    for _, npc in ipairs(ReplicatedStorage.NPCs:GetChildren()) do
        table.insert(nextBotNames, npc.Name)
    end
end

-- Fungsi utilitas
function isNextbotModel(model)
    if not model or not model.Name then return false end
    for _, name in ipairs(nextBotNames) do
        if model.Name == name then return true end
    end
    return false
end

function getDistanceFromPlayer(targetPosition)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return 0
    end
    return (targetPosition - player.Character.HumanoidRootPart.Position).Magnitude
end

function fastDistanceSquared(pos1, pos2)
    local dx = pos1.X - pos2.X
    local dy = pos1.Y - pos2.Y
    local dz = pos1.Z - pos2.Z
    return dx*dx + dy*dy + dz*dz
end

function getAttachment()
    if tick() - lastAttachmentCheck > attachmentCheckCooldown then
        cachedAttachment = workspace.Terrain:FindFirstChild("NextbotSpawnAttachment")
        lastAttachmentCheck = tick()
    end
    return cachedAttachment
end

function findSafeTeleportPositionReverse(startPos, targetPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character}
    
    local direction = (targetPos - startPos).Unit
    local maxDistance = (targetPos - startPos).Magnitude
    
    for distance = maxDistance, 0, -5 do
        local testPos = startPos + (direction * distance)
        local downRay = workspace:Raycast(testPos + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), raycastParams)
        
        if downRay then
            local groundPos = downRay.Position + Vector3.new(0, 3, 0)
            local upRay = workspace:Raycast(groundPos, Vector3.new(0, 6, 0), raycastParams)
            
            if not upRay then
                local sideRays = {
                    Vector3.new(3, 0, 0),
                    Vector3.new(-3, 0, 0),
                    Vector3.new(0, 0, 3),
                    Vector3.new(0, 0, -3)
                }
                
                local isSafe = true
                for _, sideDir in ipairs(sideRays) do
                    local sideRay = workspace:Raycast(groundPos, sideDir, raycastParams)
                    if sideRay and sideRay.Instance.CanCollide then
                        isSafe = false
                        break
                    end
                end
                
                if isSafe then
                    return groundPos
                end
            end
        end
    end
    return nil
end

-- Fungsi teleportasi
function teleportToSpawn()
    local spawnsFolder = workspace:FindFirstChild("Game") and 
                         workspace.Game:FindFirstChild("Map") and 
                         workspace.Game.Map:FindFirstChild("Parts") and 
                         workspace.Game.Map.Parts:FindFirstChild("Spawns")
    
    if spawnsFolder then
        local spawnLocations = spawnsFolder:GetChildren()
        if #spawnLocations > 0 then
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart then
                for i = 1, math.min(3, #spawnLocations) do
                    local randomSpawn = spawnLocations[math.random(1, #spawnLocations)]
                    local targetPosition = randomSpawn.CFrame.Position + Vector3.new(0, 3, 0)
                    local safePosition = findSafeTeleportPositionReverse(humanoidRootPart.Position, targetPosition)
                    
                    if safePosition then
                        humanoidRootPart.CFrame = CFrame.new(safePosition)
                        return true
                    end
                end
            end
        end
    end
    return false
end

function teleportToPlayer()
    local players = Players:GetPlayers()
    local validPlayers = {}
    
    for _, plr in ipairs(players) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(validPlayers, plr)
        end
    end
    
    if #validPlayers > 0 then
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoidRootPart then
            for i = 1, math.min(3, #validPlayers) do
                local randomPlayer = validPlayers[math.random(1, #validPlayers)]
                local targetPosition = randomPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)
                local safePosition = findSafeTeleportPositionReverse(humanoidRootPart.Position, targetPosition)
                
                if safePosition then
                    humanoidRootPart.CFrame = CFrame.new(safePosition)
                    return true
                end
            end
        end
    end
    return false
end

function teleportToDistance()
    local attachment = getAttachment()
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then return false end
    
    if attachment then
        local direction = (humanoidRootPart.Position - attachment.WorldPosition).Unit
        local targetPos = humanoidRootPart.Position + direction * getgenv().featureStates.AntiNextbotTeleportDistance
        local safePosition = findSafeTeleportPositionReverse(humanoidRootPart.Position, targetPos)
        
        if safePosition then
            humanoidRootPart.CFrame = CFrame.new(safePosition)
            return true
        else
            return teleportToSpawn()
        end
    else
        return teleportToSpawn()
    end
end

function isPlayerNearSpawn()
    local attachment = getAttachment()
    if not attachment or not player.Character then return false end
    
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    local distanceSquared = fastDistanceSquared(humanoidRootPart.Position, attachment.WorldPosition)
    local triggerDistanceSquared = getgenv().featureStates.AntiNextbotSpawnDistance * getgenv().featureStates.AntiNextbotSpawnDistance
    
    return distanceSquared <= triggerDistanceSquared
end

function performAvoidance()
    if not player.Character then return end
    
    local success = false
    
    if getgenv().featureStates.AntiNextbotSpawnType == "Spawn" then
        success = teleportToSpawn()
    elseif getgenv().featureStates.AntiNextbotSpawnType == "Player" then
        success = teleportToPlayer()
    else
        success = teleportToDistance()
    end
    
    if not success then
        if Fluent and Fluent.Notify then
            Fluent:Notify({
                Title = "Anti Nextbot Spawn",
                Content = "No safe teleport location found!",
                Duration = 2
            })
        end
    end
end

function startAttachmentSearch()
    if isSearchingForAttachment then return end
    
    isSearchingForAttachment = true
    
    task.spawn(function()
        while getgenv().featureStates.AntiNextbotSpawn and not getAttachment() do
            task.wait(3)
            
            local statsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Stats")
            if statsFolder then
                local timerValue = statsFolder:GetAttribute("Timer")
                if timerValue == 0 then
                    cachedAttachment = workspace.Terrain:FindFirstChild("NextbotSpawnAttachment")
                    lastAttachmentCheck = tick()
                    
                    if cachedAttachment then
                        if Fluent and Fluent.Notify then
                            Fluent:Notify({
                                Title = "Anti Nextbot Spawn",
                                Content = "Attachment found! System now active.",
                                Duration = 3
                            })
                        end
                        break
                    end
                end
            end
        end
        isSearchingForAttachment = false
    end)
end

function startAntiNextbotSpawn()
    if nextbotSpawnConnection then
        nextbotSpawnConnection:Disconnect()
    end
    
    nextbotSpawnConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().featureStates.AntiNextbotSpawn or not player.Character then return end
        if tick() - lastAvoidanceTime < avoidanceCooldown then return end
        
        local attachment = getAttachment()
        if not attachment then return end
        
        if isPlayerNearSpawn() then
            performAvoidance()
            lastAvoidanceTime = tick()
        end
    end)
end

-- Fungsi dummy untuk Auto Money Farm dan Auto Win
local function stopAutoMoneyFarm() end
local function stopAutoWin() end
local function startAutoMoneyFarm() end
local function startAutoWin() end

function handleAntiNextbot()
    if not getgenv().featureStates.AntiNextbot then return end
    
    local character = Players.LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local nextbots = {}
    local npcsFolder = workspace:FindFirstChild("NPCs")
    
    if npcsFolder then
        for _, model in ipairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then table.insert(nextbots, model) end
            end
        end
    end
    
    local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        for _, model in ipairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then table.insert(nextbots, model) end
            end
        end
    end
    
    for _, nextbot in ipairs(nextbots) do
        local nextbotHrp = nextbot:FindFirstChild("HumanoidRootPart")
        if nextbotHrp then
            local distance = (humanoidRootPart.Position - nextbotHrp.Position).Magnitude
            
            if distance <= getgenv().featureStates.AntiNextbotDistance then
                if getgenv().featureStates.AntiNextbotTeleportType == "Players" then
                    local validPlayers = {}
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            table.insert(validPlayers, plr)
                        end
                    end
                    
                    if #validPlayers > 0 then
                        local randomPlayer = validPlayers[math.random(1, #validPlayers)]
                        humanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                    
                elseif getgenv().featureStates.AntiNextbotTeleportType == "Spawn" then
                    local spawnsFolder = workspace:FindFirstChild("Game") and 
                                         workspace.Game:FindFirstChild("Map") and 
                                         workspace.Game.Map:FindFirstChild("Parts") and 
                                         workspace.Game.Map.Parts:FindFirstChild("Spawns")
                    
                    if spawnsFolder then
                        local spawnLocations = spawnsFolder:GetChildren()
                        if #spawnLocations > 0 then
                            local randomSpawn = spawnLocations[math.random(1, #spawnLocations)]
                            humanoidRootPart.CFrame = randomSpawn.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                    
                elseif getgenv().featureStates.AntiNextbotTeleportType == "Distance" then
                    local direction = (humanoidRootPart.Position - nextbotHrp.Position).Unit
                    local targetPos = humanoidRootPart.Position + direction * getgenv().featureStates.DistanceTeleport
                    humanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                end
                break
            end
        end
    end
end

function startAntiNextbot()
    if antiNextbotConnection then
        antiNextbotConnection:Disconnect()
    end
    
    antiNextbotConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().featureStates.AntiNextbot then return end
        
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local nearestDistance = math.huge
        local nearestNextbot = nil
        
        local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        local npcsFolder = workspace:FindFirstChild("NPCs")
        
        if playersFolder then
            for _, model in pairs(playersFolder:GetChildren()) do
                if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and isNextbotModel(model) then
                    local dist = (model.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    if dist < nearestDistance then
                        nearestDistance = dist
                        nearestNextbot = model
                    end
                end
            end
        end
        
        if npcsFolder then
            for _, model in pairs(npcsFolder:GetChildren()) do
                if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and isNextbotModel(model) then
                    local dist = (model.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    if dist < nearestDistance then
                        nearestDistance = dist
                        nearestNextbot = model
                    end
                end
            end
        end
        
        local threshold = getgenv().featureStates.AntiNextbotDistance
        local isTooClose = (nearestDistance < threshold)
        
        -- Manajemen farm suppression
        if isTooClose and not farmsSuppressedByAntiNextbot then
            previousMoneyFarm = getgenv().moneyfarm
            previousTicketFarm = getgenv().ticketfarm
            previousAutoWin = getgenv().autowin
            
            getgenv().moneyfarm = false
            getgenv().ticketfarm = false
            getgenv().autowin = false
            
            if stopAutoMoneyFarm then stopAutoMoneyFarm() end
            if stopAutoWin then stopAutoWin() end
            
            farmsSuppressedByAntiNextbot = true
            
        elseif not isTooClose and farmsSuppressedByAntiNextbot then
            getgenv().moneyfarm = previousMoneyFarm
            getgenv().ticketfarm = previousTicketFarm
            getgenv().autowin = previousAutoWin
            
            if previousMoneyFarm then
                if startAutoMoneyFarm then startAutoMoneyFarm() end
            end
            
            farmsSuppressedByAntiNextbot = false
        end
        
        -- Teleportasi ke safe zone jika terlalu dekat
        if isTooClose then
            local safePart = workspace:FindFirstChild("SecurityPart")
            if safePart then
                humanoidRootPart.CFrame = safePart.CFrame + Vector3.new(math.random(-5, 5), 3, math.random(-5, 5))
            end
        end
    end)
end

function stopAntiNextbot()
    if antiNextbotConnection then
        antiNextbotConnection:Disconnect()
        antiNextbotConnection = nil
    end
    
    -- Pulihkan farm settings
    if farmsSuppressedByAntiNextbot then
        getgenv().moneyfarm = previousMoneyFarm
        getgenv().ticketfarm = previousTicketFarm
        getgenv().autowin = previousAutoWin
        
        if previousMoneyFarm then
            if startAutoMoneyFarm then startAutoMoneyFarm() end
        end
        
        farmsSuppressedByAntiNextbot = false
    end
end

function restartSystemOnEvents()
    player.CharacterAdded:Connect(function()
        if getgenv().featureStates.AntiNextbotSpawn then
            task.wait(1)
            if not nextbotSpawnConnection then
                startAntiNextbotSpawn()
            end
        end
    end)
    
    local statsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Stats")
    if statsFolder then
        statsFolder:GetAttributeChangedSignal("Timer"):Connect(function()
            if getgenv().featureStates.AntiNextbotSpawn then
                local timerValue = statsFolder:GetAttribute("Timer")
                if timerValue == 0 then
                    cachedAttachment = workspace.Terrain:FindFirstChild("NextbotSpawnAttachment")
                    lastAttachmentCheck = tick()
                    if not nextbotSpawnConnection then
                        task.wait(1)
                        startAntiNextbotSpawn()
                    end
                end
            end
        end)
    end
end

-- Loop utama untuk AntiNextbot
task.spawn(function()
    while true do
        if getgenv().featureStates.AntiNextbot then
            pcall(handleAntiNextbot)
        end
        task.wait(0.1)
    end
end)

-- Loop untuk pengecekan attachment
task.spawn(function()
    while true do
        task.wait(attachmentCheckCooldown)
        if getgenv().featureStates.AntiNextbotSpawn then
            local currentAttachment = workspace.Terrain:FindFirstChild("NextbotSpawnAttachment")
            
            if currentAttachment and not cachedAttachment then
                cachedAttachment = currentAttachment
                if Fluent and Fluent.Notify then
                    Fluent:Notify({
                        Title = "Anti Nextbot Spawn",
                        Content = "Attachment found! System now active.",
                        Duration = 3
                    })
                end
            elseif not currentAttachment and cachedAttachment then
                cachedAttachment = nil
                if Fluent and Fluent.Notify then
                    Fluent:Notify({
                        Title = "Anti Nextbot Spawn",
                        Content = "Attachment lost - System will reactivate when found.",
                        Duration = 3
                    })
                end
            else
                cachedAttachment = currentAttachment
            end
        end
    end
end)

-- Notifikasi sistem loaded
if Fluent and Fluent.Notify then
    Fluent:Notify({
        Title = "Anti Nextbot System",
        Content = "System loaded successfully!",
        Duration = 2
    })
end

-- Inisialisasi sistem
restartSystemOnEvents()

-- UI Elements Anti-Nextbot di CombatTab
CombatTab:AddToggle("AntiNextbot", {
    Title = "Anti-Nextbot",
    Description = "Automatically teleport away from nearby Nextbots (farms pause if too close)",
    Default = getgenv().featureStates.AntiNextbot,
    Callback = function(state)
        getgenv().featureStates.AntiNextbot = state
        if state then
            startAntiNextbot()
        else
            stopAntiNextbot()
        end
    end
})

CombatTab:AddDropdown("AntiNextbotTeleportType", {
    Title = "Anti-Nextbot Teleport Type",
    Description = "Choose how to teleport when avoiding Nextbots",
    Values = {"Players", "Spawn", "Distance"},
    Default = getgenv().featureStates.AntiNextbotTeleportType,
    Callback = function(value)
        getgenv().featureStates.AntiNextbotTeleportType = value
    end
})

CombatTab:AddInput("AntiNextbotDistance", {
    Title = "Anti-Nextbot Distance",
    Description = "Distance threshold for Nextbot detection",
    Default = tostring(getgenv().featureStates.AntiNextbotDistance),
    Placeholder = tostring(getgenv().featureStates.AntiNextbotDistance),
    Numeric = true,
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            getgenv().featureStates.AntiNextbotDistance = num
        end
    end
})

CombatTab:AddInput("DistanceTeleport", {
    Title = "Distance Teleport",
    Description = "How far to teleport when using Distance mode",
    Default = tostring(getgenv().featureStates.DistanceTeleport),
    Placeholder = tostring(getgenv().featureStates.DistanceTeleport),
    Numeric = true,
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            getgenv().featureStates.DistanceTeleport = num
        end
    end
})

CombatTab:AddToggle("AntiNextbotSpawn", {
    Title = "Anti Nextbot Spawn",
    Description = "Automatically avoid Nextbot spawn areas",
    Default = false,
    Callback = function(state)
        getgenv().featureStates.AntiNextbotSpawn = state
        
        if state then
            startAntiNextbotSpawn()
            startAttachmentSearch()
            
            if not getAttachment() then
                if Fluent and Fluent.Notify then
                    Fluent:Notify({
                        Title = "Anti Nextbot Spawn",
                        Content = "System enabled - Searching for attachment...",
                        Duration = 3
                    })
                end
            else
                if Fluent and Fluent.Notify then
                    Fluent:Notify({
                        Title = "Anti Nextbot Spawn",
                        Content = "System enabled - Attachment found!",
                        Duration = 3
                    })
                end
            end
        else
            if nextbotSpawnConnection then
                nextbotSpawnConnection:Disconnect()
                nextbotSpawnConnection = nil
            end
            isSearchingForAttachment = false
        end
    end
})

CombatTab:AddDropdown("AvoidanceMode", {
    Title = "Avoidance Mode",
    Description = "Choose how to avoid Nextbot spawn",
    Values = {"Spawn", "Player", "Distance"},
    Default = "Spawn",
    Callback = function(value)
        getgenv().featureStates.AntiNextbotSpawnType = value
    end
})

CombatTab:AddInput("AvoidanceDistance", {
    Title = "Avoidance Distance",
    Description = "Distance to trigger avoidance (studs)",
    Default = tostring(getgenv().featureStates.AntiNextbotSpawnDistance),
    Placeholder = "40",
    Numeric = true,
    Callback = function(value)
        local distance = tonumber(value)
        if distance and distance > 0 then
            getgenv().featureStates.AntiNextbotSpawnDistance = distance
        end
    end
})

CombatTab:AddInput("TeleportDistance", {
    Title = "Teleport Distance",
    Description = "How far to teleport in Distance mode (studs)",
    Default = tostring(getgenv().featureStates.AntiNextbotTeleportDistance),
    Placeholder = "20",
    Numeric = true,
    Callback = function(value)
        local distance = tonumber(value)
        if distance and distance > 0 then
            getgenv().featureStates.AntiNextbotTeleportDistance = distance
        end
    end
})

-- Player Movement Settings di MainTab


-- Redeem All Code di MiscTab
MiscTab:AddButton({
    Title = "Redeem All Code",
    Description = "Redeem All code That are listed in Wikipedia",
    Callback = function()
        if getgenv().EvadeCode then
            game:GetService("Players").LocalPlayer.PlayerGui.Global.Messages.Use:Fire("You already used this", "Error")
            return
        end
        getgenv().EvadeCode = true
        
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local RemoteEvent = ReplicatedStorage.Events.Data.UseCode
        local MessageEvent = LocalPlayer.PlayerGui.Global.Messages.Use
        
        local URL = "https://wiki-wacker.vercel.app/api/raw?url=https%3A%2F%2Fevade-nextbot.fandom.com%2Fwiki%2FCodes"
        
        function getContent(url)
            local success, content = pcall(function()
                return game:HttpGet(url, true)
            end)
            if success then
                return content
            else
                return nil
            end
        end
        
        function extractTRData(htmlContent)
            if not htmlContent then return {} end
            
            local tableRows = {}
            local trPattern = "<tr>(.-)</tr>"
            
            for trContent in htmlContent:gmatch(trPattern) do
                local rowData = {}
                
                local codePattern = "<td[^>]*>%s*<code[^>]*>(.-)</code>"
                local code = trContent:match(codePattern)
                
                if code then
                    code = code:gsub("&lt;", "<")
                    code = code:gsub("&gt;", ">")
                    code = code:gsub("&amp;", "&")
                    code = code:gsub("&quot;", '"')
                    code = code:match("^%s*(.-)%s*$") or code
                    rowData.code = code
                end
                
                local tdPattern = "<td[^>]*>(.-)</td>"
                local tdCount = 0
                local tds = {}
                
                for tdContent in trContent:gmatch(tdPattern) do
                    tdCount = tdCount + 1
                    local cleanContent = tdContent
                        :gsub("<[^>]+>", "")
                        :gsub("&lt;", "<")
                        :gsub("&gt;", ">")
                        :gsub("&amp;", "&")
                        :gsub("&quot;", '"')
                        :gsub("%s+", " ")
                        :match("^%s*(.-)%s*$") or tdContent
                    table.insert(tds, cleanContent)
                end
                
                if tdCount >= 2 and not rowData.code then
                    rowData.code = tds[1]
                    rowData.description = tdCount >= 2 and tds[2] or ""
                    rowData.status = tdCount >= 3 and tds[3] or ""
                    rowData.date = tdCount >= 4 and tds[4] or ""
                elseif rowData.code then
                    rowData.description = tdCount >= 2 and tds[1] or ""
                    rowData.status = tdCount >= 3 and tds[2] or ""
                    rowData.date = tdCount >= 4 and tds[3] or ""
                end
                
                local statusPattern = "<b[^>]*>%s*<span[^>]*>([^<]+)</span>%s*</b>"
                local statusValue = trContent:match(statusPattern)
                
                if statusValue then
                    statusValue = statusValue:lower():gsub("%s+", "")
                    if statusValue == "true" or statusValue == "false" then
                        rowData.spanStatus = statusValue
                    end
                end
                
                if not rowData.spanStatus then
                    local truePos = trContent:lower():find("true")
                    local falsePos = trContent:lower():find("false")
                    if truePos then
                        rowData.spanStatus = "true"
                    elseif falsePos then
                        rowData.spanStatus = "false"
                    end
                end
                
                if rowData.code and #rowData.code > 0 then
                    table.insert(tableRows, rowData)
                end
            end
            
            return tableRows
        end
        
        function useCodeWithFeedback(code)
            local success, response = pcall(function()
                return RemoteEvent:InvokeServer(code)
            end)
            
            if not success then
                MessageEvent:Fire("Failed to fetch our Wikipedia content, please try again later", "Error")
                return
            end
            
            if response == nil then
                MessageEvent:Fire("Redeemed!", "Success")
            elseif type(response) == "boolean" then
                if response then
                    MessageEvent:Fire("Accepted!", "Success")
                else
                    MessageEvent:Fire("Invalid", "Error")
                end
            elseif type(response) == "string" then
                local lower = response:lower()
                if lower:find("success") or lower:find("accepted") or lower:find("redeemed") or lower:find("reward") then
                    MessageEvent:Fire(response, "Success")
                elseif lower:find("invalid") or lower:find("error") or lower:find("failed") or lower:find("already") then
                    MessageEvent:Fire(response, "Error")
                else
                    MessageEvent:Fire(response, "Success")
                end
            elseif type(response) == "table" then
                if response.success == true then
                    MessageEvent:Fire(response.message or "Success", "Success")
                elseif response.success == false then
                    MessageEvent:Fire(response.message or "Failed", "Error")
                elseif response.error then
                    MessageEvent:Fire(response.error, "Error")
                elseif response.message then
                    MessageEvent:Fire(response.message, "Info")
                else
                    MessageEvent:Fire("Processed", "Info")
                end
            else
                MessageEvent:Fire("Response: " .. tostring(response), "Info")
            end
        end
        
        function main()
            MessageEvent:Fire("Starting code extraction...", "Info")
            
            local htmlContent = getContent(URL)
            if not htmlContent then
                MessageEvent:Fire("Failed to fetch our Wikipedia content", "Error")
                return
            end
            
            local tableRows = extractTRData(htmlContent)
            if #tableRows == 0 then
                MessageEvent:Fire("No table rows found", "Error")
                return
            end
            
            MessageEvent:Fire("Found " .. #tableRows .. " table rows", "Info")
            
            local trueCodes = {}
            local falseCodes = {}
            local unknownCodes = {}
            
            for i, row in ipairs(tableRows) do
                local status = row.spanStatus or "unknown"
                if status == "true" then
                    table.insert(trueCodes, row.code)
                elseif status == "false" then
                    table.insert(falseCodes, row.code)
                else
                    table.insert(unknownCodes, row.code)
                end
            end
            
            MessageEvent:Fire("True codes: " .. #trueCodes, "Success")
            MessageEvent:Fire("False codes: " .. #falseCodes, "Error")
            MessageEvent:Fire("Unknown codes: " .. #unknownCodes, "Info")
            MessageEvent:Fire("Code Will be redeem in 5 Second", "Message")
            
            task.wait(5)
            
            local validCodes = {}
            for _, code in ipairs(trueCodes) do
                table.insert(validCodes, code)
            end
            for _, code in ipairs(unknownCodes) do
                table.insert(validCodes, code)
            end
            
            if #validCodes == 0 then
                MessageEvent:Fire("No valid codes to try", "Error")
                return
            end
            
            for i, code in ipairs(validCodes) do
                MessageEvent:Fire("Processing [" .. i .. "/" .. #validCodes .. "]: " .. code, "Info")
                useCodeWithFeedback(code)
            end
        end
        
        main()
    end
})

local requiredFields = {
    Friction = true,
    AirStrafeAcceleration = true,
    JumpHeight = true,
    RunDeaccel = true,
    JumpSpeedMultiplier = true,
    JumpCap = true,
    SprintCap = true,
    WalkSpeedMultiplier = true,
    BhopEnabled = true,
    Speed = true,
    AirAcceleration = true,
    RunAccel = true,
    SprintAcceleration = true,
}

getgenv().ApplyMode = "Unoptimized"
local appliedOnce = false
local gameStatsPath = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Stats")
local playersPath = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
local playerModelPresent = false

local currentSettings = {
    Speed = "1500",
    JumpCap = "1",
    AirStrafeAcceleration = "187"
}

local function isPlayerModelPresent()
    local player = game.Players.LocalPlayer
    if not player then return false end
    if not playersPath then return false end
    
    for _, model in pairs(playersPath:GetChildren()) do
        if model.Name == player.Name then
            return true
        end
    end
    return false
end

local function shouldApplySettings()
    if not gameStatsPath then return false end
    
    local roundStarted = gameStatsPath:GetAttribute("RoundStarted")
    local timer = gameStatsPath:GetAttribute("Timer")
    
    return roundStarted == false and timer == 3
end

local function getMatchingTables()
    local matched = {}
    for _, obj in pairs(getgc(true)) do
        if typeof(obj) == "table" then
            local ok = true
            for field in pairs(requiredFields) do
                if rawget(obj, field) == nil then
                    ok = false
                    break
                end
            end
            if ok then
                table.insert(matched, obj)
            end
        end
    end
    return matched
end

local function applyToTables(callback)
    if not isPlayerModelPresent() then
        return
    end
    
    local targets = getMatchingTables()
    
    if #targets == 0 then
        return
    end
    
    if getgenv().ApplyMode == "Optimized" then
        task.spawn(function()
            for i, tableObj in ipairs(targets) do
                if tableObj and typeof(tableObj) == "table" then
                    pcall(callback, tableObj)
                end
                
                if i % 3 == 0 then
                    task.wait()
                end
            end
        end)
    else
        for i, tableObj in ipairs(targets) do
            if tableObj and typeof(tableObj) == "table" then
                pcall(callback, tableObj)
            end
        end
    end
end

MiscTab:AddInput("Speed", {
    Title = "Speed",
    Description = "Set movement speed",
    Default = "1500",
    Placeholder = "1500",
    Numeric = true,
    Callback = function(input)
        local val = tonumber(input)
        if not val then return end
        if val < 1450 then return end
        currentSettings.Speed = input
        
        applyToTables(function(obj)
            obj.Speed = val
        end)
    end
})

MiscTab:AddInput("JumpCap", {
    Title = "Jump Cap",
    Description = "Set jump cap value",
    Default = "1",
    Placeholder = "1",
    Numeric = true,
    Callback = function(input)
        local val = tonumber(input)
        if not val then return end
        if val < 0.1 then return end
        currentSettings.JumpCap = input
        
        applyToTables(function(obj)
            obj.JumpCap = val
        end)
    end
})

MiscTab:AddInput("StrafeSpeed", {
    Title = "Strafe speed",
    Description = "Set air strafe acceleration",
    Default = "187",
    Placeholder = "187",
    Numeric = true,
    Callback = function(input)
        local val = tonumber(input)
        if not val then return end
        if val < 1 then return end
        currentSettings.AirStrafeAcceleration = input
        
        applyToTables(function(obj)
            obj.AirStrafeAcceleration = val
        end)
    end
})

MiscTab:AddDropdown("ApplyMethod", {
    Title = "Select Apply Method",
    Values = {"Unoptimized", "Optimized"},
    Default = "Unoptimized",
    Callback = function(value)
        getgenv().ApplyMode = value
    end,
})

-- Emote modifications di MiscTab
MiscTab:AddSection("speed emote changer", "apple")

local originalEmoteSpeeds = {}
local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
if itemsFolder then
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if emotesFolder then
        for _, module in ipairs(emotesFolder:GetChildren()) do
            if module:IsA("ModuleScript") then
                local ok, data = pcall(require, module)
                if ok and data and data.EmoteInfo then
                    originalEmoteSpeeds[module.Name] = data.EmoteInfo.SpeedMult
                end
            end
        end
    end
end

local function applyEmoteSpeed(v)
    if not itemsFolder then return end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, module in ipairs(emotesFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            local ok, data = pcall(require, module)
            if ok and data and data.EmoteInfo and data.EmoteInfo.SpeedMult ~= 0 then
                data.EmoteInfo.SpeedMult = v
            end
        end
    end
end

local function restoreOriginalEmoteSpeed()
    if not itemsFolder then return end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, module in ipairs(emotesFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            local original = originalEmoteSpeeds[module.Name]
            if original then
                local ok, data = pcall(require, module)
                if ok and data and data.EmoteInfo then
                    data.EmoteInfo.SpeedMult = original
                end
            end
        end
    end
end

getgenv().featureStates.EmoteSpeedValue = 2

MiscTab:AddInput("EmoteSpeedValue", {
    Title = "Emote Speed Value",
    Description = "Set emote speed multiplier",
    Default = tostring(getgenv().featureStates.EmoteSpeedValue),
    Placeholder = "1500",
    Numeric = true,
    Callback = function(value)
        local num = tonumber(value)
        if not num or num <= 0 then return end

        getgenv().featureStates.EmoteSpeedValue = num
        local applied = num / 1000
        applyEmoteSpeed(applied)
        
        Fluent:Notify({
            Title = "Emote Speed",
            Content = "Emote speed set to " .. num,
            Duration = 2
        })
    end
})

MiscTab:AddButton({
    Title = "Reset Emote Speed",
    Description = "Reset emote speed to original values",
    Callback = function()
        restoreOriginalEmoteSpeed()
        Fluent:Notify({
            Title = "Emote Speed",
            Content = "Emote speed reset to original",
            Duration = 2
        })
    end
})

-- Infinite Slide di MiscTab
MiscTab:AddSection("inf slide", "apple")

local CachedTables = {}
local PlrModel = nil
local SlideFrictionValue = -8
local HeartbeatConnection = nil
local SlideEnabled = false
local SlideCharacterAddedConnection = nil

local function RefreshCachedTables()
    local newCachedTables = {}
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" and rawget(obj, "Friction") and rawget(obj, "Speed") then
            table.insert(newCachedTables, obj)
        end
    end
    CachedTables = newCachedTables
end

local function UpdatePlayerModel()
    local GameFolder = workspace:FindFirstChild("Game")
    local PlayersFolder = GameFolder and GameFolder:FindFirstChild("Players")
    if PlayersFolder then
        PlrModel = PlayersFolder:FindFirstChild(LocalPlayer.Name)
    else
        PlrModel = nil
    end
end

local function SetFriction(value)
    if #CachedTables == 0 then
        RefreshCachedTables()
    end
    for _, t in ipairs(CachedTables) do
        t.Friction = value
    end
end

local function OnHeartbeat()
    if not PlrModel then
        SetFriction(5)
        return
    end
    local currentState = PlrModel:GetAttribute("State")
    if currentState == "Slide" then
        PlrModel:SetAttribute("State", "EmotingSlide")
    elseif currentState == "EmotingSlide" then
        SetFriction(SlideFrictionValue)
    else
        SetFriction(5)
    end
end

local function StartInfiniteSlide()
    SlideEnabled = true
    RefreshCachedTables()
    UpdatePlayerModel()
    
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
    end
    HeartbeatConnection = RunService.Heartbeat:Connect(OnHeartbeat)
    
    if SlideCharacterAddedConnection then
        SlideCharacterAddedConnection:Disconnect()
    end
    SlideCharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        RefreshCachedTables()
        UpdatePlayerModel()
    end)
    
    Fluent:Notify({
        Title = "Infinite Slide",
        Content = "Infinite slide enabled",
        Duration = 2
    })
end

local function StopInfiniteSlide()
    SlideEnabled = false
    SetFriction(5)
    
    if HeartbeatConnection then
        HeartbeatConnection:Disconnect()
        HeartbeatConnection = nil
    end
    
    if SlideCharacterAddedConnection then
        SlideCharacterAddedConnection:Disconnect()
        SlideCharacterAddedConnection = nil
    end
    
    PlrModel = nil
    CachedTables = {}
    
    Fluent:Notify({
        Title = "Infinite Slide",
        Content = "Infinite slide disabled",
        Duration = 2
    })
end

MiscTab:AddToggle("InfiniteSlide", {
    Title = "Infinite Slide",
    Description = "Enable infinite slide mode",
    Default = false,
    Callback = function(state)
        if state then
            StartInfiniteSlide()
        else
            StopInfiniteSlide()
        end
    end
})

MiscTab:AddInput("SlideFriction", {
    Title = "Slide Friction",
    Description = "Set slide friction value (negative numbers only)",
    Default = "-8",
    Placeholder = "-8",
    Numeric = true,
    Callback = function(value)
        local num = tonumber(value)
        if num and num < 0 then
            SlideFrictionValue = num
            if SlideEnabled and PlrModel then
                local currentState = PlrModel:GetAttribute("State")
                if currentState == "EmotingSlide" then
                    SetFriction(SlideFrictionValue)
                end
            end
        end
    end
})



MiscTab:AddButton({
    Title = "Breacher (Portal Gun)",
    Description = "Upgrade Breacher tool",
    Callback = function()
        local success, result = pcall(function()
            local Breacher = require(game:GetService("ReplicatedStorage").Tools.Breacher)

            local portalTask
            for i, task in ipairs(Breacher.Tasks) do
                if task.ResourceInfo and task.ResourceInfo.Type == "Clip" then
                    portalTask = task
                    break
            end
        end

            if not portalTask then
                portalTask = Breacher.Tasks[2]
            end

            portalTask.ResourceInfo.Cap = 999999

            local blueShoot = portalTask.Functions[1].Activations[1].Methods[1]
            local yellowShoot = portalTask.Functions[2].Activations[1].Methods[1]

            blueShoot.Info.Range = 999999
            yellowShoot.Info.Range = 999999

            blueShoot.Info.SpreadIncrease = 0
            yellowShoot.Info.SpreadIncrease = 0

            portalTask.MethodReferences.Portal.Info.SpreadInfo.MaxSpread = 0
            portalTask.MethodReferences.Portal.Info.SpreadInfo.MinSpread = 0
            portalTask.MethodReferences.Portal.Info.SpreadInfo.ReductionRate = 100

            blueShoot.Info.Cooldown = 0.1
            yellowShoot.Info.Cooldown = 0.1

            blueShoot.CooldownInfo = {}
            yellowShoot.CooldownInfo = {}
            blueShoot.Requirements = {}
            yellowShoot.Requirements = {}

            Breacher.Actions.ADS.Enabled = false

            local unequipMethod = Breacher.Tasks[1].AutomaticFunctions[2].Methods[1]
            unequipMethod.CooldownInfo = {}

            if blueShoot.CooldownInfo and blueShoot.CooldownInfo.DisabledActions then
                local newDisabled = {}
                for _, action in ipairs(blueShoot.CooldownInfo.DisabledActions) do
                    if action ~= "ADS" then
                        table.insert(newDisabled, action)
                    end
                end
                blueShoot.CooldownInfo.DisabledActions = newDisabled
            end

            if yellowShoot.CooldownInfo and yellowShoot.CooldownInfo.DisabledActions then
                local newDisabled = {}
                for _, action in ipairs(yellowShoot.CooldownInfo.DisabledActions) do
                    if action ~= "ADS" then
                        table.insert(newDisabled, action)
                    end
                end
                yellowShoot.CooldownInfo.DisabledActions = newDisabled
            end

            blueShoot.GlobalPriority = 500
            yellowShoot.GlobalPriority = 500
            blueShoot.Priority = 1
            yellowShoot.Priority = 1

            blueShoot.ResourceAboveZero = false
            yellowShoot.ResourceAboveZero = false

            portalTask.Functions[1].Activations[1].CanHoldDown = true
            portalTask.Functions[2].Activations[1].CanHoldDown = true

            if not blueShoot.Info.Speed then
                blueShoot.Info.Speed = 5000
                yellowShoot.Info.Speed = 5000
            end

            local baseTask = Breacher.Tasks[1]
            baseTask.AutomaticFunctions[1].Methods[1].Info.Cooldown = 0.1
            baseTask.AutomaticFunctions[2].Methods[1].Info.Cooldown = 0.1

            Breacher.Actions.LookBack.Enabled = true

            Breacher.Adjustments.ToolViewbob = true
            Breacher.Adjustments.AnimationRootStraight = true
            Breacher.Adjustments.TurnWaist = true

            Breacher.HUD.CrosshairType = "Accurate"
            Breacher.HUD.Colored = true

            if Breacher.Actions.ADS.Zoom then
                Breacher.Actions.ADS.Zoom = nil
            end
            
            return true
        end)
        
        if success then
            Fluent:Notify({
                Title = "Breacher (Portal Gun)",
                Content = "Portal Gun Successfully upgraded! \n✓ Infinite charges \n✓ Maximum range \n✓ Instant reload",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Breacher Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

MiscTab:AddButton({
    Title = "Grapplehook",
    Description = "Upgrade Grapplehook tool",
    Callback = function()
        local success, result = pcall(function()
            local GrappleHook = require(game:GetService("ReplicatedStorage").Tools["GrappleHook"])

            local grappleTask = GrappleHook.Tasks[2]

            local shootMethod = grappleTask.Functions[1].Activations[1].Methods[1]

            shootMethod.Info.Speed = 10000
            shootMethod.Info.Lifetime = 10.0
            shootMethod.Info.Gravity = Vector3.new(0, 0, 0)
            shootMethod.Info.SpreadIncrease = 0
            shootMethod.Info.Cooldown = 0.1

            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.MaxSpread = 0
            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.MinSpread = 0
            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.ReductionRate = 100

            local checkMethod = grappleTask.AutomaticFunctions[1].Methods[1]
            checkMethod.Info.Cooldown = 0.1
            checkMethod.CooldownInfo.TestCooldown = 0.1

            grappleTask.ResourceInfo.Cap = 999999
            grappleTask.ResourceInfo.Reserve = 999999

            GrappleHook.Adjustments.ToolViewbob = false
            GrappleHook.Actions.LookBack.Enabled = true
            GrappleHook.Actions.ADS.Enabled = true
            GrappleHook.Actions.ADS.Zoom = 0.5

            shootMethod.GlobalPriority = 500
            
            return true
        end)
        
        if success then
            Fluent:Notify({
                Title = "Grapplehook",
                Content = "Grapplehook Successfully upgraded! \n✓ Infinite charges \n✓ Super speed \n✓ No gravity",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Grapplehook Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

MiscTab:AddButton({
    Title = "Smoke Grenade",
    Description = "Upgrade Smoke Grenade",
    Callback = function()
        local success, result = pcall(function()
            local SmokeGrenade = require(game:GetService("ReplicatedStorage").Tools["SmokeGrenade"])

            SmokeGrenade.RequiresOwnedItem = false

            local throwMethod = SmokeGrenade.Tasks[1].Functions[1].Activations[1].Methods[1]

            throwMethod.ItemUseIncrement = {"SmokeGrenade", 0}
            throwMethod.Info.Cooldown = 0.05
            throwMethod.Info.ThrowVelocity = 200
            SmokeGrenade.Tasks[1].Functions[1].Activations[1].CanHoldDown = true
            throwMethod.Info.SmokeDuration = 999
            throwMethod.Info.SmokeRadius = 100
            throwMethod.Info.FadeTime = 60

            local equipMethod = SmokeGrenade.Tasks[1].AutomaticFunctions[1].Methods[1]
            local unequipMethod = SmokeGrenade.Tasks[1].AutomaticFunctions[2].Methods[1]
            equipMethod.Info.Cooldown = 0.1
            unequipMethod.Info.Cooldown = 0.1

            throwMethod.GlobalPriority = 500
            throwMethod.CooldownInfo = {}
            SmokeGrenade.HUD.ShowAmount = false
            throwMethod.Info.Density = 0.9
            throwMethod.Info.Color = Color3.new(0.7, 0.7, 0.7)
            throwMethod.Info.ExplosionRadius = 20
            throwMethod.CooldownInfo.ActivatePhrase = nil
            SmokeGrenade.KeybindInfo.UnequipKeybind = "Backspace"

            local args = {
                [1] = 0,
                [2] = 20
            }
            
            game:GetService("ReplicatedStorage").Events.Character.ToolAction:FireServer(unpack(args))
            
            return true
        end)
        
        if success then
            Fluent:Notify({
                Title = "Smoke Grenade",
                Content = "Smoke Grenade Improved! \n✓ Infinite Grenades \n✓ Instant Reload \n✓ Massive Smoke Cloud",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Smoke Grenade Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

-- Gravity GUI di MiscTab
MiscTab:AddSection("Gravity", "apple")

getgenv().GravityEnabled = false
getgenv().GravityValue = 50
getgenv().GravityPosition = getgenv().GravityPosition or UDim2.new(0.5, -110, 0, 60)

local function createGravityGUI()
    if PlayerGui:FindFirstChild("GravityGUI") then PlayerGui.GravityGUI:Destroy() end

    local gui = Instance.new("ScreenGui")  
    gui.Name = "GravityGUI"  
    gui.ResetOnSpawn = false  
    gui.Parent = PlayerGui  
    gui.Enabled = false  
    
    local btn = Instance.new("TextButton")  
    btn.Size = UDim2.new(0, 220, 0, 44)  
    btn.Position = getgenv().GravityPosition  
    btn.AnchorPoint = Vector2.new(0.5, 0)  
    btn.Text = "Gravitasi [OFF]"  
    btn.Font = Enum.Font.Gotham  
    btn.TextSize = 20  
    btn.TextColor3 = Color3.new(1,1,1)  
    btn.AutoButtonColor = false  
    btn.BackgroundTransparency = 0.15  
    btn.Parent = gui  
    
    local gradient = Instance.new("UIGradient", btn)  
    gradient.Color = ColorSequence.new({  
        ColorSequenceKeypoint.new(0, Color3.fromRGB(64, 224, 208)),  
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),  
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 149, 237))  
    })  
    gradient.Rotation = 45  
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)  
    
    local stroke = Instance.new("UIStroke", btn)  
    stroke.Thickness = 1.5  
    stroke.Color = Color3.new(1,1,1)  
    stroke.Transparency = 0.3  
    
    -- SISTEM DRAG
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil  
    
    local function update(input)  
        local delta = input.Position - dragStart  
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)  
    end  
    
    btn.InputBegan:Connect(function(input)  
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
            dragging = true  
            dragInput = input  
            dragStart = input.Position  
            startPos = btn.Position  
            
            input.Changed:Connect(function()  
                if input.UserInputState == Enum.UserInputState.End then  
                    dragging = false  
                    getgenv().GravityPosition = btn.Position  
                end  
            end)  
        end  
    end)  
    
    btn.InputChanged:Connect(function(input)  
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then  
            dragInput = input  
        end  
    end)  
    
    UserInputService.InputChanged:Connect(function(input)  
        if dragging and input == dragInput then  
            update(input)  
        end  
    end)  
    
    btn.MouseEnter:Connect(function()   
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()   
    end)  
    
    btn.MouseLeave:Connect(function()   
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()   
    end)  
    
    btn.MouseButton1Click:Connect(function()  
        if not dragging then  
            getgenv().GravityEnabled = not getgenv().GravityEnabled  
            
            if getgenv().GravityEnabled then  
                workspace.Gravity = getgenv().GravityValue  
            else  
                workspace.Gravity = 196.2  
            end  
            
            btn.Text = "Gravitasi ["..(getgenv().GravityEnabled and "ON" or "OFF").."]"  
        end  
    end)  
    
    return gui
end

local GravityGUI = nil

MiscTab:AddToggle("GravityGUI", {
    Title = "Gravity GUI",
    Description = "Enable gravity control GUI",
    Default = false,
    Callback = function(state)
        if state then
            if not GravityGUI or not GravityGUI.Parent then
                GravityGUI = createGravityGUI()
            end
            GravityGUI.Enabled = true
        else
            if GravityGUI then
                GravityGUI.Enabled = false
                if getgenv().GravityEnabled then
                    getgenv().GravityEnabled = false
                    workspace.Gravity = 196.2
                end
            end
        end
    end
})

MiscTab:AddInput("GravityValue", {
    Title = "Gravity Value",
    Description = "Set custom gravity value",
    Default = tostring(getgenv().GravityValue),
    Placeholder = tostring(getgenv().GravityValue),
    Numeric = true,
    Callback = function(val)
        local n = tonumber(val)
        if n and n > 0 then
            getgenv().GravityValue = n
            if GravityGUI and GravityGUI.Enabled and getgenv().GravityEnabled then
                workspace.Gravity = n
            end
        end
    end
})

-- Back Jump di MiscTab
MiscTab:AddSection("Back jump", "apple")

getgenv().BackJumpEnabled = false
getgenv().BackJumpSpeed = 50
getgenv().BackJumpPosition = getgenv().BackJumpPosition or UDim2.new(0.5, -110, 0, 10)

local maxExtraSpeed = 100
local minSpeedOffset = 0
local lastTick = tick()
local airAccumulator = 0
local airTotalTime = 0
local wasAir = false
local activeBV = nil
local currentSpeed = getgenv().BackJumpSpeed
local countingEnabled = false
local speedometer = nil
local backJumpGUI = nil
local backJumpLastJump = 0
local backJumpJumpCooldown = 0.1

local function truncate1Decimal(val)
    return math.floor(val * 10) / 10
end

local function getSpeedometer()
    local ok, spd = pcall(function()
        return PlayerGui.Shared.HUD.Overlay.Default.CharacterInfo.Item.Speedometer.Players
    end)
    if ok then return spd end
    return nil
end

local function IsOnGroundBack()
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return false end

    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping or 
       state == Enum.HumanoidStateType.Freefall or
       state == Enum.HumanoidStateType.Swimming then
        return false
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.IgnoreWater = true

    local rayOrigin = root.Position
    local rayDirection = Vector3.new(0, -4, 0)
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if not raycastResult then return false end

    local surfaceNormal = raycastResult.Normal
    local angle = math.deg(math.acos(surfaceNormal:Dot(Vector3.new(0, 1, 0))))

    return angle <= 45
end

local oldNewIndex
if not oldNewIndex then
    oldNewIndex = hookmetamethod(game, "__newindex", function(self, idx, val)
        if not checkcaller() and countingEnabled and speedometer and self == speedometer and idx == "Text" then
            return
        end
        return oldNewIndex(self, idx, val)
    end)
end

local function createBackJumpGUI()
    if PlayerGui:FindFirstChild("BackJumpGUI") then 
        PlayerGui.BackJumpGUI:Destroy() 
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "BackJumpGUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui
    gui.Enabled = true
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 44)
    btn.Position = getgenv().BackJumpPosition
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.Text = "Back Jump [OFF]"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.TextColor3 = Color3.new(1,1,1)
    btn.AutoButtonColor = false
    btn.BackgroundTransparency = 0.15
    btn.Parent = gui
    
    local gradient = Instance.new("UIGradient", btn)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(64, 224, 208)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 149, 237))
    })
    gradient.Rotation = 45
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1.5
    stroke.Color = Color3.new(1,1,1)
    stroke.Transparency = 0.3
    
    -- SISTEM DRAG
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    
    local function update(input)
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = btn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    getgenv().BackJumpPosition = btn.Position
                end
            end)
        end
    end)
    
    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
    
    btn.MouseEnter:Connect(function() 
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play() 
    end)
    
    btn.MouseLeave:Connect(function() 
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play() 
    end)
    
    btn.MouseButton1Click:Connect(function()
        if not dragging then
            getgenv().BackJumpEnabled = not getgenv().BackJumpEnabled
            btn.Text = "Back Jump ["..(getgenv().BackJumpEnabled and "ON" or "OFF").."]"
            
            if not getgenv().BackJumpEnabled then
                if activeBV then
                    activeBV:Destroy()
                    activeBV = nil
                end
                currentSpeed = getgenv().BackJumpSpeed
                countingEnabled = false
                airAccumulator = 0
                airTotalTime = 0
                wasAir = false
            end
        end
    end)
    
    return gui
end

RunService.RenderStepped:Connect(function()
    local deltaTime = tick() - lastTick
    lastTick = tick()

    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if root and humanoid then
            speedometer = getSpeedometer()
            local isAir = humanoid.FloorMaterial == Enum.Material.Air
            local onGround = IsOnGroundBack()

            if getgenv().BackJumpEnabled then
                local now = tick()
                if onGround and (now - backJumpLastJump) > backJumpJumpCooldown then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    backJumpLastJump = now
                end
            end

            if wasAir and not isAir then
                currentSpeed = math.max(getgenv().BackJumpSpeed - minSpeedOffset, currentSpeed - 10)
                if speedometer then speedometer.Text = tostring(truncate1Decimal(currentSpeed)) end
                airTotalTime = 0
            end
            wasAir = isAir

            if getgenv().BackJumpEnabled then
                if isAir then
                    airAccumulator = airAccumulator + deltaTime
                    airTotalTime = airTotalTime + deltaTime
                    while airAccumulator >= 0.04 do
                        airAccumulator = airAccumulator - 0.04
                        local increment = math.max(0.1, 2.5 * (0.04 / 1))
                        currentSpeed = math.min(getgenv().BackJumpSpeed + maxExtraSpeed, currentSpeed + increment)
                    end
                else
                    airAccumulator = 0
                    currentSpeed = math.max(getgenv().BackJumpSpeed - minSpeedOffset, currentSpeed - 4 * deltaTime)
                    airTotalTime = 0
                end

                if activeBV then activeBV:Destroy() end

                local lookDir = camera.CFrame.LookVector
                lookDir = Vector3.new(-lookDir.X, 0, -lookDir.Z)
                if lookDir.Magnitude ~= 0 then
                    lookDir = lookDir.Unit
                end

                local bv = Instance.new("BodyVelocity")
                bv.Velocity = lookDir * currentSpeed
                bv.MaxForce = Vector3.new(4e5, 0, 4e5)
                bv.P = 1250
                bv.Parent = root
                Debris:AddItem(bv, 0.1)
                activeBV = bv

                countingEnabled = true
                if speedometer then speedometer.Text = tostring(truncate1Decimal(currentSpeed)) end
            else
                if activeBV then activeBV:Destroy() end
                activeBV = nil
                currentSpeed = getgenv().BackJumpSpeed
                countingEnabled = false
                airAccumulator = 0
                airTotalTime = 0
                wasAir = false
            end
        end
    end
end)

MiscTab:AddToggle("BackJump", {
    Title = "Back Jump",
    Description = "Enable back jump + auto jump",
    Default = false,
    Callback = function(state)
        getgenv().BackJumpEnabled = state
        
        if state then
            if not backJumpGUI or not backJumpGUI.Parent then
                backJumpGUI = createBackJumpGUI()
            end
            Fluent:Notify({
                Title = "Back Jump",
                Content = "Back Jump + Auto Jump activated",
                Duration = 2
            })
        else
            if backJumpGUI then
                backJumpGUI:Destroy()
                backJumpGUI = nil
            end
            if activeBV then
                activeBV:Destroy()
                activeBV = nil
            end
            currentSpeed = getgenv().BackJumpSpeed
            countingEnabled = false
            airAccumulator = 0
            airTotalTime = 0
            wasAir = false
            Fluent:Notify({
                Title = "Back Jump",
                Content = "Back Jump deactivated",
                Duration = 2
            })
        end
    end
})

MiscTab:AddInput("BackJumpSpeed", {
    Title = "Back Jump Speed",
    Description = "Set back jump speed (1-500)",
    Default = "50",
    Placeholder = "50",
    Numeric = true,
    Callback = function(input)
        local val = tonumber(input)
        if val and val > 0 and val <= 500 then
            getgenv().BackJumpSpeed = val
            currentSpeed = val
        end
    end
})

-- Front Jump di MiscTab
MiscTab:AddSection("front jump", "apple")

getgenv().FrontJumpEnabled = false
getgenv().FrontJumpSpeed = 50
getgenv().FrontJumpPosition = getgenv().FrontJumpPosition or UDim2.new(0.5, -110, 0, 60)

local maxExtraSpeed = 100
local minSpeedOffset = 0
local lastTickFront = tick()
local airAccumulatorFront = 0
local airTotalTimeFront = 0
local wasAirFront = false
local activeBVFront = nil
local currentSpeedFront = getgenv().FrontJumpSpeed
local countingEnabledFront = false
local speedometerFront = nil
local frontJumpGUI = nil
local frontJumpLastJump = 0
local frontJumpJumpCooldown = 0.1

local function truncate1DecimalFront(val)
    return math.floor(val * 10) / 10
end

local function getSpeedometerFront()
    local ok, spd = pcall(function()
        return PlayerGui.Shared.HUD.Overlay.Default.CharacterInfo.Item.Speedometer.Players
    end)
    if ok then return spd end
    return nil
end

local oldNewIndexFront
if not oldNewIndexFront then
    oldNewIndexFront = hookmetamethod(game, "__newindex", function(self, idx, val)
        if not checkcaller() and countingEnabledFront and speedometerFront and self == speedometerFront and idx == "Text" then
            return
        end
        return oldNewIndexFront(self, idx, val)
    end)
end

local function IsOnGroundFront()
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return false end

    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping or 
       state == Enum.HumanoidStateType.Freefall or
       state == Enum.HumanoidStateType.Swimming then
        return false
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.IgnoreWater = true

    local rayOrigin = root.Position
    local rayDirection = Vector3.new(0, -4, 0)
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if not raycastResult then return false end

    local surfaceNormal = raycastResult.Normal
    local angle = math.deg(math.acos(surfaceNormal:Dot(Vector3.new(0, 1, 0))))

    return angle <= 45
end

local function createFrontJumpGUI()
    if PlayerGui:FindFirstChild("FrontJumpGUI") then 
        PlayerGui.FrontJumpGUI:Destroy() 
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "FrontJumpGUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui
    gui.Enabled = true
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 44)
    btn.Position = getgenv().FrontJumpPosition
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.Text = "Front Jump [OFF]"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.TextColor3 = Color3.new(1,1,1)
    btn.AutoButtonColor = false
    btn.BackgroundTransparency = 0.15
    btn.Parent = gui
    
    local gradient = Instance.new("UIGradient", btn)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(64, 224, 208)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 149, 237))
    })
    gradient.Rotation = 45
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1.5
    stroke.Color = Color3.new(1,1,1)
    stroke.Transparency = 0.3
    
    -- SISTEM DRAG
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    
    local function update(input)
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = btn.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    getgenv().FrontJumpPosition = btn.Position
                end
            end)
        end
    end)
    
    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
    
    btn.MouseEnter:Connect(function() 
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play() 
    end)
    
    btn.MouseLeave:Connect(function() 
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play() 
    end)
    
    btn.MouseButton1Click:Connect(function()
        if not dragging then
            getgenv().FrontJumpEnabled = not getgenv().FrontJumpEnabled
            btn.Text = "Front Jump ["..(getgenv().FrontJumpEnabled and "ON" or "OFF").."]"
            
            if not getgenv().FrontJumpEnabled then
                if activeBVFront then
                    activeBVFront:Destroy()
                    activeBVFront = nil
                end
                currentSpeedFront = getgenv().FrontJumpSpeed
                countingEnabledFront = false
                airAccumulatorFront = 0
                airTotalTimeFront = 0
                wasAirFront = false
            end
        end
    end)
    
    return gui
end

RunService.RenderStepped:Connect(function()
    local deltaTime = tick() - lastTickFront
    lastTickFront = tick()

    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if root and humanoid then
            speedometerFront = getSpeedometerFront()
            local isAir = humanoid.FloorMaterial == Enum.Material.Air
            local onGround = IsOnGroundFront()

            if getgenv().FrontJumpEnabled then
                local now = tick()
                if onGround and (now - frontJumpLastJump) > frontJumpJumpCooldown then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    frontJumpLastJump = now
                end
            end

            if wasAirFront and not isAir then
                currentSpeedFront = math.max(getgenv().FrontJumpSpeed - minSpeedOffset, currentSpeedFront - 10)
                if speedometerFront then speedometerFront.Text = tostring(truncate1DecimalFront(currentSpeedFront)) end
                airTotalTimeFront = 0
            end
            wasAirFront = isAir

            if getgenv().FrontJumpEnabled then
                if isAir then
                    airAccumulatorFront = airAccumulatorFront + deltaTime
                    airTotalTimeFront = airTotalTimeFront + deltaTime
                    while airAccumulatorFront >= 0.04 do
                        airAccumulatorFront = airAccumulatorFront - 0.04
                        local increment = math.max(0.1, 2.5 * (0.04 / 1))
                        currentSpeedFront = math.min(getgenv().FrontJumpSpeed + maxExtraSpeed, currentSpeedFront + increment)
                    end
                else
                    airAccumulatorFront = 0
                    currentSpeedFront = math.max(getgenv().FrontJumpSpeed - minSpeedOffset, currentSpeedFront - 4 * deltaTime)
                    airTotalTimeFront = 0
                end

                if activeBVFront then activeBVFront:Destroy() end

                local lookDir = camera.CFrame.LookVector
                lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)
                if lookDir.Magnitude ~= 0 then
                    lookDir = lookDir.Unit
                end

                local bv = Instance.new("BodyVelocity")
                bv.Velocity = lookDir * currentSpeedFront
                bv.MaxForce = Vector3.new(4e5, 0, 4e5)
                bv.P = 1250
                bv.Parent = root
                Debris:AddItem(bv, 0.1)
                activeBVFront = bv

                countingEnabledFront = true
                if speedometerFront then speedometerFront.Text = tostring(truncate1DecimalFront(currentSpeedFront)) end
            else
                if activeBVFront then activeBVFront:Destroy() end
                activeBVFront = nil
                currentSpeedFront = getgenv().FrontJumpSpeed
                countingEnabledFront = false
                airAccumulatorFront = 0
                airTotalTimeFront = 0
                wasAirFront = false
            end
        end
    end
end)

MiscTab:AddToggle("FrontJump", {
    Title = "Front Jump",
    Description = "Enable front jump",
    Default = false,
    Callback = function(state)
        getgenv().FrontJumpEnabled = state
        
        if state then
            if not frontJumpGUI or not frontJumpGUI.Parent then
                frontJumpGUI = createFrontJumpGUI()
            end
            Fluent:Notify({
                Title = "Front Jump",
                Content = "Front Jump activated",
                Duration = 2
            })
        else
            if frontJumpGUI then
                frontJumpGUI:Destroy()
                frontJumpGUI = nil
            end
            if activeBVFront then
                activeBVFront:Destroy()
                activeBVFront = nil
            end
            currentSpeedFront = getgenv().FrontJumpSpeed
            countingEnabledFront = false
            airAccumulatorFront = 0
            airTotalTimeFront = 0
            wasAirFront = false
            Fluent:Notify({
                Title = "Front Jump",
                Content = "Front Jump deactivated",
                Duration = 2
            })
        end
    end
})

MiscTab:AddInput("FrontJumpSpeed", {
    Title = "Front Jump Speed",
    Description = "Set front jump speed (1-500)",
    Default = "50",
    Placeholder = "50",
    Numeric = true,
    Callback = function(input)
        local val = tonumber(input)
        if val and val > 0 and val <= 500 then
            getgenv().FrontJumpSpeed = val
            currentSpeedFront = val
        end
    end
})

-- Lag Switch di MiscTab dengan mode Normal dan Demon
MiscTab:AddSection("lag switch", "apple")

getgenv().LagSwitchDuration = getgenv().LagSwitchDuration or 0.5
getgenv().LagSwitchMode = getgenv().LagSwitchMode or "Normal"

local fflagEnabled = false

local function SetFFlag(val)
    pcall(function()
        setfflag("MaxMissedWorldStepsRemembered", tostring(val))
    end)
end

-- Loop FFlag
task.spawn(function()
    while true do
        if fflagEnabled then
            SetFFlag(1000)
        end
        task.wait(1)
    end
end)

local function triggerLagSwitch()
    task.spawn(function()
        local start = tick()
        local duration = getgenv().LagSwitchDuration
        
        if getgenv().LagSwitchMode == "Normal" then
            while tick() - start < duration do
                for i = 1, 10000 do
                    math.random(1,1000000)
                end
            end
        else
            while tick() - start < duration do
                for i = 1, 20000 do
                    math.random(1,1000000)
                    local x = math.sqrt(i * 12345)
                    local y = math.sin(x) * math.cos(x)
                end
            end
        end
    end)
end

local function createLagSwitchGUI()

    if game.Players.LocalPlayer.PlayerGui:FindFirstChild("LagSwitchGUI") then
        game.Players.LocalPlayer.PlayerGui.LagSwitchGUI:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "LagSwitchGUI"
    gui.ResetOnSpawn = false
    gui.Parent = game.Players.LocalPlayer.PlayerGui
    gui.Enabled = false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,220,0,44)
    btn.Position = getgenv().LagSwitchPosition or UDim2.new(0.5,-110,0,120)
    btn.AnchorPoint = Vector2.new(0.5,0)
    btn.Text = "Lag Switch ("..getgenv().LagSwitchMode..")"
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 20
    btn.TextColor3 = Color3.new(1,1,1)
    btn.AutoButtonColor = false
    btn.BackgroundTransparency = 0.15
    btn.Parent = gui

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(64,224,208)),
        ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(100,149,237))
    }
    gradient.Rotation = 45
    gradient.Parent = btn

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1,0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.new(1,1,1)
    stroke.Transparency = 0.3
    stroke.Parent = btn

    -- drag
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType.Name == "MouseButton1" or input.UserInputType.Name == "Touch" then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position

            input.Changed:Connect(function()
                if input.UserInputState.Name == "End" then
                    dragging = false
                    getgenv().LagSwitchPosition = btn.Position
                end
            end)
        end
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType.Name == "MouseMovement" or input.UserInputType.Name == "Touch" then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        if not dragging then
            triggerLagSwitch()
        end
    end)

    return gui
end

local lagSwitchGUI

MiscTab:AddToggle("LagSwitch",{
    Title = "Lag Switch",
    Default = false,
    Callback = function(state)

        if state then
            if not lagSwitchGUI or not lagSwitchGUI.Parent then
                lagSwitchGUI = createLagSwitchGUI()
            end
            lagSwitchGUI.Enabled = true
        else
            if lagSwitchGUI then
                lagSwitchGUI.Enabled = false
                fflagEnabled = false
            end
        end

    end
})

MiscTab:AddDropdown("LagSwitchMode",{
    Title = "Lag Switch Mode",
    Values = {"Normal","Demon"},
    Default = getgenv().LagSwitchMode,
    Callback = function(value)

        getgenv().LagSwitchMode = value

        if value == "Demon" then
            fflagEnabled = true
        else
            fflagEnabled = false
        end

        if lagSwitchGUI and lagSwitchGUI.Enabled then
            local btn = lagSwitchGUI:FindFirstChildOfClass("TextButton")
            if btn then
                btn.Text = "Lag Switch ("..value..")"
            end
        end

    end
})

MiscTab:AddInput("LagSwitchDuration",{
    Title = "Lag Duration",
    Default = tostring(getgenv().LagSwitchDuration),
    Placeholder = "0.5",
    Numeric = true,
    Callback = function(value)

        local num = tonumber(value)

        if num and num > 0 then
            getgenv().LagSwitchDuration = num
        else
            getgenv().LagSwitchDuration = 0.5
        end

    end
})

MiscTab:AddSection("auto respawn")

local featureStates = { AutoSelfRevive = false, SelfReviveMethod = "Spawnpoint" }    

local lastSavedPosition = nil
local AutoSelfReviveConnection = nil
local respawnConnection = nil
local hasRevived = false    

local function doRevive(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local isDowned = char:GetAttribute("Downed")
    if not isDowned then return end

    if featureStates.SelfReviveMethod == "Spawnpoint" then
        if not hasRevived then
            hasRevived = true
            pcall(function()
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end)
            task.delay(10, function() hasRevived = false end)
        end
    elseif featureStates.SelfReviveMethod == "Revive" then
        if hrp then lastSavedPosition = hrp.Position end
        task.spawn(function()
            task.wait(3)
            local startTime = tick()
            repeat
                pcall(function()
                    ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                end)
                task.wait(1)
            until not char:GetAttribute("Downed") or (tick() - startTime > 1)

            local newChar
            repeat
                newChar = LocalPlayer.Character
                task.wait()
            until newChar and newChar:FindFirstChild("HumanoidRootPart")

            local newHRP = newChar:FindFirstChild("HumanoidRootPart")
            if lastSavedPosition and newHRP then
                newHRP.CFrame = CFrame.new(lastSavedPosition)
                task.wait(0.5)
                if (newHRP.Position - lastSavedPosition).Magnitude > 1 then
                    lastSavedPosition = nil
                end
            end
        end)
    end    
end    

local function setupAutoRevive(char)
    if AutoSelfReviveConnection then AutoSelfReviveConnection:Disconnect() end
    AutoSelfReviveConnection = char:GetAttributeChangedSignal("Downed"):Connect(function()
        if char:GetAttribute("Downed") then doRevive(char) end
    end)
end    

if respawnConnection then respawnConnection:Disconnect() end
respawnConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    if featureStates.AutoSelfRevive then setupAutoRevive(newChar) end
end)

MiscTab:AddDropdown("RespawnMethod", {
    Title = "Respawn Method",
    Description = "Choose respawn method",
    Values = {"Spawnpoint", "Revive"},
    Default = "Spawnpoint",
    Callback = function(value)
        featureStates.SelfReviveMethod = value
    end
})    

MiscTab:AddButton({
    Title = "Respawn",
    Description = "Manually respawn",
    Callback = function()
        doRevive(LocalPlayer.Character)
    end
})    

MiscTab:AddToggle("AutoSelfRevive", {
    Title = "Auto Self Revive",
    Description = "Automatically revive when downed",
    Default = false,
    Callback = function(state)
        featureStates.AutoSelfRevive = state
        if state and LocalPlayer.Character then
            setupAutoRevive(LocalPlayer.Character)
        end
    end
})

if LocalPlayer.Character and featureStates.AutoSelfRevive then
    setupAutoRevive(LocalPlayer.Character)
end

-- Auto Carry & Revive di MiscTab
local INTERACT_REMOTE = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")

getgenv().AutoCarryEnabled = false
getgenv().AutoReviveEnabled = false
getgenv().AutoCarryDelay = 1
getgenv().AutoReviveDelay = 1
getgenv().AutoCarryPosition = UDim2.new(0.5, -110, 0, 50)
getgenv().AutoRevivePosition = UDim2.new(0.5, -110, 0, 120)

local function CreateFloatingButton(name, enabledFlag, savedPosFlag, defaultPosY)
    if PlayerGui:FindFirstChild(name.."GUI") then
        PlayerGui[name.."GUI"]:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name.."GUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 220, 0, 44)
    Button.Position = getgenv()[savedPosFlag] or UDim2.new(0.5, -110, 0, defaultPosY)
    Button.AnchorPoint = Vector2.new(0.5, 0)
    Button.Text = name.." [OFF]"
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 20
    Button.TextColor3 = Color3.new(1,1,1)
    Button.AutoButtonColor = false
    Button.BackgroundTransparency = 0.15
    Button.Parent = screenGui
    
    local gradient = Instance.new("UIGradient", Button)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(64, 224, 208)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 149, 237))
    })
    gradient.Rotation = 45
    
    Instance.new("UICorner", Button).CornerRadius = UDim.new(1,0)
    
    local stroke = Instance.new("UIStroke", Button)
    stroke.Thickness = 1.5
    stroke.Color = Color3.new(1,1,1)
    stroke.Transparency = 0.3

    local dragging = false

    Button.MouseEnter:Connect(function()
        if not dragging then
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
        end
    end)
    Button.MouseLeave:Connect(function()
        if not dragging then
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
        end
    end)

    Button.MouseButton1Click:Connect(function()
        if not dragging then
            getgenv()[enabledFlag] = not getgenv()[enabledFlag]
            Button.Text = name.." ["..(getgenv()[enabledFlag] and "ON" or "OFF").."]"
        end
    end)

    local dragStart, startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        Button.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end

    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Button.Position
            
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.4}):Play()
            
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    getgenv()[savedPosFlag] = Button.Position
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
                    conn:Disconnect()
                end
            end)
        end
    end)

    local inputChangedConn
    inputChangedConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)

    screenGui.Destroying:Connect(function()
        if inputChangedConn then inputChangedConn:Disconnect() end
    end)

    screenGui.Enabled = false
    return screenGui
end

local AutoCarryGUI = CreateFloatingButton("AutoCarry", "AutoCarryEnabled", "AutoCarryPosition", 50)
local AutoReviveGUI = CreateFloatingButton("AutoRevive", "AutoReviveEnabled", "AutoRevivePosition", 120)

RunService.RenderStepped:Connect(function()
    if getgenv().AutoCarryEnabled then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local targetHRP = player.Character.HumanoidRootPart
                    local targetHumanoid = player.Character.Humanoid
                    if (myHRP.Position - targetHRP.Position).Magnitude <= 10 and targetHumanoid.Health <= 0 then
                        if tick() - (getgenv().AutoCarryLast or 0) >= getgenv().AutoCarryDelay then
                            INTERACT_REMOTE:FireServer("Carry", nil, player.Name)
                            getgenv().AutoCarryLast = tick()
                        end
                    end
                end
            end
        end
    end

    if getgenv().AutoReviveEnabled then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local targetHRP = player.Character.HumanoidRootPart
                    local targetHumanoid = player.Character.Humanoid
                    if (myHRP.Position - targetHRP.Position).Magnitude <= 10 and targetHumanoid.Health <= 0 then
                        if tick() - (getgenv().AutoReviveLast or 0) >= getgenv().AutoReviveDelay then
                            INTERACT_REMOTE:FireServer("Revive", true, player.Name)
                            getgenv().AutoReviveLast = tick()
                        end
                    end
                end
            end
        end
    end
end)

MiscTab:AddToggle("AutoCarryGUI", {
    Title = "Auto Carry GUI",
    Description = "Enable auto carry GUI",
    Default = false,
    Callback = function(state)
        AutoCarryGUI.Enabled = state
        if not state then
            getgenv().AutoCarryEnabled = false
        end
    end
})

MiscTab:AddInput("CarryDelay", {
    Title = "Carry Delay (s)",
    Description = "Set auto carry delay",
    Default = tostring(getgenv().AutoCarryDelay),
    Placeholder = "1",
    Numeric = true,
    Callback = function(val)
        local n = tonumber(val)
        if n and n > 0 then
            getgenv().AutoCarryDelay = n
        end
    end
})

MiscTab:AddToggle("AutoReviveGUI", {
    Title = "Auto Revive GUI",
    Description = "Enable auto revive GUI",
    Default = false,
    Callback = function(state)
        AutoReviveGUI.Enabled = state
        if not state then
            getgenv().AutoReviveEnabled = false
        end
    end
})

MiscTab:AddInput("ReviveDelay", {
    Title = "Revive Delay (s)",
    Description = "Set auto revive delay",
    Default = tostring(getgenv().AutoReviveDelay),
    Placeholder = "1",
    Numeric = true,
    Callback = function(val)
        local n = tonumber(val)
        if n and n > 0 then
            getgenv().AutoReviveDelay = n
        end
    end
})

-- Emote wheel replacement di VisualTab
local LP = Players.LocalPlayer
local CURRENT_AVATAR = nil
local ORIGINAL_DESC = nil

if LP.Character then
    local HUM = LP.Character:FindFirstChild("Humanoid")
    if HUM then
        ORIGINAL_DESC = HUM:GetAppliedDescription()
    end
end

local function applyAvatarToCharacter(char, name, id, desc)
    task.spawn(function()
        local HUM = char:WaitForChild("Humanoid", 10)
        if not HUM then return end

        for _, v in char:GetDescendants() do
            if v:IsA("Accessory") or v:IsA("Hat") then
                v:Destroy()
            end
        end
        
        for _, v in char:GetChildren() do
            if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then
                v:Destroy()
            end
        end

        local BC = HUM:FindFirstChildOfClass("BodyColors")
        if BC then BC:Destroy() end

        for _, partName in {"Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"} do
            local part = char:FindFirstChild(partName)
            if part then
                for _, v in part:GetChildren() do
                    if v:IsA("SpecialMesh") then
                        v:Destroy()
                    end
                end
            end
        end

        local HEAD = char:FindFirstChild("Head")
        if HEAD then
            local mesh = HEAD:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                mesh.MeshId = ""
                mesh.TextureId = ""
            end
        end

        task.wait(0.1)

        HUM:ApplyDescriptionClientServer(desc)
        HUM.DisplayName = name
    end)
end

local function changeAvatar(input)
    local userId = tonumber(input)
    local userName = nil

    if userId then
        local success, name = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        if not success or not name then
            return
        end
        userName = name
    else
        local success, id = pcall(function()
            return Players:GetUserIdFromNameAsync(input)
        end)
        if not success or not id then
            return
        end
        userId = id
        
        local success2, name = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        if not success2 or not name then
            return
        end
        userName = name
    end

    local success, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    if not success or not desc then
        return
    end

    CURRENT_AVATAR = {
        id = userId,
        name = userName,
        desc = desc
    }

    if LP.Character then
        applyAvatarToCharacter(LP.Character, userName, userId, desc)
    end

    LP.CharacterAdded:Connect(function(char)
        if CURRENT_AVATAR and CURRENT_AVATAR.id == userId then
            applyAvatarToCharacter(char, userName, userId, desc)
        end
    end)
end

local function resetToOriginal()
    if ORIGINAL_DESC and LP.Character then
        local HUM = LP.Character:FindFirstChild("Humanoid")
        if HUM then
            HUM:ApplyDescriptionClientServer(ORIGINAL_DESC)
            HUM.DisplayName = LP.DisplayName
        end
    end
    CURRENT_AVATAR = nil
end

local avatarInputValue = ""

VisualTab:AddInput("AvatarInput", {
    Title = "Username / User ID",
    Description = "Enter Roblox username or user ID",
    Default = "",
    Placeholder = "Roblox or 123456789",
    Callback = function(value)
        avatarInputValue = value
        if value and value ~= "" then
            changeAvatar(value)
        end
    end
})

VisualTab:AddButton({
    Title = "Apply Avatar",
    Description = "Apply avatar from entered username/ID",
    Callback = function()
        if avatarInputValue and avatarInputValue ~= "" then
            changeAvatar(avatarInputValue)
        end
    end
})

-- Headless & Korblox di VisualTab
local HEADLESS_MESH_ID = "rbxassetid://1095708"
local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_COLOR = Color3.fromRGB(50, 50, 50)

local headlessEnabled = false
local korbloxEnabled = false
local headlessMesh
local originalLegColor

local function applyHeadless(head)
    if not head then return end
    head.Transparency = 1
    head.CanCollide = false

    local face = head:FindFirstChild("face")
    if face then face:Destroy() end

    headlessMesh = Instance.new("SpecialMesh")
    headlessMesh.MeshType = Enum.MeshType.FileMesh
    headlessMesh.MeshId = HEADLESS_MESH_ID
    headlessMesh.Scale = Vector3.new(0.001, 0.001, 0.001)
    headlessMesh.Parent = head
end

local function removeHeadless(head)
    if not head then return end
    if headlessMesh then
        headlessMesh:Destroy()
        headlessMesh = nil
    end
    head.Transparency = 0
    head.CanCollide = true
end

local function applyKorblox(character)
    local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
    if not rightLeg then return end

    if not originalLegColor then
        originalLegColor = rightLeg.Color
    end

    for _, child in ipairs(rightLeg:GetChildren()) do
        if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then
            child:Destroy()
        end
    end

    rightLeg.Color = KORBLOX_COLOR
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = KORBLOX_MESH_ID
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Parent = rightLeg
end

local function removeKorblox(character)
    local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
    if not rightLeg then return end

    for _, child in ipairs(rightLeg:GetChildren()) do
        if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then
            child:Destroy()
        end
    end

    if originalLegColor then
        rightLeg.Color = originalLegColor
        originalLegColor = nil
    end
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local head = char:FindFirstChild("Head")
    if headlessEnabled then
        applyHeadless(head)
    end
    if korbloxEnabled then
        applyKorblox(char)
    end
end)

VisualTab:AddToggle("Headless", {
    Title = "Headless",
    Description = "Enable headless appearance",
    Default = false,
    Callback = function(state)
        headlessEnabled = state
        local char = LP.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if state then
            applyHeadless(head)
        else
            removeHeadless(head)
        end
    end
})

VisualTab:AddToggle("Korblox", {
    Title = "Korblox",
    Description = "Enable Korblox leg",
    Default = false,
    Callback = function(state)
        korbloxEnabled = state
        local char = LP.Character
        if not char then return end
        if state then
            applyKorblox(char)
        else
            removeKorblox(char)
        end
    end
})

VisualTab:AddSection("FOV CHANGER", "apple")

VisualTab:AddSlider("FOV", {
    Title = "Field of View",
    Description = "Adjust your field of view",
    Default = 70,
    Min = 1,
    Max = 270,
    Rounding = 0,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            pcall(function()
                game:GetService("ReplicatedStorage").Events.Data.ChangeSetting:InvokeServer(2, num)
            end)
        end
    end
})

-- Camera Stretch di VisualTab
VisualTab:AddSection("Stretch", "apple")

local cameraStretchConnection = nil
local stretchHorizontal = 0.80
local stretchVertical = 0.80

local function updateCameraStretch()
    if cameraStretchConnection then
        cameraStretchConnection:Disconnect()
        cameraStretchConnection = nil
    end
    
    cameraStretchConnection = game:GetService("RunService").RenderStepped:Connect(function()
        local Camera = workspace.CurrentCamera
        if Camera then
            Camera.CFrame = Camera.CFrame * CFrame.new(
                0, 0, 0,
                stretchHorizontal, 0, 0,
                0, stretchVertical, 0,
                0, 0, 1
            )
        end
    end)
end

VisualTab:AddToggle("CameraStretch", {
    Title = "Camera Stretch",
    Description = "Enable camera stretch effect",
    Default = false,
    Callback = function(state)
        if state then
            updateCameraStretch()
        else
            if cameraStretchConnection then
                cameraStretchConnection:Disconnect()
                cameraStretchConnection = nil
            end
        end
    end
})

VisualTab:AddInput("StretchHorizontal", {
    Title = "Camera Stretch Horizontal", 
    Description = "Set horizontal stretch value",
    Default = tostring(stretchHorizontal),
    Placeholder = "0.80",
    Numeric = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            stretchHorizontal = num
            if cameraStretchConnection then
                updateCameraStretch()
            end
        end
    end
})

VisualTab:AddInput("StretchVertical", {
    Title = "Camera Stretch Vertical",
    Description = "Set vertical stretch value",
    Default = tostring(stretchVertical),
    Placeholder = "0.80",
    Numeric = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            stretchVertical = num
            if cameraStretchConnection then
                updateCameraStretch()
            end
        end
    end
})

-- Fake Streaks di VisualTab
VisualTab:AddSection("Visual Streak", "apple")

VisualTab:AddInput("FakeStreaks", {
    Title = "Fake Streaks",
    Description = "Set fake streak value",
    Default = "",
    Placeholder = "Enter streak value",
    Numeric = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            pcall(function()
                LocalPlayer:SetAttribute("Streak", num)
                if Fluent and Fluent.Notify then
                    Fluent:Notify({
                        Title = "Streak",
                        Content = string.format("Streak set to %d", num),
                        Duration = 3
                    })
                end
            end)
        end
    end
})

-- Cosmetics swap di VisualTab
VisualTab:AddSection("cosmetics changer", "apple")

local cosmetic1 = ""
local cosmetic2 = ""
local originalCosmetic1 = ""
local originalCosmetic2 = ""
local isSwapped = false

VisualTab:AddInput("CurrentCosmetics", {
    Title = "Current Cosmetics",
    Description = "Enter current cosmetic name",
    Default = "",
    Placeholder = "Enter current cosmetic name",
    Callback = function(v)
        cosmetic1 = v
        if not isSwapped then
            originalCosmetic1 = v
        end
    end
})

VisualTab:AddSection("Select", "apple")

VisualTab:AddInput("SelectCosmetics", {
    Title = "Select Cosmetics",
    Description = "Enter cosmetic to swap with",
    Default = "ToxicInferno",
    Placeholder = "Enter cosmetic to swap with",
    Callback = function(v)
        cosmetic2 = v
        if not isSwapped then
            originalCosmetic2 = v
        end
    end
})

VisualTab:AddButton({
    Title = "Apply Cosmetics",
    Description = "Swap cosmetics",
    Callback = function()
        pcall(function()
            if cosmetic1 == "" or cosmetic2 == "" or cosmetic1 == cosmetic2 then
                return
            end
            
            local Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")
            
            function normalize(str)
                return str:gsub("%s+", ""):lower()
            end
            
            function levenshtein(s, t)
                local m, n = #s, #t
                local d = {}
                for i = 0, m do
                    d[i] = {[0] = i}
                end
                for j = 0, n do
                    d[0][j] = j
                end
                for i = 1, m do
                    for j = 1, n do
                        local cost = (s:sub(i,i) == t:sub(j,j)) and 0 or 1
                        d[i][j] = math.min(
                            d[i-1][j] + 1,
                            d[i][j-1] + 1,
                            d[i-1][j-1] + cost
                        )
                    end
                end
                return d[m][n]
            end
            
            function similarity(s, t)
                local nS, nT = normalize(s), normalize(t)
                local dist = levenshtein(nS, nT)
                return 1 - dist / math.max(#nS, #nT)
            end
            
            function findSimilar(name)
                local bestMatch = name
                local bestScore = 0.5
                for _, c in ipairs(Cosmetics:GetChildren()) do
                    local score = similarity(name, c.Name)
                    if score > bestScore then
                        bestScore = score
                        bestMatch = c.Name
                    end
                end
                return bestMatch
            end
            
            cosmetic1 = findSimilar(cosmetic1)
            cosmetic2 = findSimilar(cosmetic2)
            
            local a = Cosmetics:FindFirstChild(cosmetic1)
            local b = Cosmetics:FindFirstChild(cosmetic2)
            
            if not a or not b then
                return
            end
            
            if not isSwapped then
                originalCosmetic1 = cosmetic1
                originalCosmetic2 = cosmetic2
            end
            
            local tempRoot = Instance.new("Folder", Cosmetics)
            tempRoot.Name = "__temp_swap_" .. tostring(tick()):gsub("%.", "_")
            
            local tempA = Instance.new("Folder", tempRoot)
            local tempB = Instance.new("Folder", tempRoot)
            
            for _, c in ipairs(a:GetChildren()) do
                c.Parent = tempA
            end
            
            for _, c in ipairs(b:GetChildren()) do
                c.Parent = tempB
            end
            
            for _, c in ipairs(tempA:GetChildren()) do
                c.Parent = b
            end
            
            for _, c in ipairs(tempB:GetChildren()) do
                c.Parent = a
            end
            
            tempRoot:Destroy()
            isSwapped = true
        end)
    end
})

VisualTab:AddButton({
    Title = "Reset Cosmetics",
    Description = "Reset swapped cosmetics",
    Callback = function()
        pcall(function()
            if not isSwapped then
                return
            end
            
            if originalCosmetic1 == "" or originalCosmetic2 == "" then
                return
            end
            
            local Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")
            
            function normalize(str)
                return str:gsub("%s+", ""):lower()
            end
            
            function findSimilar(name)
                for _, c in ipairs(Cosmetics:GetChildren()) do
                    if normalize(c.Name) == normalize(name) then
                        return c.Name
                    end
                end
                return name
            end
            
            local resetCosmetic1 = findSimilar(originalCosmetic1)
            local resetCosmetic2 = findSimilar(originalCosmetic2)
            
            local a = Cosmetics:FindFirstChild(cosmetic1)
            local b = Cosmetics:FindFirstChild(cosmetic2)
            
            if a and b then
                local tempRoot = Instance.new("Folder", Cosmetics)
                tempRoot.Name = "__temp_reset_" .. tostring(tick()):gsub("%.", "_")
                
                local tempA = Instance.new("Folder", tempRoot)
                local tempB = Instance.new("Folder", tempRoot)
                
                for _, c in ipairs(a:GetChildren()) do
                    c.Parent = tempA
                end
                
                for _, c in ipairs(b:GetChildren()) do
                    c.Parent = tempB
                end
                
                for _, c in ipairs(tempA:GetChildren()) do
                    c.Parent = b
                end
                
                for _, c in ipairs(tempB:GetChildren()) do
                    c.Parent = a
                end
                
                tempRoot:Destroy()
                isSwapped = false
            end
        end)
    end
})

VisualTab:AddSection("Emote visual", "apple")

local emoteModelScript = nil
local originalEmoteData = {}
local replacementEnabled = false
local emoteDataSaved = false
local emoteFrame = nil
local currentTag = nil
local currentEmotes = {}
local selectEmotes = {}
local currentEmoteInputs = {}
local selectEmoteInputs = {}
local allEmotesList = {}

for i = 1, 12 do
    currentEmotes[i] = ""
    selectEmotes[i] = ""
end

local Events = ReplicatedStorage:WaitForChild("Events", 10)
local CharacterFolder = Events and Events:WaitForChild("Character", 10)
local EmoteRemote = CharacterFolder and CharacterFolder:WaitForChild("Emote", 10)
local PassCharacterInfo = CharacterFolder and CharacterFolder:WaitForChild("PassCharacterInfo", 10)
local remoteSignal = PassCharacterInfo and PassCharacterInfo.OnClientEvent

local emoteNameCache = {}
local normalizedCache = {}

local function loadAllEmotes()
    local emotesFolder = ReplicatedStorage:FindFirstChild("Items")
    if emotesFolder then
        emotesFolder = emotesFolder:FindFirstChild("Emotes")
        if emotesFolder then
            for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
                if emoteModule:IsA("ModuleScript") then
                    local success, emoteData = pcall(require, emoteModule)
                    if success and emoteData and emoteData.AppearanceInfo then
                        local displayName = emoteData.AppearanceInfo.NameShorted or emoteData.AppearanceInfo.Name
                        table.insert(allEmotesList, {
                            moduleName = emoteModule.Name,
                            displayName = displayName,
                            normalized = string.lower(displayName:gsub("%s+", ""))
                        })
                    end
                end
            end
        end
    end
end
loadAllEmotes()

local function searchEmote(partialName)
    if partialName == "" then return nil end
    local normalizedSearch = string.lower(partialName:gsub("%s+", ""))
    
    for _, emote in ipairs(allEmotesList) do
        if emote.normalized:find(normalizedSearch, 1, true) then
            return emote.displayName
        end
    end
    
    return nil
end

function fireSelect(emoteName)
    if not currentTag then return end
    local tagNumber = tonumber(currentTag)
    if not tagNumber or tagNumber < 0 or tagNumber > 255 then return end
    if not emoteName or emoteName == "" then return end
    
    local bufferData = buffer.create(2)
    buffer.writeu8(bufferData, 0, tagNumber)
    buffer.writeu8(bufferData, 1, 17)
    
    if remoteSignal then
        firesignal(remoteSignal, bufferData, {emoteName})
    end
end

function setupAnimationListener()
    function setupHumanoidListeners(char)
        local isR15 = char:GetAttribute("R15") == true
        local humanoid
        
        if isR15 then
            local r15Visual = char:WaitForChild("R15Visual", 5)
            if r15Visual then
                humanoid = r15Visual:WaitForChild("Visual_Humanoid", 5)
            end
        else
            humanoid = char:WaitForChild("Humanoid", 5)
        end
        
        if humanoid then
            humanoid.AnimationPlayed:Connect(function(track)
                local animation = track.Animation
                if animation and animation:IsDescendantOf(ReplicatedStorage.Items.Emotes) then
                    local emoteModule = animation:FindFirstAncestorWhichIsA("ModuleScript")
                    if emoteModule then
                        local currentEmoteName = emoteModule.Name
                        for i = 1, 12 do
                            if currentEmotes[i] ~= "" and selectEmotes[i] ~= "" then
                                local normalizedCurrent = normalizeText(currentEmotes[i])
                                local normalizedPlaying = normalizeText(currentEmoteName)
                                if normalizedCurrent == normalizedPlaying then
                                    fireSelect(selectEmotes[i])
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    if player.Character then
        setupHumanoidListeners(player.Character)
    end

    player.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        setupHumanoidListeners(newChar)
    end)
end

setupAnimationListener()

function findEmoteModelScript()
    if emoteModelScript then return emoteModelScript end
    
    for _, script in pairs(player.PlayerScripts:GetDescendants()) do
        if script.Name == "EmoteModel" then
            emoteModelScript = script
            return script
        end
    end
    
    for _, script in pairs(ReplicatedStorage:GetDescendants()) do
        if script.Name == "EmoteModel" then
            emoteModelScript = script
            return script
        end
    end
    
    return nil
end

function normalizeText(text)
    if not text then return "" end
    if not normalizedCache[text] then
        normalizedCache[text] = string.lower(text:gsub("%s+", ""))
    end
    return normalizedCache[text]
end

function findEmoteModuleByDisplayName(displayName)
    if displayName == "NONE" or not displayName then return nil end
    
    if emoteNameCache[displayName] ~= nil then
        return emoteNameCache[displayName]
    end
    
    local emotesFolder = ReplicatedStorage:FindFirstChild("Items")
    if not emotesFolder then 
        emoteNameCache[displayName] = nil 
        return nil 
    end
    
    emotesFolder = emotesFolder:FindFirstChild("Emotes")
    if not emotesFolder then 
        emoteNameCache[displayName] = nil 
        return nil 
    end
    
    local normalizedDisplayName = normalizeText(displayName)
    
    for _, emoteModule in pairs(emotesFolder:GetChildren()) do
        local success, emoteData = pcall(require, emoteModule)
        if success and emoteData then
            local emoteDisplayName = emoteData.AppearanceInfo.NameShorted or emoteData.AppearanceInfo.Name
            if normalizeText(emoteDisplayName) == normalizedDisplayName then
                emoteNameCache[displayName] = emoteModule.Name
                return emoteModule.Name
            end
        end
    end
    
    emoteNameCache[displayName] = nil
    return nil
end

function getEmoteFrame()
    local playerGui = player.PlayerGui
    local shared = playerGui and playerGui:FindFirstChild("Shared")
    local hud = shared and shared:FindFirstChild("HUD")
    local interactors = hud and hud:FindFirstChild("Interactors")
    local popups = interactors and interactors:FindFirstChild("Popups")
    return popups and popups:FindFirstChild("Emote")
end

function cleanUpLastEmoteFrame()
    if emoteFrame then
        emoteFrame = nil
    end
end

function restoreOriginalEmotes()
    if not emoteModelScript then findEmoteModelScript() end
    if not emoteModelScript or not emoteFrame then return end
    
    local emoteModelFunction = require(emoteModelScript)
    local emoteWheel = emoteFrame:FindFirstChild("Wheel")
    local emoteWheel2 = emoteFrame:FindFirstChild("Wheel2")
    
    if not emoteWheel then return end
    
    function processSlot(emoteSlot, key)
        if not emoteSlot then return end
        local textLabel = emoteSlot:FindFirstChild("TextLabel")
        local viewportFrame = emoteSlot:FindFirstChild("ViewportFrame")
        
        if textLabel and viewportFrame then
            local original = originalEmoteData[key]
            if original then
                if viewportFrame:FindFirstChild("WorldModel") then
                    viewportFrame.WorldModel:Destroy()
                end
                
                if original.displayText ~= "NONE" and original.emoteName then
                    local emoteModule = ReplicatedStorage.Items.Emotes:FindFirstChild(original.emoteName)
                    if emoteModule then
                        emoteModelFunction(viewportFrame, original.emoteName)
                    end
                    textLabel.Text = original.displayText
                else
                    textLabel.Text = "NONE"
                end
            end
        end
    end
    
    for i = 1, 6 do
        processSlot(emoteWheel:FindFirstChild("Emote"..i), "Wheel_Emote"..i)
    end
    
    if emoteWheel2 then
        for i = 1, 6 do
            processSlot(emoteWheel2:FindFirstChild("Emote"..i), "Wheel2_Emote"..i)
        end
    end
end

function replaceEmotesFrame()
    if not replacementEnabled or not emoteDataSaved or not emoteFrame then return false end
    
    if not emoteModelScript then findEmoteModelScript() end
    if not emoteModelScript then return false end
    
    local emoteModelFunction = require(emoteModelScript)
    local emoteWheel = emoteFrame:FindFirstChild("Wheel")
    local emoteWheel2 = emoteFrame:FindFirstChild("Wheel2")
    
    if not emoteWheel then return false end
    
    local anyPairsConfigured = false
    
    function processEmoteSlot(emoteSlot, wheelName, i)
        if not emoteSlot then return end
        
        local textLabel = emoteSlot:FindFirstChild("TextLabel")
        if not textLabel then return end
        
        local currentText = textLabel.Text
        local normalizedCurrent = normalizeText(currentText)
        
        for j = 1, 12 do
            local searchEmote = currentEmotes[j]
            local replaceEmote = selectEmotes[j]
            
            if searchEmote ~= "" and replaceEmote ~= "" then
                anyPairsConfigured = true
                
                if normalizedCurrent == normalizeText(searchEmote) then
                    local viewportFrame = emoteSlot.ViewportFrame
                    if viewportFrame then
                        local replacementModule = ReplicatedStorage.Items.Emotes:FindFirstChild(replaceEmote)
                        if replacementModule then
                            local key = wheelName.."_Emote"..i
                            
                            if not originalEmoteData[key] then
                                originalEmoteData[key] = {
                                    displayText = currentText,
                                    emoteName = findEmoteModuleByDisplayName(currentText) or currentText
                                }
                            end
                            
                            if viewportFrame:FindFirstChild("WorldModel") then
                                viewportFrame.WorldModel:Destroy()
                            end
                            
                            local targetEmoteModule = require(replacementModule)
                            local targetDisplayName = targetEmoteModule.AppearanceInfo.NameShorted or targetEmoteModule.AppearanceInfo.Name
                            
                            emoteModelFunction(viewportFrame, replaceEmote)
                            textLabel.Text = targetDisplayName
                        end
                    end
                    break
                end
            end
        end
    end
    
    for i = 1, 6 do
        processEmoteSlot(emoteWheel:FindFirstChild("Emote"..i), "Wheel", i)
    end
    
    if emoteWheel2 then
        for i = 1, 6 do
            processEmoteSlot(emoteWheel2:FindFirstChild("Emote"..i), "Wheel2", i)
        end
    end
    
    return anyPairsConfigured
end

function saveOriginalEmoteData(frame)
    if not frame then return end
    
    originalEmoteData = {}
    local emoteWheel = frame:FindFirstChild("Wheel")
    local emoteWheel2 = frame:FindFirstChild("Wheel2")
    
    if not emoteWheel then return end
    
    function saveSlot(emoteSlot, key)
        if not emoteSlot then return end
        local textLabel = emoteSlot:FindFirstChild("TextLabel")
        if textLabel then
            originalEmoteData[key] = {
                displayText = textLabel.Text,
                emoteName = findEmoteModuleByDisplayName(textLabel.Text) or textLabel.Text
            }
        end
    end
    
    for i = 1, 6 do
        saveSlot(emoteWheel:FindFirstChild("Emote"..i), "Wheel_Emote"..i)
    end
    
    if emoteWheel2 then
        for i = 1, 6 do
            saveSlot(emoteWheel2:FindFirstChild("Emote"..i), "Wheel2_Emote"..i)
        end
    end
    
    emoteDataSaved = true
end

function readTagFromFolder(folder)
    if not folder then return nil end
    
    local attributeValue = folder:GetAttribute("Tag")
    if attributeValue ~= nil then return attributeValue end
    
    local tagValue = folder:FindFirstChild("Tag")
    if tagValue and tagValue:IsA("ValueBase") then
        return tagValue.Value
    end
    
    return nil
end

local respawnInProgress = false
local lastRespawnTime = 0
local reapplyThread = nil

function cleanupOnRespawn()
    currentTag = nil
    emoteFrame = nil
    if reapplyThread then
        task.cancel(reapplyThread)
        reapplyThread = nil
    end
end

function handleSingleRespawn()
    local now = tick()
    if respawnInProgress and (now - lastRespawnTime) < 2 then return end
    
    respawnInProgress = true
    lastRespawnTime = now
    cleanupOnRespawn()
    
    task.spawn(function()
        local startTime = tick()
        while tick() - startTime < 10 do
            if workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players") then
                local playerFolder = workspace.Game.Players:FindFirstChild(player.Name)
                if playerFolder then
                    currentTag = readTagFromFolder(playerFolder)
                    if currentTag then
                        local tagNumber = tonumber(currentTag)
                        if tagNumber and tagNumber >= 0 and tagNumber <= 255 then
                            break
                        end
                    end
                end
            end
            task.wait(0.1)
        end
        respawnInProgress = false
    end)
    
    if replacementEnabled and emoteDataSaved then
        if reapplyThread then
            task.cancel(reapplyThread)
            reapplyThread = nil
        end
        
        reapplyThread = task.delay(1.5, function()
            if not replacementEnabled or not emoteDataSaved then return end
            
            for attempts = 1, 30 do
                emoteFrame = getEmoteFrame()
                if emoteFrame then
                    saveOriginalEmoteData(emoteFrame)
                    restoreOriginalEmotes()
                    replaceEmotesFrame()
                    break
                end
                task.wait(0.1)
            end
        end)
    end
end

-- Emote inputs di VisualTab
for i = 1, 12 do
    VisualTab:AddInput("CurrentEmote" .. i, {
        Title = "Current Emote " .. i,
        Description = "Type emote name...",
        Default = currentEmotes[i],
        Placeholder = "Type emote name...",
        Callback = function(v)
            local cleaned = v:gsub("%s+", "")
            currentEmotes[i] = cleaned
            if cleaned ~= "" then
                searchEmote(cleaned)
            end
        end
    })
end

VisualTab:AddSection("Select", "apple")

for i = 1, 12 do
    VisualTab:AddInput("SelectEmote" .. i, {
        Title = "Select Emote " .. i,
        Description = "Type emote name to replace with...",
        Default = selectEmotes[i],
        Placeholder = "Type emote name...",
        Callback = function(v)
            local cleaned = v:gsub("%s+", "")
            selectEmotes[i] = cleaned
            if cleaned ~= "" then
                searchEmote(cleaned)
            end
        end
    })
end

VisualTab:AddInput("EmoteOption", {
    Title = "Emote Possible option",
    Description = "Use 1-3 (0 or 'Random' for random)",
    Default = "0",
    Placeholder = "0",
    Numeric = true,
    Callback = function(v)
        local currentNum = v:lower() == "random" and "Random" or tonumber(v) or 0
        
        function setupCharacter(char)
            if char == player.Character then
                char:SetAttribute("EmoteNum", currentNum == "Random" and math.random(1, 3) or currentNum)
            end
        end
        
        function monitorCharacter()
            while true do
                task.wait(1)
                local char = player.Character
                if char and char:GetAttribute("EmoteNum") ~= currentNum then
                    char:SetAttribute("EmoteNum", currentNum == "Random" and math.random(1, 3) or currentNum)
                end
            end
        end
        
        if player.Character then
            setupCharacter(player.Character)
        end
        
        player.CharacterAdded:Connect(function(char)
            task.wait(1)
            setupCharacter(char)
        end)
        
        task.spawn(monitorCharacter)
    end
})

VisualTab:AddToggle("ReplaceEmoteWheel", {
    Title = "Enable replace emote wheel",
    Description = "Toggle emote wheel replacement",
    Default = true,
    Callback = function(state)
        replacementEnabled = state
        
        if emoteFrame and emoteDataSaved then
            restoreOriginalEmotes()
        end
        
        if replacementEnabled and emoteFrame and emoteDataSaved then
            replaceEmotesFrame()
        end
    end
})

VisualTab:AddButton({
    Title = "Apply Emote Mappings",
    Description = "Apply current emote mappings",
    Callback = function()
        local hasAnyEmote = false
        for i = 1, 12 do
            if currentEmotes[i] ~= "" or selectEmotes[i] ~= "" then
                hasAnyEmote = true
                break
            end
        end
        
        if not hasAnyEmote then
            return
        end
        
        function normalizeEmoteName(name)
            return name:gsub("%s+", ""):lower()
        end
        
        function isValidEmote(emoteName)
            if emoteName == "" then return false, "" end
            
            local normalizedInput = normalizeEmoteName(emoteName)
            local emotesFolder = ReplicatedStorage:FindFirstChild("Items")
            
            if emotesFolder then
                emotesFolder = emotesFolder:FindFirstChild("Emotes")
                if emotesFolder then
                    for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
                        if emoteModule:IsA("ModuleScript") then
                            if normalizeEmoteName(emoteModule.Name) == normalizedInput then
                                return true, emoteModule.Name
                            end
                        end
                    end
                end
            end
            
            return false, ""
        end
        
        local sameEmoteSlots = {}
        local missingEmoteSlots = {}
        local invalidEmoteSlots = {}
        local successfulSlots = {}
        
        for i = 1, 12 do
            if currentEmotes[i] ~= "" and selectEmotes[i] ~= "" then
                local currentValid, currentActual = isValidEmote(currentEmotes[i])
                local selectValid, selectActual = isValidEmote(selectEmotes[i])
                
                if not currentValid and not selectValid then
                    table.insert(invalidEmoteSlots, {
                        slot = i,
                        currentName = currentEmotes[i],
                        selectName = selectEmotes[i]
                    })
                elseif not currentValid then
                    table.insert(invalidEmoteSlots, {
                        slot = i,
                        currentName = currentEmotes[i]
                    })
                elseif not selectValid then
                    table.insert(invalidEmoteSlots, {
                        slot = i,
                        selectName = selectEmotes[i]
                    })
                elseif currentActual:lower() == selectActual:lower() then
                    table.insert(sameEmoteSlots, i)
                else
                    table.insert(successfulSlots, i)
                end
            elseif currentEmotes[i] ~= "" or selectEmotes[i] ~= "" then
                table.insert(missingEmoteSlots, i)
            end
        end
        
        emoteNameCache = {}
        normalizedCache = {}
        
        cleanUpLastEmoteFrame()
        emoteFrame = getEmoteFrame()
        
        if not emoteFrame then
            return
        end
        
        saveOriginalEmoteData(emoteFrame)
        restoreOriginalEmotes()
        
        if replacementEnabled then
            replaceEmotesFrame()
        end
    end
})

VisualTab:AddButton({
    Title = "Reset All Emotes",
    Description = "Reset all emote mappings",
    Callback = function()
        if emoteFrame then
            restoreOriginalEmotes()
        end
        
        for i = 1, 12 do
            currentEmotes[i] = ""
            selectEmotes[i] = ""
        end
        
        emoteNameCache = {}
        normalizedCache = {}
        cleanUpLastEmoteFrame()
    end
})

if player.Character then
    task.spawn(handleSingleRespawn)
end

player.CharacterAdded:Connect(function()
    task.wait(1)
    handleSingleRespawn()
end)

if workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players") then
    workspace.Game.Players.ChildAdded:Connect(function(child)
        if child.Name == player.Name then
            task.wait(0.5)
            handleSingleRespawn()
        end
    end)
    
    workspace.Game.Players.ChildRemoved:Connect(function(child)
        if child.Name == player.Name then
            currentTag = nil
            cleanUpLastEmoteFrame()
        end
    end)
end

-- Anti AFK di MiscTab
getgenv().AntiAFKEnabled = false
local virtualUser = game:GetService("VirtualUser")

local function startAntiAFK()
    getgenv().AntiAFKEnabled = true
    LocalPlayer.Idled:Connect(function()
        if getgenv().AntiAFKEnabled then
            virtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            virtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)
end

AutoFarmsTab:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Description = "Prevent being kicked for AFK",
    Default = false,
    Callback = function(state)
        getgenv().AntiAFKEnabled = state
        if state then startAntiAFK() end
    end
})


AutoFarmsTab:AddSection("Lupen Farm")

local AutoLupenConnection
local AutoLupenEnabled = false
local RotationAngle = 0
local RotationRadius = 1.2
local RotationSpeed = 8

local function findLupen()
    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if not gamePlayers then return end
    local lupen = gamePlayers:FindFirstChild("Lupen")
    if not lupen then
        for _,v in pairs(gamePlayers:GetChildren()) do
            if string.find(v.Name:lower(),"lupen") then
                lupen = v
                break
            end
        end
    end
    return lupen
end

local function startAutoLupen()
    if AutoLupenConnection then return end
    RotationAngle = 0
    AutoLupenConnection = game.RunService.Heartbeat:Connect(function()
        if not AutoLupenEnabled then return end
        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if character:GetAttribute("Downed") then
            pcall(function()
                game.ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end)
            return
        end
        local lupen = findLupen()
        if not lupen then return end
        local lupenHRP = lupen:FindFirstChild("HumanoidRootPart")
        if not lupenHRP then return end
        RotationAngle = (RotationAngle + RotationSpeed) % 360
        local rad = math.rad(RotationAngle)
        local offset = Vector3.new(math.cos(rad) * RotationRadius,1.5,math.sin(rad) * RotationRadius)
        local targetPos = lupenHRP.Position + offset
        hrp.CFrame = CFrame.new(targetPos,lupenHRP.Position)
    end)
    Fluent:Notify({
        Title = "Auto Farm Lupen",
        Content = "Following Lupen...",
        Duration = 3
    })
end

local function stopAutoLupen()
    if AutoLupenConnection then
        AutoLupenConnection:Disconnect()
        AutoLupenConnection = nil
    end
    Fluent:Notify({
        Title = "Auto Farm Lupen",
        Content = "Stopped.",
        Duration = 3
    })
end

AutoFarmsTab:AddToggle("AutoLupenToggle", {
    Title = "Auto Farm Lupen",
    Default = false,
    Callback = function(state)
        AutoLupenEnabled = state
        if state then
            startAutoLupen()
        else
            stopAutoLupen()
        end
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    if AutoLupenEnabled then
        task.wait(1)
        stopAutoLupen()
        startAutoLupen()
    end
end)

-- Auto Farms di AutoFarmsTab
getgenv().AutoTicketFarm = false

AutoFarmsTab:AddToggle("AutoTicketFarm", {
    Title = "Auto Ticket Farm",
    Description = "Automatically collect tickets",
    Default = false,
    Callback = function(state)
        getgenv().AutoTicketFarm = state
    end
})

RunService.Heartbeat:Connect(function()
    if getgenv().AutoTicketFarm then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local tickets = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Effects") and workspace.Game.Effects:FindFirstChild("Tickets")
        
        if char and hrp then
            if char:GetAttribute("Downed") then
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                return
            end
            
            if tickets and #tickets:GetChildren() > 0 then
                local ticket = tickets:GetChildren()[1]:FindFirstChild("HumanoidRootPart")
                if ticket then hrp.CFrame = CFrame.new(ticket.Position) end
            end
        end
    end
end)

getgenv().AutoMoneyFarm = false

AutoFarmsTab:AddToggle("AutoMoneyFarm", {
    Title = "Auto Money Farm",
    Description = "Automatically farm money",
    Default = false,
    Callback = function(state)
        getgenv().AutoMoneyFarm = state
    end
})

RunService.Heartbeat:Connect(function()
    if getgenv().AutoMoneyFarm then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if char and hrp then
            if char:GetAttribute("Downed") then
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                return
            end
            
            local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
            if playersFolder then
                for _, player in pairs(playersFolder:GetChildren()) do
                    if player:GetAttribute("Downed") and player.Name ~= LocalPlayer.Name then
                        local targetHrp = player:FindFirstChild("HumanoidRootPart")
                        if targetHrp and (hrp.Position - targetHrp.Position).Magnitude < 20 then
                            ReplicatedStorage.Events.Character.Interact:FireServer("Revive", true, player.Name)
                        end
                    end
                end
            end
        end
    end
end)

-- Bounce Multiplier di MiscTab
BounceSystem = BounceSystem or {} 
BounceSystem.Config = BounceSystem.Config or { 
    Enabled = false, 
    VelocityMultiplier = 80 
}

local bouncing = false
local climbTime = 0
local bouncePower = BounceSystem.Config.VelocityMultiplier
local connection = nil

local function startBouncing(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    bouncing = true
    climbTime = tick()
    
    if connection then connection:Disconnect() end
    
    connection = RunService.Heartbeat:Connect(function()
        if not bouncing or not character or not character.Parent then
            if connection then
                connection:Disconnect()
                connection = nil
            end
            return
        end
        
        local currentState = humanoid:GetState()
        if currentState == Enum.HumanoidStateType.Climbing then
            rootPart.Velocity = Vector3.new(rootPart.Velocity.X, bouncePower, rootPart.Velocity.Z)
        end
    end)
end

local function stopBouncing()
    bouncing = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

local function setupBounce(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Climbing then
            if BounceSystem.Config.Enabled then
                startBouncing(character)
            end
        elseif oldState == Enum.HumanoidStateType.Climbing and newState ~= Enum.HumanoidStateType.Climbing then
            stopBouncing()
        end
    end)
    
    humanoid.Climbing:Connect(function()
        if BounceSystem.Config.Enabled then
            startBouncing(character)
        end
    end)
end

MiscTab:AddToggle("BounceMultiplier", {
    Title = "Bounce Multiplier",
    Description = "Enable bounce multiplier on climbing",
    Default = false,
    Callback = function(state)
        BounceSystem.Config.Enabled = state
        if state then
            if LocalPlayer.Character then
                setupBounce(LocalPlayer.Character)
            end
        else
            stopBouncing()
        end
    end
})

MiscTab:AddInput("BounceValue", {
    Title = "Multiplier value",
    Description = "Set bounce multiplier value",
    Default = tostring(BounceSystem.Config.VelocityMultiplier),
    Placeholder = "80",
    Numeric = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            BounceSystem.Config.VelocityMultiplier = num
            bouncePower = num
        end
    end
})

if LocalPlayer.Character then
    setupBounce(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupBounce)

-- Performance options di MiscTab
ExtensionTab:AddButton({
    Title = "Clear Invis Walls",
    Description = "Remove invisible walls",
    Callback = function()
        local gameFolder = workspace:FindFirstChild("Game")
        if not gameFolder then return end
        
        local mapFolder = gameFolder:FindFirstChild("Map")
        if not mapFolder then return end
        
        local invisPartsFolder = mapFolder:FindFirstChild("InvisParts")
        if not invisPartsFolder then return end

        for _, obj in ipairs(invisPartsFolder:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = false
            end
        end
    end
})

ExtensionTab:AddButton({
    Title = "Lower Chunks",
    Description = "Reduces the streaming radius for performance improvement",
    Callback = function()
        workspace.StreamingMinRadius = 200
        workspace.StreamingTargetRadius = 500
    end
})

ExtensionTab:AddButton({
    Title = "Disable VSync",
    Description = "Disables vertical sync to allow higher FPS",
    Callback = function()
        setfpscap(9999)
    end
})

ExtensionTab:AddButton({
    Title = "Set FPS Cap Max",
    Description = "Sets the FPS cap to a very high value",
    Callback = function()
        setfpscap(99999)
    end
})

ExtensionTab:AddButton({
    Title = "Hide Skybox",
    Description = "Removes the skybox for better performance",
    Callback = function()
        game.Lighting.Sky = nil
    end
})

ExtensionTab:AddButton({
    Title = "Disable Shadows",
    Description = "Disables all shadows in the workspace",
    Callback = function()
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
            end
        end
    end
})

ExtensionTab:AddButton({
    Title = "Set Low Graphics",
    Description = "Sets the rendering quality to low",
    Callback = function()
        settings().Rendering.QualityLevel = 1
    end
})

ExtensionTab:AddButton({
    Title = "Disable Particles",
    Description = "Removes all particle effects from the game",
    Callback = function()
        for _, particle in pairs(workspace:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle:Destroy()
            end
        end
    end
})

ExtensionTab:AddButton({
    Title = "Night",
    Description = "Sets the time to night (00:00)",
    Callback = function()
        game.Lighting.TimeOfDay = "00:00:00"
    end
})

ExtensionTab:AddButton({
    Title = "Day",
    Description = "Sets the time to morning (08:00)",
    Callback = function()
        game.Lighting.TimeOfDay = "08:00:00"
    end
})

ExtensionTab:AddButton({
    Title = "Anti Fog",
    Description = "Removes fog for better visibility",
    Callback = function()
        local L = game.Lighting
        L.FogStart = 1e5
        L.FogEnd = 1e6
    end
})

ExtensionTab:AddButton({
    Title = "Low Poly Mode",
    Description = "Converts meshes to low-poly for performance",
    Callback = function()
        for _, p in pairs(workspace:GetDescendants()) do
            if p:IsA("MeshPart") or p:IsA("UnionOperation") then
                p.Material = Enum.Material.Plastic
                p.RenderFidelity = Enum.RenderFidelity.Performance
            end
        end
    end
})

ExtensionTab:AddButton({
    Title = "Disable Simplify Lighting",
    Description = "Disables lighting simplifications for custom settings",
    Callback = function()
        local L = game.Lighting
        L.Technology = Enum.Technology.Compatibility
        L.ShadowSoftness = 0
        L.EnvironmentDiffuseScale = 0
        L.EnvironmentSpecularScale = 0
    end
})

ExtensionTab:AddButton({
    Title = "Hide Useless Chunks",
    Description = "Reduces streaming of unnecessary chunks",
    Callback = function()
        workspace.StreamingMinRadius = 0
        workspace.StreamingTargetRadius = 500
    end
})

ExtensionTab:AddButton({
    Title = "Reduce Anti-Aliasing",
    Description = "Reduces anti-aliasing for performance",
    Callback = function()
        game:GetService("Rendering"):SetCore("AntiAliasing", Enum.AntiAliasingLevel.Two)
    end
})

ExtensionTab:AddButton({
    Title = "Low Quality",
    Description = "Set all graphics to low quality",
    Callback = function()
        local ToDisable = {
            Textures = true,
            VisualEffects = true,
            Parts = true,
            Particles = true,
            Sky = true
        }
        
        for _, v in next, game:GetDescendants() do
            if ToDisable.Parts then
                if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                end
            end
            
            if ToDisable.Particles then
                if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then
                    v.Enabled = false
                end
            end
            
            if ToDisable.VisualEffects then
                if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                end
            end
            
            if ToDisable.Textures then
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Texture = ""
                end
            end
            
            if ToDisable.Sky then
                if v:IsA("Sky") then
                    v.Parent = nil
                end
            end
        end
        
        if Fluent and Fluent.Notify then
            Fluent:Notify({
                Title = "Low Quality",
                Content = "Graphics settings optimized for performance",
                Duration = 3
            })
        end
    end
})

ExtensionTab:AddButton({
    Title = "Remove Texture",
    Description = "Remove all textures",
    Callback = function()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("WedgePart") or part:IsA("CornerWedgePart") then
                if part:IsA("Part") then
                    part.Material = Enum.Material.SmoothPlastic
                end
                if part:FindFirstChildWhichIsA("Texture") then
                    local texture = part:FindFirstChildWhichIsA("Texture")
                    texture.Texture = "rbxassetid://0"
                end
                if part:FindFirstChildWhichIsA("Decal") then
                    local decal = part:FindFirstChildWhichIsA("Decal")
                    decal.Texture = "rbxassetid://0"
                end
            end
        end
        
        if Fluent and Fluent.Notify then
            Fluent:Notify({
                Title = "Remove Texture",
                Content = "All textures have been removed",
                Duration = 3
            })
        end
    end
})

ExtensionTab:AddToggle("RemoveFog", {
    Title = "Remove fog",
    Description = "Toggle fog removal",
    Default = false,
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        if state then
            getgenv().featureStates.originalFogEnd = Lighting.FogEnd
            getgenv().featureStates.originalAtmospheres = {}
            
            for _, atmosphere in ipairs(Lighting:GetChildren()) do
                if atmosphere:IsA("Atmosphere") then
                    table.insert(getgenv().featureStates.originalAtmospheres, atmosphere:Clone())
                end
            end
            
            Lighting.FogEnd = 1000000
            for _, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("Atmosphere") then
                    v:Destroy()
                end
            end
            
            if Fluent and Fluent.Notify then
                Fluent:Notify({
                    Title = "Remove Fog",
                    Content = "Fog has been removed",
                    Duration = 2
                })
            end
        else
            if getgenv().featureStates and getgenv().featureStates.originalFogEnd then
                Lighting.FogEnd = getgenv().featureStates.originalFogEnd
            end
            
            if getgenv().featureStates and getgenv().featureStates.originalAtmospheres then
                for _, atmosphere in ipairs(getgenv().featureStates.originalAtmospheres) do
                    if not atmosphere.Parent then
                        local newAtmosphere = Instance.new("Atmosphere")
                        for _, prop in pairs({"Density", "Offset", "Color", "Decay", "Glare", "Haze"}) do
                            if atmosphere[prop] then
                                newAtmosphere[prop] = atmosphere[prop]
                            end
                        end
                        newAtmosphere.Parent = Lighting
                    end
                end
            end
            
            if Fluent and Fluent.Notify then
                Fluent:Notify({
                    Title = "Remove Fog",
                    Content = "Fog has been restored",
                    Duration = 2
                })
            end
        end
    end
})

-- Save Manager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("VerokiHub")
SaveManager:SetFolder("VerokiHub/Configs")

InterfaceManager:BuildInterfaceSection(ConfigTab)
SaveManager:BuildConfigSection(ConfigTab)

print("Veroki Hub loaded successfully with Fluent UI :] !")
