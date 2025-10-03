--规则书

local mod = Isaac_BenightedSoul

local game = Game()

local RulesBook = mod.IBS_Class.Item(mod.IBS_ItemID.RulesBook)


--列表
RulesBook.List = {
	zh = {
		{'胖蛆讨厌烟味'},
		{'纸会指引你'},
		{'超时后墙壁会变坚固', '时间很重要'},
		{'你的脚下有一个黑市'},
		{'有的门需要祝福才能打开', '带上祝福去开启它'},
		{'拒绝他的礼物才能获得奖励'},
		{'沉睡的守门人需要大声才能叫醒'},
		{'墙壁可能比你想象的更容易投降', '尝试是关键'},
	},

	en = {
		{'CHUB DISLIKES SMOKE!'},
		{'A PIECE OF PAPER IS YOUR GUIDE'},
		{'THE WALLS WILL HARDEN OVER TIME', 'TIME IS THE ESSENCE'},
		{'A DARK MARKET LIES UNDER YOUR FEET'},
		{'SOME DOORS REQUIRE A BLESSING', 'CARRY IT WITH YOU'},
		{'DENY HIS GIFTS TO ATTAIN YOUR REWARD'},
		{'SLEEPING GATEKEEPERS WILL NEED TO BE', 'AWOKEN WITH A LOUD SOUND'},
		{'ROOMS MAY YIELD MORE THAN YOU EXPECT', 'EXPERIMENTATION IS KEY'},
	},

	--彩蛋种子
	{'BASE', 'MENT'},
	{'KEEP', 'AWAY'},
	{'FREE', '2PAY'},
	{'PAC1', 'F1SM'},
	{'C0ME', 'BACK'},
	{'BRWN', 'SNKE'},
	{'D0NT', 'STOP'},
	{'THEG', 'H0ST'},
	{'DRAW', 'KCAB'},
	{'1MN0', 'B0DY'},
	{'TEAR', 'GL0W'},
	{'BL00', '00DY'},
	{'MED1', 'C1NE'},
	{'FACE', 'D0WN'},
	{'CHAM', 'P10N'},
	{'C0CK', 'FGHT'},
	{'C0NF', 'ETT1'},
	{'FEAR', 'M1NT'},
	{'FRA1', 'DN0T'},
	{'CLST', 'RPH0'},
}

--纸类饰品列表
RulesBook.PaperTrinket = {
	13, --商店积分
	21, --神秘纸片
	23, --寻人启示
	48, --遗失的书页
	69, --褪色全家福
	141, --失落摇篮曲
	145, --满分试卷
	169, --儿童涂鸦
	171, --店主协议
	184, --领养协议
}


--生成奖励
function RulesBook:SpawnBonus(rng, player, pos)
	pos = pos or game:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true)
	local level = game:GetLevel()
	local hud = game:GetHUD()
	local int = rng:RandomInt(1, #self.List)


	if int >= 1 and int <= 8 then
		local text = self:ChooseLanguageInTable(self.List)[int]
		hud:ShowFortuneText(text[1], text[2])

		if int == 1 or int == 7 then --炸弹
			Isaac.Spawn(5, 40, 0, pos, Vector.Zero, nil)
		elseif int == 2 then --纸
			local paper = self.PaperTrinket
			Isaac.Spawn(5, 350, paper[rng:RandomInt(1,#paper)] or 21, pos, Vector.Zero, nil)
		elseif int == 3 then --游戏计时减少10分钟
			game.TimeCounter = math.max(30, game.TimeCounter - 18000)
		elseif int == 4 then --生成血量代价商店道具
			local id = game:GetItemPool():GetCollectible(ItemPoolType.POOL_SHOP, true, self._Levels:GetRoomUniqueSeed())
			local item = Isaac.Spawn(5, 100, id, pos, Vector(0,0), nil):ToPickup()
			item.ShopItemId = -2
			item.Price = -1
		elseif int == 5 then --保释卡
			Isaac.Spawn(5, 300, 47, pos, Vector.Zero, nil)
		elseif int == 6 then --15%天使房转换率
			level:AddAngelRoomChance(0.15)
		elseif int == 8 then --触发X光透视效果
			level:SetCanSeeEverything(true)
		end
	else
		local text = self.List[int]
		hud:ShowFortuneText(text[1], text[2])

		--硬币
		Isaac.Spawn(5, 20, 0, pos, Vector.Zero, nil)
		pos = game:GetRoom():FindFreePickupSpawnPosition(pos, 0, true)
	end
end

--使用
function RulesBook:OnUse(item, rng, player)
	self:SpawnBonus(rng, player)
	return true
end
RulesBook:AddCallback(ModCallbacks.MC_USE_ITEM, 'OnUse', RulesBook.ID)



return RulesBook
