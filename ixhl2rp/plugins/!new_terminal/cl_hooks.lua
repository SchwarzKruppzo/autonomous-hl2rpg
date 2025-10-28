local PLUGIN = PLUGIN or {}

netstream.Hook("civil.terminal.open", function(name, cid, house, job, money, socialCredits, civilStatus, data)
	local info = {}
	
	info.name = name
	info.cid = cid
	info.house = house
	info.job = job
	info.money = tonumber(money)
	info.points = tonumber(socialCredits)
	info.loyalty = tonumber(civilStatus)
	info.data = data

	ix.Datafile:Setup(info)

	local terminal = ix.gui.civilTerminal

	if IsValid(terminal) then
		terminal:SwitchPage("Logged")

		surface.PlaySound("combine_tech/civic_station/station_menu_appear.mp3")
	end
end)
