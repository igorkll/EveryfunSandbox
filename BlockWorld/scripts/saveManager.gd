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
	
static func _recreateTree():
	save_world = node_main.get_node("world")
	if save_world:
		save_world.queue_free()
	
	save_world = Node3D.new()
	save_world.name = "world"
	node_main.add_child(save_world)
	
	save_world_dynamic = Node3D.new()
	save_world_dynamic.name = "dynamic"
	save_world.add_child(save_world_dynamic)
	
static func exists(name):
	return DirAccess.dir_exists_absolute(getSavePath(name))
	
static func open(name):
	_recreateTree()
	save_name = name
	save_dir = getSavePath(save_name)
	
	var file = FileAccess.open(save_dir + "/dynamic", FileAccess.READ)
	if file:
		var dynamic = bytes_to_var(file.get_buffer(file.get_length()))
		for rigidBodyData in dynamic:
			blockManager.spawn(rigidBodyData.p, rigidBodyData.r, true, rigidBodyData.n, rigidBodyData.d)
		file.close()

static func create(name):
	_recreateTree()
	save_name = name
	save_dir = getSavePath(save_name)
	
	DirAccess.make_dir_recursive_absolute(save_dir)

static func save():
	var file = FileAccess.open(save_dir + "/dynamic", FileAccess.WRITE)
	if file:
		var dynamic = []
		for rigidBody in save_world_dynamic.get_children():
			dynamic.append({
				p = rigidBody.position,
				r = rigidBody.quaternion,
				n = rigidBody.__name,
				d = rigidBody.___alldata
			})
			pass
			
		file.store_buffer(var_to_bytes(dynamic))
		file.close()
