--广告时间

local mod = Isaac_BenightedSoul
local LANG = (mod.Language == 'zh')

local game = Game()

local ADTime = mod.IBS_Class.Item(mod.IBS_ItemID.ADTime)

--广告,其实是你从来没看完的赞助者名单
local GiantBookID = Isaac.GetGiantBookIdByName('IBS_ADTime')

local path = (LANG and 'gfx/ibs/ui/giantbook/ad_time_zh/credits.anm2') or 'gfx/ibs/ui/giantbook/ad_time/credits.anm2'
local AD = Sprite(path)
AD:Play("Credits")

--播放
function ADTime:PlayAD()
	ItemOverlay.Show(GiantBookID)
	AD:Play('Credits', true)
	MusicManager():Crossfade(Music.MUSIC_CREDITS_ALT_FINAL, 0.01)
end

function ADTime:PrePlayerDeath(player)
	if player:HasCollectible(self.ID, true) then
		local data = self._Players:GetData(player)
		data.ADTimePlaying = 10 --记录正在观看广告
		self:PlayAD()
		self:DelayFunction2(function()
			player:SetFullHearts()
		end, 1)
		return false
	end
end
ADTime:AddCallback(ModCallbacks.MC_TRIGGER_PLAYER_DEATH_POST_CHECK_REVIVES, 'PrePlayerDeath')

--游戏更新时清除记录
function ADTime:OnUpdate()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = self._Players:GetData(player)
		if data.ADTimePlaying then
			if data.ADTimePlaying > 0 then
				data.ADTimePlaying = data.ADTimePlaying - 1
			else
				data.ADTimePlaying = nil
			end
		end
	end
end
ADTime:AddCallback(ModCallbacks.MC_POST_UPDATE, "OnUpdate")

--跳广告直接死
function ADTime:OnGameStarted(isContinued)
	if not isContinued then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(self.ID, true) and self._Players:GetData(player).ADTimePlaying ~= nil then
			player:RemoveCollectible(self.ID, true)
			player:Die()
		end
	end
end
ADTime:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, -1000, "OnGameStarted")

--渲染
local UPDATED = false
function ADTime:OnRender()
	local spr = ItemOverlay.GetSprite()

	--硬核判断是否在播放
	if spr:GetFilename() ~= 'gfx/ibs/ui/giantbook/ad_time.anm2' then return end
	if not spr:IsPlaying('Credits') then return end

	AD:Render(Vector(0,0))

	if game:GetPauseMenuState() == PauseMenuStates.CLOSED then	
		if UPDATED then
			UPDATED = false
		else
			UPDATED = true
			AD:Update()
		end
	end
end
ADTime:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnRender')


return ADTime