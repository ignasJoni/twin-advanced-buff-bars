--
-- Add-on Settings Panel
--

local toc, data = ...
local AddonId = toc.identifier
local AddonName = "Advanced Buff Bars"
local SettingsPanel = {}


--[[
-- Add supporting functionality for StickTo
]]
local function EnableStickTo()
	local tab = SettingsPanel.tabs.Layout.Content
	
	-- Check for allowed options
	local function CheckOptions(sender, optionKey)
		--[[ Initiate checks for each group ]]--
		local player, group, debuff = tab.PersonalBuffs.StickTo, tab.GroupBuffs.StickTo, tab.Debuffs.StickTo
		local playerTarget, groupTarget, debuffTarget = player:GetChecked()[1], group:GetChecked()[1], debuff:GetChecked()[1]
		
		-- General
		if (playerTarget == "screen") then group:EnableOption(nil, "player") debuff:EnableOption(nil, "player") end
		if (groupTarget == "screen") then player:EnableOption(nil, "group") debuff:EnableOption(nil, "group") end
		if (debuffTarget == "screen") then player:EnableOption(nil, "debuff") group:EnableOption(nil, "debuff") end
		
		
		-- PersonalBuffs
		if (groupTarget == "player") then player:DisableOption(nil, "group")
		elseif ((groupTarget == "debuff") and (debuffTarget == "screen")) then player:EnableOption(nil, "group")
		elseif ((groupTarget == "debuff") and (debuffTarget ~= "screen")) then player:DisableOption(nil, "group") 
		end
		
		if (debuffTarget == "player") then player:DisableOption(nil, "debuff")
		elseif ((debuffTarget == "group") and (groupTarget == "screen")) then player:EnableOption(nil, "debuff")
		elseif ((debuffTarget == "group") and (groupTarget ~= "screen")) then player:DisableOption(nil, "debuff") 
		end
		
		
		-- GroupBuffs
		if (playerTarget == "group") then group:DisableOption(nil, "player")
		elseif ((playerTarget == "debuff") and (debuffTarget == "screen")) then group:EnableOption(nil, "player")
		elseif ((playerTarget == "debuff") and (debuffTarget ~= "screen")) then group:DisableOption(nil, "player") 
		end
		
		if (debuffTarget == "group") then group:DisableOption(nil, "debuff")
		elseif ((debuffTarget == "player") and (playerTarget == "screen")) then group:EnableOption(nil, "debuff")	
		elseif ((debuffTarget == "player") and (playerTarget ~= "screen")) then group:DisableOption(nil, "debuff") 
		end		
		
		
		-- Debuffs
		if (playerTarget == "debuff") then debuff:DisableOption(nil, "player")
		elseif ((playerTarget == "group") and (groupTarget == "screen")) then debuff:EnableOption(nil, "player")
		elseif ((playerTarget == "group") and (groupTarget ~= "screen")) then debuff:DisableOption(nil, "player") 
		end
		
		if (groupTarget == "debuff") then debuff:DisableOption(nil, "group")
		elseif ((groupTarget == "player") and (playerTarget == "screen")) then debuff:EnableOption(nil, "group")	
		elseif ((groupTarget == "player") and (playerTarget ~= "screen")) then debuff:DisableOption(nil, "group") 
		end				
		
	end
	
	tab.PersonalBuffs.StickTo:Follow(function(key) CheckOptions("PersonalBuffs", key) end)
	tab.GroupBuffs.StickTo:Follow(function(key) CheckOptions("GroupBuffs", key) end)
	tab.Debuffs.StickTo:Follow(function(key) CheckOptions("Debuffs", key) end)

end

