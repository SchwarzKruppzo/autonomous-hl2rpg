surface.CreateFont("BookAlegreya", {
	font = "Alegreya",
	size = 28,
	weight = 800,
	antialias = true,
	extended = true
})
surface.CreateFont("BookCaveat", {
	font = "Caveat",
	size = 38,
	weight = 700,
	antialias = true,
	extended = true
})
surface.CreateFont("BookPacifico", {
	font = "Pacifico",
	size = 40,
	weight = 500,
	antialias = true,
	extended = true
})
surface.CreateFont("BookMarck", {
	font = "Marck Script",
	size = 30,
	weight = 800,
	antialias = true,
	extended = true
})

surface.CreateFont("BookAlegreyaPreview", {
	font = "Alegreya",
	size = 24,
	weight = 800,
	antialias = true,
	extended = true
})
surface.CreateFont("BookCaveatPreview", {
	font = "Caveat",
	size = 28,
	weight = 700,
	antialias = true,
	extended = true
})
surface.CreateFont("BookPacificoPreview", {
	font = "Pacifico",
	size = 30,
	weight = 500,
	antialias = true,
	extended = true
})
surface.CreateFont("BookMarckPreview", {
	font = "Marck Script",
	size = 25,
	weight = 700,
	antialias = true,
	extended = true
})



local PANEL = {}

function PANEL:Init()
	local w, h = ix.UI.Scale(900 / 3), ix.UI.Scale(300)

	self:SetSize(w, h)
	self:Center()
	self:MakePopup()

	local buttonBox = self:Add("Panel")
	buttonBox:Dock(FILL)
	buttonBox:SetTall(ix.UI.Scale(50 / 3))

	local textPreview = L("pwTextPreview")
	
	self:CreateFontButton(buttonBox, "BookAlegreya", textPreview)
	self:CreateFontButton(buttonBox, "BookCaveat", textPreview)
	self:CreateFontButton(buttonBox, "BookPacifico", textPreview)
	self:CreateFontButton(buttonBox, "BookMarck", textPreview)
end

function PANEL:CreateFontButton(buttonBox, font, text)
    local button = buttonBox:Add("DButton")
    button:Dock(TOP)
    button:SetTall(30)
    button:SetTextColor(color_black)
    button:SetWide(self:GetWide() / 7)
    button:SetText(text)
    button:SetFont(font)
    button:SetContentAlignment(5)
    button.Paint = function(this, w, h)
        self:PaintStuff(this, w, h)
    end

    button.DoClick = function()
    	self.callback(font)
        self:Remove()
    end
end

function PANEL:PaintStuff(this, w, h)
    surface.SetDrawColor(Color(255, 255, 255, 255))
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(Color(0, 0, 0, (255 / 100 * 30)))
    surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("cellar.book.font", PANEL, "DFrame")