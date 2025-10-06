--昧化伊甸

local mod = Isaac_BenightedSoul
local CharacterLock = mod.IBS_Achiev.CharacterLock
local IBS_CallbackID = mod.IBS_CallbackID
local IBS_ItemID = mod.IBS_ItemID
local IBS_Sound = mod.IBS_Sound
local Damage = mod.IBS_Class.Damage()
local Stats = mod.IBS_Lib.Stats

local game = Game()
local sfx = SFXManager()
local config = Isaac.GetItemConfig()

local BEden = mod.IBS_Class.Character(mod.IBS_PlayerID.BEden, {
	BossIntroName = 'beden',
	PocketActive = IBS_ItemID.Defined,
})

--技能树说明(排序:区,列,行)
BEden.SkillTreeInfo = {
	zh = {
		--属性区
		[1] = {
			[1] = {
				{'移速 - 0.1', '所有提升限制 - 1'},
				{'射速 - 0.2', '其他提升限制 - 2'},
				{'伤害 - 0.3', '其他提升限制 - 2'},
				{'射程 - 1', '所有提升限制 - 1'},
				{'弹速 - 0.4', '所有提升限制 - 1'},
				{'幸运 - 1', '所有提升限制 - 1'},
			},
			[2] = {
				{'移速 + 0.15', '移速提升限制 + 1'},
				{'射速 + 0.35', '所有提升限制 + 1'},
				{'伤害 + 0.5', '所有提升限制 + 1'},
				{'射程 + 1.25', '射程提升限制 + 1'},
				{'弹速 + 0.15', '弹速无提升限制'},
				{'幸运 + 1', '幸运提升限制 + 1'},	
			},
		},
		
		--物品区
		[2] = {
			'转换为点数',
			'吞下饰品',

			--长子权
			'本层道具点数价值 x 300%',
			'清空碎心',
			'+ 3 骨心, 体力回满',
			'下层7秒后死亡',
		},

		--技能区
		[3] = {
			[1] = {
				[1] = {
					Name = '[定义域+]',
					Max = 4,
					Desc = {
						{'已定义可传送至更多房间'},
						{'已定义可传送至更多房间'},
						{'已定义可传送至更多房间'},
						{'已定义可传送至更多房间'},
					},
					GreedMax = 3,
					GreedDesc = {
						{'已定义可传送至更多房间'},
						{'已定义可传送至更多房间'},
						{'已定义可传送至更多房间'},
					},
				},
				[2] = {
					Name = '[耸肩无视]',
					Max = 3,
					Desc = {
						{'秘密出口保持开启', '免疫动人诅咒的伤害'},
						{'头目车轮战与蓝子宫大门保持开启'},
						{'获得全家福, 底片,', '钥匙碎片1&2,', '菜刀碎片1&2'},
					},
					GreedMax = 1,
					GreedDesc = {
						{'暂停波次不受伤', '免疫动人诅咒的伤害'},
					},
				},
				[3] = {
					Name = '[御血]',
					Max = 6,
					Desc = {
						{'受伤时丢下半红心, 并释放血波', '被命中的敌人将掉落心(1.5秒)'},
						{'吞下乌鸦的心', '血波对敌人施加硫磺标记'},
						{'+ 2 心之容器', '普通房间内红心受伤,', '不再影响天使/恶魔房开启率'},
						{'血波伤害 + 50%', '血波范围 + 25%,', '对敌人施加流血效果'},
						{'每隔10秒恢复半红心,', '直到恢复一半'},
						{'心上限 + 6'},
					},
					GreedMax = 6,
					GreedDesc = {
						{'受伤时丢下半红心, 并释放血波', '被命中的敌人将掉落心(1.5秒)'},
						{'吞下乌鸦的心', '血波对敌人施加硫磺标记'},
						{'+ 3 心之容器'},
						{'血波伤害 + 50%', '血波范围 + 25%,', '对敌人施加流血效果'},
						{'每隔10秒恢复半红心,', '直到恢复一半'},
						{'心上限 + 6'},
					},					
				},
				[4] = {
					Name = '[他山之石]',
					Max = 8,
					Desc = {
						{'+ 1 炸弹', '+ 1 心之容器'},
						{'+ 1 钥匙', '+ 30 硬币'},
						{'生成大便', '生成死鸟'},
						{'生成小孩的心脏', '生成阿撒泻勒的残角'},
						{'生成拉萨路的魂石,', '生成游魂的魂石'},
						{'吞下银币', '吞下失落摇篮曲'},
						{'获得2骨心和1魂心', '进入新Boss房:', '触发亚波伦的魂石', '触发伯大尼的魂石'},
						{'获得长子名分', '心上限 - 3'},
					},
					GreedDesc = {
						{'+ 1 炸弹', '+ 1 心之容器'},
						{'+ 1 钥匙', '+ 30 硬币'},
						{'生成大便', '生成死鸟'},
						{'生成小孩的心脏', '生成阿撒泻勒的残角'},
						{'生成拉萨路的魂石,', '生成游魂的魂石'},
						{'生成深口袋', '吞下失落摇篮曲'},
						{'获得2骨心和1魂心', '进入新Boss房或Boss波次:', '触发亚波伦的魂石', '触发伯大尼的魂石'},
						{'获得长子名分', '心上限 - 3'},
					},
				},
				[5] = {
					Name = '[应急按钮]',
					Max = 2,
					Desc = {
						{'生成紧急按钮'},
						{'获得超紧急按钮'},
					},
				},
				[6] = {
					Name = '[所谓正道]',
					Max = 5,
					Desc = {
						{'转换道具至少获得7点数', '无法激活[我行我素]', '无法激活[行歧路者] (除非二元性)'},
						{'进入新层, 若上层未作恶:', '点数 + 21'},
						{'进入新层, 若上层未作恶:', '获得神圣卡和魂心'},
						{'进入新层, 若上层未作恶:', '清除诅咒'},
						{'天使房开启率 + 100%', '第7层以后每层都会获得鬼牌'},
					},
					GreedMax = 4,
					GreedDesc = {
						{'转换道具至少获得7点数', '无法激活[我行我素]', '无法激活[行歧路者] (除非二元性)'},
						{'天使房转换率 + 100%', '进入新层, 若上层未作恶:', '点数 + 21'},
						{'进入新层, 若上层未作恶:', '获得神圣卡和魂心', '清除诅咒'},
						{'在第7层获得鬼牌'},
					},
				},				
			},
			[2] = {
				[1] = {
					Name = '[9伏增压]',
					Max = 1,
					Desc = {
						{'已定义充能消耗 - 1', '(效果可与道具9伏特叠加)'},
					},
				},
				[2] = {
					Name = '[寻真]',
					Max = 4,
					Desc = {
						{'清理2个房间后:', '揭示一个特殊房间的位置'},
						{'清理房间后:', '生成紫色传送门'},
						{'清理Boss房后:', '揭示全图'},
						{'不再遇到迷途诅咒', '每层生成伊甸的伪忆'},
					},
					GreedMax = 2,
					GreedDesc = {
						{'完成Boss波次后:', '揭示超级隐藏房的位置'},
						{'每层生成伊甸的伪忆'},
					},
				},
				[3] = {
					Name = '[万物一心]',
					Max = 5,
					Desc = {
						{'消耗药丸时:', '点数 + 1', '每层最多通过该技能获取3点数'},
						{'消耗卡牌时:', '点数 + 2', '每层最多通过该技能获取5点数'},
						{'消耗符文时:', '点数 + 4', '每层最多通过该技能获取9点数'},
						{'消耗其他口袋物品时:', '点数 + 5', '每层最多通过该技能获取15点数'},
						{'消耗7点数吞下饰品', '可将被吞下的饰品转换为5点数', '每层最多通过该技能获取25点数'},
					},
				},
				[4] = {
					Name = '[星盘]',
					Max = 4,
					Desc = {
						{'进入宝箱房不扣除星象房开启率'},
						{'星星道具点数价值 + 40%'},
						{'生成望远镜片'},
						{'星象房开启率 + 100%'},
					},
					GreedMax = 2,
					GreedDesc = {
						{'星星道具点数价值 + 25%'},
						{'白色宝箱房变为星象房'},
					},
				},
				[5] = {
					Name = '[立地升天]',
					Max = 1,
					Desc = {
						{'飞行'},
					},
					GreedDesc = {
						{'飞行', '获得天堂阶梯'},
					},
				},
				[6] = {
					Name = '[我行我素]',
					Max = 5,
					Desc = {
						{'在第三层自动激活', '无法激活[所谓正道]', '无法激活[行歧路者]'},
						{'道具点数价值 + 25%'},
						{'当前层具有诅咒时:', '所有属性 + 25%'},
						{'在Boss房时:', '所有属性 + 25%'},
						{'所有属性 + 25%'},
					},
					GreedDesc = {
						{'在第二层自动激活', '无法激活[所谓正道]', '无法激活[行歧路者]'},
						{'道具点数价值 + 25%'},
						{'当前层具有诅咒时:', '所有属性 + 25%'},
						{'在Boss房, Boss波次或额外波次时:', '所有属性 + 25%'},
						{'所有属性 + 25%'},
					},
				},					
			},
			[3] = {
				[1] = {
					Name = '[备用电池]',
					Max = 1,
					Desc = {
						{'已定义可充满两次'},
					},
				},
				[2] = {
					Name = '[击碎命运]',
					Max = 3,
					Desc = {
						{'每转换4次道具:', '清除未知诅咒和致盲诅咒'},
						{'每转换4次道具:', '生成心硬币炸弹钥匙各一个'},
						{'每转换4次道具:', '获得骰子碎片'},
					},
					GreedDesc = {
						{'每转换3次道具:', '清除未知诅咒和致盲诅咒'},
						{'每转换3次道具:', '生成心硬币炸弹钥匙各一个'},
						{'每转换3次道具:', '获得骰子碎片'},					
					}
				},
				[3] = {
					Name = '[精炼混沌]',
					Max = 6,
					Desc = {
						{'敌人每次受伤都会为该技能累积计数', '计数达到12时令周围敌人中毒6秒', '计数达到12时重置'},
						{'计数达到24时令周围敌人燃烧6秒', '计数达到24时重置'},
						{'计数达到48时令周围敌人减速6秒', '计数达到48时重置'},
						{'计数达到60时令周围敌人流血10秒', '计数达到60时重置'},
						{'计数达到96时令周围敌人虚弱6秒', '计数达到96时重置'},
						{'计数达到128时周围普通敌人立即死亡,', 'Boss失去10%现有生命值', '计数达到128时重置'},
					},
				},
				[4] = {
					Name = '[贪婪滋生]',
					Max = 6,
					Desc = {
						{'道具价格减少1硬币'},
						{'物品价格减少1硬币'},
						{'生成屁股硬币', '生成腐烂硬币'},
						{'吞下假币'},
						{'生成染血硬币', '生成焦灼硬币', '生成扁平硬币'},
						{'吞下被吞下的硬币', '生成神圣硬币', '生成充能硬币'},
					},
				},
				[5] = {
					Name = '[巩固]',
					Max = 3,
					Desc = {
						{'免疫水迹伤害'},
						{'免疫地刺，箱子和诅咒房门伤害'},
						{'免疫爆炸，践踏和落石伤害'},
					},
				},
				[6] = {
					Name = '[行歧路者]',
					Max = 6,
					Desc = {
						{'激活将视为一次恶魔交易', '无法激活[我行我素]', '无法激活[所谓正道] (除非二元性)'},
						{'品质低于2的道具失去点数价值', '道具点数价值 + 60%'},
						{'进入新层:', '获得6点数和13硬币'},
						{'吞下犹大的舌头'},
						{'每层都会遇到黑暗诅咒', '不会遇到其他诅咒'},
						{'恶魔房开启率 + 100%', '第7层以后每层都会获得鬼牌'},
					},
					GreedMax = 5,
					GreedDesc = {
						{'激活将视为一次恶魔交易', '无法激活[我行我素]', '无法激活[行歧路者] (除非二元性)'},
						{'品质低于2的道具失去点数价值', '道具点数价值 + 60%'},
						{'进入新层:', '获得6点数和13硬币'},
						{'吞下犹大的舌头', '每层都会遇到黑暗诅咒', '不会遇到其他诅咒'},
						{'在第7层获得鬼牌'},
					},
				},					
			},
		},
	},

	en = {
		[1] = {
			[1] = {
				{'spd - 0.15', 'Stats penalty - 1'},
				{'tears - 0.2', 'Other stats penalty - 2'},
				{'dmg - 0.3', 'Other stats penalty - 2'},
				{'range - 1', 'Stats penalty - 1'},
				{'sspd - 0.4', 'Stats penalty -1'},
				{'luck - 1', 'Stats penalty - 1'},
			},
			[2] = {
				{'spd + 0.25', 'spd penalty + 1'},
				{'tears + 0.35', 'stats penalty + 1'},
				{'dmg + 0.5', 'stats penalty + 1'},
				{'range + 1.25', 'range penalty + 1'},
				{'sspd + 0.15', 'no sspd penalty'},
				{'luck + 1', 'luck penalty + 1'},	
			}	
		},
		[2] = {
			'To points',
			'Smelt',

			'This level, items to points + 300%',
			'Clear Broken Hearts',
			'+ 3 Bone Hearts, full health',
			'Next level, DIE after 7s',
		},		
		[3] = {
			[1] = {
				[1] = {
					Name = '[Definition+]',
					Max = 4,
					Desc = {
						{'Defined can go to more rooms'},
						{'Defined can go to more rooms'},
						{'Defined can go to more rooms'},
						{'Defined can go to more rooms'},
					},
					GreedMax = 3,
					GreedDesc = {
						{'Defined can go to more rooms'},
						{'Defined can go to more rooms'},
						{'Defined can go to more rooms'},
					},
				},
				[2] = {
					Name = '[Shrug It Off]',
					Max = 3,
					Desc = {
						{'Secret Exit keeps open', 'Curse of Moving immunity'},
						{"Boss Rush and Blue Worm keep open"},
						{'Gain:', 'Polaroid, Negative', 'Key Piece 1&2'},
					},
					GreedMax = 1,
					GreedDesc = {
						{'No damage when pausing waves', 'Curse of Moving immunity'},
					},
				},
				[3] = {
					Name = '[Hemokinesis]',
					Max = 6,
					Desc = {
						{'When hurt, drop half a Red Heart to', 'release bloody wave', 'Enemies hit will drop hearts(1.5s)'},
						{'Gulp Crow Heart', 'Wave can brimestone-ly mark enemies'},
						{'+ 2 Heart Container', 'Red Heart damaged in default room,', "won't decrease room chance"},
						{'Wave damage + 50%', 'range + 25%', 'bleeds enemies'},
						{'Every 10s, heal half a Red Heart', 'until half-full'},
						{'Maximum Hearts + 6'},
					},
					GreedDesc = {
						{'When hurt, drop half a Red Heart to', 'release bloody wave', 'Enemies hit will drop hearts(1.5s)'},
						{'Gulp Crow Heart', 'Wave can brimestone-ly mark enemies'},
						{'+ 3 Heart Container'},
						{'Wave damage + 50%', 'range + 25%', 'bleeds enemies'},
						{'Every 15s, heal half a Red Heart', 'until half-full'},
						{'Maximum Hearts + 6'},
					},					
				},
				[4] = {
					Name = '[Foreign Influence]',
					Max = 8,
					Desc = {
						{'+ 1 Bomb', '+ 1 Heart Container'},
						{'+ 1 Key', '+ 30 Coins'},
						{'Spawn The Poop', 'Spawn Dead Bird'},
						{"Spawn Child's Heart", "Spawn Azazel's Stump"},
						{'Spawn Soul of Lazarus,', 'Spawn Soul of the Lost'},
						{'Gulp Silver Dollar', 'Gulp Forgotten Lullaby'},
						{'Gain 2 Bone Hearts and 1 Soul Heart', 'New Boss Room:', 'Trigger Soul of Apollyon', 'Trigger Soul of Bethany'},
						{'Gain Birthright', 'Maximum Hearts - 6'},
					},
					GreedDesc = {
						{'+ 1 Bomb', '+ 1 Heart Container'},
						{'+ 1 Key', '+ 30 Coins'},
						{'Spawn The Poop', 'Spawn Dead Bird'},
						{"Spawn Child's Heart", "Spawn Azazel's Stump"},
						{'Spawn Soul of Lazarus,', 'Spawn Soul of the Lost'},
						{'Spawn Deep Pockets', 'Gulp Forgotten Lullaby'},
						{'Gain 2 Bone Hearts and 1 Soul Heart', 'New Boss Room or Boss wave:', 'Trigger Soul of Apollyon', 'Trigger Soul of Bethany'},
						{'Gain Birthright', 'Maximum Hearts - 6'},
					},					
				},
				[5] = {
					Name = '[Panic Button]',
					Max = 2,
					Desc = {
						{'Spawn Panic Button'},
						{'Gain Super Panic Button'},
					},
				},
				[6] = {
					Name = '[The Path]',
					Max = 5,
					Desc = {
						{'Items to 7 points at least', 'Invalid [My Path]', 'Invalid [Another Path] unless Duality'},
						{'New level if not do evil last level:', 'Points + 21'},
						{'New level if not do evil last level:', 'Holy Card and Soul Heart'},
						{'New level if not do evil last level:', 'Clear curses'},
						{'Angel and devil chance + 100%', 'Gain Joker in a new level after 6th'},
					},
					GreedMax = 4,
					GreedDesc = {
						{'Items to 7 points at least', 'Invalid [My Path]', 'Invalid [Another Path] unless Duality'},
						{'Angel chance + 100%', 'New level if not do evil last level:', 'Points + 21'},
						{'New level if not do evil last level:', 'Holy Card and Soul Heart', 'Clear curses'},
						{'Gain Joker at 7th level'},
					},
				},				
			},
			[2] = {
				[1] = {
					Name = '[Volt 9]',
					Max = 1,
					Desc = {
						{'Defined cost - 1', '(No conflict whth 9 Volt)'},
					},
				},
				[2] = {
					Name = '[Sought]',
					Max = 4,
					Desc = {
						{'Clear 2 rooms:', 'Reveal a special room'},
						{'Clear a room:', 'Spawn a purple portal'},
						{'Clear Boss Room:', 'Reveal the map'},
						{'No Curse of the Lost', 'Falsehood of Eden for each level'},
					},
					GreedMax = 1,
					GreedDesc = {
						{'After Boss:', 'Reveal Super Secret Room'},
					},
				},
				[3] = {
					Name = '[All For One]',
					Max = 5,
					Desc = {
						{'Consume a pill:', 'Points + 1', '3 points most through this for a level'},
						{'Consume a card:', 'Points + 1', '5 points most through this for a level'},
						{'Consume a rune:', 'Points + 1', '9 points most through this for a level'},
						{'Consume other pocket items:', 'Points + 1', '15 points most through this for a level'},
						{'Consume 7 points to smelt a trinket', 'A smelted trinket to 5 points', '25 points most through this for a level'},
					},
				},
				[4] = {
					Name = '[Astrolabe]',
					Max = 4,
					Desc = {
						{"Entering Treasure Room won't", " decrease Planetarium chance"},
						{'Star items to points + 40%'},
						{'Spawn Telescope Lens'},
						{'Planetarium chance + 100%'},
					},
					GreedMax = 2,
					GreedDesc = {
						{'Star items to points + 25%'},
						{'White Treasure Room becomes Planetarium'},
					},
				},
				[5] = {
					Name = '[Reach Sky]',
					Max = 1,
					Desc = {
						{'Flight'},
					},
					GreedDesc = {
						{'Flight', 'Gain The Stairway'},
					},
				},
				[6] = {
					Name = '[My Path]',
					Max = 5,
					Desc = {
						{'Auto-valid at 3th level', 'Invalid[The Path]', 'Invalid[Another Path]'},
						{'Items to points + 25%'},
						{'With level curses:', 'stats + 25%'},
						{'In Boos Room:', 'stats + 25%'},
						{'stats + 25%'},
					},
					GreedDesc = {
						{'Auto-valid at 2th level', 'Invalid[The Path]', 'Invalid[Another Path]'},
						{'Items to points + 25%'},
						{'With level curses:', 'stats + 25%'},
						{'In Boos Room:', 'stats + 25%'},
						{'stats + 25%'},
					},
					
				},					
			},
			[3] = {
				[1] = {
					Name = '[Battery]',
					Max = 1,
					Desc = {
						{'Defined can be fully charged twice'},
					},
				},
				[2] = {
					Name = '[Crack The Destiny]',
					Max = 3,
					Desc = {
						{'4 Items to points:', 'Clear Curse of the Unknown', 'Clear Curse of the Blind'},
						{'4 Items to points:', 'Spawn a heart, coin, bomb and key'},
						{'4 Items to points:', 'Gain Dice Shard'},
					},
					GreedDesc = {
						{'3 Items to points:', 'Clear Curse of the Unknown', 'Clear Curse of the Blind'},
						{'3 Items to points:', 'Spawn a heart, coin, bomb and key'},
						{'3 Items to points:', 'Gain Dice Shard'},
					},					
				},
				[3] = {
					Name = '[Distilled Chaos]',
					Max = 6,
					Desc = {
						{'Enemies hit add a count for this skill', '12 counts poison enemies around for 6s', 'Counts will reset at 12'},
						{'24 counts burn enemies around for 6s', 'Counts will reset at 24'},
						{'48 counts slower enemies around for 6s', 'Counts will reset at 48'},
						{'60 counts bleed enemies around for 10s', 'Counts will reset at 60'},
						{'96 counts weaken enemies around for 6s', 'Counts will reset at 96'},
						{'128 counts kill non-boss enemies around,', 'and make bosses lose 10% current hp', 'Counts will reset at 128'},
					},
				},
				[4] = {
					Name = '[Growing Greed]',
					Max = 6,
					Desc = {
						{"Items' price - 1"},
						{"Pickups' price - 1"},
						{'Spawn Butt Penny', 'Spawn Rotten Penny'},
						{'Gulp Counterfeit Penny'},
						{'Spawn Bloody Penny', 'Spawn Burnt Penny', 'Spawn Flat Penny'},
						{'Gulp Swallowed Penny', 'Spawn Blessed Penny', 'Spawn Charged Penny'},
					},
				},
				[5] = {
					Name = '[Entrench]',
					Max = 6,
					Desc = {
						{'Creep immunity'},
						{'Ground spike, chest,', 'and Cursed Room door immunity'},
						{'Explosion and crush immunity'},
					},
				},
				[6] = {
					Name = '[Another Path]',
					Max = 6,
					Desc = {
						{'Regarded as a devil deal', 'Invalid[My Path]', 'Invalid[The Path] unless Duality'},
						{'Below-2-quality items to no points', 'Items to points + 60%'},
						{'New level:', '6 points and 13 coins'},
						{"Gulp Judas' Tongue"},
						{'Curse of Darkness for each level', 'No other curses'},
						{'Devil chance + 100%', 'Gain Joker in a new level after 6th'},
					},
					GreedMax = 5,
					GreedDesc = {
						{'Regarded as a devil deal', 'Invalid[My Path]', 'Invalid[The Path] unless Duality'},
						{'Below-2-quality items to no points', 'Items to points + 60%'},
						{'New level:', '6 points and 13 coins'},
						{"Gulp Judas' Tongue", 'Curse of Darkness for each level', 'No other curses'},
						{'Gain Joker at 7th level'},
					},
				},					
			},
		},	
	}
}

