local scale = ix.UI.Scale

surface.CreateFont("cellar.main.warn", {
	font = "Blender Pro Medium",
	extended = true,
	size = 16,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

local clrConsole = Color(102, 150, 190, 10)
local console = Material("cellar/main/console")
local warning = Material("cellar/main/warning.png")
local tex = GetRenderTargetEx("ui_mainmenu_glow_rt", ScrW(), ScrH(), RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_SHARED, 0, 0, IMAGE_FORMAT_RGBA8888)
local rt_mat = CreateMaterial("ui_mainmenu_glow","UnlitGeneric",{
	["$basetexture"] = "ui_mainmenu_glow_rt",
	["$translucent"] = 1,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$additive"] = 1,
})
rt_mat:Recompute()

local PANEL = {}
PANEL.css = [[
#logo-container {
	position: absolute;
	width: auto;
	height: auto;
	display: flex;
	flex-flow: row wrap;
	align-items: stretch;
	top: 4.916rem;
	left: 4.916rem;
	animation: logo-opacity 0.5s ease forwards;
}
#logo-name-container {
	padding-left: 2.3rem;
	display: flex;
	flex-flow: column nowrap;
	justify-content: center;
}
#logo-img {
	display: inline-block;
	height: 8.916rem;
}
#logo-name {
	color: #38cff8;
	font-family: Move-X;
	font-weight: bold;
	font-size: min(4.791vw, 3.83rem);
	text-shadow: 0 0 0.025em #38cff8,
		0 0 0.1em rgba(0, 0, 255, 0.5),
		0 0 0.5em rgba(0, 0, 255, 0.5);
}
#logo-desc {
	color: #f83838;
	font-family: Move-X;
	font-style: italic;
	font-size: min(1.5625vw, 1.25rem);
	white-space: pre;
}
@keyframes logo-opacity {
	0% {
		transform: translateX(-2%);
	}
	100% {
		transform: translateX(0px);
	}
}

