extends baseblock

var timer
var hasExploded = false

func _ready():
	pass
	
func __explode():
	if hasExploded:
		return
	hasExploded = true
	
	timers.clearTimeout(timer)
	
	advanced.explode(global_position, scriptData.explosiveLevel)
	game.playSound(game.soundList["explosion"], position)
	destroy()

func _use():
	if timer != null:
		__explode()
		return

	timer = timers.setTimeout(__explode, 4)
	
func _explode():
	__explode()
	return true
