local PLUGIN = PLUGIN
local FILE = class "Datafile"

function FILE:__tostring() return "datafile["..self:CharacterID().."]" end

function FILE:Init(info)
	self.vars = info

	self.vars.character_id = tonumber(info.character_id)
	self.vars.civil_status = tonumber(info.civil_status) or 1
	self.vars.points = tonumber(info.points) or 0
	self.vars.money = tonumber(info.money) or 0
	self.vars.created_at = tonumber(info.created_at) or 0
	self.vars.last_seen = tonumber(info.last_seen) or 0

	self.vars.data = istable(info.data) and info.data or (util.JSONToTable(info.data or "[]") or {})

	self.notes = {
		all = {},
		civil = {},
		medical = {}
	}
end

function FILE:CharacterID() return self.vars.character_id end
function FILE:CitizenID() return self.vars.citizen_id end

function FILE:GetName() return self.vars.character_name end
function FILE:GetCredits() return self.vars.money end
function FILE:GetSocialCredits() return self.vars.points end
function FILE:GetCivilStatus() return self.vars.civil_status end

function FILE:GetHouse() return self.vars.house end
function FILE:GetOccupation() return self.vars.job end