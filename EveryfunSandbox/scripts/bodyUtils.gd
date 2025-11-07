extends Node

func updateBodyDataInSave(body):
	var global_transform = body.global_transform
	funcs.arraySet(saves.currentWorldData.dynamicBodies, terrainUtils.getTerrain(body).id, [
		global_transform.origin,
		global_transform.basis.get_rotation_quaternion()
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
	funcs.arraySet(saves.currentWorldData.dynamicBodies, id, [position, rotation])
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
	body.freeze = false
	terrain.position = Vector3(-0.5, -0.5, -0.5)
	terrain.init(id)

	updateBodyDataInSave(body)
	return body

func unloadBody(body):
	# need save terrain
	updateBodyDataInSave(body)
	body.queue_free()

func destroyBody(body):
	var id = terrainUtils.getTerrain(body).id
	body.queue_free()
	filesystem.remove(bodyUtils.getBodyTerrainPath(id))
	funcs.arraySet(saves.currentWorldData.dynamicBodies, terrainUtils.getTerrain(body).id, null)
	funcs.deleteAllNullsOnEnd(saves.currentWorldData.dynamicBodies)
