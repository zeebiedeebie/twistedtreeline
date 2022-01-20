LinkLuaModifier("modifier_item_rune_dice", "lua_items/rune_dice/rune_dice", LUA_MODIFIER_MOTION_NONE)

rune_dice = class({})

function rune_dice:GetIntrinsicModifierName()
  return "modifier_item_rune_dice"
end

function rune_dice:On
