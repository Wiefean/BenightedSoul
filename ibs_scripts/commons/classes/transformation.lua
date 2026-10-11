--套装Class

--[[

"data_key"指的是数据存读系统中对应的索引

"info_tbl"可包含内容:
{
	Name = {
		zh = '中文名',
		en = '英文名',
	},

	CostumeID,--装扮ID

	OnGain, --获得
	OnLose, --失去

	--道具列表
	ItemList = {
		[1] = true,
		[2] = true,
	},
	
}


]]

local mod = Isaac_BenightedSoul

local game = Game()
local config = Isaac.GetItemConfig()
local sfx = SFXManager()


local Component = mod.IBS_Class.Component

local HiddenItemList = {}

local Transformation = mod.Class(Component, function(self, data_key, info_tbl)
	Component._ctor(self)

	self.ID = data_key
	self.Info = info_tbl or {}
	self.CostumeID = info_tbl.CostumeID
	self.ItemList = info_tbl.ItemList or {}
	self.OnGain = info_tbl.OnGain
	self.OnLose = info_tbl.OnLose

	--是否启用套装
	function self:IsAvailable()
		return self:GetIBSData("persis")[data_key]
	end

	--获取数据
	function self:GetTrData(player, onlyGet)
		local data = self._Players:GetData(player)
		local KEY = "IBSTransformation_"..tostring(data_key)

		if not data[KEY] and not onlyGet then
			data[KEY] = {
				Count = 0,
				Active = false,
				First = true,
			}
		end
		
		return data[KEY]
	end

	--是否拥有套装
	function self:IsOwned(player)
		local data = self:GetTrData(player, true)
		if data then
			return data.Active
		end
		return false
	end

	--更新状态
	function self:UpdateState(player)
		local data = self:GetTrData(player)
		if data.Count < 0 then data.Count = 0 end
		
		if data.Count >= 3 and self:IsAvailable() then
			if not data.Active then
				if self.OnGain then				
					self.OnGain(player, data.First)
				end
				if self.CostumeID then
					player:AddNullCostume(self.CostumeID)
				end
				game:GetHUD():ShowItemText(self:ChooseLanguageInTable(self.Info.Name), "")
				sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER)
			end
			data.First = false
			data.Active = true
		else
			if data.Active then
				if self.OnLose then				
					self.OnLose(player)
				end
				if self.CostumeID then
					player:TryRemoveNullCostume(self.CostumeID)
				end				
			end		
			data.Active = false
		end	
	end

	--获取计数
	function self:GetCount(player)
		local data = self:GetTrData(player, true)
		if data and data.Count then
			return data.Count
		end
		return 0
	end

	--添加计数
	function self:AddCount(player, num, update)
		local data = self:GetTrData(player)
		data.Count = math.max(0, data.Count + num)
		
		if update then
			self:UpdateState(player)
		end
	end

	--获得道具检测
	local function OnGainItem(_,item, charge, first, slot, varData, player)
		if not self:IsAvailable() then return end
	
		if first and self.ItemList[item] then
			self:AddCount(player, 1, true)
		end
	end
	mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, OnGainItem)

	--失去道具检测
	local function OnRemoveItem(_,player, item)
		if not self:IsAvailable() then return end
	
		local itemConfig = config:GetCollectible(item)
		
		--排除主动
		if self.ItemList[item] and itemConfig and itemConfig.Type ~= 3 then
			self:AddCount(player, -1, true)
		end
	end
	mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, OnRemoveItem)


end, { {expectedType = 'string'}, {expectedType = 'table'} })


return Transformation
