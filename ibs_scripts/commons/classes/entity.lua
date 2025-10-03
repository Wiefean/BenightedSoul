--实体Class

--[[

"info_tbl"包含内容
{
	Type, --实体大类
	Variant, --实体类
	SubType, --实体小类
	Name = {zh = '中文名', en = '英文名'}, --名称(表)
}

]]

local mod = Isaac_BenightedSoul

local Component = mod.IBS_Class.Component

local Entity = mod.Class(Component, function(self, info_tbl)
	Component._ctor(self)
	
	self.Type = info_tbl.Type
	self.Variant = info_tbl.Variant
	self.SubType = info_tbl.SubType
	self.Name = info_tbl.Name or {}
	self.Info = info_tbl or {}

end, { {expectedType = 'table'} })


return Entity
