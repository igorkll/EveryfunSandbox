extends Node

static var node_root
static var node_main

static var save_name
static var save_dir
static var save_chunk_dir

static var save_world
static var save_world_chunks
static var save_world_dynamic

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
	
	save_world_dynamic = Node3D.new()
	save_world_dynamic.name = "dynamicObjects"
	node_main.add_child(save_world_dynamic)

static func loadChunk(position):
	var chunk = chunkManager.getChunk(position)
	
	if chunk.loadThread != null:
		chunk.loadThread.wait_to_finish()
		chunk.loadThread = null
		
	chunk.loadThread = Thread.new()
	chunk.loadThread.start(_loadChunk.bind(chunk, position))
		
static func _loadChunk(chunk, position):
	var updateMesh = false
	
	var file = FileAccess.open(save_chunk_dir + "/" + chunkManager.getChunkName(position), FileAccess.READ)
	if file:
		var objects = bytes_to_var(file.get_buffer(file.get_length()))
		
		for staticObject in objects.staticObjects:
			blockManager.wspawn(staticObject.p, false, staticObject.n, chunk, null, staticObject.d)
			updateMesh = true
		
		for dynamicObject in objects.dynamicObjects:
			var body = blockManager.wspawn(dynamicObject.p, true, dynamicObject.n, chunk, dynamicObject.r, dynamicObject.d)
			body.linear_velocity = dynamicObject.v
			updateMesh = true
		
		file.close()
	else:
		updateMesh = worldGenerator.call(world_parameters.generator, chunk, position, world_parameters.seed)
	
	if updateMesh:
		chunk.call_deferred("updateMesh")
		
	chunk.loaded = true
	
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
		player.velocity = gamedata.player_velocity
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
		_parameters.generator = "random"
	
	if not _parameters.has("seed"):
		_parameters.seed = RandomNumberGenerator.new().randi_range(-2147483648, 2147483647)
		
	world_parameters = _parameters
	
	var player = node_main.get_node("player")
	chunkManager.updateLoadedChunks([player.position])
	
	save()
	
static func saveChunk(chunk, destroyDynamic=false):
	if chunk.loadThread != null:
		chunk.loadThread.wait_to_finish()
		chunk.loadThread = null
		
	if chunk.updateThread != null:
		chunk.updateThread.wait_to_finish()
		chunk.updateThread = null
	
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
		
		for dynamicObject in save_world_dynamic.get_children():
			if chunkManager.isObjectInChunk(dynamicObject.position, chunk.chunkPosition):
				chunkdata.dynamicObjects.append({
					p = dynamicObject.position,
					v = dynamicObject.linear_velocity,
					r = dynamicObject.quaternion,
					n = dynamicObject.__name,
					d = dynamicObject.___alldata
				})
				if destroyDynamic:
					dynamicObject.queue_free()
		
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
			player_velocity = player.velocity,
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
