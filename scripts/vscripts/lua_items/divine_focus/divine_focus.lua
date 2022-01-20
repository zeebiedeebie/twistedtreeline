LinkLuaModifier("modifier_item_divine_focus", "lua_items/divine_focus/divine_focus", LUA_MODIFIER_MOTION_NONE)

item_divine_focus = item_divine_focus or class({})

function item_divine_focus:IsPermanent() return true end
function item_divine_focus:CanOnlyPlayerHeroPickup() return true end
function item_divine_focus:IsSellable() return false end

function item_divine_focus:GetIntrinsicModifierName()
  return "modifier_item_divine_focus"
end

function item_divine_focus:OnOwnerDied(params)

  local hOwner = self:GetOwner()

  if not hOwner:IsRealHero() then
    hOwner:DropItemAtPositionImmediate(self, hOwner:GetAbsOrigin())
    return
  end

  if not hOwner:IsReincarnating() then
    hOwner:DropItemAtPositionImmediate(self, hOwner:GetAbsOrigin())
  end
end

modifier_item_divine_focus =  modifier_item_divine_focus or class({})

function modifier_item_divine_focus:IsHidden() return true end
function modifier_item_divine_focus:IsPurgable() return false end
function modifier_item_divine_focus:RemoveOnDeath() return false end
function modifier_item_divine_focus:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_divine_focus:DeclareFunctions()
  funcs = {
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
  }
  return funcs
end

function modifier_item_divine_focus:SpellAmp()
  return self:GetAbility():GetSpecialValueFor("spell_amp")
end

function modifier_item_divine_focus:GetModifierSpellAmplify_Percentage()
  return self:GetAbility():GetSpecialValueFor("spell_amp")
end
