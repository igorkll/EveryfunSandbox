extends Node

static var node_root
static var node_main

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("Main")


static var save_name
static var save_dir
static var save_world
static var save_world_dynamic

static func getSavePath(name):
	return "user://saves/" + name

static func loadOrCreate(name):
	save_name = name
	save_dir = getSavePath(save_name)
	DirAccess.make_dir_recursive_absolute(save_dir)
	
	save_world = node_main.get_node("world")
	if save_world:
		save_world.queue_free()
	
	save_world = Node3D.new()
	save_world.name = "world"
	node_main.add_child(save_world)
	
	save_world_dynamic = Node3D.new()
	save_world_dynamic.name = "dynamic"
	save_world.add_child(save_world_dynamic)

static func save():
	var file = FileAccess.open(save_dir + "/dynamic.json", FileAccess.WRITE)
	if file:
		var dynamic = []
		for node in save_world_dynamic.get_children():
			dynamic.append({})
			pass
			
		file.store_buffer(var_to_bytes(dynamic))
		file.close()
