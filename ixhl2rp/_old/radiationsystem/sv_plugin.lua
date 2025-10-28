do
	local PLAYER = FindMetaTable("Player")

	-- to do: fix ugly chat send
	function PLAYER:RadNotify(stage)
		if stage > (self.lastRadNotify or 0) and (self.lastRadNotify or 0) != stage then
			if stage == 5 then
				ix.chat.Send(self, "it", L("radStage5", self), false, {self})
			elseif stage == 4 then
				ix.chat.Send(self, "it", L("radStage4", self), false, {self})
			elseif stage == 3 then
				ix.chat.Send(self, "it", L("radStage3", self), false, {self})
			elseif stage == 2 then
				ix.chat.Send(self, "it", L("radStage2", self), false, {self})
			elseif stage == 1 then
				ix.chat.Send(self, "it", L("radStage1", self), false, {self})
			end

			self.lastRadNotify = stage
		end
	end
end