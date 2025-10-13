extends baseblock

func _ready():
	var plane := MeshInstance3D.new()
	plane.mesh = PlaneMesh.new()
	plane.scale = Vector3(0.5, 0.5, 0.5)
	plane.rotation_degrees = Vector3(90, 0, -90)
	plane.position = Vector3(0.501, 0, 0)
	add_child(plane)
	
	var viewport = SubViewport.new()
	viewport.size = Vector2(512, 512)
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	
	var camera = Camera3D.new()
	viewport.add_child(camera)
	camera.look_at(Vector3(1,0,0), Vector3.UP)

	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/display.gdshader")
	material.set_shader_parameter("display_texture", viewport.get_texture())
	plane.material_override = material
