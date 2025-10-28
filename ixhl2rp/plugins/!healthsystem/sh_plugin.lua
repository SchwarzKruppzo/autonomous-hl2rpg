local PLUGIN = PLUGIN

PLUGIN.name = "Health System 2"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

ix.Net:AddPlayerVar("doll", false, nil, ix.Net.Type.EntityIndex)
ix.Net:AddPlayerVar("isBleeding", false, nil, ix.Net.Type.Bool)
ix.Net:AddPlayerVar("knocked", true, nil, ix.Net.Type.Bool)
ix.Net:AddPlayerVar("crit", false, nil, ix.Net.Type.Bool)
ix.Net:AddPlayerVar("drunk", true, nil, ix.Net.Type.Float)

ix.util.Include("cl_fx.lua")
ix.util.Include("sh_hediff.class.lua")
ix.util.Include("sh_health.class.lua")
ix.util.Include("sh_effects.define.lua")
ix.util.Include("sh_movement.lua")
ix.util.Include("sh_combat.lua")
ix.util.Include("sv_combat.lua")
ix.util.Include("cl_criticalstate.lua")
ix.util.Include("sv_criticalstate.lua")

ix.char.RegisterVar("health", {
	field = "health",
	fieldType = ix.type.text,
	Meta = ix.meta.HealthStat,
})

do
	local clrRed = Color(255, 100, 100, 255)

	ix.chat.Register("dmgMsg", {
		OnCanHear = function(self, speaker, listener)
			return true
		end,
		CanSay = function(self, speaker)
			return !IsValid(speaker)
		end,
		OnChatAdd = function(self, speaker, text, bAnonymous, data)
			local isSlay = data.b

			if data.t == 1 then
				chat.AddText(clrRed, string.format(isSlay and "Вас грабит игрок %s (%s)!" or "Вас добивает игрок %s (%s)!", data.attacker:Name(), data.attacker:GetAnonID()))
			elseif data.t == 2 then
				chat.AddText(color_white, "После игровой смерти, Вы потеряли все свои вещи и жетоны.")
			elseif data.t == 3 then
				chat.AddText(color_white, isSlay and "Вас прекратили грабить!" or "Вас прекратили добивать!")
			end
		end
	})

	ix.chat.Register("dmgAdminMsg", {
		OnCanHear = function(self, speaker, listener)
			if CAMI.PlayerHasAccess(listener, "Helix - Admin Chat", nil) then
				return true
			end

			return false
		end,
		CanSay = function(self, speaker)
			return !IsValid(speaker)
		end,
		OnChatAdd = function(self, speaker, text, bAnonymous, data)
			if !CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Admin Chat", nil) then
				return
			end

			local isSlay = data.b

			if data.t == 1 then
				chat.AddText(clrRed, string.format(isSlay and "Игрок %s (%s) пытается ограбить игрока %s (%s)!" or "Игрок %s (%s) пытается добить игрока %s (%s)!", data.attacker:Name(), data.attacker:GetAnonID(), data.crit:Name(), data.crit:GetAnonID()))
			elseif data.t == 2 then
				chat.AddText(clrRed, string.format(isSlay and "%s (%s) был ограблен игроком %s (%s)!" or "%s (%s) был добит игроком %s (%s)!", data.crit:Name(), data.crit:GetAnonID(), data.attacker:Name(), data.attacker:GetAnonID()))
			end
		end
	})
end