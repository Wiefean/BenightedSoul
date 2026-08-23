--昧化参孙技能信息EID

local mod = Isaac_BenightedSoul
local IBS_ItemID = mod.IBS_ItemID

local BSamsonEID = {}

BSamsonEID.zh = {

	--占位符
	[0] = {
		Common = '(未完成)',
		Calm = '(未完成)',
		Wrath = '(未完成)',
	},

	--愚者
	[1] = {
		Common = '无效果',
		BSamson = '切换房间时，选中最后一张牌',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--魔术师
	[2] = {
		Common = '↓{{Damage}}伤害 x 50% (不叠加)：对近战命中的敌人施加一层标记；每层标记会使敌人额外受到1伤害',
		Calm = '{{Battery}}{{2}} 对所有敌人施加十层标记；在本房间获得追踪效果',
		Wrath = '{{Battery}}{{2}} 所有敌人失去标记层数十倍的血量',
	},

	--女祭司
	[3] = {
		Common = '近战攻击可以摧毁障碍物和门',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{2}} 释放8向震荡波',
	},
	
	--皇后
	[4] = {
		Common = '近战造成流血，攻速提升25%，但范围减少10%',
		Calm = '{{Battery}}{{2}} 进入{{IBSSamsonWrath}}暴怒，获得{{Card4}}皇后效果 (不叠加)，若已有则改为1充能',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonWrath}}暴怒',
	},
	
	--皇帝
	[5] = {
		Common = '近战攻速降低25%，命中敌人时提供1秒护盾，护盾持续期间不可再叠加',
		Calm = '{{Battery}}{{3}} 获得5秒护盾',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--教皇
	[6] = {
		Common = '首次被近战命中的敌人石化1秒',
		Calm = '{{Battery}}{{3}} 对所有敌人施加5秒石化',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--恋人
	[7] = {
		Common = '近战数量 + 1；被多个近战同时命中的敌人有6%概率掉落消逝的{{HalfHeart}}半红心 ({{Luck}}幸运6：12%)',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{3}} 进入{{IBSSamsonWrath}}暴怒，生成消逝的随机心',
	},
	
	--战车
	[8] = {
		Common = '近战伤害，大小和距离会逐渐增加，直到停止攻击或达边界',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
	},
	
	--正义
	[9] = {
		Common = '近战伤害降低50%(不叠加)，对命中的敌人发射眼泪',
		Calm = '{{Battery}}{{2}} 进入{{IBSSamsonWrath}}暴怒，下一张牌的充能消耗降低为0',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonCalm}}平静，恢复1充能',
	},
	
	--隐者
	[10] = {
		Common = '(不叠加) 近战数量 + 2，攻速降低50%',
		Calm = '{{Battery}}{{3}} 发射30个随机方向的弹射硬币眼泪',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--命运之轮
	[11] = {
		Common = '近战范围增加10%；飞行',
		Calm = '{{Battery}}{{0}} 进入{{IBSSamsonWrath}}暴怒，传送至随机敌人附近发动近战攻击',
		Wrath = '{{Battery}}{{3}} 同上，概率重复多次',
	},
	
	--力量
	[12] = {
		Common = '角色体型增加10% (不叠加)',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{3}} 进入{{IBSSamsonWrath}}暴怒，获得{{Card12}}力量效果，最多叠加2次',
	},
	
	--倒吊人
	[13] = {
		Common = '飞行',
		Calm = '{{Battery}}{{0}} 切换至最后一张牌',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonWrath}}暴怒，切换至最后一张牌',
	},
	
	--死亡
	[14] = {
		Common = '近战攻击时，对{{Range}}射程内的所有敌人造成13%{{Damage}}伤害',
		Calm = '{{Battery}}{{2}} 触发{{Card14}}死亡的效果',
		Wrath = '{{Battery}}{{2}} 同上',
	},
	
	--节制
	[15] = {
		Common = '停止近战3秒后，下一次近战的伤害提升100%，范围增加25%',
		Calm = '{{Battery}}{{0}} 恢复1充能，4秒冷却',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonCalm}}平静，恢复1充能，3秒冷却',
	},

	--恶魔
	[16] = {
		Common = '(不叠加) 近战施加硫磺标记，攻速降低33%；有硫磺标记的敌人额外受到66%伤害',
		Calm = '{{Battery}}{{1}} 进入{{IBSSamsonWrath}}暴怒',
		Wrath = '{{Battery}}{{2}} 进入{{IBSSamsonWrath}}暴怒，获得{{Card16}}恶魔效果',
	},
	
	--塔
	[17] = {
		Common = '免疫爆炸；近战命中时有16%概率爆炸，造成200%{{Damage}}伤害 ({{Luck}}幸运17：50%)',
		Calm = '{{Battery}}{{2}} 进入{{IBSSamsonWrath}}暴怒，原地爆炸',
		Wrath = '{{Battery}}{{2}} 同上',
	},
	
	--星星
	[18] = {
		Common = '↑{{Luck}}幸运 + 1；近战额外造成200%{{Luck}}幸运的伤害，附带具有等量伤害的眼泪 (幸运低于1时不发射)',
		Calm = '{{Battery}}{{3}} 进入{{IBSSamsonWrath}}暴怒，在本层 + 1{{Luck}}幸运',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--月亮
	[19] = {
		Common = '近战施加减速，冻结击杀的敌人，18%概率直接冻结非头目敌人 ({{Luck}}幸运41：100%)',
		Calm = '{{Battery}}{{0}} 下一次近战攻击会冻结非头目敌人',
		Wrath = '{{Battery}}{{1}} 进入{{IBSSamsonCalm}}平静',
	},
	
	--太阳
	[20] = {
		Common = '近战命中的敌人会被点燃；近战有25%概率释放火焰 ({{Luck}}幸运15：100%)',
		Calm = '{{Battery}}{{2}} 进入{{IBSSamsonWrath}}暴怒，释放一圈火焰',
		Wrath = '{{Battery}}{{2}} 同上',
	},
	
	--审判
	[21] = {
		Common = '(不叠加) 近战伤害降低50%，命中的敌人会失去等量生命，若血量低于20%则直接死亡',
		Calm = '{{Battery}}{{0}} 进入{{IBSSamsonWrath}}暴怒，2秒冷却',
		Wrath = '{{Battery}}{{0}} 进入{{IBSSamsonCalm}}平静，2秒冷却',
	},
	
	--世界
	[22] = {
		Common = '无效果',
		Calm = '{{Battery}}{{6}} 消耗该牌，生成5张其他的正位塔罗牌',
		Wrath = '{{Battery}}{{6}} 同上',
	},

	--倒愚者
	[56] = {
		Common = '↑ 每个空的逆位塔罗牌槽位提供1{{Damage}}伤害和{{Tears}}射速',
	},
	
	--倒魔术师
	[57] = {
		Common = '↑ {{Damage}}伤害 x 200%；!!! 受到惩罚性伤害时，在本层获得一层标记；每层标记会使自身额外受到半心伤害',
	},
	
	--倒女祭司
	[58] = {
		Common = '每近战攻击5次，释放震荡波',
	},
	
	--倒皇后
	[59] = {
		Common = '{{IBSSamsonWrath}}暴怒不再翻倍{{Damage}}伤害和受伤',
	},
	
	--倒皇帝
	[60] = {
		Common = '{{IBSSamsonCalm}}平静护盾可以叠加，但持续时间缩短1秒',
	},
	
	--倒教皇
	[61] = {
		Common = '{{IBSSamsonCalm}}平静提供的护盾改为无敌时间',
	},
	
	--倒恋人
	[62] = {
		Common = '(不叠加) 近战数量 - 2；每有一种心，近战伤害提升20%，范围增加5%',
	},
	
	--倒战车
	[63] = {
		Common = '站立不动时，近战攻速提升60%',
	},
	
	--倒正义
	[64] = {
		Common = '(不叠加){{Collectible'..(IBS_ItemID.Posture)..'}}架势伤害充能量翻倍，但清理房间不再为其充能',
	},
	
	--倒隐者
	[65] = {
		Common = '↑ 每有1个{{Coin}}硬币，+ 0.04 {{Damage}}伤害',
	},
	
	--倒命运之轮
	[66] = {
		Common = '{{IBSSamsonWrath}}暴怒期间，即将受到惩罚性伤害时，消耗随机牌代替；↓这张牌被消耗时 - 1{{Luck}}幸运；↑其他牌被消耗时 + 0.25{{Luck}}幸运，并生成其反转版本',
	},

	--倒力量
	[67] = {
		Common = '↓ {{Damage}}伤害 x 75% (不叠加)；近战施加虚弱',
	},

	--倒倒吊人
	[68] = {
		Common = '切换房间后，下一次近战攻击会点金敌人',
	},
	
	--倒死亡
	[69] = {
		Common = '{{IBSSamsonWrath}}暴怒期间受伤不再消耗牌',
	},
	
	--倒节制
	[70] = {
		Common = '{{IBSSamsonWrath}}暴怒持续时间无限',
	},
	
	--倒恶魔
	[71] = {
		Common = '{{IBSSamsonCalm}}平静护盾持续时间延长0.5秒；{{IBSSamsonWrath}}暴怒持续时间减半 (不叠加)；切换房间时，进入{{IBSSamsonCalm}}平静并获得护盾',
	},

	--倒塔
	[72] = {
		Common = '爆炸会治疗角色{{HalfHeart}}半红心',
	},	
	
	--倒星星
	[73] = {
		Common = '↓ - 7 {{Luck}}幸运；↑ 每消耗过一张牌，+ 1 {{Luck}}幸运；敌人额外受到 20% x {{Luck}}幸运 点伤害 (取绝对值)',
	},
	
	--倒月亮
	[74] = {
		Common = '切换房间时，进入{{IBSSamsonWrath}}暴怒',
	},
	
	--倒太阳
	[75] = {
		Common = '↑ 切换姿态后，+ 190% 不断衰减的{{Tears}}射速倍率',
	},
	
	--倒审判
	[76] = {
		Common = '进入{{IBSSamsonCalm}}平静时，生成追踪角色的光柱 (不会伤害角色)，光柱存在时无效',
	},
	
	--倒世界
	[77] = {
		Common = '↑ 自动消耗其他槽位的逆位塔罗牌，每张 + 0.5{{Damage}}伤害和21%{{DevilRoom}}恶魔房开启率；秘密出口保持开启',
	},
	
}


