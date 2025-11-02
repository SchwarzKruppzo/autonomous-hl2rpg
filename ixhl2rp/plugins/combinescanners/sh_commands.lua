do
	local COMMAND = {}
	COMMAND.description = "Stops controlling a Combine Scanner."
	
	function COMMAND:OnRun(client, arguments)
		if client:IsPilotScanner() then
			local scanner = client:GetPilotingScanner()
			
			scanner:Eject()
		end
	end

	ix.command.Add("ScannerEject", COMMAND)
end