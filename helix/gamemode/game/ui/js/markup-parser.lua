return [=[
function parseTagBody(body){
	body=(body||"").replace(/^\s+|\s+$/g,"");
	if(!body)return null;
	if(body.charAt(0)==="/")return{type:"close",name:body.slice(1).replace(/^\s+|\s+$/g,"").toLowerCase()};
	var eq=body.indexOf("=");
	if(eq!==-1)return{type:"open",name:body.slice(0,eq).replace(/^\s+|\s+$/g,"").toLowerCase(),val:body.slice(eq+1).replace(/^\s+|\s+$/g,"")};
	return{type:"bare",name:body.toLowerCase()};
}
function colourToCss(param){
	param=(param||"").replace(/^\s+|\s+$/g,"");
	var m=param.match(/^(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*(\d+))?$/);
	if(m)return"rgb("+m[1]+","+m[2]+","+m[3]+")";
	m=param.match(/^(\d+)\s*,\s*(\d+)\s*,\s*(\d+)$/);
	if(m)return"rgb("+m[1]+","+m[2]+","+m[3]+")";
	var named=COLOURMAP[param.toLowerCase()];
	if(named)return"rgb("+named.r+","+named.g+","+named.b+")";
	return"rgb(255,255,255)";
}
function applyOutlineStyle(span,val){
	var col="rgb(0,0,0)";
	if(val&&String(val).length){
		col=colourToCss(val);
	}
	var parts=[];
	for(var k=0;k<20;k++){
		parts.push("0px 0px 1px "+col);
	}
	span.style.textShadow=parts.join(",");
}
function normalizeMaterialPath(path){
	path=path.replace(/\\/g,"/").replace(/^\/+/,"");
	var segs=path.split("/"),out=[];
	for(var i=0;i<segs.length;i++){
		var p=segs[i];
		if(!p||p===".")continue;
		if(p==="..")return null;
		out.push(p);
	}
	return out.join("/");
}
function imgFromParam(val){
	var comma=val.indexOf(",");
	var material=comma===-1?val.replace(/^\s+|\s+$/g,""):val.slice(0,comma).replace(/^\s+|\s+$/g,"");
	var sizePart=comma===-1?"":val.slice(comma+1).replace(/^\s+|\s+$/g,"");
	if(!material){
		var e=document.createElement("span");e.className="m-img-error";e.textContent="[img]";return e;
	}
	if(material.indexOf("..")!==-1){
		var e2=document.createElement("span");e2.className="m-img-error";e2.textContent="[img:invalid path]";return e2;
	}
	var norm=normalizeMaterialPath(material);
	if(!norm){
		var e3=document.createElement("span");e3.className="m-img-error";e3.textContent="[img:invalid path]";return e3;
	}
	if(!/\.[a-zA-Z0-9]+$/.test(norm))norm+=".png";
	var w=16,h=16;
	if(sizePart){
		var sm=sizePart.match(/^(\d+)\s*[xX]\s*(\d+)$/);
		if(sm){w=parseInt(sm[1],10)||16;h=parseInt(sm[2],10)||16;}
	}
	var img=document.createElement("img");
	img.className="m-img";
	img.alt="";
	img.width=w;
	img.height=h;
	img.src="asset://garrysmod/materials/"+norm;
	return img;
}
function legacyImgFromParam(val){
	val=(val||"").replace(/^\s+|\s+$/g,"");
	if(!val){
		var e0=document.createElement("span");e0.className="m-img-error";e0.textContent="[legacyimg]";return e0;
	}
	var url=val,scale=1;
	var lc=val.lastIndexOf(",");
	if(lc!==-1){
		var tail=val.slice(lc+1).replace(/^\s+|\s+$/g,"");
		if(/^[0-9]+(\.[0-9]+)?$/.test(tail)){
			url=val.slice(0,lc).replace(/^\s+|\s+$/g,"");
			scale=parseFloat(tail);
			if(isNaN(scale)||scale<=0)scale=1;
		}
	}
	scale=Math.max(0.05,Math.min(10,scale));
	if(!/^https?:\/\//i.test(url)||/^data:/i.test(url)||/javascript\s*:/i.test(url)){
		var e1=document.createElement("span");e1.className="m-img-error";e1.textContent="[legacyimg:bad url]";return e1;
	}
	var im=document.createElement("img");
	im.className="m-img m-img-legacy";
	im.alt="";
	im.draggable=false;
	function applyScaledSize(){
		var w=im.naturalWidth,h=im.naturalHeight;
		if(w&&h){
			im.style.width=(w*scale)+"px";
			im.style.height=(h*scale)+"px";
		}
	}
	im.onload=applyScaledSize;
	im.onerror=function(){
		im.alt="[legacyimg:load error]";
		im.style.maxWidth="128px";
	};
	im.src=url;
	if(im.complete&&im.naturalWidth){
		applyScaledSize();
	}
	return im;
}
function decodeTextEscapes(text){
	if(!text)return"";
	var out="",p=0,len=text.length;
	while(p<len){
		if(text.charAt(p)==="\\"&&p+1<len){
			var nx=text.charAt(p+1);
			if(nx==="<"){out+="<";p+=2;continue;}
			if(nx===">"){out+=">";p+=2;continue;}
			if(nx==="\\"){out+="\\";p+=2;continue;}
		}
		out+=text.charAt(p);
		p++;
	}
	return out;
}
function findNextUnescapedLt(s,start){
	for(var j=start;j<s.length;j++){
		if(s.charAt(j)!=="<")continue;
		var bs=0;
		for(var k=j-1;k>=0&&s.charAt(k)==="\\";k--)bs++;
		if(bs%2===0)return j;
	}
	return -1;
}
function appendTextWithNewlines(parent,text){
	if(text==="")return;
	text=decodeTextEscapes(text);
	var parts=text.split("\n");
	for(var i=0;i<parts.length;i++){
		if(i>0)parent.appendChild(document.createElement("br"));
		if(parts[i]!=="")parent.appendChild(document.createTextNode(parts[i]));
	}
}
function closeNameToKind(cn){
	if(cn==="face")return"font";
	if(cn==="colour")return"color";
	if(cn==="i")return"italic";
	return cn;
}
function parseMarkupToLine(ml){
	var line=document.createElement("div");
	line.className="m-line";
	var scopeStack=[];
	var kindStack=[];
	var current=line;
	var i=0,len=ml.length;
	function pushOpen(el,kind){
		current.appendChild(el);
		scopeStack.push(current);
		kindStack.push(kind);
		current=el;
	}
	function tryClose(closeRaw){
		var want=closeNameToKind(closeRaw);
		if(kindStack.length===0||kindStack[kindStack.length-1]!==want)return;
		kindStack.pop();
		current=scopeStack.pop();
	}
	while(i<len){
		var lt=findNextUnescapedLt(ml,i);
		if(lt===-1){
			appendTextWithNewlines(current,ml.slice(i));
			break;
		}
		if(lt>i)appendTextWithNewlines(current,ml.slice(i,lt));
		var gt=ml.indexOf(">",lt+1);
		if(gt===-1){
			appendTextWithNewlines(current,ml.slice(lt));
			break;
		}
		var tagbody=ml.slice(lt+1,gt);
		var parsed=parseTagBody(tagbody);
		if(parsed&&parsed.type==="close"){
			var cn=parsed.name;
			if(cn==="font"||cn==="face")tryClose(cn);
			else if(cn==="color"||cn==="colour")tryClose(cn);
			else if(cn==="link")tryClose("link");
			else if(cn==="size")tryClose("size");
			else if(cn==="b")tryClose("b");
			else if(cn==="italic"||cn==="i")tryClose(cn);
			else if(cn==="outline")tryClose("outline");
			else if(cn==="img"||cn==="legacyimg"){}
			else appendTextWithNewlines(current,"<"+tagbody+">");
		}else if(parsed&&parsed.type==="open"){
			var name=parsed.name,val=decodeTextEscapes(parsed.val||"");
			if(name==="font"||name==="face"){
				var s=document.createElement("span");s.style.fontFamily=val+", sans-serif";pushOpen(s,"font");
			}else if(name==="color"||name==="colour"){
				var s2=document.createElement("span");s2.style.color=colourToCss(val);pushOpen(s2,"color");
			}else if(name==="link"){
				var s3=document.createElement("span");s3.className="m-link";s3.setAttribute("data-link-id",val);pushOpen(s3,"link");
			}else if(name==="size"){
				var n=parseInt(val,10);
				if(isNaN(n))n=14;
				var sz=document.createElement("span");sz.style.fontSize=n+"px";pushOpen(sz,"size");
			}else if(name==="b"){
				var wEl=document.createElement("span");wEl.style.fontWeight="bold";pushOpen(wEl,"b");
			}else if(name==="italic"){
				var it=document.createElement("span");it.style.fontStyle="italic";pushOpen(it,"italic");
			}else if(name==="outline"){
				var ou=document.createElement("span");applyOutlineStyle(ou,val);pushOpen(ou,"outline");
			}else if(name==="img"){
				current.appendChild(imgFromParam(val));
			}else if(name==="legacyimg"){
				current.appendChild(legacyImgFromParam(val));
			}else appendTextWithNewlines(current,"<"+tagbody+">");
		}else if(parsed&&parsed.type==="bare"){
			var bn=parsed.name;
			if(bn==="italic"||bn==="i"){
				var bi=document.createElement("span");bi.style.fontStyle="italic";pushOpen(bi,"italic");
			}else if(bn==="outline"){
				var bo=document.createElement("span");applyOutlineStyle(bo,"");pushOpen(bo,"outline");
			}else if(bn==="b"){
				var bx=document.createElement("span");bx.style.fontWeight="bold";pushOpen(bx,"b");
			}else appendTextWithNewlines(current,"<"+tagbody+">");
		}else appendTextWithNewlines(current,"<"+tagbody+">");
		i=gt+1;
	}
	while(kindStack.length){
		kindStack.pop();
		current=scopeStack.pop();
	}
	return line;
}
function appendLine(markup){
	var line = parseMarkupToLine(markup);
	logEl.appendChild(line);
	
	scrollToBottom();
}
function replaceLastLine(markup){
	var line = logEl.lastElementChild;
	if (!line) {
		appendLine(markup);
		return;
	}

	var fresh = parseMarkupToLine(markup);
	line.innerHTML="";

	while (fresh.firstChild) {
		line.appendChild(fresh.firstChild);
	}

	scrollToBottom();
}
]=]