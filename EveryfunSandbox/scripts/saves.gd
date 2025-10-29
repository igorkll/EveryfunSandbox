extends Node

var savesFolderPath = "user://saves"

var currentWorldName
var currentWorldRuntimeData
var currentWorldData

var defaultWorldRuntimeData = {
	"interactiveVoxels": {},
	"fullLoaded": false,
	"time": 0,
	"autoSaveTimer": 0
}

var defaultWorldData = {
	"objectData": {},
	"interactiveVoxels": {},
	"dynamicBodies": [],
	"debug": {
		"debugInfo": false,
		"allowFly": false,
		"disableCollisionOnFly": false,
		"allowCheats": false
	}
}

var _loadingGameMessage
	
func isWorldLoaded() -> bool:
	return currentWorldName != null
	
func isWorldFullLoaded() -> bool:
	if currentWorldName == null:
		return false
		
	if currentWorldRuntimeData.fullLoaded:
		return true
	
	if currentWorldRuntimeData.time > consts.minimal_load_time and terrainUtils.isMinimalAreaLoaded(game.terrain,
		terrainUtils.getVoxelPositionFromGlobalPosition(game.terrain, game.player.position)):
		if not currentWorldRuntimeData.has("fullLoadedTimer"):
			currentWorldRuntimeData.fullLoadedTimer = 0
	else:
		currentWorldRuntimeData.erase("fullLoadedTimer")
			
	if currentWorldRuntimeData.has("fullLoadedTimer") and currentWorldRuntimeData.fullLoadedTimer >= consts.load_time_delay:
		currentWorldRuntimeData.fullLoaded = true
		if _loadingGameMessage != null:
			_loadingGameMessage.task_end()
			_loadingGameMessage = null
	
	return currentWorldRuntimeData.fullLoaded
	
func getPathInSave(path, savename=null):
	if savename == null:
		savename = currentWorldName
	return savesFolderPath.path_join(savename).path_join(path)
	
func getSavePath(savename):
	return savesFolderPath.path_join(savename)
	
func getObjectData(key):
	if not currentWorldData.objectData.has(key):
		currentWorldData.objectData[key] = {}
	return currentWorldData.objectData[key]

func save(saveEndCallback=null) -> bool:
	if currentWorldName == null || not isWorldFullLoaded() || currentWorldRuntimeData.has("voxelSaveCompletionTrackers"):
		return false
	
	currentWorldRuntimeData.savingProcessMessage = game.gameMessage("Saving...", null, true)
	currentWorldRuntimeData.saveEndCallback = saveEndCallback
	currentWorldRuntimeData.voxelSaveCompletionTrackers = [game.terrain.save_modified_blocks()]
	
	for body in game.dynamicBodies.get_children():
		_updateBodyDataInSave(body)
		currentWorldRuntimeData.voxelSaveCompletionTrackers.append(terrainUtils.getTerrain(body).save_modified_blocks())
	
	filesystem.writeObj(getPathInSave("data"), currentWorldData)
	
	return true
	
func isSaving() -> bool:
	if currentWorldName == null:
		return false
	
	return not not currentWorldRuntimeData.voxelSaveCompletionTrackers

func unload() -> bool:
	if currentWorldName == null:
		return false
	
	for child in game.objects.get_children():
		child.queue_free()
	
	game.terrain = null
	currentWorldName = null
	currentWorldRuntimeData = null
	return true

func open(savename) -> bool:
	if not exists(savename):
		return false
	
	_loadingGameMessage = game.gameMessage("Loading...", null, true)
	
	unload()
	currentWorldName = savename
	currentWorldRuntimeData = defaultWorldRuntimeData.duplicate(true)
	
	game.dynamicBodies = Node.new()
	game.dynamicBodies.name = "dynamicBodies"
	game.objects.add_child(game.dynamicBodies)
	
	var terrain = preload("res://scripts/terrain.gd").new()
	terrain.name = "terrain"
	game.objects.add_child(terrain)
	terrain.init(getPathInSave("terrain.db"))
	game.terrain = terrain
	
	var dataPath = getPathInSave("data")
	currentWorldData = {}
	if filesystem.isFile(dataPath):
		currentWorldData = filesystem.readObj(dataPath)
	currentWorldData = funcs.merge_dicts(currentWorldData, defaultWorldData)
	
	game.player.init()
	signals.emit_signal("world_open", savename)
	
	game.applySettings()
	
	return true
	
func exists(savename):
	return filesystem.isDirectory(getSavePath(savename))

func create(savename) -> bool:
	if exists(savename):
		return false
	filesystem.makeDirectory(getSavePath(savename))
	return open(savename)

func isInteractiveChunkBlockLoaded(position: Vector3i):
	return _loadedChunks.has(_getChunkPosition(position))
	
