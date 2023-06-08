--贪婪模式相关回调

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback

--初始化
local function TryInit()
	if IBS_Data.GameState.Temp.Level.Greed == nil then
		IBS_Data.GameState.Temp.Level.Greed = {}
	end
end

--检查记录的波次
local function CheckWaveRecord()
	TryInit()
	
	local wave = IBS_Data.GameState.Temp.Level.Greed.wave_record
	
	return wave or 0
end

--记录波次
local function RecordWave(value)
	TryInit()

	IBS_Data.GameState.Temp.Level.Greed.wave_record = value
end

--检查记录的清理状态
local function CheckCleanRecord()
	TryInit()

	local clean = IBS_Data.GameState.Temp.Level.Greed.clean_record
	
	return clean or false
end

--记录清理状态
local function RecordCleaned(bool)
	TryInit()

	IBS_Data.GameState.Temp.Level.Greed.clean_record = bool
end


--波次回调
local function GreedCallback()
    if (Game():IsGreedMode()) then
		local room = Game():GetRoom()
		local level = Game():GetLevel()
		
		local wave = level.GreedModeWave
		local wave_record = CheckWaveRecord()
		
		--当前波次大于记录波次时触发
		if wave > wave_record then
			Isaac.RunCallback(IBS_Callback.GREED_NEW_WAVE, wave)
			RecordWave(wave)
		end
		
		--在普通房间触发
		if (room:GetType() == RoomType.ROOM_DEFAULT) then
			local clean_record = CheckCleanRecord()
			
			--房间清理后且清理状态与上一帧不同时触发
			if room:IsClear() and (room:IsClear() ~= clean_record)then
				local boss = Game():GetGreedBossWaveNum()
				local deal = Game():GetGreedWavesNum()
				
				--波次为特定波次时改变波次完成状态
				if (wave == boss-1) or (wave == deal-1) or (wave == deal)then
					local state = 0
					
					if (wave == boss-1) then
						state = 1
					elseif (wave == deal-1) then
						state = 2
					elseif (wave == deal) then
						state = 3
					end
					
					Isaac.RunCallback(IBS_Callback.GREED_WAVE_END_STATE, state)
				end
			end
			RecordCleaned(room:IsClear())
		end	
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, GreedCallback)






