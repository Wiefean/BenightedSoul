--可互动实体Class

--[[

"info_tbl"包含内容
{
	Variant, --实体类
	Name = {zh = '中文名', en = '英文名'}, --名称(表)
}

]]

local mod = Isaac_BenightedSoul

local Entity = mod.IBS_Class.Entity

local Slot = mod.Class(Entity, function(self, info_tbl)
	info_tbl = info_tbl or {}
	info_tbl.Type = EntityType.ENTITY_SLOT
	info_tbl.SubType = 0

	Entity._ctor(self, info_tbl)

end, { {expectedType = 'table'} })




return Slot
