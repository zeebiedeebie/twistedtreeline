
LinkLuaModifier("modifier_item_tree_wall", "lua_items/tree_wall/tree_wall", LUA_MODIFIER_MOTION_NONE)
item_tree_wall = item_tree_wall or class({})
local currentCharges = 1

function item_tree_wall:GetIntrinsicModifierName()
  self:SetCurrentCharges(currentCharges)
  return "modifier_item_tree_wall"
end

function item_tree_wall:OnSpellStart()
  if not IsServer() then return end
  caster = self:GetCaster()
  local team = caster:GetTeam()
  local treeModel = "models/props_tree/palm_02b_inspector.vmdl"
  if team == DOTA_TEAM_GOODGUYS
  then treeModel = "models/props_tree/tree_oak_00.vmdl"--"models/heroes/snapfire/debut/assets/desert_props/deserttree2.vmdl"
  elseif team == DOTA_TEAM_BADGUYS
    then treeModel = "models/heroes/snapfire/debut/assets/desert_props/deserttree1.vmdl"
  end

  local maxTrees = self:GetSpecialValueFor("max_trees")
  item_tree_wall:treeGon(self:GetCaster(),currentCharges,maxTrees,treeModel)

  self:SetCurrentCharges(currentCharges)
end

function item_tree_wall:treeGon(caster,charges,maxTrees,treeModel)
  local angle = 2 * math.pi / charges
  local radius = 200 + 25 * charges
  local vPos = caster:GetAbsOrigin()
  local team = caster:GetTeam()

  GridNav:DestroyTreesAroundPoint(vPos, 500.0, true)

  for i = 1, charges do
    local duration = RandomFloat(1,15)
    local direction = Vector(math.cos(angle * i), math.sin(angle * i))
    local circlePoint = direction * radius

    if(team == DOTA_TEAM_GOODGUYS) then
      CreateTempTreeWithModel(vPos + circlePoint, duration, treeModel)
    elseif(team == DOTA_TEAM_BADGUYS) then
      CreateTempTreeWithModel(vPos - circlePoint, duration, treeModel)
    else
      CreateTempTreeWithModel(vPos + circlePoint, duration, treeModel)
    end
  end

  if charges < maxTrees then currentCharges = currentCharges + 1 end

  --Unblock
  local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, vPos, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, true)
  for i, unittable in pairs(units) do
    FindClearSpaceForUnit(unittable, unittable:GetAbsOrigin(),true)
    for i, unit in pairs(unittable) do
      print(i, "---", unit)
    end
  end
end

--INTRINSIC MODIFIER
modifier_item_tree_wall = class({})
function modifier_item_tree_wall:IsHidden()      return true end
function modifier_item_tree_wall:IsPurgable()     return false end
function modifier_item_tree_wall:RemoveOnDeath()  return false end
function modifier_item_tree_wall:GetAttributes()  return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_item_tree_wall:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
    return funcs
end

function modifier_item_tree_wall:GetModifierBonusStats_Strength()
  return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_tree_wall:GetModifierBonusStats_Agility()
    return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_tree_wall:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end
