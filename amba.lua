_G.EggESP = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RenderedEggs = workspace:WaitForChild("RenderedEggs")
local Plots = workspace:WaitForChild("Plots")
local GameData = ReplicatedStorage:WaitForChild("GameData")
local Eggs = GameData:WaitForChild("Eggs")
local module = require(Eggs)

for k, value1 in pairs(module) do
end

PlayerGui:FindFirstChild("RenderedEggsESP_GUI")
PlayerGui.RenderedEggsESP_GUI:Destroy()
local response = game:HttpGet("https://raw.githubusercontent.com/Methions/Airflow/refs/heads/main/Uploaded")
local Airflow = loadstring(response)()

local Window = Airflow:CreateWindow({
	Name = "Diablo Hub",
	ConfigurationSaving = { Enabled = false, FileName = "default", FolderName = "EggScanner" },
	Home = {
		Name = "Home",
		Desc = "Egg scanner",
		Greeting = "Diablo Hub is ready.",
		Pages = {
			{
				Name = "Status",
				Content = "Egg Farm provides live egg ESP and automatic collection for selected egg types.",
				Icon = "activity"
			},
			{
				Name = "Auto Farm",
				Content = "Select egg types, enable the farm, and it will collect matching eggs and return to your plot.",
				Icon = "crosshair"
			}
		},
		SectionName = "System info",
		Stats = { "FPS", "Ping", "Executor", "Game", "Region", "Time", "Players", "Uptime" },
		TimeFormat = "%H:%M",
		Welcome = "Hello, "
	},
	Icon = "rbxthumb://type=Asset&id=108858394161442&w=150&h=150",
	KeepOnScreen = true,
	Loading = {
		Text = "Starting",
		Title = "Diablo Hub",
		Duration = 1.4,
		Enabled = true,
		Steps = { "Preparing interface", "Loading eggs", "Almost there" }
	},
	LoadingSubtitle = "Egg Farm",
	MaxNotifications = 4,
	MaxSize = Vector2.new(1000, 700),
	MinSize = Vector2.new(480, 360),
	OpenButton = { Title = "Diablo Hub", Icon = "egg" },
	Parent = CoreGui,
	Size = UDim2.fromOffset(640, 480),
	ToggleUIKeybind = "RightControl"
})

Window:Toggle(false)

local Tab = Window:CreateTab({
	Name = "Egg Farm",
	Desc = "Egg ESP and auto farm",
	EmptyText = "Nothing here yet",
	Icon = "egg",
	Pages = {
		{
			Name = "Explanation",
			Content = "Select one or more egg types in Auto Farm Eggs, then enable auto farm. It searches for matching live eggs, moves to the egg, activates its ProximityPrompt, and returns to your plot after collection. Egg ESP can be enabled on this tab to see live eggs and their distance.",
			Icon = "info"
		}
	}
})

local Tab2 = Window:CreateTab({
	Name = "Pet",
	Desc = "Pet speed and jump controls",
	EmptyText = "Nothing here yet",
	Icon = "paw-print"
})

local Tab3 = Window:CreateTab({
	Name = "Radar",
	Desc = "Infinite selected-egg radar",
	EmptyText = "Nothing here yet",
	Icon = "radar"
})

Tab:CreateToggle({
	Name = "Egg ESP",
	Desc = "Esp's All the egg",
	CurrentValue = false,
	Callback = function(state)
		if state then
			local descendants = RenderedEggs:GetDescendants()

			for i, descendant3 in ipairs(descendants) do
			end

			local EggESP = Instance.new("BillboardGui")
			EggESP.Name = "EggESP"
			EggESP.Adornee = v2.PrimaryPart
			EggESP.Size = UDim2.fromOffset(190, 42)
			EggESP.StudsOffset = Vector3.new(0, 3, 0)
			EggESP.AlwaysOnTop = true
			EggESP.MaxDistance = 100000
			EggESP.Enabled = state
			EggESP.Parent = PlayerGui
			local TextLabel = Instance.new("TextLabel")
			TextLabel.BackgroundTransparency = 1
			TextLabel.Size = UDim2.fromScale(1, 1)
			TextLabel.Font = Enum.Font.GothamBold
			TextLabel.TextSize = 14
			TextLabel.TextColor3 = Color3.new(1, 1, 1)
			TextLabel.TextStrokeTransparency = 0
			TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
			TextLabel.Text = v2.Name
			TextLabel.Parent = EggESP
		else
			EggESP.Enabled = false
		end
	end
})

Tab:CreateDropdown({
	Name = "Auto Farm Eggs",
	Desc = "Select multiple egg types for the auto farm",
	CurrentOption = { "None" },
	MultipleOptions = true,
	Options = { "None", k },
	Callback = function()
	end
})

