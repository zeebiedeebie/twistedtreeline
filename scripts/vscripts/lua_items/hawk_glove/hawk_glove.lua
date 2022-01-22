LinkLuaModifier("modifier_item_hawk_glove","lua_items/hawk_glove/hawk_glove", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_hawk_glove_tree","lua_items/hawk_glove/hawk_glove", LUA_MODIFIER_MOTION_NONE)
if item_hawk_glove == nil then item_hawk_glove = class({}) end

function item_hawk_glove:GetIntrinsicModifierName()
  return "modifier_item_hawk_glove"
end

function item_hawk_glove:OnSpellStart()
  CreateModifierThinker(
    self:GetCaster(),
    self,
    "item_hawk_glove_tree",
    {duration = self:GetDuration()},
    self:GetCursorPosition(),
    self:GetCaster():GetTeamNumber(),
    true)
end

--Tree Modifier
if item_hawk_glove_tree == nil then item_hawk_glove_tree = class({}) end

function item_hawk_glove_tree:GetEffectName()

  --return "particles/great_particle/great_particle.vpcf"
  return "particles/items_fx/ironwood_tree.vpcf"
  --return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_stunned_bird.vpcf"
end

function item_hawk_glove_tree:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

function item_hawk_glove_tree:OnCreated(kv)
  if IsServer() then
    self:StartIntervalThink(0.1)

    EmitSoundOn("DOTA_Item.HealingSalve.Activate", self:GetParent())

    local pfx = ParticleManager:CreateParticleForTeam(
      "particles/best_particle/best_particle.vpcf",--"particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_dc.vpcf",
      PATTACH_ABSORIGIN,
      self:GetParent(),
      self:GetCaster():GetTeam()
    )

    ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pfx)
  end
end

function item_hawk_glove_tree:OnIntervalThink()
  if IsServer() then
    if not GridNav:IsNearbyTree(self:GetParent():GetAbsOrigin(), 10, false) then
      self:Destroy()
    end
    local FOWViewer = AddFOWViewer(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("vision_radius"), 0.1, false)
  end
end

function item_hawk_glove_tree:Heal()
  EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "DOTA_Item.FaerieSpark.Activate", self:GetCaster())
  local allies = FindUnitsInRadius(
    self:GetCaster():GetTeam(),
    self:GetParent():GetAbsOrigin(),
    nil,
    self:GetAbility():GetSpecialValueFor("vision_radius"),
    DOTA_UNIT_TARGET_TEAM_FRIENDLY,
    DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_CLOSEST,
    false
  )

  for _, ally in pairs(allies) do
    ally:Heal(self:GetAbility():GetSpecialValueFor("heal"), self:GetAbility())
    SendOverheadEventMessage(ally:GetPlayerOwner(), OVERHEAD_ALERT_HEAL, ally, self:GetAbility():GetSpecialValueFor("heal"), self:GetCaster():GetPlayerOwner())
  end
end

function item_hawk_glove_tree:OnDestroy()
  if IsServer() then
    self:Heal()
    UTIL_Remove(self:GetParent())
  end
end

--Hawk Glove modifier
modifier_item_hawk_glove = class({})

function modifier_item_hawk_glove:IsHidden() return true end

function modifier_item_hawk_glove:DeclareFunctions()
  funcs = {
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
  }
  return funcs
end

function modifier_item_hawk_glove:GetModifierAttackSpeedBonus_Constant()
  return self:GetAbility():GetSpecialValueFor("attack_speed")
end
