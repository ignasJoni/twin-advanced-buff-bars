local toc, data = ...
local AddonId = toc.identifier

-- Element logic
local function CheckboxChangeHandler(e, chk)
-- SINGLE
	if e.Type == "single" then
		
		-- New selection
		if chk:GetChecked() then
			local oldChk = e.checked[1]
			e.checked[1] = chk
			if oldChk and oldChk.key ~= chk.key then
				-- uncheking old
				oldChk:SetChecked(false)
			elseif oldChk and oldChk.key == chk.key then
				-- nothing changed
				return
			end
		end
		
		-- Old selection
		if not chk:GetChecked() then
			if e.checked[1].key == chk.key and not e.AllowEmpty then
				-- Can't unselect
				chk:SetChecked(true)
				return
			end
			
			-- Got uncheked
			return
		end
		
	end
	
	-- Checks if check was already selected
	local function wasChecked(e, chk)
		for _,o in ipairs(e.checked) do
			if o.key == chk.key then return true end
		end
		return false
	end
	
	-- Remove check from checked list
	local function removeChk(e, chk)
		for i,o in ipairs(e.checked) do
			if o.key == chk.key then
				table.remove(e.checked, i)
			end
		end
	end
	
	-- MULTI
	if e.Type == "multi" then
		
		-- New selection
		if chk:GetChecked() and not wasChecked(e, chk) then
			table.insert(e.checked, chk)
		elseif chk:GetChecked() then
			-- nothing changed
			return
		end
	
		-- Old selection
		if not chk:GetChecked() then
			if not e.AllowEmpty then
				-- Don't allow all to be unselected
				if #e.checked == 1 then
					chk:SetChecked(true)
					return
				end
			end
			
			-- removing from cheking list
			removeChk(e, chk)
			return
		end
	end
	
	-- Notifying about selection changed
	e:Notify(chk.key)
end

-- Supporting functions
local function SetValues(e, values)
	assert(type(values) == "table", "param 1 must be a table!")
	
	e.Type = values.select or "single"
	e.AllowEmpty = values.allowEmpty
	if e.AllowEmpty == nil then e.AllowEmpty = true end
end

local function AddOption(e, name, key)
	local frameName = toc.description .. " Checkbox Group Option "

	-- Checkbox
	local Chk = UI.CreateFrame("RiftCheckbox", frameName .. "Checkbox", e.Title)
	Chk.key = key and key or #e.options+1
	
	-- Title
	Chk.Title = UI.CreateFrame("Text", frameName .. "Checkbox Name", Chk)
	Chk.Title:SetPoint("CENTERLEFT", Chk, "CENTERRIGHT", 0, 0)
	Chk.Title:SetText(name)
	Chk.Title:SetFontColor(unpack(COLOR.white))
	
	-- positioning
	Chk:SetPoint("TOPLEFT", e.options[#e.options], "BOTTOMLEFT", 0, 4)
	
	-- Reacting on select
	Chk:EventAttach(Event.UI.Checkbox.Change, function(h) CheckboxChangeHandler(e, Chk) end, "change")
	
	table.insert(e.options, Chk)
end

local function AddOptions(e, options)
	assert(type(options) == "table", "param 1 must be a table!")

	for _,o in ipairs(options) do
		if type(o) == "table" then
			e:AddOption(o[1], o[2])
		else
			e:AddOption(o)
		end
	end
end

local function Select(e, index, key)
	if index and e.options[index] then
		-- select by index
		e.options[index]:SetChecked(true)
	elseif key then
		-- select by key
		for _,o in ipairs(e.options) do
			if o.key == key then
				o:SetChecked(true)
			end
		end
	end
end

local function GetChecked(e)
	local checked = {}
	for _,o in ipairs(e.checked) do
		checked[#checked+1] = o.key
	end
	return checked
end

local function DisableOption(e, index, key)
	local chk = nil
	if index and e.options[index] then
		-- select by index
		chk = e.options[index]
	elseif key then
		-- select by key
		for _,o in ipairs(e.options) do
			if o.key == key then
				chk = o
			end
		end
	end
	
	if chk ~= nil then
		chk:SetEnabled(false)
		chk.Title:SetAlpha(0.5)
	end
end

local function EnableOption(e, index, key)
	local chk = nil
	if index and e.options[index] then
		-- select by index
		chk = e.options[index]
	elseif key then
		-- select by key
		for _,o in ipairs(e.options) do
			if o.key == key then
				chk = o
			end
		end
	end
	
	if chk ~= nil then
		chk:SetEnabled(true)
		chk.Title:SetAlpha(1)
	end
end

local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	e.Title:SetPoint(pointSelf, target, pointTarget, x, y)
end

local function GetWidth(e, offset)
	local left = e.Title:GetLeft()
	local right = e.Title:GetRight()
	-- Checking furthest right point
	for _,o in ipairs(e.options) do
		local newRight = o.Title:GetRight()
		if newRight > right then right = newRight end
	end
	
	local width = right - left
	if offset then
		local offset = e.Title:GetLeft() - e.Title:GetParent():GetLeft()
		width = width + offset
	end
	return width
end

local function GetHeight(e, offset)
	local height = (#e.options == 0 and e.Title:GetHeight()) or (e.options[#e.options]:GetBottom() - e.Title:GetTop())
	if offset then
		local offset = e.Title:GetTop() - e.Title:GetParent():GetTop()
		height = height + offset
	end
	return height
end

-- Follow when selection has changed
local function Follow(e, callback)
	if not e.followers then e.followers = {} end
	table.insert(e.followers, callback)
end

local function Notify(e, key)
	if e.followers then
		for _,f in ipairs(e.followers) do
			if type(f) == "function" then f(key) end
		end
	end
end

-- Constructor
function Library.TwinElements.CheckboxGroup(name, parent)
	local Element = {}
	local frameName = toc.description .. " Checkbox Group "
	
	Element.Type = "single"
	Element.AllowEmpty = true
	Element.checked = {}
	
	-- Title
	Element.Title = UI.CreateFrame("Text", frameName .. "Title", parent)
	Element.Title:SetText(name .. ":")
	Element.Title:SetFontColor(unpack(COLOR.white))
	Element.Title:SetFontSize(16)
	
	--[[ Options management ]]--
	Element.options = {}
		-- Fake Option (positioning)
		Element.options[0] = UI.CreateFrame("Frame", frameName .. "Option Fake", Element.Title)
		Element.options[0]:SetPoint("TOPLEFT", Element.Title, "BOTTOMLEFT", 10, 0)
		Element.options[0]:SetWidth(0)
		Element.options[0]:SetHeight(0)
	
	--- Public functions ----
	Element.SetValues = SetValues
	Element.AddOption = AddOption
	Element.AddOptions = AddOptions
	Element.Select = Select
	Element.GetChecked = GetChecked
	Element.EnableOption = EnableOption
	Element.DisableOption = DisableOption
	Element.SetPoint = SetPoint
	Element.GetWidth = GetWidth
	Element.GetHeight = GetHeight
	Element.Follow = Follow
	Element.Notify = Notify
	-------------------------
	
	return Element
end