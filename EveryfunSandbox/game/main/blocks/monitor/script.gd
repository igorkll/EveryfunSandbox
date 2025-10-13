extends baseblock

func _ready():
	var plane := MeshInstance3D.new()
	plane.mesh = PlaneMesh.new()
	plane.scale = Vector3(0.5, 0.5, 0.5) * 0.8
	plane.rotation_degrees = Vector3(90, 0, -90)
	plane.position = Vector3(0.51, 0, 0)
	add_child(plane)

	var material := StandardMaterial3D.new()
	material.albedo_texture = get_tree().root.get_texture()
	plane.material_override = material
