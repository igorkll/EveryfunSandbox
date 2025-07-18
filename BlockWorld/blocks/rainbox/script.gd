extends block

static var shader = preload("res://blocks/rainbox/shader.gdshader")
static var mesh = preload("res://mesh/single_texture_block.obj")

func _ready():
	var light = OmniLight3D.new()
	light.omni_shadow_mode = OmniLight3D.SHADOW_CUBE
	add_child(light)

func __interact():
	self.__material.set_shader_parameter("reverse", not self.__material.get_shader_parameter("reverse"))
