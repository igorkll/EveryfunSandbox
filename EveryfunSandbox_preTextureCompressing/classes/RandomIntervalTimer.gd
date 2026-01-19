extends Node

class_name RandomIntervalTimer

@export var interval := 1.0             # базовый интервал
@export var random_interval := 0.0      # случайный допуск ± random_interval
var _callback = null
var _timer := 0.0

func start(callback: Callable):
	_callback = callback
	_set_next_timer()

func stop():
	_callback = null

func _process(delta):
	if _callback == null:
		return
	_timer -= delta
	if _timer <= 0.0:
		_callback.call()
		_set_next_timer()

func _set_next_timer():
	var random_offset = 0.0
	if random_interval > 0.0:
		random_offset = randf_range(-random_interval, random_interval)
	_timer = max(0.0, interval + random_offset)
