local toc, data = ...
local AddonId = toc.identifier

-- Default Configuration
local Config = {
	width = 990,
	height = 590
}

-- Supporting functions
local function SetVisible(e, state)
	e.Content:SetVisible(state)
	e:Notify(true)
end

local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	e.Content:SetPoint(pointSelf, target, pointTarget, x, y)
end

local function SetWidth(e, width)
	assert(type(tonumber(width)) == "number", "param 1 must be a number!")
	assert(tonumber(width) >= 0, "param 1 must be a positive number!")
	
	e.Content:SetWidth(width)
end

local function GetWidth(e, offset)
	local width = e.Content:GetWidth()
	if offset then
		local offset = e.Content:GetLeft() - e.Content:GetParent():GetLeft()
		width = width + offset
	end
	return width
end

local function SetHeight(e, height)
	assert(type(tonumber(height)) == "number", "param 1 must be a number!")
	assert(tonumber(height) >= 0, "param 1 must be a positive number!")
	
	e.Content:SetHeight(height)
end

local function GetHeight(e, offset)
	local height = e.Content:GetHeight()
	if offset then
		local offset = e.Content:GetTop() - e.Content:GetParent():GetTop()
		height = height + offset
	end
	return height
end

local function SetAlpha(e, alpha)
	assert(type(tonumber(alpha)) == "number", "param 1 must be a number!")
	
	--local r,g,b = e.Content:GetBackgroundColor()
	--e.Content:SetBackgroundColor(r,g,b,alpha)
	e.Content:SetAlpha(alpha)
end

local function GetVisible(e)
	return e.Content:GetVisible()
end

-- Follow when window was closed
local function Follow(e, callback)
	if not e.followers then e.followers = {} end
	table.insert(e.followers, callback)
end

local function Notify(e, visible)
	if e.followers then
		for _,f in ipairs(e.followers) do
			if type(f) == "function" then f(visible) end
		end
	end
end

-- Constructor
function Library.TwinElements.Window(name, parent)
	local Element = {}
	local frameName = toc.description .. " Window "
	
	-- Content
	Element.Content = UI.CreateFrame("Frame", frameName .. name, parent)
	Element.Content:SetWidth(Config.width)
	Element.Content:SetHeight(Config.height)
	Element.Content:SetBackgroundColor(unpack(COLOR.color1))
	Element.Content:SetVisible(false)
	
	-- Header
	Element.Header = UI.CreateFrame("Texture", frameName .. " Header", Element.Content)
	Element.Header:SetPoint("BOTTOMRIGHT", Element.Content, "TOPRIGHT", 40, 38)
	Element.Header:SetWidth(356)
	Element.Header:SetHeight(84)
	Element.Header:SetTexture(AddonId, "images/header.png")
	Element.Header:SetLayer(2)
	-- Header Text
	Element.Header.Text = UI.CreateFrame("Text", frameName .. " Header Text", Element.Header)
	Element.Header.Text:SetText(name)
	Element.Header.Text:SetFontColor(unpack(COLOR.white))
	Element.Header.Text:SetPoint("CENTERLEFT", Element.Header, "CENTERLEFT", 180, 3)
	Element.Header.Text:SetEffectGlow{}
	-- button: Close
	Element.Header.Close = UI.CreateFrame("RiftButton", frameName .. " Header Close Button", Element.Header)
	Element.Header.Close:SetSkin("close")
	Element.Header.Close:SetPoint("CENTERLEFT", Element.Header.Text, "CENTERLEFT", 120, 0)
	Element.Header.Close:SetText("Close")
	Element.Header.Close:SetLayer(4)
		--- Event Handlers ------
		function Element.Header.Close:MouseLeftClickHandler(h)
			Element.Content:SetVisible(false)
			Element:Notify(false)
		end
		Element.Header.Close:EventAttach(Event.UI.Input.Mouse.Left.Click, Element.Header.Close.MouseLeftClickHandler, "mouse left click")
		-------------------------
	
	--- Public functions ----
	Element.SetPoint = SetPoint
	Element.SetWidth = SetWidth
	Element.GetWidth = GetWidth
	Element.SetHeight = SetHeight
	Element.GetHeight = GetHeight
	Element.SetAlpha = SetAlpha
	Element.GetVisible = GetVisible
	Element.Follow = Follow
	Element.Notify = Notify
	-------------------------
	
	return Element
end