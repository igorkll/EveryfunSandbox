extends Node

static var node_root
static var node_main

static var save_name
static var save_dir
static var save_chunk_dir

static var save_world
static var save_world_dynamic
static var save_world_chunks

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("main")

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
	
	save_world_chunks = Node3D.new()
	save_world_chunks.name = "chunks"
	save_world.add_child(save_world_chunks)
	
static func exists(name):
	# return DirAccess.dir_exists_absolute(getSavePath(name))
	return false
	
static func open(name):
	_recreateTree()
	save_name = name
	save_dir = getSavePath(save_name)
	
	var file = FileAccess.open(save_dir + "/dynamic", FileAccess.READ)
	if file:
		var dynamic = bytes_to_var(file.get_buffer(file.get_length()))
		for rigidBodyData in dynamic:
			blockManager.spawn(rigidBodyData.p, true, rigidBodyData.n, rigidBodyData.r, rigidBodyData.d)
		
		file.close()
		
	file = FileAccess.open(save_dir + "/gamedata", FileAccess.READ)
	if file:
		var gamedata = bytes_to_var(file.get_buffer(file.get_length()))
		
		var player = node_main.get_node("player")
		var camera = player.get_node("camera")
		
		player.position = gamedata.player_position
		camera.total_pitch = gamedata.player_camera_total_pitch
		camera.quaternion = gamedata.player_camera_quaternion
			
		file.close()

static func create(name):
	_recreateTree()
	save_name = name
	save_dir = getSavePath(save_name)
	save_chunk_dir = save_dir + "/chunks"
	
	DirAccess.make_dir_recursive_absolute(save_dir)
	DirAccess.make_dir_recursive_absolute(save_chunk_dir)
	
static func saveChunk(chunk):
	if chunk.chunkUpdated:
		chunk.chunkUpdated = false
		var file = FileAccess.open(save_chunk_dir + "/" + chunkManager.getChunkName(chunk.chunkPosition), FileAccess.WRITE)
		if file:
			var staticObjects = []
			for staticObject in chunk.get_node("staticObjects").get_children():
				staticObjects.append({
					p = staticObject.position,
					n = staticObject.__name,
					d = staticObject.___alldata
				})
				pass
				
			file.store_buffer(var_to_bytes(staticObjects))
			file.close()
		
static func saveAllChunks(): # сохраняет только загруженые в данный момент чанки!
	for chunk in save_world_chunks.get_children():
		saveChunk(chunk)

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
		
	file = FileAccess.open(save_dir + "/gamedata", FileAccess.WRITE)
	if file:
		var player = node_main.get_node("player")
		var camera = player.get_node("camera")
		
		var gamedata = {
			player_position = player.position,
			player_camera_total_pitch = camera.total_pitch,
			player_camera_quaternion = camera.quaternion
		}
			
		file.store_buffer(var_to_bytes(gamedata))
		file.close()
		
	saveAllChunks()
