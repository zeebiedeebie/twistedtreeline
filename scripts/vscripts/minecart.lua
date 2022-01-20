LinkLuaModifier("modifier_minecart_knockback", "minecart", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_minecart_ride", "minecart", LUA_MODIFIER_MOTION_HORIZONTAL)

minecart = class({})
  minecart.ent = Entities:FindByName(nil,"minecart_mover") --or Entities:FindByName(nil,"minecart")

function hit(trigger)

  local ent = trigger.activator

  if ent == nil then return end

  if not ent:HasItemInInventory("item_ticket") then
    local damage = minecart.ent:GetVelocity():Length()
    local iDuration = damage / 333

    --Apply Knockback
    ent:AddNewModifier(nil, nil, "modifier_minecart_knockback", {duration = iDuration})

    --Apply Damage
    local damageInfo = CreateDamageInfo(minecart.ent, minecart.ent, minecart.ent:GetAbsOrigin(), minecart.ent:GetAbsOrigin(), damage, DAMAGE_TYPE_PHYSICAL)
    ent:TakeDamage(damageInfo)

    DestroyDamageInfo(damageInfo)
  else
    ent:AddNewModifier(nil,nil, "modifier_minecart_ride", {duration = 5})
  end
end

function disembark(trigger)
  local ent = trigger.activator
  ent:RemoveModifierByName("modifier_minecart_ride")
end

modifier_minecart_knockback = class({})

  modifier_minecart_knockback.hitDir = nil


function modifier_minecart_knockback:IsHidden() return false end
function modifier_minecart_knockback:IsDebuff() return true end
function modifier_minecart_knockback:IsStunDebuff() return true end

function modifier_minecart_knockback:OnCreated(kv)
  if IsServer() then
    self.hitDir = minecart.ent:GetVelocity():Normalized()
    if self:ApplyHorizontalMotionController() == false then
      self:Destroy()
    end
  end
end

function modifier_minecart_knockback:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    MODIFIER_EVENT_ON_DEATH,
  }
  return funcs
end

function modifier_minecart_knockback:GetOverrideAnimation(params)
  return ACT_DOTA_FLAIL
end

function modifier_minecart_knockback:CheckState()
  local state = {
    [MODIFIER_STATE_STUNNED] = true,
  }
  return state
end

function modifier_minecart_knockback:UpdateHorizontalMotion(me, dt)
    me:SetOrigin( me:GetLocalOrigin() + (self.hitDir * 20) )
    GridNav:DestroyTreesAroundPoint(me:GetAbsOrigin(), 100, true)
end

function modifier_minecart_knockback:OnDeath(kv)
  if not kv.inflictor == self then return end
  print("Minecart knockback got a kill!")
  local strSpeed = "0"

  --DoEntFireByInstanceHandle(minecart.ent, string string_2,string string_3,float float_4,handle handle_5,handle handle_6)
  --Maybe just have an entity in the map to trigger()
end

modifier_minecart_ride = class({})

function modifier_minecart_ride:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
  }
  return funcs
end

function modifier_minecart_ride:GetOverrideAnimation(params)
  return ACT_DOTA_FLAIL
end

function modifier_minecart_ride:OnCreated(kv)
  if IsServer() then
    if self:ApplyHorizontalMotionController() == false then
      self:Destroy()
    end
  end
end

function modifier_minecart_ride:UpdateHorizontalMotion(me, dt)
    me:SetOrigin(minecart.ent:GetAbsOrigin())
end
