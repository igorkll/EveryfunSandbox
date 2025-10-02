extends Node

var currentWorldName = null
var objects

func _ready():
	objects = get_node("/root/main/objects")
	create("test")
	
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
	return true

func open(savename) -> bool:
	if not exists(savename):
		return false
	
	unload()
	currentWorldName = savename
	
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
