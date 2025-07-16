extends Node

static func spawnBlock(world, position):
	var body = StaticBody3D.new()
	body.position = position
	
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()  # Создаем форму коллизии куба
	collision_shape.shape = box_shape
	body.add_child(collision_shape)
		
	var mesh_instance = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()  # Создаем меш куба
	mesh_instance.mesh = cube_mesh
	body.add_child(mesh_instance)
	
	world.add_child(body)
