extends Node

static var node_root
static var node_main

static var chunkSize = 32
static var chunkLoadingRadius = 1

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("main")

static func getChunkName(position, offsetX = 0, offsetZ = 0):
	var chunk_x: int = floor(position.x / chunkSize)
	var chunk_y: int = floor(position.y / chunkSize)
	var chunk_z: int = floor(position.z / chunkSize)
	return str(chunk_x + offsetX) + "_" + str(chunk_y) + "_" + str(chunk_z + offsetZ)

static func getChunkPosition(position):
	var chunk_x = floor(position.x / chunkSize)
	var chunk_y = floor(position.y / chunkSize)
	var chunk_z = floor(position.z / chunkSize)
	return Vector3(chunk_x * chunkSize, chunk_y * chunkSize, chunk_z * chunkSize)
	
static func getChunkArrayPosition(position):
	var chunk_x = wrapi(int(position.x), 0, chunkSize)
	var chunk_y = wrapi(int(position.y), 0, chunkSize)
	var chunk_z = wrapi(int(position.z), 0, chunkSize)
	return chunk_x + (chunk_y * chunkSize) + (chunk_z * chunkSize * chunkSize)
	
static func getChunkInternalPosition(position):
	var chunk_x = wrapi(int(position.x), 0, chunkSize)
	var chunk_y = wrapi(int(position.y), 0, chunkSize)
	var chunk_z = wrapi(int(position.z), 0, chunkSize)
	return Vector3(chunk_x, chunk_y, chunk_z)

static func getChunk(position):
	var chunkname = getChunkName(position)
	
	var chunks = node_main.get_node("world").get_node("chunks")
	var chunk = chunks.get_node(chunkname)
	if chunk:
		return chunk

	chunk = Chunk.new()
	chunk.name = chunkname
	chunk.chunkPosition = chunkManager.getChunkPosition(position)
	for iz in range(chunkManager.chunkSize):
		for iy in range(chunkManager.chunkSize):
			for ix in range(chunkManager.chunkSize):
				chunk.array.append(null)
	chunks.add_child(chunk)
	
	var staticObjects = Node3D.new()
	staticObjects.name = "staticObjects"
	chunk.add_child(staticObjects)
	
	return chunk
	
static func unloadChunk(chunk):
	saveManager.saveChunk(chunk)
	chunk.queue_free()

static func updateLoadedChunks(position):
	for ix in range(-chunkLoadingRadius, chunkLoadingRadius + 1):
		for iz in range(-chunkLoadingRadius, chunkLoadingRadius + 1):
			saveManager.loadChunk(getChunkName(position, ix, iz))
