local toc, data = ...
local AddonId = toc.identifier

-- Supporting functions
local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	e.Title:SetPoint(pointSelf, target, pointTarget, x, y)
end

local function SetWidth(e, width)
	assert(type(tonumber(width)) == "number", "param 1 must be a number!")
	assert(tonumber(width) >= 0, "param 1 must be a positive number!")
	
	e.Title:SetWidth(width)
	e.Title.BorderTop:SetWidth(width)
	e.Content.Outline:SetWidth(width)
	e.Content.Holder:SetWidth(width-8)
end

local function GetWidth(e, offset)
	local width = e.Title:GetWidth()
	if offset then
		local offset = e.Title:GetLeft() - e.Title:GetParent():GetLeft()
		width = width + offset
	end
	return width
end

local function SetHeight(e, height)
	assert(type(tonumber(height)) == "number", "param 1 must be a number!")
	assert(tonumber(height) >= 0, "param 1 must be a positive number!")

	local height = height - e.Title:GetHeight()
	e.Content.Outline:SetHeight(height)
	e.Content.Holder:SetHeight(height-8)
end

local function GetHeight(e, offset)
	local height = e.Title:GetHeight() + e.Content.Outline:GetHeight()
	if offset then
		local offset = e.Title:GetTop() - e.Title:GetParent():GetTop()
		height = height + offset
	end
	return height
end

-- Constructor
function Library.TwinElements.Subsection(name, parent)
	local Element = {}
	local frameName = toc.description .. " Subsection "
	
	local width = parent:GetWidth() -- parent fill
	
	-- Title
	Element.Title = UI.CreateFrame("Frame", frameName .. "Title", parent)
	Element.Title:SetWidth(width)
	Element.Title:SetHeight(26)
	Element.Title:SetBackgroundColor(unpack(COLOR.color4))
		-- Border Top
		Element.Title.BorderTop = UI.CreateFrame("Frame", frameName .. "Title Border Top", Element.Title)
		Element.Title.BorderTop:SetPoint("CENTERTOP", Element.Title, "CENTERTOP", 0, 0)
		Element.Title.BorderTop:SetWidth(width)
		Element.Title.BorderTop:SetHeight(2)
		Element.Title.BorderTop:SetBackgroundColor(unpack(COLOR.color5))
		-- Text
		Element.Title.Text = UI.CreateFrame("Text", frameName .. "Title", Element.Title)
		Element.Title.Text:SetPoint("CENTERLEFT", Element.Title, "CENTERLEFT", 4, 1)
		Element.Title.Text:SetFontColor(unpack(COLOR.white))
		Element.Title.Text:SetFontSize(16)
		Element.Title.Text:SetText(name)
	
	--[[ CONTENT ]]--
	Element.Content = {}
	-- Content Outline
	Element.Content.Outline = UI.CreateFrame("Frame", frameName .. "Content Outline", parent)
	Element.Content.Outline:SetPoint("TOPLEFT", Element.Title, "BOTTOMLEFT", 0, 0)
	Element.Content.Outline:SetWidth(width)
	Element.Content.Outline:SetHeight(100) -- default height
	Element.Content.Outline:SetBackgroundColor(unpack(COLOR.black))
	-- Content Holder
	Element.Content.Holder = UI.CreateFrame("Mask", frameName .. "Content Holder", Element.Content.Outline)
	Element.Content.Holder:SetPoint("TOPLEFT", Element.Content.Outline, "TOPLEFT", 4, 4)
	Element.Content.Holder:SetWidth(width-8)
	Element.Content.Holder:SetHeight(Element.Content.Outline:GetHeight()-8)
	
	--- Public functions ----
	Element.SetPoint = SetPoint
	Element.SetWidth = SetWidth
	Element.GetWidth = GetWidth
	Element.SetHeight = SetHeight
	Element.GetHeight = GetHeight
	-------------------------
	
	return Element
end