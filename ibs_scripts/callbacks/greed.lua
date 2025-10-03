--贪婪模式相关回调

--[[说明:
波次完成状态:
	0 -- 小怪波次未完成
	1 -- 小怪波次完成
	2 -- Boss波次完成
	3 -- 额外Boss波次完成
]]

local mod = Isaac_BenightedSoul
local IBS_CallbackID = mod.IBS_CallbackID

local game = Game()

local Greed = mod.IBS_Class.Callbacks{
	GREED_WAVE_CHANGE = IBS_CallbackID.GREED_WAVE_CHANGE,
	GREED_NEW_WAVE = IBS_CallbackID.GREED_NEW_WAVE,
	GREED_WAVE_END_STATE = IBS_CallbackID.GREED_WAVE_END_STATE
}


--波次完成状态
Greed.WaveEndState = {
	None = 0, -- 小怪波次未完成
	Monster = 1, -- 小怪波次完成
	Boss = 2, -- Boss波次完成
	Deal = 3 -- 额外Boss波次完成
}


--获取数据
function Greed:GetData()
	local data = self:GetIBSData('level')

	if not data.Greed then
		data.Greed = {
			Wave = game:GetLevel().GreedModeWave,
			WavePassed = 0,
			RoomCleared = game:GetRoom():IsClear()
		}
	end
	
	return data.Greed
end


--回调
function Greed:RunCallbacks()
    if not game:IsGreedMode() then return end
	local data = self:GetData()
	local room = game:GetRoom()
	local wave = game:GetLevel().GreedModeWave
	
	--波次回调
	if data.Wave ~= wave then
		self:Run(self.IDs.GREED_WAVE_CHANGE, wave)
		data.Wave = wave
	end
	if data.WavePassed < wave then
		self:Run(self.IDs.GREED_NEW_WAVE, wave)
		data.WavePassed = wave
	end
	
	--波次完成状态回调
	if room:GetType() == RoomType.ROOM_DEFAULT then --在普通房间触发(在贪婪模式相当于初始房间)
		if room:IsClear() and (data.RoomCleared ~= room:IsClear())then
			local boss = game:GetGreedBossWaveNum()
			local deal = game:GetGreedWavesNum()
			
			--波次为特定波次时改变波次完成状态
			if (wave == boss-1) or (wave == deal-1) or (wave == deal)then
				local state = self.WaveEndState.None
				
				if (wave == boss-1) then
					state = self.WaveEndState.Monster
				elseif (wave == deal-1) then
					state = self.WaveEndState.Boss
				elseif (wave == deal) then
					state = self.WaveEndState.Deal
				end

				self:Run(self.IDs.GREED_WAVE_END_STATE, state)
			end
		end
		data.RoomCleared = room:IsClear()
	end	
end
Greed:AddCallback(ModCallbacks.MC_POST_UPDATE, 'RunCallbacks')



return Greed