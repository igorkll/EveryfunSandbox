extends baseblock

var material
var mesh_instance

func _ready():
	material = StandardMaterial3D.new()
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = Vector3(1.2, 0.5, 1.2)
	mesh_instance.material_override = material
	add_child(mesh_instance)
	
	updateColor()
	
func updateColor():
	if storageData.get("state", false):
		material.albedo_color = Color(1, 0, 0)
	else:
		material.albedo_color = Color(0, 1, 0)

func _use():
	storageData.set("state", not storageData.get("state", false))
	updateColor()
