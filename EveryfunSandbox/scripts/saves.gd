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

func save():
	if currentWorldName == null:
		return
	
	game.terrain.save()

func unload():
	if currentWorldName == null:
		return
	
	for child in objects.get_children():
		child.queue_free()
	
	game.terrain = null
	currentWorldName = null

func open(name):
	currentWorldName = name
	
	var terrainScript = preload("res://scripts/terrain.gd")
	var terrain = VoxelLodTerrain.new()
	terrain.name = "terrain"
	terrain.set_script(terrainScript)
	objects.add_child(terrain)
	
	terrain.init()

func create(name):
	filesystem.makeDirectory(getPathInSave(".", name))
	open(name)
