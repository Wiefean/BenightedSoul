--成就系统

local mod = Isaac_BenightedSoul

local function LoadItem(fileName)
	return include('ibs_scripts.achievements.items.items.lock_'..fileName)
end
local function LoadPlayer(fileName)
	return include('ibs_scripts.achievements.players.lock_'..fileName)
end
local function LoadMark(fileName)
	return include('ibs_scripts.achievements.marks.marks_'..fileName)
end
local function LoadChallenge(fileName)
	return include('ibs_scripts.achievements.challenges.'..fileName)
end

mod.IBS_Achiev = {
	--道具锁
	ItemLock = {
		DreggyPie = LoadItem('dreggy_pie'),
		GoldExperience = LoadItem('gold_experience'),
	},

	--角色锁
	CharacterLock = {
		BIsaac = LoadPlayer('bisaac'),
		BMaggy = LoadPlayer('bmaggy'),
		BCBA = LoadPlayer('bcain_and_babel'),
		BJudas = LoadPlayer('bjudas'),
		BXXX = LoadPlayer('bxxx'),
		BEden = LoadPlayer('beden'),
		BLost = LoadPlayer('blost'),
		BKeeper = LoadPlayer('bkeeper'),
	},

	--通关标记
	Marks = {
		BIsaac = LoadMark('bisaac'),
		BMaggy = LoadMark('bmaggy'),
		BCBA = LoadMark('bcain_and_babel'),
		BJudas = LoadMark('bjudas'),
		BXXX = LoadMark('bxxx'),
		BEden = LoadMark('beden'),
		BEden = LoadMark('blost'),
		BKeeper = LoadMark('bkeeper'),
	},
	
	--挑战
	Challenge = {
		[1] = LoadChallenge('1'),
		[2] = LoadChallenge('2'),
		[3] = LoadChallenge('3'),
		[4] = LoadChallenge('4'),
		[5] = LoadChallenge('5'),

		[10] = LoadChallenge('10'),
		[11] = LoadChallenge('11'),
		
		[13] = LoadChallenge('13'),
	},
}

