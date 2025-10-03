--角色

local mod = Isaac_BenightedSoul

local function Load(fileName)
	return include('ibs_scripts.players.'..fileName)
end

mod.IBS_Player = {
	BIsaac = Load('bisaac'),
	BMaggy = Load('bmaggy'),
	BCBA = Load('bcain_and_babel'),
	BJudas = Load('bjudas'),
	BXXX = Load('bxxx'),
	BEden = Load('beden'),
	BLost = Load('blost'),
	BKeeper = Load('bkeeper'),
}

