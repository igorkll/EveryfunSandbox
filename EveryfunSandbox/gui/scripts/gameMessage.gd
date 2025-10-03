extends PanelContainer

var timeout
var currentTimeout
var minShowTime

var processAnimation = false
var freeWait = false

func _process(delta):
	if minShowTime != null:
		minShowTime -= delta
		if minShowTime <= 0 && freeWait:
			queue_free()
	
	material.set_shader_parameter("processAnimation", processAnimation)
	material.set_shader_parameter("timeout", 1)
	
	if currentTimeout != null:
		currentTimeout -= delta
		material.set_shader_parameter("timeout", currentTimeout / timeout)
		if currentTimeout <= 0:
			task_end()
			currentTimeout = null
	
	if timeout != null && currentTimeout == null:
		currentTimeout = timeout

func task_end():
	if minShowTime == null || minShowTime <= 0:
		queue_free()
	else:
		freeWait = true