--[[
-- Fills Layout tab content
]]
local function loadTab_Layout()
	if not SettingsPanel.tabs.Layout then return end -- Tab not loaded yet
	local Content = SettingsPanel.tabs.Layout.Content
	
	--\ PERSONAL BUFFS
	-- section
	local PersonalBuffs = UI.TwinElem("Section", "Personal Buffs", Content)
	PersonalBuffs:SetHeight(165)
	PersonalBuffs:SetPoint("TOPLEFT", Content, "TOPLEFT", 4, 4)
	
	-- input: Scale
	PersonalBuffs.Scale = UI.TwinElem("Input", "Scale", PersonalBuffs.Content.Holder)
	PersonalBuffs.Scale:SetValues{limit=1, inputType="number", nonDecimal=false, width=100, minValue=0.1, maxValue=3}
	PersonalBuffs.Scale:SetPoint("TOPLEFT", PersonalBuffs.Content.Holder, "TOPLEFT", 0, 0)
	
	-- checkbox group: Stick to
	PersonalBuffs.StickTo = UI.TwinElem("CheckboxGroup", "Stick to", PersonalBuffs.Content.Holder)
	PersonalBuffs.StickTo:SetValues{select = "single", allowEmpty = false}
	PersonalBuffs.StickTo:SetPoint("TOPLEFT", PersonalBuffs.Content.Holder, "TOPLEFT", 0, PersonalBuffs.Scale:GetHeight()+4 )
	PersonalBuffs.StickTo:AddOptions{
		{"'Group' frame", "group"},
		{"'Debuff' frame", "debuff"},
		{"Screen", "screen"}
	}
	
	-- anchor box: AnchorSelf
	PersonalBuffs.AnchorSelf = UI.TwinElem("CheckboxAnchors", "Anchor Self", PersonalBuffs.Content.Holder)
	PersonalBuffs.AnchorSelf:SetPoint("TOPLEFT", PersonalBuffs.Content.Holder, "TOPLEFT", PersonalBuffs.StickTo:GetWidth()+40, PersonalBuffs.Scale:GetHeight()+4 )
	
	-- anchor box: AnchorTarget
	PersonalBuffs.AnchorTarget = UI.TwinElem("CheckboxAnchors", "Anchor Target", PersonalBuffs.Content.Holder)
	PersonalBuffs.AnchorTarget:SetPoint("TOPLEFT", PersonalBuffs.Content.Holder, "TOPLEFT", PersonalBuffs.AnchorSelf:GetWidth(true)+60, PersonalBuffs.Scale:GetHeight()+4 )
	
	-- offset top: OffsetTop
	PersonalBuffs.OffsetTop = UI.TwinElem("Input", "Offset Top", PersonalBuffs.Content.Holder)
	PersonalBuffs.OffsetTop:SetValues{inputType="number", nonDecimal=true, width=100}
	PersonalBuffs.OffsetTop:SetPoint("TOPLEFT", PersonalBuffs.Content.Holder, "TOPLEFT", PersonalBuffs.AnchorTarget:GetWidth(true)+60, PersonalBuffs.Scale:GetHeight()+4)
	
	-- offset left: OffsetLeft
	PersonalBuffs.OffsetLeft = UI.TwinElem("Input", "Offset Left", PersonalBuffs.Content.Holder)
	PersonalBuffs.OffsetLeft:SetValues{inputType="number", nonDecimal=true, width=100}
	PersonalBuffs.OffsetLeft:SetPoint("TOPLEFT", PersonalBuffs.Content.Holder, "TOPLEFT", PersonalBuffs.AnchorTarget:GetWidth(true)+60, PersonalBuffs.OffsetTop:GetHeight(true)+10)
	PersonalBuffs.OffsetLeft:SetTitleWidth(PersonalBuffs.OffsetTop:GetTitleWidth())
	
	--/ PERSONAL BUFFS
	SettingsPanel.tabs.Layout.Content.PersonalBuffs = PersonalBuffs
	
	
	
	--\ GROUP BUFFS
	local GroupBuffs = UI.TwinElem("Section", "Group Buffs", Content)
	GroupBuffs:SetHeight(165)
	GroupBuffs:SetPoint("TOPLEFT", Content, "TOPLEFT", 4, PersonalBuffs:GetHeight(true)+12)
	
	-- input: Scale
	GroupBuffs.Scale = UI.TwinElem("Input", "Scale", GroupBuffs.Content.Holder)
	GroupBuffs.Scale:SetValues{limit=1, inputType="number", nonDecimal=false, width=100, minValue=0.1, maxValue=3}
	GroupBuffs.Scale:SetPoint("TOPLEFT", GroupBuffs.Content.Holder, "TOPLEFT", 0, 0)
	
	-- checkbox group: Stick to
	GroupBuffs.StickTo = UI.TwinElem("CheckboxGroup", "Stick to", GroupBuffs.Content.Holder)
	GroupBuffs.StickTo:SetValues{select = "single", allowEmpty = false}
	GroupBuffs.StickTo:SetPoint("TOPLEFT", GroupBuffs.Content.Holder, "TOPLEFT", 0, GroupBuffs.Scale:GetHeight()+4 )
	GroupBuffs.StickTo:AddOptions{
		{"'Player' frame", "player"},
		{"'Debuff' frame", "debuff"},
		{"Screen", "screen"}
	}
	
	-- anchor box: AnchorSelf
	GroupBuffs.AnchorSelf = UI.TwinElem("CheckboxAnchors", "Anchor Self", GroupBuffs.Content.Holder)
	GroupBuffs.AnchorSelf:SetPoint("TOPLEFT", GroupBuffs.Content.Holder, "TOPLEFT", GroupBuffs.StickTo:GetWidth()+40, GroupBuffs.Scale:GetHeight()+4 )
	
	-- anchor box: AnchorTarget
	GroupBuffs.AnchorTarget = UI.TwinElem("CheckboxAnchors", "Anchor Target", GroupBuffs.Content.Holder)
	GroupBuffs.AnchorTarget:SetPoint("TOPLEFT", GroupBuffs.Content.Holder, "TOPLEFT", GroupBuffs.AnchorSelf:GetWidth(true)+60, GroupBuffs.Scale:GetHeight()+4 )
	
	-- offset top: OffsetTop
	GroupBuffs.OffsetTop = UI.TwinElem("Input", "Offset Top", GroupBuffs.Content.Holder)
	GroupBuffs.OffsetTop:SetValues{inputType="number", nonDecimal=true, width=100}
	GroupBuffs.OffsetTop:SetPoint("TOPLEFT", GroupBuffs.Content.Holder, "TOPLEFT", GroupBuffs.AnchorTarget:GetWidth(true)+60, GroupBuffs.Scale:GetHeight()+4)
	
	-- offset left: OffsetLeft
	GroupBuffs.OffsetLeft = UI.TwinElem("Input", "Offset Left", GroupBuffs.Content.Holder)
	GroupBuffs.OffsetLeft:SetValues{inputType="number", nonDecimal=true, width=100}
	GroupBuffs.OffsetLeft:SetPoint("TOPLEFT", GroupBuffs.Content.Holder, "TOPLEFT", GroupBuffs.AnchorTarget:GetWidth(true)+60, GroupBuffs.OffsetTop:GetHeight(true)+10)
	GroupBuffs.OffsetLeft:SetTitleWidth(GroupBuffs.OffsetTop:GetTitleWidth())
	
	--/ GROUP BUFFS
	SettingsPanel.tabs.Layout.Content.GroupBuffs = GroupBuffs
	
	
	
	--\ DEBUFFS
	local Debuffs = UI.TwinElem("Section", "Debuffs", Content)
	Debuffs:SetHeight(165)
	Debuffs:SetPoint("TOPLEFT", Content, "TOPLEFT", 4, GroupBuffs:GetHeight(true)+12)
	
	-- input: Scale
	Debuffs.Scale = UI.TwinElem("Input", "Scale", Debuffs.Content.Holder)
	Debuffs.Scale:SetValues{limit=1, inputType="number", nonDecimal=false, width=100, minValue=0.1, maxValue=3}
	Debuffs.Scale:SetPoint("TOPLEFT", Debuffs.Content.Holder, "TOPLEFT", 0, 0)
	
	-- checkbox group: Stick to
	Debuffs.StickTo = UI.TwinElem("CheckboxGroup", "Stick to", Debuffs.Content.Holder)
	Debuffs.StickTo:SetValues{select = "single", allowEmpty = false}
	Debuffs.StickTo:SetPoint("TOPLEFT", Debuffs.Content.Holder, "TOPLEFT", 0, Debuffs.Scale:GetHeight()+4 )
	Debuffs.StickTo:AddOptions{
		{"'Player' frame", "player"},
		{"'Group' frame", "group"},
		{"Screen", "screen"}
	}
	
	-- anchor box: AnchorSelf
	Debuffs.AnchorSelf = UI.TwinElem("CheckboxAnchors", "Anchor Self", Debuffs.Content.Holder)
	Debuffs.AnchorSelf:SetPoint("TOPLEFT", Debuffs.Content.Holder, "TOPLEFT", Debuffs.StickTo:GetWidth()+40, Debuffs.Scale:GetHeight()+4 )
	
	-- anchor box: AnchorTarget
	Debuffs.AnchorTarget = UI.TwinElem("CheckboxAnchors", "Anchor Target", Debuffs.Content.Holder)
	Debuffs.AnchorTarget:SetPoint("TOPLEFT", Debuffs.Content.Holder, "TOPLEFT", Debuffs.AnchorSelf:GetWidth(true)+60, Debuffs.Scale:GetHeight()+4 )
	
	-- offset top: OffsetTop
	Debuffs.OffsetTop = UI.TwinElem("Input", "Offset Top", Debuffs.Content.Holder)
	Debuffs.OffsetTop:SetValues{inputType="number", nonDecimal=true, width=100}
	Debuffs.OffsetTop:SetPoint("TOPLEFT", Debuffs.Content.Holder, "TOPLEFT", Debuffs.AnchorTarget:GetWidth(true)+60, Debuffs.Scale:GetHeight()+4)
	
	-- offset left: OffsetLeft
	Debuffs.OffsetLeft = UI.TwinElem("Input", "Offset Left", Debuffs.Content.Holder)
	Debuffs.OffsetLeft:SetValues{inputType="number", nonDecimal=true, width=100}
	Debuffs.OffsetLeft:SetPoint("TOPLEFT", Debuffs.Content.Holder, "TOPLEFT", Debuffs.AnchorTarget:GetWidth(true)+60, Debuffs.OffsetTop:GetHeight(true)+10)
	Debuffs.OffsetLeft:SetTitleWidth(Debuffs.OffsetTop:GetTitleWidth())
	
	--/ DEBUFFS
	SettingsPanel.tabs.Layout.Content.Debuffs = Debuffs

	EnableStickTo()
