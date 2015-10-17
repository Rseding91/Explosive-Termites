require "defines"
require "util"

local swarmSettings =
{
	[1] =
	{
		["maxRadius"] = 200,
		["initialRadius"] = 5,
		["spreadRadius"] = 10,
		["warmupTime"] = 90
	},
	[2] =
	{
		["maxRadius"] = 400,
		["initialRadius"] = 15,
		["spreadRadius"] = 20,
		["swarmTicksBetweenVeins"] = 20,
		["numberOfVeins"] = 10,
		["warmupTime"] = 180
	}
}

local directionRanges =
{
	{["min"] = 10, ["max"] = 40},
	{["min"] = 50, ["max"] = 80},
	{["min"] = 100, ["max"] = 130},
	{["min"] = 150, ["max"] = 180},
	{["min"] = 200, ["max"] = 230},
	{["min"] = 250, ["max"] = 280},
	{["min"] = 300, ["max"] = 330}
}

local swarmTickers
local knownNames

function ticker()
	if global.termites ~= nil then
		if game.tick % 3 == 0 then
			processTermites()
		end
	else
		script.on_event(defines.events.on_tick, nil)
	end
end

script.on_configuration_changed(function(data)
  if global.termites ~= nil then
    for k,v in pairs(global.termites) do
      if v.suface == nil then
        v.surface = game.get_surface(1)
      end
    end
  end
end)

script.on_load(function()
  if global.termites ~= nil then
    script.on_event(defines.events.on_tick, ticker)
  end
end)

script.on_event(defines.events.on_trigger_created_entity, function(event)
	if knownNames[event.entity.name] then
		if global.termites == nil then
			global.termites = {}
			script.on_event(defines.events.on_tick, ticker)
		end
		knownNames[event.entity.name](event.entity.position, event.entity.surface)
		event.entity.destroy()
	end
end)

function setupSwarmType1(position, surface)
	local swarm = {}
	local initialRadius = swarmSettings[1]["initialRadius"]
	local maybeTrees = surface.find_entities_filtered{area = {{x = position.x - initialRadius, y = position.y - initialRadius}, {x = position.x + initialRadius, y = position.y + initialRadius}}, type = "tree"}
	
	swarm.startTick = game.tick
	swarm.currentRange = initialRadius
	swarm.origin = position
	swarm.trees = {}
	swarm.validTrees = {}
	swarm.type = 1
  swarm.surface = surface
	
	for k,tree in pairs(maybeTrees) do
		distX = math.abs(swarm.origin.x - tree.position.x)
		distY = math.abs(swarm.origin.y - tree.position.y)
		
		if math.floor(math.sqrt((distX * distX) + (distY * distY))) <= initialRadius then
			if swarm.validTrees[tree.position.x] == nil then
				swarm.validTrees[tree.position.x] = {}
			end
			
			swarm.validTrees[tree.position.x][tree.position.y] = 0
			table.insert(swarm.trees, {[1] = tree, [2] = tree.health / 3})
		end
	end
	
	table.insert(global.termites, swarm)
end

function setupSwarmType2(position, surface)
	local swarm = {}
	
	swarm.startTick = game.tick
	swarm.currentRange = swarmSettings[2]["initialRadius"]
	swarm.origin = position
	swarm.trees = {}
	swarm.vein = {}
	swarm.veinDirections = {}
	swarm.validTrees = {}
	swarm.type = 2
	swarm.phase = 1
	swarm.completedVeinCount = 0
  swarm.surface = surface
	swarm.surface.create_entity({name = "alien-termite-cloud", position = position})
	
	table.insert(global.termites, swarm)
end

function processTermites()
	for k,swarm in pairs(global.termites) do
		if swarm.type == nil then
			if not tickSwarmType0(swarm) then
				table.remove(global.termites, k)
			end
		elseif swarmTickers[swarm.type] then
			if not swarmTickers[swarm.type](swarm) then
				table.remove(global.termites, k)
			end
		end
	end
	
	if #global.termites == 0 then
		global.termites = nil
	end
end

remote.add_interface("termites", {
	test = function()
		for _,player in pairs(game.players) do
			player.insert({name = "explosive-termites", count = 64})
			player.insert({name = "alien-explosive-termites", count = 64})
		end
	end
})

