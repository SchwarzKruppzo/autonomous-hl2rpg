--ix.util.Include("body/sh_bodytypes.lua")
--ix.util.Include("race/sh_race.lua")

-- Character Appearance
ix.util.Include("appearance/sh_chargen.lua") -- character customization database (facemaps & selectable bodygroups)
ix.util.Include("appearance/sh_appearance.lua") -- clothing display database & model settings for layers

ix.util.Include("appearance/cl_facemap.class.lua") -- facemap texture generator
ix.util.Include("appearance/sh_outfit.class.lua") -- class that handles visuals for player clothes (bodygroups, layers logic, clientside parts)
ix.util.Include("appearance/sh_chargen.class.lua") -- character class stores customization settings and its synchronization