.hint-container {
	position: absolute;
	font-family: "BlenderProMedium";
	width: 50%;
	height: auto;
	right: 7.5%;
	bottom: 7.5%;
	color: #38cff8;
	opacity: 0;
	font-size: 1.05rem;
}
.hint-anim-down {
	animation-name: fx-opacity-down;
}
.hint-anim-right {
	animation-name: fx-opacity-right;
}
.hint-fx-container {
	position: relative;
}
.hint-footer {
	position: relative;
}
.hint-footer.news {
	font-size: 1rem;
}
.hint-content {
	margin-top: -0.1rem;
	padding-left: 2.17rem;
	position: relative;
}
.hint-textbox {
	font-family: "BlenderProMedium";
	font-size: 0.675rem;
	font-weight: 500;
	padding: 0.75rem;
	background: linear-gradient(90deg, rgba(56,207,248,0.1) 0%, rgba(0,0,0,0) 100%);
}
.hint-textbox.news {
	font-size: 0.65rem;
	font-weight: 500;
	color: rgba(56, 207, 255, 0.75);
	background: rgba(56,207,248,0.1);
}
.hint-textbox.news strong {
	font-size: 0.75rem;
	font-weight: 500;
	color: #38cff8;
}
.hint-textbox.news ul {
	margin-top: 0.1rem;
	margin-bottom: 0.5rem;
	padding-left: 1rem;
}
.hint-content:before, .hint-content:after {
    content: "";
    position: absolute;
    height: 100%;
    width: 0.1rem;
    top: 0px;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 1 1'%3E%3Cpath fill-rule='evenodd' fill='rgb(56, 207, 248)' d='M0.0,0.0 L1.0,0.0 L1.0,1.0 L0.0,1.0 L0.0,0.0 Z'/%3E%3C/svg%3E"), url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 1 1'%3E%3Cpath fill-rule='evenodd' fill='rgb(56, 207, 248)' d='M0.0,0.0 L1.0,0.0 L1.0,1.0 L0.0,1.0 L0.0,0.0 Z'/%3E%3C/svg%3E");
    background-size: 0.1rem 0.1rem;
    background-position: top right, bottom right;
    background-repeat: no-repeat;
}
.hint-content:before {
    left: 2.17rem;
}
.hint-content:after {
    right: 0px;
}
span.hint-footer {
	display: inline-block;
	line-height: 2.17rem;
	width: 100%;
	padding-left: calc(2.17rem + 0.68rem);
}
span.hint-footer:before {
	content: "";
	background-image: url("asset://garrysmod/materials/ui/hint-ico.png");
	background-size: 2rem 2rem;
	width: 2rem;
	height: 2rem;
	position: absolute;
	left: 0;
}
span.hint-footer.news:before {
	background-image: none;
}
.hint-fx-top {
	position: absolute;
	border-bottom: 0.1rem solid rgba(56, 207, 248, 0.25);
	top: 0px;
	left: 0px;
	bottom: 0px;
	right: 0px;
	width: 0%;
	animation-name: fx-top;
}
@keyframes fx-top {
	2.5% {
		width: 0%;
	}
	7.5% {
		width: calc(100% + 0.34rem);
	}
	100% {
		width: calc(100% + 0.34rem);
	}
}
.hint-fx-left {
	position: absolute;
	border-right: 0.1rem solid rgba(56, 207, 248, 0.25);
	top: 0px;
	left: 0px;
	bottom: 0px;
	width: 2.17rem;
	height: 0%;
	animation-name: fx-left;
}
@keyframes fx-left {
	2.5% {
		height: 0%;
	}
	7.5% {
		height: calc(100% + 0.34rem);
	}
	100% {
		height: calc(100% + 0.34rem);
	}
}
.hint-fx-bottom {
	position: absolute;
	border-bottom: 0.1rem solid rgba(56, 207, 248, 0.25);
	top: 0px;
	left: calc(2.17rem - 0.34rem);
	bottom: 0px;
	width: 0%;
	animation-name: fx-bottom;
}
@keyframes fx-bottom {
	7.5% {
		width: 0%;
	}
	14% {
		width: calc(100% - calc(2.17rem - 0.34rem) + 0.34rem);
	}
	100% {
		width: calc(100% - calc(2.17rem - 0.34rem) + 0.34rem);
	}
}
.hint-fx-right {
	position: absolute;
	border-right: 0.1rem solid rgba(56, 207, 248, 0.25);
	top: -0.34rem;
	right: 0px;
	height: 0%;
	animation-name: fx-right;
}
@keyframes fx-right {
	7.5% {
		height: 0%;
	}
	14% {
		height: calc(100% + 0.68rem);
	}
	100% {
		height: calc(100% + 0.68rem);
	}
}
@keyframes fx-opacity-down {
	0% {
		opacity: 0;
		transform: translateY(50%);
	}
	5% {
		opacity: 1;
		transform: translateY(0px);
	}
	100% {
		opacity: 1;
	}
}
@keyframes fx-opacity-right {
	0% {
		opacity: 0;
		transform: translateX(50%);
	}
	5% {
		opacity: 1;
		transform: translateX(0px);
	}
	100% {
		opacity: 1;
	}
}
.hint-fx {  
	animation-duration: 15s;
	animation-timing-function: ease;
	animation-fill-mode: forwards;
}

