extends baseblock

func _ready():
	var plane := MeshInstance3D.new()
	plane.mesh = PlaneMesh.new()
	plane.scale = Vector3(0.5 * multiblockRelative.x, 0.5, 0.5 * multiblockRelative.y)
	plane.rotation_degrees = Vector3(90, 0, -90)
	plane.position = Vector3(0.501, 0, 0)
	add_child(plane)
	
	var viewport = SubViewport.new()
	viewport.size = Vector2(512 * (float(multiblockRelative.x) / float(multiblockRelative.y)), 512)
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	viewport.set_use_hdr_2d(game.hdrState)
	add_child(viewport)
	
	var camera = Camera3D.new()
	viewport.add_child(camera)
	camera.projection = Camera3D.PROJECTION_FRUSTUM
	camera.position = position
	camera.near = 0.5 - 0.1
	camera.size = multiblockRelative.y - 0.2
	camera.look_at(camera.position + Vector3(voxelDirection), Vector3(voxelDirectionUp))

	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/display.gdshader")
	material.set_shader_parameter("display_texture", viewport.get_texture())
	material.set_shader_parameter("display_flip_x", true)
	plane.material_override = material
