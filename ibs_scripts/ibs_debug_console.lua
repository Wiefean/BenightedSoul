--自定义控制台指令

--[[说明书:
自定义指令默认关闭,需要用模组配置菜单开启
(到游戏本体目录的data文件里找到这个mod,修改saveX存档文件也行)

新增指令请标好注释
]]

local mod = Isaac_BenightedSoul
local IBS_Item = mod.IBS_Item
local IBS_Trinket = mod.IBS_Trinket
local Stats = mod.IBS_Lib.Stats
local IBS_Pocket = mod.IBS_Pocket

--控制台添加的属性
local cmdStats = {
	spd = 0,
	tears = 0,
	dmg = 0,
	range = 0,
	sspd = 0,
	luck = 0
}
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if (Game():GetFrameCount() <= 1) then --开局重置
		cmdStats = {
			spd = 0,
			tears = 0,
			dmg = 0,
			range = 0,
			sspd = 0,
			luck = 0
		}
		
		--刷新角色属性
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			player:AddCacheFlags(CacheFlag.CACHE_ALL)
			player:EvaluateItems()
		end			
	end
end)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_,player,flag)
	if flag == CacheFlag.CACHE_SPEED then
		Stats:Speed(player, cmdStats.spd, true)
	end
	if flag == CacheFlag.CACHE_FIREDELAY then
		Stats:TearsModifier(player, cmdStats.tears, true)
	end
	if flag == CacheFlag.CACHE_DAMAGE then
		Stats:Damage(player, cmdStats.dmg, true)
	end
	if flag == CacheFlag.CACHE_RANGE then
		Stats:Range(player, cmdStats.range, true)
	end
	if flag == CacheFlag.CACHE_SHOTSPEED then
		Stats:ShotSpeed(player, cmdStats.sspd, true)
	end	
	if flag == CacheFlag.CACHE_LUCK then
		Stats:Luck(player, cmdStats.luck, true)
	end
end)

local function IBS_CMD(_,cmd,sth)
if IBS_Data.Setting["moreCommands"] then

	local number = tonumber(sth) --数字
	
	local int = nil --整数
	if type(number) == "number" then
		int = math.floor(number) 
	end
	
	--房间中心位置
	local centerPos = Game():GetRoom():FindFreePickupSpawnPosition((Game():GetLevel():GetCurrentRoom():GetCenterPos()), 0, true)



	--生成金饰品
	if cmd == "goldent" and int ~= nil then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, int+32768, centerPos, Vector.Zero, nil)
	end

	do --添加资源
		if int ~= nil then
			if cmd == "coin" then
				Isaac.GetPlayer(0):AddCoins(int)
			end
			if cmd == "bomb" then
				Isaac.GetPlayer(0):AddBombs(int)
			end
			if cmd == "key" then
				Isaac.GetPlayer(0):AddKeys(int)
			end
		end	
	end
	
	do --添加血量
		if int ~= nil then
			do --P1
				if cmd == "addhc" then
					Isaac.GetPlayer(0):AddMaxHearts(int*2)
				end	
				if cmd == "addh" then
					Isaac.GetPlayer(0):AddHearts(int)
				end
				if cmd == "addsh" then
					Isaac.GetPlayer(0):AddSoulHearts(int)
				end
				if cmd == "addbh" then
					Isaac.GetPlayer(0):AddBlackHearts(int)
				end
				if cmd == "addeh" then
					Isaac.GetPlayer(0):AddEternalHearts(int)
				end	
				if cmd == "addgh" then
					Isaac.GetPlayer(0):AddGoldenHearts(int)
				end
				if cmd == "addrh" then
					Isaac.GetPlayer(0):AddRottenHearts(int)
				end	
				if cmd == "addboh" then
					Isaac.GetPlayer(0):AddBoneHearts(int)
				end
				if cmd == "addbrh" then
					Isaac.GetPlayer(0):AddBrokenHearts(int)
				end
			end
			do --p2
				if cmd == "addhc2" then
					Isaac.GetPlayer(1):AddMaxHearts(int*2)
				end
				if cmd == "addh2" then
					Isaac.GetPlayer(1):AddHearts(int)
				end
				if cmd == "addsh2" then
					Isaac.GetPlayer(1):AddSoulHearts(int)
				end
				if cmd == "addbh2" then
					Isaac.GetPlayer(1):AddBlackHearts(int)
				end
				if cmd == "addeh2" then
					Isaac.GetPlayer(1):AddEternalHearts(int)
				end	
				if cmd == "addgh2" then
					Isaac.GetPlayer(1):AddGoldenHearts(int)
				end
				if cmd == "addrh2" then
					Isaac.GetPlayer(1):AddRottenHearts(int)
				end	
				if cmd == "addboh2" then
					Isaac.GetPlayer(1):AddBoneHearts(int)
				end
				if cmd == "addbrh2" then
					Isaac.GetPlayer(1):AddBrokenHearts(int)
				end	
			end
		end	
	end


	do --更改属性
		if type(number) == "number" then
			if cmd == "spd" then
				cmdStats.spd = number
			end
			if cmd == "tears" then
				cmdStats.tears = number
			end		
			if cmd == "dmg" then
				cmdStats.dmg = number
			end
			if cmd == "range" then
				cmdStats.range = number
			end	
			if cmd == "sspd" then
				cmdStats.sspd = number
			end	
			if cmd == "luck" then
				cmdStats.luck = number
			end	
					
			--刷新角色属性
			for i = 0, Game():GetNumPlayers() -1 do
				local player = Isaac.GetPlayer(i)
				player:AddCacheFlags(CacheFlag.CACHE_ALL)
				player:EvaluateItems()
			end			
		end	
	end
	
	do --设置副主动
		if int ~= nil and int >= 0 then
			if cmd == "pocketactive" then --P1
				Isaac.GetPlayer(0):SetPocketActiveItem(int, ActiveSlot.SLOT_POCKET, true)
			end
			if cmd == "pocketactive2" then --P2
				Isaac.GetPlayer(1):SetPocketActiveItem(int, ActiveSlot.SLOT_POCKET, true)
			end
		end	
	end	
	
	do --切换玩家一的角色
		if int ~= nil and int >= 0 then
			if cmd == "changeplayer" then
				Isaac.GetPlayer(0):ChangePlayerType(int)
			end
		end	
	end	
	
	--使用该隐魂石
	if cmd == "door" then
		Isaac.GetPlayer(0):UseCard(83,UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
	end
	
	--隐藏/显示HUD
	if cmd == "hud" then
		local hud = Game():GetHUD()
		if hud:IsVisible() then
			hud:SetVisible(false)
		else
			hud:SetVisible(true)
		end
	end
	
	--开关鼠标
	if cmd == "mouse" then
		if Options.MouseControl then
			Options.MouseControl = false
		else
			Options.MouseControl = true
		end
	end
	
	do --用索引查看本模组各种东西的ID
		if cmd =="ibsitem" then --道具
			print(IBS_Item[sth])
		end
		
		if cmd == "ibspocket" then --口袋物品
			print(IBS_Pocket[sth])
		end
		
		if cmd =="ibstrinket" then --饰品
			print(IBS_Trinket[sth])
		end		
	end	
	
end	
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD,IBS_CMD)