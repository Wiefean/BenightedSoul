--伤害传输器

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()
local sfx = SFXManager()

local DMGTransmitter = mod.IBS_Class.Item(mod.IBS_ItemID.DMGTransmitter)


--使用
function DMGTransmitter:OnUse(item, rng, player, flag, slot)
	if player.Damage > 3.5 then
		local data = self._Players:GetData(player)
		data.DMGTransmitterRecrod = (data.DMGTransmitterRecrod or 0) + 1
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
		return true
	end
	return {ShowAnim = false, Discharge = false}
end
DMGTransmitter:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', DMGTransmitter.ID)

--属性变动
function DMGTransmitter:OnEvalueateCache(player, flag)
	if flag == CacheFlag.CACHE_DAMAGE then
		local dmg = self._Players:GetData(player).DMGTransmitterRecrod
		if dmg and dmg > 0 then		
			self._Stats:Damage(player, -dmg)
		end
	end
end
DMGTransmitter:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvalueateCache')

--增伤
function DMGTransmitter:OnTakeDMG(ent, dmg, flag, source, cd)
	if dmg <= 0 then return end
	if self._Ents:IsEnemy(ent, true) then
		local extra = 0
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			local dmg = self._Players:GetData(player).DMGTransmitterRecrod
			if dmg and dmg > 0 then	
				extra = extra + math.max(0, 2 * dmg)
				
				--彼列书
				if player:HasCollectible(59) then
					extra = extra + 1.3
				end
			end
		end
		
		return {Damage = dmg + extra, DamageFlags = flag, DamageCountdown = cd}
	end
end
DMGTransmitter:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -100000, 'OnTakeDMG')

--显示增伤
local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")
function DMGTransmitter:OnActiveRender(player, slot, offset, alpha, scale)
	if player:GetActiveItem(slot) ~= self.ID then return end
	local dmg = self._Players:GetData(player).DMGTransmitterRecrod or 0
	local stringNum = tostring(dmg*2)
	local color = KColor(1,1,1,1)
	
	local pos = Vector(scale, scale) + offset
	stringNum = "+"..stringNum
	fnt:DrawStringScaled(stringNum, pos.X, pos.Y, scale * 0.75, scale * 0.75, color)
end
DMGTransmitter:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, 'OnActiveRender')

return DMGTransmitter