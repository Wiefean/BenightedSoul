--套装

local mod = Isaac_BenightedSoul

local function Load(fileName)
	return include("ibs_scripts.transformations."..fileName)
end

mod.IBS_Transformation = {
	Doormaker = Load('doormaker'),
	Bomber = Load('bomber'),
	Abyss = Load('abyss'),

}
