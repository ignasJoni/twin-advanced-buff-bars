--
-- A button to toggle Settings Panel
--

local toc, data = ...
local AddonId = toc.identifier
local Button = {}

-- Button configuration
local Config = {
	texture = {
		NORMAL = "images/icon.png",
		HOVER = "images/iconHover.png",
		FOCUS = "images/iconPress.png"
	},
	size = {
		width = 30,
		height = 30
	}
}

--[[
-- Sets up Button positioning for first time.
-- Returns last position if already set
 ]]
local function getOffset()
	if twinConfig.addonButton == nil then
		twinConfig.addonButton = {
			offset = {
				left = (UIParent:GetHeight() - Config.size.height) / 2,
				top = (UIParent:GetWidth() - Config.size.width) / 2
			}
		}
	end

	return twinConfig.addonButton.offset.left, twinConfig.addonButton.offset.top
end


-- Follow when button was clicked
local function Follow(e, callback)
	if not e.followers then e.followers = {} end
	table.insert(e.followers, callback)
end

local function Notify(e)
	if e.followers then
		for _,f in ipairs(e.followers) do
			if type(f) == "function" then f() end
		end
	end
end

--[[
-- Creates add-on button
-- @require frame toToggle
-- @return Button
 ]]
function TwinElem:loadAddonButton(toToggle)
	Button.toToggle = toToggle

	-- creating button
	local button = UI.CreateFrame("Texture", AddonId .. "_AddonButton", TwinABB.Context)
	Button.frame = button

	-- setting up visuals
	button:SetWidth(Config.size.width)
	button:SetHeight(Config.size.height)
	button:SetTexture(AddonId, Config.texture.NORMAL)
	button:SetVisible(true)

	-- positioning
	local offsetLeft, offsetTop = getOffset()
	button:SetPoint("TOPLEFT", UIParent, "TOPLEFT", offsetLeft, offsetTop)

	-- Visual events -------
	button:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(handle) button:SetTexture(AddonId, Config.texture.HOVER) end, "mouse in")
	button:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(handle) button:SetTexture(AddonId, Config.texture.NORMAL) end, "mouse out")
	button:EventAttach(Event.UI.Input.Mouse.Left.Down, function(handle) button:SetTexture(AddonId, Config.texture.FOCUS) end, "mouse left down")
	button:EventAttach(Event.UI.Input.Mouse.Left.Up, function(handle) button:SetTexture(AddonId, Config.texture.HOVER) end, "mouse left up")
	button:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function(handle) button:SetTexture(AddonId, Config.texture.NORMAL) end, "mouse left upoutside")
	------------------------

	--- Enabling Button Drag ----
	function button:SavePoint()
		twinConfig.addonButton.offset = {
			left = self:GetLeft(),
			top = self:GetTop()
		}
	end

	button:EventAttach(Event.UI.Input.Mouse.Right.Down, Drag.rightDown, "right down")
	button:EventAttach(Event.UI.Input.Mouse.Right.Up, Drag.rightUp, "right up")
	button:EventAttach(Event.UI.Input.Mouse.Right.Upoutside, Drag.rightUp, "right up outside")
	button:EventAttach(Event.UI.Input.Mouse.Cursor.Move, Drag.move, "cursor move")
	----------------------------

	--- Enabling Button Click ----
	function button:LeftClickHandler(handle)
		if Button.toToggle ~= nil then
			if Button.toToggle:GetVisible() == true then
				Button.toToggle:SetVisible(false)
			else
				Button.toToggle:SetVisible(true)
			end
			Button:Notify()
		end
	end
	button:EventAttach(Event.UI.Input.Mouse.Left.Click, button.LeftClickHandler, "left click")
	-------------------------------
	
	--- Public Methods ---
	Button.Follow = Follow
	Button.Notify = Notify
	----------------------

	--print_r(Event.UI.Input.Mouse)

	return Button
end