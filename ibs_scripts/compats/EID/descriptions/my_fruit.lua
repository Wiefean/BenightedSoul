--我果EID


--祝福列表
local BlessList = {
	{
		name = {
			zh = '预知祝福', 
			en = 'Foreknown',
		},
		desc = {
			zh = '清理房间后有50%概率生成正位塔罗牌',
			en = 'When a room is cleared, 50% chance to spawn a common tarot card',
		},
	},
	{
		name = {
			zh = '光明祝福', 
			en = 'Light',
		},
		desc = {
			zh = '排斥敌人和敌弹',
			en = 'Repel enemies and projectiles',
		},
	},
	{
		name = {
			zh = '羽翼祝福', 
			en = 'Wing',
		},
		desc = {
			zh = '+ 0.3{{Speed}}移速; 普通房间的门保持开启',
			en = '+ 0.3 {{Speed}}spd; Doors of normal rooms keep open',
		},
		noGreed = true,
	},
	{
		name = {
			zh = '丰收祝福', 
			en = 'Harvest',
		},
		desc = {
			zh = '清理房间后复制一个掉落物',
			en = 'When a room is cleared, duplicate a pickup',
		},
	},
}		
	
return BlessList