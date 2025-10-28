local Reagents = ix.util.Lib("Reagents", {
	stored = {},
	solid = 1,
	liquid = 2,
	gas = 3,
	action = {
		touch = 1, // splashing
		ingest = 2, // ingestion
		vapor = 3, // foam, spray
		patch = 4, // patches
		inject = 5 // injection
	},
	holder = { // container flags
		injectable = 1, // Makes it possible to add reagents through droppers and syringes.
		drawable = 2, // Makes it possible to remove reagents through syringes.
		refillable = 4, // Makes it possible to add reagents through any reagent container.
		drainable = 8, // Makes it possible to remove reagents through any reagent container.
		transparent = 16, // Used on containers which you want to be able to see the reagents off.
		visible = 32, // For non-transparent containers that still have the general amount of reagents in them visible.
		noreact = 64, // Applied to a reagent holder, the contents will not react with each other.
		open = 28 // Is an open container for all intents and purposes.
	},
})


ix.util.Include("sh_reagent.class.lua")
ix.util.Include("sv_holder.class.lua")

function Reagents:All() return self.stored end
function Reagents:Get(uniqueID) return self.stored[uniqueID] end

function Reagents:New(uniqueID)
	local reagentClass = self.stored[uniqueID]

	if reagentClass then
		local reagent = setmetatable({data = {}}, {
			__index = reagentClass,
			__eq = reagentClass.__eq,
			__tostring = reagentClass.__tostring
		})

		return reagent
	else
		ErrorNoHalt("[Helix] Attempt to index unknown reagent '"..uniqueID.."'\n")
	end
end

do
	local FLAGS = ix.Reagents.holder

	function Reagents:IsRefillable(target)
		return (target.reagents or target.isReagentHolder) and bit.band(target.reagent_flags, FLAGS.refillable) == FLAGS.refillable
	end

	function Reagents:IsDrainable(target)
		return (target.reagents or target.isReagentHolder) and bit.band(target.reagent_flags, FLAGS.drainable) == FLAGS.drainable
	end

	function Reagents:IsDrawable(target)
		local flags = bit.band(target.reagent_flags, bit.bor(FLAGS.drawable, FLAGS.drainable))

		return (target.reagents or target.isReagentHolder) and ((flags == FLAGS.drainable) or (flags == FLAGS.drawable))
	end

	function Reagents:IsInjectable(target)
		local flags = bit.band(target.reagent_flags, bit.bor(FLAGS.injectable, FLAGS.refillable))

		return (target.reagents or target.isReagentHolder) and ((flags == FLAGS.refillable) or (flags == FLAGS.injectable))
	end

	function Reagents:IsOpenContainer(target)
		return self:IsRefillable(target) and self:IsDrainable(target)
	end
end

