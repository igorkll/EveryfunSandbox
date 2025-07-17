extends Node

static func spawnBlock(world, position, dynamic, blockscript):
	var body
	if dynamic:
		body = RigidBody3D.new()
	else:
		body = StaticBody3D.new()
	
	body.position = position
	body.set_script(blockscript)
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	collision_shape.shape = box_shape
	body.add_child(collision_shape)

	var material
	if "shader" in blockscript:
		material = ShaderMaterial.new()
		material.shader = blockscript.shader
		material.set_shader_parameter("albedo_texture", blockscript.texture)
	else:
		material = StandardMaterial3D.new()
		material.albedo_texture = blockscript.texture
	
	var mesh_instance = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	mesh_instance.mesh = cube_mesh
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	world.add_child(body)
