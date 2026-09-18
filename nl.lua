--[[
                          Neverlose.cc UI Library
    Author: 4lpaca
    License: MIT
    Discord: https://arceney.win/discord
    Other-Projects: https://4lpaca.win
]]

writefile = writefile or function() end
makefolder = makefolder or function() end
readfile = readfile or function() return "" end
delfile = delfile or function() end
delfolder = delfolder or function() end
listfiles = listfiles or function() return {} end
isfile = isfile or function() return false end
isfolder = isfolder or function() return false end

do
	local Constant = 'L'..'P'..'H'..'_NO_VIRTUALIZE';
	getfenv()[Constant] = getfenv()[Constant] or function(f) return f end;
end;

cloneref = cloneref or function(i) return i end;
gethui = gethui or get_hidden_gui;
getcustomasset = getcustomasset or getsynasset;
getgenv = getgenv or getfenv;

local LOAD_ENV = LPH_NO_VIRTUALIZE(function()
	if game:GetService('RunService'):IsStudio() then
		local BaseWorkspace = game:GetService("ReplicatedFirst"):FindFirstChild('PRI_WORKSPACE') or Instance.new('Folder',game:GetService("ReplicatedFirst"));
		BaseWorkspace.Name = 'PRI\0.'..tostring(string.char(math.random(50,120)))..tostring(string.char(math.random(50,120)))..tostring(string.char(math.random(50,120)))..tostring(string.char(math.random(50,120)))..tostring(string.char(math.random(50,120)))..tostring(string.char(math.random(50,120)));
		local __get_path_c = function(path)
			return (string.find(path,'/',1,true) and string.split(path,'/')) or (string.find(path,'\\',1,true) and string.split(path,'\\')) or {path};
		end;
		local __get_path = function(path)
			local main = __get_path_c(path);
			local block = BaseWorkspace;
			for i,v in next , main do
				block = block[v];
			end;
			return block;
		end;
		getgenv().readfile = function(path)
			local path : StringValue = __get_path(path);
			return path.Value;
		end;
		getgenv().isfile = function(path)
			local success , message = pcall(function() return __get_path(path); end);
			if success and not message:IsA("Folder") then return true; end;
			return false;
		end;
		getgenv().isfolder = function(path)
			local success , message = pcall(function() return __get_path(path); end);
			if success and message:IsA("Folder") then return true; end;
			return false;
		end;
		getgenv().writefile = function(path,content)
			local main = __get_path_c(path);
			local block = BaseWorkspace;
			for i,v in next , main do
				local item = block:FindFirstChild(v);
				if not item then
					local c = Instance.new('StringValue',block);
					c.Name = tostring(v);
					c.Value = content;
				else
					if item:IsA('StringValue') and tostring(item) == v then
						item.Name = tostring(v);
						item.Value = content;
					end;
					block = item;
				end;
			end;
		end;
		getgenv().listfiles = function(path)
			local fold = __get_path(path);
			local pa = {};
			for i,v in next , fold:GetChildren() do
				if v:IsA('StringValue') then
					table.insert(pa,path..'/'..tostring(v));
				end;
			end;
			return pa;
		end;
		getgenv().makefolder = function(path)
			local main = __get_path_c(path);
			local block = BaseWorkspace;
			for i,v in next , main do
				local item = block:FindFirstChild(v);
				if not item then
					local c = Instance.new('Folder',block);
					c.Name = tostring(v);
				else
					block = item;
				end;
			end;
		end;
		getgenv().delfile = function(path)
			local main = __get_path_c(path);
			local block = BaseWorkspace;
			for i,v in next , main do
				local item = block:FindFirstChild(v);
				if item and item:IsA('StringValue') then
					item:Destroy();
				else
					block = item;
				end;
			end;
		end;
	end;
end)

LOAD_ENV();

writefile = writefile or getgenv().writefile;
makefolder = makefolder or getgenv().makefolder;
readfile = readfile or getgenv().readfile;
delfolder = delfolder or getgenv().delfolder;
delfile = delfile or getgenv().delfile;
listfiles = listfiles or getgenv().listfiles;
isfolder = isfolder or getgenv().isfolder;
isfile = isfile or getgenv().isfile;

local NeverLose = {};

