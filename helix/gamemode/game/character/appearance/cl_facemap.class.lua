/*
local bakeActive = false
local bakeQueue = {}

local function BakeFaceMap(name, data)
	file.Write("charface"..name..".png", data)
end

local function BakeProcessor()
	if #bakeQueue == 0 then
		hook.Remove("SlowThink", "facemap.bake")
		bakeActive = false
		return
	end

	local baker = bakeQueue[1]
	local success, err = coroutine.resume(baker)
	if !success then
		ErrorNoHalt(err)
		table.remove(bakeQueue, 1)
	elseif coroutine.status(baker) == "dead" then
		table.remove(bakeQueue, 1)
	end
end

local function AddToBakeQueue(name, data)
	local baker = coroutine.create(BakeFaceMap)

	coroutine.resume(baker, name, data)
	bakeQueue[#bakeQueue + 1] = baker

	if bakeActive then
		hook.Add("SlowThink", "facemap.bake", BakeProcessor)
		bakeActive = true
	end
end
*/

local dataFallback = {
	x = 2048,
	y = 2048,
	size = RT_SIZE_NO_CHANGE,
	depth = MATERIAL_RT_DEPTH_SEPARATE,
	textureFlags = TEXTUREFLAGS_ANISOTROPIC or 16,
	renderTargetFlags = CREATERENDERTARGETFLAGS_AUTOMIPMAP,
	format = IMAGE_FORMAT_RGBA8888
}
dataFallback.__index = dataFallback

local function CreateRenderTarget(name, data)
	data = data or {}
	setmetatable(data, dataFallback)

	return GetRenderTargetEx(name, data.x, data.y, data.size, data.depth, data.textureFlags, data.renderTargetFlags, data.format)
end

local MatCache = {}
local function CacheMateral(mat, pngFlags)
	local existing = MatCache[mat]
	if existing and not existing:IsError() then
		return existing
	else
		local newMat = Material(mat, pngFlags)
		MatCache[mat] = newMat
		return newMat
	end
end

local function BakeTexture(blend, key)
	local blendRT = CreateRenderTarget(blend.name)
	render.PushRenderTarget(blendRT)
		cam.Start2D()
		surface.DisableClipping(true)

		for k, v in ipairs(blend.textures) do

			if not v[key] then continue end

			local mat = CacheMateral(v[key])

			mat:SetFloat("$alpha", v.blend or 1)

			ix.DX.DrawMaterial(0, 0,0, 2048, 2048, Color(v.r or 255, v.g or 255, v.b or 255, 255 * v.blend), mat)
			mat:SetFloat("$alpha", 1)
		end

/*
		if !blend.noSave then
			local data = render.Capture({
				format = "png",
				x = 0,
				y = 0,
				w = 2048,
				h = 2048,
				alpha = false
			})

			AddToBakeQueue(blend.name, data)
		end*/

		cam.End2D()
	render.PopRenderTarget()
	
	surface.DisableClipping(false)
	return blendRT
end

local mask = Material("autonomous/humans/eyes/eye_iris_mask")
local base = Material("autonomous/humans/eyes/base_eye.png")
local iris = Material("autonomous/humans/eyes/base_iris.png")
local function BakeEyes(blend, key)
	blend.color = blend.color or color_white

	local blendRT = CreateRenderTarget(blend.name, {x = 256, y = 256})
	render.PushRenderTarget(blendRT)
		cam.Start2D()

		render.Clear(0, 0, 0, 0)

		ix.DX.DrawMaterial(0, 0, 0, 256, 256, color_white, base)
		ix.DX.DrawMaterial(0, 0, 0, 256, 256, Color(blend.color.r, blend.color.g, blend.color.b, 255), iris)
		
		render.OverrideColorWriteEnable(true, false)
			render.SetWriteDepthToDestAlpha(false)
				render.OverrideBlend(true, BLEND_SRC_COLOR, BLEND_SRC_ALPHA, BLENDFUNC_MIN)

				surface.SetMaterial(mask)
				surface.DrawTexturedRect(0, 0, 256, 256)

				render.OverrideBlend(false)
			render.SetWriteDepthToDestAlpha(true)
		render.OverrideColorWriteEnable(false)

		cam.End2D()
	render.PopRenderTarget()
	
	surface.DisableClipping(false)
	return blendRT
