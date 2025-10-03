--发光的心

local mod = Isaac_BenightedSoul
local IronHeart = mod.IBS_Class.IronHeart()

local game = Game()
local sfx = SFXManager()

local GlowingHeart = mod.IBS_Class.Item(mod.IBS_ItemID.GlowingHeart)

--使用效果
function GlowingHeart:OnUse(item, rng, player)
	--昧化抹大拉
	if player:GetPlayerType() == mod.IBS_PlayerID.BMaggy then
		local data = IronHeart:GetData(player)
		data.Extra = data.Extra + 21
		data.Breakdown = math.max(0, data.Breakdown - 7)
	end

	if player:GetBrokenHearts() > 0 then
		player:AddBrokenHearts(-1)
		sfx:Play(SoundEffect.SOUND_SUPERHOLY)
	elseif player:HasCollectible(59) then --彼列书
		player:AddBlackHearts(2)
		sfx:Play(SoundEffect.SOUND_UNHOLY)
	else
		player:AddSoulHearts(2)
		sfx:Play(SoundEffect.SOUND_HOLY)		
	end

	return true
end
GlowingHeart:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', GlowingHeart.ID)


return GlowingHeart