extends block

static var texture = preload("texture.png")
static var mesh = preload("res://mesh/single_texture_block.obj")

func __interact():
	if __rigid_body:
		__rigid_body.apply_impulse(Vector3(0, 100, 0))
