local toc, data = ...
local AddonId = toc.identifier

local FrameSize = 28
local DisplayWidth = 150

-- Public functions to update frame's appearance

local function ScaleDisplay(e, scale)
	e.Display:SetWidth(DisplayWidth * scale)
	e.Display:SetHeight(FrameSize * scale)
	
	-- borders:
	e.Display.BorderTop:SetWidth(e.Display:GetWidth()-8)
	e.Display.BorderRight:SetHeight(e.Display:GetHeight()-8)
	e.Display.BorderBottom:SetWidth(e.Display:GetWidth()-8)
	e.Display.BorderLeft:SetHeight(e.Display:GetHeight()-8)
end

local function SetPoint(e, pointSelf, target, pointTarget, x, y)
	if e.lastpoint then
		-- clear last point
		e.Point:ClearPoint(e.lastpoint)
		e.Display:ClearPoint(e.lastpoint)
	end
	
	-- Manipulating position based on target
	if target == UIParent then
		-- screen
		e.Point:SetPoint(pointSelf, target, pointTarget, x, y)
		e.Display:SetPoint(pointSelf, target, pointTarget, x, y)
	else
		-- other frame
		e.Point:SetPoint(pointSelf, target.Point, pointTarget, x, y)
		e.Display:SetPoint(pointSelf, target.Display, pointTarget, x, y)
	end
	e.lastpoint = pointSelf
end


-- Creates and returns frame for display
local function CreateDisplay(name, parent)
	local Display = UI.CreateFrame("Frame", AddonId .. name, parent)
	local r,g,b = unpack(COLOR.black)
	Display:SetBackgroundColor(r,g,b,0.5)
	Display:SetHeight(FrameSize)
	Display:SetWidth(DisplayWidth)
	
	Display.Title = UI.CreateFrame("Text", AddonId .. name .. "Title", Display)
	Display.Title:SetPoint("CENTER", Display, "CENTER", 0, 0)
	Display.Title:SetFontColor(unpack(COLOR.white))
	Display.Title:SetText(name)
	
	--- borders
	Display.BorderTop = UI.CreateFrame("Frame", AddonId .. name .. "Border Top", Display)
	Display.BorderTop:SetPoint("CENTERTOP", Display, "CENTERTOP", 0, 4)
	Display.BorderTop:SetBackgroundColor(unpack(COLOR.color5))
	Display.BorderTop:SetWidth(Display:GetWidth()-8)
	Display.BorderTop:SetHeight(1)
	Display.BorderRight = UI.CreateFrame("Frame", AddonId .. name .. "Border Right", Display)
	Display.BorderRight:SetPoint("CENTERRIGHT", Display, "CENTERRIGHT", -4, 0)
	Display.BorderRight:SetBackgroundColor(unpack(COLOR.color5))
	Display.BorderRight:SetWidth(1)
	Display.BorderRight:SetHeight(Display:GetHeight()-8)
	Display.BorderBottom = UI.CreateFrame("Frame", AddonId .. name .. "Border Bottom", Display)
	Display.BorderBottom:SetPoint("CENTERBOTTOM", Display, "CENTERBOTTOM", 0, -4)
	Display.BorderBottom:SetBackgroundColor(unpack(COLOR.color5))
	Display.BorderBottom:SetWidth(Display:GetWidth()-8)
	Display.BorderBottom:SetHeight(1)
	Display.BorderLeft = UI.CreateFrame("Frame", AddonId .. name .. "Border Left", Display)
	Display.BorderLeft:SetPoint("CENTERLEFT", Display, "CENTERLEFT", 4, 0)
	Display.BorderLeft:SetBackgroundColor(unpack(COLOR.color5))
	Display.BorderLeft:SetWidth(1)
	Display.BorderLeft:SetHeight(Display:GetHeight()-8)
	
	return Display
end

function TwinElem:createBuffFrame(frameType, name, parent)
	local Element = {}
	
	Element.type = frameType 
	Element.frames = {} -- store invisible frames
	Element.buffFrames = {} -- store visible frames
	Element.sortedBuffs = {} -- store buffs (sorted by remaining time)
	
	-- Visual representation of Buffs frame
	Element.Display = CreateDisplay(name, parent)
	
	
	-- Starting point
	Element.Point = UI.CreateFrame("Frame", name, parent)
	Element.Point:SetHeight(FrameSize)
	Element.Point:SetWidth(FrameSize)
	--[[
	-- fake buff
	local fake = UI.CreateFrame("Frame", "Buff Frame Fake", Element.Point)
	fake:SetPoint("CENTERRIGHT", Element.Point, "CENTERRIGHT", 0, 0)
	fake:SetWidth(0)
	fake:SetHeight(0)
	
	Element.buffFrames[0] = fake
	]]
	--- Public functions ---
	Element.SetPoint = SetPoint
	Element.ScaleDisplay = ScaleDisplay
	------------------------
	
	return Element
end