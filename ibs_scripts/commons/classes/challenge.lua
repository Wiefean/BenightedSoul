--挑战Class

--[[
"Key"指的是数据存读系统中对应的索引


"info_tbl"可包含内容:
{

--成就贴图名
PaperNames = {
	'贴图名',
	'贴图名',
	'贴图名',
	...

--终点(字符串)	
Destination,

}, 


}


]]

local mod = Isaac_BenightedSoul
local IBS_ChallengeID = mod.IBS_ChallengeID
local IBS_PlayerKey = mod.IBS_PlayerKey
local Component = mod.IBS_Class.Component

local game = Game()

--Boss信息(用于检查目的地)
local BossInfo = {
	Foot = {Stage = 6, BossID = BossType.MOM}, --腿
	Heart = {Stage = 8}, --心脏
	Isaac = {Stage = 10, BossID = BossType.ISAAC}, --以撒
	BlueBaby = {Stage = 11, BossID = BossType.BLUE_BABY}, --蓝人
	Satan = {Stage = 10, BossID = BossType.SATAN}, --撒旦
	Lamb = {Stage = 11, BossID = BossType.LAMB}, --羔羊
	MegaSatan = {Stage = 11, BossID = BossType.MEGA_SATAN}, --超级撒旦
	Hush = {Stage = 9, BossID = BossType.HUSH}, --死寂
	Delirium = {Stage = 12, BossID = BossType.DELIRIUM}, --精神错乱
	Witness = {Stage = 8, BossID = BossType.MOTHER}, --见证者
	Greed = {Stage = 7, BossID = BossType.ULTRA_GREED}, --贪婪
}

local Challenge = mod.Class(Component, function(self, number, info_tbl)
	Component._ctor(self)

	self.ID = IBS_ChallengeID[number]
	self.Key = 'bc'..tostring(number)
	self.Info = info_tbl or {}

	--是否在挑战中
	function self:Challenging()
		return (Isaac.GetChallenge() == self.ID)
	end

	--是否在终点
	function self:AtDestination(dest)
		if not self:Challenging() then
			return false
		end
	
		dest = dest or self.Info.Destination
	
		local info = BossInfo[dest] or {}
		local room = game:GetRoom()

		--检测房间和楼层是否正确
		if game:GetRoom():GetType() ~= RoomType.ROOM_BOSS then
			return false
		end
		if info.BossID and info.BossID ~= room:GetBossID() then
			return false
		end
		if info.Stage and info.Stage ~= game:GetLevel():GetStage() then
			return false
		end

		--贪婪标记只有贪婪模式能拿
		if dest == 'Greed' and not game:IsGreedMode() then
			return false
		end

		return true
	end

	--是否已完成
	function self:IsFinished()
		return self:GetIBSData('persis')[self.Key]
	end

	--是否未完成
	function self:IsUnfinished()
		return (not self:GetIBSData('persis')[self.Key])
	end

	--取消完成
	function self:Unfinish(instantSave)
		self:GetIBSData('persis')[self.Key] = false
		
		--即时保存
		if instantSave then
			self:SaveIBSData()
		end
	end

	--完成
	function self:Finish(showPaper, instantSave)
		self:GetIBSData('persis')[self.Key] = true

		--弹出纸张
		if showPaper and self.Info.PaperNames then
			for _,v in ipairs(self.Info.PaperNames) do
				self._Screens:PlayPaper(v)
			end
		end

		--即时保存
		if instantSave then
			self:SaveIBSData()
		end		
	end

end, { {expectedType = 'number'}, {expectedType = 'table', allowNil = true} })




return Challenge