NeverLose.BuiltInRegular = Font.new('rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json',Enum.FontWeight.Regular,Enum.FontStyle.Normal);
NeverLose.BuiltInBold = Font.new('rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json',Enum.FontWeight.Bold,Enum.FontStyle.Normal);
NeverLose.GlobalSignals = {};
NeverLose.UnloadEnabled = false;

local cloneref: cloneref = cloneref or function(f) return f end;
local TweenService: TweenService = cloneref(game:GetService('TweenService'));
local UserInputService: UserInputService = cloneref(game:GetService('UserInputService'));
local TextService: TextService = cloneref(game:GetService('TextService'));
local RunService: RunService = cloneref(game:GetService('RunService'));
local Players: Players = cloneref(game:GetService('Players'));
local HttpService: HttpService = cloneref(game:GetService('HttpService'));
local LocalPlayer: Player = Players.LocalPlayer;
local CoreGui: PlayerGui = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or cloneref(game:FindFirstChild('CoreGui')) or cloneref(LocalPlayer.PlayerGui);
local Mouse: Mouse = LocalPlayer:GetMouse();
local CurrentCamera: Camera = cloneref(workspace.CurrentCamera);
local ProtectGui = protect_gui or protectgui or (syn and syn.protect_gui) or function(s) return s; end;
local GlobalWindow = Instance.new('ScreenGui');
local ManualTween = TweenInfo.new(0.1);
local SlowyTween = TweenInfo.new(0.175);
local FastTween = TweenInfo.new(0.05);
local VSlowTween = TweenInfo.new(0.5,Enum.EasingStyle.Quint);
local Encryption = {};

NeverLose.UserProfile = Players:GetUserThumbnailAsync(LocalPlayer.UserId , Enum.ThumbnailType.HeadShot , Enum.ThumbnailSize.Size150x150)
NeverLose.RandomString = LPH_NO_VIRTUALIZE(function()
	return string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4))..string.rep(string.char(math.random(1,7)),math.random(1,4));
end);

ProtectGui(GlobalWindow);

GlobalWindow.Name = NeverLose.RandomString();
GlobalWindow.IgnoreGuiInset = true;
GlobalWindow.ZIndexBehavior = Enum.ZIndexBehavior.Global;
GlobalWindow.ResetOnSpawn = false;
GlobalWindow.Parent = CoreGui;

NeverLose.Scales = {
	Small = UDim2.fromOffset(540,380),
	Mobile = UDim2.fromOffset(640,385),
	Default = UDim2.fromOffset(640 , 480),
	Large = UDim2.fromOffset(800 , 600)
};

NeverLose.IconColor = Color3.fromRGB(255, 255, 255);
NeverLose.ScreenGui = GlobalWindow;
NeverLose.Flags = {};
NeverLose.AccentColor = Color3.fromRGB(78, 127, 252);
NeverLose.MainColor = Color3.fromRGB(8, 8, 13);
NeverLose.RegisiteryColor = {};
NeverLose.NameRegisitry = {};
NeverLose.IsMosueOverOtherFrame = false;
NeverLose.GlobalLogo = "rbxassetid://120358385035996";
NeverLose.ImageColorMapping = "rbxassetid://4155801252";

NeverLose.LoadIcon = LPH_NO_VIRTUALIZE(function()
	NeverLose.RobloxIcon = {};
end);

NeverLose.IsMouseOverFrame = LPH_NO_VIRTUALIZE(function(self , Frame)
	if not Frame then return; end;
	local AbsPos: Vector2, AbsSize: Vector2 = Frame.AbsolutePosition, Frame.AbsoluteSize;
	if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
		return true;
	end;
end);

NeverLose.CreateSignal = LPH_NO_VIRTUALIZE(function(self , DefaultValue)
	local __cache = Instance.new('BindableEvent');
	local bind = {
		Value = DefaultValue,
		__event = __cache
	};
	function bind:GetValue() return bind.Value; end;
	function bind:SetValue(f) bind.Value = f; return __cache:Fire(f); end;
	function bind:Connect(f)
		local signal = __cache.Event:Connect(f);
		NeverLose:AddSignal(signal);
		return signal;
	end;
	return bind;
end);

