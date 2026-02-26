local RACE = abstract_class "Race"

RACE.id = "unknown"

function RACE:__tostring() return "Race["..self.id.."]" end

RACE.Name = ""
RACE.Description = ""
RACE.Color = Color(255, 255, 255)
RACE.PlayerClass = "player_sandbox" -- in case of unique movement behaviour
RACE.Body = "humanlike_female" -- limbs and organs tree
RACE.Default = false
--character creation and visual related
--racial bonuses
