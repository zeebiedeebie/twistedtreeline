LinkLuaModifier("modifier_boss_count_deaths", "hiddenTreasure", LUA_MODIFIER_MOTION_NONE)
timesBossKilled = 0
itemsTable = {"item_aegis","item_aghanims_shard_roshan"}

function hiddenTreasureSpawn(trigger)
  local ent = trigger.activator
  local pos = Entities:FindByName(nil, "treasureSpawn"):GetAbsOrigin()
  local target = Entities:FindByName(nil, "treasureTarget"):GetAbsOrigin()

  local unitOptions = {
    MapUnitName = "npc_dota_roshan",
    teamnumber =  DOTA_TEAM_NEUTRALS,
    modelscale = 1.001,
    angles = "0 270 0"
  }

  local unit = CreateUnitFromTable(unitOptions, pos)
  aegis = unit:AddItemByName("item_aegis")

  if timesBossKilled > 0 then unit:AddItemByName("item_aghanims_shard_roshan") end

  unit:AddNewModifier(unit, nil, "modifier_boss_count_deaths", nil)
end

function spawnClayPot(trigger)
  pos = Entities:FindByName(nil, "potSpawn"):GetAbsOrigin()
  local unitOptions = {
    MapUnitName = "npc_dota_creature_clay_pot",
    teamnumber =  DOTA_TEAM_NEUTRALS,
    modelscale = 1,
    angles = "0 0 0"
  }

  local unit = CreateUnitFromTable(unitOptions, pos)
end

function pedestalTrigger(trigger)
  local relay = Entities:FindByName(nil, "relay_pedestal_effects")
  hero = trigger.activator
  if hero:HasItemInInventory("item_aegis") then
    hero:TakeItem(hero:FindItemInInventory("item_aegis"))
    relay:Trigger(hero, self)
    AddFOWViewer(hero:GetTeam(), relay:GetAbsOrigin(), 100, 300.0, false)
    hiddenTreasureSpawn(trigger)
  end
end

function CreateAndLaunchLoot(unit, killer)
  local target = Entities:FindByName(nil, "treasureTarget"):GetAbsOrigin()

  local focus = CreateItem("item_divine_focus", nil, nil)

  physfocus = CreateItemOnPositionForLaunch(unit:GetAbsOrigin(), focus)

  vRand = RandomVector(512)
  RandScale = RandomFloat(0,1)
  RandDuration = RandomFloat(2, 6)
  RandHeight = RandomInt(512,1024)

  RandPos = target + vRand * RandScale

  focus:LaunchLoot(false, RandHeight, RandDuration, RandPos)

  AddFOWViewer(killer:GetTeam(), RandPos, 100, RandDuration, false)

  timesBossKilled = timesBossKilled + 1
end

modifier_boss_count_deaths = modifier_boss_count_deaths or class({})

function modifier_boss_count_deaths:IsHidden() return false end
function modifier_boss_count_deaths:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_boss_count_deaths:DeclareFunctions()
  funcs = {
    MODIFIER_EVENT_ON_DEATH
  }
  return funcs
end

function modifier_boss_count_deaths:OnDeath(params)
  if params.unit == self:GetParent() then
    params.unit:TakeItem(focusVis)
    CreateAndLaunchLoot(params.unit, params.attacker)
  end
end
