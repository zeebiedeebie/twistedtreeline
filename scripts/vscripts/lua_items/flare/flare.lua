LinkLuaModifier("modifier_item_flare", "lua_items/flare/flare", LUA_MODIFIER_MOTION_NONE)

item_flare = class({})

function item_flare:GetIntrinsicModifierName()
 return "modifier_item_flare"
end