end

--[[
-- Fills Player tab content
]]
local function loadTab_Player()
	if not SettingsPanel.tabs.Player then return end -- Tab not loaded yet
	local Content = SettingsPanel.tabs.Player.Content
	
	--\ LAYOUT
	
	-- section
	local Layout = UI.TwinElem("Section", "Layout", Content)
	Layout:SetHeight(155)
	Layout:SetPoint("TOPLEFT", Content, "TOPLEFT", 4, 4)
	
	-- checkbox group: Growth
	Layout.Growth = UI.TwinElem("CheckboxGroup", "Growth direction", Layout.Content.Holder)
	Layout.Growth:SetValues{select = "single", allowEmpty = false}
	Layout.Growth:SetPoint("TOPLEFT", Layout.Content.Holder, "TOPLEFT", 0, 0 )
	Layout.Growth:AddOptions{"to TOP", "to BOTTOM", "to LEFT", "to RIGHT"}
	
	-- checkbox group: BuffsPerRow
	Layout.BuffsPerRow = UI.TwinElem("CheckboxGroup", "Buffs Per Row", Layout.Content.Holder)
	Layout.BuffsPerRow:SetValues{select = "single", allowEmpty = false}
	Layout.BuffsPerRow:SetPoint("TOPLEFT", Layout.Content.Holder, "TOPLEFT", Layout.Growth:GetWidth()+60, 0 )
	Layout.BuffsPerRow:AddOptions{"Unlimited", "Limited"}
	
	-- input: Limit
	Layout.Limit = UI.TwinElem("Input", "Limit", Layout.Content.Holder)
	Layout.Limit:SetValues{inputType="number-positive", nonDecimal=true, minValue=1, maxValue=50, width=50}
	Layout.Limit:SetPoint("CENTERLEFT", Layout.BuffsPerRow.options[2].Title, "CENTERRIGHT", 30, 0)
	
	-- checkbox group: NewLine
	Layout.NewLine = UI.TwinElem("CheckboxGroup", "New Line (relative to direction)", Layout.Content.Holder)
	Layout.NewLine:SetValues{select = "single", allowEmpty = false}
	Layout.NewLine:SetPoint("TOPLEFT", Layout.Content.Holder, "TOPLEFT", Layout.Limit:GetWidth(true)+30, (Layout.Limit:GetHeight(true) - Layout.Limit:GetHeight()))
	Layout.NewLine:AddOptions{"Up / Right", "Down / Left"}
	
	--/ LAYOUT
	SettingsPanel.tabs.Player.Content.Layout = Layout
	
	
	
	--\ GROUPING
	
	-- section
	local Grouping = UI.TwinElem("Section", "Grouping", Content)
	Grouping:SetHeight(350)
	Grouping:SetPoint("TOPLEFT", Content, "TOPLEFT", 4, Layout:GetHeight(true)+12)
	
	
	-- list: ListGroups
	Grouping.ListGroup = UI.TwinElem("List", "Groups", Grouping.Content.Holder)
	Grouping.ListGroup:SetPoint("TOPLEFT", Grouping.Content.Holder, "TOPLEFT", 0, 0)
	Grouping.ListGroup:SetHeight(Grouping.Content.Holder:GetHeight()-4)
	
	-- button: BtnGetGroup
	Grouping.BtnGetGroup = UI.TwinElem("Button", ">>", Grouping.Content.Holder)
	Grouping.BtnGetGroup:SetPoint("CENTERLEFT", Grouping.ListGroup.Items.Outline, "CENTERRIGHT", 20, -20)
	
	-- button: BtnGetUse
	Grouping.BtnGetUse = UI.TwinElem("Button", "<<", Grouping.Content.Holder)
	Grouping.BtnGetUse:SetPoint("CENTERLEFT", Grouping.ListGroup.Items.Outline, "CENTERRIGHT", 20, 20)
	
	-- list: ListToUse
	Grouping.ListToUse = UI.TwinElem("List", "To use", Grouping.Content.Holder)
	Grouping.ListToUse:SetPoint("TOPLEFT", Grouping.Content.Holder, "TOPLEFT", Grouping.BtnGetGroup:GetWidth(true) + 20, 0)
	Grouping.ListToUse:SetHeight(Grouping.Content.Holder:GetHeight()-4)
	
	-- Notes
	Grouping.Notes = UI.CreateFrame("Text", Grouping.Content.Holder:GetName() .. " Notes", Grouping.Content.Holder)
	Grouping.Notes:SetPoint("TOPLEFT", Grouping.Content.Holder, "TOPLEFT", Grouping.ListToUse:GetWidth(true)+30, 0)
	Grouping.Notes:SetWordwrap(true)
	Grouping.Notes:SetWidth(Grouping.Content.Holder:GetWidth() - Grouping.ListToUse:GetWidth(true)-30)
	Grouping.Notes:SetFontColor(unpack(COLOR.white))
	Grouping.Notes:SetEffectGlow{}
	local noteOrder = "\n- The order of Groups will be the same as order inside 'To use' list;"
	local noteBuff = "\n- A buff will be asigned to the first group which conditions it matches;"
	Grouping.Notes:SetText("Notes:" .. noteOrder .. noteBuff)
	
	--/ GROUPING
	SettingsPanel.tabs.Player.Content.Grouping = Grouping
