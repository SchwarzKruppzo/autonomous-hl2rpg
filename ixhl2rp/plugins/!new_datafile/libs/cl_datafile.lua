// Clientside Datafile

local FILE = ix.util.Lib("Datafile", {
	char = 0,
	name = "N/A",
	cid = "N/A",
	house = "N/A",
	job = "N/A",
	money = 0,
	points = 0,
	loyalty = 1,
	data = {}
})

function FILE:Setup(info)
	for k, v in pairs(info) do
		self[k] = v
	end
end

function FILE:CharacterID() return self.char end
function FILE:CitizenID() return self.cid end

function FILE:GetName() return self.name end
function FILE:GetCredits() return self.money end
function FILE:GetSocialCredits() return self.points end
function FILE:GetCivilStatus() return self.loyalty end

function FILE:GetHouse() return self.house end
function FILE:GetOccupation() return self.job end

function FILE:GetData() return self.data end