func list():
	return filesystem.list(savesFolderPath)

# --------------------------------------------------------------- dynamic bodies

func _updateBodyDataInSave(body):
	var global_transform = body.global_transform
	funcs.arraySet(currentWorldData.dynamicBodies, terrainUtils.getTerrain(body).id, [
		global_transform.origin,
		global_transform.basis.get_rotation_quaternion()
	])

func createBody(position, rotation=null):
	if rotation == null:
		rotation = Quaternion()
	
	var id = funcs.getNullIndex(currentWorldData.dynamicBodies)
	funcs.arraySet(currentWorldData.dynamicBodies, id, [position, rotation])
	return loadBody(id)

func loadBody(id: int):
	var data = currentWorldData.dynamicBodies[id]
	
	var terrain = preload("res://scripts/dynamicBody.gd").new()
	var body = RigidBody3D.new()
	body.name = "body_" + str(id)
	body.freeze = true
	body.add_child(terrain)
	game.dynamicBodies.add_child(body)
	var t = body.global_transform
	t.origin = data[0]
	t.basis = Basis(data[1])
	body.global_transform = t
	body.freeze = true
	terrain.init(id)

	_updateBodyDataInSave(body)
	return body

func unloadBody(body):
	body.queue_free()

func destroyBody(body):
	funcs.arraySet(currentWorldData.dynamicBodies, terrainUtils.getTerrain(body).id, null)
	funcs.deleteAllNullsOnEnd(currentWorldData.dynamicBodies)
	unloadBody(body)

# --------------------------------------------------------------- interactive voxels

func regInteractiveVoxel(terrain, position: Vector3i, blockId=null, storageData=null, tempInteractive=false):
	if storageData == null:
		storageData = {}
		
	if blockId == 0:
		blockId = null
	
	if blockId != null:
		if tempInteractive:
			_regInteractiveVoxel(currentWorldRuntimeData.interactiveVoxels, terrain, position, blockId, storageData)
		else:
			_regInteractiveVoxel(currentWorldData.interactiveVoxels, terrain, position, blockId, storageData)
	else:
		_regInteractiveVoxel(currentWorldData.interactiveVoxels, terrain, position, null, null)
		_regInteractiveVoxel(currentWorldRuntimeData.interactiveVoxels, terrain, position, null, null)
		
func getInteractiveVoxel(terrain, position: Vector3i):
	var chunkPosition = _getChunkPosition(position)
	if currentWorldData.interactiveVoxels.has(chunkPosition):
		return currentWorldData.interactiveVoxels[chunkPosition].get(position)
	elif currentWorldRuntimeData.interactiveVoxels.has(chunkPosition):
		return currentWorldRuntimeData.interactiveVoxels[chunkPosition].get(position)

func isNotTempInteractiveVoxel(terrain, position: Vector3i):
	var chunkPosition = _getChunkPosition(position)
	if currentWorldData.interactiveVoxels.has(chunkPosition):
		return currentWorldData.interactiveVoxels[chunkPosition].has(position)
	return false
		
func isTempInteractiveVoxel(terrain, position: Vector3i):
	var chunkPosition = _getChunkPosition(position)
	if currentWorldRuntimeData.interactiveVoxels.has(chunkPosition):
		return currentWorldRuntimeData.interactiveVoxels[chunkPosition].has(position)
	return false
	
func changeInteractiveVoxel(terrain, position: Vector3i, blockId=null):
	if isTempInteractiveVoxel(terrain, position):
		_changeInteractiveVoxel(currentWorldRuntimeData.interactiveVoxels, terrain, position, blockId)
	else:
		_changeInteractiveVoxel(currentWorldData.interactiveVoxels, terrain, position, blockId)

# --------------------------------------------------------------- interactive chunk

var _interactiveChunkSize = 32
var _loadedChunks = {}

func _getChunkPosition(position: Vector3i) -> Vector3i:
	return position / _interactiveChunkSize

func _regInteractiveVoxel(interactiveVoxels, terrain, position: Vector3i, blockId, storageData):
	var chunkPosition = _getChunkPosition(position)
	if blockId != null:
		if not interactiveVoxels.has(chunkPosition):
			interactiveVoxels[chunkPosition] = {}
		interactiveVoxels[chunkPosition][position] = [blockId, storageData]
	elif interactiveVoxels.has(chunkPosition):
		interactiveVoxels[chunkPosition].erase(position)
		if interactiveVoxels[chunkPosition].is_empty():
			interactiveVoxels.erase(chunkPosition)
	
