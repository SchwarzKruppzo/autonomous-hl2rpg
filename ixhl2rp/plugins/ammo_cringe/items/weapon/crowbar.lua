ITEM.name = "Монтировка"
ITEM.description = "Цельнометаллическая монтировка, скованная в пучине войны, которой не суждено закончиться. Обладает приличным весом, боевым окрасом и смыслом, который многим еще только предстоит узнать, если те доживут до момента в будущем, который обязательно случится."
ITEM.model = "models/weapons/tfa_nmrih/w_me_crowbar.mdl"
ITEM.class = "tfa_nmrih_crowbar"
ITEM.weaponCategory = "melee"
ITEM.width = 1
ITEM.height = 3
ITEM.iconCam = {
	pos = Vector(307.93508911133, 289.47528076172, 141.46713256836),
	ang = Angle(18.666589736938, 223.25354003906, 0),
	fov = 1.3164812222903,
}

function ITEM:HasDurability()
	return (self:GetData("value") or 0) > 0
end

function ITEM:DurabilityPercentage()
	return (self:GetData("value") or 0) / (self.durability or 1)
end

function ITEM:TakeDurability(x, client)
	if self:AddDurability(-x) then
		self:Remove()
	end
end