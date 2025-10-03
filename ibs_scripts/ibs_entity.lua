--其他实体

local mod = Isaac_BenightedSoul

--Boss
local function Load(fileName)
	return include('ibs_scripts.entities.bosses.'..fileName)
end
mod.IBS_Boss = {

--勤劳
Diligence = Load('diligence'),

--坚韧
Fortitude = Load('fortitude'),

--节制
Temperance = Load('temperance'),

--慷慨
Generosity = Load('generosity'),

--谦逊
Humility = Load('humility'),


}




--眼泪
local function Load(fileName)
	return include('ibs_scripts.entities.tears.'..fileName)
end
mod.IBS_Tear = {

--劳锤眼泪
DiligenceHammerTear = Load('diligence_hammer_tear'),


}




--跟班
local function Load(fileName)
	return include('ibs_scripts.entities.familiars.'..fileName)
end
mod.IBS_Familiar = {

--魂火之灵
Wisper = Load('wisper'),

--护主之刃
Sword = Load('sword'),

--伪忆球
BXXXOrb = Load('bxxx_orb'),

--018
SCP018 = Load('018'),

--箱子僚机
BLostFloat = Load('blost_float'),

--箱子武器
BLostWeapon = Load('blost_weapon'),

--AKEY47
AKEY47 = Load('akey47'),


}




--掉落物
local function Load(fileName)
	return include('ibs_scripts.entities.pickups.'..fileName)
end
mod.IBS_Pickup = {

--种子袋
SeedBag = Load('seed_bag'),

--记忆碎片
Memory = Load('memory'),

--遗物泡影
Relic = Load('relic'),

--勤劳小麦
DeligenceWheat = Load('deligence_wheat'),


}




--可互动实体
local function Load(fileName)
	return include('ibs_scripts.entities.slots.'..fileName)
end
mod.IBS_Slot = {

--募捐箱
CollectionBox = Load('collectionbox'),

--真理小子
Albern = Load('albern'),

--换脸商
Facer = Load('facer'),

--使者
Envoy = Load('envoy'),

}




--敌弹
local function Load(fileName)
	return include('ibs_scripts.entities.projectiles.'..fileName)
end
mod.IBS_Proj = {

--劳锤
DiligenceHammer = Load('diligence_hammer'),

}




--效果
local function Load(fileName)
	return include('ibs_scripts.entities.effects.'..fileName)
end
mod.IBS_Effect = {

--用于昧化角色变身的光柱,现仅用于多人模式
Benighting = Load('benighting'),

--犹大福音
TGOJ = Load('the_gospel_of_judas'),

--犹大福音冲刺特效
TGOJDash = Load('the_gospel_of_judas_dash'),

--大光柱,用于不受欢迎的祭品
BigLight = Load('big_light'),

--扫荡(骨棒近战攻击特效)
Swing = Load('swing'),

--勤勤扫荡(小boss)
DeligenceSwing = Load('deligence_swing'),

--遗弃物品
AbandonedItem = Load('abandoned_item'),

--劳灯
DiligenceLamp = Load('diligence_lamp'),

--箱子斗篷(昧化游魂使用)
ChestMantle = Load('chest_mantle'),

--震荡波特供版
ShockWave = Load('shock_wave'),

--空实体
Empty = Load('empty'),

}



