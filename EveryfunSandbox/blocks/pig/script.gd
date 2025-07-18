extends block

static var texture = preload("res://blocks/pig/texture.png")
static var mesh = preload("res://mesh/single_texture_block.obj")

func _physics_process(delta):
	if __rigid_body:
		__rigid_body.apply_impulse(Vector3(0, 0.15, 0))
