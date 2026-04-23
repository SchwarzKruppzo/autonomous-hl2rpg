local PANEL = {}

local function escape_css_ident_token(s)
	if s:find("[^%w%%%-]") then
		return string.format("%q", s)
	end

	return s
end

local function parseLink(s)
	s = s or ""

	local colon = s:find(":", 1, true)

	if !colon then
		return s, {}
	end

	local head = s:sub(1, colon - 1)
	local tail = s:sub(colon + 1)
	local parts = string.Explode(",", tail, false)

	for i = 1, #parts do
		parts[i] = (parts[i] or ""):Trim()
	end

	return head, parts
end

local htmlOpen, styles, scripts, htmlClose =
[=[<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<style>html,body{margin:0;padding:0;height:100%;background:transparent!important;color:#ddd;font-size:14px;]=],[=[</style>
	<style id="core">
		#log{box-sizing:border-box;width:100%;height:100%;overflow-y:auto;padding:8px;word-wrap:break-word;-webkit-user-select:text;font-size:14px;}
		.m-line{margin:0 0 6px 0;line-height:1.35;}
		.m-img{vertical-align:middle;display:inline-block;image-rendering:-webkit-optimize-contrast;}
		.m-img-legacy{vertical-align:middle;display:inline-block;}
		.m-img-error{color:#f66;font-style:italic;}
		.m-link{cursor:pointer;}
		.m-link:hover{color:#ffc864;}
		]=],[=[
	</style>
	<style id="fonts"></style>
	<script type="text/javascript" charset="utf-8">
		function registerFontFace(css) {
			try {
				var el = document.getElementById("fonts");
				el.appendChild(document.createTextNode(css));
			} catch(e) {}
		}

		function setFontSize(px){
			var logEl = document.getElementById("log");
			var n = parseInt(px, 10);
			if (isNaN(n) || n<1) n=14;
			
			logEl.style.fontSize = n+"px";
		}

		function clearLog(){
			var logEl = document.getElementById("log");

			logEl.innerHTML = "";
		}

		function scrollToBottom(){
			var logEl = document.getElementById("log");

			logEl.scrollTop = logEl.scrollHeight;
		}
	</script>
	<script type="text/javascript" charset="utf-8">]=],[=[</script>
</head>
<body>
	<div id="log"></div>
</body>
<script type="text/javascript" charset="utf-8">
	var logEl = document.getElementById("log");

	logEl.addEventListener("click", function(e) {
		var t = e.target;
		while (t && t !== logEl) {
			if (t.classList && t.classList.contains("m-link")){
				e.preventDefault();
				e.stopPropagation();
				var id = t.getAttribute("data-link-id");
				var line = t.closest ? t.closest(".m-line") : null;
				var plain = line ? line.innerText : "";

				gmod.linkClick(id, plain);
				return;
			}
			t = t.parentNode;
		}
	}, true);

	document.addEventListener("mouseup", function(e) {
		if(e.button===2){
			e.preventDefault();
			var sel = window.getSelection().toString();
			gmod.setClipboard(sel);
		}
	});
</script>
</html>]=]

scripts = scripts .. ix.util.Include("js/markup-parser.lua", "client")

function PANEL:Load()
	self:SetHTML(table.concat({
		htmlOpen, 
		styles, 
		self.customStyle or "",
		scripts,
		self.customScript or "",
		htmlClose
	}))
end

function PANEL:Init()
	self.callbacks = {}

	self.lastMessageMerge = false
	self.lastMessage = nil
	self.lastMessageCounter = 1

	self:AddFunction("gmod", "linkClick", function(linkId, text)
		local id, args = parseLink(linkId)

		if self.OnLinkClick then
			return self:OnLinkClick(id, text, unpack(args))
		end
		
		if self.callbacks[id] then
			self.callbacks[id](self, text, unpack(args))
		end
	end)

	self:AddFunction("gmod", "setClipboard", function(text)
		SetClipboardText(text or "")
	end)
end

function PANEL:AddLinkCallback(id, func)
	self.callbacks[id] = func
end

function PANEL:SetMergeMessages(on)
	self.lastMessageMerge = on

	if !self.lastMessageMerge then
		self.lastMessage = nil
		self.lastMessageCounter = 1
	end
end

function PANEL:RegisterFontFace(info)
	info = info or {}

	local family = info.family
	local path = info.src

	if !family or !path then
		return error("RegisterFontFace: requires family and src strings.")
	end

	local weight = info.weight or info.fontWeight
	local style = info.style or info.fontStyle
	local css = string.format("@font-face{font-family:%s;src:url(\"asset://garrysmod/%s\")", string.format("%q", family), path)

	if weight and tostring(weight) != "" then
		css = css .. ";font-weight:" .. escape_css_ident_token(weight)
	end

	if style and tostring(style) != "" then
		css = css .. ";font-style:" .. escape_css_ident_token(style)
	end

	css = css .. "}"

	self:QueueJavascript("registerFontFace(\"" .. string.JavascriptSafe(css) .. "\")")
end

function PANEL:SetDefaultFontSize(px)
	self:QueueJavascript("setFontSize(" .. math.max(px, 1) .. ")")
end

function PANEL:AddText(text)
	text = text or ""

	if #text <= 0 then return end

	if self.lastMessageMerge and self.lastMessage and text == self.lastMessage then
		self.lastMessageCounter = (self.lastMessageCounter or 1) + 1
		local display = text .. string.format(" <color=255,64,128><font=Counter>(x%d)</font></color>", self.lastMessageCounter)
		self:QueueJavascript("replaceLastLine(\"" .. string.JavascriptSafe(display) .. "\")")
		return
	end

	if self.lastMessageMerge then
		self.lastMessage = text
		self.lastMessageCounter = 1
	end

	self:QueueJavascript("appendLine(\"" .. string.JavascriptSafe(text) .. "\")")
end

function PANEL:Clear()
	self.lastMessage = nil
	self.lastMessageCounter = 1
	self:QueueJavascript("clearLog()")
end

function PANEL:ScrollToBottom()
	self:QueueJavascript("scrollToBottom()")
end

vgui.Register("ui.web.markup", PANEL, "DHTML")