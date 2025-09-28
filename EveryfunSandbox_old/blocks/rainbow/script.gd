extends block

static var shader = preload("shader.gdshader")
static var mesh = preload("res://mesh/single_texture_block.obj")
static var allowChunkmesh = false

func updateState():
	self.__material.set_shader_parameter("reverse", self.__data.state)
	
func __initData():
	self.__data.state = false
	
func __initState():
	var light = OmniLight3D.new()
	light.omni_shadow_mode = OmniLight3D.SHADOW_CUBE
	__parents.add_child(light)

func __init():
	updateState()

func __interact():
	self.__data.state = not self.__data.state
	updateState()
