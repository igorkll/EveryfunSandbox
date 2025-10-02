extends Node

var currentWorldName = null
var currentWorldRuntimeData = null
var objects

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
	return true
	
func exists(savename):
	return filesystem.isDirectory(getSavePath(savename))

func create(savename) -> bool:
	if exists(savename):
		return false
	filesystem.makeDirectory(getSavePath(savename))
	return open(savename)
