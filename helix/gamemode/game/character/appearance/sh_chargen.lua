local CharGen = ix.util.Lib("CharGen", {
	Option = {
		FaceMap = 1,
		HairScalp = 2,
		Lips = 3,
		Makeup = 4
	},
	
	_models = {},
})

CharGen.Atlas = {}
CharGen.FaceMorph = {}
CharGen.TextureLayers = {}

function CharGen:RegisterClass(class)
	local bundle = {}

	for k, v in pairs(self.Option) do
		bundle[v] = {}
	end

	self.Atlas[class] = bundle

	return self.Atlas[class]
end

function CharGen:AddFaceMorph(class, index, name, flexID, leftEye, rightEye)
	local bundle = self.FaceMorph[class] or {}

	bundle[index] = {
		id = index,
		title = name,
		flex = flexID,
		eyes = {
			left = leftEye or vector_origin,
			right = rightEye or vector_origin,
		}
	}

	self.FaceMorph[class] = bundle
end

function CharGen:GetFaceMorphs(class)
	local bundle = self.FaceMorph[class]

	return bundle
end

function CharGen:AddTextureLayer(class, optionBundle, priority, name)
	local layers = self.TextureLayers[class] or {}

	layers[#layers + 1] = {
		option = optionBundle, 
		priority = priority, 
		title = name
	}

	table.sort(layers, function(a, b) return a.priority > b.priority end)

	self.TextureLayers[class] = layers
end

function CharGen:GetTextureLayers(class)
	local layers = self.TextureLayers[class] or {}

	return layers
end

function CharGen:AddOption(class, option, index, name, texture, color)
	local bundle = self.Atlas[class] or self:RegisterClass(class)

	if !bundle[option] then return end
	
	bundle[option][index] = {
		id = index,
		title = name,
		tex = "autonomous/chargen/"..class.."/" .. texture .. ".png",
		color = color
	}

	self.Atlas[class] = bundle
end

function CharGen:GetOptions(class, option)
	local bundle = self.Atlas[class]

	if !bundle or !bundle[option] then 
		return 
	end
	
	return bundle[option]
end

function CharGen:IsValid(class, option, index)
	local bundle = self.Atlas[class]

	if !bundle or !bundle[option] then 
		return false
	end
	
	local option = bundle[option]

	if !option then
		return false
	end
	
	return option[index]
end

function CharGen:SetModelClass(model, class)
	self._models[model:lower()] = class
end

function CharGen:GetModelClass(model)
	return self._models[model:lower()]
end

CharGen:AddTextureLayer("female", CharGen.Option.HairScalp, 1, "Hair Scalp")
CharGen:AddTextureLayer("female", CharGen.Option.Lips, 1, "Lipstick")
CharGen:AddTextureLayer("female", CharGen.Option.Makeup, 1, "Makeup")

CharGen:AddOption("female", CharGen.Option.FaceMap, 1, "Base", "facemap/base")
CharGen:AddOption("female", CharGen.Option.FaceMap, 2, "Female01", "facemap/female01")
CharGen:AddOption("female", CharGen.Option.FaceMap, 3, "Ada Wong", "facemap/wong_hd")
CharGen:AddOption("female", CharGen.Option.FaceMap, 4, "Firefly", "facemap/firefly2")
CharGen:AddOption("female", CharGen.Option.FaceMap, 5, "Claire Redfield", "facemap/claire")


CharGen:AddOption("female", CharGen.Option.HairScalp, 1, "Wong", "scalp/hair_wong")
CharGen:AddOption("female", CharGen.Option.HairScalp, 2, "Claire", "scalp/hair_claire")
CharGen:AddOption("female", CharGen.Option.HairScalp, 3, "Firefly", "scalp/hair_firefly")
CharGen:AddOption("female", CharGen.Option.HairScalp, 4, "Hair Scalp 1", "scalp/hair_black")

CharGen:AddOption("female", CharGen.Option.Lips, 1, "Lipstick 1", "lips/lips1", Color(255, 0, 0))
CharGen:AddOption("female", CharGen.Option.Makeup, 1, "Makeup 1", "makeup/eyedark")

CharGen:AddFaceMorph("female", 1, "Female01", 0, Vector(0.05, 0, 0.125), Vector(0.05, 0, -0.075))
CharGen:AddFaceMorph("female", 2, "Ada Wong", 1, Vector(-0.01, 0, 0.05), Vector(0, 0, 0))
CharGen:AddFaceMorph("female", 3, "Firefly", 4, Vector(0.02, 0, 0.1), Vector(0.02, 0, -0.1))
CharGen:AddFaceMorph("female", 4, "Claire", 5, Vector(-0.05, 0, 0.15), Vector(-0.05, 0, -0.05))

CharGen:SetModelClass("models/autonomous/base_female.mdl", "female")