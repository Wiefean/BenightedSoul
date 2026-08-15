--昧化游魂EID


--箱子描述
local Chest = {
	[PickupVariant.PICKUP_CHEST] = {
		Name = {'箱子', 'Chest'},
		Icon = 'Chest',
		Weapon = {
			['zh_cn'] = {
				'耐久100',
				'发射分裂大钥匙眼泪',
			},
			['en_us'] = {
				'Durability 100', 
				'Fire big split key tears', 
			},
		},	
		Armor = {
			['zh_cn'] = {
				'耐久2',
				'抵挡伤害，1.5秒无敌时间',
				'↑{{Speed}}移速 + 0.15',
			},
			['en_us'] = {
				'Durability 2', 
				'Block damage, 1.5s invincible time', 
				'↑{{Speed}}spd + 0.15', 
			},
		},				
		Float = {
			['zh_cn'] = {
				'耐久75',
				'数量2，环绕物',
				'发射钥匙护盾眼泪，攻击敌弹或敌人',
			},
			['en_us'] = {
				'Durability 75', 
				'Count 2, orbitals',
				'Fire key shielded tears to projectiles or enemies', 
			},
		},							
	},
	[PickupVariant.PICKUP_BOMBCHEST] = {
		Name = {'石箱子', 'Stone Chest'},
		Icon = 'StoneChest',
		Weapon = {
			['zh_cn'] = {
				'耐久210，不可修复',
				'散射8发短程眼泪两次，附带小片震荡波',
			},
			['en_us'] = {
				'Durability 210, unrepairable', 
				'Fire 8 scattering tears in short distance twice, with small shockwave', 
			},
		},	
		Armor = {
			['zh_cn'] = {
				'耐久6，不可修复',
				'抵挡伤害，1.5秒无敌时间',
				'↓{{Speed}}移速 - 0.15',
			},
			['en_us'] = {
				'Durability 6, unrepairable', 
				'Block damage, 1.5s invincible time', 
				'↓{{Speed}}spd - 0.15', 
			},
		},				
		Float = {
			['zh_cn'] = {
				'耐久180，不可修复',
				'数量2，抵挡敌弹的环绕物',
				'耐久耗尽后生成一个金箱子道具和一个饰品',
			},
			['en_us'] = {
				'Durability 180, unrepairable', 
				'Count 2, orbitals that block projectiles',
				'Spawn a golden chest item and a trinket when exhausted', 
			},
		},					
	},
	[PickupVariant.PICKUP_SPIKEDCHEST] = {
		Name = {'刺箱子', 'Spiked Chest'},
		Icon = 'SpikedChest',
		Weapon = {
			['zh_cn'] = {
				'耐久111',
				'向选定方向冲出，造成碰撞伤害，期间可阻挡敌弹并向敌人发射眼泪',
				'充能耗尽或碰到房间边界后返回',
			},
			['en_us'] = {
				'Durability 111', 
				'Rush at a direction with collision damage, during which block projectiles and fire tears to enemies', 
				'Come back when the charge is run out or touch the border of the room',
			},
		},	
		Armor = {
			['zh_cn'] = {
				'耐久2',
				'抵挡伤害，4秒无敌时间',
				'每帧对附近的敌人造成1点伤害',
			},
			['en_us'] = {
				'Durability 6, unrepairable', 
				'Block damage, 1.5s invincible time', 
				'Every frame, deal 1 damage to enemies nearby', 
			},
		},				
		Float = {
			['zh_cn'] = {
				'耐久90',
				'数量3，阻挡敌弹的跟随物',
				'造成碰撞伤害',
			},
			['en_us'] = {
				'Durability 90', 
				'Count 3, followers that block projectiles',
				'Deal collision damage'
			},
		},					
	},
	[PickupVariant.PICKUP_ETERNALCHEST] = {
		Name = {'永恒箱子', 'Eternal Chest'},
		Icon = 'HolyChest',
		Weapon = {
			['zh_cn'] = {
				'耐久70，耗尽后不消失',
				'50%概率不消耗耐久',
				'大范围散射8发穿透圣光弹性眼泪',
				'在新房间清空充能',
			},
			['en_us'] = {
				'Durability 70, exist even exhausted', 
				'50% chance not to decrease durability', 
				'Fire 8 widely scattering holy piercing bouncing tears', 
				'Clear charge at a new room',
			},
		},	
		Armor = {
			['zh_cn'] = {
				'耐久4，耗尽后不消失',
				'25%概率不消耗耐久',
				'抵挡伤害，1.1秒无敌时间',
			},
			['en_us'] = {
				'Durability 4, exist even exhausted', 
				'25% chance not to decrease durability', 
				'Block damage, 1.1s invincible time', 
			},
		},				
		Float = {
			['zh_cn'] = {
				'耐久70，耗尽后不消失',
				'50%概率不消耗耐久',
				'停留在房间中央',
				'向最多4个敌弹或敌人发射穿透圣光护盾眼泪',
			},
			['en_us'] = {
				'Durability 70, exist even exhausted', 
				'50% chance not to decrease durability', 
				'Stay at the center of the room',
				'Fire piercing holy shielded tears to 4 at most projectiles or enemies',
			},
		},					
	},
	[PickupVariant.PICKUP_MIMICCHEST] = {
		Name = {'拟态箱子', 'Mimic Chest'},
		Icon = 'TrapChest',
		Weapon = {
			['zh_cn'] = {
				'耐久111',
				'向选定方向冲出，造成碰撞伤害，期间可阻挡敌弹并向敌人发射眼泪',
				'充能耗尽或碰到房间边界后回归',
			},
			['en_us'] = {
				'Durability 111', 
				'Rush at a direction with collision damage, during which block projectiles and fire tears to enemies', 
				'Come back when the charge is run out or touch the border of the room',
			},
		},	
		Armor = {
			['zh_cn'] = {
				'耐久2',
				'抵挡伤害，4秒无敌时间',
				'每帧对附近的敌人造成1点伤害',
			},
			['en_us'] = {
				'Durability 6, unrepairable', 
				'Block damage, 1.5s invincible time', 
				'Every frame, deal 1 damage to enemies nearby', 
			},
		},				
		Float = {
			['zh_cn'] = {
				'耐久90',
				'数量3，阻挡敌弹的跟随物',
				'造成碰撞伤害',
			},
			['en_us'] = {
				'Durability 90', 
				'Count 3, followers that block projectiles',
				'Deal collision damage'
			},
		},					
	},
	[PickupVariant.PICKUP_OLDCHEST] = {
		Name = {'旧箱子', 'Old Chest'},
		Icon = 'DirtyChest',
		Weapon = {
			['zh_cn'] = {
				'耐久109，在已清理的房间也会消耗',
				'击杀敌人时恢复2耐久，若为Boss则额外恢复8耐久',
				'高速发射3道骨头，长时攻击会过热',
				'过热时无法攻击',
			},
			['en_us'] = {
				'Durability 109, decreases even in a cleared room', 
				'Recover 2 durability when killing enemies, and 8 more for killed bosses',
				'Fire 3 bones at a high speed, and overheat if keep attacking for a while', 
				'Can not attack during overheat',
			},
		},	
		Armor = {
			['zh_cn'] = {
				'耐久4',
				'每隔19秒失去1耐久，但不会耗尽',
				'击杀敌人时恢复0.05耐久, 若为Boss则额外恢复1耐久',
				'抵挡伤害，1.7秒无敌时间',
			},
			['en_us'] = {
				'Durability 4', 
				'Lose 1 durability per 19s until 1 left', 
				'Recover 0.05 durability when killing enemies, and 1 more for killed bosses',
				'Block damage, 1.7s invincible time', 
			},
		},
		Float = {
			['zh_cn'] = {
				'耐久88，在已清理的房间也会消耗',
				'击杀敌人时恢复2耐久，若为Boss则额外恢复8耐久',
				'数量4，斜向游走',
				'向最多3个敌弹或敌人发射护盾骨头',
			},
			['en_us'] = {
				'Durability 88, decreases even in a cleared room', 
				'Recover 2 durability when killing enemies, and 8 more for killed bosses',
				'Count 4, move diagonally',
				'Fire shielded bones to 3 at most projectiles or enemies'
			},
		},								
	},
	[PickupVariant.PICKUP_WOODENCHEST] = {
		Name = {'木箱子', 'Wooden Chest'},
		Icon = 'WoodenChest',
		Weapon = {
			['zh_cn'] = {
				'耐久90，不可修复',
				'清理房间后恢复3耐久',
				'在新层回满耐久',
				'发射3道蓝火',
			},
			['en_us'] = {
				'Durability 90, unrepairable', 
				'Recover 3 durability when a room is cleared', 
				'Full durability next level',
				'Fire 3 blue flames', 
			},
		},	
		Armor = {
			['zh_cn'] = {
				'耐久2，不可修复',
				'切换房间或清理房间后回满耐久',
				'抵挡伤害，1秒无敌时间',
			},
			['en_us'] = {
				'Durability 2, unrepairable', 
				'Full durability when entering another room or a room is cleared', 
				'Block damage, 1s invincible time', 
			},
		},				
		Float = {
			['zh_cn'] = {
				'耐久75，不可修复',
				'清理房间后恢复3耐久',
				'在新层回满耐久',
				'数量2，阻挡敌弹的环绕物',
				'造成碰撞伤害',
				'接触到敌弹或敌人后留下蓝火',
			},
			['en_us'] = {
				'Durability 75, unrepairable', 
				'Recover 3 durability when a room is cleared', 
				'Full durability next level',
				'Count 2, orbitals that block projectiles',
				'Deal collision damage',
				'Spawn blue flames when touching projectiles or enemies', 
			},
		},								
	},
	[PickupVariant.PICKUP_MEGACHEST] = {
		Name = {'大箱子', 'Mega Chest'},
		Icon = 'MegaChest',
		Armor = {
			['zh_cn'] = {
				'耐久5',
				'抵挡伤害，0.5秒无敌时间',
				'↓{{Speed}}移速 - 0.2',
				'可通过吸收箱子来恢复耐久',
				'首次吸收一种箱子会提升耐久上限，但会额外降低{{Speed}}移速',
			},
			['en_us'] = {
				'Durability 5', 
				'Block damage, 0.5s invincible time', 
				'↓{{Speed}}spd - 0.2', 
				'Can recover durability by absorbing chests', 
				'Absorbing a type of chest for the first time increases max durability but decrease {{Speed}}spd', 
			},
		},				
	},
	[PickupVariant.PICKUP_HAUNTEDCHEST] = {
		Name = {'闹鬼箱子', 'Haunted Chest'},
		Icon = 'HauntedChest',
		Weapon = {
			['zh_cn'] = {
				'耐久45，耗尽后变为{{Chest}}普通箱子武器',
				'发射{{Collectible678}}剖腹产眼泪',
			},
			['en_us'] = {
				'Durability 45, would be replaced by {{Chest}}Common Chest one when exhausted', 
				'Fire {{Collectible678}}C Section tears', 
			},
		},	
		Armor = {
			['zh_cn'] = {
				'装备时触发{{Card51}}神圣卡',
				'耐久1，耗尽后变为{{Chest}}普通箱子护甲',
				'抵挡伤害，0.5秒无敌时间',
				'↑{{Damage}}基础伤害倍率提升至120%',
				'会被分解的道具拥有一个额外道具作为轮换',
			},
			['en_us'] = {
				'Trigger {{Card51}}Holy Card when equipped',
				'Durability 1, would be replaced by {{Chest}}Common Chest one when exhausted', 
				'Block damage, 0.5s invincible time', 
				'↑{{Damage}}Basic dmg multi increases to 120%',
				'Items that will be decomposed have an extra option in cycle', 
			},
		},				
		Float = {
			['zh_cn'] = {
				'耐久60，耗尽后变为{{Chest}}普通箱子僚机',
				'数量2，环绕物',
				'生成小幽灵攻击敌人',
			},
			['en_us'] = {
				'Durability 60, would be replaced by {{Chest}}Common Chest one when exhausted', 
				'Count 2, orbitals',
				'Spawn lil ghosts against enemies', 
			},
		},								
	},
	[PickupVariant.PICKUP_LOCKEDCHEST] = {
		Name = {'金箱子', 'Golden Chest'},
		Icon = 'GoldenChest',
		Weapon = {
			['zh_cn'] = {
				'耐久140',
				'充能期间发射短程小激光',
				'充能完成后发射无限射程的大激光',
			},
			['en_us'] = {
				'Durability 140', 
				'Fire short small lasers when charing', 
				'Fire a big laser when fully charged',
			},
		},	
		Armor = {
			['zh_cn'] = {
				'耐久3',
				'抵挡伤害，1秒无敌时间',
				'↑{{Luck}}幸运 + 7',
			},
			['en_us'] = {
				'Durability 3', 
				'Block damage, 1s invincible time', 
				'↑{{Luck}}luck + 7', 
			},
		},				
		Float = {
			['zh_cn'] = {
				'耐久120',
				'环绕物',
				'向最多3个敌弹或敌人发射护盾激光',
			},
			['en_us'] = {
				'Durability 120', 
				'Orbital',
				'Fire shielded lasers to 3 at most projectiles or enemies'
			},
		},					
	},
	[PickupVariant.PICKUP_REDCHEST] = {
		Name = {'红箱子', 'Red Chest'},
		Icon = 'RedChest',
		Weapon = {
			['zh_cn'] = {
				'耐久123，只能用心掉落物修复',
				'发射短程{{Collectible118}}硫磺火',
			},
			['en_us'] = {
				'Durability 123, can only be repaired by heart pickups', 
				'Fire short {{Collectible118}}brimestone', 
			},
		},	
		Armor = {
			['zh_cn'] = {
				'耐久6，只能用心掉落物修复',
				'抵挡伤害，1.3秒无敌时间',
				'↑抵挡伤害后，+ 6%{{Damage}}伤害，持续一层',
			},
			['en_us'] = {
				'Durability 6, can only be repaired by heart pickups', 
				'Block damage, 1.3s invincible time', 
				'↑+ 6% {{Damage}}dmg this level for every time block damage', 
			},
		},				
		Float = {
			['zh_cn'] = {
				'耐久99，只能用心掉落物修复',
				'环绕一名敌人，召唤{{Collectible420}}黑色粉末的魔法阵',
				'被环绕的敌人会获得{{BrimstoneCurse}}硫磺标记',
			},
			['en_us'] = {
				'Durability 99, can only be repaired by heart pickups', 
				'Orbit a enemy and conjure magic circles of {{Collectible420}}Black Powder',
				'The enemy gets {{BrimstoneCurse}}Brimstone Mark'
			},
		},					
	},
	[PickupVariant.PICKUP_MOMSCHEST] = {
		Name = {'妈妈的箱子', 'Mom\'s Chest'},
		Icon = 'IBSMomsChest',
		Armor = {
			['zh_cn'] = {
				'耐久9，不可修复',
				'抵挡伤害，0.7秒无敌时间',
				'所有{{IBSBlostWeapon}}武器和{{IBSBlostFloat}}僚机的耐久变为无限',
			},
			['en_us'] = {
				'Durability 9, unrepairable', 
				'Block damage, 0.7s invincible time', 
				'The durability of {{IBSBlostWeapon}} weapons and {{IBSBlostFloat}} floats become infinite',
			},
		},					
	},				
}
	
return Chest