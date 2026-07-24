--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    unit_smart_nanos.lua
--  brief:   Enables auto reclaim & repair for idle turrets
--  author:  Owen Martindell
--
--  Copyright (C) 2008.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Smart Nanos",
		desc      = "Enables auto reclaim & repair for idle turrets v1.5",
		author    = "TheFatController",
		date      = "22 April, 2008",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = false  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local spGetSpectatingState    = Spring.GetSpectatingState
local spIsReplay              = Spring.IsReplay
local spIsCheatingEnabled     = Spring.IsCheatingEnabled
local spGetGameSeconds        = Spring.GetGameSeconds
local spAreTeamsAllied        = Spring.AreTeamsAllied
local spGetMyTeamID           = Spring.GetMyTeamID
local spGetTeamResources      = Spring.GetTeamResources
local spGetUnitDefID          = Spring.GetUnitDefID
local spGetAllUnits           = Spring.GetAllUnits
local spGetUnitHealth         = Spring.GetUnitHealth
local spGetUnitsInCylinder    = Spring.GetUnitsInCylinder
local spGetUnitPosition       = Spring.GetUnitPosition
local spGetUnitCommandCount   = Spring.GetUnitCommandCount
local spGetSelectedUnits      = Spring.GetSelectedUnits
local spGetUnitTeam           = Spring.GetUnitTeam
local spGiveOrderToUnit       = Spring.GiveOrderToUnit
local spGiveOrderToUnitMap    = Spring.GiveOrderToUnitMap
local spGetUnitCurrentCommand = Spring.GetUnitCurrentCommand
local spGetFeatureDefID       = Spring.GetFeatureDefID
local spGetFeatureResources   = Spring.GetFeatureResources
local spGetFeaturesInCylinder = Spring.GetFeaturesInCylinder
local spGetFeaturePosition    = Spring.GetFeaturePosition

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local UPDATE      = 0.5     -- Response time for commands
local NANO_GROUPS = 8  -- Groups to split nanoturrets into
local UPDATE_TICK = 2.5  -- Seconds to check if last order is still the best

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local timeCounter = 0
local order_counter = 0
local pointer = NANO_GROUPS
local nano_pointer = NANO_GROUPS

local teamUnits = {}
local buildUnits = {}
local nanoTurrets = {}
local allyUnits = {}
local orderQueue = {}

local myTeamID

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Initialize()
	myTeamID = spGetMyTeamID()
	
	if (spGetSpectatingState() or spIsReplay()) and (not spIsCheatingEnabled()) then
		Spring.Echo("Smart Nanos widget disabled for spectators")
		widgetHandler:RemoveWidget()
	end
	
	for _,unitID in ipairs(spGetAllUnits()) do
		local unitTeam = spGetUnitTeam(unitID)
		if (unitTeam == myTeamID) or spAreTeamsAllied(unitTeam, myTeamID) then
			local unitDefID = spGetUnitDefID(unitID)
			local _, _, _, _, buildProgress = spGetUnitHealth(unitID)
			if (buildProgress < 1) then
				widget:UnitCreated(unitID, unitDefID, unitTeam)
			else
				widget:UnitFinished(unitID, unitDefID, unitTeam)
			end
		end
	end
	
	UPDATE = (UPDATE / NANO_GROUPS)
end

function widget:UnitCreated(unitID, unitDefID, unitTeam)
	if (unitTeam ~= myTeamID) then
		return
	end
	buildUnits[unitID] = true
end

