local PLUGIN = PLUGIN

function PLUGIN:OpenTerminal(client, datafile)
	netstream.Start(client, "civil.terminal.open",
		datafile:GetName(),
		datafile:CitizenID(),
		datafile:GetHouse(),
		datafile:GetOccupation(),
		datafile:GetCredits(),
		datafile:GetSocialCredits(),
		datafile:GetCivilStatus(),
		datafile.vars.data
	)
end