-- Diablo Hub | Fixed
_G.EggESP = {}

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui         = game:GetService("CoreGui")

local LocalPlayer   = Players.LocalPlayer
local PlayerGui     = LocalPlayer:WaitForChild("PlayerGui")
local RenderedEggs  = workspace:WaitForChild("RenderedEggs")
local Plots         = workspace:WaitForChild("Plots")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local Eggs     = GameData:WaitForChild("Eggs")
local module   = require(Eggs)

-- Collect egg names dari module
local eggOptions = {"None"}
for k, _ in pairs(module) do
    if type(k) == "string" then
        table.insert(eggOptions, k)
    end
end

-- ─── State ───────────────────────────────────────────────
local espEnabled     = false
local autoFarmEnabled = false
local selectedFarmEggs = {}
local radarEnabled   = false
local selectedRadarEgg = "None"
local petSpeedVal    = 16
local jumpHeightVal  = 7.2
local instantAccel   = false
local petEnabled     = false

-- ─── ESP Helpers ─────────────────────────────────────────
local function clearESP()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name == "EggESP_BB" then
            gui:Destroy()
        end
    end
    _G.EggESP = {}
end

local function createESPFor(model)
    if not model:IsA("Model") then return end
    local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not primary then return end

    local bb = Instance.new("BillboardGui")
    bb.Name          = "EggESP_BB"
    bb.Adornee       = primary
    bb.Size          = UDim2.fromOffset(190, 42)
    bb.StudsOffset   = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop   = true
    bb.MaxDistance   = 100000
    bb.Enabled       = true
    bb.Parent        = PlayerGui

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size                   = UDim2.fromScale(1, 1)
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = 14
    lbl.TextColor3             = Color3.new(1, 1, 1)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3       = Color3.new(0, 0, 0)
    lbl.Text                   = model.Name
    lbl.Parent                 = bb

    _G.EggESP[model] = bb
end

local function scanAndBuildESP()
    clearESP()
    if not espEnabled then return end
    for _, desc in ipairs(RenderedEggs:GetDescendants()) do
        if desc:IsA("Model") and desc.PrimaryPart then
            createESPFor(desc)
        end
    end
end

-- Auto-update ESP text (distance)
RunService.RenderStepped:Connect(function()
    local hrp = LocalPlayer.Character and
                LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for model, bb in pairs(_G.EggESP) do
        if model and model.Parent and model.PrimaryPart then
            local dist = math.floor(
                (hrp.Position - model.PrimaryPart.Position).Magnitude
            )
            local lbl = bb:FindFirstChildWhichIsA("TextLabel")
            if lbl then
                lbl.Text = model.Name .. "\n[" .. dist .. " studs]"
            end
        else
            -- Model sudah hilang
            bb:Destroy()
            _G.EggESP[model] = nil
        end
    end
end)

-- Live update saat egg spawn/despawn
RenderedEggs.DescendantAdded:Connect(function(desc)
    task.defer(function()
        if espEnabled and desc:IsA("Model") and desc.PrimaryPart then
            createESPFor(desc)
        end
    end)
end)

RenderedEggs.DescendantRemoving:Connect(function(desc)
    if _G.EggESP[desc] then
        _G.EggESP[desc]:Destroy()
        _G.EggESP[desc] = nil
    end
end)

-- ─── Auto Farm Loop ──────────────────────────────────────
local function getPlayerPlot()
    local name = LocalPlayer.Name
    for _, plot in ipairs(Plots:GetChildren()) do
        local data = plot:FindFirstChild("Data")
        if data then
            local owner = data:FindFirstChild("Owner")
            if owner and owner.Value == name then
                local base = plot:FindFirstChild("Baseplate")
                return base
            end
        end
    end
end

local function autoFarmLoop()
    while autoFarmEnabled do
        local hrp = LocalPlayer.Character and
                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, desc in ipairs(RenderedEggs:GetDescendants()) do
                if not autoFarmEnabled then break end
                if desc:IsA("Model") and desc.PrimaryPart then
                    for _, chosen in ipairs(selectedFarmEggs) do
                        if desc.Name == chosen then
                            -- TP ke egg
                            hrp.CFrame = CFrame.new(
                                desc.PrimaryPart.Position + Vector3.new(0, 3, 0)
                            )
                            task.wait(0.3)

                            -- Trigger ProximityPrompt
                            local pp = desc:FindFirstChildWhichIsA(
                                "ProximityPrompt", true
                            )
                            if pp then
                                fireproximityprompt(pp)
                            end
                            task.wait(0.5)

                            -- Balik ke plot
                            local base = getPlayerPlot()
                            if base then
                                hrp.CFrame = CFrame.new(
                                    base.Position + Vector3.new(0, 5, 0)
                                )
                            end
                            task.wait(0.5)
                            break
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end

