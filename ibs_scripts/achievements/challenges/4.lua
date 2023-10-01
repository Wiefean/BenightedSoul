--逾越节挑战

local mod = Isaac_BenightedSoul
local IBS_Challenge = mod.IBS_Challenge
local IBS_Curse = mod.IBS_Curse
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local BigBooks = mod.IBS_Lib.BigBooks

--播放成就纸张动画
local function ShowPaper()
	local paper = "bjudas_up"
	
	--检测语言
	if mod.Language == "zh" then
		paper = paper.."_zh"
	end
	
	paper = paper..".png"	
	BigBooks:PlayPaper(paper)
end

--解锁条件
local function IsUnlockable(bossLevel)
	local Challenge = Isaac.GetChallenge() == IBS_Challenge.bc4
	local bossRoom = Game():GetRoom():GetType() == RoomType.ROOM_BOSS
	local level = Game():GetLevel():GetStage()
	
	--特定挑战
	if Challenge then
		if bossLevel then --Boss房和楼层判定
			if bossRoom and level == bossLevel then
				return true
			end
		else
			return true
		end	
	end

	return false
end

local function Pre()--楼层切换为9层并筛选诅咒
	if Isaac.GetChallenge() == (IBS_Challenge.bc4) then
		local level = Game():GetLevel()
		if level:GetStage() ~= 9 then
			Isaac.ExecuteCommand("stage 9")
			level:AddCurse(LevelCurse.CURSE_OF_DARKNESS | LevelCurse.CURSE_OF_THE_LOST | IBS_Curse.moving)
			level:RemoveCurses(LevelCurse.CURSE_OF_THE_UNKNOWN | LevelCurse.CURSE_OF_MAZE | LevelCurse.CURSE_OF_BLIND)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Pre)

local function Pare(_,continue)--战前准备
	if Isaac.GetChallenge() == (IBS_Challenge.bc4) then
		local game = Game()
		local room = game:GetRoom()
		local seed = game:GetSeeds()
			
		--移除门
		room:RemoveDoor(3)
		room:RemoveDoor(4)
		room:RemoveDoor(6)
		
		--添加彩蛋种子(音乐变慢)
		if not seed:HasSeedEffect(41) then
			seed:AddSeedEffect(41)
		end
		
		if not continue then
			local size = room:GetGridSize()
			local pos = room:GetCenterPos() + Vector(0, 80)
			
			--移除掉落物
			for _, pickup in pairs(Isaac.FindByType(5)) do pickup:Remove() end
				
			--生成道具
			Isaac.Spawn(5,100,260, pos + Vector(-80, -80), Vector.Zero, nil)
			Isaac.Spawn(5,100,323, pos + Vector(80, -80), Vector.Zero, nil)
			Isaac.Spawn(5,100,499, pos + Vector(-40, 200), Vector.Zero, nil)
			Isaac.Spawn(5,100,619, pos + Vector(0, -140), Vector.Zero, nil)
		end			
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Pare)

local function Player(_,player)--道具与角色
	if Isaac.GetChallenge() == (IBS_Challenge.bc4) then
		player:AddBlackHearts(1)
		player:AddMaxHearts(-99)
		player:AddBombs(-1)
		
		if player:GetPlayerType() ~= (IBS_Player.bjudas) then
			player:ChangePlayerType(IBS_Player.bjudas)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Player)

--只能拿长子权
local function BirthringtOnly(_,pickup, other)
	if Isaac.GetChallenge() == (IBS_Challenge.bc4) then
		local player = other:ToPlayer()
		if player and (pickup.SubType ~= 619 and pickup.SubType > 0) then
			for subType = 1,2 do
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, subType, pickup.Position, Vector.Zero, nil)
			end
			pickup:Remove()
			player:AnimateSad()
			SFXManager():Play(SoundEffect.SOUND_BLACK_POOF, 2, 2, false, 0.7)
			
			return false
		end	
	end	
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, BirthringtOnly, PickupVariant.PICKUP_COLLECTIBLE)


--模拟判定点
local function hitbox()
	if Isaac.GetChallenge() == (IBS_Challenge.bc4) then
		for _,player in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
			local box = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_BALL, 0, player.Position, Vector(0,0), nil):ToEffect()
			box:FollowParent(player)
			box.ParentOffset = Vector(0,0.1)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,hitbox)

local function hitbox2(_,effect) --硫磺火老实点，当判定点去
	if Isaac.GetChallenge() == (IBS_Challenge.bc4) then
		effect.SpriteScale = Vector(0.23,0.23)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE,hitbox2, 113)
----


--完成
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH , function()
	if IsUnlockable(9) then
		if not IBS_Data.Setting["bc4"] then			
			ShowPaper()
		end
		IBS_Data.Setting["bc4"] = true
		mod:SaveIBSData()
	end
end, EntityType.ENTITY_HUSH)

