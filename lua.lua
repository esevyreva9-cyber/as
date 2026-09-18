Понял — оставляю **весь** код как есть, ничего не вырезаю, только прокачиваю визуал: скругления (UICorner), градиенты (UIGradient), стеклянный блюр (UIBlur), новые палитры тем, шрифты, плавные пружинящие анимации, свечение при наведении. Вот полный код целиком.

```lua
if debugX then
	warn('Initialising Rayfield')
end

local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

-- =====================================================================================
-- VISUAL HELPERS (improved visuals)
-- =====================================================================================

local function addCorner(instance: Instance, radius: number)
	if instance:FindFirstChildOfClass("UICorner") then return end
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function addGradient(instance: Instance, from: Color3, to: Color3, rotation: number?)
	if instance:FindFirstChildOfClass("UIGradient") then return end
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(from, to)
	gradient.Rotation = rotation or 90
	gradient.Parent = instance
	return gradient
end

local function addBlur(instance: Instance, size: number)
	if instance:FindFirstChildOfClass("UIBlur") then return end
	local blur = Instance.new("UIBlur")
	blur.Size = size or 24
	blur.Parent = instance
end

local function updateGradient(instance: Instance, from: Color3, to: Color3)
	local gradient = instance:FindFirstChildOfClass("UIGradient")
	if gradient then
		gradient.Color = ColorSequence.new(from, to)
	end
end

-- =====================================================================================
-- LOAD WITH TIMEOUT (unchanged)
-- =====================================================================================
-- Loads and executes a function hosted on a remote URL. Cancels the request if the requested URL takes too long to respond.
-- Errors with the function are caught and logged to the output
local function loadWithTimeout(url: string, timeout: number?): ...any
	assert(type(url) == "string", "Expected string, got " .. type(url))
	timeout = timeout or 5
	local requestCompleted = false
	local success, result = false, nil

	local requestThread = task.spawn(function()
		local fetchSuccess, fetchResult = pcall(game.HttpGet, game, url)
		if not fetchSuccess or #fetchResult == 0 then
			if #fetchResult == 0 then
				fetchResult = "Empty response"
			end
			success, result = false, fetchResult
			requestCompleted = true
			return
		end
		local content = fetchResult
		local execSuccess, execResult = pcall(function()
			return loadstring(content)()
		end)
		success, result = execSuccess, execResult
		requestCompleted = true
	end)

	local timeoutThread = task.delay(timeout, function()
		if not requestCompleted then
			warn(`Request for {url} timed out after {timeout} seconds`)
			task.cancel(requestThread)
			result = "Request timed out"
			requestCompleted = true
		end
	end)

	while not requestCompleted do
		task.wait()
	end
	if coroutine.status(timeoutThread) ~= "dead" then
		task.cancel(timeoutThread)
	end
	if not success then
		warn(`Failed to process {url}: {result}`)
	end
	return if success then result else nil
end

local requestsDisabled = true --getgenv and getgenv().DISABLE_RAYFIELD_REQUESTS
local InterfaceBuild = '3K3W'
local Release = "Build 1.68"
local RayfieldFolder = "Rayfield"
local ConfigurationFolder = RayfieldFolder.."/Configurations"
local ConfigurationExtension = ".rfld"
local settingsTable = {
	General = {
		rayfieldOpen = {Type = 'bind', Value = 'K', Name = 'Rayfield Keybind'},
	},
	System = {
		usageAnalytics = {Type = 'toggle', Value = true, Name = 'Anonymised Analytics'},
	}
}

local overriddenSettings: { [string]: any } = {}
local function overrideSetting(category: string, name: string, value: any)
	overriddenSettings[`{category}.{name}`] = value
end

local function getSetting(category: string, name: string): any
	if overriddenSettings[`{category}.{name}`] ~= nil then
		return overriddenSettings[`{category}.{name}`]
	elseif settingsTable[category][name] ~= nil then
		return settingsTable[category][name].Value
	end
end

if requestsDisabled then
	overrideSetting("System", "usageAnalytics", false)
end

local HttpService = getService('HttpService')
local RunService = getService('RunService')

local useStudio = RunService:IsStudio() or false

local settingsCreated = false
local settingsInitialized = false
local cachedSettings
local prompt = useStudio and require(script.Parent.prompt) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/prompt.lua')
local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request

if not prompt and not useStudio then
	warn("Failed to load prompt library, using fallback")
	prompt = {
		create = function() end
	}
end

local function callSafely(func, ...)
	if func then
		local success, result = pcall(func, ...)
		if not success then
			warn("Rayfield | Function failed with error: ", result)
			return false
		else
			return result
		end
	end
end

local function ensureFolder(folderPath)
	if isfolder and not callSafely(isfolder, folderPath) then
		callSafely(makefolder, folderPath)
	end
end

local function loadSettings()
	local file = nil

	local success, result =	pcall(function()
		task.spawn(function()
			if callSafely(isfolder, RayfieldFolder) then
				if callSafely(isfile, RayfieldFolder..'/settings'..ConfigurationExtension) then
					file = callSafely(readfile, RayfieldFolder..'/settings'..ConfigurationExtension)
				end
			end

			if useStudio then
				file = [[
		{"General":{"rayfieldOpen":{"Value":"K","Type":"bind","Name":"Rayfield Keybind","Element":{"HoldToInteract":false,"Ext":true,"Name":"Rayfield Keybind","Set":null,"CallOnChange":true,"Callback":null,"CurrentKeybind":"K"}}},"System":{"usageAnalytics":{"Value":false,"Type":"toggle","Name":"Anonymised Analytics","Element":{"Ext":true,"Name":"Anonymised Analytics","Set":null,"CurrentValue":false,"Callback":null}}}}
	]]
			end

			if file then
				local success, decodedFile = pcall(function() return HttpService:JSONDecode(file) end)
				if success then
					file = decodedFile
				else
					file = {}
				end
			else
				file = {}
			end

			if not settingsCreated then 
				cachedSettings = file
				return
			end

			if file ~= {} then
				for categoryName, settingCategory in pairs(settingsTable) do
					if file[categoryName] then
						for settingName, setting in pairs(settingCategory) do
							if file[categoryName][settingName] then
								setting.Value = file[categoryName][settingName].Value
								setting.Element:Set(getSetting(categoryName, settingName))
							end
						end
					end
				end
			end
			settingsInitialized = true
		end)
	end)

	if not success then 
		if writefile then
			warn('Rayfield had an issue accessing configuration saving capability.')
		end
	end
end

if debugX then
	warn('Now Loading Settings Configuration')
end

loadSettings()

if debugX then
	warn('Settings Loaded')
end

local analyticsLib
local sendReport = function(ev_n, sc_n) warn("Failed to load report function") end
if not requestsDisabled then
	if debugX then
		warn('Querying Settings for Reporter Information')
	end	
	analyticsLib = loadWithTimeout("https://analytics.sirius.menu/script")
	if not analyticsLib then
		warn("Failed to load analytics reporter")
		analyticsLib = nil
	elseif analyticsLib and type(analyticsLib.load) == "function" then
		analyticsLib:load()
	else
		warn("Analytics library loaded but missing load function")
		analyticsLib = nil
	end
	sendReport = function(ev_n, sc_n)
		if not (type(analyticsLib) == "table" and type(analyticsLib.isLoaded) == "function" and analyticsLib:isLoaded()) then
			warn("Analytics library not loaded")
			return
		end
		if useStudio then
			print('Sending Analytics')
		else
			if debugX then warn('Reporting Analytics') end
			analyticsLib:report(
				{
					["name"] = ev_n,
					["script"] = {["name"] = sc_n, ["version"] = Release}
				},
				{
					["version"] = InterfaceBuild
				}
			)
			if debugX then warn('Finished Report') end
		end
	end
	if cachedSettings and (#cachedSettings == 0 or (cachedSettings.System and cachedSettings.System.usageAnalytics and cachedSettings.System.usageAnalytics.Value)) then
		sendReport("execution", "Rayfield")
	elseif not cachedSettings then
		sendReport("execution", "Rayfield")
	end
end

local promptUser = 2

if promptUser == 1 and prompt and type(prompt.create) == "function" then
	prompt.create(
		'Be cautious when running scripts',
	    [[Please be careful when running scripts from unknown developers. This script has already been ran.

<font transparency='0.3'>Some scripts may steal your items or in-game goods.</font>]],
		'Okay',
		'',
		function()

		end
	)
end

if debugX then
	warn('Moving on to continue initialisation')
end

local RayfieldLibrary = {
	Flags = {},
	Theme = {
		-- ============================================================
		-- Default — sleek dark with electric blue accent
		-- ============================================================
		Default = {
			TextColor = Color3.fromRGB(240, 244, 248),

			Background = Color3.fromRGB(17, 19, 24),
			Topbar = Color3.fromRGB(24, 27, 34),
			Shadow = Color3.fromRGB(8, 9, 12),

			NotificationBackground = Color3.fromRGB(26, 29, 38),
			NotificationActionsBackground = Color3.fromRGB(235, 238, 244),

			TabBackground = Color3.fromRGB(38, 42, 52),
			TabStroke = Color3.fromRGB(52, 58, 72),
			TabBackgroundSelected = Color3.fromRGB(59, 130, 246),
			TabTextColor = Color3.fromRGB(200, 208, 220),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(26, 29, 38),
			ElementBackgroundHover = Color3.fromRGB(36, 40, 52),
			SecondaryElementBackground = Color3.fromRGB(22, 25, 32),
			ElementStroke = Color3.fromRGB(44, 50, 64),
			SecondaryElementStroke = Color3.fromRGB(38, 42, 54),

			SliderBackground = Color3.fromRGB(30, 34, 44),
			SliderProgress = Color3.fromRGB(59, 130, 246),
			SliderStroke = Color3.fromRGB(96, 165, 250),

			ToggleBackground = Color3.fromRGB(24, 27, 34),
			ToggleEnabled = Color3.fromRGB(59, 130, 246),
			ToggleDisabled = Color3.fromRGB(58, 64, 78),
			ToggleEnabledStroke = Color3.fromRGB(96, 165, 250),
			ToggleDisabledStroke = Color3.fromRGB(72, 78, 94),
			ToggleEnabledOuterStroke = Color3.fromRGB(45, 52, 66),
			ToggleDisabledOuterStroke = Color3.fromRGB(38, 42, 52),

			DropdownSelected = Color3.fromRGB(38, 42, 54),
			DropdownUnselected = Color3.fromRGB(24, 27, 34),

			InputBackground = Color3.fromRGB(24, 27, 34),
			InputStroke = Color3.fromRGB(52, 58, 72),
			PlaceholderColor = Color3.fromRGB(150, 158, 176),

			-- New visual fields
			Accent = Color3.fromRGB(59, 130, 246),
			AccentSecondary = Color3.fromRGB(99, 102, 241),
			GlowColor = Color3.fromRGB(96, 165, 250),
			BackgroundGradientTop = Color3.fromRGB(30, 33, 42),
			BackgroundGradientBottom = Color3.fromRGB(13, 15, 19),
			TopbarGradientTop = Color3.fromRGB(33, 37, 48),
			TopbarGradientBottom = Color3.fromRGB(20, 23, 30),
			ElementGradientTop = Color3.fromRGB(32, 36, 46),
			ElementGradientBottom = Color3.fromRGB(22, 25, 33),
		},

		-- ============================================================
		-- Ocean — deep teal glass
		-- ============================================================
		Ocean = {
			TextColor = Color3.fromRGB(230, 244, 244),

			Background = Color3.fromRGB(14, 28, 30),
			Topbar = Color3.fromRGB(18, 36, 38),
			Shadow = Color3.fromRGB(8, 14, 16),

			NotificationBackground = Color3.fromRGB(19, 34, 36),
			NotificationActionsBackground = Color3.fromRGB(230, 244, 244),

			TabBackground = Color3.fromRGB(30, 54, 56),
			TabStroke = Color3.fromRGB(38, 66, 68),
			TabBackgroundSelected = Color3.fromRGB(45, 212, 191),
			TabTextColor = Color3.fromRGB(205, 230, 230),
			SelectedTabTextColor = Color3.fromRGB(12, 40, 40),

			ElementBackground = Color3.fromRGB(24, 46, 48),
			ElementBackgroundHover = Color3.fromRGB(32, 58, 60),
			SecondaryElementBackground = Color3.fromRGB(22, 40, 42),
			ElementStroke = Color3.fromRGB(40, 70, 72),
			SecondaryElementStroke = Color3.fromRGB(36, 64, 66),

			SliderBackground = Color3.fromRGB(20, 60, 62),
			SliderProgress = Color3.fromRGB(45, 212, 191),
			SliderStroke = Color3.fromRGB(94, 234, 212),

			ToggleBackground = Color3.fromRGB(24, 46, 48),
			ToggleEnabled = Color3.fromRGB(20, 184, 166),
			ToggleDisabled = Color3.fromRGB(58, 88, 90),
			ToggleEnabledStroke = Color3.fromRGB(94, 234, 212),
			ToggleDisabledStroke = Color3.fromRGB(74, 104, 106),
			ToggleEnabledOuterStroke = Color3.fromRGB(40, 90, 88),
			ToggleDisabledOuterStroke = Color3.fromRGB(38, 60, 62),

			DropdownSelected = Color3.fromRGB(28, 60, 62),
			DropdownUnselected = Color3.fromRGB(22, 42, 44),

			InputBackground = Color3.fromRGB(26, 48, 50),
			InputStroke = Color3.fromRGB(44, 74, 76),
			PlaceholderColor = Color3.fromRGB(148, 178, 178),

			Accent = Color3.fromRGB(45, 212, 191),
			AccentSecondary = Color3.fromRGB(52, 211, 153),
			GlowColor = Color3.fromRGB(94, 234, 212),
			BackgroundGradientTop = Color3.fromRGB(24, 46, 48),
			BackgroundGradientBottom = Color3.fromRGB(11, 22, 24),
			TopbarGradientTop = Color3.fromRGB(30, 56, 58),
			TopbarGradientBottom = Color3.fromRGB(16, 32, 34),
			ElementGradientTop = Color3.fromRGB(30, 54, 56),
			ElementGradientBottom = Color3.fromRGB(20, 40, 42),
		},

		-- ============================================================
		-- AmberGlow — warm amber sunset
		-- ============================================================
		AmberGlow = {
			TextColor = Color3.fromRGB(255, 245, 230),

			Background = Color3.fromRGB(38, 24, 14),
			Topbar = Color3.fromRGB(48, 32, 18),
			Shadow = Color3.fromRGB(24, 16, 8),

			NotificationBackground = Color3.fromRGB(44, 30, 18),
			NotificationActionsBackground = Color3.fromRGB(245, 230, 215),

			TabBackground = Color3.fromRGB(66, 44, 26),
			TabStroke = Color3.fromRGB(80, 54, 32),
			TabBackgroundSelected = Color3.fromRGB(251, 146, 60),
			TabTextColor = Color3.fromRGB(248, 224, 200),
			SelectedTabTextColor = Color3.fromRGB(46, 26, 8),

			ElementBackground = Color3.fromRGB(52, 36, 24),
			ElementBackgroundHover = Color3.fromRGB(64, 44, 30),
			SecondaryElementBackground = Color3.fromRGB(46, 32, 20),
			ElementStroke = Color3.fromRGB(76, 52, 34),
			SecondaryElementStroke = Color3.fromRGB(66, 44, 28),

			SliderBackground = Color3.fromRGB(70, 48, 26),
			SliderProgress = Color3.fromRGB(251, 146, 60),
			SliderStroke = Color3.fromRGB(253, 186, 116),

			ToggleBackground = Color3.fromRGB(46, 32, 20),
			ToggleEnabled = Color3.fromRGB(245, 158, 11),
			ToggleDisabled = Color3.fromRGB(88, 68, 52),
			ToggleEnabledStroke = Color3.fromRGB(252, 211, 77),
			ToggleDisabledStroke = Color3.fromRGB(110, 85, 68),
			ToggleEnabledOuterStroke = Color3.fromRGB(190, 110, 40),
			ToggleDisabledOuterStroke = Color3.fromRGB(66, 52, 42),

			DropdownSelected = Color3.fromRGB(64, 44, 30),
			DropdownUnselected = Color3.fromRGB(46, 32, 20),

			InputBackground = Color3.fromRGB(54, 38, 26),
			InputStroke = Color3.fromRGB(84, 58, 38),
			PlaceholderColor = Color3.fromRGB(196, 160, 132),

			Accent = Color3.fromRGB(251, 146, 60),
			AccentSecondary = Color3.fromRGB(245, 101, 60),
			GlowColor = Color3.fromRGB(253, 186, 116),
			BackgroundGradientTop = Color3.fromRGB(60, 40, 24),
			BackgroundGradientBottom = Color3.fromRGB(30, 18, 10),
			TopbarGradientTop = Color3.fromRGB(66, 44, 26),
			TopbarGradientBottom = Color3.fromRGB(40, 26, 14),
			ElementGradientTop = Color3.fromRGB(60, 42, 28),
			ElementGradientBottom = Color3.fromRGB(44, 30, 20),
		},

		-- ============================================================
		-- Light — clean white
		-- ============================================================
		Light = {
			TextColor = Color3.fromRGB(40, 42, 48),

			Background = Color3.fromRGB(246, 247, 250),
			Topbar = Color3.fromRGB(238, 240, 245),
			Shadow = Color3.fromRGB(190, 194, 205),

			NotificationBackground = Color3.fromRGB(252, 252, 255),
			NotificationActionsBackground = Color3.fromRGB(240, 241, 245),

			TabBackground = Color3.fromRGB(232, 234, 240),
			TabStroke = Color3.fromRGB(214, 217, 226),
			TabBackgroundSelected = Color3.fromRGB(59, 130, 246),
			TabTextColor = Color3.fromRGB(90, 94, 104),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(240, 241, 246),
			ElementBackgroundHover = Color3.fromRGB(224, 227, 235),
			SecondaryElementBackground = Color3.fromRGB(232, 234, 240),
			ElementStroke = Color3.fromRGB(210, 213, 222),
			SecondaryElementStroke = Color3.fromRGB(208, 211, 220),

			SliderBackground = Color3.fromRGB(219, 224, 234),
			SliderProgress = Color3.fromRGB(96, 165, 250),
			SliderStroke = Color3.fromRGB(147, 197, 253),

			ToggleBackground = Color3.fromRGB(222, 225, 232),
			ToggleEnabled = Color3.fromRGB(59, 130, 246),
			ToggleDisabled = Color3.fromRGB(168, 172, 182),
			ToggleEnabledStroke = Color3.fromRGB(96, 165, 250),
			ToggleDisabledStroke = Color3.fromRGB(180, 183, 192),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 150),
			ToggleDisabledOuterStroke = Color3.fromRGB(190, 193, 202),

			DropdownSelected = Color3.fromRGB(228, 231, 238),
			DropdownUnselected = Color3.fromRGB(220, 223, 230),

			InputBackground = Color3.fromRGB(240, 241, 246),
			InputStroke = Color3.fromRGB(198, 201, 210),
			PlaceholderColor = Color3.fromRGB(148, 152, 162),

			Accent = Color3.fromRGB(59, 130, 246),
			AccentSecondary = Color3.fromRGB(99, 102, 241),
			GlowColor = Color3.fromRGB(96, 165, 250),
			BackgroundGradientTop = Color3.fromRGB(252, 252, 255),
			BackgroundGradientBottom = Color3.fromRGB(238, 240, 246),
			TopbarGradientTop = Color3.fromRGB(248, 249, 252),
			TopbarGradientBottom = Color3.fromRGB(232, 234, 240),
			ElementGradientTop = Color3.fromRGB(244, 245, 250),
			ElementGradientBottom = Color3.fromRGB(234, 236, 242),
		},

		-- ============================================================
		-- Amethyst — violet glow
		-- ============================================================
		Amethyst = {
			TextColor = Color3.fromRGB(242, 240, 248),

			Background = Color3.fromRGB(24, 16, 38),
			Topbar = Color3.fromRGB(32, 22, 48),
			Shadow = Color3.fromRGB(14, 10, 24),

			NotificationBackground = Color3.fromRGB(30, 20, 44),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 250),

			TabBackground = Color3.fromRGB(50, 34, 72),
			TabStroke = Color3.fromRGB(62, 42, 86),
			TabBackgroundSelected = Color3.fromRGB(167, 139, 250),
			TabTextColor = Color3.fromRGB(226, 220, 238),
			SelectedTabTextColor = Color3.fromRGB(40, 20, 60),

			ElementBackground = Color3.fromRGB(40, 28, 58),
			ElementBackgroundHover = Color3.fromRGB(48, 34, 68),
			SecondaryElementBackground = Color3.fromRGB(36, 24, 52),
			ElementStroke = Color3.fromRGB(64, 46, 84),
			SecondaryElementStroke = Color3.fromRGB(58, 40, 76),

			SliderBackground = Color3.fromRGB(48, 34, 72),
			SliderProgress = Color3.fromRGB(167, 139, 250),
			SliderStroke = Color3.fromRGB(196, 181, 253),

			ToggleBackground = Color3.fromRGB(38, 26, 54),
			ToggleEnabled = Color3.fromRGB(139, 92, 246),
			ToggleDisabled = Color3.fromRGB(72, 58, 92),
			ToggleEnabledStroke = Color3.fromRGB(167, 139, 250),
			ToggleDisabledStroke = Color3.fromRGB(94, 78, 116),
			ToggleEnabledOuterStroke = Color3.fromRGB(96, 50, 140),
			ToggleDisabledOuterStroke = Color3.fromRGB(66, 52, 88),

			DropdownSelected = Color3.fromRGB(48, 34, 66),
			DropdownUnselected = Color3.fromRGB(34, 24, 48),

			InputBackground = Color3.fromRGB(42, 30, 60),
			InputStroke = Color3.fromRGB(74, 52, 100),
			PlaceholderColor = Color3.fromRGB(180, 158, 210),

			Accent = Color3.fromRGB(167, 139, 250),
			AccentSecondary = Color3.fromRGB(139, 92, 246),
			GlowColor = Color3.fromRGB(196, 181, 253),
			BackgroundGradientTop = Color3.fromRGB(42, 30, 64),
			BackgroundGradientBottom = Color3.fromRGB(18, 12, 30),
			TopbarGradientTop = Color3.fromRGB(48, 34, 72),
			TopbarGradientBottom = Color3.fromRGB(26, 18, 42),
			ElementGradientTop = Color3.fromRGB(48, 34, 66),
			ElementGradientBottom = Color3.fromRGB(34, 24, 50),
		},

		-- ============================================================
		-- Green — fresh mint light
		-- ============================================================
		Green = {
			TextColor = Color3.fromRGB(30, 60, 34),

			Background = Color3.fromRGB(236, 246, 238),
			Topbar = Color3.fromRGB(214, 234, 218),
			Shadow = Color3.fromRGB(190, 216, 196),

			NotificationBackground = Color3.fromRGB(242, 250, 244),
			NotificationActionsBackground = Color3.fromRGB(220, 236, 224),

			TabBackground = Color3.fromRGB(216, 236, 220),
			TabStroke = Color3.fromRGB(190, 214, 196),
			TabBackgroundSelected = Color3.fromRGB(34, 197, 94),
			TabTextColor = Color3.fromRGB(60, 92, 64),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(226, 240, 228),
			ElementBackgroundHover = Color3.fromRGB(210, 228, 214),
			SecondaryElementBackground = Color3.fromRGB(238, 248, 240),
			ElementStroke = Color3.fromRGB(182, 204, 188),
			SecondaryElementStroke = Color3.fromRGB(182, 204, 188),

			SliderBackground = Color3.fromRGB(200, 224, 204),
			SliderProgress = Color3.fromRGB(34, 197, 94),
			SliderStroke = Color3.fromRGB(74, 222, 128),

			ToggleBackground = Color3.fromRGB(214, 234, 218),
			ToggleEnabled = Color3.fromRGB(22, 163, 74),
			ToggleDisabled = Color3.fromRGB(160, 186, 164),
			ToggleEnabledStroke = Color3.fromRGB(74, 222, 128),
			ToggleDisabledStroke = Color3.fromRGB(140, 164, 144),
			ToggleEnabledOuterStroke = Color3.fromRGB(110, 180, 120),
			ToggleDisabledOuterStroke = Color3.fromRGB(168, 190, 172),

			DropdownSelected = Color3.fromRGB(222, 238, 226),
			DropdownUnselected = Color3.fromRGB(208, 226, 212),

			InputBackground = Color3.fromRGB(238, 248, 240),
			InputStroke = Color3.fromRGB(184, 206, 188),
			PlaceholderColor = Color3.fromRGB(128, 152, 132),

			Accent = Color3.fromRGB(34, 197, 94),
			AccentSecondary = Color3.fromRGB(22, 163, 74),
			GlowColor = Color3.fromRGB(74, 222, 128),
			BackgroundGradientTop = Color3.fromRGB(248, 253, 249),
			BackgroundGradientBottom = Color3.fromRGB(228, 242, 232),
			TopbarGradientTop = Color3.fromRGB(236, 248, 240),
			TopbarGradientBottom = Color3.fromRGB(206, 228, 212),
			ElementGradientTop = Color3.fromRGB(238, 248, 240),
			ElementGradientBottom = Color3.fromRGB(218, 236, 222),
		},

		-- ============================================================
		-- Bloom — rose pink
		-- ============================================================
		Bloom = {
			TextColor = Color3.fromRGB(76, 44, 58),

			Background = Color3.fromRGB(255, 240, 245),
			Topbar = Color3.fromRGB(250, 220, 228),
			Shadow = Color3.fromRGB(226, 184, 196),

			NotificationBackground = Color3.fromRGB(255, 234, 240),
			NotificationActionsBackground = Color3.fromRGB(245, 214, 224),

			TabBackground = Color3.fromRGB(244, 216, 226),
			TabStroke = Color3.fromRGB(234, 202, 214),
			TabBackgroundSelected = Color3.fromRGB(244, 114, 182),
			TabTextColor = Color3.fromRGB(120, 66, 88),
			SelectedTabTextColor = Color3.fromRGB(60, 24, 44),

			ElementBackground = Color3.fromRGB(255, 235, 240),
			ElementBackgroundHover = Color3.fromRGB(246, 220, 230),
			SecondaryElementBackground = Color3.fromRGB(255, 235, 240),
			ElementStroke = Color3.fromRGB(232, 200, 212),
			SecondaryElementStroke = Color3.fromRGB(232, 200, 212),

			SliderBackground = Color3.fromRGB(244, 206, 218),
			SliderProgress = Color3.fromRGB(244, 114, 182),
			SliderStroke = Color3.fromRGB(249, 168, 212),

			ToggleBackground = Color3.fromRGB(244, 212, 222),
			ToggleEnabled = Color3.fromRGB(236, 72, 153),
			ToggleDisabled = Color3.fromRGB(200, 180, 188),
			ToggleEnabledStroke = Color3.fromRGB(244, 114, 182),
			ToggleDisabledStroke = Color3.fromRGB(214, 184, 194),
			ToggleEnabledOuterStroke = Color3.fromRGB(220, 140, 176),
			ToggleDisabledOuterStroke = Color3.fromRGB(196, 174, 184),

			DropdownSelected = Color3.fromRGB(250, 220, 229),
			DropdownUnselected = Color3.fromRGB(242, 210, 220),

			InputBackground = Color3.fromRGB(255, 236, 242),
			InputStroke = Color3.fromRGB(224, 192, 204),
			PlaceholderColor = Color3.fromRGB(176, 138, 150),

			Accent = Color3.fromRGB(244, 114, 182),
			AccentSecondary = Color3.fromRGB(236, 72, 153),
			GlowColor = Color3.fromRGB(249, 168, 212),
			BackgroundGradientTop = Color3.fromRGB(255, 246, 250),
			BackgroundGradientBottom = Color3.fromRGB(255, 232, 240),
			TopbarGradientTop = Color3.fromRGB(255, 238, 244),
			TopbarGradientBottom = Color3.fromRGB(246, 214, 224),
			ElementGradientTop = Color3.fromRGB(255, 242, 247),
			ElementGradientBottom = Color3.fromRGB(250, 226, 234),
		},

		-- ============================================================
		-- DarkBlue — navy with vibrant blue
		-- ============================================================
		DarkBlue = {
			TextColor = Color3.fromRGB(232, 236, 244),

			Background = Color3.fromRGB(15, 20, 30),
			Topbar = Color3.fromRGB(22, 29, 42),
			Shadow = Color3.fromRGB(8, 12, 18),

			NotificationBackground = Color3.fromRGB(20, 26, 38),
			NotificationActionsBackground = Color3.fromRGB(48, 56, 72),

			TabBackground = Color3.fromRGB(30, 38, 54),
			TabStroke = Color3.fromRGB(40, 50, 70),
			TabBackgroundSelected = Color3.fromRGB(37, 99, 235),
			TabTextColor = Color3.fromRGB(196, 204, 218),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(26, 33, 46),
			ElementBackgroundHover = Color3.fromRGB(34, 43, 60),
			SecondaryElementBackground = Color3.fromRGB(30, 38, 52),
			ElementStroke = Color3.fromRGB(42, 52, 72),
			SecondaryElementStroke = Color3.fromRGB(38, 48, 66),

			SliderBackground = Color3.fromRGB(24, 40, 62),
			SliderProgress = Color3.fromRGB(37, 99, 235),
			SliderStroke = Color3.fromRGB(59, 130, 246),

			ToggleBackground = Color3.fromRGB(30, 38, 52),
			ToggleEnabled = Color3.fromRGB(37, 99, 235),
			ToggleDisabled = Color3.fromRGB(64, 70, 86),
			ToggleEnabledStroke = Color3.fromRGB(59, 130, 246),
			ToggleDisabledStroke = Color3.fromRGB(72, 78, 96),
			ToggleEnabledOuterStroke = Color3.fromRGB(28, 66, 132),
			ToggleDisabledOuterStroke = Color3.fromRGB(48, 54, 70),

			DropdownSelected = Color3.fromRGB(30, 60, 84),
			DropdownUnselected = Color3.fromRGB(22, 28, 40),

			InputBackground = Color3.fromRGB(22, 28, 40),
			InputStroke = Color3.fromRGB(42, 52, 70),
			PlaceholderColor = Color3.fromRGB(152, 162, 180),

			Accent = Color3.fromRGB(37, 99, 235),
			AccentSecondary = Color3.fromRGB(59, 130, 246),
			GlowColor = Color3.fromRGB(96, 165, 250),
			BackgroundGradientTop = Color3.fromRGB(28, 36, 52),
			BackgroundGradientBottom = Color3.fromRGB(10, 14, 22),
			TopbarGradientTop = Color3.fromRGB(32, 42, 60),
			TopbarGradientBottom = Color3.fromRGB(18, 24, 36),
			ElementGradientTop = Color3.fromRGB(32, 40, 56),
			ElementGradientBottom = Color3.fromRGB(22, 28, 40),
		},

		-- ============================================================
		-- Serenity — soft pastel blue-grey
		-- ============================================================
		Serenity = {
			TextColor = Color3.fromRGB(48, 56, 66),

			Background = Color3.fromRGB(240, 245, 250),
			Topbar = Color3.fromRGB(216, 226, 238),
			Shadow = Color3.fromRGB(196, 208, 224),

			NotificationBackground = Color3.fromRGB(210, 221, 234),
			NotificationActionsBackground = Color3.fromRGB(226, 232, 242),

			TabBackground = Color3.fromRGB(202, 213, 226),
			TabStroke = Color3.fromRGB(182, 195, 210),
			TabBackgroundSelected = Color3.fromRGB(96, 165, 250),
			TabTextColor = Color3.fromRGB(52, 60, 72),
			SelectedTabTextColor = Color3.fromRGB(28, 32, 42),

			ElementBackground = Color3.fromRGB(212, 222, 234),
			ElementBackgroundHover = Color3.fromRGB(222, 231, 242),
			SecondaryElementBackground = Color3.fromRGB(202, 213, 226),
			ElementStroke = Color3.fromRGB(190, 203, 218),
			SecondaryElementStroke = Color3.fromRGB(182, 195, 210),

			SliderBackground = Color3.fromRGB(198, 216, 234),
			SliderProgress = Color3.fromRGB(96, 165, 250),
			SliderStroke = Color3.fromRGB(147, 197, 253),

			ToggleBackground = Color3.fromRGB(210, 221, 234),
			ToggleEnabled = Color3.fromRGB(96, 165, 250),
			ToggleDisabled = Color3.fromRGB(182, 186, 196),
			ToggleEnabledStroke = Color3.fromRGB(96, 165, 250),
			ToggleDisabledStroke = Color3.fromRGB(148, 152, 164),
			ToggleEnabledOuterStroke = Color3.fromRGB(120, 136, 158),
			ToggleDisabledOuterStroke = Color3.fromRGB(138, 142, 154),

			DropdownSelected = Color3.fromRGB(220, 230, 240),
			DropdownUnselected = Color3.fromRGB(200, 211, 224),

			InputBackground = Color3.fromRGB(220, 230, 240),
			InputStroke = Color3.fromRGB(182, 195, 210),
			PlaceholderColor = Color3.fromRGB(148, 154, 166),

			Accent = Color3.fromRGB(96, 165, 250),
			AccentSecondary = Color3.fromRGB(59, 130, 246),
			GlowColor = Color3.fromRGB(147, 197, 253),
			BackgroundGradientTop = Color3.fromRGB(250, 252, 255),
			BackgroundGradientBottom = Color3.fromRGB(232, 240, 248),
			TopbarGradientTop = Color3.fromRGB(240, 246, 252),
			TopbarGradientBottom = Color3.fromRGB(210, 222, 236),
			ElementGradientTop = Color3.fromRGB(224, 232, 242),
			ElementGradientBottom = Color3.fromRGB(204, 216, 230),
		},
	}
}

-- Services
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

-- Interface Management
local Rayfield = useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
local buildAttempts = 0
local correctBuild = false
local warned
local globalLoaded
local rayfieldDestroyed = false

repeat
	if Rayfield:FindFirstChild('Build') and Rayfield.Build.Value == InterfaceBuild then
		correctBuild = true
		break
	end

	correctBuild = false

	if not warned then
		warn('Rayfield | Build Mismatch')
		print('Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.')
		warned = true
	end

	toDestroy, Rayfield = Rayfield, useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
	if toDestroy and not useStudio then toDestroy:Destroy() end

	buildAttempts = buildAttempts + 1
until buildAttempts >= 2

Rayfield.Main.Topbar.ChangeSize.Image = ""
Rayfield.Main.Elements.Template.Dropdown.Toggle.Image = ""

Rayfield.Enabled = false

if gethui then
	Rayfield.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(Rayfield)
	Rayfield.Parent = CoreGui
elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
	Rayfield.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not useStudio then
	Rayfield.Parent = CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
			Interface.Enabled = false
			Interface.Name = "Rayfield-Old"
		end
	end
elseif not useStudio then
	for _, Interface in ipairs(CoreGui:GetChildren()) do
		if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
			Interface.Enabled = false
			Interface.Name = "Rayfield-Old"
		end
	end
end

local minSize = Vector2.new(1024, 768)
local useMobileSizing

if Rayfield.AbsoluteSize.X < minSize.X and Rayfield.AbsoluteSize.Y < minSize.Y then
	useMobileSizing = true
end

if UserInputService.TouchEnabled then
	useMobilePrompt = true
end

-- Object Variables
local Main = Rayfield.Main
local MPrompt = Rayfield:FindFirstChild('Prompt')
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList
local dragBar = Rayfield:FindFirstChild('Drag')
local dragInteract = dragBar and dragBar.Interact or nil
local dragBarCosmetic = dragBar and dragBar.Drag or nil

local dragOffset = 255
local dragOffsetMobile = 150

Rayfield.DisplayOrder = 100
LoadingFrame.Version.Text = Release

-- =====================================================================================
-- BASE VISUAL POLISH (applied once to the imported interface)
-- =====================================================================================
pcall(function()
	-- Rounded window + glass gradient
	addCorner(Main, 16)
	addGradient(Main, RayfieldLibrary.Theme.Default.BackgroundGradientTop, RayfieldLibrary.Theme.Default.BackgroundGradientBottom, 90)

	-- Soft glass blur + extra inner shadow layer
	addBlur(Main, 24)

	-- Topbar: rounded top corners + gradient
	addCorner(Topbar, 16)
	addGradient(Topbar, RayfieldLibrary.Theme.Default.TopbarGradientTop, RayfieldLibrary.Theme.Default.TopbarGradientBottom, 90)

	-- Loading frame polish
	addCorner(LoadingFrame, 16)

	-- Rounded tab buttons
	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			addCorner(tabbtn, 10)
		end
	end

	-- Rounded search bar
	addCorner(Main.Search, 10)
	addCorner(Main.Search.Input, 8)

	-- Rounded + glass notifications
	addCorner(Notifications.Template, 14)
	addGradient(Notifications.Template, RayfieldLibrary.Theme.Default.NotificationBackground, RayfieldLibrary.Theme.Default.BackgroundGradientBottom, 90)
	Notifications.Template.BackgroundTransparency = 0.45
end)

local Icons = useStudio and require(script.Parent.icons) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua')

-- Variables
local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local searchOpen = false
local Notifications = Rayfield.Notifications
local keybindConnections = {}

local SelectedTheme = RayfieldLibrary.Theme.Default

local function ChangeTheme(Theme)
	if typeof(Theme) == 'string' then
		SelectedTheme = RayfieldLibrary.Theme[Theme]
	elseif typeof(Theme) == 'table' then
		SelectedTheme = Theme
	end

	Rayfield.Main.BackgroundColor3 = SelectedTheme.Background
	Rayfield.Main.Topbar.BackgroundColor3 = SelectedTheme.Topbar
	Rayfield.Main.Topbar.CornerRepair.BackgroundColor3 = SelectedTheme.Topbar
	Rayfield.Main.Shadow.Image.ImageColor3 = SelectedTheme.Shadow

	-- Update gradients to match the new theme
	updateGradient(Rayfield.Main, SelectedTheme.BackgroundGradientTop or SelectedTheme.Background, SelectedTheme.BackgroundGradientBottom or SelectedTheme.Background)
	updateGradient(Rayfield.Main.Topbar, SelectedTheme.TopbarGradientTop or SelectedTheme.Topbar, SelectedTheme.TopbarGradientBottom or SelectedTheme.Topbar)

	Rayfield.Main.Topbar.ChangeSize.ImageColor3 = SelectedTheme.TextColor
	Rayfield.Main.Topbar.Hide.ImageColor3 = SelectedTheme.TextColor
	Rayfield.Main.Topbar.Search.ImageColor3 = SelectedTheme.TextColor
	if Topbar:FindFirstChild('Settings') then
		Rayfield.Main.Topbar.Settings.ImageColor3 = SelectedTheme.TextColor
		Rayfield.Main.Topbar.Divider.BackgroundColor3 = SelectedTheme.ElementStroke
	end

	Main.Search.BackgroundColor3 = SelectedTheme.TextColor
	Main.Search.Shadow.ImageColor3 = SelectedTheme.TextColor
	Main.Search.Search.ImageColor3 = SelectedTheme.TextColor
	Main.Search.Input.PlaceholderColor3 = SelectedTheme.TextColor
	Main.Search.UIStroke.Color = SelectedTheme.SecondaryElementStroke

	if Main:FindFirstChild('Notice') then
		Main.Notice.BackgroundColor3 = SelectedTheme.Background
	end

	for _, text in ipairs(Rayfield:GetDescendants()) do
		if text.Parent.Parent ~= Notifications then
			if text:IsA('TextLabel') or text:IsA('TextBox') then
				text.TextColor3 = SelectedTheme.TextColor
				text.Font = Enum.Font.Gotham
			end
		end
	end

	for _, TabPage in ipairs(Elements:GetChildren()) do
		for _, Element in ipairs(TabPage:GetChildren()) do
			if Element.ClassName == "Frame" and Element.Name ~= "Placeholder" and Element.Name ~= "SectionSpacing" and Element.Name ~= "Divider" and Element.Name ~= "SectionTitle" and Element.Name ~= "SearchTitle-fsefsefesfsefesfesfThanks" then
				Element.BackgroundColor3 = SelectedTheme.ElementBackground
				Element.UIStroke.Color = SelectedTheme.ElementStroke
				updateGradient(Element, SelectedTheme.ElementGradientTop or SelectedTheme.ElementBackground, SelectedTheme.ElementGradientBottom or SelectedTheme.ElementBackground)
			end
		end
	end
end

local function getIcon(name : string): {id: number, imageRectSize: Vector2, imageRectOffset: Vector2}
	if not Icons then
		warn("Lucide Icons: Cannot use icons as icons library is not loaded")
		return
	end
	name = string.match(string.lower(name), "^%s*(.*)%s*$") :: string
	local sizedicons = Icons['48px']
	local r = sizedicons[name]
	if not r then
		error(`Lucide Icons: Failed to find icon by the name of "{name}"`, 2)
	end

	local rirs = r[2]
	local riro = r[3]

	if type(r[1]) ~= "number" or type(rirs) ~= "table" or type(riro) ~= "table" then
		error("Lucide Icons: Internal error: Invalid auto-generated asset entry")
	end

	local irs = Vector2.new(rirs[1], rirs[2])
	local iro = Vector2.new(riro[1], riro[2])

	local asset = {
		id = r[1],
		imageRectSize = irs,
		imageRectOffset = iro,
	}

	return asset
end

local function getAssetUri(id: any): string
	local assetUri = "rbxassetid://0"
	if type(id) == "number" then
		assetUri = "rbxassetid://" .. id
	elseif type(id) == "string" and not Icons then
		warn("Rayfield | Cannot use Lucide icons as icons library is not loaded")
	else
		warn("Rayfield | The icon argument must either be an icon ID (number) or a Lucide icon name (string)")
	end
	return assetUri
end

local function makeDraggable(object, dragObject, enableTaptic, tapticOffset)
	local dragging = false
	local relative = nil

	local offset = Vector2.zero
	local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui and screenGui.IgnoreGuiInset then
		offset += getService('GuiService'):GetGuiInset()
	end

	local function connectFunctions()
		if dragBar and enableTaptic then
			dragBar.MouseEnter:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 120, 0, 4)}):Play()
				end
			end)

			dragBar.MouseLeave:Connect(function()
				if not dragging and not Hidden then
					TweenService:Create(dragBarCosmetic, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7, Size = UDim2.new(0, 100, 0, 4)}):Play()
				end
			end)
		end
	end

	connectFunctions()

	dragObject.InputBegan:Connect(function(input, processed)
		if processed then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = true

			relative = object.AbsolutePosition + object.AbsoluteSize * object.AnchorPoint - UserInputService:GetMouseLocation()
			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 110, 0, 4), BackgroundTransparency = 0}):Play()
			end
		end
	end)

	local inputEnded = UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end

		local inputType = input.UserInputType.Name
		if inputType == "MouseButton1" or inputType == "Touch" then
			dragging = false

			connectFunctions()

			if enableTaptic and not Hidden then
				TweenService:Create(dragBarCosmetic, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.7}):Play()
			end
		end
	end)

	local renderStepped = RunService.RenderStepped:Connect(function()
		if dragging and not Hidden then
			local position = UserInputService:GetMouseLocation() + relative + offset
			if enableTaptic and tapticOffset then
				TweenService:Create(object, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y)}):Play()
				TweenService:Create(dragObject.Parent, TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))}):Play()
			else
				if dragBar and tapticOffset then
					dragBar.Position = UDim2.fromOffset(position.X, position.Y + ((useMobileSizing and tapticOffset[2]) or tapticOffset[1]))
				end
				object.Position = UDim2.fromOffset(position.X, position.Y)
			end
		end
	end)

	object.Destroying:Connect(function()
		if inputEnded then inputEnded:Disconnect() end
		if renderStepped then renderStepped:Disconnect() end
	end)
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadConfiguration(Configuration)
	local success, Data = pcall(function() return HttpService:JSONDecode(Configuration) end)
	local changed

	if not success then warn('Rayfield had an issue decoding the configuration file, please try delete the file and reopen Rayfield.') return end

	for FlagName, Flag in pairs(RayfieldLibrary.Flags) do
		local FlagValue = Data[FlagName]

		if (typeof(FlagValue) == 'boolean' and FlagValue == false) or FlagValue then
			task.spawn(function()
				if Flag.Type == "ColorPicker" then
					changed = true
					Flag:Set(UnpackColor(FlagValue))
				else
					if (Flag.CurrentValue or Flag.CurrentKeybind or Flag.CurrentOption or Flag.Color) ~= FlagValue then 
						changed = true
						Flag:Set(FlagValue) 	
					end
				end
			end)
		else
			warn("Rayfield | Unable to find '"..FlagName.. "' in the save file.")
			print("The error above may not be an issue if new elements have been added or not been set values.")
		end
	end

	return changed
end

local function SaveConfiguration()
	if not CEnabled or not globalLoaded then return end

	if debugX then
		print('Saving')
	end

	local Data = {}
	for i, v in pairs(RayfieldLibrary.Flags) do
		if v.Type == "ColorPicker" then
			Data[i] = PackColor(v.Color)
		else
			if typeof(v.CurrentValue) == 'boolean' then
				if v.CurrentValue == false then
					Data[i] = false
				else
					Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
				end
			else
				Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption or v.Color
			end
		end
	end
	if useStudio then
		if script.Parent:FindFirstChild('configuration') then script.Parent.configuration:Destroy() end

		local ScreenGui = Instance.new("ScreenGui")
		ScreenGui.Parent = script.Parent
		ScreenGui.Name = 'configuration'

		local TextBox = Instance.new("TextBox")
		TextBox.Parent = ScreenGui
		TextBox.Size = UDim2.new(0, 800, 0, 50)
		TextBox.AnchorPoint = Vector2.new(0.5, 0)
		TextBox.Position = UDim2.new(0.5, 0, 0, 30)
		TextBox.Text = HttpService:JSONEncode(Data)
		TextBox.ClearTextOnFocus = false
	end

	if debugX then
		warn(HttpService:JSONEncode(Data))
	end

	callSafely(writefile, ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension, tostring(HttpService:JSONEncode(Data)))
end

function RayfieldLibrary:Notify(data)
	task.spawn(function()
		-- Notification Object Creation
		local newNotification = Notifications.Template:Clone()
		newNotification.Name = data.Title or 'No Title Provided'
		newNotification.Parent = Notifications
		newNotification.LayoutOrder = #Notifications:GetChildren()
		newNotification.Visible = false

		-- Glass + rounded corners
		addCorner(newNotification, 14)
		addGradient(newNotification, SelectedTheme.NotificationBackground, SelectedTheme.BackgroundGradientBottom or SelectedTheme.Background, 90)
		addBlur(newNotification, 20)

		-- Set Data
		newNotification.Title.Text = data.Title or "Unknown Title"
		newNotification.Description.Text = data.Content or "Unknown Content"

		if data.Image then
			if typeof(data.Image) == 'string' and Icons then
				local asset = getIcon(data.Image)

				newNotification.Icon.Image = 'rbxassetid://'..asset.id
				newNotification.Icon.ImageRectOffset = asset.imageRectOffset
				newNotification.Icon.ImageRectSize = asset.imageRectSize
			else
				newNotification.Icon.Image = getAssetUri(data.Image)
			end
		else
			newNotification.Icon.Image = "rbxassetid://" .. 0
		end

		-- Beautiful entrance: fade + slide + scale
		newNotification.Title.TextColor3 = SelectedTheme.TextColor
		newNotification.Description.TextColor3 = SelectedTheme.TextColor
		newNotification.BackgroundColor3 = SelectedTheme.Background
		newNotification.UIStroke.Color = SelectedTheme.TextColor
		newNotification.Icon.ImageColor3 = SelectedTheme.TextColor

.fromRGB(147, 197, 253),
			BackgroundGradientTop = Color3.fromRGB(250, 252, 255),
			BackgroundGradientBottom = Color3.fromRGB(232, 240, 248),
			TopbarGradientTop = Color3.fromRGB(240, 246, 252),
			TopbarGradientBottom = Color3.fromRGB(210, 222, 236),
			ElementGradientTop = Color3.fromRGB(224, 232, 242),
			ElementGradientBottom = Color3.fromRGB(204, 216, 230),
		},
	}
}

-- Services
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

-- Interface Management
local Rayfield = useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
local buildAttempts = 0
local correctBuild = false
local warned
local globalLoaded
local rayfieldDestroyed = false

repeat
	if Rayfield:FindFirstChild('Build') and Rayfield.Build.Value == InterfaceBuild then
		correctBuild = true
		break
	end

	correctBuild = false

	if not warned then
		warn('Rayfield | Build Mismatch')
		print('Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.')
		warned = true
	end

	toDestroy, Rayfield = Rayfield, useStudio and script.Parent:FindFirstChild('Rayfield') or game:GetObjects("rbxassetid://10804731440")[1]
	if toDestroy and not useStudio then toDestroy:Destroy() end

	buildAttempts = buildAttempts + 1
until buildAttempts >= 2

Rayfield.Main.Topbar.ChangeSize.Image = ""
Rayfield.Main.Elements.Template.Dropdown.Toggle.Image = ""

Rayfield.Enabled = false

if gethui then
	Rayfield.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(Rayfield)
	Rayfield.Parent = CoreGui
elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
	Rayfield.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not useStudio then
	Rayfield.Parent = CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
			Interface.Enabled = false
			Interface.Name = "Rayfield-Old"
		end
	end
elseif not useStudio then
	for _, Interface in ipairs(CoreGui:GetChildren()) do
		if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
			Interface.Enabled = false
			Interface.Name = "Rayfield-Old"
		end
	end
end

local minSize = Vector2.new(1024, 768)
local useMobileSizing

if Rayfield.AbsoluteSize.X < minSize.X and Rayfield.AbsoluteSize.Y < minSize.Y then
	useMobileSizing = true
end

if UserInputService.TouchEnabled then
	useMobilePrompt = true
end

-- Object Variables
local Main = Rayfield.Main
local MPrompt = Rayfield:FindFirstChild('Prompt')
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList
local dragBar = Rayfield:FindFirstChild('Drag')
local dragInteract = dragBar and dragBar.Interact or nil
local dragBarCosmetic = dragBar and dragBar.Drag or nil

local dragOffset = 255
local dragOffsetMobile = 150

Rayfield.DisplayOrder = 100
LoadingFrame.Version.Text = Release

-- =====================================================================================
-- BASE VISUAL POLISH (applied once to the imported interface)
-- =====================================================================================
pcall(function()
	-- Rounded window + glass gradient
	addCorner(Main, 16)
	addGradient(Main, RayfieldLibrary.Theme.Default.BackgroundGradientTop, RayfieldLibrary.Theme.Default.BackgroundGradientBottom, 90)

	-- Soft glass blur + extra inner shadow layer
	addBlur(Main, 24)

	-- Topbar: rounded top corners + gradient
	addCorner(Topbar, 16)
	addGradient(Topbar, RayfieldLibrary.Theme.Default.TopbarGradientTop, RayfieldLibrary.Theme.Default.TopbarGradientBottom, 90)

	-- Loading frame polish
	addCorner(LoadingFrame, 16)

	-- Rounded tab buttons
	for _, tabbtn in ipairs(TabList:GetChildren()) do
		if tabbtn.ClassName == "Frame" and tabbtn.Name ~= "Placeholder" then
			addCorner(tabbtn, 10)
		end
	end

	-- Rounded search bar
	addCorner(Main.Search, 10)
	addCorner(Main.Search.Input, 8)

	-- Rounded + glass notifications
	addCorner(Notifications.Template, 14)
	addGradient(Notifications.Template, RayfieldLibrary.Theme.Default.NotificationBackground, RayfieldLibrary.Theme.Default.BackgroundGradientBottom, 90)
	Notifications.Template.BackgroundTransparency = 0.45
end)

local Icons = useStudio and require(script.Parent.icons) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua')

-- Variables
local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local searchOpen = false
local Notifications = Rayfield.Notifications
local keybindConnections = {}

local SelectedTheme = RayfieldLibrary.Theme.Default

local function ChangeTheme(Theme)
