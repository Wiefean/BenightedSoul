--参孙技能Class

--[[

这个只负责实现技能效果
关于技能触发和兼容列表详情需要用到参孙技能管理器(samson_skill_manager.lua)

"info_tbl"可包含内容:
{

CalmStateTrans, --准备从平静切换到的姿态,0表示平静,1表示暴怒
WrathStateTrans, --准备从暴怒切换到的姿态,0表示平静,1表示暴怒

CalmCost, --平静充能消耗
WrathCost, --暴怒充能消耗

CalmOnUse, --平静使用
WrathOnUse, --暴怒使用

PreAttack, --准备攻击,
OnAttack, --攻击,
PostAttack, --攻击后,

IsReversed, --是否为倒卡

}

具体使用在架势道具文件


]]

local mod = Isaac_BenightedSoul
local Ents = mod.IBS_Lib.Ents
local Players = mod.IBS_Lib.Players

local Component = mod.IBS_Class.Component

local SamsonSkill = mod.Class(Component, function(self, id, info_tbl)
	Component._ctor(self)

	self.ID = id
	self.CalmStateTrans = info_tbl.CalmStateTrans
	self.WrathStateTrans = info_tbl.WrathStateTrans
	self.CalmCost = info_tbl.CalmCost
	self.WrathCost = info_tbl.WrathCost	
	self.CalmOnUse = info_tbl.CalmOnUse
	self.WrathOnUse = info_tbl.WrathOnUse
	self.PreAttack = info_tbl.PreAttack
	self.OnAttack = info_tbl.OnAttack
	self.PostAttack = info_tbl.PostAttack
	self.IsReversed = info_tbl.IsReversed or false

	--获取实体临时数据
	function self:GetTempData(ent, onlyGet)
		local data = Ents:GetTempData(ent)
		
		--仅读取不创建
		if onlyGet then
			if data.SAMSON_SKILL_DATA and data.SAMSON_SKILL_DATA[self.ID] then
				return data.SAMSON_SKILL_DATA[self.ID]
			end
		else		
			data.SAMSON_SKILL_DATA = data.SAMSON_SKILL_DATA or {}
			data.SAMSON_SKILL_DATA[self.ID] = data.SAMSON_SKILL_DATA[self.ID] or {}
			return data.SAMSON_SKILL_DATA[self.ID]
		end
	end	
	
	--获取玩家数据
	function self:GetPlayerData(player, onlyGet)
		local data = Players:GetData(player)
		local key = tostring(self.ID)
		
		--仅读取不创建
		if onlyGet then
			if data.SAMSON_SKILL_DATA and data.SAMSON_SKILL_DATA[key] then
				return data.SAMSON_SKILL_DATA[key]
			end
		else		
			data.SAMSON_SKILL_DATA = data.SAMSON_SKILL_DATA or {}
			data.SAMSON_SKILL_DATA[key] = data.SAMSON_SKILL_DATA[key] or {}
			return data.SAMSON_SKILL_DATA[key]
		end
	end		
	
	--是否为昧化参孙
	function self:IsBSamson(player)
		return player:GetPlayerType() == mod.IBS_PlayerID.BSamson
	end
	
	--获取姿态
	function self:GetBSamsonState(player)
		return mod.IBS_Player.BSamson:GetState(player)
	end
	
	--切换姿态
	function self:ChangeSamsonState(player, state)
		mod.IBS_Player.BSamson:ChangeState(player, state)
	end
	
	--是否持有牌
	function self:HasCard(player, id)
		return mod.IBS_Item.Posture:HasCard(player, id or self.ID)
	end	
	
	--获取牌数量
	function self:GetCardNum(player, id)
		return mod.IBS_Item.Posture:GetCardNum(player, id or self.ID)
	end	
	
	--任意玩家持有牌
	function self:AnyHasCard(id)
		id = id or self.ID
		for i = 0, Game():GetNumPlayers() -1 do
			local player = Isaac.GetPlayer(i)
			if mod.IBS_Item.Posture:HasCard(player, id) then
				return true
			end
		end	
		return false
	end
	
	--获取当前牌
	function self:GetCurrentCard(player)
		return mod.IBS_Item.Posture:GetCurrentCard(player)
	end
	function self:IsCurrentCard(player)
		return mod.IBS_Item.Posture:GetCurrentCard(player) == self.ID
	end
	
	
end)

return SamsonSkill