--属性上下限
BEden.StatsLimit = {
	MinSpeed = 0.25,
	MaxSpeed = 2,

	MinTears = 1.5,
	MaxTears = 120,

	MinDamage = 1.5,

	MinRange = 3,
	
	MinShotSpeed = 0.6,
	MaxShotSpeed = 5,
	
	MinLuck = -6,
}

--字体
local fnt = Font('font/terminus.fnt')
local fnt2 = Font('font/cjk/lanapixel.fnt')

--变身
function BEden:Benighted(player, fromMenu)
	if CharacterLock.BEden:IsLocked() then return end

	--移除道具
	for id,num in pairs(self._Players:GetPlayerCollectibles(player)) do
		for i = 1,num do
			player:RemoveCollectible(id, true)
		end
	end
	
	--移除饰品
	for slot = 0,1 do
		local trinket = player:GetTrinket(slot)
		if trinket > 0 then
			player:TryRemoveTrinket(trinket)
		end
	end
	
	--移除口袋物品
	for slot = 0,3 do
		player:RemovePocketItem(slot)
	end

	--清除装扮
	player:ClearCostumes()

	--更改初始资源
	player:AddCoins(-player:GetNumCoins())
	player:AddBombs(-player:GetNumBombs())
	player:AddKeys(-player:GetNumKeys())

	--更改血量
	player:AddSoulHearts(-player:GetSoulHearts())
	player:AddMaxHearts(-player:GetMaxHearts())	
	player:AddMaxHearts(6)
	player:AddHearts(6)
	
	player:ChangePlayerType(self.ID)
	player:SetPocketActiveItem(self.Info.PocketActive, ActiveSlot.SLOT_POCKET, false)
	player:AddCacheFlags(CacheFlag.CACHE_ALL, true)

	--如果完成了对应挑战,获得7点数
	if self:GetIBSData('persis')['bc10'] then
		local data = self:GetData(player)
		data.Points = data.Points + 7
	end
end
BEden:AddCallback(IBS_CallbackID.BENIGHTED, 'Benighted', PlayerType.PLAYER_EDEN)

--数字转换成罗马数字(硬核)
local function RomanNumber(number)
	if number == 1 then
		return 'I'
	end
	if number == 2 then
		return 'II'
	end
	if number == 3 then
		return 'III'
	end
	if number == 4 then
		return 'IV'
	end
	if number == 5 then
		return 'V'
	end
	if number == 6 then
		return 'VI'
	end
	if number == 7 then
		return 'VII'
	end
	if number == 8 then
		return 'VIII'
	end
	if number == 9 then
		return 'IX'
	end
	if number == 10 then
		return 'X'
	end

	return number
