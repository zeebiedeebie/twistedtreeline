LinkLuaModifier("modifier_item_cigar", "lua_items/cigar/cigar", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_cigar_puff", "lua_items/cigar/cigar", LUA_MODIFIER_MOTION_NONE)

item_cigar = item_cigar or class({})

function item_cigar:GetIntrinsicModifierName()
  return "modifier_item_cigar"
end

function item_cigar:Spawn()
  self:SetCurrentCharges(self:GetSpecialValueFor("charges"))
end

function item_cigar:OnSpellStart()
  if not IsServer() then return end
  if self:GetCurrentCharges() == 0 then return end

  caster = self:GetCaster()

  local heal = self:GetSpecialValueFor("heal")
  local mana = self:GetSpecialValueFor("mana")
  local fDuration = self:GetSpecialValueFor("duration")

  caster:AddNewModifier(caster, self, "modifier_item_cigar_puff", {duration = fDuration})

  caster:Heal(heal, self)
  SendOverheadEventMessage(player, OVERHEAD_ALERT_HEAL, caster, heal, player)
  caster:GiveMana(mana)
  SendOverheadEventMessage(player, OVERHEAD_ALERT_MANA_ADD, caster, mana, player)

  local puffsRemaining = self:GetCurrentCharges() - 1
  self:SetCurrentCharges(puffsRemaining)

  --Permanent cloud of smoke on player head per puff. Might get funny / bad performance. Fix someday.
  --self:PlayEffect()
end

function item_cigar:PlayEffect()
  local particle_cast = "particles/econ/courier/courier_frull_ambient/courier_frull_ambient_pot_smoke.vpcf"
  local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

  ParticleManager:SetParticleControlEnt(
                  effect_cast,
                  0,
                  self:GetCaster(),
                  PATTACH_POINT_FOLLOW,
                  "attach_hitloc",
                  Vector(0,0,100),
                  true
                )
  --ParticleManager:DestroyParticle(effect_cast, true)
  ParticleManager:ReleaseParticleIndex(effect_cast)
end

modifier_item_cigar = modifier_item_cigar or class({})

function modifier_item_cigar:IsHidden() return true end
function modifier_item_cigar:IsPurgable() return false end
function modifier_item_cigar:RemoveOnDeath() return false end
function modifier_item_cigar:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_cigar:DeclareFunctions()
  funcs = {
    MODIFIER_EVENT_ON_HERO_KILLED,
    MODIFIER_PROPERTY_STATUS_RESISTANCE,
  }
  return funcs
end

function modifier_item_cigar:OnHeroKilled(params)
  if params.attacker == self:GetParent() then return end
  self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + self:GetAbility():GetSpecialValueFor("charges_per_kill"))
end

function modifier_item_cigar:GetModifierStatusResistance()
  return self:GetAbility():GetSpecialValueFor("status_resistance")
end


modifier_item_cigar_puff = class({})

function modifier_item_cigar_puff:IsHidden() return false end
function modifier_item_cigar_puff:IsPurgable() return true end
function modifier_item_cigar_puff:RemoveOnDeath() return true end
function modifier_item_cigar_puff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- function modifier_item_cigar_puff:GetEffectAttachType()
--   return PATTACH_ABSORIGIN_FOLLOW
-- end
--
-- function modifier_item_cigar_puff:GetEffectName()
--   return "particles/econ/courier/courier_frull_ambient/courier_frull_ambient_pot_smoke.vpcf"
-- end


function modifier_item_cigar_puff:DeclareFunctions()
  funcs = {
    MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK_SPECIAL,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
  }
  return funcs
end

function modifier_item_cigar_puff:GetModifierPhysical_ConstantBlockSpecial()
  return self:GetAbility():GetSpecialValueFor("block")
end

function modifier_item_cigar_puff:GetModifierMoveSpeedBonus_Percentage()
  return self:GetAbility():GetSpecialValueFor("percent_movespeed")
end
