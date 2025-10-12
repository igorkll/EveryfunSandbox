extends Node3D

func _ready():
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = Vector3(1.5, 0.5, 0.5)
	add_child(mesh_instance)
