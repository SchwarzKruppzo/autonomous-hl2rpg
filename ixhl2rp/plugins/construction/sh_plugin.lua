local PLUGIN = PLUGIN

PLUGIN.name = "Crafting Items"
PLUGIN.author = "Krieg & Schwarz Kruppzo"
PLUGIN.description = "Construction for entity, props, NPC."

if SERVER then
	PLUGIN.SaveConstructions = PLUGIN.SaveConstructions or {}

	function PLUGIN:AddConstructionToSave(entity)
		if !IsValid(entity) then
			return
		end
		
		if entity.constructionSaved then
			return
		end
		
		entity.constructionSaved = true

		self.SaveConstructions[#self.SaveConstructions + 1] = entity
	end

	function PLUGIN:SaveData()
		local data = {}

		for _, v in ipairs(self.SaveConstructions or {}) do
			if !IsValid(v) then continue end
			
			data[#data + 1] = {
				v:GetClass(),
				v:GetPos(),
				v:GetAngles()
			}
		end

		self:SetData(data)
	end

	function PLUGIN:LoadData()
		local data = self:GetData()

		if data then
			for _, v in ipairs(data) do
				local class = v[1]
				local entity = ents.Create(class)

				if IsValid(entity) then
					entity:SetPos(v[2])
					entity:SetAngles(v[3])
					entity:Spawn()
					
					if class != "combine_mine" and (not entity:IsNPC()) then
						local phys = entity:GetPhysicsObject()

						if IsValid(phys) then
							phys:EnableMotion(false)
						end
					else
						entity:SetKeyValue("spawnflags", 8192)
					end

					self:AddConstructionToSave(entity)
				end
			end
		end
	end

	local toSave = {
		["npc_turret_floor"] = true,
		["combine_mine"] = true
	}
	function PLUGIN:OnEntityCreated(ent)
		local class = ent:GetClass()

		if toSave[class] then
			self:AddConstructionToSave(ent)
		end
	end
end