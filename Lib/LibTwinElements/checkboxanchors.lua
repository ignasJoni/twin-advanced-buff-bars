local toc, data = ...
local AddonId = toc.identifier

-- Element logic
local function Select(e, pos)
	for _,chk in ipairs(e.checks) do
		if chk.pos and chk.pos == pos then
			chk:SetChecked(true)
		end
	end
end

local function AnchorChangedHandler(e, chk)
	-- New selection
	if chk:GetChecked() then
		local oldChk = e.checked
		
		if oldChk and oldChk.pos == chk.pos then
			-- nothing changed
			return
		end
		
		e.checked = chk
		if oldChk then
			-- unchecking old
			oldChk:SetChecked(false)
		end
	end
	
	-- Old selection
	if not chk:GetChecked() then
		if e.checked and e.checked.pos == chk.pos then
			-- can't unchecl
			chk:SetChecked(true)
			return
		end
		
		-- Got unchecked
		return
	end
	
	e:Notify(chk.pos)
end

-- Supporting functions
local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	e.Title:SetPoint(pointSelf, target, pointTarget, x, y)
end

local function GetWidth(e, offset)
	local left = e.Title:GetLeft()
	local right = e.Title:GetRight() > e.Holder:GetRight() and e.Title:GetRight() or e.Holder:GetRight()
	local width = right-left
	if offset then
		local offset = e.Title:GetLeft() - e.Title:GetParent():GetLeft()
		width = width + offset
	end
	return width
end

local function GetHeight(e, offset)
	local height = e.Holder:GetBottom() - e.Title:GetTop()
	if offset then
		local offset = e.Title:GetTop() - e.Title:GetParent():GetTop()
		height = height + offset
	end
	return height
end

-- Follow when selected anchor has changed
local function Follow(e, callback)
	if not e.followers then e.followers = {} end
	table.insert(e.followers, callback)
end

local function Notify(e, pos)
	if e.followers then
		for _,f in ipairs(e.followers) do
			if type(f) == "function" then f(pos) end
		end
	end
end

-- Constructor
function Library.TwinElements.CheckboxAnchors(name, parent)
	local Element = {}
	local frameName = toc.description .. " Checkbox Anchors "
	
	-- Title
	Element.Title = UI.CreateFrame("Text", frameName .. "Title", parent)
	Element.Title:SetText(name .. ":")
	Element.Title:SetFontColor(unpack(COLOR.white))
	Element.Title:SetFontSize(16)
	-- Holder
	Element.Holder = UI.CreateFrame("Frame", frameName .. "Holder", parent)
	Element.Holder:SetPoint("TOPLEFT", Element.Title, "BOTTOMLEFT", 0, 0)
	Element.Holder:SetBackgroundColor(unpack(COLOR.color2))
	Element.Holder:SetWidth(90)
	Element.Holder:SetHeight(70)
	
	--[[ Checkboxes ]]--
	Element.checks = {}
	for i=0, 7 do
		local Chk = UI.CreateFrame("RiftCheckbox", frameName .. "Checkbox", Element.Holder)
		table.insert(Element.checks, Chk)
		Chk:EventAttach(Event.UI.Checkbox.Change, function(h) AnchorChangedHandler(Element, Chk) end, "change")
	end
	-- Setting position
	Element.checks[1].pos = "N"
	Element.checks[1]:SetPoint("CENTERTOP", Element.Holder, "CENTERTOP", 0, 0)
	Element.checks[2].pos = "NE"
	Element.checks[2]:SetPoint("TOPRIGHT", Element.Holder, "TOPRIGHT", 0, 0)
	Element.checks[3].pos = "E"
	Element.checks[3]:SetPoint("CENTERRIGHT", Element.Holder, "CENTERRIGHT", 0, 0)
	Element.checks[4].pos = "SE"
	Element.checks[4]:SetPoint("BOTTOMRIGHT", Element.Holder, "BOTTOMRIGHT", 0, 0)
	Element.checks[5].pos = "S"
	Element.checks[5]:SetPoint("CENTERBOTTOM", Element.Holder, "CENTERBOTTOM", 0, 0)
	Element.checks[6].pos = "SW"
	Element.checks[6]:SetPoint("BOTTOMLEFT", Element.Holder, "BOTTOMLEFT", 0, 0)
	Element.checks[7].pos = "W"
	Element.checks[7]:SetPoint("CENTERLEFT", Element.Holder, "CENTERLEFT", 0, 0)
	Element.checks[8].pos = "NW"
	Element.checks[8]:SetPoint("TOPLEFT", Element.Holder, "TOPLEFT", 0, 0)
	
	
	--- Public functions ----
	Element.Select = Select
	Element.SetPoint = SetPoint
	Element.GetWidth = GetWidth
	Element.GetHeight = GetHeight
	Element.Follow = Follow
	Element.Notify = Notify
	-------------------------
	
	return Element
end