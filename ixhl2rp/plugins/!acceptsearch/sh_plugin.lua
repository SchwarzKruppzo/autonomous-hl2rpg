local PLUGIN = PLUGIN

PLUGIN.name = "Accept Search"
PLUGIN.author = ""
PLUGIN.description = ""

ix.util.Include("sv_plugin.lua")

ix.lang.AddTable("russian", {
	psearchAlready = "Персонажа уже обыскивают!",
	psearchPending = "Вы запросили обыск персонажа.",
	psearchWait = "Подождите перед запросом!",
	psearchAccept = "Вы согласились на обыск.",
	psearchDecline = "Вы отказались от обыска!",
	psearchDecline2 = "Персонаж отказался от обыска!",
})


local COMMAND = {}

function COMMAND:OnRun(client, arguments)
	if client:IsRestricted() then return "@notNow" end

	local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 96
		data.filter = client
	local target = util.TraceLine(data).Entity

	if IsValid(target) and target:IsPlayer() then
		if (target:IsRestricted()) then
			Schema:SearchPlayer(client, target)
		else
			PLUGIN:SendSearchPlayerRequest(client, target)
		end
	end
end

ix.command.Add("CharSearch", COMMAND)

if CLIENT then
	local function Respond(state)
		net.Start("rp.search.request")
			net.WriteBool(state)
		net.SendToServer()
	end
	
	net.Receive("rp.search.request", function(len)
		local client = net.ReadEntity()

		Derma_Query(
    		"Персонаж "..client:GetName().." хочет обыскать Вас.",
    		"Запрос обыска",
    		"Разрешить",
    		function() Respond(true) end,
			"Отклонить",
			function() Respond(false) end
		)
	end)

	net.Receive("emote.container", function()
		local sender = net.ReadEntity()
		local itemID = net.ReadString()
		local item = ix.Item:Get(itemID)
		local target = sender:GetEyeTraceNoCursor().Entity
		local entityPlayer = target:GetNetVar("player")

		local name = hook.Run("GetCharacterName", target:IsRagdoll() and entityPlayer or target, "me")

		if name then
			ix.chat.Send(sender, "me", "забирает \""..L(item.name).."\" у "..name..".")
		else
			ix.chat.Send(sender, "me", "забирает у вас \""..L(item.name).."\".")
		end
	end)
end