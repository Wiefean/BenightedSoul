--参孙技能
--倒恶魔(效果在参孙文件)

local mod = Isaac_BenightedSoul

local game = Game()
local sfx = SFXManager()

local Skill = mod.IBS_Class.SamsonSkill(71, {
	IsReversed = true,
})

return Skill