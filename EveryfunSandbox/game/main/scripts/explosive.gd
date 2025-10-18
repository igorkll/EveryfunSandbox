extends baseblock

func _ready():
	pass

func _use():
	game.playSound(game.soundList["explosion"], position)
	destroy()
