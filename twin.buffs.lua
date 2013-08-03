local toc, data = ...
local AddonId = toc.identifier
local PlayerId = Inspect.Unit.Lookup("player")

local BuffManager = {}
local BuffType = {}

local Types = {
	PLAYER = "player",
	GROUP = "group",
	DEBUFF = "debuff"
}

-- Logic Supporting functions
local function buffType(buff)
	local buffType;
	-- Check if its debuff
	if buff.debuff then return Types.DEBUFF end
	
	-- Check caster
	return buff.caster == PlayerId and Types.PLAYER or Types.GROUP
end

-- Logical functions
local function BuffAddHandler(h, unit, buffs)
	if unit ~= PlayerId then return end -- ignoring not own buffs
	
	local buffList = Inspect.Buff.Detail(PlayerId, buffs)
	for _,buff in pairs(buffList) do
		local buffType = buffType(buff)
		--if TwinBuff[buffType][buff.id] then
			-- buff already in the list
		--	return
		--else
			TwinBuff[buffType][buff.id] = buff
			BuffType[buff.id] = buffType
			BuffManager:Notify(buffType, "ADD", buff)
		--end
	end
end

local function BuffRemoveHandler(h, unit, buffs)
	if unit ~= PlayerId then return end -- ignoring not own buffs
	
	for id,_ in pairs(buffs) do
		local buffType = BuffType[id]
		TwinBuff[buffType][id] = nil
		BuffType[id] = nil
		BuffManager:Notify(buffType, "REMOVE", id)
	end
end

local function BuffChangeHandler(h, unit, buffs)

end


-- Supporting functions
local function FollowPlayer(e, callback)
	table.insert(e.followers.player, callback)
end

local function FollowGroup(e, callback)
	table.insert(e.followers.group, callback)
end

local function FollowDebuff(e, callback)
	table.insert(e.followers.debuff, callback)
end

local function Notify(e, buffType, action, buff)
	for _,f in ipairs(e.followers[buffType]) do
		if type(f) == "function" then f(action, buff) end
	end
end


--[[
-- Creates buffs frame
 ]]
function TwinElem:loadBuffsManager()

	BuffManager.followers = {}
	BuffManager.followers.player = {}
	BuffManager.followers.group = {}
	BuffManager.followers.debuff = {}

	--- Attaching Event handlers ---
	Command.Event.Attach(Event.Buff.Add, BuffAddHandler, "buff add")
	Command.Event.Attach(Event.Buff.Remove, BuffRemoveHandler, "buff remove")
	Command.Event.Attach(Event.Buff.Change, BuffChangeHandler, "buff change")
	--------------------------------
	
	--- Public functions ---
	BuffManager.FollowPlayer = FollowPlayer
	BuffManager.FollowGroup = FollowGroup
	BuffManager.FollowDebuff = FollowDebuff
	BuffManager.Notify = Notify
	------------------------
	
	return BuffManager
end