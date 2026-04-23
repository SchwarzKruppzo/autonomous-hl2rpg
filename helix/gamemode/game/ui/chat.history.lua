local PANEL = {}

AccessorFunc(PANEL, "filter", "Filter") -- blacklist of message classes
AccessorFunc(PANEL, "id", "ID", FORCE_STRING)
AccessorFunc(PANEL, "button", "Button") -- button panel that this panel corresponds to

PANEL.customStyle = [=[
html, body {
	overflow: hidden;
	margin: 2px;
}

#log {
	box-sizing: border-box;
	width: 100%;
	height: 100%;
	min-height: 0 !important;
	overflow-y: auto !important;
	overflow-x: hidden !important;
	display: flex;
	flex-direction: column;
	justify-content: flex-end;
	align-items: stretch;
	background: transparent !important;
	-webkit-user-select: none;
}
#log .m-line {
	flex-shrink: 0;
}
#log .m-line.overlay-hidden {
	opacity: 0 !important;
	visibility: hidden;
	max-height: 0 !important;
	margin: 0 !important;
	padding: 0 !important;
	overflow: hidden;
	line-height: 0;
}
html.history-open #log {
	justify-content: flex-start !important;
	-webkit-user-select: text;
}
html.history-open #log .m-line,
html.history-open #log .m-line.overlay-hidden {
	opacity: 1 !important;
	visibility: visible !important;
	max-height: none !important;
	margin: 0 0 0px 0 !important;
	line-height: auto !important;
	overflow: visible !important;
	overflow-x: auto !important;
}
*::-webkit-scrollbar {
	width: 5px;
	height: 5px;
}
*::-webkit-scrollbar-button {
	display: none;
	width: 0;
	height: 0;
}
*::-webkit-scrollbar-corner {
	background: transparent;
}
*::-webkit-scrollbar-track {
	background: rgba(0, 190, 255, 0.1);
}
*::-webkit-scrollbar-thumb {
	background: rgba(0, 190, 255, 0.5);
	border-radius: 0; /* прямоугольник */
	border: none;
}
*::-webkit-scrollbar-thumb:hover {
	background: rgb(32, 160, 190);
}
]=]

PANEL.customScript = [=[
var historyMode=false;
var lifeMs=15000,fadeMs=500;
function setChatHudTimings(l,f){
	lifeMs=l;
	fadeMs=f;
}
function clearLineFadeTimers(line){
	if(line._ch2ft1){clearTimeout(line._ch2ft1);line._ch2ft1=null;}
	if(line._ch2ft2){clearTimeout(line._ch2ft2);line._ch2ft2=null;}
}
function scheduleOverlayFadeForLine(line){
	clearLineFadeTimers(line);
	if(historyMode||!line.parentNode)return;
	var t0=parseInt(line.getAttribute("data-created"),10)||Date.now();
	var elapsed=Date.now()-t0;
	var waitHide=Math.max(0,lifeMs-elapsed);
	line.classList.remove("overlay-hidden");
	line.style.opacity="1";
	line.style.transition="";
	line._ch2ft1=setTimeout(function(){
		if(historyMode||!line.parentNode)return;
		line.style.transition="opacity "+(fadeMs/1000)+"s ease";
		line.style.opacity="0";
		line._ch2ft2=setTimeout(function(){
			if(historyMode||!line.parentNode)return;
			line.classList.add("overlay-hidden");
			line.style.opacity="0";
			line.style.transition="";
		},fadeMs);
	},waitHide);
}
function applyOverlayExitRules(){
	var now=Date.now();
	var total=lifeMs+fadeMs;
	var lines=logEl.querySelectorAll(".m-line");
	for(var i=0;i<lines.length;i++){
		var line=lines[i];
		line.classList.remove("overlay-hidden");
		line.style.opacity="";
		line.style.transition="";
		clearLineFadeTimers(line);
		var tc=parseInt(line.getAttribute("data-created"),10)||0;
		if(!tc)continue;
		var elapsed=now-tc;
		if(elapsed>=total){
			line.classList.add("overlay-hidden");
		}else{
			scheduleOverlayFadeForLine(line);
		}
	}
}
window.setChatHistoryMode=function(on){
	historyMode=!!on;
	var root=document.documentElement;
	if(historyMode){
		root.classList.add("history-open");

		requestAnimationFrame(function () {
			logEl.scrollTop = logEl.scrollHeight;
		});

		var ls=logEl.querySelectorAll(".m-line");
		for(var j=0;j<ls.length;j++){
			clearLineFadeTimers(ls[j]);
			ls[j].classList.remove("overlay-hidden");
			ls[j].style.opacity="";
			ls[j].style.transition="";
		}
	}else{
		root.classList.remove("history-open");
		applyOverlayExitRules();
	}
};
var _ch2Append0=appendLine;
appendLine=function(text){
	_ch2Append0(text);
	var line=logEl.lastElementChild;
	if(!line)return;
	line.setAttribute("data-created",String(Date.now()));
	if(!historyMode)scheduleOverlayFadeForLine(line);
};
var _ch2Replace0=replaceLastLine;
replaceLastLine=function(text){
	var prevLine=logEl.lastElementChild;
	var prevCreated=prevLine?prevLine.getAttribute("data-created"):null;
	_ch2Replace0(text);
	if(prevLine&&logEl.lastElementChild===prevLine){
		if(prevCreated)prevLine.setAttribute("data-created",prevCreated);
		if(!historyMode)scheduleOverlayFadeForLine(prevLine);
	}
};
]=]

