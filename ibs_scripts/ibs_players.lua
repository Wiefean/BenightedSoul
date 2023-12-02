--角色

local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.players."..v)
    end
end

local players = {
	"bisaac",
	"bmaggy",
	"bcain_and_babel",
	"bjudas",
}
LoadScripts(players)


local mod = Isaac_BenightedSoul
local IBS_Player = mod.IBS_Player
local Ents = mod.IBS_Lib.Ents
local SpriteDefaultPath = "gfx/001.000_player.anm2"

--角色信息
local IBS_Player_Info = {

[IBS_Player.bisaac] = {
	Costume = Isaac.GetCostumeIdByPath("gfx/ibs/characters/bisaac_cross.anm2")
},
	
[IBS_Player.bmaggy] ={
	Costume = Isaac.GetCostumeIdByPath("gfx/ibs/characters/bmaggy_hair.anm2"),
	SpritePath = "gfx/ibs/characters/player_bmaggy.anm2",
	SpriteFlightPath = "gfx/ibs/characters/player_bmaggy_flight.anm2"
},

[IBS_Player.bcain] ={
	Costume = Isaac.GetCostumeIdByPath("gfx/ibs/characters/bcain_hat.anm2"),
	SpritePath = "gfx/ibs/characters/player_bcain.anm2",
	SpriteFlightPath = "gfx/ibs/characters/player_bcain.anm2"
},

[IBS_Player.babel] ={
	Costume = Isaac.GetCostumeIdByPath("gfx/ibs/characters/babel_hair.anm2"),
	SpritePath = "gfx/ibs/characters/player_babel.anm2",
	SpriteFlightPath = "gfx/ibs/characters/player_babel.anm2"
},

[IBS_Player.bjudas] ={
	Costume = Isaac.GetCostumeIdByPath("gfx/ibs/characters/bjudas_mitre_and_mantle.anm2"),
	SpritePath = "gfx/ibs/characters/player_bjudas.anm2",
	SpriteFlightPath = "gfx/ibs/characters/player_bjudas.anm2"
},

}

--临时数据
local function GetPlayerCostumeData(player)
	local data = Ents:GetTempData(player)
	
	if not data.IBSPlayerCostume then
		data.IBSPlayerCostume = {
			PlayerType = 0,
			SpriteState = 0,
			CostumeState = 0
		}
	end
	
	return data.IBSPlayerCostume
end

--更换角色动画文件
local function ChangeSprite(player, anm2path)
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
local function UpdatePlayerSprite(_,player)
	local playerType = player:GetPlayerType()
	local TheCostume = IBS_Player_Info[playerType]
	
	if TheCostume then
		local data = GetPlayerCostumeData(player)
		
		--检测装扮和动画文件是否正确
		if data.PlayerType ~= playerType then
			local FalseCostume = IBS_Player_Info[data.PlayerType]
			if FalseCostume then
				if FalseCostume.SpritePath and FalseCostume.SpriteFlightPath and not (TheCostume.SpritePath and TheCostume.SpriteFlightPath) then
					ChangeSprite(player, SpriteDefaultPath)
				end
				if FalseCostume.Costume then
					player:TryRemoveNullCostume(FalseCostume.Costume)
				end	
			end
			data.PlayerType = playerType
			data.SpriteState = 0
			data.CostumeState = 0
		end	
		
		--更换角色动画文件
		if TheCostume.SpritePath and TheCostume.SpriteFlightPath then
			local sprState = 1
			local spritePath = TheCostume.SpritePath
			local spriteFlightPath = TheCostume.SpriteFlightPath
			local path = spritePath
			if player.CanFly then path = spriteFlightPath sprState = 2 end --飞行
			
			--超大蘑菇
			if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
				path = SpriteDefaultPath
				sprState = 0
			end
		
			if data.SpriteState ~= sprState then
				data.SpriteState = sprState
				ChangeSprite(player, path)
			end	
		end
		
		--装扮
		if TheCostume.Costume then
			local costumeState = 1
			local costume = TheCostume.Costume
			
			if data.CostumeState ~= costumeState then
				data.CostumeState = costumeState
				player:TryRemoveNullCostume(costume)
				
				if data.CostumeState == 1 then
					player:AddNullCostume(costume)
				end
			end
		end
	else
		local data = Ents:GetTempData(player).IBSPlayerCostume
		if data then
			local FalseCostume = IBS_Player_Info[data.PlayerType]
			if FalseCostume then
				if FalseCostume.SpritePath and FalseCostume.SpriteFlightPath then
					ChangeSprite(player, SpriteDefaultPath)
				end
				if FalseCostume.Costume then
					player:TryRemoveNullCostume(FalseCostume.Costume)
				end	
				Ents:GetTempData(player).IBSPlayerCostume = nil
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, UpdatePlayerSprite, 0)