html, body {
	height: 100%;
	padding: 0;
	margin: 0;
	font-size: 2.22vh;
	overflow: hidden;
	user-select: none;
	opacity: 0;
	animation: all-opacity 10s ease forwards;
}
@keyframes all-opacity {
	0% {
		opacity: 0;
	}
	3% {
		opacity: 0.3;
	}
	4% {
		opacity: 0.7;
	}
	5% {
		opacity: 0.4;
	}
	9% {
		opacity: 1;
	}
	100% {
		opacity: 1;
	}
}
#fx-border {
	background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='1876.5px' height='1003.5px'%3E%3Cpath fill-rule='evenodd' stroke='rgb(56, 207, 248)' stroke-width='3px' stroke-linecap='butt' stroke-linejoin='miter' opacity='0.251' fill='none' d='M1873.499,889.499 L1855.499,889.499 L1746.500,998.500 L865.499,998.500 L850.500,983.500 L36.500,983.500 L3.500,950.500 L3.500,84.500 L84.499,3.499 L1213.500,3.499 L1236.499,26.499 L1873.499,26.499 '/%3E%3C/svg%3E");
	background-size: 100% 92.91%;
	background-repeat: no-repeat;
	background-position: center;
	position: absolute;
	width: 97.734375%;
	height: 100%;
	right: -1px;
}
div.main-btn {
	background-color: rgba(45, 162, 201, 0.25);
	background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='285px' height='40px'%3E%3Cpath fill-rule='evenodd' opacity='0.502' fill='rgb(56, 207, 248)' d='M0.0,38.999 L285.0,38.999 L285.0,40.0 L0.0,40.0 L0.0,38.999 Z'/%3E%3Cpath fill-rule='evenodd' opacity='0.502' fill='rgb(56, 207, 248)' d='M0.0,0.0 L285.0,0.0 L285.0,1.0 L0.0,1.0 L0.0,0.0 Z'/%3E%3Cpath fill-rule='evenodd' opacity='0.502' fill='rgb(56, 207, 248)' d='M283.999,0.0 L285.0,0.0 L285.0,39.999 L283.999,39.999 L283.999,0.0 Z'/%3E%3C/svg%3E");
	background-size: 100% 100%;
	background-repeat: no-repeat;
	margin-left: 0%;
	animation: moveToRight 0.5s ease-in-out;
	animation-fill-mode: forwards;
	opacity: 0;
	position: relative;
	display: flex;
	flex-flow: row nowrap;
	align-items: center;
	justify-content: left;
	width: 11.875rem;
	height: 1.67rem;
	margin-top: 0.1rem;
	transition: background-image 100ms, background-color 100ms ease-in-out;
}
div.main-btn:nth-child(1) {
	animation-delay: 400ms;
}
div.main-btn:nth-child(2) {
	animation-delay: 300ms;
}
div.main-btn:nth-child(3) {
	animation-delay: 200ms;
}
div.main-btn:nth-child(4) {
	animation-delay: 100ms;
}
div.main-btn:nth-child(5) {
	animation-delay: 0ms;
}
div.main-btn:hover {
	background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='285px' height='40px'%3E%3Cpath fill-rule='evenodd' opacity='0.502' fill='%23f83838' d='M0.0,38.999 L285.0,38.999 L285.0,40.0 L0.0,40.0 L0.0,38.999 Z'/%3E%3Cpath fill-rule='evenodd' opacity='0.502' fill='%23f83838' d='M0.0,0.0 L285.0,0.0 L285.0,1.0 L0.0,1.0 L0.0,0.0 Z'/%3E%3Cpath fill-rule='evenodd' opacity='0.502' fill='%23f83838' d='M283.999,0.0 L285.0,0.0 L285.0,39.999 L283.999,39.999 L283.999,0.0 Z'/%3E%3C/svg%3E");
	background-color: rgba(248, 56, 56, 0.25);
}
div.main-btn:hover .main-btn-ico {
	background-color: rgb(248, 56, 56);
}
div.main-btn:hover a.main-btn {
	color: rgb(248, 56, 56);
	text-shadow: 0 0 0.1rem #f00,
		0 0 0.25rem #f00;
}
div.main-btn:last-of-type {
  margin-top: auto;
}
.main-btn-ico {
	background-color: #38cff8;
	width: 1.34rem;
	height: 100%;
	transition: background-color 100ms ease-in-out;
}
div.main-btn2 {
	display: inline-block;
	padding-left: 0.4rem;
}
a.main-btn {
	position: absolute;
	width: calc(100% - 1.74rem);
	height: 1.67rem;
	line-height: 1.67rem;
	padding-left: 1.74rem;
	color: #38cff8;
	font-family: "BlenderProBook";
	text-shadow: 0 0 0.5rem #00f;
	transition: color 100ms, text-shadow 100ms ease-in-out;
}
a.main-btn:after {

}
a:link, a:visited, a:hover, a:active {
	text-decoration: none;
}
#test2 {
	position: absolute;
	top: 55.7vh;
	bottom: 8.79vh;
	width: 11.2vh;
	display: flex;
	flex-flow: column wrap;
	justify-content: flex-start;
}
@keyframes moveToRight {
	0% {
		margin-left: 0%;
		opacity: 0;
	}
	100% {
		margin-left: 100%;
		opacity: 1;
	}
}
.warning {
	font-family: "BlenderProMedium";
	font-weight: 600;
	font-size: 0.65rem;
	color: #f83838;
	display: flex;
	align-items: center;
	position: absolute;
	top: 50vh;
	left: 11.2vh;
	animation: warning 1.25s ease-in-out infinite;
	text-shadow: 0 0 0.75em rgba(255, 0, 0, 0.75);
}
@keyframes warning {
	0% {
		opacity: 1;
	}
	50% {
		opacity: 0.75;
	}
	100% {
		opacity: 1;
	}
}
.warning-ico {
	background-image: url("asset://garrysmod/materials/ui/warning.png");
	background-size: 1.34rem 1.17rem;
	width: 1.34rem;
	height: 1.17rem;
	margin-right: 0.25rem;
}
.credits {
	font-family: "BlenderProBook";
	font-weight: 100;
	font-size: 0.75rem;
	color: rgba(100, 200, 200, 0.25);
	display: flex;
	align-items: center;
	justify-content: center;
	position: absolute;
	bottom: 0;
	height: 2.5rem;
	padding-bottom: 0.25rem;
	width: 45%;
	letter-spacing: 0.05rem
}
]]

