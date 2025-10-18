extends baseblock

func _use():
	setVariant(1 - getVariant())