function getVeinGroups(source, settings, surface)
	local segmentLengths = settings["lengths"]
	local startWidths = settings["startWidths"]
	local endWidths = settings["endWidths"]
	local segmentOrientations = settings["orientations"]
	local segmentCount = settings["count"]
	local pos1, pos2, pos3, pos4 = {}, {}, {}, {}
	local area, vertx, verty
	local currentPosition = {x = source.x, y = source.y}
	local currentOrientation
	local groups = {}
	local foundPos = {}
	
	for n=1,segmentCount do
		currentOrientation = segmentOrientations[n]
		pos1.x = currentPosition.x - (startWidths[n] / 2) * math.sin(currentOrientation * math.pi / 180)
		pos1.y = currentPosition.y + (startWidths[n] / 2) * math.cos(currentOrientation * math.pi / 180)
		pos2.x = currentPosition.x + (startWidths[n] / 2) * math.sin(currentOrientation * math.pi / 180)
		pos2.y = currentPosition.y - (startWidths[n] / 2) * math.cos(currentOrientation * math.pi / 180)
		pos3.x = currentPosition.x + segmentLengths[n] * math.cos(currentOrientation * math.pi / 180) - (endWidths[n] / 2) * math.sin(currentOrientation * math.pi / 180)
		pos3.y = currentPosition.y + segmentLengths[n] * math.sin(currentOrientation * math.pi / 180) + (endWidths[n] / 2) * math.cos(currentOrientation * math.pi / 180)
		pos4.x = currentPosition.x + segmentLengths[n] * math.cos(currentOrientation * math.pi / 180) + (endWidths[n] / 2) * math.sin(currentOrientation * math.pi / 180)
		pos4.y = currentPosition.y + segmentLengths[n] * math.sin(currentOrientation * math.pi / 180) - (endWidths[n] / 2) * math.cos(currentOrientation * math.pi / 180)
		
		area = {{x = currentPosition.x, y = currentPosition.y}, {x = currentPosition.x, y = currentPosition.y}}
		area[1].x = math.min(area[1].x, pos1.x)
		area[1].x = math.min(area[1].x, pos2.x)
		area[1].x = math.min(area[1].x, pos3.x)
		area[1].x = math.min(area[1].x, pos4.x)
		area[2].x = math.max(area[2].x, pos1.x)
		area[2].x = math.max(area[2].x, pos2.x)
		area[2].x = math.max(area[2].x, pos3.x)
		area[2].x = math.max(area[2].x, pos4.x)
		
		area[1].y = math.min(area[1].y, pos1.y)
		area[1].y = math.min(area[1].y, pos2.y)
		area[1].y = math.min(area[1].y, pos3.y)
		area[1].y = math.min(area[1].y, pos4.y)
		area[2].y = math.max(area[2].y, pos1.y)
		area[2].y = math.max(area[2].y, pos2.y)
		area[2].y = math.max(area[2].y, pos3.y)
		area[2].y = math.max(area[2].y, pos4.y)
		
		vertx = {pos1.x, pos2.x, pos4.x, pos3.x}
		verty = {pos1.y, pos2.y, pos4.y, pos3.y}
		
		local entities = surface.find_entities_filtered({area = area, type = "tree"})
		local data = {}
		for _,tree in pairs(entities) do
			if foundPos[tree.position.x] == nil or foundPos[tree.position.x][tree.position.y] == nil then
				if pnpoly(vertx, verty, tree.position.x, tree.position.y) then
					if foundPos[tree.position.x] == nil then
						foundPos[tree.position.x] = {}
					end
					foundPos[tree.position.x][tree.position.y] = 1
					table.insert(data, tree)
				end
			end
		end
		groups[n] = data
		currentPosition.x = currentPosition.x + segmentLengths[n] * math.cos(currentOrientation * math.pi / 180)
		currentPosition.y = currentPosition.y + segmentLengths[n] * math.sin(currentOrientation * math.pi / 180)
		local radius = endWidths[n] / 2
		local maybeTrees = surface.find_entities_filtered{area = {{x = currentPosition.x - radius, y = currentPosition.y - radius}, {x = currentPosition.x + radius, y = currentPosition.y + radius}}, type = "tree"}
		local distX, distY
		for k,tree in pairs(maybeTrees) do
			distX = math.abs(currentPosition.x - tree.position.x)
			distY = math.abs(currentPosition.y - tree.position.y)
			
			if foundPos[tree.position.x] == nil or foundPos[tree.position.x][tree.position.y] == nil then
				if foundPos[tree.position.x] == nil then
					foundPos[tree.position.x] = {}
				end
				foundPos[tree.position.x][tree.position.y] = 1
				
				if math.floor(math.sqrt((distX * distX) + (distY * distY))) <= radius then
					table.insert(data, tree)
				end
			end
		end
		
	end
	
	return groups
