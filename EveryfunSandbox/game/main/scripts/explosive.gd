extends baseblock

func _ready():
	pass
	
func explode():
	advanced.explode(global_position, scriptData.explosiveLevel)
	game.playSound(game.soundList["explosion"], position)
	destroy()

func _use():
	explode()
	
func _explode():
	explode()
	return true