end

--[[
-- Fills Group tab content
]]
local function loadTab_Group()
	if not SettingsPanel.tabs.Group then return end -- Tab not loaded yet
	local Content = SettingsPanel.tabs.Group.Content
	
	--\ LAYOUT
	
	-- section
	local Layout = UI.TwinElem("Section", "Layout", Content)
	Layout:SetHeight(155)
	Layout:SetPoint("TOPLEFT", Content, "TOPLEFT", 4, 4)
	
	-- checkbox group: Growth
	Layout.Growth = UI.TwinElem("CheckboxGroup", "Growth direction", Layout.Content.Holder)
	Layout.Growth:SetValues{select = "single", allowEmpty = false}
	Layout.Growth:SetPoint("TOPLEFT", Layout.Content.Holder, "TOPLEFT", 0, 0 )
	Layout.Growth:AddOptions{"to TOP", "to BOTTOM", "to LEFT", "to RIGHT"}
	
	-- checkbox group: BuffsPerRow
	Layout.BuffsPerRow = UI.TwinElem("CheckboxGroup", "Buffs Per Row", Layout.Content.Holder)
	Layout.BuffsPerRow:SetValues{select = "single", allowEmpty = false}
	Layout.BuffsPerRow:SetPoint("TOPLEFT", Layout.Content.Holder, "TOPLEFT", Layout.Growth:GetWidth()+60, 0 )
	Layout.BuffsPerRow:AddOptions{"Unlimited", "Limited"}
	
	-- input: Limit
	Layout.Limit = UI.TwinElem("Input", "Limit", Layout.Content.Holder)
	Layout.Limit:SetValues{inputType="number-positive", nonDecimal=true, minValue=1, maxValue=50, width=50}
	Layout.Limit:SetPoint("CENTERLEFT", Layout.BuffsPerRow.options[2].Title, "CENTERRIGHT", 30, 0)
	
	-- checkbox group: NewLine
	Layout.NewLine = UI.TwinElem("CheckboxGroup", "New Line (relative to direction)", Layout.Content.Holder)
	Layout.NewLine:SetValues{select = "single", allowEmpty = false}
	Layout.NewLine:SetPoint("TOPLEFT", Layout.Content.Holder, "TOPLEFT", Layout.Limit:GetWidth(true)+30, (Layout.Limit:GetHeight(true) - Layout.Limit:GetHeight()))
	Layout.NewLine:AddOptions{"Up / Right", "Down / Left"}
	
	--/ LAYOUT
	SettingsPanel.tabs.Group.Content.Layout = Layout
	
	
	
	--\ GROUPING
	
	-- section
	local Grouping = UI.TwinElem("Section", "Grouping", Content)
	Grouping:SetHeight(350)
	Grouping:SetPoint("TOPLEFT", Content, "TOPLEFT", 4, Layout:GetHeight(true)+12)
	
	
	-- list: ListGroups
	Grouping.ListGroup = UI.TwinElem("List", "Groups", Grouping.Content.Holder)
	Grouping.ListGroup:SetPoint("TOPLEFT", Grouping.Content.Holder, "TOPLEFT", 0, 0)
	Grouping.ListGroup:SetHeight(Grouping.Content.Holder:GetHeight()-4)
	
	-- button: BtnGetGroup
	Grouping.BtnGetGroup = UI.TwinElem("Button", ">>", Grouping.Content.Holder)
	Grouping.BtnGetGroup:SetPoint("CENTERLEFT", Grouping.ListGroup.Items.Outline, "CENTERRIGHT", 20, -20)
	
	-- button: BtnGetUse
	Grouping.BtnGetUse = UI.TwinElem("Button", "<<", Grouping.Content.Holder)
	Grouping.BtnGetUse:SetPoint("CENTERLEFT", Grouping.ListGroup.Items.Outline, "CENTERRIGHT", 20, 20)
	
	-- list: ListToUse
	Grouping.ListToUse = UI.TwinElem("List", "To use", Grouping.Content.Holder)
	Grouping.ListToUse:SetPoint("TOPLEFT", Grouping.Content.Holder, "TOPLEFT", Grouping.BtnGetGroup:GetWidth(true) + 20, 0)
	Grouping.ListToUse:SetHeight(Grouping.Content.Holder:GetHeight()-4)
	
	-- Notes
	Grouping.Notes = UI.CreateFrame("Text", Grouping.Content.Holder:GetName() .. " Notes", Grouping.Content.Holder)
	Grouping.Notes:SetPoint("TOPLEFT", Grouping.Content.Holder, "TOPLEFT", Grouping.ListToUse:GetWidth(true)+30, 0)
	Grouping.Notes:SetWordwrap(true)
	Grouping.Notes:SetWidth(Grouping.Content.Holder:GetWidth() - Grouping.ListToUse:GetWidth(true)-30)
	Grouping.Notes:SetFontColor(unpack(COLOR.white))
	Grouping.Notes:SetEffectGlow{}
	local noteOrder = "\n- The order of Groups will be the same as order inside 'To use' list;"
	local noteBuff = "\n- A buff will be asigned to the first group which conditions it matches;"
	Grouping.Notes:SetText("Notes:" .. noteOrder .. noteBuff)
	
	--/ GROUPING
	SettingsPanel.tabs.Group.Content.Grouping = Grouping
