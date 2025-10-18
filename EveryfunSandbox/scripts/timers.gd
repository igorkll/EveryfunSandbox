extends Node

var tps_60 = 1.0 / 60.0

func setTimeout(callback: Callable, delay_seconds: float) -> Timer:
	var timer = Timer.new()
	timer.wait_time = delay_seconds
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(func(): 
		callback.call()
		timer.queue_free()
	)
	get_tree().root.add_child.call_deferred(timer)
	return timer
	
func setInterval(callback: Callable, delay_seconds: float) -> Timer:
	var timer = Timer.new()
	timer.wait_time = delay_seconds
	timer.autostart = true
	timer.timeout.connect(func(): 
		if callback.call():
			clearTimeout(timer)
	)
	get_tree().root.add_child.call_deferred(timer)
	return timer

func clearTimeout(timer: Timer):
	if timer and is_instance_valid(timer):
		timer.stop()
		timer.queue_free()
