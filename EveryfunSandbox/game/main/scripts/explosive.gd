extends baseblock

func _ready():
	pass
	
func __explode():
	advanced.explode(global_position, scriptData.explosiveLevel)
	game.playSound(game.soundList["explosion"], position)
	destroy()

func _use():
	timers.setTimeout(__explode, 4)
	
func _explode():
	__explode()
	return true