NeverLose.SetIconMode = LPH_NO_VIRTUALIZE(function(self , Label: TextLabel , Icon: string)
	local useBold = string.lower(string.sub(Icon , -5)) == '-bold';
	if useBold then
		Label.Text = Icon:sub(1,-6);
		Label.FontFace = NeverLose.BuiltInBold;
	else
		Label.Text = Icon;
		Label.FontFace = NeverLose.BuiltInRegular;
	end;
end);

function NeverLose:AddSignal(RBXSignal)
	if NeverLose.UnloadEnabled then
		table.insert(NeverLose.GlobalSignals,RBXSignal);
	end;
	return RBXSignal;
end;

function NeverLose:AddQuery(ItemRoot: Frame , Name : string)
	table.insert(NeverLose.NameRegisitry , { Root = ItemRoot, Idx = Name });
end;

function NeverLose:MoreThanHalfY(Value: number)
	return (NeverLose.ScreenGui.AbsoluteSize.Y / 2) < Value
end;

NeverLose.IsStudio = RunService:IsStudio();
NeverLose.IsMobile = UserInputService.TouchEnabled;

NeverLose.CreateInput = LPH_NO_VIRTUALIZE(function(self , Frame , Callback)
	local Button = Instance.new('ImageButton',Frame);
	Button.ZIndex = Frame.ZIndex + 10;
	Button.Size = UDim2.fromScale(1,1);
	Button.BackgroundTransparency = 1;
	Button.ImageTransparency = 1;
	Button.Image = "rbxasset://textuers/translateIcon.png";
	if Callback then
		local bth_signal = Button.MouseButton1Click:Connect(Callback);
		return Button , bth_signal;
	end;
	return Button;
end);

NeverLose.PlayAnimate = LPH_NO_VIRTUALIZE(function(Self , Info , Property)
	local Tween = TweenService:Create(Self , Info or TweenInfo.new(0.25) , Property);
	Tween:Play();
	return Tween;
end);

NeverLose.Drag = LPH_NO_VIRTUALIZE(function(InputFrame: Frame, MoveFrame: Frame, Speed : number)
	local dragToggle: boolean = false;
	local dragStart: Vector3 = nil;
	local startPos: UDim2 = nil;
	local Tween = TweenInfo.new(Speed);
	local updateInput = function(input)
		local delta = input.Position - dragStart;
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y);
		NeverLose.PlayAnimate(MoveFrame,Tween,{ Position = position });
	end;
	NeverLose:AddSignal(InputFrame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
			dragToggle = true;
			dragStart = input.Position;
			startPos = MoveFrame.Position;
			local input_end;
			input_end = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false;
					input_end:Disconnect();
				end
			end)
		end
	end));
	NeverLose:AddSignal(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragToggle then updateInput(input) end
		end
	end));
end);

NeverLose.Rounding = LPH_NO_VIRTUALIZE(function(num, numDecimalPlaces)
	local mult = 10 ^ (numDecimalPlaces or 0);
	return math.floor(num * mult + 0.5) / mult;
end);

NeverLose.ProcessParams = LPH_NO_VIRTUALIZE(function(self , Params , Fixed)
	Params = Params or {};
	local k = Params or {};
	for i,v in next , Fixed do k[i] = Params[i] or v; end;
	table.clear(Fixed);
	return k;
end);

function NeverLose:CreateShadow(parent , RollingEffect)
	local Shadow = {};
	local UIShadowSafe85 = Instance.new("UIStroke")
	local UIShadowSafe65 = Instance.new("UIStroke")
	local UIShadowSafe50 = Instance.new("UIStroke")
	local UIShadowSafe45 = Instance.new("UIStroke")
	UIShadowSafe85.Thickness = 6.000; UIShadowSafe85.Transparency = 1; UIShadowSafe85.Parent = parent
	UIShadowSafe65.Thickness = 5.000; UIShadowSafe65.Transparency = 1; UIShadowSafe65.Parent = parent
	UIShadowSafe50.Thickness = 4.000; UIShadowSafe50.Transparency = 1; UIShadowSafe50.Parent = parent
	UIShadowSafe45.Thickness = 3.000; UIShadowSafe45.Transparency = 1; UIShadowSafe45.Parent = parent
	Shadow.Render = LPH_NO_VIRTUALIZE(function(self , value)
		if value then
			NeverLose.PlayAnimate(UIShadowSafe85 , SlowyTween , { Transparency = 0.900 })
			NeverLose.PlayAnimate(UIShadowSafe65 , SlowyTween , { Transparency = 0.900 })
			NeverLose.PlayAnimate(UIShadowSafe50 , SlowyTween , { Transparency = 0.900 })
			NeverLose.PlayAnimate(UIShadowSafe45 , SlowyTween , { Transparency = 0.900 })
		else
			NeverLose.PlayAnimate(UIShadowSafe85 , SlowyTween , { Transparency = 1 })
			NeverLose.PlayAnimate(UIShadowSafe65 , SlowyTween , { Transparency = 1 })
			NeverLose.PlayAnimate(UIShadowSafe50 , SlowyTween , { Transparency = 1 })
			NeverLose.PlayAnimate(UIShadowSafe45 , SlowyTween , { Transparency = 1 })
		end;
	end);
	return Shadow;
