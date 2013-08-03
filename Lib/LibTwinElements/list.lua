local toc, data = ...
local AddonId = toc.identifier

local Config = {
	width = 200,
	scrollWidth = 16, -- default scrollbar width
	height = 250,
	titleHeight = 27,
	texture = "images/list_item.png",
	itemHeight = 20,
	itemWidthSub = 27
}

-- Element Logic Support
local function createItemFrame(e)
	local parent = e.Items.Mask

	local Item = UI.CreateFrame("Texture", "Twin Elements List Item" ,parent)
	Item:SetBackgroundColor(unpack(COLOR.color2))
	Item:SetTexture(AddonId, Config.texture)
	Item:SetWidth(parent:GetWidth())
	Item:SetHeight(Config.itemHeight)
	
	Item.Title = UI.CreateFrame("Text", "Twin Elements List Item Title", Item)
	Item.Title:SetPoint("CENTERLEFT", Item, "CENTERLEFT", 2, 0)
	Item.Title:SetFontColor(unpack(COLOR.white))
	Item.Title:SetEffectGlow{blurX=1, blurY=1, colorA=1}
	Item.Title:SetWidth(Item:GetWidth()-4)
	
	-- Events -------------
		function Item:MouseEnterHandler(handle)
			if e.Items.selected ~= self then
				self:SetBackgroundColor(unpack(COLOR.color1))
			end
		end
		function Item:MouseLeaveHandler(handle)
			if e.Items.selected ~= self then
				self:SetBackgroundColor(unpack(COLOR.color2))
			end
		end
		function Item:MouseClickHandler(handle)
			local oldSelection = e.Items.selected
			if not oldSelection or oldSelection.key ~= self.key then
				e.Items.selected = self
				-- unckecking old
				if oldSelection then
					oldSelection:SetBackgroundColor(unpack(COLOR.color2))
				end
				-- checking new
				self:SetBackgroundColor(unpack(COLOR.color5))
				-- Notifying
				e:Notify(self.key)
			end
		end
		Item:EventAttach(Event.UI.Input.Mouse.Cursor.In, Item.MouseEnterHandler, "mouse in")
		Item:EventAttach(Event.UI.Input.Mouse.Cursor.Out, Item.MouseLeaveHandler, "mouse out")
		Item:EventAttach(Event.UI.Input.Mouse.Left.Click, Item.MouseClickHandler, "mouse left click")
		-----------------------
	
	-- Reset
	function Item:Reset()
		self.Title:SetText("")
		self:SetBackgroundColor(unpack(COLOR.color2))
		self.key = nil
		self.realTitle = nil
		self:ClearPoint("CENTERTOP")
		self:SetVisible(false)
	end
	
	return Item
end

local function setItemTitle(text, item)
	local width = item.Title:GetWidth()
	local charLen = 6
	local maxLen = math.floor(width/6) + math.floor(width/60) - 1
	if item then
		if string.len(text) > maxLen then
			text = string.sub(text, 1, maxLen) .. "..."
		end
		item.Title:SetText(text)
	end
end

-- Element Logic
local function ListChangeHandler(e)
	local visibleItems = math.floor(e.Items.Mask:GetHeight() / Config.itemHeight)
	local scrollbar = e.Items.Scrollbar
	
	-- Updating Scrollbar state
	local state = #e.Items.options > visibleItems
	scrollbar:SetEnabled(state)
	
	-- Unselecting
	if e.Items.selected then
		e.Items.selected:SetBackgroundColor(unpack(COLOR.color2))
		e.Items.selected = nil
	end
	
	-- Reseting list position to top
	e.Items.options[0]:SetPoint("CENTERTOP", e.Items.Mask, "CENTERTOP", 0, 0)
	
	
	-- Updating Scrollbar Range
	local maxRange = #e.Items.options-visibleItems
	maxRange = maxRange >= 0 and maxRange or 0 
	scrollbar:SetRange(0, maxRange)
	
	-- Updating Scrollbar Position
	scrollbar:SetPosition(0)
end

local function ListScrollbarChangeHandler(e)
	e.Items.options[0]:SetPoint("CENTERTOP", e.Items.Mask, "CENTERTOP", 0, Config.itemHeight * math.ceil(e.Items.Scrollbar:GetPosition()) * -1)
end

local function ListWheelForwardHandler(e)
	if e.Items.Scrollbar:GetEnabled() then
		-- reacting only when scrollbar is active
		local rangeMin = e.Items.Scrollbar:GetRange()
		if math.ceil(e.Items.Scrollbar:GetPosition()) > rangeMin then
			-- Top item is not visible
			e.Items.Scrollbar:Nudge(-1)
		end
	end
end

