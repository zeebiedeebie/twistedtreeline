--Tooltip for this should be extensive, but feature garbled text that obscures the function of some effects.
LinkLuaModifier("modifier_item_smudged_scroll", "lua_items/smudged_scroll/smudged_scroll", LUA_MODIFIER_MOTION_NONE)
if item_smudged_scroll == nil then item_smudged_scroll = class({}) end

local prev = -1

function item_smudged_scroll:GetIntrinsicModifierName()
  return  "modifier_item_smudged_scroll"
end

function item_smudged_scroll:OnSpellStart()
  self:RandomEffect()
end

function item_smudged_scroll:NovelRandomInt(min, max, prev)
  --base case prevents crash
  if min == max then return min end

  local iRand = RandomInt(min,max)
  if prev ~= iRand then return iRand
  else return self:NovelRandomInt(min, max, prev)
  end
end

function item_smudged_scroll:RandomEffect()
    local iRand = self:NovelRandomInt(1,6, prev)

    self:GetCaster():ModifyGold(iRand, false, DOTA_ModifyGold_AbilityGold)
    SendOverheadEventMessage(self:GetCaster():GetPlayerOwner(), OVERHEAD_ALERT_GOLD, self:GetCaster(), iRand, self:GetCaster():GetPlayerOwner())

    if iRand == 1 then self:RandomBlink()
    elseif iRand == 2  then self:RandomHeal()
    elseif iRand == 3 then self:RandomRunes()
    elseif iRand == 4 then self:SpawnUnits()
    elseif iRand == 5 then self:Thunderstorm()
    elseif iRand == 6 then self:AreaAttack()
    elseif iRand == 0 then self:RandomEffect()
    end

    prev = iRand
end

function item_smudged_scroll:RandomBlink()
  --Teleports the caster to a random point within the radius
  local caster = self:GetCaster()
  local vRand = RandomVector(RandomInt(1,1200)) --hardcoded blink distance
  local newPos = caster:GetAbsOrigin() + vRand

  --Particle Effect
  local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_teleport_flash_trails.vpcf", PATTACH_POINT_FOLLOW, caster)
  ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
  ParticleManager:ReleaseParticleIndex(pfx)

  local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_teleport_flash_trails.vpcf", PATTACH_POINT_FOLLOW, caster)
  ParticleManager:SetParticleControlEnt(pfx2, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), false )
  ParticleManager:ReleaseParticleIndex(pfx2)
  --sfx
  EmitSoundOn("Hero_Antimage.Blink_in", caster)

  --Blink
  FindClearSpaceForUnit(caster, newPos, true)

  --post-blink sfx
  EmitSoundOn("Hero_Antimage.Blink_out", caster)
end

function item_smudged_scroll:RandomHeal()
  --Heals the caster for a random amount
  local caster = self:GetCaster()
  local player = caster:GetPlayerOwner()
  local iRand = RandomInt(1,1000) --Hardcoded max heal value

  --Heal and Effects
  caster:Heal(iRand, self)
  SendOverheadEventMessage(player, OVERHEAD_ALERT_HEAL, caster, iRand, player)
  self:EmitSound("DOTA_Item.MagicWand.Activate")
end

function item_smudged_scroll:RandomRunes()
  --Creates a random rune for each hero within the search radius.
  local caster = self:GetCaster()
  local searchRadius = 1200 --Hardcoded search radius
  local heroes = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, caster:GetAbsOrigin(), nil, searchRadius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, true)
  for i, hero in pairs(heroes) do
    CreateRune(hero:GetAbsOrigin() + hero:GetForwardVector() * 100, RandomInt(0,7))
  end
end

function item_smudged_scroll:SpawnUnits()
  --Creates a bunch of units in front of the caster.
  local caster = self:GetCaster()
  local units = {
    "npc_dota_neutral_kobold",
    "npc_dota_neutral_ghost",
    "npc_dota_neutral_wildkin",
  }

  for i = 2, 6 do
    local randUnit = RandomInt(1, 3) --2nd arg must be length of units table (how to do this in lua?)
    local str = ""
    str = units[randUnit]
    CreateUnitByName(str, caster:GetAbsOrigin() + caster:GetForwardVector() * 100, true, nil, nil, DOTA_TEAM_NEUTRALS)
  end
end

function item_smudged_scroll:Thunderstorm()
  --Hit all units in radius with a damaging lightning bolt
  local victims = FindUnitsInRadius(
    self:GetCaster():GetTeamNumber(),
    self:GetCaster():GetAbsOrigin(),
    nil,
    1200,
    DOTA_UNIT_TARGET_TEAM_BOTH,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_COURIER,
    DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES,
    FIND_ANY_ORDER,
    false
  )

  for k,victim in pairs(victims) do
    --Play vfx
    local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(pfx, 1, victim, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), false)
    ParticleManager:ReleaseParticleIndex(pfx)

    --Play sound
    EmitSoundOn("Hero_Zuus.LightningBolt", victim)

    --Destroy Trees
    GridNav:DestroyTreesAroundPoint(victim:GetAbsOrigin(), 250, true)

    --Deal damage
    ApplyDamage({
      victim = victim,
      attacker = self:GetCaster(),
      damage = 250,
      damage_type = DAMAGE_TYPE_MAGICAL,
      DOTA_DAMAGE_FLAG_NONE,
      ability = self,
    })
  end
end

function item_smudged_scroll:AreaAttack()
  --Attack all enemies in a radius
  local victims = FindUnitsInRadius(
    self:GetCaster():GetTeamNumber(),
    self:GetCaster():GetAbsOrigin(),
    nil,
    1200,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_COURIER,
    DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
    FIND_ANY_ORDER,
    false
  )
  for k,victim in pairs(victims) do
    self:GetCaster():PerformAttack(victim, true, true, true, true, true, false, true)
  end
end

modifier_item_smudged_scroll = class({})
function modifier_item_smudged_scroll:IsHidden() return true end