end;

function NeverLose:CreateOptionWindow(Frame: Frame , Zindex)
	Zindex = Zindex or 9;
	local Window = { Signal = NeverLose:CreateSignal(false) };
	local OptionHandler = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIListLayout = Instance.new("UIListLayout")
	local UIStroke = Instance.new("UIStroke")
	local shadow = NeverLose:CreateShadow(OptionHandler);

	OptionHandler.Name = NeverLose.RandomString();
	OptionHandler.Parent = NeverLose.ScreenGui
	OptionHandler.AnchorPoint = Vector2.new(0, 0)
	OptionHandler.BackgroundColor3 = Color3.fromRGB(20, 22, 27)
	OptionHandler.BackgroundTransparency = 0.035
	OptionHandler.BorderSizePixel = 0
	OptionHandler.ClipsDescendants = true
	OptionHandler.Position = UDim2.new(255,255,255,255)
	OptionHandler.Size = UDim2.new(0, 220, 0, 75)
	OptionHandler.ZIndex = Zindex + 9

	UICorner.CornerRadius = UDim.new(0, 10); UICorner.Parent = OptionHandler
	UIListLayout.Parent = OptionHandler
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIStroke.Transparency = 0.650; UIStroke.Color = Color3.fromRGB(45, 48, 58); UIStroke.Parent = OptionHandler

	NeverLose:AddSignal(UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(LPH_NO_VIRTUALIZE(function()
		NeverLose.PlayAnimate(OptionHandler , SlowyTween , { Size = UDim2.new(0, 220, 0, UIListLayout.AbsoluteContentSize.Y - 1) })
	end)));

	NeverLose:AddSignal(OptionHandler:GetPropertyChangedSignal('BackgroundTransparency'):Connect(LPH_NO_VIRTUALIZE(function()
		if OptionHandler.BackgroundTransparency > 0.9 then
			OptionHandler.Visible = false; UIListLayout.Parent = nil; OptionHandler.Parent = nil;
		else
			OptionHandler.Visible = true; UIListLayout.Parent = OptionHandler
			OptionHandler.Parent = NeverLose.ScreenGui;
		end
	end)));

	local SetPosition = LPH_NO_VIRTUALIZE(function()
		if NeverLose:MoreThanHalfY(Frame.AbsolutePosition.Y + 65) then
			OptionHandler.AnchorPoint = Vector2.new(0,1)
		else
			OptionHandler.AnchorPoint = Vector2.new(0,0)
		end;
		OptionHandler.Position = UDim2.fromOffset(Frame.AbsolutePosition.X + 18 , Frame.AbsolutePosition.Y + 65);
	end);

	Window.SetRender = LPH_NO_VIRTUALIZE(function(value)
		if value then
			SetPosition();
			NeverLose.PlayAnimate(OptionHandler , SlowyTween , { BackgroundTransparency = 0.035 })
			NeverLose.PlayAnimate(UIStroke , SlowyTween , { Transparency = 0.650 })
			shadow:Render(true);
			OptionHandler.Parent = NeverLose.ScreenGui;
		else
			NeverLose.PlayAnimate(OptionHandler , SlowyTween , { BackgroundTransparency = 1 })
			NeverLose.PlayAnimate(UIStroke , SlowyTween , { Transparency = 1 })
			shadow:Render(false);
		end;
	end);

	Window.SetRender(false);
	Window.Signal:Connect(Window.SetRender)
	return Window;
