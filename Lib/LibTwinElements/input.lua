local toc, data = ...
local AddonId = toc.identifier

-- Element logic
local function SetValues(e, values)
	local values = values or {}
	e.Type = values.inputType or "text"
	e.Limit = values.limit
	e.NonDecimal = values.nonDecimal
	e.MinValue = values.minValue
	e.MaxValue = values.maxValue
	e.Increase = values.increase
	
	if values.width then e:SetWidth(values.width) end
end

local function InputTextHandler(e)
	local oldText = e.Field.oldText or ""
	local newText = e.Field:GetText()
	
	if oldText == newText then return end -- no text changed
	
	-- Validating text based on type
	--[[ TEXT ]]--
	if e.Type == "text" then
		if e.Limit then
			-- Limit number of characters
			if #newText > e.Limit then
				e:SetText(oldText)
				return
			end
		end
	end
	
	--[[ NUMBER ]]--
	if e.Type == "number" or e.Type == "number-positive" then
		
		if #newText > #oldText then
			-- Checking last character
			local positive = (e.Type == "number-positive" and "") or "-"
			local pattern = (e.NonDecimal and "^[%d%c" .. positive .. "]$") or "^[%d%c" .. positive .. ".]$"
			local char = string.sub(newText, #newText)
			if not char:match(pattern) then
				e:SetText(oldText)
				return
			end
		
			-- Checking overall format
			if not tonumber(newText) and ((e.Type == "number-positive" and newText == "-") or newText ~= "-") then
				-- not number
				e:SetText(oldText)
				return
			elseif newText:match("^[-]?0%d.*$") then
				-- Disallowing start with zero
				local zero = string.find(newText, "0")
				local formatted = (zero == 1 and string.sub(newText, 2)) or string.sub(newText, 1, 1) .. string.sub(newText, 3)
				e:SetText(formatted)
				return
			elseif #newText > 2 then
				local number = (e.NonDecimal and "^[-]?%d*$") or "^[-]?%d+%.?%d?%d?$"
				if not newText:match(number) then
					-- not allowed format
					e:SetText(oldText)
					return
				end
			end
			
			-- Limit number of characters
			-- Applying limit only on non-decimal digits
			local digits = string.match(newText, "%d+")
			if e.Limit then
				if digits and #digits > e.Limit then
					e:SetText(oldText)
					return
				end
			end
		end
	
		-- Validation passed
		-- Applying min-max constraints
		local newNumber = tonumber(newText)
		if #newText > #oldText and newNumber then
			if e.MinValue then
				if newNumber < e.MinValue then
					-- number lower than allowed
					newText = tostring(e.MinValue)
					e:SetText(newText)
					e.Field:SetCursor(#newText)
					e:Notify()
					return
				end
			end
			
			if e.MaxValue then
				if newNumber > e.MaxValue then
					-- nummer higher than allowed
					newText = tostring(e.MaxValue)
					e:SetText(newText)
					e.Field:SetCursor(#newText)
					e:Notify()
					return
				end
			end
		end
	end
	
	-- Validation successful
	e.Field.oldText = newText
	e:Notify()
end

-- Supporting functions
local function SetText(e, text)
	text = tostring(text)
	e.Field.oldText = text
	e.Field:SetText(text)
end

local function GetText(e)
	return e.Field:GetText()
end

local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	e.Title:SetPoint(pointSelf, target, pointTarget, x, y)
end

local function SetWidth(e, width)
	assert(type(tonumber(width)) == "number", "param 1 must be a number!")
	assert(tonumber(width) >= 0, "param 1 must be a positive number!")
	
	e.FieldOutline:SetWidth(width)
	e.Field:SetWidth(width-2)
end

local function GetWidth(e, offset)
	local width = e.FieldOutline:GetRight() - e.Title:GetLeft()
	if offset then
		local offset = e.Title:GetLeft() - e.Title:GetParent():GetLeft()
		width = width + offset
	end
	return width
end

local function SetTitleWidth(e, width)
	assert(type(tonumber(width)) == "number", "param 1 must be a number!")
	assert(tonumber(width) >= 0, "param 1 must be a positive number!")
	
	e.Title:SetWidth(width)
end

local function GetTitleWidth(e)
	return e.Title:GetWidth()
end

local function SetHeight(e, height)
	assert(type(tonumber(height)) == "number", "param 1 must be a number!")
	assert(tonumber(height) >= 0, "param 1 must be a positive number!")

	e.Title:SetHeight(height)
	e.FieldOutline:SetHeight(height)
	e.Field:SetHeight(height-2)
end

local function GetHeight(e, offset)
	local height = e.FieldOutline:GetHeight()
	if offset then
		local offset = e.FieldOutline:GetTop() - e.FieldOutline:GetParent():GetTop()
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
		local text = e.Field:GetText()
		for _,f in ipairs(e.followers) do
			if type(f) == "function" then f(text) end
		end
	end
end


-- Constructor
function Library.TwinElements.Input(name, parent)
	local Element = {}
	local frameName = toc.description .. " Input "
	
	Element.Type = "text" -- default type
	
	-- Title
	Element.Title = UI.CreateFrame("Text", frameName .. "Title", parent)
	Element.Title:SetText(name .. ":")
	Element.Title:SetFontColor(unpack(COLOR.white))
	Element.Title:SetFontSize(16)
	-- Element outline
	Element.FieldOutline = UI.CreateFrame("Frame", frameName .. "Field Outline", parent)
	Element.FieldOutline:SetPoint("CENTERLEFT", Element.Title, "CENTERRIGHT", 10, 0)
	Element.FieldOutline:SetBackgroundColor(unpack(COLOR.color4))
	-- Element
	Element.Field = UI.CreateFrame("RiftTextfield", frameName .. "Field", Element.FieldOutline)
	Element.Field:SetPoint("CENTER", Element.FieldOutline, "CENTER", 0, 0)
	Element.Field:SetBackgroundColor(unpack(COLOR.black))
	Element.FieldOutline:SetHeight(Element.Field:GetHeight()+2)
	Element.FieldOutline:SetWidth(Element.Field:GetWidth()+2)
		--- Text change event ---
		Element.Field:EventAttach(Event.UI.Textfield.Change, function(h) InputTextHandler(Element)  end, "input changed")
		-------------------------
	
	--- Public functions ----
	Element.SetValues = SetValues
	Element.SetText = SetText
	Element.GetText = GetText
	Element.SetPoint = SetPoint
	Element.SetWidth = SetWidth
	Element.GetWidth = GetWidth
	Element.SetTitleWidth = SetTitleWidth
	Element.GetTitleWidth = GetTitleWidth
	Element.SetHeight = SetHeight
	Element.GetHeight = GetHeight
	Element.Follow = Follow
	Element.Notify = Notify
	-------------------------
	
	return Element
end