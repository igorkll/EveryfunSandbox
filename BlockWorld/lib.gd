extends Node

static func spawnBlock(world, position):
	var body = StaticBody3D.new()
	body.position = position
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	collision_shape.shape = box_shape
	body.add_child(collision_shape)
		
	var mesh_instance = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()
	mesh_instance.mesh = cube_mesh
	body.add_child(mesh_instance)
	
	var material = StandardMaterial3D.new()
	material.albedo_texture = preload("res://skybox.jpg")
	mesh_instance.material_override = material
	
	world.add_child(body)
