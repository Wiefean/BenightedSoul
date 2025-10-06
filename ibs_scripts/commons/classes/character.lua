--角色Class

--[[
"PlayerKey"指的是数据存读系统中对应的角色索引


"info_tbl"可包含内容:
{
BossIntroName, --boss战角色名字贴图文件名称
SpritePath, --动画路径
SpritePathFlight, --飞行动画路径

PocketActive, --副手主动
TearsModifier, --射速修正
}


]]

local mod = Isaac_BenightedSoul

local game = Game()
local SpriteDefaultPath = "gfx/001.000_player.anm2"

local Component = mod.IBS_Class.Component

local Character = mod.Class(Component, function(self, id, info_tbl)
	Component._ctor(self)

	self.ID = id
	self.PlayerKey = mod.IBS_PlayerID._ToKey(id)
	self.Info = info_tbl or {}

	--射速修正
	function self:__OnEvaluateCache(player, flag)
		if player:GetPlayerType() == (self.ID) then
			if flag == CacheFlag.CACHE_FIREDELAY then
				local tears = self.Info.TearsModifier
				if tears then
					self._Stats:TearsModifier(player, tears)
				end
			end
		end	
	end
	self:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, '__OnEvaluateCache')

	--动画数据
	function self:__GetAnimData(player)
		local data = self._Ents:GetTempData(player)

		if not data.IBSPlayerAnim then
			data.IBSPlayerAnim = {
				PlayerType = 0,
				SpriteState = -1,
			}
		end
		
		return data.IBSPlayerAnim
	end

	--角色初始化
	function self:__OnPlayerInit(player)
		if player:GetPlayerType() == self.ID then
			local item = self.Info.PocketActive
			if item and not (game:GetRoom():GetFrameCount() < 0 and game:GetFrameCount() > 0) then
				player:SetPocketActiveItem(item, ActiveSlot.SLOT_POCKET, false)
			end
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, 725, '__OnPlayerInit')

	--boss战名字翻译
	function self:__OnBossIntro()
		local spr = RoomTransition.GetVersusScreenSprite()
		if spr and mod.Language == 'zh' and self.Info.BossIntroName then
			local path = 'gfx/ibs/ui/portrait/'..(self.Info.BossIntroName)..'_name.png'
			if path == spr:GetLayer(6):GetSpritesheetPath() then			
				local newPath = 'gfx/ibs/ui/portrait/'..(self.Info.BossIntroName)..'_name_zh.png'
				spr:ReplaceSpritesheet(6, newPath, true)
			end
		end
	end
	self:AddCallback(ModCallbacks.MC_POST_BOSS_INTRO_SHOW, '__OnBossIntro')

	--更换角色动画文件
	function self:__ChangeSprite(player, anm2path)
		local spr = player:GetSprite()
		local animation = spr:GetAnimation()
		local frame = spr:GetFrame()
		local overlayAnimation = spr:GetOverlayAnimation()
		local overlayFrame = spr:GetOverlayFrame()
		spr:Load(anm2path, true)
		spr:SetFrame(animation, frame)
		spr:SetOverlayFrame(overlayAnimation, overlayFrame)
	end

	--更新贴图
	function self:__UpdatePlayerSprite(player)
		if player:IsCoopGhost() then return end
		local playerType = player:GetPlayerType()
		
		if playerType == self.ID then
			local data = self:__GetAnimData(player)
			local sprPath = self.Info.SpritePath
			local sprPathFlight = self.Info.SpritePathFlight

			--更换角色动画文件
			if sprPath and sprPathFlight then
				local sprState = 1
				local path = sprPath
				
				--飞行
				if player.CanFly then
					path = sprPathFlight
					sprState = 2
				end
				
				--超大蘑菇
				if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
					path = SpriteDefaultPath
					sprState = 0
				end
			
				if data.SpriteState ~= sprState then
					data.SpriteState = sprState
					self:__ChangeSprite(player, path)
				end	
			end
		else
			local data = self._Ents:GetTempData(player).IBSPlayerAnim 
			if data and data.PlayerType ~= playerType then
				data.PlayerType = playerType
				data.SpriteState = 0
			end
		end
	end
	self:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, -725, '__UpdatePlayerSprite', 0)

end, { {expectedType = 'number'}, {expectedType = 'table', allowNil = true} })


return Character
