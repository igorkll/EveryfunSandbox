extends Node

func setTimeout(callback: Callable, delay_seconds: float) -> Timer:
	var timer = Timer.new()
	timer.wait_time = delay_seconds
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(func(): 
		callback.call()
		timer.queue_free()
	)
	get_tree().root.add_child(timer)
	return timer

func clearTimeout(timer: Timer):
	if timer and is_instance_valid(timer):
		timer.stop()
		timer.queue_free()