Tab:CreateToggle({
	Name = "Enable auto farm",
	Desc = "GET THEM EGGGGSSSSSSSSSSS",
	CurrentValue = false,
	Callback = function()
	end
})

RunService.RenderStepped:Connect(function(deltaTime)
end)

Tab3:CreateDropdown({
	Name = "Eggs",
	Desc = "Choose exactly one egg for the radar to track",
	CurrentOption = "None",
	MultipleOptions = false,
	Options = { "None", k },
	Callback = function()
	end
})

Tab3:CreateToggle({
	Name = "Infinite Radar",
	Desc = "revere the radar its still spelled radar INSTANT THAT MIND BLOWING get a job bro",
	CurrentValue = false,
	Callback = function()
	end
})

Tab3:CreateParagraph({ Title = "Radar", Content = "Select one egg, then enable Infinite Radar." })

for _, item in ipairs({
	{ name = "pet speed", desc = "Set the riding speed", currentValue = 16, value = 250 },
	{ name = "Jump Height", desc = "Set the jump height while pet mode is enabled", currentValue = 7.2, value = 50 },
}) do
	Tab2:CreateSlider({
		Name = item.name,
		Desc = item.desc,
		CurrentValue = item.currentValue,
		Increment = 1,
		Range = { 1, item.value },
		Callback = function()
		end
	})
end

Tab2:CreateToggle({
	Name = "Instant Acceleration / Instant Stop",
	Desc = "SPEED O SOUND SONIC",
	CurrentValue = false,
	Callback = function(state)
		if not state then
			local HumanoidRootPart = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, HumanoidRootPart.AssemblyLinearVelocity.Y, 0)
		end
	end
})

Tab2:CreateToggle({
	Name = "Enable Pet",
	Desc = "ENABLEEEEEE",
	CurrentValue = false,
	Callback = function()
		Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		Players.LocalPlayer:GetAttribute("IsRiding")
		Players.LocalPlayer:GetAttribute("IsPassenger")
	end
})

local Tab4 = Window:CreateTab({
	Name = "Live Eggs",
	Desc = "Currently rendered eggs",
	EmptyText = "No rendered eggs",
	Icon = "list"
})

Tab:CreateParagraph({ Title = "Auto Farm Status", Content = "Disabled" })

Tab:CreateButton({
	Name = "TP Plot",
	Desc = "Teleport to your owned plot",
	Callback = function(state)
		Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

		if state then
			local children = Plots:GetChildren()

			for i2, item2 in ipairs(children) do
				local Data = item2:FindFirstChild("Data")
				Data:FindFirstChild("Owner")
				item2:FindFirstChild("Baseplate")
			end
		else
			local children2 = Plots:GetChildren()

			for i3, item3 in ipairs(children2) do
				local Data2 = item3:FindFirstChild("Data")
				Data2:FindFirstChild("Owner")
				item3:FindFirstChild("Baseplate")
			end
		end
	end
})

Tab:CreateButton({
	Name = "Rescan Eggs",
	Desc = "Scan RenderedEggs once",
	Callback = function(state)
		if state then
			local descendants2 = RenderedEggs:GetDescendants()

			for i4, item4 in ipairs(descendants2) do
			end

			local EggESP2 = Instance.new("BillboardGui")
			EggESP2.Name = "EggESP"
			EggESP2.Adornee = v5.PrimaryPart
			EggESP2.Size = UDim2.fromOffset(190, 42)
			EggESP2.StudsOffset = Vector3.new(0, 3, 0)
			EggESP2.AlwaysOnTop = true
			EggESP2.MaxDistance = 100000
			EggESP2.Enabled = false
			EggESP2.Parent = PlayerGui
			local TextLabel2 = Instance.new("TextLabel")
			TextLabel2.BackgroundTransparency = 1
			TextLabel2.Size = UDim2.fromScale(1, 1)
			TextLabel2.Font = Enum.Font.GothamBold
			TextLabel2.TextSize = 14
			TextLabel2.TextColor3 = Color3.new(1, 1, 1)
			TextLabel2.TextStrokeTransparency = 0
			TextLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
			TextLabel2.Text = v5.Name
			TextLabel2.Parent = EggESP2
			EggESP:Destroy()
		else
			local descendants3 = RenderedEggs:GetDescendants()

			for i5, item5 in ipairs(descendants3) do
			end

			local EggESP3 = Instance.new("BillboardGui")
			EggESP3.Name = "EggESP"
			EggESP3.Adornee = v6.PrimaryPart
			EggESP3.Size = UDim2.fromOffset(190, 42)
			EggESP3.StudsOffset = Vector3.new(0, 3, 0)
			EggESP3.AlwaysOnTop = true
			EggESP3.MaxDistance = 100000
			EggESP3.Enabled = false
			EggESP3.Parent = PlayerGui
			local TextLabel3 = Instance.new("TextLabel")
			TextLabel3.BackgroundTransparency = 1
			TextLabel3.Size = UDim2.fromScale(1, 1)
			TextLabel3.Font = Enum.Font.GothamBold
			TextLabel3.TextSize = 14
			TextLabel3.TextColor3 = Color3.new(1, 1, 1)
			TextLabel3.TextStrokeTransparency = 0
			TextLabel3.TextStrokeColor3 = Color3.new(0, 0, 0)
			TextLabel3.Text = v6.Name
			TextLabel3.Parent = EggESP3
			EggESP2:Destroy()
		end
	end
})

