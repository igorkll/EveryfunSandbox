extends baseblock

func _ready():
	var plane := MeshInstance3D.new()
	plane.mesh = PlaneMesh.new()
	plane.scale = Vector3(0.5, 0.5, 0.5) * 0.95
	plane.rotation_degrees = Vector3(90, 0, -90)
	plane.position = Vector3(0.501, 0, 0)
	add_child(plane)

	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/display.gdshader")
	material.set_shader_parameter("display_texture", get_tree().root.get_texture())
	material.set_shader_parameter("display_x", 16)
	material.set_shader_parameter("display_y", 16)
	plane.material_override = material
