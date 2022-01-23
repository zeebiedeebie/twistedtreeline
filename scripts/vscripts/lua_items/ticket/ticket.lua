LinkLuaModifier("modifier_item_ticket", "lua_items/ticket/ticket", LUA_MODIFIER_MOTION_NONE)
item_ticket = class({})

function item_ticket:GetIntrinsicModifierName()
  return "modifier_item_ticket"
end

function item_ticket:OnSpellStart()
  local relay = Entities:FindByName(nil, "relay_minecart_ticket")
  relay:Trigger(self:GetCaster(),self:GetCaster())
  EmitSoundOn("DOTA_Item.Butterfly", self:GetCaster())
end

modifier_item_ticket = class({})
function modifier_item_ticket:IsHidden() return true end
function modifier_item_ticket:IsPurgable() return false end
function modifier_item_ticket:RemoveOnDeath() return false end
function modifier_item_ticket:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_ticket:DeclareFunctions()
  funcs = {
    MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    MODIFIR_PROPERTY_RESPAWNTIME,
    MODIFIER_PROPERTY_DEATHGOLDCOST
  }
  return funcs
end

function modifier_item_ticket:GetModifierTurnRate_Percentage()
  return self:GetAbility():GetSpecialValueFor("turn_rate_percentage")
end

function modifier_item_ticket:GetModifierConstantRespawnTime()
  return self:GetAbility():GetSpecialValueFor("respawn_time")
end

function modifier_item_ticket:GetModifierConstantDeathGoldCost()
  return self:GetAbility():GetSpecialValueFor("death_cost")
end
