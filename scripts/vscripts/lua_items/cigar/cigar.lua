LinkLuaModifier("modifier_item_cigar", "lua_items/cigar/cigar", LUA_MODIFIER_MOTION_NONE)

item_cigar = item_cigar or class({})
local puffsRemaining = 100

function item_cigar:GetIntrinsicModifierName()
  self:SetCurrentCharges(puffsRemaining)
  return "modifier_item_cigar"
end

function item_cigar:OnSpellStart()
  if not IsServer() then return end
  caster = self:GetCaster()

  local heal = self:GetSpecialValueFor("heal")
  local mana = self:GetSpecialValueFor("mana")

  if puffsRemaining == 0 then

    return
  end

  caster:Heal(heal, self)
  SendOverheadEventMessage(player, OVERHEAD_ALERT_HEAL, caster, heal, player)
  caster:GiveMana(mana)
  SendOverheadEventMessage(player, OVERHEAD_ALERT_MANA_ADD, caster, mana, player)
  puffsRemaining = puffsRemaining - 1
  self:SetCurrentCharges(puffsRemaining)
end

modifier_item_cigar = modifier_item_cigar or class({})

function modifier_item_cigar:IsHidden() return true end
function modifier_item_cigar:IsPurgable() return false end
function modifier_item_cigar:RemoveOnDeath() return false end
function modifier_item_cigar:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_cigar:DeclareFunctions()
  funcs = {
    MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
  }
end
function modifier_item_cigar:GetModifierPercentageCooldown()
  return 50
end
