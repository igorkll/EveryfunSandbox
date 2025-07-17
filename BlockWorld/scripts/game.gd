extends Node

static var block_mesh

func _ready():
	block_mesh = BoxMesh.new()

static func spawnBlock(world, position, dynamic, blockscript):
	var body
	if dynamic:
		body = RigidBody3D.new()
	else:
		body = StaticBody3D.new()
	
	body.position = position
	body.set_script(blockscript)
	
	var box_collision = CollisionShape3D.new()
	box_collision.shape = BoxShape3D.new()
	body.add_child(box_collision)

	var material
	if "shader" in blockscript:
		material = ShaderMaterial.new()
		material.shader = blockscript.shader
	else:
		material = StandardMaterial3D.new()
		material.albedo_texture = blockscript.texture
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = block_mesh
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	world.add_child(body)
