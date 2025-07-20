extends block

static var texture = preload("texture.png")
static var mesh = preload("res://mesh/single_texture_block.obj")

func jump():
	__rigid_body.apply_impulse(Vector3(0, 25, 0))

func __init():
	if "jump" in __data && __data.jump && __rigid_body:
		jump()
		__data.jump = false

func __interact():
	if __rigid_body:
		jump()
	else:
		__data.jump = true
		blockManager.toDynamic(self)
