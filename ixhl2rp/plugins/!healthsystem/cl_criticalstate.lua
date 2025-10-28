local PLUGIN = PLUGIN
local PLAYER = FindMetaTable("Player")

function PLAYER:InCriticalState()
	return self:GetNetVar("crit")
end

do
	local crit_material = Material("cellar/ui/crit.png")
	local size = 32
	local mid  = size / 2
	local abs = math.abs
	local use = string.upper(input.LookupBinding("+use"))

	local focus_stick = 0
	local focus_range = 25
	local focus_ent = nil
	local focused_ent = nil

	surface.CreateFont("ixCrit", {
		font = "Roboto Lt",
		size = 18,
		weight = 500,
		antialias = true,
		extended = true
	})
	surface.CreateFont("ixCritBlur", {
		font = "Roboto Lt",
		size = 18,
		weight = 500,
		blursize = 2,
		antialias = true,
		extended = true
	})

	local critCount = 0
	local critPlayers = {}

	net.Receive("crit.use", function()
		local isSlay = net.ReadBool()

		if isSlay then
			Derma_Query("Ограбив этого персонажа, Вы отправите его на точку появления в рамках правила NLR, получив инвентарь погибшего. Этот процесс займет 10 секунд. Вы точно уверены в этом?", "Ограбить персонажа", "Ограбить", function() 
				net.Start("crit.apply")
					net.WriteBool(true)
				net.SendToServer()

				end, "Отмена", function() 

				net.Start("crit.apply")
				net.SendToServer()
			end)
		else
			Derma_Query("Добивая этого персонажа, Вы безвозвратно заблокируете его, получив инвентарь погибшего. Этот процесс займет 30 секунд. Вы точно уверены в этом?", "Добить персонажа", "Добить", function() 
				net.Start("crit.apply")
					net.WriteBool(true)
				net.SendToServer()

				end, "Отмена", function() 

				net.Start("crit.apply")
				net.SendToServer()
			end)
		end
	end)

	timer.Create("ixCritUpdate", 1, 0, function()
		for _, client in ipairs(player.GetAll()) do
			critPlayers[client] = client:GetNetVar("crit", nil)
		end

		critCount = table.Count(critPlayers)
	end)

	local function IsOffScreen(scrpos)
		return not scrpos.visible or scrpos.x < 0 or scrpos.y < 0 or scrpos.x > ScrW() or scrpos.y > ScrH()
	end

	local function UseCriticalButton()
		local menu = ix.SimpleMenu()

		menu:AddOption("ОГРАБИТЬ", function()
			net.Start("crit.use")
				net.WriteEntity(focused_ent)
				net.WriteBool(true)
			net.SendToServer()
		end)

		menu:AddOption("ДОБИТЬ", function()
			net.Start("crit.use")
				net.WriteEntity(focused_ent)
				net.WriteBool(false)
			net.SendToServer()
		end)

		menu:Open()
		menu:Center()

		focused_ent = nil
		return true
	end

	function PLUGIN:PlayerBindPress(client, bind, pressed)
		if IsValid(focused_ent) and focus_stick >= CurTime() then
			if bind:find("attack") and pressed then
				return true
			elseif bind:find("+use") and pressed then
				return UseCriticalButton()
			end
		end
	end

	function PLUGIN:HUDPaint()
		self:DrawBleeding()
		
		if critCount == 0 then
			return
		end

		surface.SetMaterial(crit_material)

		local plypos = LocalPlayer():GetPos()
		local midscreen_x = ScrW() / 2
		local midscreen_y = ScrH() / 2
		local pos, scrpos, d
		local focus_ent = nil
		local focus_d, focus_scrpos_x, focus_scrpos_y = 0, midscreen_x, midscreen_y

		for but, _ in pairs(critPlayers) do
			if IsValid(but) and but:IsPlayer() then
				local doll = but:GetNetVar("doll") and Entity(but:GetNetVar("doll"))
				if IsValid(doll) then
					but = doll
				end

				local boneID = but:LookupBone("ValveBiped.Bip01_Head1")

				pos = but:GetPos()

				if boneID then
					pos = but:GetBonePosition(boneID)
				end

				scrpos = pos:ToScreen()

				if !IsOffScreen(scrpos) then
					d = pos - plypos
					d = d:Dot(d) / (100 ^ 2)

					if d < 1 then
						surface.SetDrawColor(255, 255, 255, 255 * (1 - d))
						surface.DrawTexturedRect(scrpos.x - mid, scrpos.y - mid, size, size)

						if d > focus_d then
							local x = abs(scrpos.x - midscreen_x)
							local y = abs(scrpos.y - midscreen_y)
							if (x < focus_range and y < focus_range and
								 x < focus_scrpos_x and y < focus_scrpos_y) then

								if focus_stick < CurTime() or but == focused_ent then
									focus_ent = but
								end
							end
						end
					end
				end
			else
				critPlayers[but] = nil
				critCount = table.Count(critPlayers)
			end

			if IsValid(focus_ent) then
				focused_ent = focus_ent
				focus_stick = CurTime() + 0.1

				local text = string.format("НАЖМИТЕ [%s] ЧТОБЫ ОГРАБИТЬ ИЛИ ДОБИТЬ", use)
				local x = scrpos.x
				local y = scrpos.y + 16
				surface.SetFont("ixCrit")

				local tX, tY = surface.GetTextSize(text)
				x = x - tX/2
				
				surface.SetFont("ixCritBlur")
				surface.SetTextColor(0, 0, 0, 255)
				surface.SetTextPos(x, y)
				surface.DrawText(text)

				surface.SetFont("ixCrit")
				surface.SetTextColor(255, 255, 255, 255)
				surface.SetTextPos(x, y)
				surface.DrawText(text)
			end
		end
	end
end