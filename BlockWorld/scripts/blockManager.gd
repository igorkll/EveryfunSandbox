extends Node

static var node_root
static var node_main

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("Main")

static func spawn(position, quaternion, dynamic, blockname):
	var blockscript = load("res://blocks/" + blockname + "/script.gd")
	
	var body
	if dynamic:
		body = RigidBody3D.new()
		if quaternion:
			body.quaternion = quaternion
	else:
		body = StaticBody3D.new()
	
	body.position = position
	body.set_script(blockscript)
	
	body.__name = blockname
	
	if dynamic:
		body.__rigid_body = body
	else:
		body.__static_body = body
	
	var box_collision = CollisionShape3D.new()
	box_collision.shape = BoxShape3D.new()
	body.add_child(box_collision)

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
			
		body.__material = material
		
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = mesh
		mesh_instance.material_override = material
		body.add_child(mesh_instance)

	if dynamic:
		node_main.get_node("world").get_node("dynamic").add_child(body)
	else:
		node_main.get_node("world").add_child(body)
	
	return body

static func destroy(blockobject):
	blockobject.queue_free()
	
static func interact(blockobject):
	if "__interact" in blockobject:
		blockobject.__interact()

static func isBlock(blockobject):
	return blockobject is RigidBody3D || blockobject is StaticBody3D
	