-- ─── Radar Loop ──────────────────────────────────────────
local radarConnection
local function startRadar()
    if radarConnection then
        radarConnection:Disconnect()
        radarConnection = nil
    end
    if not radarEnabled or selectedRadarEgg == "None" then return end

    radarConnection = RunService.RenderStepped:Connect(function()
        local hrp = LocalPlayer.Character and
                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local closest, closestDist = nil, math.huge
        for _, desc in ipairs(RenderedEggs:GetDescendants()) do
            if desc:IsA("Model") and desc.Name == selectedRadarEgg
               and desc.PrimaryPart then
                local d = (hrp.Position - desc.PrimaryPart.Position).Magnitude
                if d < closestDist then
                    closest     = desc
                    closestDist = d
                end
            end
        end

        -- Highlight closest
        if closest then
            -- (opsional) bisa tambahin arrow/highlight di sini
        end
    end)
end

-- ─── GUI Build ───────────────────────────────────────────
local response = game:HttpGet(
    "https://raw.githubusercontent.com/Methions/Airflow/refs/heads/main/Uploaded"
)
local Airflow = loadstring(response)()

local Window = Airflow:CreateWindow({
    Name   = "Diablo Hub",
    ConfigurationSaving = {
        Enabled    = false,
        FileName   = "default",
        FolderName = "EggScanner"
    },
    Home = {
        Name     = "Home",
        Desc     = "Egg scanner",
        Greeting = "Diablo Hub is ready.",
        Pages = {
            { Name = "Status",    Content = "Live egg ESP + auto collect.",         Icon = "activity"  },
            { Name = "Auto Farm", Content = "Select eggs, enable farm, it collects.", Icon = "crosshair" }
        },
        SectionName = "System info",
        Stats       = {"FPS","Ping","Executor","Game","Region","Time","Players","Uptime"},
        TimeFormat  = "%H:%M",
        Welcome     = "Hello, "
    },
    Icon   = "rbxthumb://type=Asset&id=108858394161442&w=150&h=150",
    KeepOnScreen  = true,
    Loading = {
        Text     = "Starting",
        Title    = "Diablo Hub",
        Duration = 1.4,
        Enabled  = true,
        Steps    = {"Preparing interface","Loading eggs","Almost there"}
    },
    LoadingSubtitle  = "Egg Farm",
    MaxNotifications = 4,
    MaxSize          = Vector2.new(1000, 700),
    MinSize          = Vector2.new(480, 360),
    OpenButton       = { Title = "Diablo Hub", Icon = "egg" },
    Parent           = CoreGui,
    Size             = UDim2.fromOffset(640, 480),
    ToggleUIKeybind  = "RightControl"
})

Window:Toggle(false)

-- ── Tab: Egg Farm ─────────────────────────────────────────
local TabFarm = Window:CreateTab({
    Name      = "Egg Farm",
    Desc      = "Egg ESP and auto farm",
    EmptyText = "Nothing here yet",
    Icon      = "egg",
    Pages = {
        {
            Name    = "Explanation",
            Content = "Select egg types, enable auto farm. Script TPs to egg, "
                   .. "activates ProximityPrompt, then returns to your plot.",
            Icon    = "info"
        }
    }
})

TabFarm:CreateToggle({
    Name         = "Egg ESP",
    Desc         = "Show all rendered eggs with distance label",
    CurrentValue = false,
    Callback     = function(state)
        espEnabled = state
        scanAndBuildESP()
    end
})

TabFarm:CreateDropdown({
    Name            = "Auto Farm Eggs",
    Desc            = "Select egg types to collect",
    CurrentOption   = {"None"},
    MultipleOptions = true,
    Options         = eggOptions,
    Callback        = function(selected)
        selectedFarmEggs = {}
        for _, v in ipairs(selected) do
            if v ~= "None" then
                table.insert(selectedFarmEggs, v)
            end
        end
    end
})

local farmStatusParagraph = TabFarm:CreateParagraph({
    Title   = "Auto Farm Status",
    Content = "Disabled"
})

