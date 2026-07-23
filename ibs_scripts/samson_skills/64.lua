--参孙技能
--倒正义(效果在架势文件)

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(64, {
	IsReversed = true,
})


return Skill