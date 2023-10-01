--昧化犹大

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Challenge = mod.IBS_Challenge
local IBS_Item = mod.IBS_Item
local IBS_Trinket = mod.IBS_Trinket
local IBS_Player = mod.IBS_Player
local IBS_Sound = mod.IBS_Sound
local Pools = mod.IBS_Lib.Pools
local Stats = mod.IBS_Lib.Stats
local Players = mod.IBS_Lib.Players
local Ents = mod.IBS_Lib.Ents

--角色属性
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player, flag)
	if player:GetPlayerType() == (IBS_Player.bjudas) then
		if flag == CacheFlag.CACHE_SPEED then
			Stats:Speed(player, 0.11)
		end	
		if flag == CacheFlag.CACHE_FIREDELAY then
			Stats:TearsModifier(player, 0.6)
		end	
		if flag == CacheFlag.CACHE_DAMAGE then
			Stats:Damage(player, -1.28)
		end
		if flag == CacheFlag.CACHE_RANGE then
			Stats:Range(player, 0.16)
		end
		if flag == CacheFlag.CACHE_SHOTSPEED then
			Stats:ShotSpeed(player, 0.11)
		end	
	end	
end)

--初始化角色
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_,player)
    if player:GetPlayerType() == (IBS_Player.bjudas) then
        local game = Game()
        if not (game:GetRoom():GetFrameCount() < 0 and game:GetFrameCount() > 0) then
			player:AddEternalHearts(1)
            player:SetPocketActiveItem((IBS_Item.tgoj), ActiveSlot.SLOT_POCKET, false)
			
			--混沌信仰
			if (Isaac.GetChallenge() ~= IBS_Challenge.bc4) and IBS_Data.Setting["bc4"] then
				player:AddTrinket(IBS_Trinket.chaoticbelief)	
			end
        end
    end
end)

--变身
local function Henshin(_,player)
	local canHenshin = false 

	--检测彼列书和三块钱
	if player:GetNumCoins() >= 3 then
		for slot = 0,1 do
			if player:GetActiveItem(slot) == 34 then
				player:RemoveCollectible(34, true, slot)
				canHenshin = true
				break
			end	
		end
		if player:GetActiveItem(2) == 34 then canHenshin = true end
	end
	
	if canHenshin then
		player:ChangePlayerType(IBS_Player.bjudas)
		player:AddCoins(-3)
		player:AddBlackHearts(1)
		player:AddEternalHearts(1)
		player:AddMaxHearts(-2)
		player:SetPocketActiveItem(IBS_Item.tgoj, ActiveSlot.SLOT_POCKET, false)
		
		--混沌信仰
		if IBS_Data.Setting["bc4"] then
			player:AddTrinket(IBS_Trinket.chaoticbelief)
		end
		
		--我释放恶魂
		SFXManager():Play(266)
		SFXManager():Play(468)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
		player:SetMinDamageCooldown(76)
		for i = 1,7 do
			Isaac.Spawn(1000, 189, 1, player.Position + 20*RandomVector(), Vector.Zero, player)
		end
	end
end
mod:AddCallback(IBS_Callback.BENIGHTED_HENSHIN, Henshin, PlayerType.PLAYER_JUDAS)