end

--[[
-- Fills Debuff tab content
]]
local function loadTab_Debuff()
	if not SettingsPanel.tabs.Debuff then return end -- Tab not loaded yet
	local Content = SettingsPanel.tabs.Debuff.Content
	
	--\ LAYOUT
	
	-- section
	local Layout = UI.TwinElem("Section", "Layout", Content)
	Layout:SetHeight(155)
	Layout:SetPoint("TOPLEFT", Content, "TOPLEFT", 4, 4)
	
	-- checkbox group: Growth
	Layout.Growth = UI.TwinElem("CheckboxGroup", "Growth direction", Layout.Content.Holder)
	Layout.Growth:SetValues{select = "single", allowEmpty = false}
	Layout.Growth:SetPoint("TOPLEFT", Layout.Content.Holder, "TOPLEFT", 0, 0 )
	Layout.Growth:AddOptions{"to TOP", "to BOTTOM", "to LEFT", "to RIGHT"}
	
	-- checkbox group: BuffsPerRow
	Layout.BuffsPerRow = UI.TwinElem("CheckboxGroup", "Buffs Per Row", Layout.Content.Holder)
	Layout.BuffsPerRow:SetValues{select = "single", allowEmpty = false}
	Layout.BuffsPerRow:SetPoint("TOPLEFT", Layout.Content.Holder, "TOPLEFT", Layout.Growth:GetWidth()+60, 0 )
	Layout.BuffsPerRow:AddOptions{"Unlimited", "Limited"}
	
	-- input: Limit
	Layout.Limit = UI.TwinElem("Input", "Limit", Layout.Content.Holder)
	Layout.Limit:SetValues{inputType="number-positive", nonDecimal=true, minValue=1, maxValue=50, width=50}
	Layout.Limit:SetPoint("CENTERLEFT", Layout.BuffsPerRow.options[2].Title, "CENTERRIGHT", 30, 0)
	
	-- checkbox group: NewLine
	Layout.NewLine = UI.TwinElem("CheckboxGroup", "New Line (relative to direction)", Layout.Content.Holder)
	Layout.NewLine:SetValues{select = "single", allowEmpty = false}
	Layout.NewLine:SetPoint("TOPLEFT", Layout.Content.Holder, "TOPLEFT", Layout.Limit:GetWidth(true)+30, (Layout.Limit:GetHeight(true) - Layout.Limit:GetHeight()))
	Layout.NewLine:AddOptions{"Up / Right", "Down / Left"}
	
	--/ LAYOUT
	SettingsPanel.tabs.Debuff.Content.Layout = Layout
	
	
	
	--\ GROUPING
	
	-- section
	local Grouping = UI.TwinElem("Section", "Grouping", Content)
	Grouping:SetHeight(350)
	Grouping:SetPoint("TOPLEFT", Content, "TOPLEFT", 4, Layout:GetHeight(true)+12)
	
	
	-- list: ListGroups
	Grouping.ListGroup = UI.TwinElem("List", "Groups", Grouping.Content.Holder)
	Grouping.ListGroup:SetPoint("TOPLEFT", Grouping.Content.Holder, "TOPLEFT", 0, 0)
	Grouping.ListGroup:SetHeight(Grouping.Content.Holder:GetHeight()-4)
	
	-- button: BtnGetGroup
	Grouping.BtnGetGroup = UI.TwinElem("Button", ">>", Grouping.Content.Holder)
	Grouping.BtnGetGroup:SetPoint("CENTERLEFT", Grouping.ListGroup.Items.Outline, "CENTERRIGHT", 20, -20)
	
	-- button: BtnGetUse
	Grouping.BtnGetUse = UI.TwinElem("Button", "<<", Grouping.Content.Holder)
	Grouping.BtnGetUse:SetPoint("CENTERLEFT", Grouping.ListGroup.Items.Outline, "CENTERRIGHT", 20, 20)
	
	-- list: ListToUse
	Grouping.ListToUse = UI.TwinElem("List", "To use", Grouping.Content.Holder)
	Grouping.ListToUse:SetPoint("TOPLEFT", Grouping.Content.Holder, "TOPLEFT", Grouping.BtnGetGroup:GetWidth(true) + 20, 0)
	Grouping.ListToUse:SetHeight(Grouping.Content.Holder:GetHeight()-4)
	
	-- Notes
	Grouping.Notes = UI.CreateFrame("Text", Grouping.Content.Holder:GetName() .. " Notes", Grouping.Content.Holder)
	Grouping.Notes:SetPoint("TOPLEFT", Grouping.Content.Holder, "TOPLEFT", Grouping.ListToUse:GetWidth(true)+30, 0)
	Grouping.Notes:SetWordwrap(true)
	Grouping.Notes:SetWidth(Grouping.Content.Holder:GetWidth() - Grouping.ListToUse:GetWidth(true)-30)
	Grouping.Notes:SetFontColor(unpack(COLOR.white))
	Grouping.Notes:SetEffectGlow{}
	local noteOrder = "\n- The order of Groups will be the same as order inside 'To use' list;"
	local noteBuff = "\n- A buff will be asigned to the first group which conditions it matches;"
	Grouping.Notes:SetText("Notes:" .. noteOrder .. noteBuff)
	
	--/ GROUPING
	SettingsPanel.tabs.Debuff.Content.Grouping = Grouping
