--极巨化钥士

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local MrDynamax = mod.IBS_Class.Item(mod.IBS_ItemID.MrDynamax)

--使用
function MrDynamax:OnUse(item, rng, player, flag, slot)
	local level = game:GetLevel()
	
	--贪婪模式,不在主世界
	if game:IsGreedMode() or (level:GetDimension() ~= 0) then
		sfx:Play(187, 1, 30) --失败提示音
		return {ShowAnim = false, Discharge = false}
	end

	if (flag & UseFlag.USE_CARBATTERY <= 0) then
		local level = game:GetLevel()
		local seed = rng:Next()
		local roomData = self._Levels:CreateRoomData{
			Seed = seed,
			Type = RoomType.ROOM_BOSSRUSH,
			Shape = RoomShape.ROOMSHAPE_2x2,
		}
		
		if roomData then
			local gridIndex = level:GetCurrentRoomIndex()
		
			for _,offset in pairs{1, -1, 13, -13} do
				if level:TryPlaceRoom(roomData, gridIndex + offset, -1, seed, true, true) then
					game:GetRoom():MamaMegaExplosion(player.Position)

					--举起道具动画
					local spr = Sprite('gfx/ibs/ui/items/any.anm2')
					spr:ReplaceSpritesheet(0, config:GetCollectible(self.ID).GfxFileName, true)
					spr.Scale = Vector(4,4)
					spr:Play('Idle')
					player:AnimatePickup(spr)

					--美德书
					if player:HasCollectible(584) then
						player:AddKeys(99)
					end

					--彼列书
					if player:HasCollectible(59) then
						local keys = player:GetNumKeys()
						player:AddKeys(-keys)
						if keys > 0 then
							self._Stats:PersisDamage(player, 0.13 * keys, true)
						end
					end

					return {ShowAnim = false, Remove = true}
				end
			end
		end
	end
	
	sfx:Play(187, 1, 30) --失败提示音
	
	return {ShowAnim = false, Discharge = false}
end
MrDynamax:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', MrDynamax.ID)



return MrDynamax