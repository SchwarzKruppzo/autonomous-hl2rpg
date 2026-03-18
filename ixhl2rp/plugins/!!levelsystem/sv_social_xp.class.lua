local ChatXPService = class("ChatXPService")

local function GetPlayerId(ply)
	if !IsValid(ply) then
		return
	end

	return ply:SteamID64() or ply:SteamID()
end

local function NormalizeText(text)
	text = tostring(text or "")
	text = string.utf8lower(text)
	text = text:gsub("[%c%p]", " ")
	text = text:gsub("%s+", " ")
	text = string.Trim(text)
	return text
end

local function GetBucket(map, id, now, window)
	local b = map[id]

	if !b or (now - b.start) >= window then
		b = {start = now, xp = 0}
		map[id] = b
	end

	return b
end

function ChatXPService:Init(config)
	self.config = config or {}

	self._lastPairAward = {} -- [speakerId][listenerId] = time
	self._listenerMinute = {} -- [listenerId] = {start=t, xp=n}
	self._listenerHour = {} -- [listenerId] = {start=t, xp=n}
	self._speakerRecent = {} -- [speakerId] = {{t=t, text=norm}, ...}
	self._lastActive = {} -- [playerId] = time (IC activity)
end

function ChatXPService:StoreRecentMessage(speakerId, now, normalized)
	local maxRecent = self.config.maxRecentMessages or 10
	local recent = self._speakerRecent[speakerId] or {}
	self._speakerRecent[speakerId] = recent

	recent[#recent + 1] = {t = now, text = normalized}

	local extra = #recent - maxRecent
	if extra > 0 then
		for i = 1, extra do
			table.remove(recent, 1)
		end
	end
end

function ChatXPService:CheckDuplicateMessage(speakerId, now, normalized)
	local window = self.config.dupWindowSec or 120
	local recent = self._speakerRecent[speakerId]

	if !recent then
		return false
	end

	for i = #recent, 1, -1 do
		local entry = recent[i]

		if (now - entry.t) > window then
			break
		end

		if entry.text == normalized then
			return true
		end
	end

	return false
end

function ChatXPService:ComputeMessageXP(len)
	local base = self.config.baseXP or 4
	local perLen = self.config.bonusPerLen or 80
	local maxBonus = self.config.maxBonus or 3

	local bonus = 0
	if perLen > 0 then
		bonus = math.floor(len / perLen)
	end

	bonus = math.Clamp(bonus, 0, maxBonus)
	return base + bonus
end

function ChatXPService:Evaluate(speaker, listener, chatType, text, time)
	local cfg = self.config

	if !IsValid(speaker) or !IsValid(listener) then
		return false, 0 -- invalid entities
	end

	if speaker == listener then
		return false, 0 -- same person
	end

	local speakerId = GetPlayerId(speaker)
	local listenerId = GetPlayerId(listener)

	if not speakerId or not listenerId then
		return false, 0 -- missing ids
	end

	if cfg.blacklist and cfg.blacklist[chatType] then
		return false, 0 -- blacklisted_type
	end

	-- mark speaker as active on eligible chat types
	if cfg.activeChatTypes and cfg.activeChatTypes[chatType] then
		self._lastActive[speakerId] = time
	end

	-- anti-afk for listener: must have spoken recently
	if cfg.requireActiveListener then
		local last = self._lastActive[listenerId] or 0
		if (time - last) > (cfg.activeWindowSec or 180) then
			return false, 0 -- inactive listener
		end
	end

	text = text or ""
	local len = string.utf8len(text) or 0
	if len < (cfg.minLen or 50) then
		return false, 0 -- too short
	end

	-- pair cooldown
	local pairCooldown = cfg.pairCooldownSec or 25
	if pairCooldown > 0 then
		self._lastPairAward[speakerId] = self._lastPairAward[speakerId] or {}
		local lastPair = self._lastPairAward[speakerId][listenerId] or 0
		if (time - lastPair) < pairCooldown then
			return false, 0 -- pair cooldown
		end
	end

	-- duplicate protection
	local normalized = NormalizeText(text)
	if #normalized > 0 then
		if self:CheckDuplicateMessage(speakerId, time, normalized) then
			return false, 0 -- duplicate
		end
	end

	-- caps
	local capPerMinute = cfg.capPerMinute or 10
	if capPerMinute > 0 then
		local b = GetBucket(self._listenerMinute, listenerId, time, 60)
		if b.xp >= capPerMinute then
			return false, 0 -- capPerMinute
		end
	end

	local capPerHour = cfg.capPerHour or 0
	if capPerHour > 0 then
		local b = GetBucket(self._listenerHour, listenerId, time, 3600)
		if b.xp >= capPerHour then
			return false, 0 -- capPerHour
		end
	end

	local xp = self:ComputeMessageXP(len)
	xp = math.max(xp, 0)

	return xp > 0, xp, speakerId, listenerId, normalized
end

function ChatXPService:Award(speaker, listener, chatType, text, time)
	time = time or CurTime()

	local allow, rewardXP, speakerId, listenerId, normalized = self:Evaluate(speaker, listener, chatType, text, time)

	if !allow or (rewardXP or 0) <= 0 then
		return 0
	end

	speakerId = speakerId or GetPlayerId(speaker)
	listenerId = listenerId or GetPlayerId(listener)

	-- update caps buckets
	local capPerMinute = self.config.capPerMinute or 10
	if capPerMinute > 0 and listenerId then
		local b = GetBucket(self._listenerMinute, listenerId, time, 60)
		local allowed = math.max(capPerMinute - b.xp, 0)
		rewardXP = math.min(rewardXP, allowed)
		b.xp = b.xp + rewardXP
	end

	local capPerHour = self.config.capPerHour or 0
	if capPerHour > 0 and listenerId and xp > 0 then
		local b = GetBucket(self._listenerHour, listenerId, time, 3600)
		local allowed = math.max(capPerHour - b.xp, 0)
		rewardXP = math.min(rewardXP, allowed)
		b.xp = b.xp + rewardXP
	end

	if rewardXP <= 0 then
		return 0
	end

	-- pair timestamp
	local pairCooldown = self.config.pairCooldownSec or 25
	if pairCooldown > 0 and speakerId and listenerId then
		self._lastPairAward[speakerId] = self._lastPairAward[speakerId] or {}
		self._lastPairAward[speakerId][listenerId] = time
	end

	-- store message for duplicate detection
	if speakerId and normalized and #normalized > 0 then
		self:StoreRecentMessage(speakerId, time, normalized)
	end

	return xp
end

