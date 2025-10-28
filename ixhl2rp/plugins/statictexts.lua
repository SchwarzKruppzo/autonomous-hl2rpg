local PLUGIN = PLUGIN

PLUGIN.name = "Static Texts"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = "Позволяет игрокам создавать и управлять постоянными текстовыми аннотациями."

local annotations = PLUGIN.annotations or {}
PLUGIN.annotations = annotations

ix.config.Add("annotationDuration", 240, "Время в минутах до автоматического истечения аннотации.", nil, {
	data = {min = 1, max = 10080},
	category = "Utilities"
})

CAMI.RegisterPrivilege({
	Name = "Helix - Map Annotations",
	MinAccess = "admin"
})

local function createAnnotationData(client, annotationText)
	return {
		position = client:GetPos() + Vector(0, 0, 30),
		content = annotationText,
		ownerName = client:GetName(),
		ownerSteamID = client:SteamID(),
		createdAt = os.date("%m/%d/%Y %H:%M:%S", os.time())
	}
end

local function validateAdd(client, annotationText, clientPos)
	if annotationText:Trim() == "" then
		return false
	end

	for _, annotation in ipairs(annotations) do
		if annotation.position:DistToSqr(clientPos) < 2500 then
			client:Notify("Это место слишком близко к существующей аннотации!")
			return false
		end

		if annotation.ownerSteamID == client:SteamID() and !CAMI.PlayerHasAccess(client, "Helix - Map Annotations") then
			client:Notify("У вас может быть только одна активная аннотация. Сначала удалите свою.")
			return false
		end
	end

	return true
end

do
	local CMD = {}
	CMD.description = "Разместить описательную аннотацию в текущем месте."
	CMD.arguments = ix.type.text
	CMD.privilege = "Map Annotations"
	CMD.alias = {"StaticTextAdd", "SceneTextAdd"}

	function CMD:OnRun(client, annotationText)
		local currentTime = CurTime()

		if client.lastAnnotationTime and client.lastAnnotationTime > currentTime then
			client:NotifyLocalized("tooSoon")
			return
		end

		local clientPos = client:GetPos()

		if !validateAdd(client, annotationText, clientPos) then
			return
		end

		local annotationData = createAnnotationData(client, annotationText)
		PLUGIN:CreateAnnotation(annotationData)

		client.lastAnnotationTime = currentTime + 5
		client:Notify("Аннотация успешно размещена.")

		ix.log.Add(client, "annotationCreated", annotationText)
	end

	ix.command.Add("SceneText", CMD)
end

do
	local CMD = {}
	CMD.description = "Удалить ближайшую аннотацию."
	CMD.privilege = "Map Annotations"
	CMD.alias = {"StaticTextRemove", "RemoveSceneText"}

	function CMD:OnRun(client)
		local eyeTrace = client:GetEyeTraceNoCursor()

		if !eyeTrace.Hit then
			return
		end

		local hitPosition = eyeTrace.HitPos

		for index, annotation in ipairs(annotations) do
			if annotation.position:DistToSqr(hitPosition) < 2500 then
				if annotation.ownerSteamID == client:SteamID() or CAMI.PlayerHasAccess(client, "Helix - Map Annotations") then
					PLUGIN:DeleteAnnotation(index)
					client:Notify("Аннотация удалена.")
					ix.log.Add(client, "annotationDeleted", annotation.content)
				else
					client:Notify("Недостаточно прав для удаления этой аннотации.")
				end
				return
			end
		end

		client:Notify("Аннотация не найдена в этом направлении.")
	end

	ix.command.Add("SceneTextRemove", CMD)
end

