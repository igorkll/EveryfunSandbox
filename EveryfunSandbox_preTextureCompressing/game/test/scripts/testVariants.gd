extends baseblock

var counter = 0

func _use():
	setVariant(1 - getVariant())
	counter += 1
	print(counter)
