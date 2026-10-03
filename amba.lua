-- Diablo Hub | WindUI Version
-- WindUI by Footagesus

_G.EggESP = {}

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local RenderedEggs = workspace:WaitForChild("RenderedEggs")
local Plots        = workspace:WaitForChild("Plots")

local GameData = ReplicatedStorage:WaitForChild("GameData")
local Eggs     = GameData:WaitForChild("Eggs")
local module   = require(Eggs)

-- Kumpulin egg names
local eggOptions = {}
for k, _ in pairs(module) do
    if type(k) == "string" then
        table.insert(eggOptions, k)
    end
end
table.sort(eggOptions)

-- ── State ─────────────────────────────────────────────────
local espEnabled      = false
local autoFarmEnabled = false
local selectedFarmEggs = {}
local radarEnabled    = false
local selectedRadarEgg = nil
local petSpeedVal     = 16
local jumpHeightVal   = 7.2
local instantAccel    = false
local petEnabled      = false

-- ── WindUI Load ───────────────────────────────────────────
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title    = "Diablo Hub",
    Icon     = "egg",
    Author   = "Diablo",
    Folder   = "DiabloHub",
    Size     = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme    = "Dark",
})

-- ── Tabs ──────────────────────────────────────────────────
local TabFarm  = Window:Tab({ Title = "Egg Farm",  Icon = "egg"       })
local TabLive  = Window:Tab({ Title = "Live Eggs", Icon = "list"      })
local TabRadar = Window:Tab({ Title = "Radar",     Icon = "radar"     })
local TabPet   = Window:Tab({ Title = "Pet",       Icon = "paw-print" })

-- ══════════════════════════════════════════════════════════
-- ESP HELPERS
-- ══════════════════════════════════════════════════════════
local function clearESP()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name == "EggESP_BB" then gui:Destroy() end
    end
    _G.EggESP = {}
end

local function makeESP(model)
    if not model:IsA("Model") then return end
    local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local bb = Instance.new("BillboardGui")
    bb.Name         = "EggESP_BB"
    bb.Adornee      = root
    bb.Size         = UDim2.fromOffset(190, 40)
    bb.StudsOffset  = Vector3.new(0, 4, 0)
    bb.AlwaysOnTop  = true
    bb.MaxDistance  = 999999
    bb.Enabled      = true
    bb.Parent       = PlayerGui

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size                   = UDim2.fromScale(1, 1)
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = 13
    lbl.TextColor3             = Color3.new(1, 1, 1)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3       = Color3.new(0, 0, 0)
    lbl.Text                   = model.Name
    lbl.Parent                 = bb

    _G.EggESP[model] = {bb = bb, lbl = lbl}
end

local function scanESP()
    clearESP()
    if not espEnabled then return end
    for _, d in ipairs(RenderedEggs:GetDescendants()) do
        if d:IsA("Model") and d.PrimaryPart then
            makeESP(d)
        end
    end
end

-- Live update distance + cleanup
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for model, data in pairs(_G.EggESP) do
        if model and model.Parent and model.PrimaryPart then
            local dist = math.floor(
                (hrp.Position - model.PrimaryPart.Position).Magnitude
            )
            data.lbl.Text = model.Name .. "\n[" .. dist .. " studs]"
        else
            if data.bb then data.bb:Destroy() end
            _G.EggESP[model] = nil
        end
    end
end)

RenderedEggs.DescendantAdded:Connect(function(d)
    task.defer(function()
        if espEnabled and d:IsA("Model") and d.PrimaryPart then
            makeESP(d)
        end
    end)
end)

RenderedEggs.DescendantRemoving:Connect(function(d)
    local e = _G.EggESP[d]
    if e then
        if e.bb then e.bb:Destroy() end
        _G.EggESP[d] = nil
    end
end)

-- ══════════════════════════════════════════════════════════
-- AUTO FARM
-- ══════════════════════════════════════════════════════════
local function getPlotBase()
    for _, plot in ipairs(Plots:GetChildren()) do
        local data  = plot:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")
        if owner and owner.Value == LocalPlayer.Name then
            return plot:FindFirstChild("Baseplate")
        end
    end
end

local function autoFarmLoop()
    while autoFarmEnabled do
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and #selectedFarmEggs > 0 then
            for _, d in ipairs(RenderedEggs:GetDescendants()) do
                if not autoFarmEnabled then break end
                if d:IsA("Model") and d.PrimaryPart then
                    for _, chosen in ipairs(selectedFarmEggs) do
                        if d.Name == chosen then
                            -- TP ke egg
                            hrp.CFrame = CFrame.new(
                                d.PrimaryPart.Position + Vector3.new(0, 4, 0)
                            )
                            task.wait(0.35)
                            -- Aktivasi proximity
                            local pp = d:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if pp then
                                fireproximityprompt(pp)
                            end
                            task.wait(0.5)
                            -- Balik ke plot
                            local base = getPlotBase()
                            if base then
                                hrp.CFrame = CFrame.new(
                                    base.Position + Vector3.new(0, 5, 0)
                                )
                            end
                            task.wait(0.4)
                            break
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end

