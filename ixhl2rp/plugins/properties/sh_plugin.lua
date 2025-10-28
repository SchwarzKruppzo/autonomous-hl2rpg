local PLUGIN = PLUGIN

PLUGIN.name = "Business Property"
PLUGIN.description = ""
PLUGIN.author = "Schwarz Kruppzo"

function PLUGIN:SetupAreaProperties()
	ix.area.AddType("property")
end

ix.util.Include("sv_hooks.lua")

ix.lang.AddTable("russian", {
	poiNotFound = "Вы не находитесь в предприятии!",
	poiStarted = "Вы начали смену на предприятии!",
	poiClosed = "Вы завершили смену на предприятии! Всего посетителей за день: %i",
	cmdPoiStart = "Позволяет начать смену на предприятии, в котором вы находитесь. Каждый уникальный посетитель принесет 10 жетоны в кассу после окончания смены.",
	cmdPoiEnd = "Позволяет завершить смену на предприятии, в котором вы находитесь.",
	cmdPoiCash = "Забрать вырученные за активность предприятия жетоны. Необходимо находиться рядом с кассой.",
	poiAlready = "Сначала необходимо завершить смену!",
	poiNoAccess = "У вас нет доступа к кассе!",
	poiNoAccess2 = "Необходимо стоять возле кассы!",
})

ix.command.Add("OpenBusiness", {
	description = "@cmdPoiStart",
	OnRun = function(self, client)
		local register

		for k, v in ipairs(ents.FindByClass("ix_property_cash")) do
			if client:GetPos():Distance(v:GetPos()) > 192 then
				continue
			end
			
			register = v
			break
		end

		if IsValid(register) then
			local propertyID = register.propertyID
			local poi = ix.poi[propertyID]

			if poi then
				if !client:HasIDAccess(register.access) then
					return
				end

				if !IsValid(poi.active) then
					local cid = client:GetIDCard()

					poi.log = poi.log or {
						opened = 0,
						time = 0,
						visitors = 0,
						owner = "N/A"
					}

					poi.log.time = poi.log.time + (CurTime() - (poi.time or CurTime()))
					poi.log.opened = poi.log.opened + 1
					poi.log.owner = cid:GetData("name") or "N/A"

					client.activePoi = propertyID
					poi.active = client
					poi.time = CurTime()
					
					return "@poiStarted"
				else
					return (poi.active:GetName().." уже находится на смене этого предприятия.")
				end
			end
		else
			return "@poiNoAccess2"
		end

		return "@poiNotFound"
	end
})

local formatx = "Property ID: %s; кассир: %s; посетителей: %s (прибыль: %s, в кассе: %s); открытий: %s; общее время: %s сек."
ix.command.Add("BusinessInfo", {
	description = "",
	OnRun = function(self, client)
		for k, v in pairs(ix.poi) do
			if v.log then
				client:ChatNotify(string.format(formatx,
					k,
					v.log.owner,
					v.log.visitors,
					v.log.visitors * 5,
					v.cash,
					v.log.opened,
					math.Round(v.time)
				))
			end
		end
	end
})

ix.command.Add("CloseBusiness", {
	description = "@cmdPoiEnd",
	OnRun = function(self, client)
		if client.activePoi then
			local poi = ix.poi[client.activePoi]

			if poi and poi.active == client then
				client.activePoi = nil
				poi.active = false

				client:NotifyLocalized("poiClosed", table.Count(poi.visitors or {}))
				return
			end
		end

		return "@poiNotFound"
	end
})

ix.command.Add("GetCash", {
	description = "@cmdPoiCash",
	OnRun = function(self, client)
		local register

		for k, v in ipairs(ents.FindByClass("ix_property_cash")) do
			if client:GetPos():Distance(v:GetPos()) > 192 then
				continue
			end
			
			register = v
			break
		end

		if IsValid(register) then
			local propertyID = register.propertyID
			local poi = ix.poi[propertyID]

			if poi and !poi.active then
				if !client:HasIDAccess(register.access) then
					return "@poiNoAccess"
				end

				local amount = poi.cash or 0

				if amount > 0 then
					client:GetCharacter():GiveMoney(amount)

					client:NotifyLocalized("moneyTaken", ix.currency.Get(amount))
				end

				poi.cash = 0
				return
			else
				return "@poiAlready"
			end
		else
			return "@poiNoAccess2"
		end

		return "@poiNotFound"
	end
})

ix.command.Add("AddCashRegister", {
	description = "",
	arguments = {
		ix.type.string,
		ix.type.string,
	},
	superAdminOnly = true,
	OnRun = function(self, client, propertyID, access)
		local trace = client:GetEyeTraceNoCursor()
		local entity = ents.Create("ix_property_cash")
		entity:SetPos(trace.HitPos + Vector(0, 0, 5))
		entity:Spawn()
		entity.propertyID = propertyID
		entity.access = access

		return
	end
})