end


--获取数据
function BEden:GetData(player)
	local data = self._Players:GetData(player)
	data.BEDEN = data.BEDEN or {
		Points = 0, --点数
		Blasphemer = false, --渎神,长子权效果

		--面板当前选择
		section = 1, --区域(1属性,2物品栏,3技能)
		row = 1, --行
		column = 1, --列
		page = 1, --物品区页码

		--属性
		spd = 1,
		tears = (30/11),
		dmg = 3.5,
		range = 6.5,
		sspd = 1,
		luck = 0,
		
		--属性提升限制
		p_spd = 0,
		p_tears = 0,
		p_dmg = 0,
		p_range = 0,
		p_luck = 0,

		--技能
		definition_up = 0,
		volt9 = 0,
		battery = 0,
		shrug_it_off = 0,
		sought = 0,
		crack_the_destiny = 0,
		hemokinesis = 0,
		all_for_one = 0,
		distilled_chaos = 0,
		foreign_influence = 0,
		astrolabe = 0,
		growing_greed = 0,
		panic_button = 0,
		reach_sky = 0,
		entrench = 0,
		the_path = 0,
		my_path = 0,
		another_path = 0,

		--用于技能实现
		soughtToken = 0,
		crackDestinyToken = 0,
		allForOneToken = 0,
		distilledChaosToken = 0,
		eivl = false,
		lastLevelEvil = false,

	}
	return data.BEDEN
end

--获取万物一心每层点数获取上限
local function GetAllForOneMaxPoints(lv)
	if lv >= 5 then
		return 25
	elseif lv >= 4 then
		return 15
	elseif lv >= 3 then
		return 9
	elseif lv >= 2 then
		return 5
	elseif lv >= 1 then
		return 3
	end

	return 0
end

--长子权效果触发后下层7秒后死亡
function BEden:BlasphemerLevel()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			local data = BEden:GetData(player)
			if data.Blasphemer then
				game:Darken(1, 270)
				self:DelayFunction(function()
					if player:GetPlayerType() == BEden.ID then
						local data = BEden:GetData(player)
						if data.Blasphemer then
							player:Die()
							data.Blasphemer = false
						end
					end
				end, 210)
			end
		end
	end	
end
BEden:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'BlasphemerLevel')

--修改心上限
function BEden:OnHeartLimit(player, limit)
	local data = self:GetData(player)

	--御血6级
	if data.hemokinesis >= 6 then
		limit = limit + 12
	end

	--他山之石8级
	if data.foreign_influence >= 8 then
		limit = math.max(2, limit - 6)
	end

	return limit
end
BEden:AddCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, 'OnHeartLimit', BEden.ID)


--新房间检测角色
function BEden:OnNewRoom()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if self._Players:GetData(player).BEDEN and player:GetPlayerType() ~= self.ID then
			player:ChangePlayerType(mod.IBS_PlayerID.BEden)
			player:SetPocketActiveItem(IBS_ItemID.Defined, ActiveSlot.SLOT_POCKET, false)
		end
	end	
end
BEden:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'OnNewRoom')


--修改射速(无视原版射速上限)
local function SetTears(player, value)
	player.MaxFireDelay = math.max((30 / value) - 1, -0.99) --射击延迟要大于-1
end

--属性
function BEden:OnEvaluateCache(player, flag)
	if player:GetPlayerType() == self.ID then
		local data = self:GetData(player)
		local lv = data.my_path
		local mult = 1
		
		--我行我素效果
		if lv >= 3 and game:GetLevel():GetCurses() > 0 then
			mult = mult * 1.25
		end
		if lv >= 4 then
			if (game:GetRoom():GetType() == RoomType.ROOM_BOSS) or game:IsGreedBoss() or game:IsGreedFinalBoss() then
				mult = mult * 1.25
			end
		end
		if lv >= 5 then
			mult = mult * 1.25
		end


		if flag & CacheFlag.CACHE_SPEED > 0 then
			player.MoveSpeed = data.spd * mult
		end
		if flag & CacheFlag.CACHE_FIREDELAY > 0 then
			SetTears(player, data.tears * mult)
		end
		if flag & CacheFlag.CACHE_DAMAGE > 0 then
			player.Damage = data.dmg * mult
		end
		if flag & CacheFlag.CACHE_RANGE > 0 then
			player.TearRange = 40 * data.range * mult
		end
		if flag & CacheFlag.CACHE_SHOTSPEED > 0 then
			player.ShotSpeed = data.sspd * mult
		end
		if flag & CacheFlag.CACHE_LUCK > 0 then
			player.Luck = data.luck * mult
		end
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 10^7, 'OnEvaluateCache')

--黑名单道具(名单内道具不生效)
BEden.ItemBlackList = {
	304, --天秤座
	562, --谷底石
}
function BEden:OnPlayerUpdate(player)
	if player:GetPlayerType() == self.ID then
		for _,id in ipairs(self.ItemBlackList) do
			if not player:IsCollectibleBlocked(id) then
				player:BlockCollectible(id)
			end
		end
		self._Ents:GetTempData(player).LastIsBEden = true
	elseif self._Ents:GetTempData(player).LastIsBEden then
		for _,id in ipairs(self.ItemBlackList) do
			if player:IsCollectibleBlocked(id) then
				player:UnblockCollectible(id)
			end
		end	
		self._Ents:GetTempData(player).LastIsBEden = nil
	end
end
BEden:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'OnPlayerUpdate')

--物品栏临时数据
function BEden:GetInventory(player)
	local data = self._Ents:GetTempData(player)
	data.BEDENINV = data.BEDENINV or {}
	return data.BEDENINV
end

--获取道具贴图
local function GetItemSprite(id, isTrinket)
	local spr = Sprite('gfx/ibs/ui/players/beden_icons.anm2')
	local gfx = ''
	local itemConfig = (isTrinket and config:GetTrinket(id)) or config:GetCollectible(id)

	if itemConfig then   
		gfx = itemConfig.GfxFileName
	end

	if gfx == '' or not gfx then
		gfx = 'gfx/items/collectibles/placeholder.png'
	elseif isTrinket and id > 32768 then --金饰品特效
		spr:SetRenderFlags(AnimRenderFlags.GOLDEN)
	end

	spr:ReplaceSpritesheet(0, gfx, true)
	spr:Play('Selection')

	return spr
end

--刷新物品栏
function BEden:RefreshInventory(player)
	if player:GetPlayerType() ~= self.ID then return end
	local inv = self:GetInventory(player)
	local data = self:GetData(player)

	for k,_ in pairs(inv) do
		inv[k] = nil
	end

	local page = 1

	--记录饰品(万物一心5级)
	if data.all_for_one >= 5 then
		for slot = 0,1 do
			local id = player:GetTrinket(slot)
			local itemConfig = config:GetTrinket(id)
			if itemConfig then
				inv[page] = inv[page] or {}
				table.insert(inv[page], {Sprite = GetItemSprite(id, true), ID = id, Type = 'Trinket', Slot = slot})
				if #inv[page] >= 15 then --一页最多展示15个物品
					page = page + 1
				end
			end
		end
		
		--被吞下(熔炼)的饰品
		for id,tbl in ipairs(player:GetSmeltedTrinkets()) do
			for i = 1,tbl.trinketAmount do
				local itemConfig = config:GetTrinket(id)
				if itemConfig then
					inv[page] = inv[page] or {}
					table.insert(inv[page], {Sprite = GetItemSprite(id, true), ID = id, Type = 'Trinket', Slot = -1})
					if #inv[page] >= 15 then --一页最多展示15个物品
						page = page + 1
					end
				end
			end
			for i = 1,tbl.goldenTrinketAmount do
				local goldenID = id + 32768
				local itemConfig = config:GetTrinket(goldenID)
				if itemConfig then
					inv[page] = inv[page] or {}
					table.insert(inv[page], {Sprite = GetItemSprite(goldenID, true), ID = goldenID, Type = 'Trinket', Slot = -1})
					if #inv[page] >= 15 then --一页最多展示15个物品
						page = page + 1
					end
				end			
			end
		end
	end

	--记录主动道具(不包括副手主动)
	for slot = 0,1 do
		local id = player:GetActiveItem(slot)
		local itemConfig = config:GetCollectible(id)
		if itemConfig and itemConfig.Type == ItemType.ITEM_ACTIVE and player:HasCollectible(id, true) then
			inv[page] = inv[page] or {}
			table.insert(inv[page], {Sprite = GetItemSprite(id), ID = id, Type = 'Active', Slot = slot})
			if #inv[page] >= 15 then --一页最多展示15个物品
				page = page + 1
			end
		end
	end

	--记录被动道具
	local MAX = config:GetCollectibles().Size - 1
	for id = -MAX, MAX do
		local itemConfig = config:GetCollectible(id)
		if itemConfig and (itemConfig.Type == ItemType.ITEM_PASSIVE or itemConfig.Type == ItemType.ITEM_FAMILIAR) and player:HasCollectible(id, true) then
			local num = (id < 0 and 1) or player:GetCollectibleNum(id, true)
			for i = 1,num do
				inv[page] = inv[page] or {}
				table.insert(inv[page], {Sprite = GetItemSprite(id), ID = id, Type = 'Passive', Slot = -1})
				if #inv[page] >= 15 then --一页最多展示15个物品
					page = page + 1
				end
			end
		end
	end

	--第一页始终存在
	inv[1] = inv[1] or {}
end


--获取属性加点价格
function BEden:GetStatsSectionCost(player, row, column)
	if player:GetPlayerType() ~= self.ID then return 0 end
	local data = self:GetData(player)

	if row == 1 then --移速
		if column == 1 then --降低
			return 1
		else --提升
			return math.min(50, 6 + (3 ^ data.p_spd))
		end
	elseif row == 2 then --射速
		if column == 1 then
			return 3
		else
			return math.min(50, 3 + (3 ^ data.p_tears))
		end	
	elseif row == 3 then --伤害
		if column == 1 then
			return 3
		else
			return math.min(50, 2 + (3 ^ data.p_dmg))
		end	
	elseif row == 4 then --射程
		if column == 1 then
			return 2
		else
			return math.min(50, (2 ^ data.p_range))
		end	
	elseif row == 5 then --弹速
		if column == 1 then
			return 5
		else
			return 2
		end	
	elseif row == 6 then --幸运
		if column == 1 then
			return 2
		else
			return math.min(50, 1 + (2 ^ data.p_luck))
		end	
	end

	return 0
end

--触发属性区效果
function BEden:TriggerStatsSection(player, row, column, playSound)
	if player:GetPlayerType() ~= self.ID then return false end
	local SUCESS = false
	local data = self:GetData(player)
	local cost = self:GetStatsSectionCost(player, row, column)

	--判断点数是否足够
	if data.Points < cost then
		if playSound then
			sfx:Play(187, 1, 30)
		end			
		return false
	end

	--降低属性提升限制
	local function DecreasePenalty()
		data.p_spd = math.max(0, data.p_spd - 1)
		data.p_tears = math.max(0, data.p_tears - 1)
		data.p_dmg = math.max(0, data.p_dmg - 1)
		data.p_range = math.max(0, data.p_range - 1)
		data.p_luck = math.max(0, data.p_luck - 1)
	end

	--提高属性提升限制
	local function IncreasePenalty()
		data.p_spd = data.p_spd + 1
		data.p_tears = data.p_tears + 1
		data.p_dmg = data.p_dmg + 1
		data.p_range = data.p_range + 1
		data.p_luck = data.p_luck + 1
	end

	if row == 1 then --移速
		if column == 1 then --降低
			if data.spd - 0.1 >= self.StatsLimit.MinSpeed then
				data.spd = data.spd - 0.1
				DecreasePenalty()
				SUCESS = true
			end
		else --提升
			if data.spd < self.StatsLimit.MaxSpeed then
				data.spd = data.spd + 0.15
				data.p_spd = data.p_spd + 1
				SUCESS = true
			end
		end
	elseif row == 2 then --射速
		if column == 1 then
			if data.tears - 0.2 >= self.StatsLimit.MinTears then
				data.tears = data.tears - 0.2

				data.p_spd = math.max(0, data.p_spd - 2)
				data.p_dmg = math.max(0, data.p_dmg - 2)
				data.p_range = math.max(0, data.p_range - 2)
				data.p_luck = math.max(0, data.p_luck - 2)

				SUCESS = true
			end
		else
			if data.tears < self.StatsLimit.MaxTears then
				data.tears = data.tears + 0.35
				IncreasePenalty()
				SUCESS = true
			end
		end
	elseif row == 3 then --伤害
		if column == 1 then
			if data.dmg - 0.3 >= self.StatsLimit.MinDamage then
				data.dmg = data.dmg - 0.3

				data.p_spd = math.max(0, data.p_spd - 2)
				data.p_tears = math.max(0, data.p_tears - 2)
				data.p_range = math.max(0, data.p_range - 2)
				data.p_luck = math.max(0, data.p_luck - 2)

				SUCESS = true
			end
		else
			data.dmg = data.dmg + 0.5
			IncreasePenalty()
			SUCESS = true
		end
	elseif row == 4 then --射程
		if column == 1 then
			if data.range - 1 >= self.StatsLimit.MinRange then
				data.range = data.range - 1
				DecreasePenalty()
				SUCESS = true
			end
		else
			data.range = data.range + 1.25
			data.p_range = data.p_range + 1
			SUCESS = true
		end
	elseif row == 5 then --弹速
		if column == 1 then
			if data.sspd - 0.4 >= self.StatsLimit.MinShotSpeed then
				data.sspd = data.sspd - 0.4
				DecreasePenalty()
				SUCESS = true
			end
		else
			if data.sspd < self.StatsLimit.MaxShotSpeed then
				data.sspd = data.sspd + 0.15
				SUCESS = true
			end
		end
	elseif row == 6 then --幸运
		if column == 1 then
			if data.luck - 1 >= self.StatsLimit.MinLuck then
				data.luck = data.luck - 1
				DecreasePenalty()
				SUCESS = true
			end
		else
			data.luck = data.luck + 1
			data.p_luck = data.p_luck + 1
			SUCESS = true
		end
	end

	if SUCESS then
		data.Points = math.max(0, data.Points - cost)
		if playSound then
			if column == 1 then
				sfx:Play(267)
			else
				sfx:Play(268)
			end
		end
		player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
	else
		if playSound then
			sfx:Play(187, 1, 30)
		end			
	end

	return SUCESS
