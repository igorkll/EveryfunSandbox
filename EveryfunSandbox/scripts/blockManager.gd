extends Node

static var node_root
static var node_main
static var autoChunkUpdate = false

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("main")
	
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

static func spawn(position, dynamic, blockname, quaternion=null, data=null, state=null):
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
	
	if not data:
		data = [{}, {}]
		
	if state:
		body.__state = state
	else:
		body.__state = {}
	
	body.__name = blockname
	body.___alldata = data
	body.___gamedata = data[0]
	body.__data = data[1]
		
	if dynamic:
		body.__rigid_body = body
		
	var box_collision = CollisionShape3D.new()
	box_collision.shape = BoxShape3D.new()
	body.add_child(box_collision)
	
	var chunk
	if dynamic:
		var _mesh = getMeshAndMaterial(blockscript)
					
		body.__material = _mesh[1]
		
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = _mesh[0]
		mesh_instance.material_override = _mesh[1]
		body.add_child(mesh_instance)
	else:
		chunk = chunkManager.getChunk(position)
		chunk.array[chunkManager.getChunkArrayPosition(position)] = blockname
		if autoChunkUpdate:
			chunk.updateMesh()

	if dynamic:
		node_main.get_node("world").get_node("dynamic").add_child(body)
	else:
		chunk.get_node("staticObjects").add_child(body)
	
	if "__firstInit" in body:
		if not "fi" in body.___gamedata or not body.___gamedata.fi: # first init
			body.__firstInit()
			body.___gamedata.fi = true
			
	if "__init" in body:
		body.__init()
	
	return body

static func destroy(blockobject):
	if not blockobject.__rigid_body:
		var chunk = chunkManager.getChunk(blockobject.position)
		var index = chunkManager.getChunkArrayPosition(blockobject.position)
		if chunk.array[index] == blockobject.__name:
			chunk.array[index] = null
			if autoChunkUpdate:
				chunk.updateMesh()
	blockobject.queue_free()
	
static func interact(blockobject):
	if "__interact" in blockobject:
		blockobject.__interact()

static func isDynamic(blockobject):
	return blockobject.get_parent() == node_main.get_node("world").get_node("dynamic")
	
static func isStatic(blockobject):
	return blockobject.get_parent().get_parent().get_parent() == node_main.get_node("world").get_node("chunks")
	
static func isBlock(blockobject):
	return isDynamic(blockobject) || isStatic(blockobject)

static func toDynamic(blockobject):
	if isStatic(blockobject):
		destroy(blockobject)
		return spawn(blockobject.position, true, blockobject.__name, blockobject.quaternion, blockobject.___alldata, blockobject.__state)
	return blockobject
	
static func snapBlockPosition(pos):
	return Vector3(roundf(pos.x), roundf(pos.y), roundf(pos.z))

static func toStatic(blockobject):
	if isDynamic(blockobject):
		destroy(blockobject)
		return spawn(snapBlockPosition(blockobject.position), false, blockobject.__name, null, blockobject.___alldata, blockobject.__state)
	return blockobject