func _changeInteractiveVoxel(interactiveVoxels, terrain, position: Vector3i, blockId=null):
	if blockId == 0:
		blockId = null
	
	var chunkPosition = _getChunkPosition(position)
	if blockId != null:
		if not interactiveVoxels.has(chunkPosition):
			interactiveVoxels[chunkPosition] = {}
		
		if interactiveVoxels[chunkPosition].has(chunkPosition):
			interactiveVoxels[chunkPosition][position][0] = blockId
		else:
			interactiveVoxels[chunkPosition][position] = [blockId, {}]
	elif interactiveVoxels.has(chunkPosition):
		interactiveVoxels[chunkPosition].erase(position)
		if interactiveVoxels[chunkPosition].is_empty():
			interactiveVoxels.erase(chunkPosition)

func _loadVoxels(chunkVoxels):
	if chunkVoxels:
		for interactiveVoxelPosition in chunkVoxels:
			var interactiveVoxel = chunkVoxels[interactiveVoxelPosition]
			terrainUtils.loadBlock(game.terrain, interactiveVoxelPosition, interactiveVoxel[0], interactiveVoxel[1])

func _unloadVoxels(chunkVoxels):
	if chunkVoxels:
		for interactiveVoxelPosition in chunkVoxels:
			terrainUtils.unloadBlock(game.terrain, interactiveVoxelPosition)

func _updateLoadedInteractiveVoxels(loadersPositions):
	var currentLoadedChunks = {}
	for loaderPosition in loadersPositions:
		var chunkPosition = _getChunkPosition(terrainUtils.getVoxelPositionFromGlobalPosition(game.terrain, loaderPosition))
		currentLoadedChunks[chunkPosition] = true
		
		if not _loadedChunks.has(chunkPosition):
			_loadedChunks[chunkPosition] = true
			
			_loadVoxels(currentWorldData.interactiveVoxels.get(chunkPosition))
			_loadVoxels(currentWorldRuntimeData.interactiveVoxels.get(chunkPosition))
	
	for loadedChunk in _loadedChunks.keys():
		if not currentLoadedChunks.has(loadedChunk):
			_loadedChunks.erase(loadedChunk)
			
			_unloadVoxels(currentWorldData.interactiveVoxels.get(loadedChunk))
			_unloadVoxels(currentWorldRuntimeData.interactiveVoxels.get(loadedChunk))

func _checkAutosave():
	if currentWorldRuntimeData.autoSaveTimer >= game.settings.game.autoSaveInterval:
		currentWorldRuntimeData.autoSaveTimer = 0
		save()
	
	if currentWorldRuntimeData.has("voxelSaveCompletionTrackers"):
		var saved = true
		
		for tracker in currentWorldRuntimeData.voxelSaveCompletionTrackers:
			if not tracker.is_complete():
				saved = false
				break
		
		if saved:
			currentWorldRuntimeData.savingProcessMessage.task_end()
			if game.settings.gui.showSaveLabel:
				game.gameMessage("Game saved!")
			
			if currentWorldRuntimeData.saveEndCallback:
				currentWorldRuntimeData.saveEndCallback.call()
			
			currentWorldRuntimeData.erase("voxelSaveCompletionTrackers")
			currentWorldRuntimeData.erase("savingProcessMessage")
			currentWorldRuntimeData.erase("saveEndCallback")
		
func _checkLoaded():
	var loadersPositions = []
	loadersPositions.append(game.camera.global_position)
	
	var chunkLoadingDistance = floor((game.view_distance * 2) / _interactiveChunkSize)
	if chunkLoadingDistance < 1:
		chunkLoadingDistance = 1
	
	var duplicatedLoadersPositions
	if chunkLoadingDistance > 1:
		duplicatedLoadersPositions = []
		for ix in range(chunkLoadingDistance):
			for iy in range(chunkLoadingDistance):
				for iz in range(chunkLoadingDistance):
					for pos in loadersPositions:
						var loaderPosition = pos + (Vector3(ix, iy, iz) * _interactiveChunkSize)
						var offset = (_interactiveChunkSize / 2) * (chunkLoadingDistance - 1)
						loaderPosition.x -= offset
						loaderPosition.y -= offset
						loaderPosition.z -= offset
						duplicatedLoadersPositions.append(loaderPosition)
	elif chunkLoadingDistance == 1:
		duplicatedLoadersPositions = loadersPositions
	else:
		duplicatedLoadersPositions = []
	
	_updateLoadedInteractiveVoxels(duplicatedLoadersPositions)

func _per_second():
	if currentWorldRuntimeData:
		_checkLoaded()

func _ready():
	timers.setInterval(_per_second, 1)

func _process(delta):
	if _loadingGameMessage != null:
		isWorldFullLoaded()
	
	if currentWorldRuntimeData:
		currentWorldRuntimeData.time += delta
		currentWorldRuntimeData.autoSaveTimer += delta
		if currentWorldRuntimeData.has("fullLoadedTimer"):
			currentWorldRuntimeData.fullLoadedTimer += delta

		_checkAutosave()
	
