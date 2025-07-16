extends Node

static func spawnBlock(world, position):
	var rigid_body = RigidBody3D.new()
	rigid_body.position = position
	
	# Создаем CollisionShape3D
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()  # Создаем форму коллизии куба
	collision_shape.shape = box_shape
	
	# Создаем MeshInstance3D
	var mesh_instance = MeshInstance3D.new()
	var cube_mesh = BoxMesh.new()  # Создаем меш куба
	mesh_instance.mesh = cube_mesh
	
	# Добавляем CollisionShape3D и MeshInstance3D в RigidBody3D
	rigid_body.add_child(collision_shape)
	rigid_body.add_child(mesh_instance)
	
	# Добавляем RigidBody3D в текущую сцену
	world.add_child(rigid_body)