PANEL.patch = [[
<strong>Патч 28.6:</strong>
<ul style="list-style: none;">
</ul>
<strong>ЯДРО:</strong>
<ul style="list-style: none;">
	<li>— Подготовка ядра к запланированным изменениям интерфейса.</li>
</ul>
<strong>22.09.2024:</strong>
<ul style="list-style: none;">
</ul>
<strong>НОВОЕ:</strong>
<ul style="list-style: none;">
	<li>— Добавлены предметы: Черные брюки, Белые брюки, Черные брюки с ремнем, Черный пиджак, Белый пиджак, Черный пиджак с пальто.</li>
</ul>
]]

PANEL.html = [[
<div id="fx-border"></div>
<div id="logo-container">
</div>
<div class="credits">DIRECTED, MAINTAINED AND DEVELOPED BY SCHWARZ KRUPPZO (2014-2024)</div>

<div class="hint-container hint-fx hint-anim-down">
	<div class="hint-fx-container">
		<div class="hint-footer">
			<span class="hint-footer">ГРАЖДАНСКАЯ ОБОРОНА</span>
			<div class="hint-fx-top hint-fx"></div>
		</div>
		<div class="hint-content">
			<div class="hint-textbox">Сотрудники Гражданской Обороны — это не только игроки, которые призваны избивать других игроков, но они также являются интересными персонажами. Несмотря на то, что сотрудники, обычно, немногословны, многие из них подвержены коррупции и могут иметь связи с Сопротивлением. Всегда обращайтесь к сотрудникам, если желаете что-то узнать или рассказать.</div>
			<div class="hint-fx-bottom hint-fx"></div>
			<div class="hint-fx-right hint-fx"></div>
		</div>
		<div class="hint-fx-left hint-fx"></div>
	</div>
</div>

<div class="hint-container hint-fx hint-anim-right" style="top: 25%; right: 1%; width: 27.5%;">
	<div class="hint-fx-container">
		<div class="hint-footer ">
			<span class="hint-footer news">ВЕРСИЯ #28</span>
			<div class="hint-fx-top hint-fx"></div>
		</div>
		<div class="hint-content">
			<div class="hint-textbox news">
]]..PANEL.patch..[[
			</div>
			<div class="hint-fx-bottom hint-fx"></div>
			<div class="hint-fx-right hint-fx"></div>
		</div>
		<div class="hint-fx-left hint-fx"></div>
	</div>
</div>
<div class="warning"><div class="warning-ico"></div>Защищено системой анонимности версии 5.</div>
<div id="test2">
	<div class="main-btn">
		<div class="main-btn-ico" src="#" alt=""></div>
		<a class="main-btn" href="#" onclick="menu.Button(1);">НОВОЕ ПРИБЫТИЕ</a>
	</div>
	<div class="main-btn">
		<div class="main-btn-ico" src="#" alt=""></div>
		<a class="main-btn" href="#" onclick="menu.Button(2);">ПЕРСОНАЖИ</a>
	</div>
	<div class="main-btn">
		<div class="main-btn-ico" src="#" alt=""></div>
		<a class="main-btn" href="#" onclick="menu.Button(3);">КОНТЕНТ</a>
	</div>
	<div class="main-btn">
		<div class="main-btn-ico" src="#" alt=""></div>
		<a class="main-btn" href="#" onclick="menu.Button(4);">ИНФОРМАЦИЯ</a>
	</div>
	<div class="main-btn" id="exit">
		<div class="main-btn-ico" src="#" alt=""></div>
		<a class="main-btn" href="#" onclick="menu.Button(5);">ЗАКРЫТЬ</a>
	</div>
</div>]]
PANEL.java = [[
const restart_anim = ($el) => {
	$el.getAnimations().forEach((anim) => {
		anim.cancel();
		anim.play();
	});
};


function reload_animations() {
	restart_anim(document.documentElement);
	restart_anim(document.getElementById('logo-container'));

	document.querySelectorAll('div.main-btn').forEach((el) => {
		restart_anim(el);
	});

	document.querySelectorAll('.hint-fx').forEach((el) => {
		restart_anim(el);
	});
};
]]