end

--[[
-- Fills Grouping tab content
]]
local function loadTab_Grouping()
	if not SettingsPanel.tabs.Grouping then return end -- Tab not loaded yet
	local Content = SettingsPanel.tabs.Grouping.Content
	
	--\ GROUPS
	
	-- section
	local Groups = UI.TwinElem("Section", "Groups list", Content)
	Groups:SetPoint("TOPLEFT", Content, "TOPLEFT", 4, 4)
	Groups:SetHeight(Content:GetHeight()-8)
	Groups:SetWidth(220)
	
	-- list: ListGroups
	Groups.ListGroups = UI.TwinElem("List", "To use", Groups.Content.Holder)
	Groups.ListGroups:SetPoint("TOPLEFT", Groups.Content.Holder, "TOPLEFT", 0, 0)
	Groups.ListGroups:SetHeight(300)
	
	--/ GROUPS
	SettingsPanel.tabs.Grouping.Content.Groups = Groups
	
	--\ SETTINGS
	
	-- section
	local Settings = UI.TwinElem("Section", "Settings", Content)
	Settings:SetPoint("TOPLEFT", Content, "TOPLEFT", Groups:GetWidth(true) + 8, 4)
	Settings:SetHeight(Content:GetHeight()-8)
	Settings:SetWidth(Content:GetWidth() - Groups:GetWidth(true) - 12)
	
	
	-- input: title
	Settings.Title = UI.TwinElem("Input", "Title", Settings.Content.Holder)
	Settings.Title:SetPoint("TOPLEFT", Settings.Content.Holder, "TOPLEFT", 0, 0)
	Settings.Title:SetValues{width=200}
	
	-- checkbox group: Filters
	Settings.Filters = UI.TwinElem("CheckboxGroup", "Filter", Settings.Content.Holder)
	Settings.Filters:SetPoint("TOPLEFT", Settings.Content.Holder, "TOPLEFT", 0, Settings.Title:GetHeight()+4 )
	Settings.Filters:SetValues{select = "single", allowEmpty = true}
	Settings.Filters:AddOptions{"Remaining time", "Buff name"}
	
	
		--\ sub: REMAINING TIME
		-- section
		local RemainingTime = UI.TwinElem("Subsection", "Remaining Time", Settings.Content.Holder)
		RemainingTime:SetPoint("TOPLEFT", Settings.Content.Holder, "TOPLEFT", 0, Settings.Filters:GetHeight(true)+12)
		RemainingTime:SetHeight(100)
		
		--input: Seconds
		RemainingTime.Seconds = UI.TwinElem("Input", "Seconds", RemainingTime.Content.Holder)
		RemainingTime.Seconds:SetPoint("TOPLEFT", RemainingTime.Content.Holder, "TOPLEFT", 0, 0)
		RemainingTime.Seconds:SetValues{inputType="number-positive", nonDecimal=true, minValue=0, width=100}
	
		-- checkbox group: Comparison
		RemainingTime.Comparison = UI.TwinElem("CheckboxGroup", "Logical comparison", RemainingTime.Content.Holder)
		RemainingTime.Comparison:SetPoint("TOPLEFT", RemainingTime.Content.Holder, "TOPLEFT", RemainingTime.Seconds:GetWidth()+20, 0 )
		RemainingTime.Comparison:SetValues{select = "single", allowEmpty = false}
		RemainingTime.Comparison:AddOptions{"More than", "Less than"}
		
		--/ sub: REMAINING TIME
		Settings.RemainingTime = RemainingTime
	
	
		--\ sub: BUFF NAME
		-- section
		local BuffName = UI.TwinElem("Subsection", "Buff name", Settings.Content.Holder)
		BuffName:SetPoint("TOPLEFT", Settings.Content.Holder, "TOPLEFT", 0, RemainingTime:GetHeight(true)+12)
		BuffName:SetHeight(270)
		
		--[[ Name is ]]--
		-- input: NameIs
		BuffName.NameIs = UI.TwinElem("Input", "Name is", BuffName.Content.Holder)
		BuffName.NameIs:SetPoint("TOPLEFT", BuffName.Content.Holder, "TOPLEFT", 30, 0)
		BuffName.NameIs:SetWidth(120)
		-- button: BtnAddNameIs
		BuffName.BtnAddNameIs = UI.TwinElem("Button", "Add", BuffName.Content.Holder)
		BuffName.BtnAddNameIs:SetPoint("CENTERLEFT", BuffName.NameIs.FieldOutline, "CENTERRIGHT", 8, 0)
		-- list: ListNameIs
		BuffName.ListNameIs = UI.TwinElem("List", "Name is", BuffName.Content.Holder)
		BuffName.ListNameIs:SetPoint("TOPLEFT", BuffName.Content.Holder, "TOPLEFT", 30, BuffName.NameIs:GetHeight()+8)
		BuffName.ListNameIs:SetWidth(BuffName.NameIs:GetWidth() + BuffName.BtnAddNameIs:GetWidth() + 6)
		BuffName.ListNameIs:SetHeight(170)
		-- button: BtnRemoveNameIs
		BuffName.BtnRemoveNameIs = UI.TwinElem("Button", "Remove Selected", BuffName.Content.Holder)
		BuffName.BtnRemoveNameIs:SetPoint("CENTERTOP", BuffName.ListNameIs.Items.Outline, "CENTERBOTTOM", 0, 4)
		
		--[[ Name contains ]]--
		-- input: NameContains
		BuffName.NameContains = UI.TwinElem("Input", "Name contains", BuffName.Content.Holder)
		BuffName.NameContains:SetPoint("TOPLEFT", BuffName.Content.Holder, "TOPLEFT", BuffName.BtnAddNameIs:GetWidth(true) + 60, 0)
		BuffName.NameContains:SetWidth(120)
		-- button: BtnAddNameContains
		BuffName.BtnAddNameContains = UI.TwinElem("Button", "Add", BuffName.Content.Holder)
		BuffName.BtnAddNameContains:SetPoint("CENTERLEFT", BuffName.NameContains.FieldOutline, "CENTERRIGHT", 8, 0)
		-- list: ListNameContains
		BuffName.ListNameContains = UI.TwinElem("List", "Name contains", BuffName.Content.Holder)
		BuffName.ListNameContains:SetPoint("TOPLEFT", BuffName.Content.Holder, "TOPLEFT", BuffName.BtnAddNameIs:GetWidth(true) + 60, BuffName.NameContains:GetHeight()+8)
		BuffName.ListNameContains:SetWidth(BuffName.NameContains:GetWidth() + BuffName.BtnAddNameContains:GetWidth() + 6)
		BuffName.ListNameContains:SetHeight(170)
		-- button: BtnRemoveNameContains
		BuffName.BtnRemoveNameContains = UI.TwinElem("Button", "Remove Selected", BuffName.Content.Holder)
		BuffName.BtnRemoveNameContains:SetPoint("CENTERTOP", BuffName.ListNameContains.Items.Outline, "CENTERBOTTOM", 0, 4)
		
		--/ sub: BUFF NAME
		Settings.BuffName = BuffName
		
		local function clickAdd1()
			local title = BuffName.NameIs:GetText()
			if string.len(title) > 0 then 
				BuffName.ListNameIs:AddItem(title)
				BuffName.NameIs:SetText("")
			end
		end
		BuffName.BtnAddNameIs:Follow(clickAdd1)
		
		local function clickAdd3()
			print("click")
		end
		BuffName.BtnAddNameIs:Follow(clickAdd3)
		
		local function clickAdd2()
			local title = BuffName.NameContains:GetText()
			if string.len(title) > 0 then 
				BuffName.ListNameContains:AddItem(title)
				BuffName.NameContains:SetText("")
			end
		end
		BuffName.BtnAddNameContains:Follow(clickAdd2)
		
		local function clickRemove1()
			local key, title = BuffName.ListNameIs:RemoveSelected()
			print(tostring(key) .. ":" .. tostring(title))
		end
		BuffName.BtnRemoveNameIs:Follow(clickRemove1)
		
		local function clickRemove2()
			local key, title = BuffName.ListNameContains:RemoveSelected()
			print(tostring(key) .. ":" .. tostring(title))
		end
		BuffName.BtnRemoveNameContains:Follow(clickRemove2)
	
	--/ SETTINGS
	SettingsPanel.tabs.Grouping.Content.Settings = Groups
	
