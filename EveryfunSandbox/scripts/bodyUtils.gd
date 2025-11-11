extends Node

func getBody(body):
	if body is RigidBody3D:
		return body
	return body.get_parent()

func updateBodyDataInSave(body):
	body = getBody(body)
	var terrain = terrainUtils.getTerrain(body)
	if not terrain:
		return
	
	var global_transform = body.global_transform
	funcs.arraySet(saves.currentWorldData.dynamicBodies, terrain.id, [
		global_transform.origin,
		global_transform.basis.get_rotation_quaternion(),
		terrain.storageData,
		body.linear_velocity,
		body.angular_velocity
	])
	
func getBodyTerrainPath(id: int):
	var idStr = str(id)
	var terrainPath = saves.getPathInSave("bodies".path_join(idStr + ".db"))
	filesystem.makeDirectoryForFile(terrainPath)
	return terrainPath

func createBody(position, rotation=null):
	if rotation == null:
		rotation = Quaternion()
	
	var id = funcs.getNullIndex(saves.currentWorldData.dynamicBodies)
	funcs.arraySet(saves.currentWorldData.dynamicBodies, id, [position, rotation, {}, Vector3(), Vector3()])
	return loadBody(id)

func loadBody(id: int):
	var data = saves.currentWorldData.dynamicBodies[id]
	
	var terrain = preload("res://scripts/classes/dynamicBody.gd").new()
	var body = RigidBody3D.new()
	body.name = "body_" + str(id)
	body.freeze = true
	body.add_child(terrain)
	game.dynamicBodies.add_child(body)
	var t = body.global_transform
	t.origin = data[0]
	t.basis = Basis(data[1])
	body.global_transform = t
	body.linear_velocity = data[3]
	body.angular_velocity = data[4]
	terrain.freeze = false
	terrain.position = Vector3(-0.5, -0.5, -0.5)
	terrain.storageData = data[2]
	terrain.init(id)
	
	print("LOAD BODY ", terrain.id)

	updateBodyDataInSave(body)
	updateBody(body)
	return body
	
func updateBody(body):
	body = getBody(body)
	var terrain = terrainUtils.getTerrain(body)
	terrain.needUpdate = false
	
	var mass = 0
	var center_of_mass = Vector3(0, 0, 0)
	for pos in terrain.loadedBlocks:
		var id = terrain.loadedBlocks[pos][1]
		var blockInfo = blockUtils.list_id2obj[id].info
		mass += blockInfo.weight
		center_of_mass = (Vector3(pos) + blockInfo.center_of_mass) * blockInfo.weight
	
	if mass <= 0:
		mass = 0.001
	center_of_mass /= mass
		
	body.mass = mass
	body.center_of_mass_mode = RigidBody3D.CenterOfMassMode.CENTER_OF_MASS_MODE_CUSTOM
	body.center_of_mass = center_of_mass

func unloadBody(body):
	body = getBody(body)
	var terrain = terrainUtils.getTerrain(body)
	if terrain.unloaded:
		return
	terrain.unloaded = true
	print("UNLOAD BODY ", terrain.id)
	saves.saveBodyId(body)
	updateBodyDataInSave(body)
	body.remove_child(terrain)
	game.tempNode.add_child(terrain)
	saves.saveTerrainBackground(terrain)
	body.queue_free()

func destroyBody(body):
	body = getBody(body)
	var terrain = terrainUtils.getTerrain(body)
	terrain.unloaded = true
	
	var id = terrainUtils.getTerrain(body).id
	body.queue_free()
	filesystem.remove(bodyUtils.getBodyTerrainPath(id))
	funcs.arraySet(saves.currentWorldData.dynamicBodies, terrainUtils.getTerrain(body).id, null)
	funcs.deleteAllNullsOnEnd(saves.currentWorldData.dynamicBodies)
