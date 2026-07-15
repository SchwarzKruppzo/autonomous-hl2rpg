ITEM.name = "Многофункциональный инструмент"
ITEM.model = "models/alyx_emptool_prop.mdl"
ITEM.description = "Что может быть лучше, чем взлом систем Альянса, используя инструменты этого же Альянса? В руке у вас один из таких портативных инструментов."
ITEM.category = "Инструменты"
ITEM.rarity = 3
ITEM.width = 1
ITEM.height = 2
ITEM.iconCam = {
	pos = Vector(7.9705405235291, 1.3049583435059, 131.99598693848),
	ang = Angle(86.487617492676, 186.46231079102, 0),
	fov = 1.7994338862117,
}
ITEM.contraband = true

ITEM.functions.editCombineLock = {
	name = "Редактировать Combine Lock",
	OnClick = function(item)
		local lookedUpEntity = item.player:GetEyeTraceNoCursor().Entity
		local access = lookedUpEntity:GetAccess()
		Derma_StringRequest("Выставление доступа", Format("Текущий доступ замка \"%s\"", access), access, function(newAccess)
			netstream.Start("ixOmniEditCombineLock", lookedUpEntity, newAccess)
		end)

		return false
	end,
	OnCanRun = function(item)
		local client = item.player
		local lookedUpEntity = client:GetEyeTraceNoCursor().Entity

		return lookedUpEntity:GetClass() == "ix_combinelock" && client:HasIDAccess(lookedUpEntity:GetAccess())
	end
}

ITEM.functions.connectToScanner = {
	name = "Подключиться",
	OnRun = function(item)
		local lookedUpEntity = item.player:GetEyeTraceNoCursor().Entity
		
		ix.plugin.list["combinescanners"]:ConnectScannerToPlayer(item.player, lookedUpEntity)
	end,
	OnCanRun = function(item)
		local client = item.player
		local lookedUpEntity = client:GetEyeTraceNoCursor().Entity

		if (lookedUpEntity:GetClass() == "ix_scanner") then
			local isCombineScanner = lookedUpEntity:GetIsCombine()
			local isCombinePlayer = client:IsCombine()

			return ((isCombineScanner && isCombinePlayer) || (!isCombineScanner && !isCombinePlayer)) && ix.plugin.list["combinescanners"]:CanEnterToScanner(client, lookedUpEntity)
		end

		return false
	end
}

ITEM.combine = {
	dropBioLock = {
		name = "Сбросить биологическую защиту",
		icon = "icon16/disconnect.png",
		OnRun = function(item, targetItem, items, data)
			local client = item.player

			if (!targetItem:GetData("locked")) then
				return client:Notify("Вооружение не имеет действующей биологической защиты!")
			end

			targetItem:SetData("locked", nil)

			if (!client:IsCombine()) then
				local char = client:GetCharacter()

				if (math.random(100) + char:GetSpecial("lk") - 1 < 95) then
					item:Remove()

					local pos = client:GetPos() + Vector(0, 0, 30)
					local effect = EffectData()
						effect:SetStart(pos)
						effect:SetOrigin(pos)
						effect:SetMagnitude(0)
						effect:SetScale(0.5)
						effect:SetColor(25)
						effect:SetEntity(client)
					util.Effect("Explosion", effect, true, true)
					util.BlastDamage(client, client, pos, 280, 20)
					-- local damageInfo = DamageInfo()
					-- 	damageInfo:SetDamage(20)
					-- 	damageInfo:SetAttacker(client)
					-- 	damageInfo:SetInflictor(client)
					-- 	damageInfo:SetDamageType(DMG_BLAST)
					-- util.BlastDamageInfo(damageInfo, pos, 300)
				end
			end

			client:Notify("Биологическая защита сброшена. Она будет вновь задейстована на первого, кто активирует вооружение.")
		end,
		OnCanRun = function(item, targetItem, items, data)
			return !!targetItem.hasLock
		end
	}
}