extends baseblock

func _ready():
	var node = Node3D.new()
	node.position = Vector3(0.25, 0.2, 0)
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = Vector3(1, 0.5, 0.5)
	node.add_child(mesh_instance)
	
	add_child(node)
