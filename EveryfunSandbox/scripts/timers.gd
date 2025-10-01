extends Node

var pending_timers: Array[SceneTreeTimer] = []

func setTimeout(callback: Callable, delay_seconds: float) -> Timer:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = delay_seconds
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(func(): 
		callback.call()
		timer.queue_free()
	)
	return timer

func clearTimeout(timer: Timer):
	if timer and is_instance_valid(timer):
		timer.stop()
		timer.queue_free()
