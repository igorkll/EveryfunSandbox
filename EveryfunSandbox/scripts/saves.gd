extends Node

var currentWorldName
var currentWorldRuntimeData
var currentWorldData

var defaultWorldData = {
	"objectData": {},
	"interactiveVoxelPositions": {}
}

var objects
var loadingGameMessage

func _ready():
	objects = get_node("/root/main/objects")
	
func isWorldLoaded() -> bool:
	return currentWorldName != null
	
func isWorldFullLoaded() -> bool:
	if currentWorldName == null:
		return false
		
	if currentWorldRuntimeData.fullLoaded:
		return true
	
	if currentWorldRuntimeData.time > consts.minimal_load_time and game.terrain.is_area_meshed(AABB(
		terrainUtils.getVoxelPositionFromGlobalPosition(game.player.position) - consts.minimum_loading_radius_for_play,
		terrainUtils.getVoxelPositionFromGlobalPosition(game.player.position) + consts.minimum_loading_radius_for_play), 0):
		currentWorldRuntimeData.fullLoaded = true
		if loadingGameMessage != null:
			loadingGameMessage.task_end()
			loadingGameMessage = null
	
	return currentWorldRuntimeData.fullLoaded
	
func getPathInSave(path, savename=null):
	if savename == null:
		savename = currentWorldName
	return ("user://saves").path_join(savename).path_join(path)
	
func getSavePath(savename):
	return ("user://saves").path_join(savename)
	
func getObjectData(key):
	if not currentWorldData.objectData.has(key):
		currentWorldData.objectData[key] = {}
	return currentWorldData.objectData[key]

func save(saveEndCallback=null) -> bool:
	if currentWorldName == null || not isWorldFullLoaded() || currentWorldRuntimeData.has("voxelSaveCompletionTracker"):
		return false
	
	currentWorldRuntimeData.savingProcessMessage = game.gameMessage("Saving...", null, true)
	currentWorldRuntimeData.saveEndCallback = saveEndCallback
	currentWorldRuntimeData.voxelSaveCompletionTracker = game.terrain.save_modified_blocks()
	filesystem.writeObj(getPathInSave("data"), currentWorldData)
	
	return true
	
func isSaving() -> bool:
	if currentWorldName == null:
		return false
	
	return not not currentWorldRuntimeData.voxelSaveCompletionTracker

func unload() -> bool:
	if currentWorldName == null:
		return false
	
	for child in objects.get_children():
		child.queue_free()
	
	game.terrain = null
	currentWorldName = null
	currentWorldRuntimeData = null
	return true

func open(savename) -> bool:
	if not exists(savename):
		return false
	
	loadingGameMessage = game.gameMessage("Loading...", null, true)
	
	unload()
	currentWorldName = savename
	currentWorldRuntimeData = {
		"fullLoaded": false,
		"time": 0,
		"autoSaveTimer": 0
	}
	
	var terrain = preload("res://scripts/terrain.gd").new()
	terrain.name = "terrain"
	objects.add_child(terrain)
	terrain.init(getPathInSave("terrain.db"))
	game.terrain = terrain
	
	var dataPath = getPathInSave("data")
	currentWorldData = {}
	if filesystem.isFile(dataPath):
		currentWorldData = filesystem.readObj(dataPath)
	currentWorldData = funcs.merge_dicts(currentWorldData, defaultWorldData)
	
	for pos in currentWorldData.interactiveVoxelPositions:
		terrainUtils.loadBlock(pos, currentWorldData.interactiveVoxelPositions[pos])
	
	game.player.init()
	
	return true
	
func exists(savename):
	return filesystem.isDirectory(getSavePath(savename))

func create(savename) -> bool:
	if exists(savename):
		return false
	filesystem.makeDirectory(getSavePath(savename))
	return open(savename)

func _process(delta):
	if loadingGameMessage != null:
		isWorldFullLoaded()
	
	if currentWorldRuntimeData:
		currentWorldRuntimeData.time += delta
		currentWorldRuntimeData.autoSaveTimer += delta

		if currentWorldRuntimeData.autoSaveTimer >= game.settings.game.autoSaveInterval:
			currentWorldRuntimeData.autoSaveTimer = 0
			save()
		
		if currentWorldRuntimeData.has("voxelSaveCompletionTracker") && currentWorldRuntimeData.voxelSaveCompletionTracker.is_complete():
			currentWorldRuntimeData.savingProcessMessage.task_end()
			game.gameMessage("Game saved!")
			
			if currentWorldRuntimeData.saveEndCallback:
				currentWorldRuntimeData.saveEndCallback.call()
			
			currentWorldRuntimeData.erase("voxelSaveCompletionTracker")
			currentWorldRuntimeData.erase("savingProcessMessage")
			currentWorldRuntimeData.erase("saveEndCallback")
			
