if !ix.meta.ItemReagentContainer then
	ix.util.Include("reagent_container.lua", "shared")
end

local ItemGlass = class("ItemGlassContainer")
implements("ItemReagentContainer", "ItemGlassContainer")

ItemGlass = ix.meta.ItemGlassContainer
ItemGlass.reusable = true
ItemGlass.reagent_flags = ix.Reagents.holder.open
ItemGlass.useSound = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav"}

function ItemGlass:Init()
	ix.meta.ItemReagentContainer.Init(self)

	self.functions.use = {
		name = "loot.useSip",
		OnRun = function(item)
			local client = item.player
			local character = client:GetCharacter()
			local sipAmount = item.sip_amount or (item:GetMaxVolume() * 0.2)
			sipAmount = math.min(sipAmount, item.reagents and item.reagents.volume or 0)

			if sipAmount <= 0 then return end

			local thirst, hunger = ix.Reagents:Consume(item.reagents, sipAmount, client)
			character:UpdateNeeds(thirst, hunger)

			if istable(item.useSound) then
				client:EmitSound(item.useSound[math.random(1, #item.useSound)])
			else
				client:EmitSound(item.useSound)
			end
		end,
		OnCanRun = function(item)
			if SERVER and item.reagents then return item.reagents.volume > 0.1 end
			if CLIENT then return (item:GetData("value") or 0) > 0.1 end
			return true
		end
	}

	self.functions.useall = {
		name = "loot.useSipAll",
		OnRun = function(item)
			local client = item.player
			local character = client:GetCharacter()
			local remaining = item.reagents and item.reagents.volume or 0

			if remaining <= 0.1 then return end

			local thirst, hunger = ix.Reagents:Consume(item.reagents, remaining, client)
			character:UpdateNeeds(thirst, hunger)

			if istable(item.useSound) then
				client:EmitSound(item.useSound[math.random(1, #item.useSound)])
			else
				client:EmitSound(item.useSound)
			end
		end,
		OnCanRun = function(item)
			if SERVER and item.reagents then return item.reagents.volume > 0.1 end
			if CLIENT then return (item:GetData("value") or 0) > 0.1 end
			return true
		end
	}

	self.functions.pour = {
		name = "loot.pourContents",
		OnRun = function(item)
			if item.reagents then
				item.reagents:Clear()
			end
		end,
		OnCanRun = function(item)
			if SERVER and item.reagents then return item.reagents.volume > 0.1 end
			if CLIENT then return (item:GetData("value") or 0) > 0.1 end
			return true
		end
	}

	if SERVER then
		self:AddDataCallback("value", function(item, value)
			local entity = item:GetEntity()

			item.cachedFluidColor = nil

			if IsValid(entity) then
				local updateColor = item:GetReagentsColor()

				entity:SetNetVar("liquidColor", updateColor)
			end
		end)
	else
		self:AddDataCallback("value", function(item, value)
			local entity = item:GetEntity()

			if IsValid(entity) then
				entity.targetLiquidFrac = value / self:GetMaxVolume()
			else
				item.cachedFluidColor = nil
				item.updateFluidVisual = true
			end
		end)
	end
end

function ItemGlass:GetReagentsColor()
	if !self.cachedFluidColor then
		local reagents = self:GetData("reagents_data")

		self.cachedFluidColor = ix.Reagents:GetMixedColor(reagents)
	end

	return self.cachedFluidColor
end

function ItemGlass:OnEntityCreated(entity)
	timer.Simple(0, function()
		local updateColor = self:GetReagentsColor()

		entity:SetNetVar("liquidColor", updateColor)
	end)
end

if CLIENT then
	local function RemapMulti(value, dataTbl)
		if (value <= dataTbl[1][1]) then
			return dataTbl[1][2]
		elseif (value >= dataTbl[#dataTbl][1]) then
			return dataTbl[#dataTbl][2]
		else
			for k, v in ipairs(dataTbl) do
				if (value >= v[1] and value < dataTbl[k + 1][1]) then
					return math.Remap(value, v[1], dataTbl[k + 1][1], v[2], dataTbl[k + 1][2])
				end
			end
		end
	end

	local function SetLiquidLevel(entity, level, info)
		info = info or entity:GetItem()

		entity.liquid_offset = entity.liquid_offset or {}
		entity.liquid_scale = entity.liquid_scale or {}

		for k, v in ipairs(info.Liquid_PhysData) do
			if !v.noHeightZ then
				local vec_offset = entity.liquid_offset[k] or Vector(0, 0, 0)
				local frac = v.heightZ * (1 - level)

				if info.Liquid_InvertHeightZ then
					vec_offset.y = frac
					vec_offset.z = 0
				else
					vec_offset.y = 0
					vec_offset.z = frac
				end

				entity:ManipulateBonePosition(v.boneID, vec_offset)

				entity.liquid_offset[k] = vec_offset
			end
			
			if v.scaleXY then
				local vec_scale = entity.liquid_scale[k] or Vector(0, 0, 0)
				local f = 1 + RemapMulti(level, v.scaleXY)
				local c = v.scaleZ and (1 + RemapMulti(level, v.scaleZ)) or 1

				vec_scale.x = f
				vec_scale.y = info.Liquid_ScaleXZY and c or f
				vec_scale.z = info.Liquid_ScaleXZY and f or c

				entity:ManipulateBoneScale(v.boneID, vec_scale)

				entity.liquid_scale[k] = vec_scale
			end
		end
	end

	local function EntityThink(entity)
		if entity.liquidFrac != entity.targetLiquidFrac then
			entity.liquidFrac = Lerp(10 * FrameTime(), entity.liquidFrac, entity.targetLiquidFrac or entity.liquidFrac)

			SetLiquidLevel(entity, entity.liquidFrac, entity.liquidInfo)
		end
	end

	function ItemGlass:DrawEntity(entity, info)
		if !entity.liquidReady then
			entity.liquidReady = true

			entity.liquidFrac = (self:GetData("value") or 0) / self:GetMaxVolume()
			entity.targetLiquidFrac = entity.liquidFrac

			if info then
				entity.liquidInfo = info
			else
				entity.Think = EntityThink
			end

			SetLiquidLevel(entity, entity.liquidFrac, info)

			self.updateFluidVisual = true
		end
	end

	function ItemGlass:LayoutIcon(panel, entity)
		self:DrawEntity(entity, self)

		if self.updateFluidVisual then
			local updateColor = self:GetReagentsColor()

			entity.liquid_color = updateColor
			entity.targetLiquidFrac = (self:GetData("value") or 0) / self:GetMaxVolume()

			self.updateFluidVisual = false
		end

		EntityThink(entity)
	end

	function ItemGlass:PopulateTooltip(tooltip)
		if !self:GetEntity() then
			local currentVolume = math.Round(self:GetVolume())
			local maxVolume = self:GetMaxVolume()

			local vol = tooltip:AddRowAfter("name")
			vol:SetBackgroundColor(derma.GetColor("Success", tooltip))
			vol:SetText(L("volumeDesc", currentVolume, maxVolume))
		end
	end
end

return ItemGlass