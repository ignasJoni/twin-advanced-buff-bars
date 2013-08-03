local toc, data = ...
local AddonId = toc.identifier

-- Element Logic
local function AddItem(e, title, key)
	local frameName = toc.description .. " Tabbed Panel Item "
	
	-- Item
	local Item = UI.CreateFrame("Frame", frameName .. title, e.Tabs.Holder)
	Item:SetHeight(46)
	Item:SetBackgroundColor(unpack(COLOR.color5))
	Item:SetPoint("TOPLEFT", e.items[#e.items], "TOPRIGHT", 0, 0)
	-- Title
	Item.Title = UI.CreateFrame("Text", frameName .. "Item Title", Item)
	Item.Title:SetText(title)
	Item.Title:SetFontSize(18)
	Item.Title:SetFontColor(unpack(COLOR.color1))
	Item.Title:SetPoint("CENTER", Item, "CENTER", 0, 0)
	Item:SetWidth(Item.Title:GetWidth() + 28) -- width fix
		
		--- Visual events ------
		function Item:MouseCursorInHandler(h)
			if not self.selected then
				self:SetBackgroundColor(unpack(COLOR.color6))
			end
		end
		function Item:MouseCursorOutHandler(h)
			if not self.selected then
				self:SetBackgroundColor(unpack(COLOR.color5))
			end
		end
		Item:EventAttach(Event.UI.Input.Mouse.Cursor.In, Item.MouseCursorInHandler, "mouse in")
		Item:EventAttach(Event.UI.Input.Mouse.Cursor.Out, Item.MouseCursorOutHandler, "mouse out")
		------------------------
		
	-- Content
	Item.Content = UI.CreateFrame("Frame", frameName .. "Item Content", e.Content)
	Item.Content:SetPoint("CENTERTOP", e.Content, "CENTERTOP", 0, 0)
	Item.Content:SetWidth(e.Content:GetWidth())
	Item.Content:SetHeight(e.Content:GetHeight())
	Item.Content:SetVisible(false)
	
	--- Logic ---------------
	Item:EventAttach(Event.UI.Input.Mouse.Left.Click, function(handle) e:Select(Item) end, "left click")
	-- Visual appearance based on state
	function Item:UpdateState()
		if self.selected then
			-- Selected
			self:SetBackgroundColor(unpack(COLOR.color6))
			self.Title:SetFontColor(unpack(COLOR.white))
			self.Content:SetVisible(true)
		else
			-- Unselected
			self.Title:SetFontColor(unpack(COLOR.color1))
			self:SetBackgroundColor(unpack(COLOR.color5))
			self.Content:SetVisible(false)
		end
	end
	-------------------------
	
	Item.key = key
	table.insert(e.items, Item)
	return Item
end

local function Select(e, item)
	local item = type(item) == "table" and item or e.items[item]
	if item.selected then return end -- ignoring already selected items
	
	-- clearing previous selection
	if e.selectedItem then
		e.selectedItem.selected = false
		e.selectedItem:UpdateState()
	end
	
	-- Selecting new
	item.selected = true
	item:UpdateState()
	e.selectedItem = item
	
	e:Notify(item.key)
end

-- Supporting functions
local function SetVisible(e, state)
	e.Tabs.Holder:SetVisible(state)
	e.Content:SetVisible(state)
end

local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	e.Tabs.Holder:SetPoint(pointSelf, target, pointTarget, x, y)
end

local function SetWidth(e, width)
	assert(type(tonumber(width)) == "number", "param 1 must be a number!")
	assert(tonumber(width) >= 0, "param 1 must be a positive number!")
	
	e.Tabs.Holder:SetWidth(width)
	e.Tabs.BorderBottom:SetWidth(width)
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

	e.Content:SetHeight(height-50)
end

local function GetHeight(e, offset)
	local height = e.Content:GetHeight()+50
	if offset then
		local offset = e.Tabs.Holder:GetTop() - e.Tabs.Holder:GetParent():GetTop()
		height = height + offset
	end
	return height
end

local function SetAlpha(e, alpha)
	assert(type(tonumber(alpha)) == "number", "param 1 must be a number!")
	
	local r,g,b = e.Content:GetBackgroundColor()
	e.Content:SetBackgroundColor(r,g,b,alpha)
end

-- Follow when selected tab has changed
local function Follow(e, callback)
	if not e.followers then e.followers = {} end
	table.insert(e.followers, callback)
end

local function Notify(e, tabKey)
	if e.followers then
		for _,f in ipairs(e.followers) do
			if type(f) == "function" then f(tabKey) end
		end
	end
end


-- Constructor
function Library.TwinElements.TabbedPanel(name, parent)
	local Element = {}
	local frameName = toc.description .. " Tabbed Panel "
	
	--[[ Tabs ]]--
	Element.Tabs = {}
	-- Holder
	Element.Tabs.Holder = UI.CreateFrame("Frame", frameName .. "Tabs Holder", parent)
	Element.Tabs.Holder:SetWidth(parent:GetWidth()-8) -- Fill parent with 4px margin
	Element.Tabs.Holder:SetHeight(50)
	Element.Tabs.Holder:SetBackgroundColor(unpack(COLOR.color2))
	-- Border Bottom
	Element.Tabs.BorderBottom = UI.CreateFrame("Frame", frameName .. "Tabs Holder Border Bottom", Element.Tabs.Holder)
	Element.Tabs.BorderBottom:SetPoint("CENTERBOTTOM", Element.Tabs.Holder, "CENTERBOTTOM", 0, 0)
	Element.Tabs.BorderBottom:SetWidth(Element.Tabs.Holder:GetWidth())
	Element.Tabs.BorderBottom:SetHeight(4)
	Element.Tabs.BorderBottom:SetBackgroundColor(unpack(COLOR.color4))
		-- Fake Item (starting point)
		Element.items = {}
		Element.items[0] = UI.CreateFrame("Frame", frameName .. "Item 0", Element.Tabs.Holder)
		Element.items[0]:SetHeight(46)
		Element.items[0]:SetWidth(0)
		Element.items[0]:SetPoint("TOPLEFT", Element.Tabs.Holder, "TOPLEFT", 0, 0)
	
	--[[ Content ]]--
	Element.Content = UI.CreateFrame("Mask", frameName .. "Tabs Content", parent)
	Element.Content:SetPoint("CENTERTOP", Element.Tabs.Holder, "CENTERBOTTOM", 0, 0)
	Element.Content:SetWidth(parent:GetWidth()-8) -- Fill parent with 4px margin
	Element.Content:SetHeight(parent:GetHeight() - 50 - 8) -- Fill parent with 4px margin
	Element.Content:SetBackgroundColor(unpack(COLOR.color2))
	
	--- Public functions ----
	Element.AddItem = AddItem
	Element.Select = Select
	Element.SetPoint = SetPoint
	Element.SetWidth = SetWidth
	Element.GetWidth = GetWidth
	Element.SetHeight = SetHeight
	Element.GetHeight = GetHeight
	Element.SetAlpha = SetAlpha
	Element.Follow = Follow
	Element.Notify = Notify
	-------------------------
	
	return Element
end