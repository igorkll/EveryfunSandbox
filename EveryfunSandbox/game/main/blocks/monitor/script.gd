extends baseblock

func _ready():
	var plane := MeshInstance3D.new()
	plane.mesh = PlaneMesh.new()
	plane.scale = Vector3(0.5, 0.5, 0.5)
	plane.rotation_degrees = Vector3(0, 0, -90)
	plane.position = Vector3(0.6, 0, 0)
	add_child(plane)

	var material := StandardMaterial3D.new()
	# material.albedo_texture = viewport.get_texture()
	plane.material_override = material
