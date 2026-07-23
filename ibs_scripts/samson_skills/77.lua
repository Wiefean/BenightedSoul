--参孙技能
--倒世界

local mod = Isaac_BenightedSoul
local BigLight = mod.IBS_Effect.BigLight

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(77, {
	IsReversed = true,
})

--自动消耗倒牌
function Skill:OnPlayerUpdate(player)
	if not player:IsFrame(77,0) then return end
	if not self:HasCard(player) then return end
	local data = self._Players:GetData(player).Posture
	
	if data and data.Cards2 then
		local cardData = self:GetPlayerData(player)
		local Posture = mod.IBS_Item.Posture
		for slot,id in ipairs(data.Cards2) do
			if id > 0 and (id ~= self.ID or self:GetCardNum(player) > 1) then
				cardData.Num = (cardData.Num or 0) + 1
				Posture:ConsumeCard(player, slot, true)
				
				--烟雾
				local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player):ToEffect()			
				poof.SpriteScale = Vector(0.5,0.5)
				poof.Color = Color(0,0,0,0.5)
				poof:FollowParent(player)
				sfx:Play(33, 1, 2, false, 2)
				break
			end
		end
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, "OnPlayerUpdate", 0)

--属性
function Skill:OnEvalueateCache(player, flag)
	if flag == CacheFlag.CACHE_DAMAGE then
		local data = self:GetPlayerData(player, true)
		if data and data.Num then		
			self._Stats:Damage(player, data.Num * 0.5)
		end
	end	
end
Skill:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

--增加恶魔房开启率
function Skill:OnDevilChance(chance)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self:GetPlayerData(player, true)
		if data and data.Num then		
			return chance + data.Num * 0.21
		end		
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_DEVIL_CALCULATE, 'OnDevilChance')

--开门
function Skill:OnDoorUpdate(door)
	if game:IsGreedMode() then return end
	if not self:AnyHasCard() then return end
	if door:IsRoomType(RoomType.ROOM_SECRET_EXIT) and door:IsLocked() then
		door:SetLocked(false)
	end
end
Skill:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, 'OnDoorUpdate')

return Skill