extends Node

var currentWorldName
var currentWorldRuntimeData
var currentWorldData

var defaultWorldData = {
	"playersData": {}
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
	
	if game.terrain.is_area_meshed(AABB(
		game.getVoxelPositionFromGlobalPosition(game.player.position) - consts.minimum_loading_radius_for_play,
		game.getVoxelPositionFromGlobalPosition(game.player.position) + consts.minimum_loading_radius_for_play), 0):
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

func save() -> bool:
	if currentWorldName == null:
		return false
	
	game.terrain.save()
	filesystem.writeObj(getPathInSave("data"), currentWorldData)
	
	game.gameMessage("game saved!")
	
	return true

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
	
	loadingGameMessage = game.gameMessage("loading...", null, true)
	
	unload()
	currentWorldName = savename
	currentWorldRuntimeData = {
		"fullLoaded": false
	}
	
	var terrainScript = preload("res://scripts/terrain.gd")
	var terrain = VoxelLodTerrain.new()
	terrain.name = "terrain"
	terrain.set_script(terrainScript)
	objects.add_child(terrain)
	terrain.init(getPathInSave("terrain.db"))
	game.terrain = terrain
	
	var dataPath = getPathInSave("data")
	currentWorldData = {}
	if filesystem.isFile(dataPath):
		currentWorldData = filesystem.readObj(dataPath)
	currentWorldData = funcs.merge_dicts(currentWorldData, defaultWorldData)
	
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
