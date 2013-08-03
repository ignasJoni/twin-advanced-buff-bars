local FrameSize = 28

local time_sort = function (a, b)
	if not a.duration then return true end -- no duration
	if not b.duration then return false end -- no duration
	
	local t = Inspect.Time.Frame()
	return (a.duration-(t-a.begin)) > (b.duration-(t-b.begin))
end 

local function CreateBuffFrame(parent)
	local Frame = UI.CreateFrame("Frame", "Buff Frame", parent)
	Frame:SetWidth(FrameSize)
	Frame:SetHeight(FrameSize)
	Frame:SetBackgroundColor(unpack(COLOR.color1))
	Frame:SetVisible(false)
	
	-- Icon
	Frame.Icon = UI.CreateFrame("Texture", "Buff Icon", Frame)
	Frame.Icon:SetPoint("CENTER", Frame, "CENTER", 0, 0)
	Frame.Icon:SetWidth(FrameSize-4)
	Frame.Icon:SetHeight(FrameSize-4)
	
	-- Time
	Frame.Time = UI.CreateFrame("Text", "Buff Time", Frame)
	Frame.Time:SetPoint("CENTERBOTTOM", Frame.Icon, "CENTERBOTTOM", 0, 2)
	Frame.Time:SetLayer(1)
	Frame.Time:SetFontColor(unpack(COLOR.white))
	Frame.Time:SetEffectGlow{colorA=1, blurX=4, blurY=4, strength=3}
	
	function Frame:SetIcon(icon)
		self.Icon:SetTexture("Rift", icon)
	end
	
	function Frame:SetTime(t)
		if t and t >= 0 then
			local fTime = format_time(t)
			self.Time:SetText(fTime)
		else
			self.Time:SetText("")
		end
	end
	
	function Frame:Reset()
		self.buff = nil
		self:ClearPoint("CENTERRIGHT")
		self:SetTime()
		self:SetVisible(false)
	end
	
	Frame.buff = nil -- assigned buff
	return Frame
end

local function AddBuff(e, buff)	
	-- Getting buff frame for buff
	local Frame = #e.frames > 0 and table.remove(e.frames) or CreateBuffFrame(e.Point)
	-- Updating Frame
	Frame.buff = buff
	Frame:SetIcon(buff.icon)
	Frame:SetTime(buff.remaining)
	Frame:SetVisible(true)
	
	-- Deciding position for buff
	local pos = table.bininsert(e.sortedBuffs, buff, time_sort)
	
	-- Setting position
	Frame:SetPoint("CENTERRIGHT", e.buffFrames[pos-1], "CENTERLEFT", -1, 0)
	
	-- Repositioning next frame
	if e.buffFrames[pos] then
		e.buffFrames[pos]:ClearPoint("CENTERRIGHT")
		e.buffFrames[pos]:SetPoint("CENTERRIGHT", Frame, "CENTERLEFT", -1, 0)
	end
	
	table.insert(e.buffFrames, pos, Frame)
end

local function RemoveBuff(e, id)
	local pos;
	-- Retrieving buff frame
	for i,buff in ipairs(e.sortedBuffs) do
		if buff.id == id then
			table.remove(e.sortedBuffs, i)
			frame = table.remove(e.buffFrames, i)
			frame:Reset()
			pos = i
			break
		end
	end
	
	-- Repositioning next frame
	if e.buffFrames[pos] then
		e.buffFrames[pos]:ClearPoint("CENTERRIGHT")
		e.buffFrames[pos]:SetPoint("CENTERRIGHT", e.buffFrames[pos-1], "CENTERLEFT", -1, 0)
	end
end

local function UpdateTime(e)
	local t = Inspect.Time.Frame()
	
	for _,frame in ipairs(e.buffFrames) do
		local buff = frame.buff
		if buff.duration then
			frame:SetTime(buff.duration-(t-buff.begin))
		end
	end
end

local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	e.Point:SetPoint(pointSelf, target, pointTarget, x, y)
end

function TwinElem:createBuffFrame(frameType, name, parent)
	local Element = {}
	Element.type = frameType
	Element.frames = {}
	Element.buffFrames = {}
	Element.sortedBuffs = {}
	
	-- Starting point
	Element.Point = UI.CreateFrame("Frame", name, parent)
	Element.Point:SetHeight(FrameSize)
	Element.Point:SetWidth(FrameSize)
	
	-- fake buff
	local fake = UI.CreateFrame("Frame", "Buff Frame Fake", Element.Point)
	fake:SetPoint("CENTERRIGHT", Element.Point, "CENTERRIGHT", 0, 0)
	fake:SetWidth(0)
	fake:SetHeight(0)
	
	Element.buffFrames[0] = fake
	
	--- Public functions ---
	Element.AddBuff = AddBuff
	Element.RemoveBuff = RemoveBuff
	Element.UpdateTime = UpdateTime
	Element.SetPoint = SetPoint
	------------------------
	
	return Element
end