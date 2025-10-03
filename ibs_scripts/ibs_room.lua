--房间(仅部分)


local mod = Isaac_BenightedSoul

local function Load(fileName)
	return include("ibs_scripts.rooms."..fileName)
end

mod.IBS_Room = {
	Elegiast = Load('elegiast'),

}

