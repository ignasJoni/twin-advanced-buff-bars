local toc, data = ...
local AddonId = toc.identifier


-- Supporting functions
local function SetVisible(e, state)
	e.Title.Outline:SetVisible(state)
	e.Content.Outline:SetVisible(state)
	
	if status == true then e:Notify() end
end

local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	e.Title.Outline:SetPoint(pointSelf, target, pointTarget, x, y)
end

local function SetWidth(e, width)
	assert(type(tonumber(width)) == "number", "param 1 must be a number!")
	assert(tonumber(width) >= 0, "param 1 must be a positive number!")
	
	e.Title.Outline:SetWidth(width)
	e.Title.Fill:SetWidth(width-2)
	e.Content.Outline:SetWidth(width-10)
	e.Content.Outline.BorderBottom:SetWidth(width-10)
	e.Content.Holder:SetWidth(width-18)
end

local function GetWidth(e, offset)
	local width = e.Title.Outline:GetWidth()
	if offset then
		local offset = e.Title.Outline:GetLeft() - e.Title.Outline:GetParent():GetLeft()
		width = width + offset
	end
	return width
end

local function SetHeight(e, height)
	assert(type(tonumber(height)) == "number", "param 1 must be a number!")
	assert(tonumber(height) >= 0, "param 1 must be a positive number!")

	e.Content.Outline:SetHeight(height-28)
	e.Content.Holder:SetHeight(height-36)
end

local function GetHeight(e, offset)
	local height = e.Content.Outline:GetHeight()+28
	if offset then
		local offset = e.Title.Outline:GetTop() - e.Title.Outline:GetParent():GetTop()
		height = height + offset
	end
	return height
end

-- Follow when sections becomes visible
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
function Library.TwinElements.Section(name, parent)
	local Element = {}
	local frameName = toc.description .. " Section "
	local width = parent:GetWidth() - 8 -- fill parent with 4px margin
	
	--[[ Title ]]--
	Element.Title = {}
	-- Outline
	Element.Title.Outline = UI.CreateFrame("Frame", frameName .. " Title Outline", parent)
	Element.Title.Outline:SetBackgroundColor(unpack(COLOR.color4))
	Element.Title.Outline:SetWidth(width)
	Element.Title.Outline:SetHeight(28)
	-- Fill
	Element.Title.Fill = UI.CreateFrame("Frame", frameName .. " Title Fill", Element.Title.Outline)
	Element.Title.Fill:SetPoint("CENTERBOTTOM", Element.Title.Outline, "CENTERBOTTOM", 0, 0)
	Element.Title.Fill:SetBackgroundColor(unpack(COLOR.color3))
	Element.Title.Fill:SetWidth(width-2)
	Element.Title.Fill:SetHeight(27)
	-- Text
	Element.Title.Text = UI.CreateFrame("Text", frameName .. " Title Text", Element.Title.Fill)
	Element.Title.Text:SetPoint("CENTERLEFT", Element.Title.Fill, "CENTERLEFT", 10, 0)
	Element.Title.Text:SetText(name)
	Element.Title.Text:SetFontColor(unpack(COLOR.white))
	Element.Title.Text:SetEffectGlow{colorA=0.2}
	Element.Title.Text:SetFontSize(16)
	
	--[[ Content ]]--
	Element.Content = {}
	-- Outline
	Element.Content.Outline = UI.CreateFrame("Frame", frameName .. " Content Outline", parent)
	Element.Content.Outline:SetPoint("TOPLEFT", Element.Title.Outline, "BOTTOMLEFT", 5, 0)
	Element.Content.Outline:SetWidth(width - 10)
	Element.Content.Outline:SetHeight(100) -- default height
	Element.Content.Outline:SetBackgroundColor(unpack(COLOR.color1))
	-- Border Bottom
	Element.Content.Outline.BorderBottom = UI.CreateFrame("Frame", frameName .. " Content Border Bottom", Element.Content.Outline)
	Element.Content.Outline.BorderBottom:SetPoint("CENTERBOTTOM", Element.Content.Outline, "CENTERBOTTOM", 0, 0)
	Element.Content.Outline.BorderBottom:SetWidth(width - 10)
	Element.Content.Outline.BorderBottom:SetHeight(2)
	Element.Content.Outline.BorderBottom:SetBackgroundColor(unpack(COLOR.color4))
	-- Holder
	Element.Content.Holder = UI.CreateFrame("Mask", frameName .. " Content Holder", Element.Content.Outline)
	Element.Content.Holder:SetPoint("TOPLEFT", Element.Content.Outline, "TOPLEFT", 4, 4)
	Element.Content.Holder:SetWidth(width - 18)
	Element.Content.Holder:SetHeight(92)
	
	--- Public functions ----
	Element.SetPoint = SetPoint
	Element.SetWidth = SetWidth
	Element.GetWidth = GetWidth
	Element.SetHeight = SetHeight
	Element.GetHeight = GetHeight
	Element.Follow = Follow
	Element.Notify = Notify
	-------------------------
	
	return Element
end