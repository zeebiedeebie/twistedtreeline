LinkLuaModifier("modifier_item_sacrifice_ring","lua_items/sacrifice_ring/sacrifice_ring", LUA_MODIFIER_MOTION_NONE)
if item_sacrifice_ring == nil then item_sacrifice_ring = class({}) end

function item_sacrifice_ring:GetIntrinsicModifierName()
 return "modifier_item_sacrifice_ring"
end

function item_sacrifice_ring:OnSpellStart()
  local caster = self:GetCaster()
  local target = self:GetCursorTarget()

  local conv_pct = self:GetSpecialValueFor("health_conversion")

  local mana = target:GetHealth() * (conv_pct/100)
  caster:GiveMana(mana)
  target:Kill(self,caster)
  self:PlayEffect(target)
end

function item_sacrifice_ring:PlayEffect(target)
  local particle_cast = "particles/units/heroes/hero_lich/lich_dark_ritual.vpcf"
  local sound_cast = "Ability.DarkRitual"

  local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)

  ParticleManager:SetParticleControlEnt(
                  effect_cast,
                  1,
                  self:GetCaster(),
                  PATTACH_POINT_FOLLOW,
                  "attach_attack1",
                  target:GetAbsOrigin(),
                  true
                )

  ParticleManager:ReleaseParticleIndex(effect_cast)

  EmitSoundOn(sound_cast, target)
end

modifier_item_sacrifice_ring = class({})
function modifier_item_sacrifice_ring:IsHidden() return true end
function modifier_item_sacrifice_ring:IsPurgable() return false end
function modifier_item_sacrifice_ring:RemoveOnDeath() return false end
function modifier_item_sacrifice_ring:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_sacrifice_ring:DeclareFunctions()
  funcs = {
    MODIFIER_PROPERTY_MANA_BONUS,
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
  }
  return funcs
end

function modifier_item_sacrifice_ring:GetModifierManaBonus()
  return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_sacrifice_ring:GetModifierConstantHealthRegen()
  return self:GetAbility():GetSpecialValueFor("hp_regen")
end
