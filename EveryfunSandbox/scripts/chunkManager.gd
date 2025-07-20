extends Node

static var node_root
static var node_main

static var chunkWidth = 32
static var chunkHeight = 32

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("main")

static func getChunkName(position):
	var chunk_x = floor(position.x / chunkWidth)
	var chunk_y = floor(position.y / chunkHeight)
	var chunk_z = floor(position.z / chunkWidth)
	return str(chunk_x) + ":" + str(chunk_y) + ":" + str(chunk_z)

static func getChunkPosition(position):
	var chunk_x = floor(position.x / chunkWidth)
	var chunk_y = floor(position.y / chunkHeight)
	var chunk_z = floor(position.z / chunkWidth)
	return Vector3(chunk_x * chunkWidth, chunk_y * chunkHeight, chunk_z * chunkWidth)

static func getChunk(position):
	var chunkname = getChunkName(position)
	
	var chunks = node_main.get_node("world").get_node("chunks")
	var chunk = chunks.get_node(chunkname)
	if chunk:
		return chunk

	chunk = StaticBody3D.new()
	chunk.position = getChunkPosition(position)
	chunk.name = chunkname
	chunks.add_child(chunk)
	
	var meshlist = Node3D.new()
	meshlist.name = "meshlist"
	chunk.add_child(meshlist)
	
	return chunk

static func addCollision(position):
	var chunk = getChunk(position)
	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.transform.origin = position - getChunkPosition(position)
	chunk.add_child(collision)

static func addMesh(position, blockname):
	var chunk = getChunk(position)
	var meshlist = chunk.get_node("meshlist")
	
	var multiMeshInstance:MultiMeshInstance3D = meshlist.get_node(blockname)
	if not multiMeshInstance:
		multiMeshInstance = MultiMeshInstance3D.new()
		multiMeshInstance.name = blockname
		meshlist.add_child(multiMeshInstance)
		
		var multiMesh = MultiMesh.new()
		multiMesh.name = "multimesh"
		multiMeshInstance.multimesh = multiMesh
		multiMeshInstance.add_child(multiMesh)
