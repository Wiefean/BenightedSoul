--生化母体

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local Reservoir = mod.IBS_Class.Transformation("trans_reservoir", {
	Name = {
		zh = '生化母体！',
		en = 'Reservoir!',
	},

	CostumeID = Isaac.GetCostumeIdByPath('gfx/ibs/characters/trans_reservoir.anm2'),

	OnGain = function(player, first)
		if first then
			player:AddRottenHearts(18)
		end
	end,

	ItemList = {
		[103] = true, --普通感冒
		[214] = true, --贫血
		[261] = true, --眼球突出
		[347] = true, --复视
		[350] = true, --毒性休克
		[368] = true, --溢泪症
		[379] = true, --双瞳
		[440] = true, --肾结石
		[446] = true, --死牙
		[452] = true, --静脉曲张
		[453] = true, --复杂性骨折
		[454] = true, --多指畸形
		[459] = true, --鼻窦炎
		[460] = true, --青光眼
		[466] = true, --传染病
		[469] = true, --抑郁症
		[502] = true, --大青春痘
		[510] = true, --精神错乱
		[525] = true, --麻风病
		[531] = true, --泪血症
		[549] = true, --脆骨症
		[553] = true, --毛霉菌病
		[558] = true, --眼瘤
		[645] = true, --小畸胎瘤
		[657] = true, --血管炎
		[680] = true, --水土不服症
		[683] = true, --骨刺
		[724] = true, --高凝血
		[725] = true, --大肠激躁症
		[726] = true, --咳血
		[731] = true, --麦粒肿
	},
})

--受伤判定
function Reservoir:OnTakeDMG(ent, dmg, flag, source)
	local player = ent:ToPlayer()
	
	if player and self:IsOwned(player) then
		local target = source.Entity
		if target and target:IsEnemy() and target:IsActiveEnemy() and not target:IsBoss() then
			local ent = Isaac.Spawn(10,3,0, target.Position, Vector.Zero, player):ToNPC()
			ent:AddCharmed(EntityRef(player), -1)
			target:Remove()
		end
	end
end
Reservoir:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, 'OnTakeDMG')

--腐烂Gaper友好
function Reservoir:OnNpcUpdate(npc)
	if npc.Variant == 3 and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if self:IsOwned(player) then
				npc:AddCharmed(EntityRef(player), -1)
				break
			end
		end	
	end
end
Reservoir:AddCallback(ModCallbacks.MC_NPC_UPDATE, 'OnNpcUpdate', 10)

--失去腐心时获得红心
function Reservoir:OnPlayerUpdate(player)
	if not self:IsOwned(player) then return end
	local data = self._Ents:GetTempData(player)
	local num = player:GetRottenHearts()
	data.TRANSFORMATION_RESERVOIR_RECORD = data.TRANSFORMATION_RESERVOIR_RECORD or num

	if data.TRANSFORMATION_RESERVOIR_RECORD ~= num then
		if data.TRANSFORMATION_RESERVOIR_RECORD > num then
			if player:HasCollectible(IBS_ItemID.Hoarding) then		
				player:AddHearts(2)
			else		
				player:AddHearts(1)
			end
		end
		data.TRANSFORMATION_RESERVOIR_RECORD = num
	end
end
Reservoir:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate', 0)


--血泪效果
function Reservoir:OnFireTear(tear)
	local player = self._Ents:IsSpawnerPlayer(tear, true)
    if player and self:IsOwned(player) then
		self._Tears:ToBlood(tear)
    end
end
Reservoir:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, 'OnFireTear')

return Reservoir