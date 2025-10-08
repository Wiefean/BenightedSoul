--昧化夏娃

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID
local CharacterLock = mod.IBS_Achiev.CharacterLock

local game = Game()
local sfx = SFXManager()

local BEve = mod.IBS_Class.Character(mod.IBS_PlayerID.BEve, {
	BossIntroName = 'beve',
	PocketActive = mod.IBS_ItemID.MyFruit,
})

return BEve