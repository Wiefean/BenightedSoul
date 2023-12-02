--其他实体
--部分实体包含在对应的道具等lua文件里


--加载
local function LoadScripts(scripts)
    for _, v in ipairs(scripts) do
        include("ibs_scripts.entities."..v)
    end
end

local entities = {
	"bosses.temperance",
	"bosses.fortitude",
	
	"effects.pickingup",
	"effects.benighting",
}
LoadScripts(entities)


local mod = Isaac_BenightedSoul
local IBS_Boss = mod.IBS_Boss
local Translations = mod.IBS_Lib.Translations

local LANG = mod.Language

--新房间Boss替换提醒
local function BossReplacedReminder()
	mod:DelayFunction(function()
		for _,Boss in pairs(IBS_Boss) do
			if #Isaac.FindByType(Boss.Type, Boss.Variant, Boss.SubType, false, true) > 0 then
				local info = Translations[LANG].BossReplaced[Boss.Key]	
				Game():GetHUD():ShowItemText(info.Title, info.Sub)
			end
		end
	end, 1)
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.LATE, BossReplacedReminder)