end

function pnpoly(vertx, verty, testx, testy)
	local j = 4
	local c = false
	
	for i = 1, 4 do
		if ((verty[i] > testy) ~= (verty[j] > testy)) and (testx < (vertx[j] - vertx[i]) * (testy - verty[i]) / (verty[j] - verty[i]) + vertx[i]) then
			c = not c
		end
		j = i
	end
	
	return c
end

function tickSwarmType2(swarm)
	local spreadRadius = swarmSettings[swarm.type]["spreadRadius"]
	local warmupTime = swarmSettings[swarm.type]["warmupTime"]
	
	if swarm.phase == 1 then
		if game.tick >= (swarm.startTick + warmupTime) then
			swarm.phase = 2
			swarm.phaseStep = 1
		elseif math.random(5) == 1 then
			local x = (randomSign() * math.random(10)) + swarm.origin.x
			local y = (randomSign() * math.random(10)) + swarm.origin.y
			swarm.surface.create_entity({name = "medium-explosion", position = {x = x, y = y}})
		end
	elseif swarm.phase == 2 then
		local health
		local phaseStep = swarm.phaseStep
		
		if phaseStep == 1 then
			swarm.vein = getVeinGroups(swarm.origin, generateSettings(swarm), swarm.surface)
			swarm.phaseStep = 2
		elseif phaseStep > swarmSettings[swarm.type]["swarmTicksBetweenVeins"] then
			for k,group in pairs(swarm.vein) do
				for i,tree in pairs(group) do
					if tree.valid then
						swarm.surface.create_entity
						{
							name = "explosion",
							position = tree.position,
							force = game.forces.player
						}
						tree.destroy()
					end
				end
			end
			swarm.vein = nil
			swarm.phaseStep = nil
			
			local count = swarm.completedVeinCount + 1
			swarm.completedVeinCount = count
			
			if count == swarmSettings[swarm.type]["numberOfVeins"] then
				swarm.phase = 3
				swarm.completedVeinCount = nil
				
				local radius = swarm.currentRange
				local maybeTrees = swarm.surface.find_entities_filtered{area = {{x = swarm.origin.x - radius, y = swarm.origin.y - radius}, {x = swarm.origin.x + radius, y = swarm.origin.y + radius}}, type = "tree"}
				for k,tree in pairs(maybeTrees) do
					distX = math.abs(swarm.origin.x - tree.position.x)
					distY = math.abs(swarm.origin.y - tree.position.y)
					
					if math.floor(math.sqrt((distX * distX) + (distY * distY))) <= radius then
						if swarm.validTrees[tree.position.x] == nil then
							swarm.validTrees[tree.position.x] = {}
						end
						
						swarm.validTrees[tree.position.x][tree.position.y] = 0
						table.insert(swarm.trees, {[1] = tree, [2] = tree.health - 1})
					end
				end
			else
				swarm.vein = getVeinGroups(swarm.origin, generateSettings(swarm), swarm.surface)
				swarm.phaseStep = 2
			end
		else
			swarm.phaseStep = phaseStep + 1
			if math.random(5) == 1 then
				local x = (randomSign() * math.random(10)) + swarm.origin.x
				local y = (randomSign() * math.random(10)) + swarm.origin.y
				swarm.surface.create_entity({name = "medium-explosion", position = {x = x, y = y}})
			end
		end
	elseif swarm.phase == 3 then
		local treesTicked = 0
		local tree
		local health
		local spreadRadius = swarmSettings[swarm.type]["spreadRadius"]
		local foundTreeX, foundTreeY
		local performanceBreak = false
		local abs = math.abs
		local floor = math.floor
		local sqrt = math.sqrt
		local validTrees = swarm.validTrees
		
		for k,treeTable in pairs(swarm.trees) do
			if (swarm.currentRange > 200 and treesTicked == 100) or treesTicked == 300 then
				performanceBreak = true
				break
			end
			tree = treeTable[1]
			if tree.valid then
				treeX = tree.position.x
				treeY = tree.position.y
				distX = abs(swarm.origin.x - treeX)
				distY = abs(swarm.origin.y - treeY)
				
				if floor(sqrt((distX * distX) + (distY * distY))) <= swarm.currentRange then
					treesTicked = treesTicked + 1
					health = tree.health
					if health > treeTable[2] then
						tree.health = health - 1
						
						if validTrees[treeX][treeY] == 0 then
							validTrees[treeX][treeY] = 1
							nearTrees = swarm.surface.find_entities_filtered({area = {{x = treeX - spreadRadius, y = treeY - spreadRadius}, {x = treeX + spreadRadius, y = treeY + spreadRadius}}, type = "tree"})
							for _,tree2 in pairs(nearTrees) do
								foundTreeX = tree2.position.x
								foundTreeY = tree2.position.y
								if validTrees[foundTreeX] == nil or validTrees[foundTreeX][foundTreeY] == nil then
									distX = abs(treeX - foundTreeX)
									distY = abs(treeY - foundTreeY)
									
									if floor(sqrt((distX * distX) + (distY * distY))) <= spreadRadius then
										if validTrees[foundTreeX] == nil then
											validTrees[foundTreeX] = {}
										end
										
										validTrees[foundTreeX][foundTreeY] = 0
										table.insert(swarm.trees, {[1] = tree2, [2] = tree2.health - 1})
									end
								end
							end
						end
					else
						swarm.surface.create_entity({name = "explosion", position = tree.position, })
						table.remove(swarm.trees, k)
						tree.destroy()
					end
				end
			else
				table.remove(swarm.trees, k)
			end
		end
		
		if performanceBreak == false then
			if swarm.currentRange < swarmSettings[swarm.type]["maxRadius"] then
				swarm.currentRange = swarm.currentRange + 1.5
			elseif treesTicked == 0 then
				return false
			end
		end
	end
	
	return true