BSamsonEID.en = {

	[0] = {
		Common = '(Unfinished)',
		Calm = '(Unfinished)',
		Wrath = '(Unfinished)',
	},

	[1] = {
		Common = 'No effect',
		BSamson = 'When changing rooms, select the last card',
		Calm = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonCalm}}Calm',
	},

	[2] = {
		Common = '↓{{Damage}}DMG x 50% (not stackable); Apply a mark to enemies hit by swing; Each mark let enemies take 1 more damage',
		Calm = '{{Battery}}{{2}} Apply 10 marks to all enemies; Gain homing effect in the current room',
		Wrath = '{{Battery}}{{2}} All enemies lose Hp equalling to 10x marks',
	},

	[3] = {
		Common = 'Swing can destroy obstacles and doors',
		Calm = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
		Wrath = '{{Battery}}{{2}} Fire 8-dir shockwaves',
	},

	[4] = {
		Common = 'Swing applies bleeding, 25% faster but in 10% smaller range',
		Calm = '{{Battery}}{{2}} Enter {{IBSSamsonWrath}}Wrath; Gain {{Card4}}The Empress effect, if already then cost 1 charge inserted',
		Wrath = '{{Battery}}{{0}} Enter {{IBSSamsonWrath}}Wrath',
	},

	[5] = {
		Common = 'Swing 25% slower, + 1s sheild when hitting enemies, not stackable during sheilded',
		Calm = '{{Battery}}{{2}} + 5s sheild',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonCalm}}Calm',
	},

	[6] = {
		Common = 'Petrify enemies firstly hit for 1s',
		Calm = '{{Battery}}{{2}} Petrify all enemies for 5s',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonCalm}}Calm',
	},

	[7] = {
		Common = 'Swing num + 1; Enemies hit by plural swings have 6% chance to drop temporary {{HalfHeart}}Half Heart ({{Luck}}Luck 6: 12%)',
		Calm = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
		Wrath = '{{Battery}}{{3}} Enter {{IBSSamsonWrath}}Wrath, spawn a random temporary heart',
	},

	[8] = {
		Common = 'Swing damage, size and distance will gradually increase until stopping attack or hitting border',
		Calm = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
	},

	[9] = {
		Common = 'Swing with 50% lower damage (not stackable), fire tears to enemies hit',
		Calm = '{{Battery}}{{2}} Enter {{IBSSamsonWrath}}Wrath, next card costs 0 charge',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Calm, + 1 charge',
	},

	[10] = {
		Common = '(Not stackable) Swing num + 2, but 50% slower',
		Calm = '{{Battery}}{{3}} Fire 30 bouncing coin tears in random direction',
		Wrath = '{{Battery}}{{0}} Enter {{IBSSamsonCalm}}Calm',
	},

	[11] = {
		Common = 'Swing in 10% wider range; Grant Flight',
		Calm = '{{Battery}}{{0}} Enter {{IBSSamsonCalm}}Wrath, teleport to a random enemy and swing',
		Wrath = '{{Battery}}{{3}} Ditto, may repeat for a while',
	},
	
	[12] = {
		Common = 'Isaac becomes 10% bigger (not stackable)',
		Calm = '{{Battery}}{{1}} Enter{{IBSSamsonWrath}} Wrath',
		Wrath = '{{Battery}}{{3}} Enter {{IBSSamsonWrath}}Wrath, gain {{Card12}}Strength effect, up to 2',
	},

	[13] = {
		Common = 'Grant flight',
		Calm = '{{Battery}}{{0}} Switch to the last card',
		Wrath = '{{Battery}}{{0}} Enter {{IBSSamsonWrath}}Wrath, switch to the last card',
	},

	[14] = {
		Common = 'While swinging, deal 13% {{Damage}}damage to all enemies in {{Range}}range',
		Calm = '{{Battery}}{{2}} Trigger {{Card14}}Death',
		Wrath = '{{Battery}}{{2}} Ditto',
	},

	[15] = {
		Common = 'Stopping swinging for 3s makes next swing in 25% wider range with 100% higher damage',
		Calm = '{{Battery}}{{0}} + 1 charge, + 4s cooldown',
		Wrath = '{{Battery}}{{0}} Enter {{IBSSamsonCalm}}Calm, + 1 charge, + 3s cooldown',
	},

	[16] = {
		Common = '(Not stackable) Swing applies brimestone mark, 33% slower; Enemies with brimestone mark take extra 66% damage',
		Calm = '{{Battery}}{{1}} Enter {{IBSSamsonWrath}}Wrath',
		Wrath = '{{Battery}}{{2}} Enter {{IBSSamsonWrath}}Wrath, gain {{Card15}}The Devil effect',
	},

	[17] = {
		Common = 'Explosion immunity; Swing has 16% chance to explode when hitting enemies, 200%{{Damage}}damage ({{Luck}}Luck 17：50%)',
		Calm = '{{Battery}}{{2}} Enter {{IBSSamsonWrath}}Wrath, and explode',
		Wrath = '{{Battery}}{{2}} Ditto',
	},

	[18] = {
		Common = '↑{{Luck}}Luck + 1;Swing deals extra 200%{{Luck}}luck damage, fire a tear with the same damage (Invalid when luck is below 1)',
		Calm = '{{Battery}}{{3}} Enter {{IBSSamsonWrath}}Wrath, + 1 {{Luck}}luck in the current level',
		Wrath = '{{Battery}}{{0}} Enter {{IBSSamsonCalm}}Calm',
	},

	[19] = {
		Common = 'Swing applies slowing, freezes enemies killed, 18% chance to directly freeze non-boss enemies ({{Luck}}41: 100%)',
		Calm = '{{Battery}}{{0}} Next swing freezes non-boss enemies',
		Wrath = '{{Battery}}{{1}} Enter {{IBSSamsonCalm}}Calm',
	},

	[20] = {
		Common = 'Swing applies burning; Swing has 25% chance to fire a flame ({{Luck}}Luck 15: 100%)',
		Calm = '{{Battery}}{{2}} Enter {{IBSSamsonWrath}}Wrath, fire flames around',
		Wrath = '{{Battery}}{{2}} Ditto',
	},

	[21] = {
		Common = 'Swing with 50% lower damage, enemies hit lose equal Hp, if below 20%, be killed instantly',
		Calm = '{{Battery}}{{0}} Enter {{IBSSamsonWrath}}Wrath, + 2s cooldown',
		Wrath = '{{Battery}}{{0}} Enter{{IBSSamsonCalm}}Calm, + 2s cooldown',
	},

	[22] = {
		Common = 'No effect',
		Calm = '{{Battery}}{{6}} Cosnume this card, spawn 5 other common tarot cards',
		Wrath = '{{Battery}}{{6}} Ditto',
	},

	[56] = {
		Common = '↑ + 1 {{Damage}}dmg and {{Tears}}tears for each empty reversed tarot slot',
	},

	[57] = {
		Common = '↑ {{Damage}}dmg x 200%; !!! When taking penal damage, gain 1 mark in the current level; Each mark causes extra half a heart hurt',
	},

	[58] = {
		Common = 'Fire shockwaves after every 5 swing',
	},

	[59] = {
		Common = 'Disable double {{Damage}}dmg and hurt from {{IBSSamsonWrath}}Wrath',
	},
	
	[60] = {
		Common = 'Stackable shield from {{IBSSamsonCalm}}Calm, but with less 1s',
	},
	
	[61] = {
		Common = '{{IBSSamsonCalm}}Calm provides invincibility inserted of sheild',
	},

	[62] = {
		Common = '(Not stackable) Swing num - 2; Swing in 5% wider range with 20% higher damage for each kind of hearts',
	},

	[63] = {
		Common = 'Swing 60% faster when standing by',
	},

	[64] = {
		Common = '(Not stackable) Double charge from damage for {{Collectible'..(IBS_ItemID.Posture)..'}}Posture, but none form cleaning rooms anymore',
	},

	[65] = {
		Common = '↑ For each {{Coin}}coin, + 0.04 {{Damage}}dmg',
	},

	[66] = {
		Common = 'Before taking penal damage in {{IBSSamsonWrath}}Wrath, consume a random card instead; ↓If this one, - 1 {{Luck}}luck; ↑If another, + 0.25 {{Luck}}luck, and spawn the reversed version',
	},

	[67] = {
		Common = '↓ {{Damage}}dmg x 75% (not stackable); Swing applies weakness',
	},
	
	[68] = {
		Common = 'The first swing applies midas after changing rooms',
	},

	[69] = {
		Common = 'Taking damage in {{IBSSamsonWrath}}Wrath will not consume cards anymore',
	},

	[70] = {
		Common = 'Infinite {{IBSSamsonWrath}}Wrath duration',
	},	

	[71] = {
		Common = 'Shield from {{IBSSamsonCalm}}Calm lasts 0.5s longer; Half {{IBSSamsonWrath}}Wrath duration (not stackable); When changing rooms, enter {{IBSSamsonCalm}}Calm and gain sheild',
	},

	[72] = {
		Common = 'Explosion heals Isaac {{HalfHeart}}half a heart',
	},	

	[73] = {
		Common = '↓ - 7 {{Luck}}luck; ↑ For each consumed tarot card, + 1 {{Luck}}luck; Enemies take extra 20% x {{Luck}}luck damage (absolute value)',
	},

	[74] = {
		Common = 'When changing rooms, enter {{IBSSamsonWrath}}Wrath',
	},

	[75] = {
		Common = '↑ When changing states, + 190% decaying {{Tears}}tears multiplier',
	},

	[76] = {
		Common = 'When entering {{IBSSamsonWrath}}Calm, lower a light pillar following Isaac (no hurt), not available if exists',
	},

	[77] = {
		Common = '↑ Automatically consume reversed tarot in other slots, + 0.5 {{Damage}}dmg and 21% {{Devil}}devil chance for each; Secret Exit keeps open',
	},

}


return BSamsonEID