end


--昧化伊甸的技能是否达到特定等级
local function Skill(player, key, lv)
	if player:GetPlayerType() == BEden.ID and BEden:GetData(player)[key] >= lv then
		return true
	end
	return false
end

--是否有昧化伊甸的技能达到特定等级
local function AnyoneSkill(key, lv)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if Skill(player, key, lv) then
			return true
		end
	end
	return false
end


--获取已选择的物品
function BEden:GetSelectedItem(player)
	if player:GetPlayerType() ~= self.ID then return 0 end
	local data = self:GetData(player)
	if data.section ~= 2 then return 0 end
	local inv = self:GetInventory(player)
	local tbl = inv[data.page]
	if tbl then
		local item = tbl[5*(data.row-1)+data.column]
		if item then
			return item
		end
	end

	return nil
end

--获取物品点数价值
function BEden:GetItemPointValue(id, player, isTrinket, isSmeltedTrinket)
	local itemConfig = (isTrinket and config:GetTrinket(id)) or config:GetCollectible(id)
	if not itemConfig then return 0 end

	--万物一心5级才允许操作饰品
	if isTrinket and player and Skill(player, 'all_for_one', 5) then
		if isSmeltedTrinket then
			local data = self:GetData(player)
			local value = 5
			local Max = GetAllForOneMaxPoints(data.all_for_one)

			while data.allForOneToken + value > Max do
				value = value - 1
			end

			return value
		else
			return -7
		end
	else
		local quality = math.max(0, itemConfig.Quality or 0)
		if id == 550 or id == 551 then quality = 2 end --妈铲部件视为2级
		local value = math.floor(3 ^ quality)
		local greed = game:IsGreedMode()

		if player and player:GetPlayerType() == self.ID then
			local data = self:GetData(player)

			--渎神,长子权效果
			if data.Blasphemer then
				value = value * 3
			end

			--星盘效果
			if (greed and data.astrolabe >= 1) or data.astrolabe >= 2 then
				if itemConfig:HasTags(ItemConfig.TAG_STARS) then
					local mult = (greed and 1.25) or 1.4
					value = math.ceil(value * mult)
				end
			end

			if data.my_path > 0 then
				--我行我素2级
				if data.my_path >= 2 then
					value = math.ceil(value * 1.25)
				end
			else
				--行歧路者2级
				if data.another_path >= 2 then
					if quality >= 2 then
						value = math.ceil(value * 1.6)
					else
						value = 0
					end
				end

				--所谓正道1级
				if data.the_path >= 1 and (data.another_path <= 0 or player:HasCollectible(498)) then
					value = math.max(7 , value)
				end
			end
		end

		return value
	end	
	
	return 0
end

--触发物品区效果
function BEden:TriggerItemsSection(player, row, column, page, playSound)
	if player:GetPlayerType() ~= self.ID then return false end
	local inv = self:GetInventory(player)
	local tbl = inv[page]
	if not tbl then return end
	local key = 5*(row-1) + column
	local item = tbl[key]
	if not item then return end
	local data = self:GetData(player)

	--万物一心5级才允许操作饰品
	if item.Type == 'Trinket' and data.all_for_one >= 5 then
		local value = self:GetItemPointValue(item.ID, player, true, item.Slot == -1)
		
		--吞下饰品
		if value < 0 then
			if data.Points >= (-value) then
				player:TryRemoveTrinket(item.ID)
				player:AddSmeltedTrinket(item.ID, false)
				data.Points = data.Points + value
				table.remove(tbl, key)
				if playSound then
					sfx:Play(157, 1, 1, false, 1)
				end				
			else
				if playSound then
					sfx:Play(187, 1, 30)
				end
			end
		else--转换被吞下的饰品
			player:TryRemoveSmeltedTrinket(item.ID)
			data.allForOneToken = data.allForOneToken + value
			data.Points = data.Points + value
			table.remove(tbl, key)
			if playSound then
				sfx:Play(33, 1, 1, false, 1)
			end
		end

		return true
	else
		local value = self:GetItemPointValue(item.ID, player)

		if value >= 0 then
			data.Points = data.Points + value
			player:RemoveCollectible(item.ID, true, item.Slot or -1, item.Type ~= 'Active')

			--触发长子权效果
			if item.ID == 619 then
				player:AddBrokenHearts(-player:GetBrokenHearts())
				player:AddBoneHearts(3)
				player:SetFullHearts()
				data.Blasphemer = true
			end

			table.remove(tbl, key)
			
			--击碎命运
			local lv = data.crack_the_destiny
			if lv > 0 then
				data.crackDestinyToken = data.crackDestinyToken + 1
				
				local cost = (game:IsGreedMode() and 3) or 4
				if data.crackDestinyToken >= cost then
					local level = game:GetLevel()
					level:RemoveCurses(LevelCurse.CURSE_OF_THE_UNKNOWN)
					level:RemoveCurses(LevelCurse.CURSE_OF_BLIND)
					
					--2级效果
					if lv >= 2 then
						local room = game:GetRoom()
						local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
						Isaac.Spawn(5, 10, 0, pos, Vector.Zero, nil)

						pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
						Isaac.Spawn(5, 20, 0, pos, Vector.Zero, nil)

						pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
						Isaac.Spawn(5, 30, 0, pos, Vector.Zero, nil)

						pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
						Isaac.Spawn(5, 40, 0, pos, Vector.Zero, nil)						
					end

					--3级效果
					if lv >= 3 then
						local room = game:GetRoom()
						local pos = room:FindFreePickupSpawnPosition(player.Position, 0, true)
						Isaac.Spawn(5, 300, 49, pos, Vector.Zero, nil)					
					end

					data.crackDestinyToken = data.crackDestinyToken - cost
				end
			end
			
			if playSound then
				sfx:Play(33, 1, 1, false, 1)
			end

			return true
		end
	end

	return false
end


--根据坐标获取技能等级
function BEden:GetSkillLevel(player, row, column)
	if player:GetPlayerType() ~= self.ID then return 0 end
	local data = self:GetData(player)

	if row == 1 then
		if column == 1 then --定义域+
			return data.definition_up
		end
		if column == 2 then --9伏增压
			return data.volt9
		end
		if column == 3 then --备用电池
			return data.battery
		end
	elseif row == 2 then
		if column == 1 then --耸肩无视
			return data.shrug_it_off
		end
		if column == 2 then --寻真
			return data.sought
		end
		if column == 3 then --击碎命运
			return data.crack_the_destiny
		end
	elseif row == 3 then
		if column == 1 then --御血
			return data.hemokinesis
		end
		if column == 2 then --万物一心
			return data.all_for_one
		end
		if column == 3 then --精炼混沌 
			return data.distilled_chaos
		end
	elseif row == 4 then
		if column == 1 then --他山之石
			return data.foreign_influence
		end
		if column == 2 then --星盘
			return data.astrolabe
		end
		if column == 3 then --贪婪滋生
			return data.growing_greed
		end
	elseif row == 5 then
		if column == 1 then --应急按钮
			return data.panic_button
		end		
		if column == 2 then --立地升天
			return data.reach_sky
		end		
		if column == 3 then --巩固
			return data.entrench
		end		
	elseif row == 6 then
		if column == 1 then --所谓正道
			return data.the_path
		end
		if column == 2 then --我行我素
			return data.my_path
		end
		if column == 3 then --行歧路者 
			return data.another_path
		end		
	end

	return 0
end

--获取技能加点价格
function BEden:GetSkillsSectionCost(player, row, column)
	if player:GetPlayerType() ~= self.ID then return 0 end
	local data = self:GetData(player)
	local greed = game:IsGreedMode()

	if row == 1 then
		--定义域+
		if column == 1 and data.definition_up < ((greed and 3) or 4) then
			return 6 + (3 ^ data.definition_up)
		end

		--9伏增压
		if column == 2 and data.volt9 < 1 then
			return 49
		end
		
		--备用电池
		if column == 3 and data.battery < 1 then
			return 49
		end
	elseif row == 2 then
		--耸肩无视
		if column == 1 then
			if data.shrug_it_off < ((greed and 1) or 3) then
				return 5 * (1 + data.shrug_it_off)
			end
		end

		--寻真
		if column == 2 then
			if data.sought < ((greed and 2) or 4) then
				if greed then
					return 5 + (20 * data.sought)
				else				
					return 5 + (3 * data.sought)
				end
			end
		end

		--击碎命运
		if column == 3 then 
			if data.crack_the_destiny < 3 then
				return 8 + (8 * data.crack_the_destiny)
			end
		end		
	elseif row == 3 then
		--御血
		if column == 1 then
			if data.hemokinesis < 6 then
				return 6 + 6 * data.hemokinesis
			end
		end
		
		--万物一心
		if column == 2 then 
			if data.all_for_one < 5 then
				return 5
			end
		end
		
		--精炼混沌
		if column == 3 then 
			if data.distilled_chaos < 6 then
				return 6 + 6 * data.distilled_chaos
			end
		end
	elseif row == 4 then
		--他山之石
		if column == 1 then
			if data.foreign_influence < 8 then
				return 7
			end
		end

		--星盘
		if column == 2 then
			if greed then
				if data.astrolabe < 2 then
					return 12 + (12 * data.astrolabe)
				end
			elseif data.astrolabe < 4 then
				return 12 + (6 * data.astrolabe)
			end
		end

		--贪婪滋生
		if column == 3 then
			if data.growing_greed < 6 then
				return 2 ^ (1 + data.growing_greed)
			end
		end
	elseif row == 5 then
		--应急按钮
		if column == 1 then
			if data.panic_button < 2 then
				return 5
			end
		end
		
		--立地升天
		if column == 2 then
			if data.reach_sky < 1 then
				return 49
			end
		end

		--巩固
		if column == 3 then
			if data.entrench < 3 then
				return 10 + (15 * data.entrench)
			end
		end
	elseif row == 6 then
		local duality = player:HasCollectible(498)

		--所谓正道
		if column == 1 and data.the_path < ((greed and 4) or 5) then
			if data.my_path <= 0 and (data.another_path <= 0 or duality) then
				return 7 + (7 * data.the_path)
			end
		end

		--我行我素
		if column == 2 and data.my_path > 0 and data.my_path < 5 then
			if data.the_path <= 0 and data.another_path <= 0 then
				return 25
			end
		end

		--行歧路者
		if column == 3 and data.another_path < ((greed and 5) or 6) then
			if data.my_path <= 0 and (data.the_path <= 0 or duality) then
				return 6 + (6 * data.another_path)
			end
		end		
	end

	return 0
end