end

--[[
-- Updates Settings Panel to match Configuration
-- @require Loaded twinConfig (assumes all data is set up)
]]
local function MatchConfig(e)
	local Config;
	
	-- Layout > PersonalBuffs
	local PersonalBuffs = e.tabs.Layout.Content.PersonalBuffs
	Config = twinConfig.player
	PersonalBuffs.Scale:SetText(Config.Scale)
	PersonalBuffs.StickTo:Select(nil, Config.StickTo)
	PersonalBuffs.AnchorSelf:Select(Config.AnchorSelf)
	PersonalBuffs.AnchorTarget:Select(Config.AnchorTarget)
	PersonalBuffs.OffsetTop:SetText(Config.OffsetTop)
	PersonalBuffs.OffsetLeft:SetText(Config.OffsetLeft)
	
	-- Layout > GroupBuffs
	local GroupBuffs = e.tabs.Layout.Content.GroupBuffs
	Config = twinConfig.group
	GroupBuffs.Scale:SetText(Config.Scale)
	GroupBuffs.StickTo:Select(nil, Config.StickTo)
	GroupBuffs.AnchorSelf:Select(Config.AnchorSelf)
	GroupBuffs.AnchorTarget:Select(Config.AnchorTarget)
	GroupBuffs.OffsetTop:SetText(Config.OffsetTop)
	GroupBuffs.OffsetLeft:SetText(Config.OffsetLeft)
	
	-- Layout > Debuffs
	local Debuffs = e.tabs.Layout.Content.Debuffs
	Config = twinConfig.debuff
	Debuffs.Scale:SetText(Config.Scale)
	Debuffs.StickTo:Select(nil, Config.StickTo)
	Debuffs.AnchorSelf:Select(Config.AnchorSelf)
	Debuffs.AnchorTarget:Select(Config.AnchorTarget)
	Debuffs.OffsetTop:SetText(Config.OffsetTop)
	Debuffs.OffsetLeft:SetText(Config.OffsetLeft)
end

--[[
-- Save changes made to configurations
-- @require Loaded twinConfig (assumes all data is set up)
]]
local function EnableUpdateOnChange(e)

	-- Layout > PersonalBuffs
	local PersonalBuffs = e.tabs.Layout.Content.PersonalBuffs
	PersonalBuffs.Scale:Follow(function(t) if tonumber(t) ~= nil then twinConfig.player.Scale = tonumber(t) end end)
	PersonalBuffs.StickTo:Follow(function(key) twinConfig.player.StickTo = key end)
	PersonalBuffs.AnchorSelf:Follow(function(pos) twinConfig.player.AnchorSelf = pos end)
	PersonalBuffs.AnchorTarget:Follow(function(pos) twinConfig.player.AnchorTarget = pos end)
	PersonalBuffs.OffsetTop:Follow(function(t) if tonumber(t) ~= nil then twinConfig.player.OffsetTop = tonumber(t) end end)
	PersonalBuffs.OffsetLeft:Follow(function(t) if tonumber(t) ~= nil then twinConfig.player.OffsetLeft = tonumber(t) end end)

	-- Layout > GroupBuffs
	local GroupBuffs = e.tabs.Layout.Content.GroupBuffs
	GroupBuffs.Scale:Follow(function(t) if tonumber(t) ~= nil then twinConfig.group.Scale = tonumber(t) end end)
	GroupBuffs.StickTo:Follow(function(key) twinConfig.group.StickTo = key end)
	GroupBuffs.AnchorSelf:Follow(function(pos) twinConfig.group.AnchorSelf = pos end)
	GroupBuffs.AnchorTarget:Follow(function(pos) twinConfig.group.AnchorTarget = pos end)
	GroupBuffs.OffsetTop:Follow(function(t) if tonumber(t) ~= nil then twinConfig.group.OffsetTop = tonumber(t) end end)
	GroupBuffs.OffsetLeft:Follow(function(t) if tonumber(t) ~= nil then twinConfig.group.OffsetLeft = tonumber(t) end end)
	
	-- Layout > GroupBuffs
	local Debuffs = e.tabs.Layout.Content.Debuffs
	Debuffs.Scale:Follow(function(t) if tonumber(t) ~= nil then twinConfig.debuff.Scale = tonumber(t) end end)
	Debuffs.StickTo:Follow(function(key) twinConfig.debuff.StickTo = key end)
	Debuffs.AnchorSelf:Follow(function(pos) twinConfig.debuff.AnchorSelf = pos end)
	Debuffs.AnchorTarget:Follow(function(pos) twinConfig.debuff.AnchorTarget = pos end)
	Debuffs.OffsetTop:Follow(function(t) if tonumber(t) ~= nil then twinConfig.debuff.OffsetTop = tonumber(t) end end)
	Debuffs.OffsetLeft:Follow(function(t) if tonumber(t) ~= nil then twinConfig.debuff.OffsetLeft = tonumber(t) end end)
	
