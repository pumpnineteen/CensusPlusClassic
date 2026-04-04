local	addon_name, addonTable = ...  
local CPp = addonTable.CPp or {}

local g_AccumulatedPruneData = {};

function CensusPlus_AccumulatePruneData(realm, faction, race, class, name)
	local pruneData = {}
	pruneData.realm = realm
	pruneData.faction = faction
	pruneData.race = race
	pruneData.class = class
	pruneData.name = name
	--print("Prune "..realm.." "..faction.." "..race.." "..class.." "..name)
	table.insert(g_AccumulatedPruneData, pruneData)
end

-- Prune the accumulation
function CENSUSPLUS_PRUNETheData()
	local num = #g_AccumulatedPruneData
	CPp.Msg(format(CENSUSPLUS_PRUNEINFO, num))
	while (num > 0) do
		-- Remove the top job from the queue and send it
		local pruneData = g_AccumulatedPruneData[num]

		CensusPlus_Database["Servers"][pruneData.realm][pruneData.faction][pruneData.race][pruneData.class][pruneData.name]
		= {}
		CensusPlus_Database["Servers"][pruneData.realm][pruneData.faction][pruneData.race][pruneData.class][pruneData.name]
		= nil

		table.remove(g_AccumulatedPruneData)
		num = #g_AccumulatedPruneData
	end
end

-- Prune time entries
function CENSUSPLUS_PRUNETimes()
	local pruneDays = 60 * 60 * 24 * 21 --  num seconds
	local accumTimesData = {}
	local PruneCount = 0

	for realmName, realmDatabase in pairs(CensusPlus_Database["TimesPlus"]) do
		if (realmName ~= nil) then
			for factionName, factionDatabase in pairs(realmDatabase) do
				if (factionName ~= nil) then
					for moment, count in pairs(factionDatabase) do
						--  Moment is in format of YYYY-MM-DD&HH:MM
						local test = string.sub(moment, 1, 2)
						local tYear, tMonth, tDay
						tYear = string.sub(moment, 1, 4)
						tMonth = string.sub(moment, 6, 7)
						tDay = string.sub(moment, 9, 10)
						local momentTime = time({
							year = tYear,
							month = tMonth,
							day = tDay,
							hour = 0
						})

						if (time() - momentTime > pruneDays) then
							--  cull entry
							local pruneData = {}
							pruneData.realm = realmName
							pruneData.faction = factionName
							pruneData.entry = moment
							table.insert(accumTimesData, pruneData)
						end
					end
				end
			end
		end
	end

	local num = #accumTimesData
	while (num > 0) do
		local pruneData = accumTimesData[num]

		CensusPlus_Database["TimesPlus"][pruneData.realm][pruneData.faction][pruneData.entry]
		= {}
		CensusPlus_Database["TimesPlus"][pruneData.realm][pruneData.faction][pruneData.entry]
		= nil
		table.remove(accumTimesData)
		num = #accumTimesData
	end

	for realmName, realmDatabase in pairs(CensusPlus_Database["TimesPlus"]) do
		if (realmName ~= nil) then
			for factionName, factionDatabase in pairs(realmDatabase) do
				if (factionName ~= nil) then
					PruneCount = 0
					for _ in pairs(factionDatabase) do
						PruneCount = PruneCount + 1
					end
					if (PruneCount == 0) then
						realmDatabase[factionName] = {}
						realmDatabase[factionName] = nil
					end
				end
			end
			PruneCount = 0
			for _ in pairs(realmDatabase) do
				PruneCount = PruneCount + 1
			end
			if (PruneCount == 0) then
				CensusPlus_Database["TimesPlus"][realmName] = {}
				CensusPlus_Database["TimesPlus"][realmName] = nil
			end
		end
	end
end

function CENSUSPLUS_PRUNEDeadBranches()
	local PruneCount = 0

	for realmName, realmDatabase in pairs(CensusPlus_Database["Servers"]) do
		if (realmName ~= nil) then
			for factionName, factionDatabase in pairs(realmDatabase) do
				if (factionName ~= nil) then
					for raceName, raceDatabase in pairs(factionDatabase) do
						if (raceName ~= nil) then
							for className, classDatabase in
								pairs(raceDatabase)
							do
								if (className ~= nil) then
									PruneCount = 0
									for _ in pairs(classDatabase) do
										PruneCount = PruneCount + 1
										if (PruneCount > 0) then
											break
										end
									end
									if (PruneCount == 0) then
										raceDatabase[className] = {}
										raceDatabase[className] = nil
									end
								end
							end
							PruneCount = 0
							for _ in pairs(raceDatabase) do
								PruneCount = PruneCount + 1
								if (PruneCount > 0) then
									break
								end
							end
							if (PruneCount == 0) then
								factionDatabase[raceName] = {}
								factionDatabase[raceName] = nil
							end
						end
					end
					PruneCount = 0
					for _ in pairs(factionDatabase) do
						PruneCount = PruneCount + 1
						if (PruneCount > 0) then
							break
						end
					end
					if (PruneCount == 0) then
						realmDatabase[factionName] = {}
						realmDatabase[factionName] = nil
					end
				end
			end
			PruneCount = 0
			for _ in pairs(realmDatabase) do
				PruneCount = PruneCount + 1
				if (PruneCount > 0) then
					break
				end
			end
			if (PruneCount == 0) then
				CensusPlus_Database["Servers"][realmName] = {}
				CensusPlus_Database["Servers"][realmName] = nil
			end
		end
	end
end
