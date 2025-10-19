--真实之眼

local mod = Isaac_BenightedSoul
local Stats = mod.IBS_Lib.Stats

local game = Game()
local config = Isaac.GetItemConfig()

local TheEyeofTruth = mod.IBS_Class.Item(mod.IBS_ItemID.TheEyeofTruth)

--字体
local fnt = Font('font/pftempestasevencondensed.fnt')

--渲染掉落物和敌人的ID
function TheEyeofTruth:OnRender()
	if not game:GetHUD():IsVisible() then return end
	if not PlayerManager.AnyoneHasCollectible(self.ID) then return end
	if game:GetRoom():GetFrameCount() <= 1 then return end
	for _,ent in ipairs(Isaac.GetRoomEntities()) do
		if ent:ToPickup() or ent:IsEnemy() then
			local pos = self._Screens:WorldToScreen(ent.Position, Vector(0,0), true)
			fnt:DrawStringScaled(tostring(ent.Type)..'.'..tostring(ent.Variant)..'.'..tostring(ent.SubType), pos.X - 32, pos.Y, 0.5, 0.5, KColor(1,1,1,1), 64, true)
			--fnt:DrawStringScaled(ent.HitPoints..' / '..ent.MaxHitPoints, pos.X - 32, pos.Y, 0.5, 0.5, KColor(1,1,1,1), 64, true)
		end
	end
end
TheEyeofTruth:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnRender')

--属性
function TheEyeofTruth:OnEvaluateCache(player, flag)
	if player:HasCollectible(self.ID) then
		local num = player:GetCollectibleNum(self.ID)
		if flag == CacheFlag.CACHE_RANGE then
			Stats:Range(player, 2*num)
		end
	end	
end
TheEyeofTruth:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'OnEvaluateCache')


return TheEyeofTruth