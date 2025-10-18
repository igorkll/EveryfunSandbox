extends baseblock

func _ready():
	print("C ", getVariant())

func _use():
	print("OLD ", getVariant())
	setVariant(1 - getVariant())
	print("NEW ", getVariant())
