local frameConstructors = {
	Button = Library.TwinElements.Button,
	Window = Library.TwinElements.Window,
	TabbedPanel = Library.TwinElements.TabbedPanel,
	Section = Library.TwinElements.Section,
	Subsection = Library.TwinElements.Subsection,
	Input = Library.TwinElements.Input,
	CheckboxGroup = Library.TwinElements.CheckboxGroup,
	CheckboxAnchors = Library.TwinElements.CheckboxAnchors,
	List = Library.TwinElements.List,
}

UI.TwinElem = function(frameType, name, parent)
	assert(type(frameType) == "string", "param 1 must be a string!")
	assert(type(name) == "string", "param 2 must be a string!")
	assert(type(parent) == "table", "param 3 must be a valid frame parent!")

	local constructor = frameConstructors[frameType]
	if constructor then
	return constructor(name, parent)
	end
end
