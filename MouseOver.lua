Mouseover = {}

local MouseOverAddMenu = CreateFrame("Frame", "MouseOverAddMenu", MouseOverMainFrame, "ScrollableFrame")
MouseOverAddMenu:Hide()
MouseOverMainFrame.scrollable:ClearAllPoints()
MouseOverMainFrame.scrollable:SetPoint("TOP", MouseOverMainFrame.buttonAdd, "BOTTOM", 10, -10)
MouseOverMainFrame.scrollable:SetHeight(MouseOverMainFrame:GetHeight() - 70)
MouseOverMainFrame.scrollable.slider:SetHeight(MouseOverMainFrame.scrollable:GetHeight())

	
function GetMySpellInfo(spellID)
	local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellID)
	return {name = name, icon = icon, spellID = spellID}
end

Mouseover.SpellMOCount = 1
Mouseover.SpellMO = {}
Mouseover.SpellMO["Esprit ancestral"]= GetMySpellInfo(2008)

function MouseOverMainFrame:LoadSpellMO()
	print("ici")
	for name,spell in pairs(Mouseover.SpellMO) do
		print(name)
		print(spell)
		Mouseover:AddSpellToMO(Mouseover:CreateSpellFrame(spell, MouseOverMainFrame.scrollable.content))
	end
end

function Mouseover:AddSpellToMO(frame)
	Mouseover.SpellMOCount = Mouseover.SpellMOCount + 1
	Mouseover.SpellMO[frame.spell.name] = frame.spell
	frame:SetParent(MouseOverMainFrame.scrollable.content)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", 20, -70 * (Mouseover.SpellMOCount - 2))
	frame:SetScript("OnMouseDown", function(self, buton, down)
	end)
	if (Mouseover.SpellMOCount * 70 + 10 > MouseOverMainFrame.scrollable:GetHeight()) then
		MouseOverMainFrame.scrollable.slider:SetMinMaxValues(0, Mouseover.SpellMOCount * 70 - MouseOverMainFrame.scrollable:GetHeight() + 10)
	else
		MouseOverMainFrame.scrollable.slider:SetMinMaxValues(0, 1)
	end
end

function Mouseover:CreateSpellFrame(Spell, parent)
	local frame = CreateFrame("Frame", "frameAdd" .. Spell.name, parent)
	local texture = frame:CreateTexture("textureAdd" .. Spell.name)
	local text = frame:CreateFontString("textAdd" .. Spell.name, "OVERLAY") 
	frame:SetSize(parent:GetWidth() - 60, 60)
	frame.spell = Spell
	texture:SetWidth(60)
	texture:SetHeight(60)
	texture:SetPoint("TOPLEFT")
	texture:SetTexture(GetSpellTexture(Spell.name))
	text:SetFont("Fonts\\ARIALN.TTF", 20)
	text:SetTextColor(0.6,0.6,0.6,1)
	text:SetPoint("LEFT", texture, "RIGHT", 10, 0)
	text:SetText(Spell.name)
	frame:SetScript("OnEnter", function(self, motion)
		local backdrop = {bgFile = nil, edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", tile = true, tileSize = 32, edgeSize = 16, insets = {left = 0, right = 40, top = 0, bottom = 0}}
		self:SetBackdrop(backdrop)
	end)
	frame:SetScript("OnLeave", function(self, motion)
		local backdrop = {bgFile = nil, edgeFile = nil, tile = true, tileSize = 32, edgeSize = 16, insets = {left = 11, right = 12, top = 12, bottom = 11}}
		self:SetBackdrop(backdrop)
	end)
	return frame
end
function MouseOverAddMenu:AddSpellToContent(Spell, range)
	print("add")
	print(Spell.name)
	local frame = Mouseover:CreateSpellFrame(Spell, MouseOverAddMenu.scrollable.content)
	frame:SetPoint("TOPLEFT", 30, -(range * 70) -10)
	
	frame:SetScript("OnMouseDown", function(self, buton, down)
		Mouseover:AddSpellToMO(frame)
		MouseOverMainFrame:OpenAddMenu()
	end)
end


MouseOverMainFrame["OpenAddMenu"] = function () 
	MouseOverAddMenu:SetPoint("RIGHT", MouseOverMainFrame, "LEFT", -10, 0)
	local childs = {MouseOverAddMenu.scrollable.content:GetChildren()};
	for _, child in ipairs(childs) do
		child:Hide()
	end
	local count = 0
	id, specName, description, icon, background, role, primaryStat = GetSpecializationInfo(GetSpecialization(), false, false, nil, nil)
	print(name)
	for i = 2, GetNumSpellTabs() do
		local tabName,tabTexture, tabOffset, tabNumSpells = GetSpellTabInfo(i);
		if (tabName == specName) then
			for j = 1, tabNumSpells do
				local skillType, spellId = GetSpellBookItemInfo(tabOffset + j, "bookType")
				local spell = GetMySpellInfo(spellId)
				print(spell.name)
				if (IsPlayerSpell(spell.spellID) and not Mouseover.SpellMO[spell.name]) then
					MouseOverAddMenu:AddSpellToContent(spell, count)
					count = count + 1
				end
			end
		end
	end
	if (count * 70 + 10 > MouseOverAddMenu.scrollable:GetHeight()) then
		MouseOverAddMenu.scrollable.slider:SetMinMaxValues(0, count * 70 - MouseOverAddMenu.scrollable:GetHeight() + 10)
	else
		MouseOverAddMenu.scrollable.slider:SetMinMaxValues(0, 1)
	end
	MouseOverAddMenu:Show()
end

function MouseOverMainFrame:ApplyMouseOver()
	for spellName,spell in pairs(Mouseover.SpellMO) do
--		spell = Mouseover.SpellMO["Esprit ancestral"]
		local macroName = spell.name .. "_MouseOver__"
		
		if (GetMacroIndexByName(macroName) == 0) then
			local macroID = CreateMacro(macroName, spell.icon, "", 1, 1)
			EditMacro(macroID, macroName, spell.icon, "/say hi")
		end
		for i=1, 8 do
			atype, id, subType, spellID = GetActionInfo(i)
			if (atype == "spell" and subType == "spell") then
				print(id)
				local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(id)
				print(name)
				if (id == spell.spellID) then
					print("slot " .. i)
					PickupMacro(macroName)
					PlaceAction(i)
					ClearCursor()
				end
			end
		end


	end
	print("aply")
end

MouseOverMainFrame:LoadSpellMO()