if CLIENT then
	local visibilityCacheTime = -1
	local visibilityCache = {}

	local function IsVisibleToclient(LocalPlayer, clientEyePos, annotation)
		local now = CurTime()

		if visibilityCacheTime <= now or !visibilityCache[annotation] then
			local visibilityTrace = util.TraceLine({
				start = clientEyePos,
				endpos = annotation.position,
				mask = MASK_SOLID_BRUSHONLY
			})

			visibilityCache[annotation] = !visibilityTrace.Hit
			visibilityCacheTime = now + 0.5
		end

		return visibilityCache[annotation]
	end

	function PLUGIN:HUDPaint()
		if !annotations or #annotations == 0 then
			return
		end

		local LocalPlayer = LocalPlayer()
		local eyePosition = LocalPlayer:EyePos()
		local screenWidth, screenHeight = ScrW(), ScrH()
		local screenCenterX, screenCenterY = screenWidth * 0.5, screenHeight * 0.5
		local adminAccess = CAMI.PlayerHasAccess(LocalPlayer, "Helix - Map Annotations")

		for _, annotation in ipairs(annotations) do
			local distanceSqr = eyePosition:DistToSqr(annotation.position)
			if distanceSqr <= 90000 and IsVisibleToclient(LocalPlayer, eyePosition, annotation) then
				local screenPos = annotation.position:ToScreen()
				local screenDistance = math.Distance(screenCenterX, screenCenterY, screenPos.x, screenPos.y)
				local fadeByScreen = math.max(0, 1 - (screenDistance / screenWidth) * 1.5)
				local fadeByDistance = math.max(0, 1 - math.sqrt(distanceSqr) * 0.003333)
				local textAlpha = 255 * fadeByScreen * fadeByDistance

				local textColor = Color(255, 255, 255, textAlpha)
				local outlineColor = Color(0, 0, 0, textAlpha)
				local textFont = "ixGenericFont"

				surface.SetFont(textFont)
				local wrappedLines = ix.util.WrapText(annotation.content, screenWidth * 0.25, textFont)

				if input.IsKeyDown(KEY_LALT) and adminAccess then
					table.insert(wrappedLines, annotation.ownerName .. " (" .. annotation.ownerSteamID .. ")")
					table.insert(wrappedLines, annotation.createdAt)
				end

				local lineSpacing = 4
				local _, textHeight = surface.GetTextSize(annotation.content)
				local totalHeight = (#wrappedLines * textHeight)
				local startY = screenPos.y - totalHeight / 2

				for lineIndex, lineText in ipairs(wrappedLines) do
					local textWidth, lineHeight = surface.GetTextSize(lineText)
					local lineY = startY + (lineIndex - 1) * (lineHeight + lineSpacing)

					draw.SimpleTextOutlined(lineText, textFont, screenPos.x - textWidth / 2, lineY, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, outlineColor)
				end
			end
		end
	end

	-- Netstream hooks for client
	netstream.Hook("ixAnnotationCreate", function(newAnnotation)
		table.insert(annotations, newAnnotation)
	end)

	netstream.Hook("ixAnnotationDelete", function(annotationIndex)
		table.remove(annotations, annotationIndex)
	end)

	netstream.Hook("ixAnnotationSync", function(allAnnotations)
		annotations = allAnnotations
	end)

else
	ix.log.AddType("annotationCreated", function(client, content)
		return string.format("%s создал аннотацию: %s", client:GetName(), content)
	end)

	ix.log.AddType("annotationDeleted", function(client, content)
		return string.format("%s удалил аннотацию: %s", client:GetName(), content)
	end)

	function PLUGIN:CreateAnnotation(annotationData)
		local newIndex = #annotations + 1
		annotations[newIndex] = annotationData

		local expirationDelay = (annotationData.remainingTime or ix.config.Get("annotationDuration", 240)) * 60
		timer.Create("ixAnnotationExpire" .. newIndex, expirationDelay, 1, function()
			self:DeleteAnnotation(newIndex)
		end)

		netstream.Start(nil, "ixAnnotationCreate", annotationData)
	end

	function PLUGIN:DeleteAnnotation(index)
		local annotation = table.remove(annotations, index)

		if annotation then
			local timerName = "ixAnnotationExpire" .. index
			if timer.Exists(timerName) then
				timer.Remove(timerName)
			end

			netstream.Start(nil, "ixAnnotationDelete", index)
		end
	end

	function PLUGIN:clientInitialSpawn(client)
		timer.Simple(2, function()
			if IsValid(client) then
				netstream.Start(client, "ixAnnotationSync", annotations)
			end
		end)
	end

	function PLUGIN:SaveData()
		for index, annotation in ipairs(annotations) do
			local timerName = "ixAnnotationExpire" .. index
			if timer.Exists(timerName) then
				annotation.remainingTime = timer.TimeLeft(timerName)
			end
		end

		ix.data.Set("mapannotations", annotations)
	end

	function PLUGIN:LoadData()
		local savedAnnotations = ix.data.Get("mapannotations", {})

		for _, annotation in ipairs(savedAnnotations) do
			self:CreateAnnotation(annotation)
		end
	end
end