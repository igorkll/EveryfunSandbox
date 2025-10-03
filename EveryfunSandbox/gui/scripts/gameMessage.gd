extends PanelContainer

var timeout
var currentTimeout
var processAnimation = false

func _process(delta):
	material.set_shader_parameter("processAnimation", processAnimation)
	material.set_shader_parameter("timeout", 1)
	
	if currentTimeout != null:
		currentTimeout -= delta
		material.set_shader_parameter("timeout", currentTimeout / timeout)
		if currentTimeout <= 0:
			queue_free()
			currentTimeout = null
	
	if timeout != null && currentTimeout == null:
		currentTimeout = timeout
