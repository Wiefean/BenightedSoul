--已定义

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local Ents = mod.IBS_Lib.Ents
local Players = mod.IBS_Lib.Players

local sfx = SFXManager()

local Destination = {
	[1] = {Type = RoomType.ROOM_BOSS, Charge = 5},
	[2] = {Type = RoomType.ROOM_SHOP, Charge = 3},
	[3] = {Type = RoomType.ROOM_TREASURE, Charge = 4},
	[4] = {Type = RoomType.ROOM_DUNGEON, Charge = 6},
	[5] = {Type = RoomType.ROOM_BLACK_MARKET, Charge = 6},
	[6] = {Type = RoomType.ROOM_SECRET, Charge = 2},
	[7] = {Type = RoomType.ROOM_SUPERSECRET, Charge = 4},
	[8] = {Type = RoomType.ROOM_ULTRASECRET, Charge = 9},
	[9] = {Type = RoomType.ROOM_DEVIL, Charge = 12}
}

local GreedDestination = {
	[1] = {Type = RoomType.ROOM_SHOP, Charge = 1},
	[2] = {Type = RoomType.ROOM_TREASURE, Charge = 3},
	[3] = {Type = RoomType.ROOM_DUNGEON, Charge = 2},
	[4] = {Type = RoomType.ROOM_BLACK_MARKET, Charge = 4},		
	[5] = {Type = RoomType.ROOM_SUPERSECRET, Charge = 3},
	[6] = {Type = RoomType.ROOM_GREED_EXIT, Charge = 2},
	[7] = {Type = RoomType.ROOM_DEVIL, Charge = 5}
}

local function GetTeleportData(player)
	local data = Ents:GetTempData(player)
	data.DEFINED = data.DEFINED or {Mode = 1}

	return data.DEFINED
end

local function ModeChange(_,player, type, action)
	if (type == 2) and (action == ButtonAction.ACTION_MAP) then
		if player:HasCollectible(IBS_Item.defined) then
			local game = Game()
			if (not game:IsPaused()) and (player:AreControlsEnabled()) then
				local MAX = 9
				if game:IsGreedMode() then
					MAX = 7
				end
				
				local data = GetTeleportData(player)
				if data.Mode < MAX then
					data.Mode = data.Mode + 1
				else
					data.Mode = 1
				end
			end
		end
	end	
end
mod:AddCallback(IBS_Callback.PLAYER_DOUBLE_TAP, ModeChange)

--允许尝试使用
mod:AddCallback(IBS_Callback.TRY_USE_ITEM, function(_,item, player, slot, charges)
	return (charges >= 0) and (charges < 12)
end, IBS_Item.defined)

local function Teleport(_,item, rng, player, flags, slot)
	if (flags & UseFlag.USE_CARBATTERY <= 0) then--拒绝车载电池
		local game = Game()
		local level = game:GetLevel()
		local data = GetTeleportData(player)
		local where = nil
		if game:IsGreedMode() then
			where = GreedDestination[data.Mode]
		else
			where = Destination[data.Mode]
		end
		
		local discharge = where.Charge
		if player:HasCollectible(584) then discharge = discharge - 1 end
		if player:HasCollectible(59) then discharge = discharge - 1 end
		if player:HasCollectible(116) then discharge = discharge - 1 end
		if discharge < 0 then discharge = 0 end
		
		if Players:DischargeSlot(player, slot, discharge, true, false) or (flags & UseFlag.USE_OWNED <= 0) then
			local idx = level:QueryRoomTypeIndex(where.Type, false, rng, true)
			if (where.Type == RoomType.ROOM_DUNGEON) then idx = -13 end --高级商店
			if (flags & UseFlag.USE_OWNED <= 0) or (flags & UseFlag.USE_VOID > 0) then
				idx = level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, false, rng, true)
			end

			game:StartRoomTransition(idx, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
		end
		
		return {ShowAnim = false, Discharge = false}
	end	
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, Teleport, IBS_Item.defined)

--显示模式
local spr = Sprite()
spr:Load("gfx/ibs/ui/items/defined.anm2", true)

local spr_greed = Sprite()
spr_greed:Load("gfx/ibs/ui/items/defined_greed.anm2", true)

local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")

local function RenderMode(_,item, player, slot, pos)
	if (slot == 0) or (slot == 2) then
		local data = GetTeleportData(player)
		
		if data then
			local discharge = 0
			if Game():IsGreedMode() then
				discharge = GreedDestination[data.Mode].Charge
				if player:HasCollectible(584) then discharge = discharge - 1 end
				if player:HasCollectible(59) then discharge = discharge - 1 end
				if player:HasCollectible(116) then discharge = discharge - 1 end
				if discharge < 0 then discharge = 0 end
				
				spr_greed:Play(data.Mode)
				spr_greed:Render(pos)
				fnt:DrawString(discharge, (pos.X)-18, (pos.Y)-22, KColor(1,1,1,1,0,0,0))
			else
				discharge = Destination[data.Mode].Charge
				if player:HasCollectible(584) then discharge = discharge - 1 end
				if player:HasCollectible(59) then discharge = discharge - 1 end
				if player:HasCollectible(116) then discharge = discharge - 1 end
				if discharge < 0 then discharge = 0 end
				
				spr:Play(data.Mode)
				spr:Render(pos)
				fnt:DrawString(discharge, (pos.X)-18, (pos.Y)-22, KColor(1,1,1,1,0,0,0))
			end
		end
	end	
end
mod:AddCallback(IBS_Callback.ACTIVE_SLOT_RENDER, RenderMode, IBS_Item.defined)