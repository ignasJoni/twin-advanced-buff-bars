-- Setting up initial data
--TwinABB.context = UI.CreateContext('TwinABBContext')
--TwinABB.identifier = "TwinABB"

local toc, data = ...
local AddonId = toc.identifier

-- Generate the root context for UI elements, and secure it
TwinABB.Context = UI.CreateContext('tABBContext')
TwinABB.Context:SetSecureMode("restricted")

function init()
	-- print_r(toc)
end

init()

-- Checks if time has passed
local function Milisec(x)
	local passed = x
	local lastTime = Inspect.Time.Frame()
	return function ()
		local curr = Inspect.Time.Frame()
		local diff = curr - lastTime
		if diff >= passed then
			lastTime = curr
			return true
		end
		return false
	end
end

-- Setup player's configurations (twinConfig)
local function LoadConfig(reset)
	
	--/ Buff Frames
	
	-- PLAYER
	if twinConfig.player == nil or reset then 
		twinConfig.player = {
			Scale = 1,
			StickTo = "screen",
			AnchorSelf = "N",
			AnchorTarget = "N",
			OffsetTop = 0,
			OffsetLeft = 0
		} 
	end
	
	-- GROUP
	if twinConfig.group == nil or reset then 
		twinConfig.group = {
			Scale = 1,
			StickTo = "player",
			AnchorSelf = "NE",
			AnchorTarget = "SE",
			OffsetTop = 0,
			OffsetLeft = 0
		} 
	end
	
	-- DEBUFF
	if twinConfig.debuff == nil or reset then 
		twinConfig.debuff = {
			Scale = 1,
			StickTo = "group",
			AnchorSelf = "NE",
			AnchorTarget = "SE",
			OffsetTop = 0,
			OffsetLeft = 0
		} 
	end
	
	--\ Buff Frame
	
end

function TwinABB.OnSavedVariablesLoaded()
	-- Setting config storage
	if twinConfig == nil then twinConfig = {} end

	-- Loading Settings Panel
	TwinABB.SettingsPanel = TwinElem:loadSettingsPanel()
	-- Load player's configuration and update Settings Panel to match
	LoadConfig()
	TwinABB.SettingsPanel:MatchConfig()
	TwinABB.SettingsPanel:EnableUpdateOnChange()
	
	
	--[[
	local function windowHideCallback(visible)
		print(tostring(visible))
	end
	TwinABB.SettingsPanel.Frame:Follow(windowHideCallback)
	]]--

	-- Loading add-on button and enabling Toggle
	TwinABB.Button = TwinElem:loadAddonButton(TwinABB.SettingsPanel.Frame.Content)
	--[[
	local function ButtonPressedCallback()
		print(tostring(TwinABB.SettingsPanel:GetVisible()))
	end
	TwinABB.Button:Follow(ButtonPressedCallback)
	]]--
	
	-- Loading Buffs Frames
	TwinABB.PlayerFrame = TwinElem:createBuffFrame("player", "Player Buffs", TwinABB.Context)
	TwinABB.GroupFrame = TwinElem:createBuffFrame("group", "Group Buffs", TwinABB.Context)
	TwinABB.DebuffFrame = TwinElem:createBuffFrame("debuff", "Debuff Buffs", TwinABB.Context)
	
	-- Setting position
	TwinABB.PlayerFrame:SetPoint(PtP(twinConfig.player.AnchorSelf), NtF(twinConfig.player.StickTo), PtP(twinConfig.player.AnchorTarget), twinConfig.player.OffsetLeft, twinConfig.player.OffsetTop)
	TwinABB.GroupFrame:SetPoint(PtP(twinConfig.group.AnchorSelf), NtF(twinConfig.group.StickTo), PtP(twinConfig.group.AnchorTarget), twinConfig.group.OffsetLeft, twinConfig.group.OffsetTop)
	TwinABB.DebuffFrame:SetPoint(PtP(twinConfig.debuff.AnchorSelf), NtF(twinConfig.debuff.StickTo), PtP(twinConfig.debuff.AnchorTarget), twinConfig.debuff.OffsetLeft, twinConfig.debuff.OffsetTop)
	
	-- Show changes when settings are altered
	TwinABB.SettingsPanel:EnableFramesUpdate()
	
	-- Loading buffs manager
	--TwinABB.Buffs = TwinElem:loadBuffsManager()
	--[[
	local function playerCallback(action, buff)
		if action == "ADD" then
			TwinABB.PlayerFrame:AddBuff(buff)
		elseif action == "REMOVE" then
			TwinABB.PlayerFrame:RemoveBuff(buff)
		end
	end
	TwinABB.Buffs:FollowPlayer(playerCallback)
	
	local function groupCallback(action, buff)
		if action == "ADD" then
			TwinABB.GroupFrame:AddBuff(buff)
		elseif action == "REMOVE" then
			TwinABB.GroupFrame:RemoveBuff(buff)
		end
	end
	TwinABB.Buffs:FollowGroup(groupCallback)
	
	local function debuffCallback(action, buff)
		if action == "ADD" then
			TwinABB.DebuffFrame:AddBuff(buff)
		elseif action == "REMOVE" then
			TwinABB.DebuffFrame:RemoveBuff(buff)
		end
	end
	TwinABB.Buffs:FollowDebuff(debuffCallback)
	
	-- Start updating time
	local DoUpdate = Milisec(0.2)
	local function CheckTime()
		if DoUpdate() then
			TwinABB.PlayerFrame:UpdateTime()
			TwinABB.GroupFrame:UpdateTime()
			TwinABB.DebuffFrame:UpdateTime()
		end
	end
	Command.Event.Attach(Event.System.Update.End, CheckTime, "update end")
	]]--
end

table.insert(Event.Addon.SavedVariables.Load.End, { function(identifier) if identifier == AddonId then TwinABB.OnSavedVariablesLoaded() end end, AddonId, AddonId .. "_OnSavedVariablesLoaded" })

--table.insert(Event.Addon.Startup.End, { TwinABB.OnAddonStartupEnd, AddonId, AddonId .. "_OnAddonStartupEnd" })
--table.insert(Event.Addon.Startup.End, { WT.OnAddonStartupEnd, AddonId, AddonId .. "_OnAddonStartupEnd" })
