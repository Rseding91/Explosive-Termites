require "defines"

local maxRadius = 200
local initialRadius = 5
local spreadRadius = 10
local loaded

function ticker()
	if glob.termites ~= nil then
		if game.tick % 3 == 0 then
			processTermites()
		end
	else
		game.onevent(defines.events.ontick, nil)
	end
end

game.onload(function()
	if not loaded then
		loaded = true
		
		if glob.termites ~= nil then
			game.onevent(defines.events.ontick, ticker)
		end
	end
end)

game.oninit(function()
	loaded = true
	
	if glob.termites ~= nil then
		game.onevent(defines.events.ontick, ticker)
	end
end)

game.onevent(defines.events.onentitydied, function(event)
	local swarm
	local distX,distY
	
	if event.entity.name == "termite-detonation" then
		if glob.termites == nil then
			glob.termites = {}
			game.onevent(defines.events.ontick, ticker)
		end
		
		swarm = {}
		swarm.startTick = game.tick
		swarm.currentRange = initialRadius
		swarm.origin = event.entity.position
		swarm.trees = game.findentitiesfiltered{area = {{x = event.entity.position.x - maxRadius, y = event.entity.position.y - maxRadius}, {x = event.entity.position.x + maxRadius, y = event.entity.position.y + maxRadius}}, type = "tree"}
		swarm.more = {}
		swarm.more.validTrees = {}
		
		for k,tree in pairs(swarm.trees) do
			distX = math.abs(swarm.origin.x - tree.position.x)
			distY = math.abs(swarm.origin.y - tree.position.y)
			
			if math.floor(math.sqrt((distX * distX) + (distY * distY))) <= initialRadius then
				if swarm.more.validTrees[tree.position.x] == nil then
					swarm.more.validTrees[tree.position.x] = {}
				end
				
				swarm.more.validTrees[tree.position.x][tree.position.y] = 0
			end
			
			swarm.more[k] = tree.health / 3
		end
		
		table.insert(glob.termites, swarm)
	end
end)

function processTermites()
	local distX,distY
	local treesTicked = 0
	local nearTrees
	local treeX,treeY
	
	for k1,swarm in pairs(glob.termites) do
		for k2,tree in pairs(swarm.trees) do
			if tree.valid then
				treeX = tree.position.x
				treeY = tree.position.y
				if swarm.more.validTrees[treeX] ~= nil and swarm.more.validTrees[treeX][treeY] ~= nil then
					distX = math.abs(swarm.origin.x - treeX)
					distY = math.abs(swarm.origin.y - treeY)
					
					if math.floor(math.sqrt((distX * distX) + (distY * distY))) <= swarm.currentRange then
						treesTicked = treesTicked + 1
						
						if tree.health > 2 and tree.health >= swarm.more[k2] then
							tree.health = tree.health - 1
							
							if swarm.more.validTrees[treeX][treeY] == 0 then
								swarm.more.validTrees[treeX][treeY] = 1
								nearTrees = game.findentitiesfiltered{area = {{x = treeX - spreadRadius, y = treeY - spreadRadius}, {x = treeX + spreadRadius, y = treeY + spreadRadius}}, type = "tree"}
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
							game.createentity
							{
								name = "explosion",
								position = tree.position,
								force = game.forces.player
							}
							table.remove(swarm.trees, k2)
							tree.destroy()
						end
					end
				end
			else
				table.remove(swarm.trees, k2)
			end
		end
		
		if game.tick - swarm.startTick > 90 then
			if swarm.currentRange < maxRadius then
				swarm.currentRange = swarm.currentRange + 0.5
			elseif treesTicked == 0 then
				table.remove(glob.termites, k1)
			end
		end
	end
	
	if #glob.termites == 0 then
		glob.termites = nil
	end
end












