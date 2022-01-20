local bag = 0
local longest = 0

--Might be dangerous/annoying
--DOTA_SpawnMapAtPosition("submaps/randomroom"..RandomInt(0,2), Vector(0,0,0), false, nil, nil, nil)

function pressurePadOpen(trigger)
  local ent = trigger.activator
  if not ent then return end

  --Spawn random map if first time triggered
  --if not mapSpawned then spawnMap() end

  --Map Entity References
  local padOpen = Entities:FindByName(nil,"pressurePadRelayOpen")
  local hiddenDoorOpen = Entities:FindByName(nil, "hiddenDoorRelayOpen")

  --Press down pad and open hidden door
  padOpen:Trigger(ent, padOpen)
  hiddenDoorOpen:Trigger(ent, hiddenDoorOpen)

  local timer = Timers:CreateTimer("pressurePadTimer", {
    callback = function()
      print("Pad Timer Go")
      bag = bag + 1
      --ent:AngerNearbyUnits()
      return .25
    end
})
end

function pressurePadClose(trigger)
  local ent = trigger.activator
  if not ent then return end

  --Map Entity References
  local padClose = Entities:FindByName(nil, "pressurePadRelayClose")
  local hiddenDoorClose = Entities:FindByName(nil, "hiddenDoorRelayClose")

  --pad comes up and closes hidden door
  padClose:Trigger(ent, padClose)
  hiddenDoorClose:Trigger(ent, hiddenDoorClose)

  --Remove Map
  --if mapSpawned then removeMap() end

  --Check duration
  Timers:RemoveTimer("pressurePadTimer")

  --Update longest
  if bag > longest then
    longest = bag
    print("===== new longest time of :", bag / 4, " sec ====== ")
  end
  bag = 0
end
