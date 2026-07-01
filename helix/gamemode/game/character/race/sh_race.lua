local Races = ix.util.Lib("Races", {
	stored = {},
	stored_id = {},
}

ix.util.Include("sh_race.class.lua")

function Races:All()
	return self.stored_id
end

function Races:ID(class)
	return self.stored[class]
end

function Races:Get(id)
	return self.stored_id[id]
end

function Races:Load()
	--ix.Pipeline:IncludeDir("race", "helix/gamemode/game/character/race/races")
end