end

local FaceMap = class("FaceMap")
local CharGen = ix.CharGen

function FaceMap:Init(name, bundle)
	self.name = name
	self.bundle = bundle

	self.layers = {}
	self.blendLayers = {}
	self.colorLayers = {}

	self.faceMix = 0
	self.primary = nil
	self.secondary = nil

	self.eyeColor = color_white

	self._primaryTex = 0
	self._secondaryTex = 0
	self._layers = {}

	self.noSave = false
end

function FaceMap:GetPrimary() return self._primaryTex end
function FaceMap:GetSecondary() return self._secondaryTex end
function FaceMap:GetMix() return self.faceMix end

function FaceMap:SetPrimary(id)
	local faces = CharGen:GetOptions(self.bundle, CharGen.Option.FaceMap)

	if faces and faces[id] then
		self.primary = faces[id].tex
		self._primaryTex = id
	end
end

function FaceMap:SetSecondary(id)
	local faces = CharGen:GetOptions(self.bundle, CharGen.Option.FaceMap)

	if faces and faces[id] then
		self.secondary = faces[id].tex
		self._secondaryTex = id
	end
end

function FaceMap:SetMix(value)
	self.faceMix = math.Clamp(value, 0, 1)
end

function FaceMap:SetLayer(id, option, index)
	local textures = CharGen:GetOptions(self.bundle, option)

	if textures and textures[index] then
		self.layers[id] = textures[index]
		self._layers[id] = index
	else
		self.layers[id] = nil
		self._layers[id] = 0
	end
end

function FaceMap:SetLayerBlend(id, value)
	self.blendLayers[id] = math.Clamp(value, 0, 1)
end

function FaceMap:SetLayerColor(id, clr)
	self.colorLayers[id] = clr
end

function FaceMap:SetEyeColor(clr)
	self.eyeColor = clr
end

function FaceMap:GenerateEyes(callback)
	local data = {
		name = "eyes_"..self.name,
		color = self.eyeColor,
		noSave = self.noSave
	}

	if callback then
		local hookName = "facemap.eyes."..self.name

		hook.Add("PreRender", hookName, function()
			hook.Remove("PreRender", hookName)

			local texture = BakeEyes(data, "$basetexture")

			callback(texture)
		end)
	else
		return BakeEyes(data, "$basetexture")
	end
end

function FaceMap:Generate(callback)
	local textures = {}

	if self.primary then
		textures[#textures + 1] = {["$basetexture"] = self.primary, blend = 1}
	end

	if self.secondary then
		textures[#textures + 1] = {["$basetexture"] = self.secondary, blend = self.faceMix and self.faceMix or 0}
	end

	for k, v in pairs(self.layers) do
		local info = {}
		info["$basetexture"] = v.tex
		info.blend = self.blendLayers[k] and self.blendLayers[k] or 0

		if self.colorLayers[k] then
			info.r = self.colorLayers[k].r
			info.g = self.colorLayers[k].g
			info.b = self.colorLayers[k].b
		else
			if v.color then
				info.r = v.color.r
				info.g = v.color.g
				info.b = v.color.b
			end
		end

		textures[#textures + 1] = info
	end

	local data = {
		name = "facemap_"..self.name,
		textures = textures,
		noSave = self.noSave
	}

	if callback then
		local hookName = "facemap."..self.name

		hook.Add("PreRender", hookName, function()
			hook.Remove("PreRender", hookName)

			local texture = BakeTexture(data, "$basetexture")

			callback(texture)
		end)
	else
		return BakeTexture(data, "$basetexture")
	end
end