--嫉妒致胜

local mod = Isaac_BenightedSoul

local game = Game()

local EnvyToWin = mod.IBS_Class.Trinket(mod.IBS_TrinketID.EnvyToWin)


function EnvyToWin:OnNewRoom()
	if not PlayerManager.AnyoneHasTrinket(self.ID) then return end
	local room = game:GetRoom()
	local roomType = room:GetType()
	
	--检测boss房或小boss房
	if roomType ~= RoomType.ROOM_BOSS and roomType ~= RoomType.ROOM_MINIBOSS then
		return
	end

	--检测清理状态
	if room:IsClear() then return end
	
	Isaac.Spawn(51,1,0, room:GetCenterPos(), Vector.Zero, nil)
end
EnvyToWin:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')

--击杀嫉妒生成硬币
function EnvyToWin:OnNpcDeath(npc)
	if npc.SubType > 0 then return end
	if not PlayerManager.AnyoneHasTrinket(self.ID) then return end
	local variant = npc.Variant
	
	if variant == 0
		or variant == 10
		or variant == 20
		or variant == 30
		or variant == 1
		or variant == 11
		or variant == 21
		or variant == 31
	then
		local mult = PlayerManager.GetTotalTrinketMultiplier(self.ID)
		if RNG(npc.InitSeed):RandomInt(100) < 50*mult then
			Isaac.Spawn(5,20,0, npc.Position, RandomVector(), npc)
		end
	end
end
EnvyToWin:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, 'OnNpcDeath', 51)

return EnvyToWin