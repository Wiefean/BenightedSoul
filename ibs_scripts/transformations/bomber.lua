--炸弹人

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local game = Game()
local sfx = SFXManager()

local Bomber = mod.IBS_Class.Transformation("trans_bomber", {
	Name = {
		zh = '炸弹人！',
		en = 'Bomber!',
	},

	CostumeID = Isaac.GetCostumeIdByPath('gfx/ibs/characters/trans_bomber.anm2'),

	OnGain = function(player, first)
		if first then
			local room = game:GetRoom()
		
			local pos = room:FindFreePickupSpawnPosition(player.Position + Vector(0,-40), 0, true)
			Isaac.Spawn(5, 40, 7, pos, Vector.Zero, nil):ToPickup().Wait = 45
		end
	end,

	ItemList = {
		[19] = true, --轰
		[37] = true, --炸弹先生
		[40] = true, --神风
		[47] = true, --胎儿博士的遥控器
		[52] = true, --胎儿博士
		[106] = true, --大爆弹先生
		[125] = true, --波比炸弹
		[131] = true, --炸弹袋
		[137] = true, --起爆器
		[140] = true, --鲍勃的诅咒
		[168] = true, --史诗胎儿
		[190] = true, --烟火盛宴
		[209] = true, --屁股炸弹
		[223] = true, --纵火狂
		[250] = true, --炸弹买一送一
		[256] = true, --炙热炸弹
		[353] = true, --炸弹人
		[366] = true, --分裂炸弹
		[367] = true, --黏性炸弹
		[371] = true, --塔之诅咒
		[378] = true, --大号
		[427] = true, --炸药包
		[432] = true, --闪光炸弹
		[483] = true, --妈炸
		[517] = true, --快速炸弹
		[563] = true, --魅彩炸弹
		[583] = true, --罐中火箭
		[614] = true, --鲜血炸弹
		[646] = true, --硫磺火炸弹
		[727] = true, --幽灵炸弹

		[IBS_ItemID.DustyBomb] = true, --尘埃炸弹
		[IBS_ItemID.MiniHorn] = true, --小小角恶魔
		[IBS_ItemID.SaleBomb] = true, --促销炸弹
		[IBS_ItemID.BomberKey] = true, --炸钥人
	},
})


--爆炸增伤
function Bomber:PreTakeDMG(ent, dmg, flag, source, cd)
	if flag & DamageFlag.DAMAGE_EXPLOSION <= 0 then return end
	
	if self._Ents:IsEnemy(ent, true) then
		local mult = 1
	
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if self:IsOwned(player) then
				mult = mult * 1.5
			
				if player:HasCollectible(IBS_ItemID.Hoarding) then
					mult = mult + 0.1 * self:GetCount(player)
				end
			end
		end		

		if mult > 1 then
			return {Damage = dmg * mult}
		end
	end
end
Bomber:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -999, 'PreTakeDMG')

return Bomber