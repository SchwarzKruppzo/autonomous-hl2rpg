local PANEL = {}
local AnimatedBG = Material("autonomous/ui/terminal/cmb_bg_animated")
local BG = Material("autonomous/ui/terminal/bg.png")
local C24 = Material("autonomous/c24_logo.png")


AccessorFunc(PANEL, "page", "Page", FORCE_STRING)

PANEL.Pages = {
	Login = {
		title = "АВТОРИЗАЦИЯ",
		frame = function(terminal, container)
			local panel = container:Add("Panel")
			panel:Dock(FILL)
			panel:SetSize(container:GetWide(), container:GetTall())

			local logoSize = 128
			local logo = panel:Add("Panel")
			logo:SetSize(logoSize, logoSize)
			logo.Paint = function(_, w, h)
				ix.DX.DrawMaterial(0, 0, 0, w, h, ix.Palette.combinegreen:Alpha(200), C24)
			end
			logo:Center()
			logo:AlignTop(16)

			local text = panel:Add("DLabel")
			text:SetFont("cmb.terminal.light24")
			text:SetTextColor(ix.Palette.combinegreen)
			text:SetText("ДОБРО ПОЖАЛОВАТЬ!")
			text:MoveBelow(logo, 16)
			text:SizeToContents()
			text:CenterHorizontal()

			local login = panel:Add("terminal.button.cmb")
			login:SetSize(terminal:GetWide() * 0.5, 40)
			login:SetText("РЕГИСТРАЦИЯ / ВХОД В СИСТЕМУ")
			login:CenterHorizontal()
			login:MoveBelow(text, 24)
			login.OnClick = function(_)
				ix.gui.civilTerminal = terminal

				net.Start("civil.terminal.login")
					net.WriteEntity(terminal.entity)
				net.SendToServer()
				--terminal:SwitchPage("Logged")

				--surface.PlaySound( "combine_tech/civic_station/station_menu_appear.mp3" )
			end

			return panel
		end,
	},
	Logged = {
		title = "НАВИГАЦИЯ",
		frame = function(terminal, container)
			local Buttons = {
				{title = "ЛИЧНЫЙ КАБИНЕТ", page = "Datafile"},
				{title = "ВЫЗОВ СЛУЖБ"},
				{title = "ГРАЖДАНСКИЙ КОДЕКС"},
			}

			local sizew = container:GetWide() - terminal:GetWide() * 0.5
			local panel = container:Add("Panel")
			panel:Dock(FILL)
			panel:DockPadding(sizew * 0.5, 0, sizew * 0.5, 0)

			for _, info in SortedPairs(Buttons) do
				local btn = panel:Add("terminal.button.cmb")
				btn:SetTall(40)
				btn:Dock(TOP)
				btn:DockMargin(0, 10, 0, 0)
				btn:SetText(info.title)
				btn.OnClick = function(_)
					if info.page then
						terminal:SwitchPage(info.page)

						return
					end
				end
			end
			
			local exit = panel:Add("terminal.button.cmb")
			exit:SetTall(40)
			exit:Dock(BOTTOM)
			exit:DockMargin(0, 0, 0, 10)
			exit:SetText("ВЫХОД")
			exit.OnClick = function(_)
				terminal:SwitchPage("Login")

				surface.PlaySound("combine_tech/civic_station/station_menu_disappear.mp3")
			end

			return panel
		end,
	},
	Datafile = {
		title = "ЛИЧНЫЙ КАБИНЕТ",
		frame = function(terminal, container)
			local panel = container:Add("terminal.page.datafile")
			panel:Dock(FILL)
			panel:SetSize(container:GetWide(), container:GetTall())
			panel:CreateTabs()

			return panel
		end,
	}
}

function PANEL:PaintNews(x2, y2, w, h)
	local text = self.newsText .. '     ::     '
	surface.SetFont(self.newsFont)

	local textw, texth = surface.GetTextSize(text)

	surface.SetTextColor(ix.Palette.black)

	local x = x2 + RealTime() * 64 % textw * -1

	while (x < w) do
		surface.SetTextPos(x, y2 + h / 2 - texth / 2)
		surface.DrawText(text)
		x = x + textw
	end
end

function PANEL:Init()
	self:SetSize(640, 360)

	self.title = "АВТОРИЗАЦИЯ"
	//self.newsText = "UnionNews-24 :: Сообщения с фронта на Ближнем востоке - Миротворческие силы Надзора выигрывают 97,8% сражений против врагов Вселенского Союза.     ::     Десант колонистов, организованный корпорацией \"EuroEnergy\", высадился на северном побережье Южной Америки. Первоначальные доклады указывали на то, что местная фауна была «катастрофически агрессивна» во время процесса очистки от последствий портальных штормов."
	self.newsText = 'Корпорация "Amax BioTech" провела успешные испытания серии оптических имплантов для гражданских, обладающие функциями GPS навигации нового поколения. Как заявили в компании, «оптические импланты станут доступны каждому гражданину», первые копии можно будет заказать через любое районное отделение Медицинского и Научного Союза уже на этой неделе.     ::     Порноактриса была найдена мёртвой в собственной квартире на "Альпийском Резорте". Предварительная причина смерти — истощение и обезвоживание на фоне чрезмерного использования «взрослых» стимуляторов от фирмы Uni-Pharmacy. Местны силы Гражданской Обороны занялись расследованием.'
	self.newsFont = "cmb.terminal.medium24"

	self.container = self:Add("Panel")
	self.container:Dock(FILL)
	self.container:DockMargin(25, 33 + 5, 22, 10)

	self.bottom = self:Add("Panel")
	self.bottom:Dock(BOTTOM)
	self.bottom:DockMargin(25, 0, 22, 0)
	self.bottom:SetTall(34)
	self.bottom:InvalidateParent(true)

	self.news = self.bottom:Add("Panel")
	self.news:Dock(FILL)
	self.news:DockMargin(0, 0, 0, 5)
	self.news.Paint = function(_, w, h)
		surface.SetDrawColor(ix.Palette.combineyellow)
		surface.DrawRect(0, 0, w, h)
		DisableClipping(false)
		self:PaintNews(0, 0, w, h)
	end

	self:SetPaintedManually(true)
	ix.testgui = self

	self:SwitchPage("Login")
end

function PANEL:SwitchPage(page)
	local info = self.Pages[page]

	if !info or page == self:GetPage() then
		return
	end
	
	self.title = info.title
	self:SetPage(page)

	self.container:Clear()

	info.frame(self, self.container)
end

function PANEL:GetPageTitle()
	return self.title
end

local gray = Color(255, 255, 255, 150)
function PANEL:Paint(w, h)
	ix.DX.Draw(0, 0, 0, w, h, nil, ix.DX.BLUR)
	ix.DX.DrawMaterial(0, 0, 0, w, h, gray, BG)

	render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_MAX, BLEND_ONE, BLEND_ZERO, BLENDFUNC_ADD)
		surface.SetMaterial(AnimatedBG)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(0, 0, w, h)
	render.OverrideBlend(false)

	surface.SetDrawColor(ix.Palette.combineblue)

	local x = 25

	surface.DrawLine(x, 33, w - 22, 33)
	surface.DrawLine(x, h - 39.5, w - 22, h - 39.5)

	draw.SimpleText(":: " .. self:GetPageTitle() .. " ::", "cmb.terminal.title", 25, 8, ix.Palette.combineblue, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
end

vgui.Register("terminal.civil", PANEL)