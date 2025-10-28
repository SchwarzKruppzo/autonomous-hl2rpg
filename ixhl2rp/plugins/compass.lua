local PLUGIN = PLUGIN
PLUGIN.name = "Compass"
PLUGIN.author = "Schwarz Kruppzo & mCompass"
PLUGIN.description = ""

if SERVER then return end

local adv_compass_tbl = {
	[0] = "С",
	[45] = "СВ",
	[90] = "В",
	[135] = "ЮВ",
	[180] = "Ю",
	[225] = "ЮЗ",
	[270] = "З",
	[315] = "СЗ",
	[360] = "С"
}

local compass_style = {
	heading = true,
	compassX = 0.5,
	compassY = 0.05,
	width = 0.25,
	height = 0.03,
	spacing = 2.5,
	ratio = 1.8,
	offset = 0,
	color = Color(115, 255, 200)
}
local fontRatioChangeTable = fontRatioChangeTable or {}
local smoothedAngle = 0

local function getTextSize(font, text)
	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)

	return w, h
end

local function createFonts()
	local h = compass_style.height
	local r = compass_style.ratio
	local numberFontName = "exo_compass_Numbers_" .. r

	if !fontRatioChangeTable[numberFontName] then
		surface.CreateFont(numberFontName, {
			font = "BudgetLabel",
			size = math.Round((ScrH() * h) / r),
			weight = 600,
			extended = true,
			shadow = true,
			scanlines = 1,
			outline = true,
			antialias = true
		})

		surface.CreateFont("exo_compass_Letters", {
			font = "CATArena",
			size = ScrH() * h,
			extended = true,
			shadow = true,
			scanlines = 1,
			outline = true,
			antialias = true
		})

		fontRatioChangeTable[numberFontName] = true
	end

	return numberFontName
end

local numberFont = createFonts()
local triangleSize = 8
local lerpSpeed = 0.15
local scrW, scrH = ScrW(), ScrH()

function PLUGIN:Think()
	local ply = LocalPlayer()
	
	if !IsValid(ply) or !ply:Alive() then return end

	local ang = ply:EyeAngles().y
	local targetAngle = -ang % 360
	local delta = math.NormalizeAngle(targetAngle - smoothedAngle)
	
	smoothedAngle = smoothedAngle + delta * lerpSpeed
end

function PLUGIN:HUDPaint()
	local ply = LocalPlayer()
	local char = ply:GetCharacter()

	if !char or !ply:Alive() or ix.gui.characterMenu:IsVisible() then
		return
	end

	local ang = Angle(0, smoothedAngle, 0) 
	local compassX = scrW * compass_style.compassX
	local compassY = scrH * compass_style.compassY
	local width = scrW * compass_style.width
	local height = scrH * compass_style.height
	local cl_spacing = compass_style.spacing
	local ratio = compass_style.ratio
	local offset = compass_style.offset
	local color = compass_style.color
	local heading = compass_style.heading

	local spacing = (width * cl_spacing) / 360
	local numOfLines = width / spacing
	local fadeDistance = width / 2

	local startAngle = math.Round(smoothedAngle) % 360

	surface.SetFont(numberFont)

	for k = 0, numOfLines do
		local relative_deg = k
		local x = (compassX - (width / 2)) + (relative_deg * spacing)
		local i = startAngle + k
		local value = math.abs(x - compassX)
		local calc = 1 - ((value + (value - fadeDistance)) / (width / 2))
		local alpha = 255 * math.Clamp(calc, 0.001, 1)
		local i_offset = -math.Round(i - offset - (numOfLines / 2)) % 360

		if i_offset % 15 == 0 and i_offset >= 0 then
			local a = i_offset
			local text_key = 360 - (a % 360)
			local text = adv_compass_tbl[text_key] or text_key
			local font = isstring(text) and "exo_compass_Letters" or numberFont
			local w = getTextSize(font, text)

			surface.SetDrawColor(color.r, color.g, color.b, alpha)
			surface.SetTextColor(color.r, color.g, color.b, alpha)
			surface.SetFont(font)

			if font == numberFont then
				surface.DrawLine(x, compassY, x, compassY + height * 0.2)
				surface.DrawLine(x, compassY, x, compassY + height * 0.3)
				surface.SetTextPos(x - w / 2, compassY + height * 0.5)
				surface.DrawText(text)
			else
				surface.SetTextPos(x - w / 2, compassY)
				surface.DrawText(text)
			end
		end
	end

	if heading then
		local triangle = {
			{x = compassX - triangleSize / 2, y = compassY - (triangleSize * 2)},
			{x = compassX + triangleSize / 2, y = compassY - (triangleSize * 2)},
			{x = compassX, y = compassY - triangleSize}
		}

		surface.SetDrawColor(color)
		draw.NoTexture()
		surface.DrawPoly(triangle)

		local text = math.Round(smoothedAngle - offset) % 360
		local w, h = getTextSize(numberFont, text)
		surface.SetFont(numberFont)
		surface.SetTextColor(color)
		surface.SetTextPos(compassX - w / 2, compassY - h - (triangleSize * 2))
		surface.DrawText(text)
	end
end

function PLUGIN:OnScreenSizeChanged()
	scrW, scrH = ScrW(), ScrH()

	fontRatioChangeTable = {}
	numberFont = createFonts()
end
