LinkLuaModifier("modifier_item_stinger","lua_items/stinger/stinger", LUA_MODIFIER_MOTION_NONE)

item_stinger =  item_stinger or class({})

local charges = 0

function item_stinger:GetIntrinsicModifierName()
  return "modifier_item_stinger"
end

function item_stinger:Sting(caster, source, target)
  local damage = self:GetSpecialValueFor("base_damage") + charges * self:GetSpecialValueFor("charge_damage")
  --Draw Particle
  local pfx = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf", PATTACH_POINT_FOLLOW, caster)
  ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
  ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
  ParticleManager:SetParticleControl(pfx, 2, Vector(damage, 0, 0))
  ParticleManager:SetParticleControl(pfx, 3, Vector(0.3, 0, 0))
  ParticleManager:ReleaseParticleIndex(pfx)

  if target:IsAlive() then
    ApplyDamage({
      victim = target,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_MAGICAL,
      DOTA_DAMAGE_FLAG_NONE,
      ability = self,
    })
  end

  if not target:IsAlive() then
    charges = charges + 1
    self:SetCurrentCharges(charges)
    caster:EmitSound("DOTA_Item.Hand_Of_Midas")
  end
end

function item_stinger:OnSpellStart()
  if not IsServer() then return end

  local caster = self:GetCaster()
  local target = self:GetCursorTarget()

  if target:GetTeam() ~= caster:GetTeam() then
    if target:TriggerSpellAbsorb(self) then
      return nil
    end
  end

  if target:IsMagicImmune() then
    return nil
  end

  --Play Sound
  caster:EmitSound("DOTA_Item.Dagon.Activate")
  target:EmitSound("DOTA_Item.Dagon1.Target")
  target:EmitSound("DOTA_Item.Dagon"..self:GetLevel()..".Target")

  print("Zap!!!")
  self:Sting(caster, self, target)
end

modifier_item_stinger = modifier_item_stinger or class({})

function modifier_item_stinger:IsHidden() return true end
function modifier_item_stinger:IsPurgable() return false end
function modifier_item_stinger:RemoveOnDeath() return false end
function modifier_item_stinger:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_stinger:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
  }
  return funcs
end

function modifier_item_stinger:GetModifierBonusStats_Strength()
  return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_stinger:GetModifierBonusStats_Agility()
  return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_stinger:GetModifierBonusStats_Intellect()
  return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end