local pos, ang = vector_origin, Angle()
local mdlang = Angle(0, -90, 0)

function PANEL:Init()
	self.mdl = ClientsideModel('models/cellar/logo.mdl', RENDERGROUP_OPAQUE)
	self.mdl:SetNoDraw(true)
	self.mdl:SetupBones()

	self:SetSize(ScrW(), ScrH())
	self:Center()
	self:SetAlpha(255)
	self:SetAllowLua(true)
	self:SetHTML([[<html>
		<body oncontextmenu="return false">
			<style>
				@font-face {
					font-family: BlenderProBook; 
					src: url("asset://garrysmod/resource/fonts/BlenderPro-Book.ttf");
				}
				@font-face {
					font-family: BlenderProBook; 
					src: url("asset://garrysmod/resource/fonts/BlenderPro-BookItalic.ttf");
					font-style: italic;
				}
				@font-face {
					font-family: BlenderProBold; 
					src: url("asset://garrysmod/resource/fonts/BlenderPro-Bold.ttf");
				}
				@font-face {
					font-family: BlenderProBold; 
					src: url("asset://garrysmod/resource/fonts/BlenderPro-BoldItalic.ttf");
					font-style: italic;
				}
				@font-face {
					font-family: BlenderProMedium; 
					src: url("asset://garrysmod/resource/fonts/BlenderPro-Medium.ttf");
				}
				@font-face {
					font-family: BlenderProMedium; 
					src: url("asset://garrysmod/resource/fonts/BlenderPro-MediumItalic.ttf");
					font-style: italic;
				}
				@font-face {
					font-family: BlenderProThin; 
					src: url("asset://garrysmod/resource/fonts/BlenderPro-Thin.ttf");
				}
				@font-face {
					font-family: BlenderProThin; 
					src: url("asset://garrysmod/resource/fonts/BlenderPro-ThinItalic.ttf");
					font-style: italic;
				}
				@font-face {
					font-family: BlenderProHeavy; 
					src: url("asset://garrysmod/resource/fonts/BlenderPro-Heavy.ttf");
				}

			]]..self.css..[[</style>]]..self.html..[[<script>]]..self.java..[[</script>
		</body>
	</html>]])

	self:AddFunction("menu", "Button", function(id)
		self:MenuClick(tonumber(id))

		LocalPlayer():EmitSound("Helix.Press")
	end)

	self:AddFunction("menu", "Hover", function()
		LocalPlayer():EmitSound("Helix.Rollover")
	end)
end

