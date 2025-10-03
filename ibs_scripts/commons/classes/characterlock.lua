--角色锁Class

--[[
"PlayerKey"指的是数据存读系统中对应的角色索引
]]

local mod = Isaac_BenightedSoul
local Component = mod.IBS_Class.Component

local game = Game()


local CharacterLock = mod.Class(Component, function(self, id, paperNames)
	Component._ctor(self)

	self.ID = id
	self.PlayerKey = mod.IBS_PlayerID._ToKey(id)
	self.PaperNames = paperNames


	--是否已解锁
	function self:IsUnlocked()
		return self:GetIBSData('persis')[self.PlayerKey].Unlocked
	end

	--是否未解锁
	function self:IsLocked()
		return (not self:GetIBSData('persis')[self.PlayerKey].Unlocked)
	end

	--锁
	function self:Lock(instantSave)
		local data = self:GetIBSData('persis')
		data[self.PlayerKey].Unlocked = false
		
		--即时保存
		if instantSave then
			self:SaveIBSData()
		end
	end

	--解锁
	function self:Unlock(showPaper, instantSave)
		local data = self:GetIBSData('persis')
		data[self.PlayerKey].Unlocked = true

		--弹出纸张
		if showPaper and self.PaperNames then
			for _,v in ipairs(self.PaperNames) do
				self._Screens:PlayPaper(v)
			end
		end
		
		--即时保存
		if instantSave then
			self:SaveIBSData()
		end
	end

end, { {expectedType = 'number'}, {expectedType = 'table', allowNil = true} })



return CharacterLock