local function ListWheelBackHandler(e)
	if e.Items.Scrollbar:GetEnabled() then
		-- reacting only when scrollbar is active
		local _, rangeMax = e.Items.Scrollbar:GetRange()
		if math.ceil(e.Items.Scrollbar:GetPosition()) < rangeMax then
			-- Top item is not visible
			e.Items.Scrollbar:Nudge(1)
		end
	end
end

local function AddItem(e, title, key)
	-- Getting item frame
	local item = #e.Items.frames == 0 and createItemFrame(e) or table.remove(e.Items.frames)
	-- setting title and updating height
	setItemTitle(title, item)
	item.realTitle = title
	-- positioning and storing
	item:SetPoint("CENTERTOP", e.Items.options[#e.Items.options], "CENTERBOTTOM", 0, 0)
	item:SetVisible(true)
	table.insert(e.Items.options, item)
	-- setting passed key
	item.key = key or #e.Items.options
	
	-- Updating Scrollbar
	ListChangeHandler(e)
end

local function AddItems(e, items)
	for _,item in ipairs(items) do
		if type(item) == "table" then 
			e:AddItem(item[1], item[2])
		else
			e:AddItem(item)
		end
	end
end

local function RemoveSelected(e)
	local item = e.Items.selected
	if item then
		local key = item.key
		local title = item.realTitle
		
		for pos,ii in ipairs(e.Items.options) do
			if ii.key == item.key then
				table.insert(e.Items.frames, table.remove(e.Items.options, pos))
				item:Reset()
				
				if pos <= #e.Items.options then
					-- updating 'next' item
					e.Items.options[pos]:SetPoint("CENTERTOP", e.Items.options[pos-1], "CENTERBOTTOM", 0, 0)
				end
				
				-- Resetting List
				ListChangeHandler(e)
				
				return key, title
			end
		end
	end
	
	return nil
end

local function ClearAllItems(e)
	while #e.Items.options > 0 do
		local item = table.remove(e.Items.options, 1)
		item:Reset()
		table.insert(e.Items.frames, item)
	end
	-- Items removed. Reseting list visuals
	ListChangeHandler(e)
end

local function GetSelected(e)
	local item = e.Items.selected
	if item then
		return item.key, item.realTitle
	end
	return item
end

local function SelectItem(e, index, key)
	local item;
	local index = index
	-- finding item
	if index and index <= #e.Items.options then
		item = e.Items.options[index]
	else
		for i,v in ipairs(e.Items.options) do
			if v.key == key then
				index = i
				item = v
				break
			end
		end
	end
	
	-- selecting (left click imitation)
	local oldSelection = e.Items.selected
	if not oldSelection or oldSelection.key ~= item.key then
		e.Items.selected = item
		-- unckecking old
		if oldSelection then
			oldSelection:SetBackgroundColor(unpack(COLOR.color2))
		end
		-- checking new
		item:SetBackgroundColor(unpack(COLOR.color5))
		-- Notifying
		e:Notify(item.key)
	else
		-- item already selected
		return
	end
	
	-- Updating List View
	local scrollbar = e.Items.Scrollbar
	local visibleItems = math.floor(e.Items.Mask:GetHeight() / Config.itemHeight)
	local inViewTop = scrollbar:GetPosition()+1
	local inViewBottom = inViewTop + visibleItems - 1
	
	if index < inViewTop or index > inViewBottom then
		-- items is currently invisible
		local nudge;
		if index < inViewTop then
			nudge = index - scrollbar:GetPosition() - 1
		else
			nudge = index - inViewTop
			local _, rMax = scrollbar:GetRange()
			nudge = nudge <= rMax and nudge or rMax
		end
		scrollbar:Nudge(nudge)
	end
end

-- Supporting functions
local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	e.Title:SetPoint(pointSelf, target, pointTarget, x, y)
end

local function SetWidth(e, width)
	assert(type(tonumber(width)) == "number", "param 1 must be a number!")
	assert(tonumber(width) >= 0, "param 1 must be a positive number!")
	
	e.Title:SetWidth(width)
	e.Title.BorderBottom:SetWidth(width)
	e.Items.Outline:SetWidth(width-8)
	e.Items.Mask:SetWidth(width-Config.itemWidthSub)
	Config.width = width
	
	-- items
	local newItemWidth = width-Config.itemWidthSub
	for _,item in ipairs(e.Items.options) do
		item:SetWidth(newItemWidth)
		item.Title:SetWidth(newItemWidth-4)
		setItemTitle(item.realTitle, item)
	end
	for _,item in ipairs(e.Items.frames) do
		item:SetWidth(newItemWidth)
	end
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

	Config.height = height
	local height = height-Config.titleHeight
	e.Items.Outline:SetHeight(height)
	e.Items.Scrollbar:SetHeight(height-2)
	e.Items.Mask:SetHeight(height-2)
end

local function GetHeight(e, offset)
	local height = Config.height
	if offset then
		local offset = e.Title:GetTop() - e.Title:GetParent():GetTop()
		height = height + offset
	end
	return height
end

-- Follow when new list item was selected
local function Follow(e, callback)
	if not e.followers then e.followers = {} end
	table.insert(e.followers, callback)
end

local function Notify(e)
	if e.followers then
		local key = e.Items.selected.key
		local title = e.Items.selected.realTitle
		for _,f in ipairs(e.followers) do
			if type(f) == "function" then f(key, title) end
		end
	end
end


-- Constructor
function Library.TwinElements.List(name, parent)
	local Element = {}
	local frameName = toc.description .. " List "
	
	Element.Items = {}
	Element.Items.options = {}
	Element.Items.frames = {}
	
	--Title
	Element.Title = UI.CreateFrame("Frame", frameName .. "Title", parent)
	Element.Title:SetBackgroundColor(unpack(COLOR.color3))
	Element.Title:SetWidth(Config.width)
	Element.Title:SetHeight(Config.titleHeight)
		-- Title Text
		Element.Title.Text = UI.CreateFrame("Text", frameName .. "Title Text", Element.Title)
		Element.Title.Text:SetPoint("CENTER", Element.Title, "CENTER", 0, 0)
		Element.Title.Text:SetText(name)
		Element.Title.Text:SetFontColor(unpack(COLOR.white))
		Element.Title.Text:SetFontSize(16)
		Element.Title.Text:SetEffectGlow{colorA=0.5}
		-- Title Border Bottom
		Element.Title.BorderBottom = UI.CreateFrame("Frame", frameName .. "Title Border Bottom", Element.Title)
		Element.Title.BorderBottom:SetPoint("CENTERBOTTOM", Element.Title, "CENTERBOTTOM", 0, 0)
		Element.Title.BorderBottom:SetWidth(Config.width)
		Element.Title.BorderBottom:SetHeight(2)
		Element.Title.BorderBottom:SetBackgroundColor(unpack(COLOR.color5))
		
	--[[ Items ]]--
	-- Outline
	Element.Items.Outline = UI.CreateFrame("Frame", frameName .. "Items outline", parent)
	Element.Items.Outline:SetPoint("CENTERTOP", Element.Title, "CENTERBOTTOM", 0, 0)
	Element.Items.Outline:SetBackgroundColor(unpack(COLOR.black))
	Element.Items.Outline:SetWidth(Config.width - 8)
	Element.Items.Outline:SetHeight(Config.height - Config.titleHeight)
	-- Scrollbar
	Element.Items.Scrollbar = UI.CreateFrame("RiftScrollbar", frameName .. "Items Scrollbar", Element.Items.Outline)
	Element.Items.Scrollbar:SetPoint("CENTERRIGHT", Element.Items.Outline, "CENTERRIGHT", -1, 0)
	Element.Items.Scrollbar:SetHeight(Element.Items.Outline:GetHeight()-2)
	Element.Items.Scrollbar:SetEnabled(false)
		--- Change event ----------
		Element.Items.Scrollbar:EventAttach(Event.UI.Scrollbar.Change, function(h) ListScrollbarChangeHandler(Element) end, "scrollbar change")
		---------------------------	
	-- Mask
	Element.Items.Mask = UI.CreateFrame("Mask", frameName .. "Items Mask", Element.Items.Outline)
	Element.Items.Mask:SetPoint("CENTERLEFT", Element.Items.Outline, "CENTERLEFT", 1, 0)
	local r,g,b = unpack(COLOR.color1)
	Element.Items.Mask:SetBackgroundColor(r,g,b,0.5)
	Element.Items.Mask:SetWidth(Config.width - Config.itemWidthSub)
	Element.Items.Mask:SetHeight(Element.Items.Outline:GetHeight()-2)
		--- Mouse Wheel Events -----
		Element.Items.Mask:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, function(h) ListWheelForwardHandler(Element) end, "wheel forward")
		Element.Items.Mask:EventAttach(Event.UI.Input.Mouse.Wheel.Back, function(h) ListWheelBackHandler(Element) end, "wheel back")
		----------------------------
	-- Fake
	local fake = UI.CreateFrame("Frame", frameName .. "Fake Item", Element.Items.Mask)
	fake:SetPoint("CENTERTOP", Element.Items.Mask, "CENTERTOP", 0, 0)
	fake:SetHeight(0)
	fake:SetWidth(0)
	Element.Items.options[0] = fake
	
	--- Items ----
	Element.AddItem = AddItem
	Element.AddItems = AddItems
	Element.RemoveSelected = RemoveSelected
	Element.ClearAllItems = ClearAllItems
	Element.GetSelected = GetSelected
	Element.SelectItem = SelectItem
	--------------
	
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