--触发技能区效果
function BEden:TriggerSkillsSection(player, row, column, playSound)
	if player:GetPlayerType() ~= self.ID then return false end
	local SUCESS = false
	local data = self:GetData(player)
	local cost = self:GetSkillsSectionCost(player, row, column)

	--判断点数是否足够
	if data.Points < cost then
		if playSound then
			sfx:Play(187, 1, 30)
		end			
		return false
	end

	local greed = game:IsGreedMode()

	--生成
	local function Spawn(T,V,S)
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		Isaac.Spawn(T, V, S, pos, Vector.Zero, nil)
	end

	if row == 1 then
		--定义域+
		if column == 1 and data.definition_up < ((greed and 3) or 4) then
			data.definition_up = data.definition_up + 1
			SUCESS = true
		end

		--9伏增压
		if column == 2 and data.volt9 < 1 then
			data.volt9 = data.volt9 + 1
			SUCESS = true
		end
		
		--备用电池
		if column == 3 and data.battery < 1 then
			data.battery = data.battery + 1
			SUCESS = true
		end
	elseif row == 2 then
		--耸肩无视
		if column == 1 and data.shrug_it_off < ((greed and 1) or 3) then
			data.shrug_it_off = data.shrug_it_off + 1
			
			--3级效果
			if data.shrug_it_off == 3 then
				player:AddCollectible(327)
				player:AddCollectible(328)
				player:AddCollectible(238)
				player:AddCollectible(239)
				player:AddCollectible(626)
				player:AddCollectible(627)
			end

			SUCESS = true
		end
		
		--寻真
		if column == 2 and data.sought < ((greed and 2) or 4) then
			data.sought = data.sought + 1
			
			--4级效果
			if data.sought == 4 then
				game:GetLevel():RemoveCurses(LevelCurse.CURSE_OF_THE_LOST)
			end

			SUCESS = true
		end
		
		--击碎命运
		if column == 3 and data.crack_the_destiny < 3 then
			data.crack_the_destiny = data.crack_the_destiny + 1
			SUCESS = true
		end
	elseif row == 3 then
		--御血
		if column == 1 and data.hemokinesis < 6 then
			data.hemokinesis = data.hemokinesis + 1

			if data.hemokinesis == 2 then
				player:AddSmeltedTrinket(107)
			end
			if data.hemokinesis == 3 then
				local num = (greed and 6) or 4
				player:AddMaxHearts(num)
				player:AddHearts(num)
			end

			SUCESS = true
		end
		
		--万物一心
		if column == 2 and data.all_for_one < 5 then
			data.all_for_one = data.all_for_one + 1
			SUCESS = true
		end
		
		--精炼混沌
		if column == 3 and data.distilled_chaos < 6 then
			data.distilled_chaos = data.distilled_chaos + 1
			SUCESS = true
		end		
	elseif row == 4 then
		--他山之石
		if column == 1 and data.foreign_influence < 8 then
			data.foreign_influence = data.foreign_influence + 1

			if data.foreign_influence == 1 then
				player:AddBombs(1)
				player:AddMaxHearts(2)
				player:AddHearts(2)
			end
			if data.foreign_influence == 2 then
				player:AddKeys(1)
				player:AddCoins(30)
			end
			if data.foreign_influence == 3 then
				Spawn(5,100,36)
				Spawn(5,100,117)
			end
			if data.foreign_influence == 4 then
				Spawn(5,350,34)
				Spawn(5,350,162)
			end
			if data.foreign_influence == 5 then
				Spawn(5,300,89)
				Spawn(5,300,91)
			end
			if data.foreign_influence == 6 then
				if greed then
					Spawn(5,100,416)
				else
					player:AddSmeltedTrinket(110)
				end
				player:AddSmeltedTrinket(141)
			end
			if data.foreign_influence == 7 then
				player:AddBoneHearts(2)
				player:AddSoulHearts(2)
			end
			if data.foreign_influence == 8 then
				player:AddCollectible(619)
			end

			SUCESS = true
		end

		--星盘
		if column == 2 then
			if greed then
				if data.astrolabe < 2 then
					data.astrolabe = data.astrolabe + 1
					SUCESS = true
				end
			elseif data.astrolabe < 4 then
				data.astrolabe = data.astrolabe + 1
				
				--3级效果
				if data.astrolabe == 3 then
					Spawn(5, 350, 152)
				end	
					
				SUCESS = true
			end
		end
		
		--贪婪滋生
		if column == 3 and data.growing_greed < 6 then
			data.growing_greed = data.growing_greed + 1
			
			if data.growing_greed == 3 then
				Spawn(5, 350, 24)
				Spawn(5, 350, 126)
			end	
			if data.growing_greed == 4 then
				player:AddSmeltedTrinket(52)
			end	
			if data.growing_greed == 5 then
				Spawn(5, 350, 49)
				Spawn(5, 350, 50)
				Spawn(5, 350, 51)
			end	
			if data.growing_greed == 6 then
				player:AddSmeltedTrinket(1)
				Spawn(5, 350, 131)
				Spawn(5, 350, 147)
			end	

			SUCESS = true
		end		
	elseif row == 5 then
		--应急按钮
		if column == 1 and data.panic_button < 2 then
			data.panic_button = data.panic_button + 1
			
			if data.panic_button == 1 then
				Spawn(5,350,149)
			end
			if data.panic_button == 2 then
				player:AddCollectible(IBS_ItemID.SuperPanicButton)
			end
			
			SUCESS = true
		end
	
		--立地升天
		if column == 2 and data.reach_sky < 1 then
			data.reach_sky = data.reach_sky + 1
			
			--贪婪模式额外给天梯
			if greed and data.reach_sky == 1 then
				player:AddCollectible(586)
			end

			SUCESS = true
		end

		--巩固
		if column == 3 and data.entrench < 3 then
			data.entrench = data.entrench + 1
			SUCESS = true
		end	
	elseif row == 6 then
		local duality = player:HasCollectible(498)

		--所谓正道
		if column == 1 and data.the_path < ((greed and 4) or 5) then
			if data.my_path <= 0 and (data.another_path <= 0 or duality) then
				data.the_path = data.the_path + 1
				
				--5级效果
				if data.the_path == 5 then
					game:GetLevel():AddAngelRoomChance(1)
				end
				
				SUCESS = true
			end
		end

		--我行我素
		if column == 2 and data.my_path > 0 and data.my_path < 5 then
			if data.the_path <= 0 and data.another_path <= 0 then
				data.my_path = data.my_path + 1
				player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
				SUCESS = true
			end
		end

		--行歧路者
		if column == 3 and data.another_path < ((greed and 5) or 6) then
			if data.my_path <= 0 and (data.the_path <= 0 or duality) then
				data.another_path = data.another_path + 1

				--1级效果
				if data.another_path == 1 then
					game:AddDevilRoomDeal()
					sfx:Play(316)
				end
				
				--4级效果
				if data.another_path == 4 then
					player:AddSmeltedTrinket(56)
				end
				
				SUCESS = true
			end
		end
	end

	if SUCESS then
		data.Points = math.max(0, data.Points - cost)
		if playSound then
			sfx:Play(268)
		end
	else
		if playSound then
			sfx:Play(187, 1, 30)
		end			
	end

	return SUCESS
end

--是否能打开面板
function BEden:CanOpenConsole(player)
	local level = game:GetLevel()
	if player:GetPlayerType() == self.ID and level:GetStartingRoomIndex() == level:GetCurrentRoomDesc().SafeGridIndex and game:GetRoom():IsClear() then
		return true
	end

	return false
end

--初始房间用已定义操作面板
function BEden:OnUseItem(item, rng, player, flag, slot)
	if (flag & UseFlag.USE_OWNED > 0) and slot == 2 then
		if self:CanOpenConsole(player) then
			self._Players:TryHoldItem(item, player, flag, slot)
		end
	end	
end
BEden:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUseItem', IBS_ItemID.Defined)

--等待时间,用于修正
local wait = 0

--尝试打开面板
function BEden:OnTryHoldItem(item, player, flag, slot, holdingItem)
	if holdingItem <= 0 and self:CanOpenConsole(player) and slot == 2 then
		local canHold = true

		if (flag & UseFlag.USE_OWNED <= 0) or (flag & UseFlag.USE_CARBATTERY > 0) or (flag & UseFlag.USE_VOID > 0) then
			canHold = false
		end
		
		--一次只能打开一个面板
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == self.ID and self._Players:IsHoldingItem(player, self.ID) then
				canHold = false
				break
			end
		end

		--刷新物品栏
		if canHold then
			local data = self:GetData(player)
			BEden:RefreshInventory(player)
			data.page = math.min(data.page, #self:GetInventory(player))
			wait = 15
		end

		return {
			CanHold = canHold,
			AllowHurt = true,
		}
	end
end
BEden:AddCallback(IBS_CallbackID.TRY_HOLD_ITEM, 'OnTryHoldItem', IBS_ItemID.Defined)


--正在打开面板
function BEden:OnHoldingItem(item, player, flag, slot)
	if game:IsPaused() then return end
	if slot ~= 2 then return end
	if not self:CanOpenConsole(player) then return end
	local cid = player.ControllerIndex

	player:AddControlsCooldown(1) --防止角色乱动

	--按丢弃键结束握住
	if Input.IsActionTriggered(ButtonAction.ACTION_DROP, cid) then
		return false
	end

	local data = self:GetData(player)

	--切换区域
	if Input.IsActionTriggered(ButtonAction.ACTION_LEFT, cid) then
		if data.section > 1 then
			data.section = data.section - 1
		else
			data.section = 3
		end
		data.row,data.column = 1,1
	end
	if Input.IsActionTriggered(ButtonAction.ACTION_RIGHT, cid) then
		if data.section < 3 then
			data.section = data.section + 1
		else
			data.section = 1
		end
		data.row,data.column = 1,1
	end

	local UP = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, cid)
	local DOWN = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, cid)
	local LEFT = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, cid)
	local RIGHT = Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, cid)

	--属性区
	if data.section == 1 then
		if UP then
			if data.row > 1 then
				data.row = data.row - 1
			else
				data.row = 6
			end
		end
		if DOWN then
			if data.row < 6 then
				data.row = data.row + 1
			else
				data.row = 1
			end
		end
		if LEFT then
			if data.column > 1 then
				data.column = data.column - 1
			else
				data.column = 2
			end
		end
		if RIGHT then
			if data.column < 2 then
				data.column = data.column + 1
			else
				data.column = 1
			end
		end
	end
	
	--物品区
	local maxPages = #self:GetInventory(player)
	if data.section == 2 then
		if UP then
			if data.row > 1 then
				data.row = data.row - 1
			else
				data.row = 3
			end
		end
		if DOWN then
			if data.row < 3 then
				data.row = data.row + 1
			else
				data.row = 1
			end
		end
		if LEFT then
			if data.column > 1 then
				data.column = data.column - 1
			else
				data.column = 5

				if data.page > 1 then
					data.page = data.page - 1
				else
					data.page = maxPages
				end
			end
		end
		if RIGHT then
			if data.column < 5 then
				data.column = data.column + 1
			else
				data.column = 1
				
				if data.page < maxPages then
					data.page = data.page + 1
				else
					data.page = 1
				end	
			end
		end
		
		--快捷切换页码
		if Input.IsActionTriggered(ButtonAction.ACTION_UP, cid) then
			if data.page > 1 then
				data.page = data.page - 1
			else
				data.page = maxPages
			end
		end
		if Input.IsActionTriggered(ButtonAction.ACTION_DOWN, cid) then
			if data.page < maxPages then
				data.page = data.page + 1
			else
				data.page = 1
			end	
		end		
	end	
	
	--技能区
	if data.section == 3 then
		if UP then
			if data.row > 1 then
				data.row = data.row - 1
			else
				data.row = 6
			end
		end
		if DOWN then
			if data.row < 6 then
				data.row = data.row + 1
			else
				data.row = 1
			end
		end
		if LEFT then
			if data.column > 1 then
				data.column = data.column - 1
			else
				data.column = 3
			end
		end
		if RIGHT then
			if data.column < 3 then
				data.column = data.column + 1
			else
				data.column = 1
			end
		end
	end

end
BEden:AddCallback(IBS_CallbackID.HOLDING_ITEM, 'OnHoldingItem', IBS_ItemID.Defined)

local beden_hud = Sprite('gfx/ibs/ui/players/beden_hud.anm2')
beden_hud:Play('Idle')

local beden_sel = Sprite('gfx/ibs/ui/players/beden_icons.anm2')
beden_sel:Play('Selection')