function PANEL:MenuClick(id)
	local parent = self:GetParent()

	parent:MenuClick(id, self)
end

function PANEL:Show()
	local function render_glow()
		render.PushRenderTarget(tex)
			render.Clear(0, 0, 0, 150)
		
			cam.Start2D()
				if IsValid(self) then
					self.paint_manual = true
					--self:SetPaintedManually(true)
					self:PaintManual()
					--self:SetPaintedManually(false)
					self.paint_manual = false
				end
			cam.End2D()
			render.BlurRenderTarget(tex, 8, 2, 10)
		render.PopRenderTarget()
	end

	hook.Add("HUDPaint", "ui.mainmenu.glow", render_glow)

	ix.UI:Scanline(true)

	self:QueueJavascript("reload_animations();")
end

function PANEL:Paint(w, h)
	if !self.paint_manual then
		surface.SetMaterial(rt_mat)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	render.SetBlend(1 * self:GetAlpha())
	render.SetColorModulation(1, 1, 1)
	
	cam.Start3D(pos, ang, 5, 0, 0, nil, nil, 0.01, 5280)
		--cam.IgnoreZ(true)
			render.SuppressEngineLighting(true)
			self.mdl:SetPos(pos + Vector(580, 20, 7))
			self.mdl:SetAngles(mdlang)
			self.mdl:DrawModel()

			render.SuppressEngineLighting(false)
		--cam.IgnoreZ(false)
	cam.End3D()

	local h = h - 100 - 155
	surface.SetMaterial(console)
	surface.SetDrawColor(clrConsole)
	surface.DrawTexturedRectUV(w - 512, 50 + 7, 512, h, 0, 0, 1, h / 1024)
end

vgui.Register("ui.mainmenu", PANEL, "DHTML")



local PANEL = {}

AccessorFunc(PANEL, "bUsingCharacter", "UsingCharacter", FORCE_BOOL)

local cyb = Material("ui/vignette.png")

function PANEL:Init()
	self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

	self.bg = self:Add("EditablePanel")
	self.bg:Dock(FILL)
	self.bg.Paint = function(this, w, h)
		surface.SetDrawColor(color_black)
		surface.SetMaterial(cyb)
		surface.DrawTexturedRect(0, 0, w, h)

		if BRANCH != "x86-64" then
			surface.SetTextColor(255, 0, 0)
			surface.SetFont("Session")
			surface.SetTextPos(50, 50)
			surface.DrawText("Установите x86-64 версию игры.")
		end
	end
	
	self.html = self:Add("ui.mainmenu")
end

function PANEL:UpdateReturnButton(bValue)
	if bValue != nil then
		self.bUsingCharacter = bValue
	end
end

function PANEL:OnDim()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)

	ix.UI:Scanline(false)

	hook.Remove("HUDPaint", "ui.mainmenu.glow")
end

function PANEL:OnUndim()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(true)

	self.html:Show()

	self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
	self:UpdateReturnButton()
end

function PANEL:MenuClick(id)
	local parent = self:GetParent()
	local maximum = hook.Run("GetMaxPlayerCharacter", LocalPlayer()) or ix.config.Get("maxCharacters", 5)
	local bHasCharacter = #ix.characters > 0

	if id == 1 then
		if (#ix.characters >= maximum) then
			parent:ShowNotice(3, L("maxCharacters"))
			return
		end

		self:Dim(parent.newCharacterPanel, function()
			parent.newCharacterPanel:SetActiveSubpanel("faction", 0)
		end)
	elseif id == 2 then
		if !bHasCharacter then
			parent:ShowNotice(3, "У вас должен быть хотя бы один персонаж!")
		else
			self:Dim(parent.loadCharacterPanel)
		end
	elseif id == 3 then
		gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=2425908945")
	elseif id == 4 then
		gui.OpenURL("https://discord.gg/yySMv9ZMRU")
	elseif id == 5 then
		if self.bUsingCharacter then
			parent:Close()
		else
			RunConsoleCommand("disconnect")
		end
	end
end

vgui.Register("ui.mainmenu.wrapper", PANEL, "ixCharMenuPanel")