end;

-- ==== СОЗДАТЕЛЬ ОКОН ====
function NeverLose:CreateWindow(Config)
	Config = Config or {};
	Config.Name = Config.Name or "Neverlose"
	Config.Content = Config.Content or "Roblox"
	Config.Size = Config.Size or NeverLose.Scales.Default
	Config.Keybind = Config.Keybind or "Insert"
	Config.Logo = Config.Logo or NeverLose.GlobalLogo

	local Window = {
		Signal = NeverLose:CreateSignal(true),
		Tabs = {},
		CurrentTab = 1,
		Keybind = Config.Keybind,
		Name = Config.Name,
		Size = Config.Size,
	};

	local WindowFrame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local LeftMenu = Instance.new("Frame")
	local RightMenu = Instance.new("Frame")
	local HeadFrame = Instance.new("Frame")
	local LogoImage = Instance.new("ImageLabel")
	local WindowName = Instance.new("TextLabel")
	local WindowContent = Instance.new("TextLabel")
	local LeftScrolling = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local TabContainer = Instance.new("Frame")

	WindowFrame.Name = "NLWindow"
	WindowFrame.Parent = NeverLose.ScreenGui
	WindowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	WindowFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
	WindowFrame.BackgroundTransparency = 0.055
	WindowFrame.BorderSizePixel = 0
	WindowFrame.ClipsDescendants = true
	WindowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	WindowFrame.Size = Config.Size
	WindowFrame.Active = true;

	UICorner.CornerRadius = UDim.new(0, 12)
	UICorner.Parent = WindowFrame

	LeftMenu.Parent = WindowFrame
	LeftMenu.BackgroundTransparency = 1
	LeftMenu.Size = UDim2.new(0, 175, 1, 0)

	HeadFrame.Parent = LeftMenu
	HeadFrame.BackgroundTransparency = 1
	HeadFrame.Size = UDim2.new(1, 0, 0, 50)

	LogoImage.Parent = HeadFrame
	LogoImage.AnchorPoint = Vector2.new(0, 0.5)
	LogoImage.BackgroundTransparency = 1
	LogoImage.Position = UDim2.new(0, 10, 0.5, 0)
	LogoImage.Size = UDim2.new(0, 35, 0, 35)
	LogoImage.Image = Config.Logo
	LogoImage.ImageColor3 = NeverLose.IconColor
	local logoCorner = Instance.new("UICorner")
	logoCorner.CornerRadius = UDim.new(0, 7)
	logoCorner.Parent = LogoImage

	WindowName.Parent = HeadFrame
	WindowName.BackgroundTransparency = 1
	WindowName.Position = UDim2.new(0, 55, 0, 4)
	WindowName.Size = UDim2.new(0, 200, 0, 25)
	WindowName.Font = Enum.Font.GothamBold
	WindowName.Text = Config.Name
	WindowName.TextColor3 = Color3.fromRGB(255, 255, 255)
	WindowName.TextSize = 18
	WindowName.TextXAlignment = Enum.TextXAlignment.Left

	WindowContent.Parent = HeadFrame
	WindowContent.BackgroundTransparency = 1
	WindowContent.Position = UDim2.new(0, 55, 0, 25)
	WindowContent.Size = UDim2.new(0, 200, 0, 15)
	WindowContent.Font = Enum.Font.GothamBold
	WindowContent.Text = Config.Content
	WindowContent.TextColor3 = Color3.fromRGB(255, 255, 255)
	WindowContent.TextSize = 9
	WindowContent.TextTransparency = 0.65
	WindowContent.TextXAlignment = Enum.TextXAlignment.Left

	LeftScrolling.Parent = LeftMenu
	LeftScrolling.Active = true
	LeftScrolling.AnchorPoint = Vector2.new(0.5, 0)
	LeftScrolling.BackgroundTransparency = 1
	LeftScrolling.Position = UDim2.new(0.5, 0, 0, 60)
	LeftScrolling.Size = UDim2.new(1, -10, 1, -70)
	LeftScrolling.ScrollBarThickness = 0
	LeftScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)

	UIListLayout.Parent = LeftScrolling
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)

	RightMenu.Parent = WindowFrame
	RightMenu.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
	RightMenu.BackgroundTransparency = 0.6
	RightMenu.BorderSizePixel = 0
	RightMenu.ClipsDescendants = true
	RightMenu.Position = UDim2.new(0, 176, 0, 0)
	RightMenu.Size = UDim2.new(1, -176, 1, 0)
	local rightCorner = Instance.new("UICorner")
	rightCorner.CornerRadius = UDim.new(0, 13)
	rightCorner.Parent = RightMenu
	local rightStroke = Instance.new("UIStroke")
	rightStroke.Transparency = 0.65
	rightStroke.Color = Color3.fromRGB(45, 48, 58)
	rightStroke.Parent = RightMenu

	TabContainer.Parent = RightMenu
	TabContainer.BackgroundTransparency = 1
	TabContainer.ClipsDescendants = true
	TabContainer.Position = UDim2.new(0, 0, 0, 0)
	TabContainer.Size = UDim2.new(1, 0, 1, 0)

	local DragFrame = Instance.new("Frame")
	DragFrame.Parent = WindowFrame
	DragFrame.BackgroundTransparency = 1
	DragFrame.Size = UDim2.new(1, 0, 0, 50)
	DragFrame.ZIndex = 7
	NeverLose.Drag(DragFrame, WindowFrame, 0.15)

	function Window:SetRender(value)
		if value then
			WindowFrame.Visible = true
			WindowFrame.Parent = NeverLose.ScreenGui
			NeverLose.PlayAnimate(WindowFrame, SlowyTween, { BackgroundTransparency = 0.055 })
		else
			NeverLose.PlayAnimate(WindowFrame, SlowyTween, { BackgroundTransparency = 1 })
		end
	end

	function Window:ToggleInterface()
		local newval = not Window.Signal:GetValue()
		Window.Signal:SetValue(newval)
		if newval then
			WindowFrame.Visible = true
			WindowFrame.Parent = NeverLose.ScreenGui
			NeverLose.PlayAnimate(WindowFrame, SlowyTween, { BackgroundTransparency = 0.055 })
		else
			NeverLose.PlayAnimate(WindowFrame, SlowyTween, { BackgroundTransparency = 1 })
		end
	end

	NeverLose:AddSignal(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode.Name == Window.Keybind then
			Window:ToggleInterface()
		end
	end))

	-- ==== ЗАГОЛОВОК КАТЕГОРИИ ====
	function Window:AddTabLabel(Name)
		local TabLabel = Instance.new("TextLabel")
		TabLabel.Name = NeverLose.RandomString()
		TabLabel.Parent = LeftScrolling
		TabLabel.BackgroundTransparency = 1
		TabLabel.Size = UDim2.new(1, -7, 0, 15)
		TabLabel.ZIndex = 8
		TabLabel.Font = Enum.Font.GothamBold
		TabLabel.Text = Name
		TabLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
		TabLabel.TextSize = 11
		TabLabel.TextTransparency = 0.4
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left
		TabLabel.LayoutOrder = #LeftScrolling:GetChildren() + 1

		local SetRender = LPH_NO_VIRTUALIZE(function(val)
			NeverLose.PlayAnimate(TabLabel, SlowyTween, {
				TextTransparency = val and 0.4 or 1
			})
		end)
		SetRender(Window.Signal:GetValue())
		Window.Signal:Connect(SetRender)
		return TabLabel
	end

	function Window:AddTab(Config)
		Config = Config or {}
		Config.Name = Config.Name or "Tab"
		Config.Icon = Config.Icon or "crosshairs"

		local Tab = { Signal = NeverLose:CreateSignal(false) }
		local TabButton = Instance.new("Frame")
		local TabIcon = Instance.new("TextLabel")
		local TabLabel = Instance.new("TextLabel")
		local TabFrame = Instance.new("Frame")
		local LeftScroll = Instance.new("ScrollingFrame")
		local RightScroll = Instance.new("ScrollingFrame")
		local LL1 = Instance.new("UIListLayout")
		local LL2 = Instance.new("UIListLayout")
		local TabCorner = Instance.new("UICorner")

		TabButton.Parent = LeftScrolling
		TabButton.BackgroundColor3 = Color3.fromRGB(41, 45, 49)
		TabButton.BackgroundTransparency = 0.5
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(1, -1, 0, 30)
		TabButton.LayoutOrder = #LeftScrolling:GetChildren() + 1

		TabCorner.CornerRadius = UDim.new(0, 6)
		TabCorner.Parent = TabButton

		TabIcon.Parent = TabButton
		TabIcon.AnchorPoint = Vector2.new(0, 0.5)
		TabIcon.BackgroundTransparency = 1
		TabIcon.Position = UDim2.new(0, 2, 0.5, 0)
		TabIcon.Size = UDim2.new(0, 25, 0, 25)
		TabIcon.FontFace = NeverLose.BuiltInBold
		TabIcon.Text = Config.Icon
		TabIcon.TextColor3 = NeverLose.AccentColor
		TabIcon.TextSize = 16

		TabLabel.Parent = TabButton
		TabLabel.AnchorPoint = Vector2.new(0, 0.5)
		TabLabel.BackgroundTransparency = 1
		TabLabel.Position = UDim2.new(0, 30, 0.5, 0)
		TabLabel.Size = UDim2.new(1, -7, 0, 15)
		TabLabel.Font = Enum.Font.GothamMedium
		TabLabel.Text = Config.Name
		TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TabLabel.TextSize = 12
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left

		TabFrame.Parent = TabContainer
		TabFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		TabFrame.BackgroundTransparency = 1
		TabFrame.ClipsDescendants = true
		TabFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		TabFrame.Size = UDim2.new(1, 0, 1, 0)

		LeftScroll.Parent = TabFrame
		LeftScroll.Active = true
		LeftScroll.AnchorPoint = Vector2.new(0.5, 0.5)
		LeftScroll.BackgroundTransparency = 1
		LeftScroll.Position = UDim2.new(0.25, 0, 0.5, 0)
		LeftScroll.Size = UDim2.new(0.5, 0, 1, -5)
		LeftScroll.ScrollBarThickness = 0
		LL1.Parent = LeftScroll
		LL1.HorizontalAlignment = Enum.HorizontalAlignment.Right
		LL1.SortOrder = Enum.SortOrder.LayoutOrder
		LL1.Padding = UDim.new(0, 5)

		RightScroll.Parent = TabFrame
		RightScroll.Active = true
		RightScroll.AnchorPoint = Vector2.new(0.5, 0.5)
		RightScroll.BackgroundTransparency = 1
		RightScroll.Position = UDim2.new(0.75, 0, 0.5, 0)
		RightScroll.Size = UDim2.new(0.5, 0, 1, -5)
		RightScroll.ScrollBarThickness = 0
		LL2.Parent = RightScroll
		LL2.SortOrder = Enum.SortOrder.LayoutOrder
		LL2.Padding = UDim.new(0, 5)

		NeverLose:AddSignal(LL1:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			LeftScroll.CanvasSize = UDim2.fromOffset(0, LL1.AbsoluteContentSize.Y + 1)
		end))
		NeverLose:AddSignal(LL2:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			RightScroll.CanvasSize = UDim2.fromOffset(0, LL2.AbsoluteContentSize.Y + 1)
		end))

		function Tab.SetValue(value)
			Tab.Signal:SetValue(value)
			if value then
				TabFrame.Visible = true
				TabFrame.Parent = TabContainer
				NeverLose.PlayAnimate(TabButton, SlowyTween, { BackgroundTransparency = 0.5 })
				NeverLose.PlayAnimate(TabIcon, SlowyTween, { TextTransparency = 0, TextColor3 = NeverLose.AccentColor })
				NeverLose.PlayAnimate(TabLabel, SlowyTween, { TextTransparency = 0 })
			else
				NeverLose.PlayAnimate(TabButton, SlowyTween, { BackgroundTransparency = 1 })
				NeverLose.PlayAnimate(TabIcon, SlowyTween, { TextTransparency = 0.5, TextColor3 = Color3.fromRGB(252,252,252) })
				NeverLose.PlayAnimate(TabLabel, SlowyTween, { TextTransparency = 0.5 })
			end
		end

		table.insert(Window.Tabs, Tab)
		if Window.Tabs[Window.CurrentTab] == Tab then Tab.SetValue(true) else Tab.SetValue(false) end

		local btn = NeverLose:CreateInput(TabButton, function()
			for i, v in next, Window.Tabs do
				if v == Tab then v.Set
