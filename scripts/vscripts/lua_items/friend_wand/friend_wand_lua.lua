LinkLuaModifier("modifier_item_friend_wand","lua_items/friend_wand/friend_wand_lua",LUA_MODIFIER_MOTION_NONE)

item_friend_wand_lua = class({})

function item_friend_wand_lua:GetIntrinsicModifierName()
  return "modifier_item_friend_wand"
end

function item_friend_wand_lua:OnSpellStart()
  caster = self:GetCaster()
  caster:EmitSound("DOTA_Item.Necronomicon.Activate")
  caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
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
function modifier_item_friend_wand:IsHidden()       return false end
function modifier_item_friend_wand:IsPurgable()     return false end
function modifier_item_friend_wand:RemoveOnDeath()  return false end
function modifier_item_friend_wand:IsBuff()         return true end
function modifier_item_friend_wand:IsAura()         return true end
function modifier_item_friend_wand:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_friend_wand:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
  }
  return funcs
end

function modifier_item_friend_wand:GetAuraRadius()
  return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_friend_wand:GetModifierConstantHealthRegen()
  return self:GetAbility():GetSpecialValueFor("health_regen")
end
