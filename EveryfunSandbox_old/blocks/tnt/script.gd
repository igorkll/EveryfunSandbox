extends block

static var texture = preload("texture.png")
static var mesh = preload("res://mesh/single_texture_block.obj")

func __initState():
	__state.audio_before_explode = AudioStreamPlayer3D.new()
	__state.audio_before_explode.max_distance = 64
	__state.audio_before_explode.stream = preload("before_explode.mp3")
	__parents.add_child(__state.audio_before_explode)
	

func __interact():
	__state.audio_before_explode.play()