Tab4:CreateParagraph({ Title = "Live Eggs", Content = "Scanning..." })

Tab4:CreateButton({
	Name = "Refresh List",
	Desc = "Rescan the rendered egg folder",
	Callback = function(state)
		if state then
			local descendants4 = RenderedEggs:GetDescendants()

			for i6, item6 in ipairs(descendants4) do
			end

			local EggESP4 = Instance.new("BillboardGui")
			EggESP4.Name = "EggESP"
			EggESP4.Adornee = v7.PrimaryPart
			EggESP4.Size = UDim2.fromOffset(190, 42)
			EggESP4.StudsOffset = Vector3.new(0, 3, 0)
			EggESP4.AlwaysOnTop = true
			EggESP4.MaxDistance = 100000
			EggESP4.Enabled = false
			EggESP4.Parent = PlayerGui
			local TextLabel4 = Instance.new("TextLabel")
			TextLabel4.BackgroundTransparency = 1
			TextLabel4.Size = UDim2.fromScale(1, 1)
			TextLabel4.Font = Enum.Font.GothamBold
			TextLabel4.TextSize = 14
			TextLabel4.TextColor3 = Color3.new(1, 1, 1)
			TextLabel4.TextStrokeTransparency = 0
			TextLabel4.TextStrokeColor3 = Color3.new(0, 0, 0)
			TextLabel4.Text = v7.Name
			TextLabel4.Parent = EggESP4
			EggESP3:Destroy()
		else
			local descendants5 = RenderedEggs:GetDescendants()

			for i7, item7 in ipairs(descendants5) do
			end

			local EggESP5 = Instance.new("BillboardGui")
			EggESP5.Name = "EggESP"
			EggESP5.Adornee = v8.PrimaryPart
			EggESP5.Size = UDim2.fromOffset(190, 42)
			EggESP5.StudsOffset = Vector3.new(0, 3, 0)
			EggESP5.AlwaysOnTop = true
			EggESP5.MaxDistance = 100000
			EggESP5.Enabled = false
			EggESP5.Parent = PlayerGui
			local TextLabel5 = Instance.new("TextLabel")
			TextLabel5.BackgroundTransparency = 1
			TextLabel5.Size = UDim2.fromScale(1, 1)
			TextLabel5.Font = Enum.Font.GothamBold
			TextLabel5.TextSize = 14
			TextLabel5.TextColor3 = Color3.new(1, 1, 1)
			TextLabel5.TextStrokeTransparency = 0
			TextLabel5.TextStrokeColor3 = Color3.new(0, 0, 0)
			TextLabel5.Text = v8.Name
			TextLabel5.Parent = EggESP5
			EggESP4:Destroy()
		end
	end
})

local descendants6 = RenderedEggs:GetDescendants()

for i8, item8 in ipairs(descendants6) do
end

local EggESP6 = Instance.new("BillboardGui")
EggESP6.Name = "EggESP"
EggESP6.Adornee = v9.PrimaryPart
EggESP6.Size = UDim2.fromOffset(190, 42)
EggESP6.StudsOffset = Vector3.new(0, 3, 0)
EggESP6.AlwaysOnTop = true
EggESP6.MaxDistance = 100000
EggESP6.Enabled = false
EggESP6.Parent = PlayerGui
local TextLabel6 = Instance.new("TextLabel")
TextLabel6.BackgroundTransparency = 1
TextLabel6.Size = UDim2.fromScale(1, 1)
TextLabel6.Font = Enum.Font.GothamBold
TextLabel6.TextSize = 14
TextLabel6.TextColor3 = Color3.new(1, 1, 1)
TextLabel6.TextStrokeTransparency = 0
TextLabel6.TextStrokeColor3 = Color3.new(0, 0, 0)
TextLabel6.Text = v9.Name
TextLabel6.Parent = EggESP6
EggESP5:Destroy()

RenderedEggs.DescendantAdded:Connect(function(descendant)
	task.defer(function()
	end)
end)

RenderedEggs.DescendantRemoving:Connect(function(descendant2)
end)

