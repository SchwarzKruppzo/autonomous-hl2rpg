do
	local COMMAND = {}
	COMMAND.description = "@scannerEjectDesc"
	
	function COMMAND:OnRun(client, arguments)
		if client:IsPilotScanner() then
			local scanner = client:GetPilotingScanner()
			
			scanner:Eject()
		end
	end

	ix.command.Add("ScannerEject", COMMAND)
end