--面板显示及操作
function BEden:OnHUDRender()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local isHolding,slot = self._Players:IsHoldingItem(player, IBS_ItemID.Defined)
		
		if self:CanOpenConsole(player) and isHolding and slot == 2 then
			local data = self:GetData(player)
			local greed = game:IsGreedMode()
			local duality = player:HasCollectible(498)
			local pos = Vector.Zero

			--按口袋物品键操作面板
			if wait <= 0 and (not game:IsPaused()) and Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, player.ControllerIndex) then
				--属性区
				if data.section == 1 then
					self:TriggerStatsSection(player, data.row, data.column, true)
				end

				--物品区
				if data.section == 2 then
					self:TriggerItemsSection(player, data.row, data.column, data.page, true)
				end

				--技能区
				if data.section == 3 then
					self:TriggerSkillsSection(player, data.row, data.column, true)
				end	
			end
			if wait > 0 then
				wait = wait - 1
			end

			--面板背景
			beden_hud:Render(Vector(208, 128))
			local anim = 'Idle'
			if data.Blasphemer then
				anim = 'Idle2'
			end
			beden_hud:Play(anim)

			--显示点数
			fnt:DrawStringScaled(math.floor(data.Points), 130, 17, 1, 1, KColor(1,1,1,1), 144, true)


			--属性区显示是否达到上下限
			if data.spd - 0.1 < self.StatsLimit.MinSpeed then
				fnt:DrawStringScaled('X', 60, 34, 2, 2, KColor(1,0,0,1), 32, true)
			end
			if data.spd >= self.StatsLimit.MaxSpeed then
				fnt:DrawStringScaled('X', 86, 34, 2, 2, KColor(1,0,0,1), 32, true)
			end
			if data.tears - 0.2 < self.StatsLimit.MinTears then
				fnt:DrawStringScaled('X', 60, 67, 2, 2, KColor(1,0,0,1), 32, true)
			end
			if data.tears >= self.StatsLimit.MaxTears then
				fnt:DrawStringScaled('X', 86, 66, 2, 2, KColor(1,0,0,1), 32, true)
			end
			if data.dmg - 0.3 < self.StatsLimit.MinDamage then
				fnt:DrawStringScaled('X', 60, 100, 2, 2, KColor(1,0,0,1), 32, true)
			end
			if data.range - 1 < self.StatsLimit.MinRange then
				fnt:DrawStringScaled('X', 60, 131, 2, 2, KColor(1,0,0,1), 32, true)
			end
			if data.sspd - 0.4 < self.StatsLimit.MinShotSpeed then
				fnt:DrawStringScaled('X', 60, 163, 2, 2, KColor(1,0,0,1), 32, true)
			end
			if data.sspd >= self.StatsLimit.MaxShotSpeed then
				fnt:DrawStringScaled('X', 86, 163, 2, 2, KColor(1,0,0,1), 32, true)
			end
			if data.luck - 1 < self.StatsLimit.MinLuck then
				fnt:DrawStringScaled('X', 60, 196, 2, 2, KColor(1,0,0,1), 32, true)
			end


			--显示物品区的道具
			local inv = self:GetInventory(player)
			local X,Y = 140,114
			local _column = 1
			local tbl = inv[data.page]
			if tbl then
				for _,v in ipairs(tbl) do
					v.Sprite:Render(Vector(X,Y))

					X = X + 31.5
					_column = _column + 1

					if _column > 5 then
						X = 142
						Y = Y + 32
						_column = 1
					end
				end
			end
			--显示物品区页码
			fnt:DrawStringScaled(tostring(data.page)..'/'..tostring(#inv), 133, 206, 1, 1, KColor(1,1,1,1), 144, true)


			--技能区显示等级
			if data.definition_up > 0 then
				local color = KColor(0,1,0,0.7)
				
				if greed then
					if data.definition_up >= 3 then
						color = KColor(1,1,0,0.7)
					end
				else
					if data.definition_up >= 4 then
						color = KColor(1,1,0,0.7)
					end				
				end

				fnt:DrawStringScaled(RomanNumber(data.definition_up), 292, 41, 1.25, 1.25, color, 32, true)
			end
			if data.volt9 > 0 then
				fnt:DrawStringScaled(RomanNumber(data.volt9), 323, 41, 1.25, 1.25, KColor(1,1,0,0.7), 32, true)
			end
			if data.battery > 0 then
				fnt:DrawStringScaled(RomanNumber(data.battery), 354, 41, 1.25, 1.25, KColor(1,1,0,0.7), 32, true)
			end
			if data.shrug_it_off > 0 then
				local color = KColor(0,1,0,0.7)
				
				if greed then
					if data.shrug_it_off >= 1 then
						color = KColor(1,1,0,0.7)
					end
				else
					if data.shrug_it_off >= 3 then
						color = KColor(1,1,0,0.7)
					end				
				end

				fnt:DrawStringScaled(RomanNumber(data.shrug_it_off), 292, 73, 1.25, 1.25, color, 32, true)
			end
			if data.sought > 0 then
				local color = KColor(0,1,0,0.7)
				
				if greed then
					if data.sought >= 2 then
						color = KColor(1,1,0,0.7)
					end
				else
					if data.sought >= 4 then
						color = KColor(1,1,0,0.7)
					end				
				end

				fnt:DrawStringScaled(RomanNumber(data.sought), 323, 73, 1.25, 1.25, color, 32, true)
			end
			if data.crack_the_destiny > 0 then
				local color = KColor(0,1,0,0.7)
				
				if data.crack_the_destiny >= 3 then
					color = KColor(1,1,0,0.7)
				end

				fnt:DrawStringScaled(RomanNumber(data.crack_the_destiny), 354, 73, 1.25, 1.25, color, 32, true)
			end	
			if data.hemokinesis > 0 then
				local color = KColor(0,1,0,0.7)
				
				if data.hemokinesis >= 6 then
					color = KColor(1,1,0,0.7)
				end

				fnt:DrawStringScaled(RomanNumber(data.hemokinesis), 292, 105, 1.25, 1.25, color, 32, true)
			end
			if data.all_for_one > 0 then
				local color = KColor(0,1,0,0.7)
				
				if data.all_for_one >= 5 then
					color = KColor(1,1,0,0.7)
				end

				fnt:DrawStringScaled(RomanNumber(data.all_for_one), 323, 105, 1.25, 1.25, color, 32, true)
			end
			if data.distilled_chaos > 0 then
				local color = KColor(0,1,0,0.7)
				
				if data.distilled_chaos >= 6 then
					color = KColor(1,1,0,0.7)
				end

				fnt:DrawStringScaled(RomanNumber(data.distilled_chaos), 354, 105, 1.25, 1.25, color, 32, true)
			end
			if data.foreign_influence > 0 then
				local color = KColor(0,1,0,0.7)
				
				if data.foreign_influence >= 8 then
					color = KColor(1,1,0,0.7)
				end

				fnt:DrawStringScaled(RomanNumber(data.foreign_influence), 292, 137, 1.25, 1.25, color, 32, true)
			end
			if data.astrolabe > 0 then
				local color = KColor(0,1,0,0.7)
				
				if greed then
					if data.astrolabe >= 2 then
						color = KColor(1,1,0,0.7)
					end
				else
					if data.astrolabe >= 4 then
						color = KColor(1,1,0,0.7)
					end				
				end

				fnt:DrawStringScaled(RomanNumber(data.astrolabe), 323, 137, 1.25, 1.25, color, 32, true)
			end			
			if data.growing_greed > 0 then
				local color = KColor(0,1,0,0.7)
				
				if data.growing_greed >= 6 then
					color = KColor(1,1,0,0.7)
				end

				fnt:DrawStringScaled(RomanNumber(data.growing_greed), 354, 137, 1.25, 1.25, color, 32, true)
			end
			if data.panic_button > 0 then
				local color = KColor(0,1,0,0.7)
				
				if data.panic_button >= 2 then
					color = KColor(1,1,0,0.7)
				end

				fnt:DrawStringScaled(RomanNumber(data.panic_button), 292, 169, 1.25, 1.25, color, 32, true)
			end
			if data.reach_sky > 0 then
				fnt:DrawStringScaled(RomanNumber(data.reach_sky), 323, 169, 1.25, 1.25, KColor(1,1,0,0.7), 32, true)
			end
			if data.entrench > 0 then
				local color = KColor(0,1,0,0.7)
				
				if data.entrench >= 3 then
					color = KColor(1,1,0,0.7)
				end

				fnt:DrawStringScaled(RomanNumber(data.entrench), 354, 169, 1.25, 1.25, color, 32, true)
			end			
			if data.the_path > 0 and data.my_path <= 0 and (data.another_path <= 0 or duality) then
				local color = KColor(0,1,0,0.7)
				
				if greed then
					if data.the_path >= 4 then
						color = KColor(1,1,0,0.7)
					end
				else
					if data.the_path >= 5 then
						color = KColor(1,1,0,0.7)
					end				
				end

				fnt:DrawStringScaled(RomanNumber(data.the_path), 292, 201, 1.25, 1.25, color, 32, true)

				fnt:DrawStringScaled('X', 324, 195, 2, 2, KColor(1,0,0,1), 32, true)
				if not duality then
					fnt:DrawStringScaled('X', 356, 195, 2, 2, KColor(1,0,0,1), 32, true)
				end
			end		
			if data.my_path >= 1 then
				local color = KColor(0,1,0,0.7)
				
				if data.my_path >= 5 then
					color = KColor(1,1,0,0.7)
				end

				fnt:DrawStringScaled(RomanNumber(data.my_path), 323, 201, 1.25, 1.25, color, 32, true)

				fnt:DrawStringScaled('X', 292, 195, 2, 2, KColor(1,0,0,1), 32, true)
				fnt:DrawStringScaled('X', 356, 195, 2, 2, KColor(1,0,0,1), 32, true)
			elseif data.my_path <= 0 then
				fnt:DrawStringScaled('X', 324, 195, 2, 2, KColor(1,0,0,1), 32, true)
			end
			if data.another_path > 0 and data.my_path <= 0 then
				local color = KColor(0,1,0,0.7)
				
				if greed then
					if data.another_path >= 5 then
						color = KColor(1,1,0,0.7)
					end
				else
					if data.another_path >= 6 then
						color = KColor(1,1,0,0.7)
					end				
				end

				fnt:DrawStringScaled(RomanNumber(data.another_path), 354, 201, 1.25, 1.25, color, 32, true)

				fnt:DrawStringScaled('X', 324, 195, 2, 2, KColor(1,0,0,1), 32, true)
				if not duality then
					fnt:DrawStringScaled('X', 292, 195, 2, 2, KColor(1,0,0,1), 32, true)
				end
			end




			--显示光标及点数变更
			pos = Vector(43, 16)
			local delta = 0
			if data.section == 1 then --属性区
				pos = Vector(49, 16)
				pos.X = pos.X + data.column * 26
				pos.Y = pos.Y + data.row * 32.5
				delta = -self:GetStatsSectionCost(player, data.row, data.column)
				beden_sel:SetFrame(0)
			end
			if data.section == 2 then --物品区
				pos = Vector(108, 83)
				pos.X = pos.X + data.column * 32
				pos.Y = pos.Y + data.row * 32
				
				local item = self:GetSelectedItem(player)
				if item then
					delta = self:GetItemPointValue(item.ID, player, item.Type == 'Trinket', item.Slot == -1)
				end
				beden_sel:SetFrame(1)
			end
			if data.section == 3 then --技能区
				pos = Vector(277, 18)
				pos.X = pos.X + data.column * 31
				pos.Y = pos.Y + data.row * 32				
				delta = -self:GetSkillsSectionCost(player, data.row, data.column)
				beden_sel:SetFrame(0)
			end

			beden_sel:Render(pos)

			if delta ~= 0 then
				local color = KColor(0,1,0,1)
				local str = ''

				if delta > 0 then
					str = '+'..str
				end
				if delta < 0 then
					delta = -delta
					str = '-'..str
					color = KColor(1,0,0,1)
				end

				str = str..tostring(math.floor(delta))
				
				fnt:DrawStringScaled(str, 128, 81, 1, 1, color, 144, true)
			end


			--显示描述
			local info = self.SkillTreeInfo[mod.Language]
			if data.section == 1 then --属性区
				local Y = 40
				local tbl = (info[1][data.column] and info[1][data.column][data.row]) or {}
				for _,str in ipairs(tbl) do
					fnt2:DrawStringScaledUTF8(str, 130, Y, 1, 1, KColor(1,1,1,1), 144, true)
					Y = Y + 16
				end
			end
			if data.section == 2 then --物品区
				local item = self:GetSelectedItem(player)
				if item then
					if item.Type == 'Trinket' and data.all_for_one >= 5 then
						if item.Slot == -1 then
							fnt2:DrawStringScaledUTF8(info[2][1], 130, 42, 1, 1, KColor(1,1,1,1), 144, true)
							local str = '('..tostring(data.allForOneToken)..'/'..tostring(GetAllForOneMaxPoints(data.all_for_one))..')'
							fnt2:DrawStringScaledUTF8(str, 130, 54, 1, 1, KColor(1,1,1,1), 144, true)
						else
							fnt2:DrawStringScaledUTF8(info[2][2], 130, 48, 1, 1, KColor(1,1,1,1), 144, true)
						end
					else
						if item.ID ~= 619 then
							fnt2:DrawStringScaledUTF8(info[2][1], 130, 48, 1, 1, KColor(1,1,1,1), 144, true)
						else--长子权描述
							fnt2:DrawStringScaledUTF8(info[2][3], 130, 32, 1, 1, KColor(1,1,1,1), 144, true)
							fnt2:DrawStringScaledUTF8(info[2][4], 130, 42, 1, 1, KColor(1,1,1,1), 144, true)
							fnt2:DrawStringScaledUTF8(info[2][5], 130, 52, 1, 1, KColor(1,1,1,1), 144, true)
							fnt2:DrawStringScaledUTF8(info[2][6], 130, 62, 1, 1, KColor(1,0,0,1), 144, true)
						end						
					end
				end
			end
			if data.section == 3 then --技能区
				local tbl = (info[3][data.column] and info[3][data.column][data.row])
				if tbl then
					local Max = (greed and tbl.GreedMax) or tbl.Max or 1
					local desc = (greed and tbl.GreedDesc) or tbl.Desc or {}
					local lv = math.min(self:GetSkillLevel(player, data.row, data.column)+1, Max)

					local name = tbl.Name
					if Max > 1 then
						name = name..' '..RomanNumber(lv)
					end
					fnt2:DrawStringScaledUTF8(name, 130, 30, 1, 1, KColor(1,1,1,1), 144, true)

					local Y = 43
					for _,str in ipairs(desc[lv] or {}) do
						fnt2:DrawStringScaledUTF8(str, 130, Y, 1, 1, KColor(1,1,1,1), 144, true)
						Y = Y + 10
					end
				end
			end


			break
		end
	end
end
BEden:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, 'OnHUDRender')



----------------以下均为技能区实现----------------
--已定义相关技能实现在已定义文件内(defined.lua)
--动人诅咒相关技能实现在动人诅咒文件内(moving.lua)

--耸肩无视1级
function BEden:ShrugItOff(door)
	if not game:IsGreedMode() and door:IsRoomType(RoomType.ROOM_SECRET_EXIT) and door:IsLocked() then
		if AnyoneSkill('shrug_it_off', 1) then
			door:SetLocked(false)
		end
	end
end
BEden:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, 'ShrugItOff')

