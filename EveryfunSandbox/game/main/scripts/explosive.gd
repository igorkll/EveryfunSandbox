extends baseblock

func _ready():
	pass
	
func __explode():
	advanced.explode(global_position, scriptData.explosiveLevel)
	game.playSound(game.soundList["explosion"], position)
	destroy()

func _use():
	__explode()
	
func _explode():
	__explode()
	return true