function widget:UnitFinished(unitID, unitDefID, unitTeam)
	if UnitDefs[unitDefID].customParams.commtype then
		myTeamID = spGetMyTeamID()
	end
	
	if (unitTeam == myTeamID) then
	
		buildUnits[unitID] = nil
		
		teamUnits[unitID] = {}
		teamUnits[unitID].unitDefID = unitDefID
		teamUnits[unitID].damaged = false
		
		if (UnitDefs[unitDefID].isBuilder and not UnitDefs[unitDefID].canMove) then
			nanoTurrets[unitID] = {}
			nanoTurrets[unitID].unitDefID = unitDefID
			nanoTurrets[unitID].buildDistance = UnitDefs[nanoTurrets[unitID].unitDefID].buildDistance
			nanoTurrets[unitID].buildDistanceSqr = (UnitDefs[nanoTurrets[unitID].unitDefID].buildDistance * UnitDefs[nanoTurrets[unitID].unitDefID].buildDistance)
			nanoTurrets[unitID].damaged = false
			local posX,_,posZ = spGetUnitPosition(unitID)
			nanoTurrets[unitID].posX = posX
			nanoTurrets[unitID].posZ = posZ
			nanoTurrets[unitID].timeCounter = spGetGameSeconds()
			nanoTurrets[unitID].auto = false
			nanoTurrets[unitID].pointer = nano_pointer
			if (nano_pointer < NANO_GROUPS) then
				nano_pointer = nano_pointer + 1
			else
				nano_pointer = 1
			end
			teamUnits[unitID] = nil
		end
	elseif spAreTeamsAllied(unitTeam, myTeamID) then
		allyUnits[unitID] = {}
		allyUnits[unitID].unitDefID = unitDefID
		allyUnits[unitID].damaged = false
	end
end

function widget:CommandNotify(id, params, options)
	local selUnits = spGetSelectedUnits()
	
	for _,unitID in ipairs(selUnits) do
		if nanoTurrets[unitID] then
			nanoTurrets[unitID].auto = false
			orderQueue[unitID] = nil
		end
	end
	
	if (id == CMD.RECLAIM) then
		local targetUnit = params[1]
		teamUnits[targetUnit] = nil
		for unitID,unitDefs in pairs(nanoTurrets) do
			local cmdID, _, _, cmdParam = spGetUnitCurrentCommand(unitID)
			if (cmdID == CMD.REPAIR) and (cmdParam == targetUnit) then
				if options.shift then
					spGiveOrderToUnit(unitID,CMD.STOP, 0, 0)
				else
					spGiveOrderToUnit(unitID,CMD.RECLAIM,targetUnit, 0)
				end
			end
		end
	end
	
	if (id == CMD.REPAIR) then
		local targetUnit = params[1]
		if (not teamUnits[targetUnit]) and (not allyUnits[targetUnit]) and (not nanoTurrets[targetUnit])
				and (not buildUnits[targetUnit]) and (spGetUnitTeam(targetUnit) == myTeamID) then
			widget:UnitFinished(targetUnit, spGetUnitDefID(targetUnit), myTeamID)
		end
		for unitID,unitDefs in pairs(nanoTurrets) do
			local cmdID, _, _, cmdParam = spGetUnitCurrentCommand(unitID)
			if (cmdID == CMD.RECLAIM) and (cmdParam == targetUnit) then
				spGiveOrderToUnit(unitID,CMD.REPAIR,{targetUnit}, 0)
			end
		end
	end
end

local function getDistance(x1,z1,x2,z2)
	local dx,dz = x1-x2,z1-z2
	return (dx*dx)+(dz*dz)
end

local function processOrderQueue()
	local newQueue = {}
	for unitID,orders in pairs(orderQueue) do
		if nanoTurrets[unitID] and nanoTurrets[unitID].auto then
			local key = table.concat(orders,"-")
			local map = newQueue[key]
			if not map then
				map = {}
				newQueue[key] = map
			end
			map[unitID] = orders
		else
			orderQueue[unitID] = nil
		end
	end
	for _,unitMap in pairs(newQueue) do
		local anyID = next(unitMap)
		local type, id, params = unitMap[anyID][1], unitMap[anyID][2], unitMap[anyID][3]
		if (type == 1) then
			spGiveOrderToUnitMap(unitMap, CMD.INSERT, {0, id, CMD.OPT_SHIFT, params}, CMD.OPT_ALT)
		else
			spGiveOrderToUnitMap(unitMap, id, {params}, CMD.OPT_SHIFT)
		end
	end
	orderQueue = {}
end

