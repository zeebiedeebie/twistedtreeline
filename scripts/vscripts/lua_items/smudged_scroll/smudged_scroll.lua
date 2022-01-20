LinkLuaModifier("modifier_item_smudged_scroll", "lua_items/smudged_scroll/smudged_scroll", LUA_MODIFIER_MOTION_NONE)
if item_smudged_scroll == nil then item_smudged_scroll = class({}) end

function item_smudged_scroll:GetIntrinsicModifierName()
  return  "modifier_item_smudged_scroll"
end

function item_smudged_scroll:OnSpellStart()
  local caster = self:GetCaster()
  self:RandomEffect()
end

function item_smudged_scroll:RandomEffect()
    local iRand = RandomInt(1,4)

    self:GetCaster():ModifyGold(iRand, false, DOTA_ModifyGold_AbilityGold)
    SendOverheadEventMessage(self:GetCaster():GetPlayerOwner(), OVERHEAD_ALERT_GOLD, self:GetCaster(), iRand, self:GetCaster():GetPlayerOwner())

    if iRand == 1 then self:RandomBlink()
    elseif iRand == 2  then self:RandomHeal()
    elseif iRand == 3 then self:RandomRunes()
    elseif iRand == 4 then self:SpawnUnits()
    end
end

function item_smudged_scroll:RandomBlink()
  local caster = self:GetCaster()
  local vRand = RandomVector(RandomInt(1,1200)) --hardcoded blink distance
  local newPos = caster:GetAbsOrigin() + vRand

  --Blink
  FindClearSpaceForUnit(caster, newPos, true)
  --Particle Effect
  local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_chen/chen_teleport_flash_trails.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
  ParticleManager:SetParticleControlForward(pfx, 0, self:GetCaster():GetAbsOrigin())
  ParticleManager:ReleaseParticleIndex(pfx)
end

function item_smudged_scroll:RandomHeal()
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