--耸肩无视2级
function BEden:ShrugItOff2()
	if game:IsGreedMode() then return end
	local room = game:GetRoom()
	if room:IsClear() and AnyoneSkill('shrug_it_off', 2) then
		local bossID = room:GetBossID()
		
		if bossID == BossType.MOM then
			room:TrySpawnBossRushDoor(true)
		end
		if bossID == BossType.MOMS_HEART or bossID == BossType.IT_LIVES then		
			room:TrySpawnBlueWombDoor(false, true)
		end
	end
end
BEden:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'ShrugItOff2')
BEden:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, 'ShrugItOff2')

--贪婪模式耸肩无视1级
function BEden:ShrugItOff_Greed(player, dmg, flag, source)
	if game:IsGreedMode() and flag == 268435584 and Skill(player, 'shrug_it_off', 1) then
		return false
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -1000, 'ShrugItOff_Greed')


--寻真1和2级
function BEden:Sought1And2()
	if game:IsGreedMode() then return end
	local room = game:GetRoom()
	if not room:IsClear() then return end

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			local lv = data.sought
			
			if lv > 0 then
				if data.soughtToken < 1 then
					data.soughtToken = data.soughtToken + 1
				else
					data.soughtToken = 0
					if lv >= 1 then
						local level = game:GetLevel()
						for i = 1,169 do
							local roomData = level:GetRoomByIdx(i).Data					
							if roomData and roomData.Type ~= 0 and roomData.Type ~= 1 then
								local roomDesc = level:GetRoomByIdx(i)
								local flag = (1<<2)
								if roomDesc and roomDesc.DisplayFlags & flag <= 0 then
									roomDesc.DisplayFlags = roomDesc.DisplayFlags | flag
									break
								end
							end
						end
						level:UpdateVisibility()
					end
				end
				if lv >= 2 then
					local room = game:GetRoom()
					local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0,-80), 0, true)
					Isaac.Spawn(1000, 161, 3, pos, Vector.Zero, nil)					
				end
			end
		end
	end		
end
BEden:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Sought1And2')

--寻真3级
function BEden:Sought3()
	if game:IsGreedMode() then return end
	local room = game:GetRoom()
	if not room:IsClear() then return end
	if game:GetRoom():GetType() ~= RoomType.ROOM_BOSS then return end
	if AnyoneSkill('sought', 3) then
		local level = game:GetLevel()
		for i = 0,168 do
			local roomDesc = level:GetRoomByIdx(i)
			if roomDesc then
				roomDesc.DisplayFlags = roomDesc.DisplayFlags | (1<<0) | (1<<1) | (1<<2)
			end
		end
		level:UpdateVisibility()		
	end
end
BEden:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, 'Sought3')

--寻真4级
function BEden:Sought4()
	if game:IsGreedMode() then return end
	if AnyoneSkill('sought', 4) then
		game:GetLevel():RemoveCurses(LevelCurse.CURSE_OF_THE_LOST)
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0,-80), 0, true)
		Isaac.Spawn(5, 300, mod.IBS_PocketID.BEden, pos, Vector.Zero, nil)				
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'Sought4')

--贪婪模式寻真1级
function BEden:Sought_Greed(state)
	if state == 2 and AnyoneSkill('sought', 1) then
		local level = game:GetLevel()
		for i = 0,168 do
			local roomData = level:GetRoomByIdx(i).Data					
			if roomData and roomData.Type == RoomType.ROOM_SUPERSECRET then
				local roomDesc = level:GetRoomByIdx(i)
				local flag = (1<<2)
				if roomDesc and roomDesc.DisplayFlags & flag <= 0 then
					roomDesc.DisplayFlags = roomDesc.DisplayFlags | flag
					break
				end
			end
		end
		level:UpdateVisibility()		
	end
end
BEden:AddCallback(IBS_CallbackID.GREED_WAVE_END_STATE, 'Sought_Greed')

--贪婪模式寻真2级
function BEden:Sought2_Greed()
	if not game:IsGreedMode() then return end
	if AnyoneSkill('sought', 2) then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos() + Vector(0,-80), 0, true)
		Isaac.Spawn(5, 300, mod.IBS_PocketID.BEden, pos, Vector.Zero, nil)				
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'Sought2_Greed')

--御血
function BEden:Hemokinesis(ent, dmg, flag, source)
	if dmg <=0 then return end
	local player = ent:ToPlayer()
	if source.Type == EntityType.ENTITY_SLOT then return end
	if player and player:GetPlayerType() == self.ID and Damage:CanHurtPlayer(player, flag, source) and (flag & DamageFlag.DAMAGE_NO_PENALTIES <= 0) then
		local data = self:GetData(player)
		local lv = data.hemokinesis

		if lv > 0 then
			if player:GetHearts() > 0 then
				local pickup = Isaac.Spawn(5,10,2, player.Position, RandomVector() * 0.5 * math.random(1, 6), nil):ToPickup()
				pickup.Timeout = 50
				pickup.Wait = 10			
			end
			player:AddHearts(-1)
			
			local dmg = data.dmg * 6 if lv >= 4 then dmg = dmg * 1.5 end
			local range = 90 if lv >= 4 then range = range * 1.25 end
			local scale = 1 if lv >= 4 then scale = 1.25 end

			for _,target in pairs(Isaac.FindInRadius(player.Position, range, EntityPartition.ENEMY)) do
				if self._Ents:IsEnemy(target) then				
					target:TakeDamage(dmg, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
					
					if lv >= 2 then
						target:SetBossStatusEffectCooldown(0)
						target:AddBrimstoneMark(EntityRef(player), 321)
						if target:GetBrimstoneMarkCountdown() < 321 then
							target:SetBrimstoneMarkCountdown(321)
						end
					end
					if lv >= 4 then
						target:SetBossStatusEffectCooldown(0)
						target:AddBleeding(EntityRef(player), 321)
						if target:GetBleedingCountdown() < 321 then
							target:SetBleedingCountdown(321)
						end						
					end

					local pickup = Isaac.Spawn(5,10,2, target.Position, RandomVector() * 0.5 * math.random(1, 6), nil):ToPickup()
					pickup.Timeout = 50
					pickup.Wait = 0
				end
			end
			
			for subType = 3,4 do
				local poof = Isaac.Spawn(1000,16, subType, player.Position, Vector.Zero, player)
				poof.SpriteScale = Vector(scale, scale)
			end
			sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0, false, 1.3)
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 200, 'Hemokinesis')

--御血3级
function BEden:Hemokinesis3()
	if AnyoneSkill('hemokinesis', 3) then
		local level = game:GetLevel()
		if level:GetStateFlag(LevelStateFlag.STATE_REDHEART_DAMAGED) then
			level:SetStateFlag(LevelStateFlag.STATE_REDHEART_DAMAGED, false)
		end
	end	
end
BEden:AddCallback(ModCallbacks.MC_POST_RENDER, 'Hemokinesis3')

--御血5级
function BEden:Hemokinesis5(player)
	if Skill(player, 'hemokinesis', 5) and player:IsFrame(300, 0) and player:GetHearts() < math.floor(player:GetEffectiveMaxHearts() / 2) then
		player:AddHearts(1)
	end	
end
BEden:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, 'Hemokinesis5')


--万物一心图标和字体
local allForOneSpr = Sprite('gfx/ibs/ui/players/beden_icons.anm2')
allForOneSpr.Scale = Vector(0.5, 0.5)
allForOneSpr:Play('AllForOne')
allForOneFnt = Font('font/cjk/lanapixel.fnt')

local allForOneAlpha = 0 --不透明度

--展示万物一心提示
function BEden:ShowAllForOneIcon()
	allForOneAlpha = 1
end

--渲染万物一心提示
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
	allForOneSpr.Color = Color(1,1,1,allForOneAlpha)

	if not game:IsPaused() then
		if allForOneAlpha > 0 then
			allForOneAlpha = allForOneAlpha - 0.005
		end
	end

	if allForOneAlpha <= 0 then return end
	if not game:GetHUD():IsVisible() then return end

	for i = 0, game:GetNumPlayers() -1 do
		local player = Isaac.GetPlayer(i)
		local data = BEden._Players:GetData(player).BEDEN
		
		if data and player:GetPlayerType() == BEden.ID then
			if data.all_for_one > 0 then
				local pos = BEden._Screens:WorldToScreen(player.Position, nil, true) + Vector(-14,16)
				local str = tostring(data.allForOneToken)..'/'..tostring(GetAllForOneMaxPoints(data.all_for_one))
				allForOneSpr:Render(pos)
				allForOneFnt:DrawStringScaled(str, pos.X + 12, pos.Y - 8, 1, 1, KColor(1,1,1,allForOneAlpha))
			end			
		end
	end
end, 0)

--尝试通过万物一心增加点数
local function AllForOnePoints(player, num)
	if player:GetPlayerType() == BEden.ID then
		local data = BEden:GetData(player)
		local Max = GetAllForOneMaxPoints(data.all_for_one)

		while data.allForOneToken + num > Max do
			num = num - 1
		end
		
		if num > 0 then
			data.Points = data.Points + num
			data.allForOneToken = data.allForOneToken + num
			BEden:ShowAllForOneIcon()
		end
	end
end

--万物一心1级
function BEden:AllForOne(pill, player, flag)
	if (flag & UseFlag.USE_MIMIC > 0) or (flag & UseFlag.USE_NOANIM > 0) or (flag & UseFlag.USE_NOHUD > 0) then return end
	if player:GetPlayerType() == self.ID then
		local data = self:GetData(player)
		if data.all_for_one > 0 then
			AllForOnePoints(player, 1)
		end
	end
end
BEden:AddCallback(ModCallbacks.MC_USE_PILL, 'AllForOne')

--万物一心2,3,4级
function BEden:AllForOne234(card, player, flag)
	if (flag & UseFlag.USE_MIMIC > 0) or (flag & UseFlag.USE_NOANIM > 0) or (flag & UseFlag.USE_NOHUD > 0) then return end
	if player:GetPlayerType() == self.ID then
		local cardConfig = config:GetCard(card)
		if cardConfig then
			local cardType = cardConfig.CardType
			local data = self:GetData(player)
			local lv = data.all_for_one
	
			if cardType == 0 or cardType == 1 or cardType == 3 or cardType == 5 then
				if lv >= 2 then
					AllForOnePoints(player, 2)
				end
			elseif cardType == 2 then
				if lv >= 3 then
					AllForOnePoints(player, 4)
				end	
			else
				if lv >= 4 then
					AllForOnePoints(player, 5)
				end				
			end
		end
	end
end
BEden:AddCallback(ModCallbacks.MC_USE_CARD, 'AllForOne234')

--新层重置万物一心点数获取累积
function BEden:AllForOne_Reset()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			BEden:GetData(player).allForOneToken = 0
		end
	end	
end
BEden:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, 'AllForOne_Reset')


