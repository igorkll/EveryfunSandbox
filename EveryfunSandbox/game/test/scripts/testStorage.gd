extends baseblock

var material
var mesh_instance

func _ready():
	material = StandardMaterial3D.new()
	
	var node = Node3D.new()
	node.position = Vector3(0.25, 0.2, 0)
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = Vector3(1, 0.5, 0.5)
	mesh_instance.material_override = material
	node.add_child(mesh_instance)
	
	add_child(node)
	updateColor()
	
func updateColor():
	if storageData.get("state", false):
		material.albedo_color = Color(1, 0, 0)
	else:
		material.albedo_color = Color(0, 1, 0)

func _use():
	storageData.set("state", not storageData.get("state", false))
	updateColor()
