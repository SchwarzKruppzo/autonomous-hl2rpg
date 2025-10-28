local PANEL = {}
PANEL.colorBG = Color(255, 255, 255, 150)

function PANEL:Init()
	if IsValid(ix.gui.limbstatus) then
		ix.gui.limbstatus:Remove()
	end
	
	ix.gui.limbstatus = self

	self:SetSize(120, 240)

	self:BuildData()
end

local tex_body = Material("clockwork/limbs/body.png")
function PANEL:BuildData()
	local character = LocalPlayer():GetCharacter()
	local limbs = character:Limbs()

	if !limbs then
		return
	end

	self.character = character
	self.texBG = tex_body
	self.tex = {}

	local health = self.character:Health()

	for k, limb in ipairs(health.body.parts or {}) do
		if limb.hidden then continue end

		self.tex[#self.tex + 1] = {limb.name, limb.texture, limb.id, limb.health}
	end

	self:SetHelixTooltip(function(tooltip)
		local title = tooltip:AddRow("name")
		title:SetImportant()
		title:SetText(L"limbStatus")
		title:SizeToContents()
		title:SetMaxWidth(math.max(title:GetMaxWidth(), ScrW() * 0.5))

		if self.character then
			local text = ""
			local health = self.character:Health()
			for k, limb in ipairs(health.body.parts or {}) do
				if limb.hidden then continue end

				text = text .. string.format("%s — %s/%s HP", limb.name, health:GetPartHealth(limb.id), limb.health) .. ((k != #limbs) and "\n" or "")
			end
				  
			local description = tooltip:AddRow("description")
			description:SetText(text)
			description:SizeToContents()
		end
	end)
end

function PANEL:Paint(w, h)
	if self.character then
		surface.SetDrawColor(self.colorBG)
		surface.SetMaterial(self.texBG)
		surface.DrawTexturedRect(0, 0, w, h)

		local health = self.character:Health()
		for k, v in ipairs(self.tex) do
			local limbColor = ix.limb:GetColor(health:GetPartHealth(v[3]), v[4])

			surface.SetDrawColor(limbColor.r, limbColor.g, limbColor.b, 150)
			surface.SetMaterial(v[2])
			surface.DrawTexturedRect(0, 0, w, h)
		end
	end
end

vgui.Register("ixLimbStatus", PANEL, "EditablePanel")
