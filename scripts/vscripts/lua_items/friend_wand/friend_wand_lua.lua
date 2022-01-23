LinkLuaModifier("modifier_item_friend_wand","lua_items/friend_wand/friend_wand_lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_friend_wand_aura","lua_items/friend_wand/friend_wand_lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_friend_wand_aura_buff","lua_items/friend_wand/friend_wand_lua",LUA_MODIFIER_MOTION_NONE)

item_friend_wand_lua = class({})

function item_friend_wand_lua:GetIntrinsicModifierName()
  return "modifier_item_friend_wand"
end

function item_friend_wand_lua:OnSpellStart()
  caster = self:GetCaster()
  caster:EmitSound("DOTA_Item.Necronomicon.Activate")
  caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)

  -- local friends = FindUnitsInRadius(
  --   self:GetCaster():GetTeamNumber(),
  --   self:GetCaster():GetAbsOrigin(),
  --   nil,
  --   self:GetSpecialValueFor("aura_radius"),
  --   DOTA_UNIT_TARGET_TEAM_FRIENDLY,
  --   DOTA_UNIT_TARGET_CREEP,
  --   DOTA_UNIT_TARGET_FLAG_NONE,
  --   FIND_ANY_ORDER,
  --   false
  -- )
  -- DeepPrintTable(friends)
end

function item_friend_wand_lua:OnChannelFinish(interrupted)
  if not IsServer() then return end
  --parameters
  if not interrupted
    then
    	local summon_duration = self:GetSpecialValueFor("summon_duration")
    	local caster = self:GetCaster()
    	local caster_loc = caster:GetAbsOrigin()
    	local caster_direction = caster:GetForwardVector()
    	local summon_name = "npc_dota_creature_vhoul_buddy"
    	local summon_loc = caster:GetAbsOrigin() --RotatePosition(caster_loc, QAngle(0,0,0), caster_loc + caster_direction * 180)
    	local summon = CreateUnitByName(summon_name, summon_loc, true, caster, caster, caster:GetTeam())
    	summon:SetControllableByPlayer(caster:GetPlayerID(), true)
    	summon:AddNewModifier(caster, self, "modifier_kill", {duration = summon_duration})
      local pfx = ParticleManager:CreateParticle("particles/econ/events/ti9/shovel_dig_rocks.vpcf", PATTACH_WORLDORIGIN, caster)
      ParticleManager:SetParticleControl(pfx, 0, summon:GetAbsOrigin())
      ParticleManager:ReleaseParticleIndex(pfx)
      EmitSoundOn("SeasonalConsumable.TI9.Shovel.Dig", summon);
      caster:RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)

    end
end

--INTRINSIC MODIFIER
modifier_item_friend_wand = class({})
function modifier_item_friend_wand:IsHidden() return true end
function modifier_item_friend_wand:IsPurgable() return false end
function modifier_item_friend_wand:RemoveOnDeath()  return false end
function modifier_item_friend_wand:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_friend_wand:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
  }
  return funcs
end


function modifier_item_friend_wand:GetModifierConstantHealthRegen()
  return self:GetAbility():GetSpecialValueFor("health_regen")
end

function modifier_item_friend_wand:OnCreated()
  if IsServer() then
    if not self:GetAbility() then self:Destroy()
     end
   end

  if IsServer() then
    self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_friend_wand_aura", {})
  end

  self:StartIntervalThink(0.25)

end

function modifier_item_friend_wand:OnDestroy()
  if IsServer() then
    if self:GetCaster():HasModifier("modifier_item_friend_wand_aura") then
        self:GetCaster():RemoveModifierByName("modifier_item_friend_wand_aura")
      end
    end
end

function modifier_item_friend_wand:OnIntervalThink()
  local friends = FindUnitsInRadius(
    self:GetParent():GetTeamNumber(),
    self:GetParent():GetAbsOrigin(),
    nil,
    self:GetAbility():GetSpecialValueFor("aura_radius"),
    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
    DOTA_UNIT_TARGET_CREEP,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false
  )

  for i, friend in pairs(friends) do
    print(i)
    print ("--")
    print(friend)
    friend:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_friend_wand_aura_buff",{duration = 0.25})
  end
end

--Actual Aura
modifier_item_friend_wand_aura = class({})
function modifier_item_friend_wand_aura:IsHidden() return false end
function modifier_item_friend_wand_aura:IsBuff() return true end

function modifier_item_friend_wand_aura:DeclareFunctions()
  funcs = {}
  return funcs
end

function modifier_item_friend_wand_aura:IsAura() return true end
function modifier_item_friend_wand_aura:IsAuraActiveOnDeath() return false end
function modifier_item_friend_wand_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_friend_wand_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_item_friend_wand_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ALLY end
function modifier_item_friend_wand_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end
function modifier_item_friend_wand_aura:GetModifierAura() return "modifier_item_friend_wand_aura_buff" end



--Aura Applied buff
modifier_item_friend_wand_aura_buff = class({})
function modifier_item_friend_wand_aura_buff:IsBuff() return true end
function modifier_item_friend_wand_aura_buff:IsHidden() return false end
function modifier_item_friend_wand_aura_buff:IsPurgable() return false end
function modifier_item_friend_wand_aura_buff:RemoveOnDeath() return true end

function modifier_item_friend_wand_aura_buff:OnCreated()
  print("friend wand aura buff created")
end


function modifier_item_friend_wand_aura_buff:DeclareFunctions()
  funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
  }
  return funcs
end
function modifier_item_friend_wand_aura_buff:GetModifierConstantHealthRegen()
  return self:GetAbility():GetSpecialValueFor("aura_health_regen")
end
