extends Node

static var node_root
static var node_main

static var save_name
static var save_dir
static var save_chunk_dir

static var save_world
static var save_world_dynamic
static var save_world_chunks

static var world_parameters

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("main")

static func getSavePath(name):
	return "user://saves/" + name
	
static func _recreateTree(name):
	save_name = name
	save_dir = getSavePath(save_name)
	save_chunk_dir = save_dir + "/chunks"
	
	if node_main.has_node("world"):
		save_world = node_main.get_node("world")
		if save_world:
			save_world.queue_free()
	
	save_world = Node3D.new()
	save_world.name = "world"
	node_main.add_child(save_world)
	
	save_world_chunks = Node3D.new()
	save_world_chunks.name = "chunks"
	save_world.add_child(save_world_chunks)
	
static func loadChunk(position):
	var oldAutoChunkUpdate = blockManager.autoChunkUpdate
	blockManager.autoChunkUpdate = false
	blockManager.blockSpawned = false
	
	var chunk = chunkManager.getChunk(position)
	var file = FileAccess.open(save_chunk_dir + "/" + chunkManager.getChunkName(position), FileAccess.READ)
	if file:
		if file:
			var objects = bytes_to_var(file.get_buffer(file.get_length()))
			
			for staticObject in objects.staticObjects:
				blockManager.spawn(staticObject.p, false, staticObject.n, chunk, null, staticObject.d)
			
			for dynamicObject in objects.dynamicObjects:
				blockManager.spawn(dynamicObject.p, true, dynamicObject.n, chunk, dynamicObject.r, dynamicObject.d)
			
			file.close()
	else:
		worldGenerator.call(world_parameters.generator, chunk, position, world_parameters.seed)
	
	blockManager.autoChunkUpdate = oldAutoChunkUpdate
	if blockManager.blockSpawned:
		chunk.updateMesh()
	
	return chunk
	
static func exists(name):
	return DirAccess.dir_exists_absolute(getSavePath(name))
	
static func open(name):
	_recreateTree(name)
	
	var player = node_main.get_node("player")
	var camera = player.get_node("camera")
	
	var file = FileAccess.open(save_dir + "/gamedata", FileAccess.READ)
	if file:
		var gamedata = bytes_to_var(file.get_buffer(file.get_length()))
		
		player.position = gamedata.player_position
		camera.total_pitch = gamedata.player_camera_total_pitch
		camera.quaternion = gamedata.player_camera_quaternion
		gameApi.setTime(gamedata.time)
			
		file.close()
		
	file = FileAccess.open(save_dir + "/parameters", FileAccess.READ)
	if file:
		world_parameters = bytes_to_var(file.get_buffer(file.get_length()))
		file.close()
		
	chunkManager.updateLoadedChunks([player.position])


static func create(name, _parameters={}):
	_recreateTree(name)
	
	DirAccess.make_dir_recursive_absolute(save_dir)
	DirAccess.make_dir_recursive_absolute(save_chunk_dir)
	
	if not _parameters.has("generator"):
		_parameters.generator = "flat_world"
	
	if not _parameters.has("seed"):
		_parameters.seed = RandomNumberGenerator.new().randi_range(-2147483648, 2147483647)
		
	world_parameters = _parameters
	
	var player = node_main.get_node("player")
	chunkManager.updateLoadedChunks([player.position])
	
static func saveChunk(chunk):
	var file = FileAccess.open(save_chunk_dir + "/" + chunkManager.getChunkName(chunk.chunkPosition), FileAccess.WRITE)
	if file:
		var chunkdata = {
			staticObjects = [],
			dynamicObjects = []
		}
		
		for staticObject in chunk.get_node("staticObjects").get_children():
			chunkdata.staticObjects.append({
				p = staticObject.position,
				n = staticObject.__name,
				d = staticObject.___alldata
			})
			pass
		
		for dynamicObject in chunk.get_node("dynamicObjects").get_children():
			chunkdata.dynamicObjects.append({
				p = dynamicObject.position,
				r = dynamicObject.quaternion,
				n = dynamicObject.__name,
				d = dynamicObject.___alldata
			})
			pass
		
		file.store_buffer(var_to_bytes(chunkdata))
		file.close()
		
static func saveAllChunks(): # сохраняет только загруженые в данный момент чанки!
	for chunk in save_world_chunks.get_children():
		saveChunk(chunk)

static func save():
	var file = FileAccess.open(save_dir + "/gamedata", FileAccess.WRITE)
	if file:
		var player = node_main.get_node("player")
		var camera = player.get_node("camera")
		
		var gamedata = {
			player_position = player.position,
			player_camera_total_pitch = camera.total_pitch,
			player_camera_quaternion = camera.quaternion,
			time = gameApi.getTime()
		}
			
		file.store_buffer(var_to_bytes(gamedata))
		file.close()
		
	file = FileAccess.open(save_dir + "/parameters", FileAccess.WRITE)
	if file:
		file.store_buffer(var_to_bytes(world_parameters))
		file.close()
		
	saveAllChunks()