task.spawn(function()
	local descendants7 = RenderedEggs:GetDescendants()
	local lastDescendants = descendants7
	local lastEggESP = EggESP6

	for _ = 1, 25 do
		local previousDescendants = lastDescendants
		local previousEggESP = lastEggESP

		for i9, previousDescendant in ipairs(previousDescendants) do
		end
		-- Source Leak | https://discord.gg/x7YbZeezpm

		local EggESP7 = Instance.new("BillboardGui")
		EggESP7.Name = "EggESP"
		EggESP7.Adornee = v10.PrimaryPart
		EggESP7.Size = UDim2.fromOffset(190, 42)
		EggESP7.StudsOffset = Vector3.new(0, 3, 0)
		EggESP7.AlwaysOnTop = true
		EggESP7.MaxDistance = 100000
		EggESP7.Enabled = false
		EggESP7.Parent = PlayerGui
		local TextLabel7 = Instance.new("TextLabel")
		TextLabel7.BackgroundTransparency = 1
		TextLabel7.Size = UDim2.fromScale(1, 1)
		TextLabel7.Font = Enum.Font.GothamBold
		TextLabel7.TextSize = 14
		TextLabel7.TextColor3 = Color3.new(1, 1, 1)
		TextLabel7.TextStrokeTransparency = 0
		TextLabel7.TextStrokeColor3 = Color3.new(0, 0, 0)
		TextLabel7.Text = v10.Name
		TextLabel7.Parent = EggESP7
		previousEggESP:Destroy()
		task.wait(0.15)
		local descendants8 = RenderedEggs:GetDescendants()

		for i10, item9 in ipairs(descendants8) do
		end

		local EggESP8 = Instance.new("BillboardGui")
		EggESP8.Name = "EggESP"
		EggESP8.Adornee = v11.PrimaryPart
		EggESP8.Size = UDim2.fromOffset(190, 42)
		EggESP8.StudsOffset = Vector3.new(0, 3, 0)
		EggESP8.AlwaysOnTop = true
		EggESP8.MaxDistance = 100000
		EggESP8.Enabled = false
		EggESP8.Parent = PlayerGui
		local TextLabel8 = Instance.new("TextLabel")
		TextLabel8.BackgroundTransparency = 1
		TextLabel8.Size = UDim2.fromScale(1, 1)
		TextLabel8.Font = Enum.Font.GothamBold
		TextLabel8.TextSize = 14
		TextLabel8.TextColor3 = Color3.new(1, 1, 1)
		TextLabel8.TextStrokeTransparency = 0
		TextLabel8.TextStrokeColor3 = Color3.new(0, 0, 0)
		TextLabel8.Text = v11.Name
		TextLabel8.Parent = EggESP8
		EggESP7:Destroy()
		task.wait(0.15)
		local descendants9 = RenderedEggs:GetDescendants()
		lastDescendants = descendants9
		lastEggESP = EggESP8
	end

	for i59, lastDescendant in ipairs(lastDescendants) do
	end

	local EggESP57 = Instance.new("BillboardGui")
	EggESP57.Name = "EggESP"
	EggESP57.Adornee = v60.PrimaryPart
	EggESP57.Size = UDim2.fromOffset(190, 42)
	EggESP57.StudsOffset = Vector3.new(0, 3, 0)
	EggESP57.AlwaysOnTop = true
	EggESP57.MaxDistance = 100000
	EggESP57.Enabled = false
	EggESP57.Parent = PlayerGui
	local TextLabel57 = Instance.new("TextLabel")
	TextLabel57.BackgroundTransparency = 1
	TextLabel57.Size = UDim2.fromScale(1, 1)
	TextLabel57.Font = Enum.Font.GothamBold
	TextLabel57.TextSize = 14
	TextLabel57.TextColor3 = Color3.new(1, 1, 1)
	TextLabel57.TextStrokeTransparency = 0
	TextLabel57.TextStrokeColor3 = Color3.new(0, 0, 0)
	TextLabel57.Text = v60.Name
	TextLabel57.Parent = EggESP57
	lastEggESP:Destroy()
	task.wait(0.15)
end)

task.spawn(function()
	task.wait(0.1)
	local HumanoidRootPart2 = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	EggESP57.Enabled = false
	TextLabel57.Text = v60.Name .. "\n[" .. math.floor((HumanoidRootPart2.Position - v60.PrimaryPart.Position).Magnitude) .. " studs]"
	TextLabel57.TextColor3 = Color3.new(1, 1, 1)
end)

task.spawn(function()
	task.wait(0.25)
	task.wait(0.25)
end)

task.spawn(function()
	task.wait(0.2)
	task.wait(0.2)
end)

task.spawn(function()
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
end)

task.spawn(function()
	task.wait(0.05)
	Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	Players.LocalPlayer:GetAttribute("IsRiding")
	Players.LocalPlayer:GetAttribute("IsPassenger")
	task.wait(0.05)
end)