--精炼混沌
function BEden:DistilledChaos(ent, dmg)
	if dmg <=0 then return end
	if not self._Ents:IsEnemy(ent) then return end

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == self.ID then
			local data = self:GetData(player)
			local lv = data.distilled_chaos
			
			if lv > 0 then
				data.distilledChaosToken = data.distilledChaosToken + 1
				local poison = false
				local burn = false
				local slow = false
				local bleed = false
				local weak = false
				local die = false
				
				if data.distilledChaosToken == 12 then
					if lv == 1 then
						data.distilledChaosToken = 0
					end
					poison = true
				end
				if data.distilledChaosToken == 24 then
					if lv == 2 then
						data.distilledChaosToken = 0
					end
					burn = true
				end
				if data.distilledChaosToken == 48 then
					if lv == 3 then
						data.distilledChaosToken = 0
					end
					slow = true
				end
				if data.distilledChaosToken == 60 then
					if lv == 4 then
						data.distilledChaosToken = 0
					end
					bleed = true
				end
				if data.distilledChaosToken == 96 then
					if lv == 5 then
						data.distilledChaosToken = 0
					end
					weak = true
				end
				if data.distilledChaosToken == 128 then
					if lv >= 6 then
						data.distilledChaosToken = 0
					end
					die = true
				end

				for _,target in pairs(Isaac.FindInRadius(player.Position, 300, EntityPartition.ENEMY)) do
					if self._Ents:IsEnemy(target) then
						if poison then
							target:SetBossStatusEffectCooldown(0)
							if target:GetPoisonCountdown() < 180 then
								target:AddPoison(EntityRef(player), 180, 6)
								target:SetPoisonCountdown(180)
							end										
							local fart = Isaac.Spawn(1000,34, 0, target.Position, Vector.Zero, nil):ToEffect()
							fart.DepthOffset = 10
						end
						if burn then
							target:SetBossStatusEffectCooldown(0)
							if target:GetBurnCountdown() < 180 then
								target:AddBurn(EntityRef(player), 180, 6)
								target:SetBurnCountdown(180)			
							end						
							local flame = Isaac.Spawn(1000,52, 0, target.Position, Vector.Zero, nil):ToEffect()
							flame.Timeout = 20
							flame.DepthOffset = 10
							sfx:Play(43)
						end
						if slow then
							target:SetBossStatusEffectCooldown(0)
							if target:GetSlowingCountdown() < 180 then
								target:AddSlowing(EntityRef(player), 180, 0.6, Color.Default)							
							end
							local fart = Isaac.Spawn(1000,34, 0, target.Position, Vector.Zero, nil):ToEffect()
							local fartColor = Color(1,1,1,1)
							fartColor:SetColorize(1,1,1,1)
							fart.Color = fartColor
							fart.DepthOffset = 10
						end
						if bleed then
							target:SetBossStatusEffectCooldown(0)
							if target:GetBleedingCountdown() < 300 then
								target:AddBleeding(EntityRef(player), 300)
								target:SetBleedingCountdown(300)
							end
							sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0, false, 1.3)
						end
						if weak then
							if target:GetWeaknessCountdown() < 180 then
								target:AddWeakness(EntityRef(nil), 180)					
								target:SetWeaknessCountdown(180)
							end						
							target:SetBossStatusEffectCooldown(0)
						end
						if die then
							if target:IsBoss() then
								target.HitPoints = target.HitPoints * 0.9
							else
								target:Die()
							end
							local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, target.Position, Vector.Zero, nil)
							poof.Color = Color(0,0,0,1)
							sfx:Play(SoundEffect.SOUND_BLACK_POOF)
							game:ShakeScreen(25)
						end
					end
				end				
			end
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 666, 'DistilledChaos')


--他山之石7级(贪婪模式也生效)
function BEden:ForeignInfluence7(wave)
	local room = game:GetRoom()
	if room:GetType() ~= RoomType.ROOM_BOSS then return end
	if not room:IsFirstVisit() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if Skill(player, 'foreign_influence', 7) then
			player:UseCard(94, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
			player:UseCard(96, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		end
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, 200, 'ForeignInfluence7')

--贪婪模式他山之石7级
function BEden:ForeignInfluence7_Greed(wave)
	if wave ~= game:GetGreedBossWaveNum() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if Skill(player, 'foreign_influence', 7) then
			player:UseCard(94, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
			player:UseCard(96, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		end
	end
end
BEden:AddPriorityCallback(IBS_CallbackID.GREED_NEW_WAVE, 200, 'ForeignInfluence7_Greed')


--星盘1级
function BEden:Astrolabe()
	if game:IsGreedMode() then return end
	if AnyoneSkill('astrolabe', 1) then
		return false
	end
end
BEden:AddCallback(ModCallbacks.MC_PRE_PLANETARIUM_APPLY_TREASURE_PENALTY, 'Astrolabe')

--星盘4级
function BEden:Astrolabe4(chance)
	if game:IsGreedMode() then return end
	if AnyoneSkill('astrolabe', 4) then	
		return chance + 1
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_PLANETARIUM_CALCULATE, 700, 'Astrolabe4')

--贪婪模式星盘2级
function BEden:Astrolabe2_Greed(roomSlot, roomData, seed)
	if game:IsGreedMode() and AnyoneSkill('astrolabe', 2) then
		--白宝箱房变星象房
		if roomSlot:Column() == 7 and roomSlot:Row() == 7 then
			local newData = self._Levels:CreateRoomData{
				Seed = seed,
				Type = RoomType.ROOM_PLANETARIUM,
				Shape = roomSlot:Shape(),
				Doors = roomSlot:DoorMask()
			}
			
			if newData then
				return newData
			end
		end
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, -500, 'Astrolabe2_Greed')


--贪婪滋生
function BEden:GrowingGreed(variant, subType, shopItemID, price)
	if price <= 0 then return end
	local newPrice = price

	--1级 
	if variant == 100 and subType ~= 0 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if Skill(player, 'growing_greed', 1) then
				newPrice = newPrice - 1
			end
		end
	end	
	
	--2级
	if variant ~= 100 or subType ~= 0 then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if Skill(player, 'growing_greed', 2) then
				newPrice = newPrice - 1
			end
		end
	end

	--0元购
	if newPrice <= 0 then newPrice = -1000 end

	if newPrice ~= price then
		return newPrice
	end
end
BEden:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, 'GrowingGreed')


--立地升天
function BEden:ReachSky(player, flag)
	if flag & CacheFlag.CACHE_FLYING > 0 and Skill(player, 'reach_sky', 1) then
		player.CanFly = true
	end
end
BEden:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, 'ReachSky')

--立地升天装扮
function BEden:ReachSky_Costume(player)
	if player:GetPlayerType() ~= self.ID then return end
	local data = self:GetData(player)
	if data.reach_sky <= 0 then return end
	local effect = player:GetEffects()
	local id = 179 --宿命(天使翅膀)

	if (not game:IsGreedMode()) and data.my_path <= 0 and data.another_path > 0 then
		id = 82 --深渊领主(恶魔翅膀)
	end

	if not effect:HasCollectibleEffect(id) then
		effect:AddCollectibleEffect(id, true)
	end	
end
BEden:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 'ReachSky_Costume')


--巩固
function BEden:Entrench(player, dmg, flag, source)
	if player:GetPlayerType() ~= self.ID then return end
	local data = self:GetData(player)
	local lv = data.entrench

	if lv >= 1 and source.Type == 1000 and (source.Variant >= 22 and source.Variant <= 26) then
		return false
	end
	if lv >= 2 and (flag & DamageFlag.DAMAGE_CURSED_DOOR > 0 or flag & DamageFlag.DAMAGE_CHEST > 0 or (flag & DamageFlag.DAMAGE_SPIKES > 0 and flag & DamageFlag.DAMAGE_NO_PENALTIES <= 0)) then
		return false
	end
	if lv >= 3 and (flag & DamageFlag.DAMAGE_EXPLOSION > 0 or flag & DamageFlag.DAMAGE_CRUSH > 0) then
		return false
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -9999, 'Entrench')


--乞丐列表
local BeggerList = {
	4, --普通乞丐
	9, --炸弹乞丐
	13, --电池乞丐
	18, --腐烂乞丐
}

--记录作恶(乞丐死亡,进入恶魔房)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	if game:GetLevel():GetStateFlag(LevelStateFlag.STATE_BUM_KILLED) then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == BEden.ID then
				BEden:GetData(player).evil = true
			end
		end	
	end
end)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	if game:GetRoom():GetType() == RoomType.ROOM_DEVIL then
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			if player:GetPlayerType() == BEden.ID then
				BEden:GetData(player).evil = true
			end
		end
	end
end, 6)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			data.lastLevelEvil = data.evil
			data.evil = false
		end
	end
end, 6)

--所谓正道2级
function BEden:ThePath2()
	if game:IsGreedMode() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			if data.the_path >= 2 and not data.lastLevelEvil then
				data.Points = data.Points + 21
				sfx:Play(IBS_Sound.AngelBonus)
			end
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'ThePath2')

--所谓正道3级
function BEden:ThePath3()
	if game:IsGreedMode() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			if data.the_path >= 3 and not data.lastLevelEvil then
				player:AddCard(51)
				player:AddSoulHearts(2)
				sfx:Play(IBS_Sound.AngelBonus)
			end
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'ThePath3')

--所谓正道4级
function BEden:ThePath4()
	if game:IsGreedMode() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			if data.the_path >= 4 and not data.lastLevelEvil then
				local level = game:GetLevel()
				level:RemoveCurses(level:GetCurses())
				sfx:Play(IBS_Sound.AngelBonus)
				break
			end
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 700, 'ThePath4')

--所谓正道5级
function BEden:ThePath5()
	if game:IsGreedMode() then return end
	if AnyoneSkill('the_path', 5) then
		game:GetLevel():AddAngelRoomChance(1)
	end	
	if game:GetLevel():GetStage() < 7 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			if data.the_path >= 5 and not data.lastLevelEvil then
				local room = game:GetRoom()
				local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
				Isaac.Spawn(5, 300, 31, pos, Vector.Zero, nil)
			end
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'ThePath5')

--所谓正道5级,修改房率
function BEden:ThePath5_2(chance)
	if game:IsGreedMode() then return end
	if AnyoneSkill('the_path', 5) then
		return chance + 1
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_DEVIL_CALCULATE, 200, 'ThePath5_2')


--贪婪模式所谓正道2级
function BEden:ThePath2_Greed()
	if not game:IsGreedMode() then return end
	if AnyoneSkill('the_path', 2) then
		game:GetLevel():AddAngelRoomChance(1)
	end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			if data.the_path >= 2 and not data.lastLevelEvil then
				data.Points = data.Points + 21
				sfx:Play(IBS_Sound.AngelBonus)
			end
		end
	end		
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'ThePath2_Greed')

--贪婪模式所谓正道3级
function BEden:ThePath3_Greed()
	if not game:IsGreedMode() then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			if data.the_path >= 3 and not data.lastLevelEvil then
				local level = game:GetLevel()
				level:RemoveCurses(level:GetCurses())
				player:AddCard(51)
				player:AddSoulHearts(2)				
				sfx:Play(IBS_Sound.AngelBonus)
			end
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 700, 'ThePath3_Greed')

--贪婪模式所谓正道4级
function BEden:ThePath4_Greed()
	if not game:IsGreedMode() then return end
	if game:GetLevel():GetStage() < 7 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			if data.the_path >= 4 and not data.lastLevelEvil then
				local room = game:GetRoom()
				local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
				Isaac.Spawn(5, 300, 31, pos, Vector.Zero, nil)			
			end
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'ThePath4_Greed')


--自动激活我行我素
function BEden:MyPath()
	if game:IsGreedMode() then return end
	if game:GetLevel():GetStage() < 3 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			if data.my_path <= 0 and data.the_path <= 0 and data.another_path <= 0 then
				data.my_path = 1
			end
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'MyPath')

--贪婪模式自动激活我行我素
function BEden:MyPath_Greed()
	if not game:IsGreedMode() then return end
	if game:GetLevel():GetStage() < 2 then return end
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			if data.my_path <= 0 and data.the_path <= 0 and data.another_path <= 0 then
				data.my_path = 1
			end
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'MyPath_Greed')

--贪婪模式我行我素刷新属性
function BEden:MyPath_Greed_2()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if Skill(player, 'my_path', 4) then
			player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
		end
	end	
end
BEden:AddPriorityCallback(IBS_CallbackID.GREED_WAVE_CHANGE, 200, 'MyPath_Greed_2')


--行歧路者3级(包括贪婪模式)
function BEden:AnotherPath3()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:GetPlayerType() == BEden.ID then
			local data = BEden:GetData(player)
			if data.another_path >= 3 then
				data.Points = data.Points + 6
				player:AddCoins(13)
				sfx:Play(IBS_Sound.DevilBonus, 0.9)
			end
		end
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'AnotherPath3')

--行歧路者5级
function BEden:AnotherPath5()
	if game:IsGreedMode() then return end
	if AnyoneSkill('another_path', 5) then
		local level = game:GetLevel()
		level:RemoveCurses(level:GetCurses())	
		level:AddCurse(LevelCurse.CURSE_OF_DARKNESS, false)
		sfx:Play(IBS_Sound.DevilBonus, 0.9)
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 666, 'AnotherPath5')

--行歧路者6级
function BEden:AnotherPath6()
	if game:IsGreedMode() then return end
	if game:GetLevel():GetStage() < 7 then return end
	if AnyoneSkill('another_path', 6) then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		Isaac.Spawn(5, 300, 31, pos, Vector.Zero, nil)
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'AnotherPath6')

--行歧路者6级,修改房率
function BEden:AnotherPath6_2(chance)
	if game:IsGreedMode() then return end
	if AnyoneSkill('another_path', 6) then
		return chance + 1
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_DEVIL_CALCULATE, 200, 'AnotherPath6_2')


--贪婪模式行歧路者4级
function BEden:AnotherPath4_Greed()
	if not game:IsGreedMode() then return end
	if AnyoneSkill('another_path', 4) then
		local level = game:GetLevel()
		level:RemoveCurses(level:GetCurses())	
		level:AddCurse(LevelCurse.CURSE_OF_DARKNESS, true)
		sfx:Play(IBS_Sound.DevilBonus, 0.9)
	end
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 666, 'AnotherPath4_Greed')

--贪婪模式行歧路者5级
function BEden:ThePath5_Greed()
	if not game:IsGreedMode() then return end
	if game:GetLevel():GetStage() < 7 then return end
	if AnyoneSkill('another_path', 5) then
		local room = game:GetRoom()
		local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true)
		Isaac.Spawn(5, 300, 31, pos, Vector.Zero, nil)
	end	
end
BEden:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, 200, 'ThePath5_Greed')



return BEden