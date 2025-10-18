extends baseblock

func _ready():
	pass
	
func _explode():
	advanced.explode(global_position, scriptData.explosiveLevel)
	game.playSound(game.soundList["explosion"], position)
	destroy()

func _use():
	_explode()