-- ══════════════════════════════════════════════════════════
-- TAB: EGG FARM
-- ══════════════════════════════════════════════════════════
TabFarm:Toggle({
    Title   = "Egg ESP",
    Default = false,
    Callback = function(state)
        espEnabled = state
        scanESP()
    end
})

TabFarm:MultiDropdown({
    Title   = "Auto Farm Eggs",
    Values  = eggOptions,
    Default = {},
    Callback = function(selected)
        selectedFarmEggs = {}
        for _, v in ipairs(selected) do
            table.insert(selectedFarmEggs, v)
        end
    end
})

local farmStatusLabel
TabFarm:Label({ Title = "Status: Idle", Callback = function(lbl)
    farmStatusLabel = lbl
end })

TabFarm:Toggle({
    Title   = "Enable Auto Farm",
    Default = false,
    Callback = function(state)
        autoFarmEnabled = state
        if farmStatusLabel then
            farmStatusLabel:Set(state and "Status: Running 🟢" or "Status: Idle 🔴")
        end
        if state then
            task.spawn(autoFarmLoop)
        end
    end
})

TabFarm:Button({
    Title    = "TP to My Plot",
    Callback = function()
        local hrp  = LocalPlayer.Character and
                     LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local base = getPlotBase()
        if hrp and base then
            hrp.CFrame = CFrame.new(base.Position + Vector3.new(0, 5, 0))
        end
    end
})

TabFarm:Button({
    Title    = "Rescan ESP",
    Callback = function()
        scanESP()
    end
})

-- ══════════════════════════════════════════════════════════
-- TAB: LIVE EGGS
-- ══════════════════════════════════════════════════════════
local liveLabel
TabLive:Label({ Title = "Press Refresh to scan.", Callback = function(lbl)
    liveLabel = lbl
end })

TabLive:Button({
    Title    = "Refresh List",
    Callback = function()
        local names = {}
        for _, d in ipairs(RenderedEggs:GetDescendants()) do
            if d:IsA("Model") then
                table.insert(names, d.Name)
            end
        end
        local text = #names > 0
            and ("Found " .. #names .. " eggs:\n" .. table.concat(names, ", "))
            or "No eggs found."
        if liveLabel then liveLabel:Set(text) end
    end
})

-- ══════════════════════════════════════════════════════════
-- TAB: RADAR
-- ══════════════════════════════════════════════════════════
TabRadar:Paragraph({
    Title   = "Radar",
    Content = "Pilih satu jenis egg, lalu aktifkan Infinite Radar."
})

TabRadar:Dropdown({
    Title   = "Select Egg",
    Values  = eggOptions,
    Default = eggOptions[1] or "",
    Callback = function(val)
        selectedRadarEgg = val
    end
})

local radarConn
TabRadar:Toggle({
    Title   = "Infinite Radar",
    Default = false,
    Callback = function(state)
        radarEnabled = state
        if radarConn then radarConn:Disconnect(); radarConn = nil end
        if not state or not selectedRadarEgg then return end

        radarConn = RunService.Heartbeat:Connect(function()
            local hrp = LocalPlayer.Character and
                        LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local best, bestDist = nil, math.huge
            for _, d in ipairs(RenderedEggs:GetDescendants()) do
                if d:IsA("Model") and d.Name == selectedRadarEgg and d.PrimaryPart then
                    local dist = (hrp.Position - d.PrimaryPart.Position).Magnitude
                    if dist < bestDist then
                        best      = d
                        bestDist  = dist
                    end
                end
            end
            -- TP ke yang paling dekat
            if best and bestDist > 5 then
                hrp.CFrame = CFrame.new(
                    best.PrimaryPart.Position + Vector3.new(0, 4, 0)
                )
                local pp = best:FindFirstChildWhichIsA("ProximityPrompt", true)
                if pp then fireproximityprompt(pp) end
            end
        end)
    end
})

-- ══════════════════════════════════════════════════════════
-- TAB: PET
-- ══════════════════════════════════════════════════════════
TabPet:Slider({
    Title   = "Pet Speed",
    Min     = 1,
    Max     = 250,
    Default = 16,
    Callback = function(val)
        petSpeedVal = val
        if petEnabled then
            local hum = LocalPlayer.Character and
                        LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = petSpeedVal end
        end
    end
})

TabPet:Slider({
    Title   = "Jump Height",
    Min     = 1,
    Max     = 100,
    Default = 7,
    Callback = function(val)
        jumpHeightVal = val
        if petEnabled then
            local hum = LocalPlayer.Character and
                        LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpHeight = jumpHeightVal end
        end
    end
})

TabPet:Toggle({
    Title   = "Instant Accel / Stop",
    Default = false,
    Callback = function(state)
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

TabPet:Toggle({
    Title   = "Enable Pet Mode",
    Default = false,
    Callback = function(state)
        petEnabled = state
        local hum = LocalPlayer.Character and
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed  = state and petSpeedVal   or 16
            hum.JumpHeight = state and jumpHeightVal or 7.2
        end
    end
})

-- ══════════════════════════════════════════════════════════
print("[Diablo Hub] Loaded with WindUI ✓")
