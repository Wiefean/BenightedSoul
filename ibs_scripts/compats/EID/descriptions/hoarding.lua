--收集癖EID

local HoardingEID = {}

HoardingEID.zh = {

	--套装列表(不包括成人和践踏套装)
	FormList = {
		[ItemConfig.TAG_GUPPY] = '{{Guppy}} 敌人受伤时有10%概率生成蓝苍蝇',

		[ItemConfig.TAG_FLY] = '{{LordoftheFlies}} 敌人死亡时有50%概率生成蓝苍蝇',
		
		[ItemConfig.TAG_MUSHROOM] ='{{FunGuy}} 拾取时，50%概率获得1{{Heart}}心之容器',
		
		[ItemConfig.TAG_ANGEL] = '{{Seraphim}} 拾取时，+ 1{{SoulHeart}}魂心',
		
		[ItemConfig.TAG_BOB] = '{{Bob}} 集齐套装后免疫爆炸',
		
		[ItemConfig.TAG_SYRINGE] = '{{Spun}} + 0.25 {{Damage}}伤害',
		
		[ItemConfig.TAG_MOM] = '{{Mom}} 敌人额外受到0.25伤害',
		
		[ItemConfig.TAG_BABY] = '{{Conjoined}} + 0.15 {{Tears}}射速',
		
		[ItemConfig.TAG_DEVIL] = '{{Leviathan}} 拾取时，+ 1 {{HalfBlackHeart}}半黑心',
		
		[ItemConfig.TAG_POOP] = '{{OhCrap}} 集齐套装后，摧毁大便额外恢复1{{Heart}}红心',
		
		[ItemConfig.TAG_BOOK] = '{{Bookworm}} 使用书时获得(0.5 x 最大充能 x 套件数量)秒的护盾',
		
		[ItemConfig.TAG_SPIDER] = '{{SpiderBaby}} 在新房间或新贪婪波次生成2只蓝蜘蛛',

	},

	--践踏套装(不包括变大药)
	StompyFrom = {
		info = '{{Stompy}} + 20碰撞伤害',
		[12] = true, --大蘑菇
		[302] = true, --狮子座
	},

}

HoardingEID.en = {

	FormList = {
		[ItemConfig.TAG_GUPPY] = '{{Guppy}} 10% chance to spawn a blue fly when hurting an enemy',
		
		[ItemConfig.TAG_FLY] = '{{LordoftheFlies}} 50% chance to spawn a blue fly when killing an enemy',
		
		[ItemConfig.TAG_MUSHROOM] = '{{FunGuy}} When gained, 50% chance to gain {{Heart}}Health up',
		
		[ItemConfig.TAG_ANGEL] = '{{Seraphim}} When gained, + 1 {{SoulHeart}}Soul Heart',
		
		[ItemConfig.TAG_BOB] = '{{Bob}} Grants explosion immunity when this transformation is done',
		
		[ItemConfig.TAG_SYRINGE] = '{{Spun}} + 0.25 {{Damage}}dmg',
		
		[ItemConfig.TAG_MOM] = '{{Mom}} Enemies take 0.25 more damage',
		
		[ItemConfig.TAG_BABY] = '{{Conjoined}} + 0.15 {{Tears}}tears',
		
		[ItemConfig.TAG_DEVIL] = '{{Leviathan}} When gained, + 1 {{HalfBlackHeart}}Half Black Heart',
		
		[ItemConfig.TAG_POOP] = '{{OhCrap}} When this transformation is done, heal an extra {{Heart}}Heart from destroying a poop',

		[ItemConfig.TAG_BOOK] = '{{Bookworm}} Provides (0.5 x maxCharges x componentNum) shield when using a book',
		
		[ItemConfig.TAG_SPIDER] = '{{SpiderBaby}} Spawns 2 blue spiders in a new room or a new greed wave',
	},

	StompyFrom = {
		info = '{{Stompy}} + 20 collision damage',
		[12] = true,
		[302] = true,
	},

}

return HoardingEID