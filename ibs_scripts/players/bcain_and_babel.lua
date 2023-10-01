--昧化该隐&亚伯

local mod = Isaac_BenightedSoul
local IBS_Callback = mod.IBS_Callback
local IBS_Item = mod.IBS_Item
local IBS_Player = mod.IBS_Player
local IBS_Sound = mod.IBS_Sound
local Pools = mod.IBS_Lib.Pools
local Finds = mod.IBS_Lib.Finds
local Ents = mod.IBS_Lib.Ents

local sfx = SFXManager()


--临时玩家数据
local function GetPlayerData(player)
	local data = Ents:GetTempData(player)
	data.BISAAC = data.BISAAC or {
		PlayerMatched = false,
		CostumeState = "none"
	}

	return data.BISAAC
end

--变身
local function Henshin(_,player)
	if player:GetActiveItem(0) == 105 then
		player:RemoveCollectible(105, true, 0)
		player:ChangePlayerType(IBS_Player.bisaac)
		player:AddSoulHearts(6)
		player:AddMaxHearts(-6)
		player:SetPocketActiveItem(IBS_Item.ld6, ActiveSlot.SLOT_POCKET, false)
		
		--如果完成了对应挑战,生成一个骰子碎片
		if IBS_Data.Setting["bc1"] then
			sfx:Play(500, 0.7)
			Isaac.Spawn(5, 300, 49, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, nil)
		end
		
		player:SetColor(Color(1,1,0,0.5,1,1,0), 30, 7, true, false)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
	end
end
mod:AddCallback(IBS_Callback.BENIGHTED_HENSHIN, Henshin, PlayerType.PLAYER_ISAAC)

--初始化角色
local function OnInit(_,player)
    local game = Game()
    if player:GetPlayerType() == (IBS_Player.bcain) then
		if not player.Child or not player.Parent then
			Isaac.ExecuteCommand("addplayer "..tostring(IBS_Player.babel).." "..tostring(player.ControllerIndex))

			local babel = Isaac.GetPlayer(game:GetNumPlayers() -1)
			babel.Parent = player
			babel.Position = player.Position + Vector(30,0)
			
			player.Child = babel
			player.Position = player.Position - Vector(30,0)
			
			game:GetHUD():AssignPlayerHUDs()
		end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, OnInit)


