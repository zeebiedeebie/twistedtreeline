LinkLuaModifier("modifier_item_grenade_cache", "lua_items/grenade_cache/grenade_cache",  LUA_MODIFIER_MOTION_NONE)
item_grenade_cache = class({})

function item_grenade_cache:GetIntrinsicModifierName()
  return "modifier_item_grenade_cache"
end

function item_grenade_cache_OnSpellStart()
end

function item_grenade_cache:OnChannelFinish(bInterrupted)
  if not bInterrupted then
    local casterPos = self:GetCaster():GetAbsOrigin()
    local cursorPos = self:GetCaster():GetCursorPosition()
    local item = CreateItem("item_grenade_flashbang", self:GetCaster(), self:GetCaster())
    local physItem = CreateItemOnPositionForLaunch(casterPos, item)
    item:LaunchLoot(false, 250, .5, cursorPos + RandomVector(100))
  end
end

modifier_item_grenade_cache = class({})

function modifier_item_grenade_cache:IsHidden() return true end
function modifier_item_grenade_cache:IsPurgable() return false end
function modifier_item_grenade_cache:RemoveOnDeath() return false end
function modifier_item_grenade_cache:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_grenade_cache:DeclareFunctions()
  funcs = {

  }
  return funcs
end

--Grenades generated by item

item_grenade_flashbang = class({})

function item_grenade_flashbang:OnSpellStart()
  self:ThrowGrenade()
end

function item_grenade_flashbang:ThrowGrenade()
  --local effectname = "particles/units/heroes/hero_sniper/sniper_shard_concussive_grenade_model.vpcf"
  local caster = self:GetCaster()
  local options = {
    Ability = self,
    --EffectName = effectname,
    vSpawnOrigin = caster:GetAbsOrigin(),
    fDistance = (self:GetCursorPosition() - self:GetAbsOrigin()):Length(),
    fStartRadius = 64,
    fEndRadius = 64,
    Source = caster,
    bHasFrontalCone = false,
    bReplaceExisting = false,
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
    iUnitTargetType = DOTA_UNIT_TARGET_BASIC,
    fExpireTime = GameRules:GetGameTime() + 1.7,
    bDeleteOnHit = false,
    vVelocity = caster:GetForwardVector() * 1200,
    bProvidesVision = true,
    iVisionRadius = 10,
    iVisionTeamNumber = caster:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(options)
    self:PlayGrenadeVisual(projectile)
end

function item_grenade_flashbang:PlayGrenadeVisual(projectile)

  pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_shard_concussive_grenade_model.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
  ParticleManager:SetParticleControlEnt(pfx, 0, self:GetCaster(), PATTACH_POINT, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
  ParticleManager:SetParticleControl(pfx, 1, ProjectileManager:GetLinearProjectileLocation(projectile))
  ParticleManager:SetParticleControl(pfx, 3, ProjectileManager:GetLinearProjectileVelocity(projectile))
  ParticleManager:SetParticleControl(pfx, 5, self:GetCursorPosition())


  --ParticleManager:SetParticleControl(pfx, 4, self:GetCursorPosition())
  --ParticleManager:DestroyParticle(pfx, false)
  ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_item_grenade_flashbang = class({})
function modifier_item_grenade_flashbang:IsHidden() return true end
function modifier_item_grenade_flashbang:IsPurgable() return false end
function modifier_item_grenade_flashbang:RemoveOnDeath() return false end
function modifier_item_grenade_flashbang:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_grenade_flashbang:DeclareFunctions()
  funcs = {

  }
  return funcs
end

modifier_item_grenade_flashbang_flash = class({})
function modifier_item_grenade_flashbang_flash:IsHidden() return false end
function modifier_item_grenade_flashbang_flash:IsPurgable() return true end
function modifier_item_grenade_flashbang_flash:RemoveOnDeath() return false end
--Leaving out getattributes here beacuse I don't think I need it

function modifier_item_grenade_flashbang_flash:DeclareFunctions()
  funcs = {

  }
  return funcs
end
