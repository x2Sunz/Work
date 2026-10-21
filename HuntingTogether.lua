local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local HttpService = cloneref(game:GetService("HttpService"))
local WindUI
do
	local ok, result = pcall(function()
		return require("./src/Init")
	end)

	if ok then
		WindUI = result
	else
		if cloneref(game:GetService("RunService")):IsStudio() then
			WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
		else
			WindUI =
				loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
		end
	end
end
function createPopup()
	return WindUI:Popup({
		Title = "Welcome to the WindUI!",
		Icon = "bird",
		Content = "Hello!",
		Buttons = {
			{
				Title = "Hahaha",
				Icon = "bird",
				Variant = "Tertiary",
			},
			{
				Title = "Hahaha",
				Icon = "bird",
				Variant = "Tertiary",
			},
			{
				Title = "Hahaha",
				Icon = "bird",
				Variant = "Tertiary",
			},
		},
	})
end

-- */  Window  /* --
local Window = WindUI:CreateWindow({
	Title = "Hunting Together by x2Sunz",
	Folder = "ftgshub",
	Icon = "solar:folder-2-bold-duotone",
	NewElements = true,
	HideSearchBar = false,

	OpenButton = {
		Title = "Open .ftgs hub UI", -- can be changed
		CornerRadius = UDim.new(1, 0), -- fully rounded
		StrokeThickness = 3, -- removing outline
		Enabled = true, -- enable or disable openbutton
		Draggable = true,
		OnlyMobile = false,
		Scale = 0.5,

		Color = ColorSequence.new( -- gradient
			Color3.fromHex("#30FF6A"),
			Color3.fromHex("#e7ff2f")
		),
	},
	Topbar = {
		Height = 44,
		ButtonsType = "Mac", -- Default or Mac
	},
})

--createPopup()

--Window:SetUIScale(.8)

-- */  Tags  /* --
do
	Window:Tag({
		Title = "v" .. WindUI.Version,
		Icon = "github",
		Color = Color3.fromHex("#1c1c1c"),
		Border = true,
	})
end

-- */  Colors  /* --
local Purple = Color3.fromHex("#7775F2")
local Yellow = Color3.fromHex("#ECA201")
local Green = Color3.fromHex("#10C550")
local Grey = Color3.fromHex("#83889E")
local Blue = Color3.fromHex("#257AF7")
local Red = Color3.fromHex("#EF4F1D")

-- */ Other Functions /* --
local function parseJSON(luau_table, indent, level, visited)
	indent = indent or 2
	level = level or 0
	visited = visited or {}

	local currentIndent = string.rep(" ", level * indent)
	local nextIndent = string.rep(" ", (level + 1) * indent)

	if luau_table == nil then
		return "null"
	end

	local dataType = type(luau_table)

	if dataType == "table" then
		if visited[luau_table] then
			return '"[Circular Reference]"'
		end

		visited[luau_table] = true

		local isArray = true
		local maxIndex = 0

		for k, _ in pairs(luau_table) do
			if type(k) == "number" and k > maxIndex then
				maxIndex = k
			end
			if type(k) ~= "number" or k <= 0 or math.floor(k) ~= k then
				isArray = false
				break
			end
		end

		local count = 0
		for _ in pairs(luau_table) do
			count = count + 1
		end
		if count ~= maxIndex and isArray then
			isArray = false
		end

		if count == 0 then
			return "{}"
		end

		if isArray then
			if count == 0 then
				return "[]"
			end

			local result = "[\n"

			for i = 1, maxIndex do
				result = result .. nextIndent .. parseJSON(luau_table[i], indent, level + 1, visited)
				if i < maxIndex then
					result = result .. ","
				end
				result = result .. "\n"
			end

			result = result .. currentIndent .. "]"
			return result
		else
			local result = "{\n"
			local first = true

			local keys = {}
			for k in pairs(luau_table) do
				table.insert(keys, k)
			end
			table.sort(keys, function(a, b)
				if type(a) == type(b) then
					return tostring(a) < tostring(b)
				else
					return type(a) < type(b)
				end
			end)

			for _, k in ipairs(keys) do
				local v = luau_table[k]
				if not first then
					result = result .. ",\n"
				else
					first = false
				end

				if type(k) == "string" then
					result = result .. nextIndent .. '"' .. k .. '": '
				else
					result = result .. nextIndent .. '"' .. tostring(k) .. '": '
				end

				result = result .. parseJSON(v, indent, level + 1, visited)
			end

			result = result .. "\n" .. currentIndent .. "}"
			return result
		end
	elseif dataType == "string" then
		local escaped = luau_table:gsub("\\", "\\\\")
		escaped = escaped:gsub('"', '\\"')
		escaped = escaped:gsub("\n", "\\n")
		escaped = escaped:gsub("\r", "\\r")
		escaped = escaped:gsub("\t", "\\t")

		return '"' .. escaped .. '"'
	elseif dataType == "number" then
		return tostring(luau_table)
	elseif dataType == "boolean" then
		return luau_table and "true" or "false"
	elseif dataType == "function" then
		return '"function"'
	else
		return '"' .. dataType .. '"'
	end
end

local function tableToClipboard(luau_table, indent)
	indent = indent or 4
	local jsonString = parseJSON(luau_table, indent)
	setclipboard(jsonString)
	return jsonString
end

-- */  Home Tab  /* --
do
	local HomeTab = Window:Tab({
		Title = "Home",
		Desc = "Auto Farm",
		Icon = "solar:info-square-bold",
		IconColor = Grey,
		IconShape = "Square",
		Border = true,
	})
    local FarmCount = 0
    local function getNearestMonster()
        local Nearest, NearestDist = nil, math.huge
        for _, v in ipairs(Workspace.Monsters:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and (not v:FindFirstChildOfClass("Humanoid") or v:FindFirstChildOfClass("Humanoid").Health > 0) then
                local Distance = (v:FindFirstChild("HumanoidRootPart").Position - LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
                if Distance < NearestDist then
                    Nearest, NearestDist = v, Distance
                end
            end
        end
        return Nearest
    end
    local AutoFarm = HomeTab:Toggle({
        Title = "Auto Farm",
        Desc = "ออโต้ฟาม",
        Callback = function(Value)
            _G.AutoFarm = Value
            FarmCount += 1
            local vCount = FarmCount
            task.spawn(function()
                while _G.AutoFarm do task.wait()
                    pcall(function()
                        local v = getNearestMonster()
                        repeat wait()
                            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):MoveTo(v.HumanoidRootPart.Position)
                            ReplicatedStorage.Remotes.UseSkill:FireServer("bash", v)
                        until not _G.AutoFarm or LocalPlayer.Character.Humanoid.Health < 1 or not v
                        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):MoveTo(LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position)
                        wait(3)
                    end)
                end
            end)
        end
    })
    local Session = 0
    local OldCFrame
    local function startAutoRespawn()
        Session += 1
        local I = Session
        task.spawn(function()
            while task.wait(.1) do
                pcall(function()
                    if _G.AutoRespawn then
                        if LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                            if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then OldCFrame = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame end
                            return
                        end
                        local DeadChar = LocalPlayer.Character
                        repeat task.wait(.25)
                            if LocalPlayer.PlayerGui:WaitForChild("HuntRespawn").Enabled then
                                local Holder = LocalPlayer.PlayerGui:WaitForChild("HuntRespawn"):WaitForChild("Holder")
                                local Window = Holder:WaitForChild("Window")
                                local Card = Window:WaitForChild("Card_")
                                local Body = Card:WaitForChild("Body")
                                for _, b in pairs(Body:GetChildren()) do
                                    if b:IsA("ImageButton") and b.Image == "rbxassetid://102634679156347" then
                                        GuiService.SelectedObject = b
                                        VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.Return, false, game)
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                        VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.BackSlash, false, game)
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.BackSlash, false, game)
                                    end
                                end
                            end
                            local NewCharacter = LocalPlayer.Character
                            local NewHumanoid = NewCharacter and NewCharacter:FindFirstChildOfClass("Humanoid")
                        until Session ~= I or (NewCharacter and NewCharacter ~= DeadChar and NewHumanoid and NewHumanoid.Health > 0)
                        if LocalPlayer.Character:WaitForChild("HumanoidRootPart", 10) and OldCFrame then
                            for _ = 1, 8 do
                                LocalPlayer.Character:WaitForChild("HumanoidRootPart", 10).AssemblyLinearVelocity = Vector3.zero
                                LocalPlayer.Character:WaitForChild("HumanoidRootPart", 10).CFrame = OldCFrame
                                task.wait(.15)
                            end
                        end
                    end
                end)
            end
        end)
    end
    local AutoRespawn = HomeTab:Toggle({
        Title = "Auto Respawn",
        Desc = "ออโต้เกิดใหม่",
        Callback = function(Value)
            _G.AutoRespawn = Value
            if _G.AutoRespawn then
                startAutoRespawn()
            else
                Session += 1
            end
        end
    })
    local AutoChests = HomeTab:Toggle({
        Title = "Auto Cheats",
        Desc = "ออโต้เปิดกล่อง",
        Callback = function(Value)
            _G.AutoChests = Value
            task.spawn(function()
                while task.wait(.1) do
                    pcall(function()
                        if _G.AutoChests then
                            VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end
                    end)
                end
            end)
        end
    })
    local AutoCombat = HomeTab:Toggle({
        Title = "Auto Combat",
        Desc = "ออโต้ต่อสู้",
        Callback = function(Value)
            _G.AutoCombat = Value
            task.spawn(function()
                while task.wait(.1) do
                    pcall(function()
                        if _G.AutoCombat then
                            if LocalPlayer.PlayerGui.LumiAuto.AutoButton.Body.Face.BackgroundColor3 == Color3.fromRGB(34, 46, 88) then
                                VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.F, false, game)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                            end
                        end
                    end)
                end
            end)
        end
    })
end
