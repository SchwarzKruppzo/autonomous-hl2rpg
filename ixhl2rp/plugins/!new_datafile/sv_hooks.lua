local PLUGIN = PLUGIN

PLUGIN.stored = PLUGIN.stored or {}

function PLUGIN:LoadData()
	local query = mysql:Create("datafiles")
		query:Create("character_id", "INT(11) UNSIGNED NOT NULL")
		query:Create("character_name", "TEXT DEFAULT NULL")
		query:Create("citizen_id", "VARCHAR(5) DEFAULT NULL")
		query:Create("dna", "VARCHAR(32) DEFAULT NULL")
		query:Create("job", "TEXT NOT NULL")
		query:Create("house", "TEXT DEFAULT NULL")
		query:Create("civil_status", "TINYINT NOT NULL")
		query:Create("points", "INT(11) NOT NULL")
		query:Create("money", "INT(11) UNSIGNED NOT NULL")
		query:Create("create_time", "INT(11) UNSIGNED NOT NULL")
		query:Create("last_seen", "INT(11) UNSIGNED NOT NULL")
		query:Create("data", "TEXT DEFAULT NULL")
		query:PrimaryKey("character_id")
	query:Execute()

	local query = mysql:Create("datafiles_notes")
		query:Create("id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
		query:Create("character_id", "INT(11) UNSIGNED NOT NULL")
		query:Create("poster_id", "INT(11) UNSIGNED NOT NULL")
		query:Create("poster_name", "TEXT DEFAULT NULL")
		query:Create("category", "TINYINT NOT NULL")
		query:Create("text", "TEXT DEFAULT NULL")
		query:Create("timestamp", "INT(11) UNSIGNED NOT NULL")
		query:PrimaryKey("id")
	query:Execute()

	local query = mysql:Create("datafiles_transactions")
		query:Create("id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
		query:Create("receiver_id", "INT(11) UNSIGNED DEFAULT NULL")
		query:Create("sender_id", "INT(11) UNSIGNED DEFAULT NULL")
		query:Create("receiver_name", "TEXT DEFAULT NULL")
		query:Create("sender_name", "TEXT DEFAULT NULL")
		query:Create("reason", "TEXT DEFAULT NULL")
		query:Create("amount", "INT NOT NULL")
		query:Create("timestamp", "INT(11) UNSIGNED NOT NULL")
		query:PrimaryKey("id")
	query:Execute()

	local query = mysql:Create("datafiles_messages")
		query:Create("id", "INT(11) UNSIGNED NOT NULL AUTO_INCREMENT")
		query:Create("receiver_id", "INT(11) UNSIGNED DEFAULT NULL")
		query:Create("sender_id", "INT(11) UNSIGNED DEFAULT NULL")
		query:Create("sender_name", "TEXT DEFAULT NULL")
		query:Create("text", "TEXT DEFAULT NULL")
		query:Create("title", "TEXT DEFAULT NULL")
		query:Create("timestamp", "INT(11) UNSIGNED NOT NULL")
		query:PrimaryKey("id")
	query:Execute()
end

-- preload datafiles
function PLUGIN:CharacterRestored(character)
	local id = character:GetID()
	local file = ix.Datafile:Get(id)

	if file then
		character.datafile = file
		return
	end
	
	local query = mysql:Select("datafiles")
		query:Select("character_id")
		query:Select("character_name")
		query:Select("citizen_id")
		query:Select("dna")
		query:Select("job")
		query:Select("house")
		query:Select("civil_status")
		query:Select("points")
		query:Select("money")
		query:Select("create_time")
		query:Select("last_seen")
		query:Select("data")
		query:Where("character_id", id)
		query:Limit(1)
		query:Callback(function(result)
			if istable(result) and #result > 0 then
				local info = result[1]

				character.datafile = ix.Datafile:Preload(info)
			else
				character.noDatafile = true
			end
		end)
	query:Execute()
end

function PLUGIN:OnCharacterCreated(client, character)
	character.noDatafile = true
end












