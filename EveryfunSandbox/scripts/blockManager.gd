extends Node

static var node_root
static var node_main
static var autoChunkUpdate = true
static var blockSpawned = false
static var blockList = []

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("main")
	
	var dir = DirAccess.open("res://blocks")

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir(): 
				blockList.append(file_name)
			file_name = dir.get_next()

		dir.list_dir_end()
	
static func getMeshAndMaterial(blockscript):
	if "mesh" in blockscript:
		var mesh = blockscript.mesh

		var material
		if "shader" in blockscript:
			material = ShaderMaterial.new()
			material.shader = blockscript.shader
			if "texture" in blockscript:
				material.set_shader_parameter("__texture", blockscript.texture)
		else:
			material = StandardMaterial3D.new()
			if "texture" in blockscript:
				material.albedo_texture = blockscript.texture
				
		return [mesh, material]


static func getBlockscript(blockname):
	return load("res://blocks/" + blockname + "/script.gd")

static func spawn(position, dynamic, blockname, chunk=null, quaternion=null, data=null, state=null, parentsNode=null):
	blockSpawned = true
	
	var blockscript = getBlockscript(blockname)
	
	var body
	if dynamic:
		body = RigidBody3D.new()
		body.position = position
	else:
		body = StaticBody3D.new()
		body.position = position
	
	if quaternion:
		body.quaternion = quaternion
	
	body.set_script(blockscript)
	body.__name = blockname
	if dynamic:
		body.__rigid_body = body
	
	if not data:
		data = [{}, {}]
	
	body.___alldata = data
	body.___gamedata = data[0]
	body.__data = data[1]
		
	if not state:
		state = [{}, {}]
	
	body.___allstate = state
	body.___gamestate = state[0]
	body.__state = state[1]
		
	var box_collision = CollisionShape3D.new()
	box_collision.shape = BoxShape3D.new()
	body.add_child(box_collision)
	
	if parentsNode:
		parentsNode.get_parent().remove_child(parentsNode)
	else:
		parentsNode = Node3D.new()

	body.add_child(parentsNode)
	body.__parents = parentsNode
	
	var allowChunkmesh = true
	if "allowChunkmesh" in blockscript:
		allowChunkmesh = blockscript.allowChunkmesh

	if not chunk:
		chunk = chunkManager.getChunk(position)

	if dynamic || not allowChunkmesh:
		var _mesh = getMeshAndMaterial(blockscript)
					
		body.__material = _mesh[1]
		
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = _mesh[0]
		mesh_instance.material_override = _mesh[1]
		body.add_child(mesh_instance)
	else:
		chunk.array[chunkManager.getChunkArrayPosition(position)] = blockname
		chunk.deltaUseCount(blockname, 1)
		if autoChunkUpdate:
			chunk.updateMesh()

	if dynamic:
		node_main.get_node("dynamicObjects").add_child(body)
	else:
		chunk.get_node("staticObjects").add_child(body)
	
	if "__initData" in body:
		if not "inited" in body.___gamedata or not body.___gamedata.inited:
			body.__initData()
			body.___gamedata.inited = true
			
	if "__initState" in body:
		if not "inited" in body.___gamestate or not body.___gamestate.inited:
			body.__initState()
			body.___gamestate.inited = true
			
	if "__init" in body:
		body.__init()
	
	return body

static func destroy(blockobject):
	if isStatic(blockobject):
		var chunk = chunkManager.getChunk(blockobject.position)
		var index = chunkManager.getChunkArrayPosition(blockobject.position)
		if chunk.array[index] == blockobject.__name:
			chunk.deltaUseCount(blockobject.__name, -1)
			chunk.array[index] = null
			if autoChunkUpdate:
				chunk.updateMesh()
	blockobject.queue_free()
	
static func interact(blockobject):
	if "__interact" in blockobject:
		blockobject.__interact()

static func isDynamic(blockobject):
	return blockobject.get_parent().name == "dynamicObjects"
	
static func isStatic(blockobject):
	return blockobject.get_parent().name == "staticObjects"
	
static func isBlock(blockobject):
	return isDynamic(blockobject) || isStatic(blockobject)

static func toDynamic(blockobject):
	if isStatic(blockobject):
		var newBlock = spawn(blockobject.position, true, blockobject.__name, null, blockobject.quaternion, blockobject.___alldata, blockobject.___allstate, blockobject.__parents)
		destroy(blockobject)
		return newBlock
	
	return blockobject
	
static func snapBlockPosition(pos):
	return Vector3(roundf(pos.x), roundf(pos.y), roundf(pos.z))

static func toStatic(blockobject):
	if isDynamic(blockobject):
		var newBlock = spawn(snapBlockPosition(blockobject.position), false, blockobject.__name, null, null, blockobject.___alldata, blockobject.___allstate, blockobject.__parents)
		destroy(blockobject)
		return newBlock
	
	return blockobject
