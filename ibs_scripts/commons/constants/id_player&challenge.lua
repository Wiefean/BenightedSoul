--常量,角色&挑战 ID

local mod = Isaac_BenightedSoul

--角色
mod.IBS_PlayerID = {
BIsaac = Isaac.GetPlayerTypeByName("Benighted Isaac"),
BMaggy = Isaac.GetPlayerTypeByName("Benighted Magdalene"),
BCain = Isaac.GetPlayerTypeByName("Benighted Cain"),
BAbel = Isaac.GetPlayerTypeByName("Benighted Abel"),
BJudas = Isaac.GetPlayerTypeByName("Benighted Judas"),
BXXX = Isaac.GetPlayerTypeByName("Benighted ???"),
BEve = Isaac.GetPlayerTypeByName("Benighted Eve"),
BSamson = Isaac.GetPlayerTypeByName("Benighted Samson"),
BEden = Isaac.GetPlayerTypeByName("Benighted Eden"),
BLost = Isaac.GetPlayerTypeByName("Benighted Lost"),
BKeeper = Isaac.GetPlayerTypeByName("Benighted Keeper"),

}

--将角色ID转换为字符串索引
local IBS_PlayerID = mod.IBS_PlayerID
local PlayerTypeToKey = {
	[IBS_PlayerID.BIsaac] = "BIsaac",
	[IBS_PlayerID.BMaggy] = "BMaggy",
	[IBS_PlayerID.BCain] = "BCBA",
	[IBS_PlayerID.BAbel] = "BCBA",
	[IBS_PlayerID.BJudas] = "BJudas",
	[IBS_PlayerID.BXXX] = "BXXX",
	[IBS_PlayerID.BEve] = "BEve",
	[IBS_PlayerID.BEden] = "BEden",
	[IBS_PlayerID.BLost] = "BLost",
	[IBS_PlayerID.BKeeper] = "BKeeper",
}

--将角色ID转换为字符串索引
IBS_PlayerID._ToKey = function(playerType)
	return PlayerTypeToKey[playerType] or 'NILLLLLLLLLLLLLLLLLL'
end


--角色索引(用于保存数据)
mod.IBS_PlayerKey = {
BIsaac = 'BIsaac',
BMaggy = 'BMaggy',
BCain = 'BCBA',
BAbel = 'BCBA',
BCBA = 'BCBA',
BJudas = 'BJudas',
BXXX = 'BXXX',
BEve = 'BEve',
BEden = 'BEden',
BLost = 'BLost',
BKeeper = 'BKeeper',

}

--挑战
mod.IBS_ChallengeID = {
	[1] = Isaac.GetChallengeIdByName("BC1 Rolling Destiny"),
	[2] = Isaac.GetChallengeIdByName("BC2 The Fragile"),
	[3] = Isaac.GetChallengeIdByName("BC3 Graze !"),
	[4] = Isaac.GetChallengeIdByName("BC4 Passover"),
	[5] = Isaac.GetChallengeIdByName("BC5 Dualcast"),
	[6] = Isaac.GetChallengeIdByName("BC6 Marsh Rooms"),
	
	[10] = Isaac.GetChallengeIdByName("BC10 Envery"),
	[11] = Isaac.GetChallengeIdByName("BC11 Keys are Bomb"),
	
	[13] = Isaac.GetChallengeIdByName("BC13 Generosity Mode"),

}
