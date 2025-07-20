extends Node

static var node_root
static var node_main

static var chunkSize = 32

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("main")

static func getChunkName(position):
	var chunk_x: int = floor(position.x / chunkSize)
	var chunk_y: int = floor(position.y / chunkSize)
	var chunk_z: int = floor(position.z / chunkSize)
	return str(chunk_x) + "_" + str(chunk_y) + "_" + str(chunk_z)

static func getChunkPosition(position):
	var chunk_x = floor(position.x / chunkSize)
	var chunk_y = floor(position.y / chunkSize)
	var chunk_z = floor(position.z / chunkSize)
	return Vector3(chunk_x * chunkSize, chunk_y * chunkSize, chunk_z * chunkSize)
	
static func getChunkInternalPosition(position):
	var chunk_x = int(position.x) % chunkSize
	var chunk_y = int(position.y) % chunkSize
	var chunk_z = int(position.z) % chunkSize
	return chunk_x + (chunk_y * chunkSize) + (chunk_z * chunkSize * chunkSize)

static func getChunk(position):
	var chunkname = getChunkName(position)
	
	var chunks = node_main.get_node("world").get_node("chunks")
	var chunk = chunks.get_node(chunkname)
	if chunk:
		return chunk

	chunk = Chunk.new()
	chunk.position = getChunkPosition(position)
	chunk.name = chunkname
	chunks.add_child(chunk)
	
	return chunk