function widget:Update(deltaTime)
	if (spGetMyTeamID() ~= myTeamID) then
		Spring.Echo("Smart Nanos widget disabled for team change")
		widgetHandler:RemoveWidget()
		return false
	end

	if next(nanoTurrets) == nil or timeCounter <= UPDATE then
		-- don't update yet
		return false
	end

	timeCounter = 0

	local eCur, eMax = spGetTeamResources(myTeamID, "energy")
	local mCur, mMax, _, mInc = spGetTeamResources(myTeamID, "metal")
	local ePercent = (eCur / eMax)
	local lowEnergy = eCur < mCur
	local energySurplus = ePercent > 0.9
	local metalSurplus = mInc > (mMax - mCur)

	if next(orderQueue) then
		if (order_counter == NANO_GROUPS) then
			processOrderQueue()
			order_counter = 1
		else
			order_counter = order_counter + 1
		end
	end

	if (pointer == NANO_GROUPS) then
		for unitID,_ in pairs(teamUnits) do
			local curH, maxH = spGetUnitHealth(unitID)
			if curH and maxH then
				teamUnits[unitID].rHealth = curH
				if (curH < maxH) then
					teamUnits[unitID].damaged = true
				else
					teamUnits[unitID].damaged = false
				end
			else
				teamUnits[unitID] = nil
			end
		end
		for unitID,_ in pairs(allyUnits) do
			local curH, maxH = spGetUnitHealth(unitID)
			if curH and maxH then
				allyUnits[unitID].rHealth = curH
				if (curH < maxH) then
					allyUnits[unitID].damaged = true
				else
					allyUnits[unitID].damaged = false
				end
			else
				allyUnits[unitID] = nil
			end
		end
		pointer = 1
	else
		pointer = (pointer + 1)
	end

	for unitID,unitDefs in pairs(nanoTurrets) do
		if (unitDefs.pointer == pointer) then
			local curH, maxH = spGetUnitHealth(unitID)
			if (curH < maxH) then
				nanoTurrets[unitID].damaged = true
			else
				nanoTurrets[unitID].damaged = false
			end
			
			local prevCommand, _, _, prevUnit = spGetUnitCurrentCommand(unitID)
			local cQueueCount = spGetUnitCommandCount(unitID)

			local commandMe = false

			if (cQueueCount == 0) then
				commandMe = true
				nanoTurrets[unitID].auto = false
			else
				if (prevCommand == CMD.PATROL) and (cQueueCount <= 4) then
					commandMe = true
					nanoTurrets[unitID].auto = false
				end

				if nanoTurrets[unitID].auto then
					if (prevCommand == CMD.RECLAIM) then
						if prevUnit < Game.maxUnits then
							local targetDefID = spGetUnitDefID(prevUnit)
							if (targetDefID ~= nil) and UnitDefs[targetDefID].canMove then
								local uX, _, uZ = spGetUnitPosition(prevUnit)
								if (getDistance(unitDefs.posX, unitDefs.posZ, uX, uZ) > unitDefs.buildDistanceSqr) then
									commandMe = true
								end
							end
						end
					end
					if (prevCommand == CMD.REPAIR) then
						local targetDefID = spGetUnitDefID(prevUnit)
						if (targetDefID ~= nil) and UnitDefs[targetDefID].canMove then
							local uX, _, uZ = spGetUnitPosition(prevUnit)
							if (getDistance(unitDefs.posX, unitDefs.posZ, uX, uZ) > unitDefs.buildDistanceSqr) then
								commandMe = true
							end
						end
					end

					if ((unitDefs.timeCounter + UPDATE_TICK) < spGetGameSeconds()) then
						commandMe = true
					end
				end
			end

			if (commandMe) then
				unitDefs.timeCounter = spGetGameSeconds()

				local ordered = false

				local nearUnits = spGetUnitsInCylinder(unitDefs.posX, unitDefs.posZ, unitDefs.buildDistance)

				if (nearUnits ~= nil) then
					for _,nearUnitID in pairs(nearUnits) do
						if nanoTurrets[nearUnitID] and nanoTurrets[nearUnitID].damaged and (unitID ~= nearUnitID) then
							if (prevCommand ~= CMD.REPAIR) or (prevUnit ~= bestUnit) then
								orderQueue[unitID] = {1, CMD.REPAIR, nearUnitID}
							end
							ordered = true
							break
						end
					end

					if (not ordered) then
						local bestUnit = nil
						local bestStat = math.huge
						local nextUnit = nil
						for _,nearUnitID in pairs(nearUnits) do
							if (teamUnits[nearUnitID] and teamUnits[nearUnitID].damaged) then
								if (nextUnit == nil) then nextUnit = nearUnitID end
									if (#UnitDefs[spGetUnitDefID(nearUnitID)].weapons > 0) then
										if (teamUnits[nearUnitID].rHealth < bestStat) then
										bestUnit = nearUnitID
										bestStat = teamUnits[nearUnitID].rHealth
									end
								end
							end
						end

						if (bestUnit ~= nil) and (not ordered) then
							if (prevCommand ~= CMD.REPAIR) or (prevUnit ~= bestUnit) then
								orderQueue[unitID] = {1, CMD.REPAIR, bestUnit}
							end
							ordered = true
						elseif (nextUnit ~= nil) and (not ordered) then
							if (prevCommand ~= CMD.REPAIR) or (prevUnit ~= nextUnit) then
								orderQueue[unitID] = {1, CMD.REPAIR, nextUnit}
							end
							ordered = true
						end
					end

					if (not ordered) or ((not energySurplus) and (not metalSurplus)) then
						-- check features
						-- take features outside of buildDistance but who's edge is inside of buildDistance
						local nearFeatures = spGetFeaturesInCylinder(unitDefs.posX, unitDefs.posZ, unitDefs.buildDistance+75)
						for i = #nearFeatures, 1, -1 do
							local fX, _, fZ = spGetFeaturePosition(featureID)
							local fd = spGetFeatureDefID(featureID)
							local radiusSqr = (FeatureDefs[fd].radius * FeatureDefs[fd].radius)
							if not FeatureDefs[fd].reclaimable or not (getDistance(unitDefs.posX, unitDefs.posZ, fX, fZ) < (unitDefs.buildDistanceSqr + radiusSqr)) then
								table.remove(nearFeatures, i)
							end
						end
						-- identify best feature
						local bestFeature = nil
						local metal = false
						for _,featureID in ipairs(nearFeatures) do
							local fm,_,fe  = spGetFeatureResources(featureID)
							if metalSurplus and fm > 0 then
							elseif energySurplus and fm == 0 and fe > 0 then
							elseif lowEnergy and fm < fe then
							else -- feature satisfies "best" clause
								bestFeature = featureID
								metal = fm > 0
							end
						end

						if not metal then
							local bestUnit = nil
							local bestStat = math.huge
							for _,nearUnitID in pairs(nearUnits) do
								if (allyUnits[nearUnitID] and allyUnits[nearUnitID].damaged) then
									if (#UnitDefs[spGetUnitDefID(nearUnitID)].weapons > 0) then
										if (allyUnits[nearUnitID].rHealth < bestStat) then
											bestUnit = nearUnitID
											bestStat = allyUnits[nearUnitID].rHealth
										end
									end
								end
							end

							if (bestUnit ~= nil) then
								if (prevCommand ~= CMD.REPAIR) or (prevUnit ~= bestUnit) then
									orderQueue[unitID] = {1, CMD.REPAIR, bestUnit}
								end
								ordered = true
							end
						end

						if bestFeature and (not ordered) then
							if (prevCommand ~= CMD.RECLAIM) or (prevUnit ~= (bestFeature + Game.maxUnits)) then
								orderQueue[unitID] = {1, CMD.RECLAIM, (bestFeature + Game.maxUnits)}
							end
							ordered = true
						end
					end
				end

				if (nanoTurrets[unitID].auto) and (not ordered) and (cQueueCount > 0) and
						((prevCommand == CMD.REPAIR) or (prevCommand == CMD.RECLAIM)) then
					orderQueue[unitID] = {0, prevCommand, prevUnit}
				elseif ordered then
					nanoTurrets[unitID].auto = true
				end
			end
		end
	end
end

function widget:UnitGiven(unitID, unitDefID, unitTeam)
	widget:UnitFinished(unitID, unitDefID, unitTeam)
end

function widget:UnitDestroyed(unitID, unitDefID, unitTeam)
	buildUnits[unitID] = nil
	nanoTurrets[unitID] = nil
	teamUnits[unitID] = nil
	allyUnits[unitID] = nil
	orderQueue[unitID] = nil
end

function widget:UnitTaken(unitID, unitDefID, unitTeam)
	buildUnits[unitID] = nil
	nanoTurrets[unitID] = nil
	teamUnits[unitID] = nil
	allyUnits[unitID] = nil
	orderQueue[unitID] = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