end

--[[
-- Updates Buffs Frames on settings change
]]
local function EnableFramesUpdate(e)
	-- Layout > PersonalBuffs
	local player = NtF("player")
	local PersonalBuffs = e.tabs.Layout.Content.PersonalBuffs
	PersonalBuffs.Scale:Follow(function(t) if tonumber(t) ~= nil then player:ScaleDisplay(tonumber(t)) end end)
	--PersonalBuffs.StickTo:Follow(function(key) twinConfig.player.StickTo = key end)
	--PersonalBuffs.AnchorSelf:Follow(function(pos) twinConfig.player.AnchorSelf = pos end)
	--PersonalBuffs.AnchorTarget:Follow(function(pos) twinConfig.player.AnchorTarget = pos end)
	--PersonalBuffs.OffsetTop:Follow(function(t) if tonumber(t) ~= nil then twinConfig.player.OffsetTop = tonumber(t) end end)
	--PersonalBuffs.OffsetLeft:Follow(function(t) if tonumber(t) ~= nil then twinConfig.player.OffsetLeft = tonumber(t) end end)

	-- Layout > GroupBuffs
	local group = NtF("group")
	local GroupBuffs = e.tabs.Layout.Content.GroupBuffs
	GroupBuffs.Scale:Follow(function(t) if tonumber(t) ~= nil then group:ScaleDisplay(tonumber(t)) end end)
	--GroupBuffs.StickTo:Follow(function(key) twinConfig.group.StickTo = key end)
	--GroupBuffs.AnchorSelf:Follow(function(pos) twinConfig.group.AnchorSelf = pos end)
	--GroupBuffs.AnchorTarget:Follow(function(pos) twinConfig.group.AnchorTarget = pos end)
	--GroupBuffs.OffsetTop:Follow(function(t) if tonumber(t) ~= nil then twinConfig.group.OffsetTop = tonumber(t) end end)
	--GroupBuffs.OffsetLeft:Follow(function(t) if tonumber(t) ~= nil then twinConfig.group.OffsetLeft = tonumber(t) end end)
	
	-- Layout > GroupBuffs
	local debuff = NtF("debuff")
	local Debuffs = e.tabs.Layout.Content.Debuffs
	Debuffs.Scale:Follow(function(t) if tonumber(t) ~= nil then debuff:ScaleDisplay(tonumber(t)) end end)
	--Debuffs.StickTo:Follow(function(key) twinConfig.debuff.StickTo = key end)
	--Debuffs.AnchorSelf:Follow(function(pos) twinConfig.debuff.AnchorSelf = pos end)
	--Debuffs.AnchorTarget:Follow(function(pos) twinConfig.debuff.AnchorTarget = pos end)
	--Debuffs.OffsetTop:Follow(function(t) if tonumber(t) ~= nil then twinConfig.debuff.OffsetTop = tonumber(t) end end)
	--Debuffs.OffsetLeft:Follow(function(t) if tonumber(t) ~= nil then twinConfig.debuff.OffsetLeft = tonumber(t) end end)
end

--[[
-- Creates Settings Panel
-- @return SettingsPanel
]]
function TwinElem:loadSettingsPanel()
	-- Settings window
	SettingsPanel.Frame = UI.TwinElem("Window", AddonName, TwinABB.Context)
	SettingsPanel.Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	-- Tabs
	SettingsPanel.TabsPanel = UI.TwinElem("TabbedPanel", AddonName, SettingsPanel.Frame.Content)
	SettingsPanel.TabsPanel:SetPoint("CENTERTOP", SettingsPanel.Frame.Content, "CENTERTOP", 0, 4)
	
	--[[ Tab Items ]]--
	SettingsPanel.tabs = {}
	SettingsPanel.tabs.Layout = SettingsPanel.TabsPanel:AddItem("Layout", "LAYOUT")
	SettingsPanel.tabs.Player = SettingsPanel.TabsPanel:AddItem("Player", "PLAYER")
	SettingsPanel.tabs.Group = SettingsPanel.TabsPanel:AddItem("Group", "GROUP")
	SettingsPanel.tabs.Debuff = SettingsPanel.TabsPanel:AddItem("Debuff", "DEBUFF")
	SettingsPanel.tabs.Grouping = SettingsPanel.TabsPanel:AddItem("Grouping", "GROUPING")
	
	--[[ Items' Elements ]]--
	loadTab_Layout()
	loadTab_Player()
	loadTab_Group()
	loadTab_Debuff()
	loadTab_Grouping()
	
	-- Selecting first tab item
	SettingsPanel.TabsPanel:Select(1)
	
	--- Public functions ---
	SettingsPanel.GetVisible = function(e)
		return e.Frame:GetVisible()
	end
	SettingsPanel.MatchConfig = MatchConfig
	SettingsPanel.EnableUpdateOnChange = EnableUpdateOnChange
	SettingsPanel.EnableFramesUpdate = EnableFramesUpdate
	------------------------
	
	return SettingsPanel
end