TabFarm:CreateToggle({
    Name         = "Enable Auto Farm",
    Desc         = "GET THEM EGGSSSS",
    CurrentValue = false,
    Callback     = function(state)
        autoFarmEnabled = state
        farmStatusParagraph:Set({
            Title   = "Auto Farm Status",
            Content = state and "Running" or "Disabled"
        })
        if state then
            task.spawn(autoFarmLoop)
        end
    end
})

TabFarm:CreateButton({
    Name     = "TP to My Plot",
    Desc     = "Teleport to your owned plot",
    Callback = function()
        local hrp  = LocalPlayer.Character and
                     LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local base = getPlayerPlot()
        if hrp and base then
            hrp.CFrame = CFrame.new(base.Position + Vector3.new(0, 5, 0))
        end
    end
})

TabFarm:CreateButton({
    Name     = "Rescan ESP",
    Desc     = "Rebuild ESP for all current eggs",
    Callback = function()
        scanAndBuildESP()
    end
})

-- ── Tab: Live Eggs ────────────────────────────────────────
local TabLive = Window:CreateTab({
    Name      = "Live Eggs",
    Desc      = "Currently rendered eggs",
    EmptyText = "No rendered eggs",
    Icon      = "list"
})

local liveParagraph = TabLive:CreateParagraph({
    Title   = "Live Eggs",
    Content = "Press Refresh to scan."
})

TabLive:CreateButton({
    Name     = "Refresh List",
    Desc     = "Rescan RenderedEggs folder",
    Callback = function()
        local names = {}
        for _, desc in ipairs(RenderedEggs:GetDescendants()) do
            if desc:IsA("Model") then
                table.insert(names, desc.Name)
            end
        end
        local txt = #names > 0
            and table.concat(names, "\n")
            or  "No eggs found."
        liveParagraph:Set({ Title = "Live Eggs (" .. #names .. ")", Content = txt })
    end
})

-- ── Tab: Radar ────────────────────────────────────────────
local TabRadar = Window:CreateTab({
    Name      = "Radar",
    Desc      = "Track nearest egg of chosen type",
    EmptyText = "Nothing here yet",
    Icon      = "radar"
})

TabRadar:CreateParagraph({
    Title   = "Radar",
    Content = "Select one egg type then enable Infinite Radar."
})

TabRadar:CreateDropdown({
    Name            = "Eggs",
    Desc            = "Choose one egg type to track",
    CurrentOption   = "None",
    MultipleOptions = false,
    Options         = eggOptions,
    Callback        = function(selected)
        selectedRadarEgg = selected
        if radarEnabled then startRadar() end
    end
})

TabRadar:CreateToggle({
    Name         = "Infinite Radar",
    Desc         = "Continuously track nearest selected egg",
    CurrentValue = false,
    Callback     = function(state)
        radarEnabled = state
        startRadar()
    end
})

-- ── Tab: Pet ──────────────────────────────────────────────
local TabPet = Window:CreateTab({
    Name      = "Pet",
    Desc      = "Pet speed and jump controls",
    EmptyText = "Nothing here yet",
    Icon      = "paw-print"
})

TabPet:CreateSlider({
    Name         = "Pet Speed",
    Desc         = "Speed while riding",
    CurrentValue = 16,
    Increment    = 1,
    Range        = {1, 250},
    Callback     = function(val)
        petSpeedVal = val
        -- apply ke humanoid / pet model jika ada reference
    end
})

TabPet:CreateSlider({
    Name         = "Jump Height",
    Desc         = "Jump height while in pet mode",
    CurrentValue = 7.2,
    Increment    = 0.1,
    Range        = {1, 50},
    Callback     = function(val)
        jumpHeightVal = val
    end
})

TabPet:CreateToggle({
    Name         = "Instant Acceleration / Stop",
    Desc         = "Zero velocity on toggle off",
    CurrentValue = false,
    Callback     = function(state)
        instantAccel = state
        if not state then
            local hrp = LocalPlayer.Character and
                        LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    0, hrp.AssemblyLinearVelocity.Y, 0
                )
            end
        end
    end
})

TabPet:CreateToggle({
    Name         = "Enable Pet Mode",
    Desc         = "Activate pet riding",
    CurrentValue = false,
    Callback     = function(state)
        petEnabled = state
        local hum = LocalPlayer.Character and
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if state then
                hum.WalkSpeed = petSpeedVal
                hum.JumpHeight = jumpHeightVal
            else
                hum.WalkSpeed  = 16
                hum.JumpHeight = 7.2
            end
        end
    end
})