end

function generateSettings(swarm)
	local settings =
	{
		["lengths"] = {
			[1] = 30,
			[2] = 30,
			[3] = 25,
			[4] = 25,
			[5] = 25,
			[6] = 20,
			[7] = 15,
			[8] = 10,
			[9] = 10,
			[10] = 10
		},
		["startWidths"] = {
			[1] = 8,
			[2] = 8,
			[3] = 7,
			[4] = 7,
			[5] = 7,
			[6] = 7,
			[7] = 6,
			[8] = 6,
			[9] = 6,
			[10] = 5
		},
		["endWidths"] = {
			[1] = 8,
			[2] = 8,
			[3] = 7,
			[4] = 7,
			[5] = 7,
			[6] = 7,
			[7] = 6,
			[8] = 6,
			[9] = 6,
			[10] = 5
		},
		["orientations"] = {},
		["count"] = 10
	}
	local oneAgo
	local twoAgo
	local last
	local sign
	local minOrientation, maxOrientation
	
	if #swarm.veinDirections == 0 then
		swarm.veinDirections = util.table.deepcopy(directionRanges)
		for i = #swarm.veinDirections, 2, -1 do
			local r = math.random(i)
			swarm.veinDirections[i], swarm.veinDirections[r] = swarm.veinDirections[r], swarm.veinDirections[i]
		end  
	end
	
	local k = math.random(#swarm.veinDirections)
	minOrientation = swarm.veinDirections[k]["min"]
	maxOrientation = swarm.veinDirections[k]["max"]
	table.remove(swarm.veinDirections, k)
	
	settings["orientations"][1] = math.random(minOrientation, maxOrientation)
	last = settings["orientations"][1]
	oneAgo = randomSign()
	settings["orientations"][2] = last + (oneAgo * 90)
	last = settings["orientations"][2]
	
	for i=3,settings["count"] do
		sign = randomSign()
		if sign == oneAgo and sign == twoAgo then
			sign = sign * -1
		end
		settings["orientations"][i] = last + (sign * 90)
		twoAgo = oneAgo
		oneAgo = sign
		last = settings["orientations"][i]
	end
	
	return settings
end

function randomSign()
	if math.random(1, 2) == 1 then
		return -1
	else
		return 1
	end
end

function tickSwarmType1(swarm)
	local treesTicked = 0
	local tree
	local spreadRadius = swarmSettings[swarm.type]["spreadRadius"]
	local treeX, treeY, foundTreeX, foundTreeY
	
	for k,treeTable in pairs(swarm.trees) do
		tree = treeTable[1]
		if tree.valid then
			treeX = tree.position.x
			treeY = tree.position.y
			distX = math.abs(swarm.origin.x - treeX)
			distY = math.abs(swarm.origin.y - treeY)
			
			if math.floor(math.sqrt((distX * distX) + (distY * distY))) <= swarm.currentRange then
				treesTicked = treesTicked + 1
				
				if tree.health > 2 and tree.health >= treeTable[2] then
					tree.health = tree.health - 1
					
					if swarm.validTrees[treeX][treeY] == 0 then
						swarm.validTrees[treeX][treeY] = 1
						nearTrees = swarm.surface.find_entities_filtered({area = {{x = treeX - spreadRadius, y = treeY - spreadRadius}, {x = treeX + spreadRadius, y = treeY + spreadRadius}}, type = "tree"})
						for _,tree2 in pairs(nearTrees) do
							foundTreeX = tree2.position.x
							foundTreeY = tree2.position.y
							if swarm.validTrees[foundTreeX] == nil or swarm.validTrees[foundTreeX][foundTreeY] == nil then
								distX = math.abs(treeX - foundTreeX)
								distY = math.abs(treeY - foundTreeY)
								
								if math.floor(math.sqrt((distX * distX) + (distY * distY))) <= spreadRadius then
									if swarm.validTrees[foundTreeX] == nil then
										swarm.validTrees[foundTreeX] = {}
									end
									
									swarm.validTrees[foundTreeX][foundTreeY] = 0
									table.insert(swarm.trees, {[1] = tree2, [2] = tree2.health / 3})
								end
							end
						end
					end
				else
					swarm.surface.create_entity
					{
						name = "explosion",
						position = tree.position,
						force = game.forces.player
					}
					table.remove(swarm.trees, k)
					tree.destroy()
				end
			end
		else
			table.remove(swarm.trees, k)
		end
	end
	
	if game.tick - swarm.startTick > swarmSettings[swarm.type]["warmupTime"] then
		if swarm.currentRange < swarmSettings[swarm.type]["maxRadius"] then
			swarm.currentRange = swarm.currentRange + 0.5
		elseif treesTicked == 0 then
			return false
		end
	end
	
	return true
end

function tickSwarmType0(swarm)
	local treesTicked = 0
	local spreadRadius = 10
	local maxRadius = 200
	
	for k,tree in pairs(swarm.trees) do
		if tree.valid then
			treeX = tree.position.x
			treeY = tree.position.y
			if swarm.more.validTrees[treeX] ~= nil and swarm.more.validTrees[treeX][treeY] ~= nil then
				distX = math.abs(swarm.origin.x - treeX)
				distY = math.abs(swarm.origin.y - treeY)
				
				if math.floor(math.sqrt((distX * distX) + (distY * distY))) <= swarm.currentRange then
					treesTicked = treesTicked + 1
					
					if tree.health > 2 and tree.health >= swarm.more[k] then
						tree.health = tree.health - 1
						
						if swarm.more.validTrees[treeX][treeY] == 0 then
							swarm.more.validTrees[treeX][treeY] = 1
							nearTrees = swarm.surface.find_entities_filtered{area = {{x = treeX - spreadRadius, y = treeY - spreadRadius}, {x = treeX + spreadRadius, y = treeY + spreadRadius}}, type = "tree"}
							for _,tree in pairs(nearTrees) do
								distX = math.abs(treeX - tree.position.x)
								distY = math.abs(treeY - tree.position.y)
								
								if math.floor(math.sqrt((distX * distX) + (distY * distY))) <= spreadRadius then
									if swarm.more.validTrees[tree.position.x] == nil then
										swarm.more.validTrees[tree.position.x] = {}
									end
									
									if swarm.more.validTrees[tree.position.x][tree.position.y] == nil then
										swarm.more.validTrees[tree.position.x][tree.position.y] = 0
									end
								end
							end
						end
					else
						swarm.surface.create_entity
						{
							name = "explosion",
							position = tree.position,
							force = game.forces.player
						}
						table.remove(swarm.trees, k)
						tree.destroy()
					end
				end
			end
		else
			table.remove(swarm.trees, k)
		end
	end
	
	if game.tick - swarm.startTick > 90 then
		if swarm.currentRange < maxRadius then
			swarm.currentRange = swarm.currentRange + 0.5
		elseif treesTicked == 0 then
			return false
		end
	end
	
	return true
end

knownNames =
{
	["termite-detonation"] = setupSwarmType1,
	["alien-termite-detonation"] = setupSwarmType2
}

swarmTickers =
{
	[1] = tickSwarmType1,
	[2] = tickSwarmType2
}
