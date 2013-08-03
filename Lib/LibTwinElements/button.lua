local toc, data = ...
local AddonId = toc.identifier

local Config = {
	states = {
		NORMAL = "images/btn_NORMAL.png",
		HOVER = "images/btn_HOVER.png",
		ACTIVE = "images/btn_ACTIVE.png",
	},
	width = 68,
	heigth = 32
}

-- Element logic
local function SetState(e, state)
	assert(type(state) == "string", "param 1 must be a string!")
	
	e.Frame:SetTexture(AddonId, Config.states[state])
end

-- Supporting functions
local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	e.Frame:SetPoint(pointSelf, target, pointTarget, x, y)
end

local function SetWidth(e, width)
	assert(type(tonumber(width)) == "number", "param 1 must be a number!")
	assert(tonumber(width) >= 0, "param 1 must be a positive number!")
	
	e.Frame:SetWidth(width)
end

local function GetWidth(e, offset)
	local width = e.Frame:GetWidth()
	if offset then
		local offset = e.Frame:GetLeft() - e.Frame:GetParent():GetLeft()
		width = width + offset
	end
	return width
end

local function SetHeight(e, height)
	assert(type(tonumber(height)) == "number", "param 1 must be a number!")
	assert(tonumber(height) >= 0, "param 1 must be a positive number!")

	e.Frame:SetHeight(height)
end

local function GetHeight(e, offset)
	local height = e.Frame:GetHeight()
	if offset then
		local offset = e.Frame:GetTop() - e.Frame:GetParent():GetTop()
		height = height + offset
	end
	return height
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

-- Constructor
function Library.TwinElements.Button(name, parent)
	local Element = {}
	local frameName = toc.description .. " Button "
	
	-- Button
	Element.Frame = UI.CreateFrame("Texture", frameName .. "Frame", parent)
	Element.Frame:SetWidth(Config.width)
	Element.Frame:SetHeight(Config.heigth)
		--- Mouse Events -----
		function Element.Frame:MouseInHandler(h)
			Element:SetState("HOVER")
		end
		function Element.Frame:MouseOutHandler(h)
			Element:SetState("NORMAL")
		end
		function Element.Frame:MouseLeftDownHandler(h)
			Element:SetState("ACTIVE")
		end
		function Element.Frame:MouseLeftUpHandler(h)
			Element:SetState("HOVER")
		end
		function Element.Frame:MouseLeftUpoutsideHandler(h)
			Element:SetState("NORMAL")
		end
		Element.Frame:EventAttach(Event.UI.Input.Mouse.Cursor.In, Element.Frame.MouseInHandler, "mouse in")
		Element.Frame:EventAttach(Event.UI.Input.Mouse.Cursor.Out, Element.Frame.MouseOutHandler, "mouse out")
		Element.Frame:EventAttach(Event.UI.Input.Mouse.Left.Down, Element.Frame.MouseLeftDownHandler, "mouse left down")
		Element.Frame:EventAttach(Event.UI.Input.Mouse.Left.Up, Element.Frame.MouseLeftUpHandler, "mouse left up")
		Element.Frame:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, Element.Frame.MouseLeftUpoutsideHandler, "mouse left upoutside")
		Element.Frame:EventAttach(Event.UI.Input.Mouse.Left.Click, function(h) Element:Notify() end, "mouse left click")
		----------------------
	
	-- Title
	Element.Title = UI.CreateFrame("Text", frameName .. "Title", parent)
	Element.Title:SetPoint("CENTER", Element.Frame, "CENTER", 0, 0)
	Element.Title:SetFontColor(unpack(COLOR.black))
	Element.Title:SetFontSize(15)
	Element.Title:SetLayer(1)
	Element.Title:SetText(name)
	local r,g,b = unpack(COLOR.white)
	Element.Title:SetEffectGlow{colorR=r, colorG=g, colorB=b, colorA=1, blurX=6, blurY=6}
		-- width fix
		if Element.Title:GetWidth()+20 > Config.width then
			Element.Frame:SetWidth(Element.Title:GetWidth()+20)
		end
	
	--- Public functions ----
	Element.SetState = SetState
	Element.SetPoint = SetPoint
	Element.SetWidth = SetWidth
	Element.GetWidth = GetWidth
	Element.SetHeight = SetHeight
	Element.GetHeight = GetHeight
	Element.Follow = Follow
	Element.Notify = Notify
	-------------------------
	
	Element:SetState("NORMAL")
	return Element
end