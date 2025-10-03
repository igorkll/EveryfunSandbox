extends PanelContainer

var timeout
var processAnimation = false
var minShowTime

var _defaultTimeout
var _freeWait = false

func _ready():
	self.material = ShaderMaterial.new()
	self.material.shader = preload("res://gui/panel.gdshader")

func _process(delta):
	if minShowTime != null:
		minShowTime -= delta
		if minShowTime <= 0 && _freeWait:
			queue_free()
			return
	
	material.set_shader_parameter("processAnimation", processAnimation)
	
	if timeout != null && _defaultTimeout == null:
		_defaultTimeout = timeout
	
	if timeout != null:
		timeout -= delta
		material.set_shader_parameter("timeout", timeout / _defaultTimeout)
		if timeout <= 0:
			task_end()
			timeout = null

func task_end():
	if minShowTime == null || minShowTime <= 0:
		queue_free()
	else:
		_freeWait = true