function PANEL:Init()
	self.active = false

	self:SetPaintedManually(true)
	self:SetActive(false)
	self:SetMergeMessages(true)

	self.filter = {}
end

function PANEL:OnLinkClick(id, message, ...)
	local args = { ... }
	local callback = ix.chat.links[id]

	if callback then
		callback(message, unpack(args))
	end
end

-- when true, all lines are visible
function PANEL:SetActive(isActive)
	self.active = isActive

	self:QueueJavascript("setChatHistoryMode(" .. (isActive and "true" or "false") .. ");")
end

function PANEL:GetActive()
	return self.active
end

function PANEL:SetFadeLifeTime(fadeTime, lifeTime)
	local lifeTime = math.floor((lifeTime or 6) * 1000)
	local fadeTime = math.floor((fadeTime or 0.4) * 1000)

	self:QueueJavascript(string.format("setChatHudTimings(%d, %d);", lifeTime, fadeTime))
end

function PANEL:AddLine(elements, bShouldScroll)
	-- table.concat is faster than regular string concatenation where there are lots of strings to concatenate
	local buffer = {
		"<font=Chat>"
	}

	if CHAT_CLASS_STYLE.size then
		buffer[#buffer + 1] = string.format("<size=%d>", CHAT_CLASS_STYLE.size)
	end

	if CHAT_CLASS_STYLE.italic then
		buffer[#buffer + 1] = "<i>"
	end

	if CHAT_CLASS_STYLE.bold then
		buffer[#buffer + 1] = "<b>"
	end

	if ix.option.Get("chatTimestamps", false) then
		buffer[#buffer + 1] = "<color=150,150,150>("

		if ix.option.Get("hour24Time", false) then
			buffer[#buffer + 1] = os.date("%H:%M")
		else
			buffer[#buffer + 1] = os.date("%I:%M %p")
		end

		buffer[#buffer + 1] = ") "
	end

	for _, v in ipairs(elements) do
		if type(v) == "IMaterial" then
			local texture = v:GetName()

			if (texture) then
				buffer[#buffer + 1] = string.format("<img=%s,%dx%d> ", texture, v:Width(), v:Height())
			end
		elseif istable(v) and v.r and v.g and v.b then
			buffer[#buffer + 1] = string.format("<color=%d,%d,%d>", v.r, v.g, v.b)
		elseif type(v) == "Player" then
			local color = team.GetColor(v:Team())

			buffer[#buffer + 1] = string.format("<color=%d,%d,%d><link=player:%s>%s</link", color.r, color.g, color.b,
				v:GetCharacter():GetID(),v:GetName():gsub("<", "&lt;"):gsub(">", "&gt;"))
		elseif istable(v) and v.link then
			buffer[#buffer + 1] = v:parse()
		else
			buffer[#buffer + 1] = tostring(v):gsub("%b**", function(value)
				local inner = value:utf8sub(2, -2)

				if (inner:find("%S")) then
					return "<i>" .. value:utf8sub(2, -2) .. "</i>"
				end
			end)
		end
	end

	buffer[#buffer + 1] = "</font>"

	local buff = table.concat(buffer)

	self:AddText("<outline>" .. buff)
end

function PANEL:OnFocusChanged(gained)
	if !gained then
		self:QueueJavascript("window.getSelection().removeAllRanges()")
	end
end

vgui.Register("ui.chat.history", PANEL, "ui.web.markup")