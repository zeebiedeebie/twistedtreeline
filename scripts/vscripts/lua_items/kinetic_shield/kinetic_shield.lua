LinkLuaModifier("modifier_item_kinetic_shield", "lua_items/kinetic_shield/kinetic_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_kinetic_shield_ethereal", "lua_items/kinetic_shield/kinetic_shield", LUA_MODIFIER_MOTION_NONE)


if item_kinetic_shield == nil then
  item_kinetic_shield = class({})
end

function item_kinetic_shield:GetIntrinsicModifierName()
  return "modifier_item_kinetic_shield"
end

function item_kinetic_shield:OnSpellStart()
  local caster = self:GetCaster()
end

function item_kinetic_shield:Repel()
  self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_kinetic_shield_ethereal", {duration = 5})
  self:GetCaster():EmitSound("DOTA_Item.EtherealBlade.Target")
end

modifier_item_kinetic_shield = class({})
function modifier_item_kinetic_shield:IsHidden() return false end
function modifier_item_kinetic_shield:IsPurgable() return false end
function modifier_item_kinetic_shield:RemoveOnDeath() return false end
function modifier_item_kinetic_shield:IsBuff() return true end
function modifier_item_kinetic_shield:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_kinetic_shield:DeclareFunctions()
  funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_EVENT_ON_ATTACKED
  }
  return funcs
end


function modifier_item_kinetic_shield:OnTakeDamage(keys)
  if not IsServer() then return end

  if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and keys.attacker:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
    if not keys.unit:IsOther() then

      --Play Sound for Attacker
      EmitSoundOnClient("DOTA_Item.BladeMail.Damage", keys.attacker:GetPlayerOwner())

      --Increment Modifier Stacks
      local damage = keys.original_damage
      damage = damage + self:GetCaster():GetModifierStackCount("modifier_item_kinetic_shield", self:GetCaster())
      self:GetCaster():SetModifierStackCount("modifier_item_kinetic_shield", self:GetCaster(), damage)
    end
  end
end

function modifier_item_kinetic_shield:OnAttacked(keys)

  if not IsServer() then return end

  if keys.target == self:GetCaster() then
    if self:GetCaster():GetModifierStackCount("modifier_item_kinetic_shield", self:GetCaster()) > 50 then
      self:GetAbility():Repel()
      self:GetCaster():SetModifierStackCount("modifier_item_kinetic_shield", self:GetCaster(), 0)
    end
  end
end

function modifier_item_kinetic_shield:GetModifierMoveSpeedBonus_Constant()
  return self:GetAbility():GetSpecialValueFor("bonus_move_speed")
end

--Ethereal Modifier
modifier_item_kinetic_shield_ethereal = class({})

function modifier_item_kinetic_shield_ethereal:IsHidden() return false end
function modifier_item_kinetic_shield_ethereal:IsPurgable() return true end
function modifier_item_kinetic_shield_ethereal:RemoveOnDeath() return true end
function modifier_item_kinetic_shield_ethereal:IsBuff() return true end
function modifier_item_kinetic_shield_ethereal:DeclareFunctions()
  funcs = {
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
    MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
  }
  return funcs
end

function modifier_item_kinetic_shield_ethereal:GetModifierMagicalResistanceDecrepifyUnique()
  return 50
end

function modifier_item_kinetic_shield_ethereal:GetAbsoluteNoDamagePhysical()
  return 1
end

function modifier_item_kinetic_shield_ethereal:CheckState()
  local state = {
    [MODIFIER_STATE_ATTACK_IMMUNE] = true,
    [MODIFIER_STATE_DISARMED] = true,
  }
  return state
end

function modifier_item_kinetic_shield_ethereal:GetStatusEffectName()
  return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_item_kinetic_shield_ethereal:OnCreated()
  if IsServer() then
    if not self:GetAbility() then self:Destroy() end
  end
end
